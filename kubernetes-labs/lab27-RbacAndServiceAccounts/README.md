# Lab 27: Securing Kubernetes with RBAC and Service Accounts  

## Overview

This lab demonstrates **Kubernetes security best practices** using:

- **Service Accounts**
- **RBAC (Role-Based Access Control)**
- **Role & RoleBinding**
- **Token Management**
- **Custom `kubeconfig` for least-privilege access**

To create a `jenkins-sa` in the `ivolve` namespace with **read-only access to Pods**, then generate a secure `kubeconfig` file to verify limited permissions.

---

### 1. Create Namespace: `ivolve`

create `namespace.yaml` file

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ivolve
```

```bash
kubectl apply -f namespace.yaml
```

---

### 2. Create Service Account: `jenkins-sa`

create `serviceaccount.yaml` file

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins-sa
  namespace: ivolve
```

```bash
kubectl apply -f serviceaccount.yaml
```

---

### 3. Create a Secret

create `secret.yaml` file
```yaml
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: jenkins-sa-token
  namespace: ivolve
  annotations:
    kubernetes.io/service-account.name: jenkins-sa
```

apply:
```bash
kubectl apply -f secret.yaml
```

---

### 4. Define Role: `pod-reader` (Read-only on Pods)

create `role.yaml` file

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: ivolve
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

```bash
kubectl apply -f role.yaml
```

---

### 5. Create RoleBinding: Bind `jenkins-sa` → `pod-reader`

create `rolebinding.yaml` file

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: jenkins-pod-reader-binding
  namespace: ivolve
subjects:
- kind: ServiceAccount
  name: jenkins-sa
  namespace: ivolve
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

```bash
kubectl apply -f rolebinding.yaml
```

---

## Bonus: Generate Custom `kubeconfig` for `jenkins-sa`

create script: `generate-kubeconfig.sh`

```bash
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
```

#### Make executable & run:

```bash
chmod +x generate-kubeconfig.sh
./generate-kubeconfig.sh
```


---

## Verify Limited Access with Custom Kubeconfig

### 1. List Pods → **Allowed**

```bash
kubectl --kubeconfig=kubeconfig-jenkins-sa get pods -n ivolve
```

**Expected**: List of pods (if any)

---

### 2. List Services → **Forbidden**

```bash
kubectl --kubeconfig=kubeconfig-jenkins-sa get services -n ivolve
```

---

### 3. Try Creating a Pod → **Forbidden**

```bash
kubectl --kubeconfig=kubeconfig-jenkins-sa run test --image=nginx --restart=Never -n ivolve
```
