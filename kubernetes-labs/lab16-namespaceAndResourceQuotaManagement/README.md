# Lab 16: Namespace Management and Resource Quota Enforcement

## Overview
This lab demonstrates how to implement namespace isolation and resource quota enforcement in Kubernetes using the **declarative method**.

### Step 1: Create the Namespace

Create `namespace.yaml`:
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ivolve
  labels:
    name: ivolve
    environment: lab
```

Apply the namespace:
```bash
kubectl apply -f namespace.yaml
```

**Verification:**
```bash
kubectl get ns ivolve
```

---

### Step 2: Apply Resource Quota

Create `resource-quota.yaml`:
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: pod-quota
  namespace: ivolve
spec:
  hard:
    pods: "2"
```

Apply the resource quota:
```bash
kubectl apply -f resource-quota.yaml
```

---

### Step 3: Test the Resource Quota

Create `test-deployment.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-test
  namespace: ivolve
spec:
  replicas: 3  #more than quota
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```

Apply the test deployment:
```bash
kubectl apply -f test-deployment.yaml
```


### View Resource Quota Status
```bash
kubectl describe quota pod-quota -n ivolve

kubectl get pods -n ivolve

kubectl describe deployment nginx-test -n ivolve
```
