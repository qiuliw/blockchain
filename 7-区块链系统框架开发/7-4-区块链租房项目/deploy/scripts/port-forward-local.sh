#!/usr/bin/env bash
# 将 hkzf-web 转发到 localhost，WSL 镜像网络下 Windows 可直接用 localhost 访问
set -euo pipefail

NAMESPACE="${NAMESPACE:-hkzf}"
WEB_PORT="${WEB_PORT:-30888}"
PID_FILE="/tmp/hkzf-port-forward.pid"

stop_forward() {
  if [[ -f "$PID_FILE" ]]; then
    local pid
    pid="$(cat "$PID_FILE")"
    kill "$pid" 2>/dev/null || true
    rm -f "$PID_FILE"
  fi
  pkill -f "kubectl -n ${NAMESPACE} port-forward svc/hkzf-web" 2>/dev/null || true
}

case "${1:-start}" in
  stop)
    stop_forward
    echo "已停止 port-forward"
    exit 0
    ;;
  start)
    stop_forward
    ;;
  *)
    echo "用法: $0 [start|stop]"
    exit 1
    ;;
esac

kubectl -n "$NAMESPACE" rollout status deployment/hkzf-web --timeout=120s
kubectl -n "$NAMESPACE" rollout status deployment/hkzf-api --timeout=120s

kubectl -n "$NAMESPACE" port-forward --address 0.0.0.0 "svc/hkzf-web" "${WEB_PORT}:80" \
  >/tmp/hkzf-port-forward.log 2>&1 &
echo $! >"$PID_FILE"
sleep 2

if ! kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  echo "port-forward 启动失败，日志:"
  cat /tmp/hkzf-port-forward.log
  exit 1
fi

echo "=========================================="
echo " HKZF 已通过 port-forward 暴露"
echo " WSL:     http://127.0.0.1:${WEB_PORT}/auth.html"
echo " Windows: http://127.0.0.1:${WEB_PORT}/auth.html"
echo " API:     http://127.0.0.1:${WEB_PORT}/api/auth?name=test&id=123"
echo " 说明: Windows 请用 127.0.0.1，避免 localhost 走 IPv6(::1) 连不上"
echo " 停止: ./deploy.sh stop"
echo "=========================================="
