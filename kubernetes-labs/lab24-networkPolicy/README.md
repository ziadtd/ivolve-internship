# Lab 24: Control Pod-to-Pod Traffic via Kubernetes NetworkPolicy  

## Overview

This lab implements **Kubernetes NetworkPolicy** to enforce **least-privilege networking**:

---

### 1. Create NetworkPolicy

**`networkpolicy-allow-app-to-mysql.yaml`**

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-app-to-mysql
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: mysql
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: nodejs-app
      ports:
        - protocol: TCP
          port: 3306
```

---

## Apply

```bash
kubectl apply -f networkpolicy-allow-app-to-mysql.yaml
```

---

## Verification Steps

### 1. Confirm Policy Applied

```bash
kubectl get networkpolicy allow-app-to-mysql -o wide
```

```bash
kubectl describe networkpolicy allow-app-to-mysql
```

**Expected**:
```yaml
Spec:
  Pod Selector:     app=mysql
  Ingress:
    From:
      PodSelector:  app=nodejs-app
    Port:           3306/TCP
```

---

### 2. Test from `nodejs-app` Pod (Allowed)

```bash
NODEJS_POD=$(kubectl get pod -l app=nodejs-app -o jsonpath="{.items[0].metadata.name}")
kubectl exec -it $NODEJS_POD -- nc -zv mysql-service 3306```
```
---

### 3. Test from Unauthorized Pod (Blocked)

```bash
kubectl run -i --rm --restart=Never test-pod --image=busybox -- sh
```

Inside pod:
```sh
nc -zv mysql-service 3306
exit
```
