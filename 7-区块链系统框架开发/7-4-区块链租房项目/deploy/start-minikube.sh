#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEPLOY="$ROOT/deploy"
FABRIC="$DEPLOY/fabric"

ORGS_K8S="/fabric/organizations"
MSP_K8S="/fabric/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp"
PEER_TLS_K8S="/fabric/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls"
ORDERER_TLS_K8S="/fabric/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls"

echo "==> 停止旧进程/容器"
pkill -f /tmp/hkzf-server 2>/dev/null || true
pkill -f "http.server 8889" 2>/dev/null || true
docker rm -f orderer.example.com peer0.org1.example.com peer0.org2.example.com fabric-bootstrap fabric-crypto 2>/dev/null || true

echo "==> 启动 Fabric (Docker)"
cd "$DEPLOY"
chmod +x scripts/*.sh
docker compose up fabric-crypto
docker compose up -d orderer.example.com peer0.org1.example.com peer0.org2.example.com
sleep 8
docker compose up fabric-bootstrap

echo "==> 部署链码 (CCAAS, 宿主机 Docker 构建)"
chmod +x "$DEPLOY/scripts/deploy-chaincode.sh"
bash "$DEPLOY/scripts/deploy-chaincode.sh"

echo "==> 启动 minikube (挂载 fabric 证书目录)"
minikube stop 2>/dev/null || true
minikube start --driver=docker --cpus=2 --memory=4096 \
  --mount-string "$FABRIC:/fabric" --mount 2>/dev/null || \
minikube start --driver=docker --cpus=2 --memory=4096

echo "==> 修复 fabric 目录权限"
sudo chown -R "$(id -u):$(id -g)" "$FABRIC/channel-artifacts" 2>/dev/null || true
chmod -R a+rX "$FABRIC" 2>/dev/null || true

echo "==> 构建镜像 (minikube docker)"
eval "$(minikube docker-env)"
docker build -f "$DEPLOY/docker/Dockerfile.hkzf" -t hkzf-api:local "$ROOT"
docker build -f "$DEPLOY/docker/Dockerfile.web" -t hkzf-web:local "$ROOT"

echo "==> 部署到 Kubernetes"
kubectl apply -f "$DEPLOY/k8s/namespace.yaml"
sed \
  -e "s|FABRIC_ORGS_HOST_PATH|$ORGS_K8S|g" \
  -e "s|FABRIC_MSP_HOST_PATH|$MSP_K8S|g" \
  -e "s|FABRIC_PEER_TLS_HOST_PATH|$PEER_TLS_K8S|g" \
  -e "s|FABRIC_ORDERER_TLS_HOST_PATH|$ORDERER_TLS_K8S|g" \
  "$DEPLOY/k8s/hkzf-api.yaml" | kubectl apply -f -
kubectl apply -f "$DEPLOY/k8s/hkzf-web.yaml"

kubectl -n hkzf rollout status deployment/hkzf-api --timeout=180s
kubectl -n hkzf rollout status deployment/hkzf-web --timeout=120s

echo "==> 启动 localhost port-forward"
chmod +x "$DEPLOY/scripts/port-forward-local.sh"
bash "$DEPLOY/scripts/port-forward-local.sh" start

IP="$(minikube ip)"
echo ""
echo "=========================================="
echo " HKZF 已部署 (minikube 模拟 K8s)"
echo " 推荐访问: http://127.0.0.1:30888/auth.html"
echo " minikube NodePort:      http://${IP}:30888/auth.html (仅 WSL 内)"
echo " Fabric peer: host.minikube.internal:7051"
echo "=========================================="
