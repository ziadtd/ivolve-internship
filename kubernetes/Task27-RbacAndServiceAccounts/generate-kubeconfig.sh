#!/usr/bin/env bash
# generate-kubeconfig.sh - 100% working token-based kubeconfig
set -euo pipefail

NAMESPACE="ivolve"
SA_NAME="jenkins-sa"
KUBECONFIG_OUT="kubeconfig-jenkins-sa"
CONTEXT_NAME="${SA_NAME}-context"

echo "=== Generating kubeconfig for SA: $SA_NAME in ns: $NAMESPACE ==="

# 1. Ensure token secret exists
echo "Creating/updating token secret..."
kubectl -n $NAMESPACE apply -f - <<EOF
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: ${SA_NAME}-token
  namespace: $NAMESPACE
  annotations:
    kubernetes.io/service-account.name: $SA_NAME
EOF

# 2. Link secret to SA
kubectl -n $NAMESPACE patch serviceaccount $SA_NAME \
  -p "{\"secrets\":[{\"name\":\"${SA_NAME}-token\"}]}"

# 3. Wait for token to be populated
echo "Waiting for token to be issued..."
sleep 3

# 4. Extract CA, Token, and API Server
SECRET_NAME="${SA_NAME}-token"
CA_CRT=$(kubectl -n $NAMESPACE get secret $SECRET_NAME -o jsonpath='{.data.ca\.crt}')
TOKEN=$(kubectl -n $NAMESPACE get secret $SECRET_NAME -o jsonpath='{.data.token}' | base64 -d)
SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')

# 5. Generate clean kubeconfig
cat > "$KUBECONFIG_OUT" <<EOF
apiVersion: v1
kind: Config
clusters:
- name: kubernetes
  cluster:
    certificate-authority-data: $CA_CRT
    server: $SERVER
contexts:
- name: $CONTEXT_NAME
  context:
    cluster: kubernetes
    namespace: $NAMESPACE
    user: $SA_NAME
current-context: $CONTEXT_NAME
users:
- name: $SA_NAME
  user:
    token: $TOKEN
EOF

chmod 600 "$KUBECONFIG_OUT"
echo "Kubeconfig generated: $KUBECONFIG_OUT"
echo ""
echo "Test commands:"
echo "  kubectl --kubeconfig=$KUBECONFIG_OUT get pods -n $NAMESPACE"
echo "  kubectl --kubeconfig=$KUBECONFIG_OUT get services -n $NAMESPACE  # Should fail"
