#!/usr/bin/env bash
set -euo pipefail

FABRIC_ROOT=/fabric
CHAINCODE_ROOT=/chaincode
CHANNEL_NAME="${CHANNEL_NAME:-mychannel}"
CONFIGTX_PATH="${FABRIC_ROOT}/configtx"
export FABRIC_CFG_PATH=/etc/hyperledger/fabric

ORDERER_CA="${FABRIC_ROOT}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
ORDERER_ADMIN_TLS="${FABRIC_ROOT}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt"
ORDERER_ADMIN_TLS_CERT="${FABRIC_ROOT}/organizations/ordererOrganizations/example.com/users/Admin@example.com/tls/client.crt"
ORDERER_ADMIN_TLS_KEY="${FABRIC_ROOT}/organizations/ordererOrganizations/example.com/users/Admin@example.com/tls/client.key"

log() { echo "[bootstrap] $*"; }

generate_crypto() {
  if [ -d "${FABRIC_ROOT}/organizations/peerOrganizations/org1.example.com" ]; then
    log "crypto material already exists"
    return
  fi
  log "generating crypto material"
  cryptogen generate --config="${FABRIC_ROOT}/cryptogen/crypto-config-org1.yaml" --output="${FABRIC_ROOT}/organizations"
  cryptogen generate --config="${FABRIC_ROOT}/cryptogen/crypto-config-org2.yaml" --output="${FABRIC_ROOT}/organizations"
  cryptogen generate --config="${FABRIC_ROOT}/cryptogen/crypto-config-orderer.yaml" --output="${FABRIC_ROOT}/organizations"
}

set_globals() {
  local org=$1
  if [ "$org" -eq 1 ]; then
    export CORE_PEER_LOCALMSPID=Org1MSP
    export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
    export CORE_PEER_TLS_ROOTCERT_FILE="${FABRIC_ROOT}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt"
    export CORE_PEER_MSPCONFIGPATH="${FABRIC_ROOT}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp"
  else
    export CORE_PEER_LOCALMSPID=Org2MSP
    export CORE_PEER_ADDRESS=peer0.org2.example.com:9051
    export CORE_PEER_TLS_ROOTCERT_FILE="${FABRIC_ROOT}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt"
    export CORE_PEER_MSPCONFIGPATH="${FABRIC_ROOT}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp"
  fi
  export CORE_PEER_TLS_ENABLED=true
}

create_channel() {
  mkdir -p "${FABRIC_ROOT}/channel-artifacts"
  if [ ! -f "${FABRIC_ROOT}/channel-artifacts/${CHANNEL_NAME}.block" ]; then
    log "creating channel ${CHANNEL_NAME}"
    FABRIC_CFG_PATH="${CONFIGTX_PATH}" configtxgen -profile ChannelUsingRaft -outputBlock "${FABRIC_ROOT}/channel-artifacts/${CHANNEL_NAME}.block" -channelID "${CHANNEL_NAME}"
  fi

  for attempt in 1 2 3 4 5; do
    if osnadmin channel join \
      --channelID "${CHANNEL_NAME}" \
      --config-block "${FABRIC_ROOT}/channel-artifacts/${CHANNEL_NAME}.block" \
      -o orderer.example.com:7053 \
      --ca-file "${ORDERER_ADMIN_TLS}" \
      --client-cert "${ORDERER_ADMIN_TLS_CERT}" \
      --client-key "${ORDERER_ADMIN_TLS_KEY}"; then
      log "orderer joined channel ${CHANNEL_NAME}"
      break
    fi
    log "orderer not ready, retry ${attempt}/5"
    sleep 5
  done

  set_globals 1
  peer channel join -b "${FABRIC_ROOT}/channel-artifacts/${CHANNEL_NAME}.block"
  set_globals 2
  peer channel join -b "${FABRIC_ROOT}/channel-artifacts/${CHANNEL_NAME}.block"
}

seed_data() {
  log "seeding skipped in bootstrap (handled by deploy-chaincode.sh)"
}

main() {
  generate_crypto
  log "waiting for peers"
  sleep 20
  create_channel
  sleep 5
  log "bootstrap complete (chaincode deployed separately)"
}

main "$@"
