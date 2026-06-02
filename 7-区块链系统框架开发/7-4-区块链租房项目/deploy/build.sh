#!/usr/bin/env bash
# 构建 Docker 镜像（写入 minikube 本地 Docker）
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEPLOY="$(cd "$(dirname "$0")" && pwd)"
GOPROXY="${GOPROXY:-https://goproxy.cn,direct}"
API_IMAGE="${API_IMAGE:-hkzf-api:local}"
WEB_IMAGE="${WEB_IMAGE:-hkzf-web:local}"
CHAINCODES=(authentication certification contract)

log() { echo "[build] $*"; }

docker_build() {
  eval "$(minikube docker-env 2>/dev/null)"
  docker "$@"
}

build_api() {
  log "$API_IMAGE"
  docker_build build -f "$DEPLOY/docker/Dockerfile.hkzf" \
    --build-arg "GOPROXY=$GOPROXY" -t "$API_IMAGE" "$ROOT"
}

build_web() {
  log "$WEB_IMAGE"
  docker_build build -f "$DEPLOY/docker/Dockerfile.web" -t "$WEB_IMAGE" "$ROOT"
}

build_chaincode() {
  local name=$1 tag="${2:-${1}_ccaas:local}"
  log "$tag"
  docker_build build -f "$DEPLOY/docker/Dockerfile.chaincode" \
    --build-arg "CHAINCODE_DIR=$name" --build-arg "GOPROXY=$GOPROXY" \
    -t "$tag" "$ROOT"
}

usage() {
  cat <<EOF
用法: $0 <目标>

  app                 构建 hkzf-api、hkzf-web
  chaincode <name>    构建单个链码镜像（如 authentication）
  all                 应用 + 三个链码（默认）

环境变量: API_IMAGE WEB_IMAGE GOPROXY
EOF
}

main() {
  case "${1:-all}" in
    app)
      build_api
      build_web
      ;;
    chaincode)
      [ -n "${2:-}" ] || { usage; exit 1; }
      build_chaincode "$2" "${3:-}"
      ;;
    all)
      build_api
      build_web
      for cc in "${CHAINCODES[@]}"; do
        build_chaincode "$cc"
      done
      ;;
    -h|--help|help)
      usage
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "$@"
