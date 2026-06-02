#!/usr/bin/env bash
# 将 configtx / TLS 证书中的 *.example.com 域名映射到 K8s Service ClusterIP
set -euo pipefail

NS="${FABRIC_NS:-fabric}"

log() { echo "[patch-hosts] $*"; }

orderer_ip="$(kubectl -n "$NS" get svc orderer -o jsonpath='{.spec.clusterIP}')"
org1_ip="$(kubectl -n "$NS" get svc peer0-org1 -o jsonpath='{.spec.clusterIP}')"
org2_ip="$(kubectl -n "$NS" get svc peer0-org2 -o jsonpath='{.spec.clusterIP}')"

host_aliases=$(cat <<EOF
[
  {"ip":"${orderer_ip}","hostnames":["orderer.example.com"]},
  {"ip":"${org1_ip}","hostnames":["peer0.org1.example.com"]},
  {"ip":"${org2_ip}","hostnames":["peer0.org2.example.com"]}
]
EOF
)

patch_deployment() {
  local name=$1
  log "patch ${name} hostAliases (orderer=${orderer_ip}, org1=${org1_ip}, org2=${org2_ip})"
  kubectl -n "$NS" patch deployment "$name" --type=merge -p "{\"spec\":{\"template\":{\"spec\":{\"hostAliases\":${host_aliases}}}}}"
}

for dep in orderer peer0-org1 peer0-org2; do
  patch_deployment "$dep"
done

kubectl -n "$NS" rollout status deployment/orderer --timeout=180s
kubectl -n "$NS" rollout status deployment/peer0-org1 --timeout=180s
kubectl -n "$NS" rollout status deployment/peer0-org2 --timeout=180s
log "host aliases applied"
