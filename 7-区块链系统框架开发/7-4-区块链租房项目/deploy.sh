#!/usr/bin/env bash
# HKZF 唯一部署入口（构建见 deploy/build.sh）
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
DEPLOY="$ROOT/deploy"
FABRIC_NS="${FABRIC_NS:-fabric}"
APP_NS="${APP_NS:-hkzf}"
WEB_PORT="${WEB_PORT:-30888}"
PF_PID_FILE="/tmp/hkzf-port-forward.pid"

log() { echo "[deploy] $*"; }

usage() {
  cat <<EOF
用法: $0 <命令>

部署:
  up        全栈（minikube + 链 + 业务）
  chain     仅 Fabric 网络与链码
  app       仅业务应用（需 chain 已就绪）
  stop      停止 port-forward
  forward   启动 Web port-forward（业务已部署时可用）

构建:
  build           构建全部镜像（等同 build.sh all）
  build-app       仅 hkzf-api / hkzf-web

示例:
  $0 build-app && $0 chain && $0 app
  $0 up
EOF
}

ensure_minikube() {
  if ! minikube status >/dev/null 2>&1; then
    log "start minikube"
    minikube start --driver=docker --cpus=4 --memory=6144
  fi
  eval "$(minikube docker-env)"
}

run_build() {
  ensure_minikube
  bash "$DEPLOY/build.sh" "${1:-all}"
}

sync_app_fabric_certs() {
  local tmp="/tmp/hkzf-fabric-certs-$$"
  trap 'rm -rf "$tmp"' RETURN
  mkdir -p "$tmp/msp" "$tmp/peer-tls" "$tmp/orderer-tls"

  kubectl -n "$FABRIC_NS" exec deploy/peer0-org1 -- tar -C /fabric/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp -cf - . \
    | tar -xf - -C "$tmp/msp"
  kubectl -n "$FABRIC_NS" exec deploy/peer0-org1 -- tar -C /fabric/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls -cf - . \
    | tar -xf - -C "$tmp/peer-tls"
  kubectl -n "$FABRIC_NS" exec deploy/peer0-org1 -- tar -C /fabric/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls -cf - . \
    | tar -xf - -C "$tmp/orderer-tls"

  tar -cf "$tmp/msp.tar" -C "$tmp" msp
  tar -cf "$tmp/peer-tls.tar" -C "$tmp" peer-tls
  tar -cf "$tmp/orderer-tls.tar" -C "$tmp" orderer-tls

  kubectl create namespace "$APP_NS" 2>/dev/null || true
  kubectl -n "$APP_NS" delete secret fabric-msp-bundle fabric-peer-tls-bundle fabric-orderer-tls-bundle --ignore-not-found
  kubectl -n "$APP_NS" create secret generic fabric-msp-bundle --from-file=msp.tar="$tmp/msp.tar"
  kubectl -n "$APP_NS" create secret generic fabric-peer-tls-bundle --from-file=peer-tls.tar="$tmp/peer-tls.tar"
  kubectl -n "$APP_NS" create secret generic fabric-orderer-tls-bundle --from-file=orderer-tls.tar="$tmp/orderer-tls.tar"
  log "fabric certs synced to namespace ${APP_NS}"
}

apply_app() {
  sync_app_fabric_certs
  kubectl apply -f "$DEPLOY/k8s/app/namespace.yaml"
  kubectl apply -f "$DEPLOY/k8s/app/hkzf-api.yaml"
  kubectl apply -f "$DEPLOY/k8s/app/hkzf-web.yaml"
}

wait_app() {
  kubectl -n "$APP_NS" rollout status deployment/hkzf-api --timeout=180s
  kubectl -n "$APP_NS" rollout status deployment/hkzf-web --timeout=120s
}

port_forward_cmd() {
  echo "kubectl -n ${APP_NS} port-forward --address 0.0.0.0 svc/hkzf-web ${WEB_PORT}:80"
}

port_forward_stop() {
  if [[ -f "$PF_PID_FILE" ]]; then
    kill "$(cat "$PF_PID_FILE")" 2>/dev/null || true
    rm -f "$PF_PID_FILE"
  fi
  pkill -f "kubectl -n ${APP_NS} port-forward svc/hkzf-web" 2>/dev/null || true
}

port_forward_start() {
  port_forward_stop
  kubectl -n "$APP_NS" port-forward --address 0.0.0.0 "svc/hkzf-web" "${WEB_PORT}:80" \
    >/tmp/hkzf-port-forward.log 2>&1 &
  echo $! >"$PF_PID_FILE"
  sleep 2
  if ! kill -0 "$(cat "$PF_PID_FILE")" 2>/dev/null; then
    cat /tmp/hkzf-port-forward.log
    exit 1
  fi
  log "port-forward 已启动 (PID $(cat "$PF_PID_FILE"))"
  log "访问: http://127.0.0.1:${WEB_PORT}/"
  log "关于: http://127.0.0.1:${WEB_PORT}/about.html"
  log "转发命令: $(port_forward_cmd)"
  log "停止转发: $0 stop"
}

cmd_chain() {
  ensure_minikube
  chmod +x "$DEPLOY/build.sh" "$DEPLOY/scripts/"*.sh
  bash "$DEPLOY/scripts/deploy-fabric-k8s.sh"
  bash "$DEPLOY/scripts/deploy-chaincode-k8s.sh"
  log "chain ready (ns ${FABRIC_NS})"
}

cmd_app() {
  run_build app
  apply_app
  kubectl -n "$APP_NS" delete pod -l app=hkzf-api --force --grace-period=0 2>/dev/null || true
  wait_app
  port_forward_start
}

cmd_up() {
  cmd_chain
  cmd_app
}

cmd_forward() {
  kubectl -n "$APP_NS" get svc/hkzf-web >/dev/null 2>&1 || {
    log "hkzf-web 未就绪，请先执行: $0 app"
    exit 1
  }
  port_forward_start
}

cmd_stop() {
  port_forward_stop
}

main() {
  case "${1:-up}" in
    up) cmd_up ;;
    chain) cmd_chain ;;
    app) cmd_app ;;
    forward) cmd_forward ;;
    build) run_build all ;;
    build-app) run_build app ;;
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
