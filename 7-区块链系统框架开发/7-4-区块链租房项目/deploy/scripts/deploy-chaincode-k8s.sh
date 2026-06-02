#!/usr/bin/env bash
# 在 K8s 部署 CCAAS 链码（fabric 命名空间，通过 peer Pod exec）
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DEPLOY="$ROOT/deploy"
NS="${FABRIC_NS:-fabric}"
CHANNEL_NAME="${CHANNEL_NAME:-mychannel}"
CCAAS_DIR="/tmp/hkzf-ccaas"
PKG_DIR="/tmp/hkzf-chaincode-pkgs"

ORDERER_CA="/fabric/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

log() { echo "[chaincode-k8s] $*"; }

set_globals() {
  local org=$1
  if [ "$org" -eq 1 ]; then
    PEER_DEPLOY=peer0-org1
    PEER_MSP=Org1MSP
    PEER_ADDR=peer0-org1:7051
    PEER_TLS=/fabric/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    MSP_PATH=/fabric/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    PEER_TLS_HOST=peer0.org1.example.com
  else
    PEER_DEPLOY=peer0-org2
    PEER_MSP=Org2MSP
    PEER_ADDR=peer0-org2:9051
    PEER_TLS=/fabric/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    MSP_PATH=/fabric/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    PEER_TLS_HOST=peer0.org2.example.com
  fi
}

peer_exec() {
  local tls_override="${PEER_TLS_HOST:-}"
  kubectl -n "$NS" exec "deploy/${PEER_DEPLOY}" -- sh -c "
    export CORE_PEER_LOCALMSPID='${PEER_MSP}'
    export CORE_PEER_ADDRESS='${PEER_ADDR}'
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_TLS_ROOTCERT_FILE='${PEER_TLS}'
    export CORE_PEER_MSPCONFIGPATH='${MSP_PATH}'
    ${tls_override:+export CORE_PEER_TLS_SERVERHOSTOVERRIDE='${tls_override}'}
    peer $*
  "
}

setup_peer_host_aliases() {
  local org1_ip org2_ip
  org1_ip="$(kubectl -n "$NS" get svc peer0-org1 -o jsonpath='{.spec.clusterIP}')"
  org2_ip="$(kubectl -n "$NS" get svc peer0-org2 -o jsonpath='{.spec.clusterIP}')"
  kubectl -n "$NS" exec "deploy/peer0-org1" -- sh -c "
    grep -q 'peer0.org1.example.com' /etc/hosts || echo '${org1_ip} peer0.org1.example.com' >> /etc/hosts
    grep -q 'peer0.org2.example.com' /etc/hosts || echo '${org2_ip} peer0.org2.example.com' >> /etc/hosts
  "
  kubectl -n "$NS" exec "deploy/peer0-org2" -- sh -c "
    grep -q 'peer0.org1.example.com' /etc/hosts || echo '${org1_ip} peer0.org1.example.com' >> /etc/hosts
    grep -q 'peer0.org2.example.com' /etc/hosts || echo '${org2_ip} peer0.org2.example.com' >> /etc/hosts
  "
}

commit_chaincode() {
  local name=$1
  setup_peer_host_aliases
  kubectl -n "$NS" exec "deploy/peer0-org1" -- sh -c "
    export CORE_PEER_LOCALMSPID='Org1MSP'
    export CORE_PEER_ADDRESS='peer0.org1.example.com:7051'
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_TLS_ROOTCERT_FILE='/fabric/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt'
    export CORE_PEER_MSPCONFIGPATH='/fabric/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp'
    peer lifecycle chaincode commit \
      -o orderer:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile '${ORDERER_CA}' \
      --channelID '${CHANNEL_NAME}' --name '${name}' --version 1 --sequence 1 --waitForEvent=false \
      --peerAddresses peer0.org1.example.com:7051 \
      --tlsRootCertFiles /fabric/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
      --peerAddresses peer0.org2.example.com:9051 \
      --tlsRootCertFiles /fabric/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
  "
}

build_ccaas_image() {
  bash "$DEPLOY/scripts/build-images.sh" chaincode "$1" "${1}_ccaas:local"
}

ensure_ccaas_service() {
  local name=$1
  kubectl -n "$NS" apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: ${name}-ccaas
  namespace: ${NS}
spec:
  selector:
    app: ${name}-ccaas
  ports:
    - port: 7052
      targetPort: 7052
EOF
}

deploy_ccaas() {
  local name=$1 package_id=$2
  kubectl -n "$NS" apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${name}-ccaas
  namespace: ${NS}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${name}-ccaas
  template:
    metadata:
      labels:
        app: ${name}-ccaas
    spec:
      containers:
        - name: chaincode
          image: ${name}_ccaas:local
          imagePullPolicy: Never
          env:
            - name: CHAINCODE_ID
              value: "${package_id}"
            - name: CHAINCODE_SERVER_ADDRESS
              value: "0.0.0.0:7052"
            - name: CHAINCODE_TLS_DISABLED
              value: "true"
          ports:
            - containerPort: 7052
EOF
  kubectl -n "$NS" rollout status "deployment/${name}-ccaas" --timeout=120s
}

