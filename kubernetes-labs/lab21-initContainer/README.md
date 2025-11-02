# Lab 21: Kubernetes Init Container for Pre-Deployment Database Setup  

## Overview

This lab extends lab 20 by adding an **Init Container** that:

1. **Waits** for MySQL to be ready
2. **Creates** the `ivolve` database (if not exists)
3. **Creates** `appuser` with full privileges
4. **Only then** starts Node.js app

---

### 1. **Update Deployment with Init Container**

Replace current `deployment.yaml` with this:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nodejs-app
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
      initContainers:
        - name: init-db
          image: mysql:8.0
          command:
            - sh
            - -c
            - |
              echo "Waiting for MySQL to be ready..."
              until mysqladmin ping -h "$MYSQL_HOST" -u root -p"$MYSQL_ROOT_PASSWORD" --silent; do
                sleep 2
              done
              echo "MySQL is up. Setting up ivolve DB and appuser..."

              mysql -h "$MYSQL_HOST" -u root -p"$MYSQL_ROOT_PASSWORD" <<EOF
              CREATE DATABASE IF NOT EXISTS ivolve;
              CREATE USER IF NOT EXISTS 'appuser'@'%' IDENTIFIED BY 'apppassword';
              GRANT ALL PRIVILEGES ON ivolve.* TO 'appuser'@'%';
              FLUSH PRIVILEGES;
              EOF

              echo "Database setup complete."
          env:
            - name: MYSQL_HOST
              value: mysql-service
            - name: MYSQL_ROOT_PASSWORD
              value: rootpassword
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
          livenessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 15
            periodSeconds: 10
      volumes:
        - name: logs
          emptyDir: {}
```

---

### 2. **Apply the Updated Deployment**

```bash
kubectl apply -f deployment.yaml
```

---

### 3. **Monitor Init Container Logs**

```bash
# Get pod name
POD_NAME=$(kubectl get pods -l app=nodejs-app -o jsonpath="{.items[0].metadata.name}")

# Watch init container logs
kubectl logs $POD_NAME -c init-db -f
```

---

### 4. **Test Application via Port-Forward**

```bash
kubectl port-forward service/nodejs-service 8080:80
```

```bash
curl http://localhost:8080/health
```

```bash
curl http://localhost:8080/ready
```
