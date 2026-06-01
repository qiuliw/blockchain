#!/usr/bin/env bash
# 在宿主机构建并部署 CCAAS 链码（避免 peer 容器内 docker build 失败）
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DEPLOY="$ROOT/deploy"
# 使用 Docker volume 存放证书，避免中文路径 bind mount 异常
FABRIC_VOLUME="${FABRIC_VOLUME:-hkzf-fabric-data}"
FABRIC="/fabric"
CHANNEL_NAME="${CHANNEL_NAME:-mychannel}"
CCAAS_DIR="/tmp/hkzf-ccaas"
PKG_DIR="$HOME/.hkzf-chaincode-pkgs"
NETWORK="fabric_test"
SCRIPT_DIR="/tmp/hkzf-scripts"

ORDERER_CA="/fabric/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

log() { echo "[chaincode] $*"; }

peer_cmd() {
  docker run --rm -v "$FABRIC:/fabric" -v "$PKG_DIR:/pkgs" -v /tmp:/tmp --network "$NETWORK" \
    -e FABRIC_CFG_PATH=/etc/hyperledger/fabric \
    "$@" \
    hyperledger/fabric-tools:2.5.12 peer "$@"
}

set_globals() {
  local org=$1
  if [ "$org" -eq 1 ]; then
    PEER_MSP=Org1MSP
    PEER_ADDR=peer0.org1.example.com:7051
    PEER_TLS=/fabric/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    MSP_PATH=/fabric/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
  else
    PEER_MSP=Org2MSP
    PEER_ADDR=peer0.org2.example.com:9051
    PEER_TLS=/fabric/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    MSP_PATH=/fabric/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
  fi
}

run_peer() {
  docker run --rm -v "${FABRIC_VOLUME}:/fabric" -v "$PKG_DIR:/pkgs" -v /tmp:/tmp --network "$NETWORK" \
    -e CORE_PEER_LOCALMSPID="$PEER_MSP" \
    -e CORE_PEER_ADDRESS="$PEER_ADDR" \
    -e CORE_PEER_TLS_ENABLED=true \
    -e CORE_PEER_TLS_ROOTCERT_FILE="$PEER_TLS" \
    -e CORE_PEER_MSPCONFIGPATH="$MSP_PATH" \
    hyperledger/fabric-tools:2.5.12 peer "$@"
}

build_ccaas_image() {
  local name=$1
  log "building image ${name}_ccaas"
  docker build --no-cache -f "$DEPLOY/docker/Dockerfile.chaincode" \
    --build-arg "CHAINCODE_DIR=${name}" \
    -t "${name}_ccaas:local" \
    "$ROOT"
}

start_ccaas_container() {
  local name=$1
  local package_id=$2
  docker rm -f "${name}_ccaas" 2>/dev/null || true
  docker run -d --name "${name}_ccaas" --network "$NETWORK" \
    -e CHAINCODE_ID="$package_id" \
    -e CHAINCODE_SERVER_ADDRESS=0.0.0.0:7052 \
    -e CHAINCODE_TLS_DISABLED=true \
    "${name}_ccaas:local"
}

prepare_ccaas_package() {
  local name=$1
  local label=$2
  local pkg_dir="$CCAAS_DIR/${name}"
  mkdir -p "$pkg_dir"
  cat > "$pkg_dir/connection.json" <<EOF
{
  "address": "${name}_ccaas:7052",
  "dial_timeout": "10s",
  "tls_required": false
}
EOF
  cat > "$pkg_dir/metadata.json" <<EOF
{
  "type": "ccaas",
  "label": "${label}"
}
EOF
  tar -czf "$pkg_dir/code.tar.gz" -C "$pkg_dir" connection.json
  tar -czf "${PKG_DIR}/${name}.tar.gz" -C "$pkg_dir" metadata.json code.tar.gz
}

deploy_one() {
  local name=$1
  log "deploying ${name}"

  build_ccaas_image "$name"
  local label="${name}_1"
  prepare_ccaas_package "$name" "$label"

  set_globals 1
  run_peer lifecycle chaincode install "/pkgs/${name}.tar.gz"
  local package_id
  package_id="$(run_peer lifecycle chaincode calculatepackageid "/pkgs/${name}.tar.gz")"
  log "${name} package id: ${package_id}"

  start_ccaas_container "$name" "$package_id"
  sleep 3

  set_globals 1
  run_peer lifecycle chaincode approveformyorg \
    -o orderer.example.com:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "$ORDERER_CA" \
    --channelID "$CHANNEL_NAME" --name "$name" --version 1 --package-id "$package_id" --sequence 1 \
    --peerAddresses peer0.org1.example.com:7051 \
    --tlsRootCertFiles /fabric/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt

  set_globals 2
  run_peer lifecycle chaincode install "/pkgs/${name}.tar.gz"
  run_peer lifecycle chaincode approveformyorg \
    -o orderer.example.com:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "$ORDERER_CA" \
    --channelID "$CHANNEL_NAME" --name "$name" --version 1 --package-id "$package_id" --sequence 1 \
    --peerAddresses peer0.org2.example.com:9051 \
    --tlsRootCertFiles /fabric/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

  set_globals 1
  run_peer lifecycle chaincode commit \
    -o orderer.example.com:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "$ORDERER_CA" \
    --channelID "$CHANNEL_NAME" --name "$name" --version 1 --sequence 1 \
    --peerAddresses peer0.org1.example.com:7051 \
    --tlsRootCertFiles /fabric/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
    --peerAddresses peer0.org2.example.com:9051 \
    --tlsRootCertFiles /fabric/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
}

seed_data() {
  log "seeding sample ledger data"
  set_globals 1
  run_peer chaincode invoke \
    -o orderer.example.com:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "$ORDERER_CA" \
    -C "$CHANNEL_NAME" -n authentication \
    -c '{"Args":["add","211004197001010000","张三","false"]}' \
    --peerAddresses peer0.org1.example.com:7051 \
    --tlsRootCertFiles "$PEER_TLS" || true
}

main() {
  mkdir -p "$CCAAS_DIR" "$PKG_DIR" "$SCRIPT_DIR"
  # 确保 fabric 证书在 docker volume 中
  if ! docker run --rm -v "${FABRIC_VOLUME}:/fabric" hyperledger/fabric-tools:2.5.12 test -d /fabric/organizations/peerOrganizations/org1.example.com/users; then
    echo "[chaincode] 初始化 fabric 证书 volume..."
    docker volume create "${FABRIC_VOLUME}" 2>/dev/null || true
    tar -C "$DEPLOY/fabric" -cf - . 2>/dev/null | docker run -i --rm -v "${FABRIC_VOLUME}:/fabric" hyperledger/fabric-tools:2.5.12 sh -c 'cd /fabric && tar -xf - && chmod -R a+rX /fabric'
  fi
  deploy_one authentication
  deploy_one certification
  deploy_one contract
  sleep 3
  seed_data
  log "chaincode deployment complete"
}

main "$@"
