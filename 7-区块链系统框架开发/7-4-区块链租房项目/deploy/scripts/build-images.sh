#!/usr/bin/env bash
# 使用 Docker 多阶段构建应用与链码镜像（不在宿主机直接 go build）
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DEPLOY="$ROOT/deploy"
GOPROXY="${GOPROXY:-https://goproxy.cn,direct}"

log() { echo "[build-images] $*"; }

build_app_images() {
  local api_tag="${1:-hkzf-api:local}"
  local web_tag="${2:-hkzf-web:local}"

  log "build ${api_tag} (Dockerfile.hkzf)"
  docker build -f "$DEPLOY/docker/Dockerfile.hkzf" \
    --build-arg "GOPROXY=${GOPROXY}" \
    -t "$api_tag" \
    "$ROOT"

  log "build ${web_tag} (Dockerfile.web)"
  docker build -f "$DEPLOY/docker/Dockerfile.web" \
    -t "$web_tag" \
    "$ROOT"
}

build_chaincode_image() {
  local name=$1
  local tag="${2:-${name}_ccaas:local}"

  log "build ${tag} (Dockerfile.chaincode, CHAINCODE_DIR=${name})"
  docker build -f "$DEPLOY/docker/Dockerfile.chaincode" \
    --build-arg "CHAINCODE_DIR=${name}" \
    --build-arg "GOPROXY=${GOPROXY}" \
    -t "$tag" \
    "$ROOT"
}

usage() {
  cat <<EOF
用法:
  $0 app [api_tag] [web_tag]          构建 API + Web 镜像
  $0 chaincode <name> [tag]           构建单个 CCAAS 链码镜像
  $0 all                              构建 app + 三个链码镜像
EOF
}

main() {
  case "${1:-app}" in
    app)
      build_app_images "${2:-hkzf-api:local}" "${3:-hkzf-web:local}"
      ;;
    chaincode)
      [ -n "${2:-}" ] || { usage; exit 1; }
      build_chaincode_image "$2" "${3:-${2}_ccaas:local}"
      ;;
    all)
      build_app_images
      for cc in authentication certification contract; do
        build_chaincode_image "$cc"
      done
      ;;
    -h|--help)
      usage
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "$@"
