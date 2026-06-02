#!/usr/bin/env bash
# HKZF 部署入口：链 (fabric ns) 与业务 (hkzf ns) 分离，全 K8s
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
DEPLOY="$ROOT/deploy"

log() { echo "[deploy] $*"; }

usage() {
  cat <<EOF
用法: $0 [命令]

  up      全栈：minikube + 链 + 业务（默认）
  chain   仅部署 Fabric 网络与链码（namespace: fabric）
  app     仅部署业务应用（namespace: hkzf，需 chain 已就绪）
  stop    停止 localhost port-forward

示例:
  $0 chain && $0 app
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

build_app_images() {
  bash "$DEPLOY/scripts/build-images.sh" app
}

apply_app() {
  bash "$DEPLOY/scripts/sync-app-fabric-certs.sh"
  kubectl apply -f "$DEPLOY/k8s/app/namespace.yaml"
  kubectl apply -f "$DEPLOY/k8s/app/hkzf-api.yaml"
  kubectl apply -f "$DEPLOY/k8s/app/hkzf-web.yaml"
}

wait_app() {
  kubectl -n hkzf rollout status deployment/hkzf-api --timeout=180s
  kubectl -n hkzf rollout status deployment/hkzf-web --timeout=120s
}

cmd_chain() {
  ensure_minikube
  chmod +x "$DEPLOY/scripts/"*.sh
  bash "$DEPLOY/scripts/deploy-fabric-k8s.sh"
  bash "$DEPLOY/scripts/deploy-chaincode-k8s.sh"
  log "chain layer ready (namespace fabric)"
}

cmd_app() {
  ensure_minikube
  build_app_images
  apply_app
  kubectl -n hkzf delete pod -l app=hkzf-api --force --grace-period=0 2>/dev/null || true
  wait_app
  bash "$DEPLOY/scripts/port-forward-local.sh" start
  log "verify"
  kubectl exec -n hkzf deploy/hkzf-web -- wget -qO- \
    "http://hkzf-api:8080/auth?name=%E5%BC%A0%E4%B8%89&id=211004197001010000" || true
  echo ""
  echo "访问: http://127.0.0.1:30888/auth.html"
}

cmd_up() {
  cmd_chain
  cmd_app
  echo ""
  echo "=========================================="
  echo " HKZF 全 K8s 已部署"
  echo " 链:   namespace fabric"
  echo " 业务: namespace hkzf"
  echo " 访问: http://127.0.0.1:30888/auth.html"
  echo "=========================================="
}

cmd_stop() {
  bash "$DEPLOY/scripts/port-forward-local.sh" stop
}

main() {
  case "${1:-up}" in
    up) cmd_up ;;
    chain) cmd_chain ;;
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
