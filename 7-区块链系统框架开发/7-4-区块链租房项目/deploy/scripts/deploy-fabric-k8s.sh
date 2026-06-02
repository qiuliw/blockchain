#!/usr/bin/env bash
# 在 K8s (fabric 命名空间) 部署 Fabric 网络：证书 → orderer/peer → 建通道
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DEPLOY="$ROOT/deploy"
FABRIC="$DEPLOY/fabric"
NS="${FABRIC_NS:-fabric}"
CHANNEL_NAME="${CHANNEL_NAME:-mychannel}"

log() { echo "[fabric-k8s] $*"; }

apply_configmap() {
  kubectl create namespace "$NS" 2>/dev/null || true
  kubectl -n "$NS" create configmap fabric-config \
    --from-file="$FABRIC/cryptogen" \
    --from-file="$FABRIC/configtx" \
    --dry-run=client -o yaml | kubectl apply -f -
}

run_crypto_job() {
  log "generate crypto material (skip if PVC already initialized)"
  kubectl -n "$NS" delete job fabric-crypto --ignore-not-found
  kubectl -n "$NS" apply -f - <<'EOF'
apiVersion: batch/v1
kind: Job
metadata:
  name: fabric-crypto
  namespace: fabric
spec:
  backoffLimit: 2
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: crypto
          image: hyperledger/fabric-tools:2.5.12
          command: ["/bin/bash", "-c"]
          args:
            - |
              set -e
              if [ -d /fabric/organizations/peerOrganizations/org1.example.com ]; then
                echo "crypto exists"
                exit 0
              fi
              mkdir -p /fabric/configtx /fabric/channel-artifacts
              cp /config/configtx.yaml /fabric/configtx/configtx.yaml
              cryptogen generate --config=/config/crypto-config-org1.yaml --output=/fabric/organizations
              cryptogen generate --config=/config/crypto-config-org2.yaml --output=/fabric/organizations
              cryptogen generate --config=/config/crypto-config-orderer.yaml --output=/fabric/organizations
              chmod -R a+rX /fabric
          volumeMounts:
            - name: fabric-data
              mountPath: /fabric
            - name: fabric-config
              mountPath: /config
      volumes:
        - name: fabric-data
          persistentVolumeClaim:
            claimName: fabric-data
        - name: fabric-config
          configMap:
            name: fabric-config
EOF
  kubectl -n "$NS" wait --for=condition=complete job/fabric-crypto --timeout=180s
}

run_bootstrap_job() {
  if kubectl -n "$NS" run "bootstrap-check-$RANDOM" --rm -i --restart=Never \
    --image=hyperledger/fabric-tools:2.5.12 \
    --overrides='{"spec":{"containers":[{"name":"bootstrap-check","image":"hyperledger/fabric-tools:2.5.12","env":[{"name":"CORE_PEER_LOCALMSPID","value":"Org1MSP"},{"name":"CORE_PEER_ADDRESS","value":"peer0-org1:7051"},{"name":"CORE_PEER_TLS_ENABLED","value":"true"},{"name":"CORE_PEER_TLS_ROOTCERT_FILE","value":"/fabric/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt"},{"name":"CORE_PEER_MSPCONFIGPATH","value":"/fabric/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp"}],"volumeMounts":[{"name":"fabric-data","mountPath":"/fabric"}]}],"volumes":[{"name":"fabric-data","persistentVolumeClaim":{"claimName":"fabric-data"}}]}}' \
    --command -- peer channel list 2>/dev/null | grep -q "${CHANNEL_NAME}"; then
    log "peers already joined ${CHANNEL_NAME}, skip bootstrap"
    return
  fi
  log "create channel and join peers"
  kubectl -n "$NS" delete job fabric-bootstrap --ignore-not-found
  kubectl -n "$NS" apply -f - <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: fabric-bootstrap
  namespace: ${NS}
spec:
  backoffLimit: 3
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: bootstrap
          image: hyperledger/fabric-tools:2.5.12
          env:
            - name: CHANNEL_NAME
              value: "${CHANNEL_NAME}"
            - name: FABRIC_CFG_PATH
              value: /etc/hyperledger/fabric
            - name: PEER_ORG1_ADDR
              value: peer0-org1:7051
            - name: PEER_ORG2_ADDR
              value: peer0-org2:9051
          command: ["/bin/bash", "/scripts/bootstrap.sh"]
          volumeMounts:
            - name: fabric-data
              mountPath: /fabric
            - name: bootstrap-script
              mountPath: /scripts
      volumes:
        - name: fabric-data
          persistentVolumeClaim:
            claimName: fabric-data
        - name: bootstrap-script
          configMap:
            name: fabric-bootstrap-script
            defaultMode: 0755
EOF
  kubectl -n "$NS" wait --for=condition=complete job/fabric-bootstrap --timeout=300s
}

main() {
  apply_configmap
  kubectl create configmap fabric-bootstrap-script \
    --from-file=bootstrap.sh="$DEPLOY/scripts/bootstrap.sh" \
    -n "$NS" --dry-run=client -o yaml | kubectl apply -f -

  kubectl apply -f "$DEPLOY/k8s/fabric/namespace.yaml"
  kubectl apply -f "$DEPLOY/k8s/fabric/pvc.yaml"

  run_crypto_job

  kubectl apply -f "$DEPLOY/k8s/fabric/orderer.yaml"
  kubectl apply -f "$DEPLOY/k8s/fabric/peer-org1.yaml"
  kubectl apply -f "$DEPLOY/k8s/fabric/peer-org2.yaml"

  kubectl -n "$NS" rollout status deployment/orderer --timeout=180s
  kubectl -n "$NS" rollout status deployment/peer0-org1 --timeout=180s
  kubectl -n "$NS" rollout status deployment/peer0-org2 --timeout=180s

  bash "$DEPLOY/scripts/patch-fabric-hosts.sh"

  sleep 5
  run_bootstrap_job
  log "fabric network ready in namespace ${NS}"
}

main "$@"
