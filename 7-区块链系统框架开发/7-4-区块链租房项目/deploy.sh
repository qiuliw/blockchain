#!/usr/bin/env bash
# HKZF 唯一部署入口：Fabric (Docker) + 链码 + minikube (K8s 应用)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
DEPLOY="$ROOT/deploy"
FABRIC="$DEPLOY/fabric"
VOL="${FABRIC_VOLUME:-hkzf-fabric-data}"

ORGS_K8S="/fabric/organizations"
MSP_K8S="/fabric/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp"
PEER_TLS_K8S="/fabric/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls"
ORDERER_TLS_K8S="/fabric/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls"

log() { echo "[deploy] $*"; }

usage() {
  cat <<EOF
用法: $0 [命令]

  up      全栈部署（Fabric + 链码 + minikube + 应用），默认命令
  app     仅重建并发布应用（Fabric 已在运行时）
  stop    停止 localhost port-forward

示例:
  $0
  $0 app
  $0 stop
EOF
}

sync_fabric_certs() {
  if [ ! -f "$FABRIC/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" ]; then
    log "sync fabric certs: volume ${VOL} -> ${FABRIC}"
    mkdir -p "$FABRIC/organizations"
    rm -rf "$FABRIC/organizations"/*
    docker run --rm -v "${VOL}:/fabric" hyperledger/fabric-tools:2.5.12 \
      sh -c 'tar -C /fabric/organizations -cf - .' | tar -xf - -C "$FABRIC/organizations"
  fi
}

ensure_minikube_mount() {
  if minikube ssh -- "test -d /fabric/organizations/peerOrganizations/org1.example.com" 2>/dev/null; then
    return
  fi
  log "restart minikube with fabric mount"
  minikube stop
  minikube start --driver=docker --cpus=2 --memory=4096 \
    --mount-string "${FABRIC}:/fabric" --mount
}

build_app_images() {
  eval "$(minikube docker-env)"
  bash "$DEPLOY/scripts/build-images.sh" app
}

apply_k8s() {
  kubectl apply -f "$DEPLOY/k8s/namespace.yaml"
  sed \
    -e "s|FABRIC_ORGS_HOST_PATH|$ORGS_K8S|g" \
    -e "s|FABRIC_MSP_HOST_PATH|$MSP_K8S|g" \
    -e "s|FABRIC_PEER_TLS_HOST_PATH|$PEER_TLS_K8S|g" \
    -e "s|FABRIC_ORDERER_TLS_HOST_PATH|$ORDERER_TLS_K8S|g" \
    "$DEPLOY/k8s/hkzf-api.yaml" | kubectl apply -f -
  kubectl apply -f "$DEPLOY/k8s/hkzf-web.yaml"
}

wait_rollout() {
  kubectl -n hkzf rollout status deployment/hkzf-api --timeout=180s
  kubectl -n hkzf rollout status deployment/hkzf-web --timeout=120s
}

cmd_up() {
  log "启动 Fabric (Docker)"
  cd "$DEPLOY"
  chmod +x scripts/*.sh
  docker rm -f orderer.example.com peer0.org1.example.com peer0.org2.example.com fabric-bootstrap fabric-crypto 2>/dev/null || true
  docker compose up fabric-crypto
  docker compose up -d orderer.example.com peer0.org1.example.com peer0.org2.example.com
  sleep 8
  docker compose up fabric-bootstrap

  log "部署链码 (CCAAS)"
  bash "$DEPLOY/scripts/deploy-chaincode.sh"

  log "启动 minikube"
  minikube stop 2>/dev/null || true
  minikube start --driver=docker --cpus=2 --memory=4096 \
    --mount-string "$FABRIC:/fabric" --mount 2>/dev/null || \
  minikube start --driver=docker --cpus=2 --memory=4096

  sync_fabric_certs
  build_app_images
  apply_k8s
  wait_rollout

  bash "$DEPLOY/scripts/port-forward-local.sh" start

  IP="$(minikube ip)"
  echo ""
  echo "=========================================="
  echo " HKZF 已部署 (minikube)"
  echo " 访问: http://127.0.0.1:30888/auth.html"
  echo " NodePort: http://${IP}:30888/auth.html"
  echo " Fabric peer: host.minikube.internal:7051"
  echo "=========================================="
}

cmd_app() {
  sync_fabric_certs
  ensure_minikube_mount
  build_app_images
  apply_k8s
  kubectl -n hkzf delete pod -l app=hkzf-api --force --grace-period=0 2>/dev/null || true
  wait_rollout
  bash "$DEPLOY/scripts/port-forward-local.sh" start

  log "verify"
  kubectl exec -n hkzf deploy/hkzf-web -- wget -qO- \
    "http://hkzf-api:8080/auth?name=%E5%BC%A0%E4%B8%89&id=211004197001010000" || true
  echo ""
  echo "访问: http://127.0.0.1:30888/auth.html"
}

cmd_stop() {
  bash "$DEPLOY/scripts/port-forward-local.sh" stop
}

main() {
  case "${1:-up}" in
    up) cmd_up ;;
    app) cmd_app ;;
    stop) cmd_stop ;;
    -h|--help|help) usage ;;
    *)
      echo "未知命令: $1"
      usage
      exit 1
      ;;
  esac
}

main "$@"
