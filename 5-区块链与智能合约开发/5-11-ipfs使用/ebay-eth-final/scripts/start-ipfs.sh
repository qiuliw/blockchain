#!/usr/bin/env bash
# 配置并启动本地 IPFS（Kubo）
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IPFS_BIN="${IPFS_BIN:-/tmp/kubo/ipfs}"

if [ ! -x "$IPFS_BIN" ]; then
  echo "未找到 $IPFS_BIN"
  echo "请先下载 Kubo: https://dist.ipfs.tech/#go-ipfs"
  echo "解压后设置 IPFS_BIN=/path/to/ipfs"
  exit 1
fi

echo "==> 配置 IPFS CORS 与网关"
"$IPFS_BIN" config --json API.HTTPHeaders.Access-Control-Allow-Origin '["*"]'
"$IPFS_BIN" config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT","POST","GET","OPTIONS"]'
"$IPFS_BIN" config --json API.HTTPHeaders.Access-Control-Allow-Headers '["Authorization","Content-Type"]'
"$IPFS_BIN" config Addresses.Gateway /ip4/127.0.0.1/tcp/8848
"$IPFS_BIN" config Addresses.API /ip4/127.0.0.1/tcp/5001

if pgrep -f "$IPFS_BIN daemon" >/dev/null 2>&1; then
  echo "==> IPFS 已在运行"
else
  echo "==> 启动 ipfs daemon（API:5001 网关:8848）"
  nohup "$IPFS_BIN" daemon > /tmp/ipfs-daemon.log 2>&1 &
  sleep 2
fi

echo "==> 健康检查"
VERSION=$(curl -sf -X POST http://127.0.0.1:5001/api/v0/version)
echo "IPFS OK: $VERSION"

echo "==> 测试上传"
HASH=$(echo "ebay-eth-final-test" | curl -sf -X POST "http://127.0.0.1:5001/api/v0/add" -F "file=@-;filename=test.txt" | sed -n 's/.*"Hash":"\([^"]*\)".*/\1/p')
echo "上传成功: $HASH"
echo "网关: http://127.0.0.1:8848/ipfs/$HASH"
