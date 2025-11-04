# Lab 22: Health Monitoring of Application Pods  

---

## Overview

This lab **adds Kubernetes health probes** to the **Node.js application** (`ziadtd/nodejs-mysql-app:latest`) to ensure:

- **Readiness Probe**: Only **ready pods** receive traffic via `nodejs-service`
- **Liveness Probe**: **Unhealthy pods** are automatically **restarted**
- **Zero downtime** during startup, DB connection, or failures

---



## Updated Deployment with Probes

create `deployment-probes.yaml`

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
          
          readinessProbe:
            httpGet:
              path: /ready
              port: 3000
            initialDelaySeconds: 10  
            periodSeconds: 5         
            timeoutSeconds: 3       
            successThreshold: 1
            failureThreshold: 3    

          livenessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 15  
            periodSeconds: 10        
            timeoutSeconds: 5
            successThreshold: 1
            failureThreshold: 3       

      volumes:
        - name: logs
          emptyDir: {}
```

---

## Apply the Deployment

```bash
kubectl apply -f deployment-probes.yaml
```

---

## Verification Steps

### 1. **Monitor Pod Readiness**

```bash
kubectl get pods -l app=nodejs-app -w
```

---

### 2. **Check Probe Events**

```bash
POD_NAME=$(kubectl get pod -l app=nodejs-app -o jsonpath="{.items[0].metadata.name}")
kubectl describe pod $POD_NAME
```

Look for:
```yaml
Readiness :  http-get http://:3000/ready delay=10s timeout=3s period=5s #success=1 #failure=3
Liveness  :   http-get http://:3000/health delay=15s timeout=5s period=10s #success=1 #failure=3
```

---

### 3. **Verify Service Endpoints**

```bash
kubectl get endpoints nodejs-service
```
---

### 4. **Test Application**

```bash
kubectl port-forward service/nodejs-service 8080:80
```

```bash
curl http://localhost:8080/ready

curl http://localhost:8080/health
```

