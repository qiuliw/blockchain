#!/usr/bin/env bash
# 将 fabric 命名空间中的 Admin MSP / TLS 证书同步到 hkzf 应用命名空间
set -euo pipefail

DEPLOY="$(cd "$(dirname "$0")/.." && pwd)"
FABRIC_NS="${FABRIC_NS:-fabric}"
APP_NS="${APP_NS:-hkzf}"
TMP="/tmp/hkzf-fabric-certs-$$"

log() { echo "[sync-certs] $*"; }

cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

mkdir -p "$TMP/msp" "$TMP/peer-tls" "$TMP/orderer-tls"

kubectl -n "$FABRIC_NS" exec deploy/peer0-org1 -- tar -C /fabric/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp -cf - . \
  | tar -xf - -C "$TMP/msp"
kubectl -n "$FABRIC_NS" exec deploy/peer0-org1 -- tar -C /fabric/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls -cf - . \
  | tar -xf - -C "$TMP/peer-tls"
kubectl -n "$FABRIC_NS" exec deploy/peer0-org1 -- tar -C /fabric/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls -cf - . \
  | tar -xf - -C "$TMP/orderer-tls"

tar -cf "$TMP/msp.tar" -C "$TMP" msp
tar -cf "$TMP/peer-tls.tar" -C "$TMP" peer-tls
tar -cf "$TMP/orderer-tls.tar" -C "$TMP" orderer-tls

kubectl create namespace "$APP_NS" 2>/dev/null || true
kubectl -n "$APP_NS" delete secret fabric-msp-bundle fabric-peer-tls-bundle fabric-orderer-tls-bundle --ignore-not-found
kubectl -n "$APP_NS" create secret generic fabric-msp-bundle --from-file=msp.tar="$TMP/msp.tar"
kubectl -n "$APP_NS" create secret generic fabric-peer-tls-bundle --from-file=peer-tls.tar="$TMP/peer-tls.tar"
kubectl -n "$APP_NS" create secret generic fabric-orderer-tls-bundle --from-file=orderer-tls.tar="$TMP/orderer-tls.tar"

log "secrets synced to namespace ${APP_NS}"