prepare_ccaas_package() {
  local name=$1 label=$2
  local pkg_dir="$CCAAS_DIR/${name}"
  mkdir -p "$pkg_dir" "$PKG_DIR"
  cat > "$pkg_dir/connection.json" <<EOF
{
  "address": "${name}-ccaas.${NS}.svc.cluster.local:7052",
  "dial_timeout": "10s",
  "tls_required": false
}
EOF
  cat > "$pkg_dir/metadata.json" <<EOF
{"type":"ccaas","label":"${label}"}
EOF
  tar --mtime='1970-01-01' --owner=0 --group=0 -czf "$pkg_dir/code.tar.gz" -C "$pkg_dir" connection.json
  tar --mtime='1970-01-01' --owner=0 --group=0 -czf "${PKG_DIR}/${name}.tar.gz" -C "$pkg_dir" metadata.json code.tar.gz

  kubectl -n "$NS" exec deploy/peer0-org1 -- mkdir -p /fabric/chaincode-pkgs
  cat "${PKG_DIR}/${name}.tar.gz" | kubectl -n "$NS" exec -i deploy/peer0-org1 -- sh -c "cat > /fabric/chaincode-pkgs/${name}.tar.gz"
}

is_committed() {
  local name=$1
  set_globals 1
  peer_exec lifecycle chaincode querycommitted --channelID "$CHANNEL_NAME" --name "$name" 2>/dev/null | grep -q "Version: 1"
}

wait_for_commit_readiness() {
  local name=$1
  for _ in $(seq 1 30); do
    set_globals 1
    local status
    status="$(peer_exec lifecycle chaincode checkcommitreadiness \
      --channelID "$CHANNEL_NAME" --name "$name" --version 1 --sequence 1 --output json 2>/dev/null || true)"
    if echo "$status" | grep -q '"Org1MSP": true' && echo "$status" | grep -q '"Org2MSP": true'; then
      return 0
    fi
    sleep 2
  done
  log "timeout waiting for commit readiness: ${name}"
  return 1
}

deploy_one() {
  local name=$1
  if is_committed "$name"; then
    log "${name} already committed, skip"
    return
  fi
  log "deploying ${name}"
  build_ccaas_image "$name"
  ensure_ccaas_service "$name"
  prepare_ccaas_package "$name" "${name}_1"

  set_globals 1
  peer_exec lifecycle chaincode install "/fabric/chaincode-pkgs/${name}.tar.gz" >/dev/null || true
  local package_id
  package_id="$(peer_exec lifecycle chaincode calculatepackageid "/fabric/chaincode-pkgs/${name}.tar.gz" | tr -d '\r' | tail -1)"
  [ -n "$package_id" ] || { log "failed to get package id for ${name}"; exit 1; }
  log "${name} package id: ${package_id}"

  deploy_ccaas "$name" "$package_id"
  sleep 3

  set_globals 1
  peer_exec lifecycle chaincode approveformyorg \
    -o orderer:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "$ORDERER_CA" \
    --channelID "$CHANNEL_NAME" --name "$name" --version 1 --package-id "$package_id" --sequence 1 \
    --waitForEvent=false \
    --peerAddresses peer0-org1:7051 \
    --tlsRootCertFiles /fabric/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
    >/dev/null 2>&1 || true

  set_globals 2
  peer_exec lifecycle chaincode install "/fabric/chaincode-pkgs/${name}.tar.gz" >/dev/null || true
  peer_exec lifecycle chaincode approveformyorg \
    -o orderer:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "$ORDERER_CA" \
    --channelID "$CHANNEL_NAME" --name "$name" --version 1 --package-id "$package_id" --sequence 1 \
    --waitForEvent=false \
    --peerAddresses peer0-org2:9051 \
    --tlsRootCertFiles /fabric/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt \
    >/dev/null 2>&1 || true

  wait_for_commit_readiness "$name"
  set_globals 1
  commit_chaincode "$name"
}

invoke_chaincode() {
  local chaincode=$1 ctor=$2
  kubectl -n "$NS" exec "deploy/peer0-org1" -- sh -c "
    export CORE_PEER_LOCALMSPID='Org1MSP'
    export CORE_PEER_ADDRESS='peer0.org1.example.com:7051'
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_TLS_ROOTCERT_FILE='/fabric/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt'
    export CORE_PEER_MSPCONFIGPATH='/fabric/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp'
    peer chaincode invoke \
      -o orderer:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile '${ORDERER_CA}' \
      -C '${CHANNEL_NAME}' -n '${chaincode}' -c '${ctor}' \
      --waitForEventTimeout 60s \
      --peerAddresses peer0.org1.example.com:7051 \
      --tlsRootCertFiles /fabric/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
      --peerAddresses peer0.org2.example.com:9051 \
      --tlsRootCertFiles /fabric/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
  "
}

seed_data() {
  invoke_chaincode authentication '{"Args":["add","211004197001010000","\u5f20\u4e09","false"]}' || true
}

main() {
  mkdir -p "$CCAAS_DIR" "$PKG_DIR"
  eval "$(minikube docker-env)"
  deploy_one authentication
  deploy_one certification
  deploy_one contract
  seed_data
  log "chaincode deployment complete"
}

main "$@"
