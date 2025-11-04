# Lab 20: Node.js Application Deployment on Kubernetes with ClusterIP Service

## Overview

This Lab demonstrates the deployment of a Node.js application on Kubernetes using a Deployment with 2 replicas, environment variables sourced from a ConfigMap and Secret, a PersistentVolumeClaim (PVC) bound to a statically provisioned PersistentVolume (PV), and a ClusterIP Service for internal traffic balancing. A toleration is added to the pod specification to allow scheduling on nodes tainted with `workload=worker:NoSchedule`.

  ```yaml
  apiVersion: v1
  kind: PersistentVolume
  metadata:
    name: static-pv
  spec:
    capacity:
      storage: 1Gi
    volumeMode: Filesystem
    accessModes:
      - ReadWriteOnce
    persistentVolumeReclaimPolicy: Retain
    storageClassName: manual
    hostPath:
      path: /data/nodejs-app  
  ```

## Deployment Steps

create `static-pv.yaml`
### 1. Create PV
  ```yaml
  apiVersion: v1
  kind: PersistentVolume
  metadata:
    name: static-pv
  spec:
    capacity:
      storage: 1Gi
    volumeMode: Filesystem
    accessModes:
      - ReadWriteOnce
    persistentVolumeReclaimPolicy: Retain
    storageClassName: manual
    hostPath:
      path: /data/nodejs-app  
  ```

```bash
kubectl apply -f static-pv.yaml
```

### 2. Create ConfigMap and Secret
Create `configmap-secret.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nodejs-config
data:
  DB_HOST: "mysql-service.default.svc.cluster.local" 
---
apiVersion: v1
kind: Secret
metadata:
  name: nodejs-secret
type: Opaque
data:
  DB_USER: YWRtaW4=  # Base64: "admin"
  DB_PASSWORD: cGFzc3dvcmQ=  # Base64: "password"
```

Apply:
```bash
kubectl apply -f configmap-secret.yaml
```

### 3. Create PersistentVolumeClaim
Create `pvc.yaml`. This claims the static PV:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nodejs-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: manual
  volumeName: static-pv 
```

Apply:
```bash
kubectl apply -f pvc.yaml
```

### 4. Create Deployment
Create `deployment.yaml`. This includes env vars from ConfigMap/Secret, volume mount for PVC, and the required toleration:

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
        - key: "workload"
          operator: "Equal"
          value: "worker"
          effect: "NoSchedule"
      containers:
        - name: nodejs-container
          image: ziadtd/nodejs-mysql-app:latest  
          ports:
            - containerPort: 3000
          env:
            - name: DB_HOST
              valueFrom:
                configMapKeyRef:
                  name: nodejs-config
                  key: DB_HOST
            - name: DB_USER
              valueFrom:
                secretKeyRef:
                  name: nodejs-secret
                  key: DB_USER
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: nodejs-secret
                  key: DB_PASSWORD
          volumeMounts:
            - name: app-storage
              mountPath: /mnt/nodejs-app    
      volumes:
        - name: app-storage
          persistentVolumeClaim:
            claimName: nodejs-pvc
```

Apply:
```bash
kubectl apply -f deployment.yaml
```

Verify:
```bash
kubectl get deployments nodejs-app
kubectl get pods -l app=nodejs-app
```

### 5. Create ClusterIP Service
Create `service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nodejs-service
spec:
  type: ClusterIP
  selector:
    app: nodejs-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
```

Apply:
```bash
kubectl apply -f service.yaml
```


## Testing

deploy `mysql.yaml` that is required by the application

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql:8.0
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: rootpassword
            - name: MYSQL_DATABASE
              value: ivolve
          ports:
            - containerPort: 3306
          volumeMounts:
            - name: mysql-data
              mountPath: /var/lib/mysql
      volumes:
        - name: mysql-data
          emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: mysql-service
spec:
  selector:
    app: mysql
  ports:
    - port: 3306
      targetPort: 3306
```
### Access via Port-Forward
Forward local port 8080 to the service for testing:

```bash
kubectl port-forward service/nodejs-service 8080:80
```

```bash
curl http://localhost:8080/health
```

