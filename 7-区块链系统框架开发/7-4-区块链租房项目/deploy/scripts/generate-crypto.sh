#!/usr/bin/env bash
set -euo pipefail

FABRIC_ROOT=/fabric
export FABRIC_CFG_PATH="${FABRIC_ROOT}/configtx"

if [ -d "${FABRIC_ROOT}/organizations/peerOrganizations/org1.example.com" ]; then
  echo "[crypto] material exists, skip"
  exit 0
fi

echo "[crypto] generating organizations"
cryptogen generate --config="${FABRIC_ROOT}/cryptogen/crypto-config-org1.yaml" --output="${FABRIC_ROOT}/organizations"
cryptogen generate --config="${FABRIC_ROOT}/cryptogen/crypto-config-org2.yaml" --output="${FABRIC_ROOT}/organizations"
cryptogen generate --config="${FABRIC_ROOT}/cryptogen/crypto-config-orderer.yaml" --output="${FABRIC_ROOT}/organizations"
echo "[crypto] done"
