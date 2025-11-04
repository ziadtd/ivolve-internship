# Lab 23: Pod Resource Management with CPU and Memory Requests and Limits  

---

## Overview

This lab **adds CPU and memory resource constraints** to the **Node.js application** (`ziadtd/nodejs-mysql-app:latest`) to ensure:

- **Guaranteed resources** → No starvation
- **Hard limits** → Prevent runaway pods
- **Efficient scheduling** → Pods only run on capable nodes
- **Self-healing** under pressure

---

## Updated Deployment with Resources

create `deployment-resources.yaml` file

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nodejs-app
  labels:
    app: nodejs-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nodejs-app
  template:
    metadata:
      labels:
        app: nodejs-app
    spec:
      tolerations:
        - key: workload
          operator: Equal
          value: worker
          effect: NoSchedule
      containers:
        - name: nodejs-container
          image: ziadtd/nodejs-mysql-app:latest
          ports:
            - containerPort: 3000
          env:
            - name: DB_HOST
              value: mysql-service
            - name: DB_USER
              value: appuser
            - name: DB_PASSWORD
              value: apppassword
            - name: DB_NAME
              value: ivolve
          volumeMounts:
            - name: logs
              mountPath: /app/logs
          resources:
            requests:
              memory: "256Mi"
              cpu: "250m"
            limits:
              memory: "512Mi"
              cpu: "500m"
          readinessProbe:
            httpGet:
              path: /ready
              port: 3000
            initialDelaySeconds: 10
            periodSeconds: 5
            timeoutSeconds: 3
            failureThreshold: 3
          livenessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 15
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 3
      volumes:
        - name: logs
          emptyDir: {}
```

---

## Apply the Deployment

```bash
kubectl apply -f deployment-resources.yaml
```

---

## Verification Steps

Verify Resources Applied

```bash
POD_NAME=$(kubectl get pod -l app=nodejs-app -o jsonpath="{.items[0].metadata.name}")
kubectl describe pod $POD_NAME | grep -A 10 "Requests\|Limits"
```

**Expected Output**:
```yaml
Limits:
  cpu:        500m
  memory:     512Mi
Requests:
  cpu:        250m
  memory:     256Mi
```

---

### 2. **Monitor Real-Time Usage**

```bash
kubectl top pod -l app=nodejs-app
```
