# Lab 19: StatefulSet Deployment with Headless Service

## Overview

 StatefulSet Deployment with Headless Service. The lab demonstrates best practices for deploying a stateful application (MySQL) using Kubernetes `StatefulSet`, integrating persistent storage via PVC, secure credential management via `Secret`, node tolerations, and stable network identity through a headless service.

---

### 1. Create MySQL Root Password Secret

create manifests/secret-mysql-root.yaml 

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-root-secret
type: Opaque
data:
  password: cm9vdHBhc3N3b3Jk  # base64: rootpassword
```

---

### 2. Persistent Volume (PV)

create manifests/pv-mysql-data.yaml

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-data-pv
  labels:
    type: local
    app: mysql
spec:
  capacity:
    storage: 2Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce         
  persistentVolumeReclaimPolicy: Retain
  storageClassName: ""       
  hostPath:
    path: /mnt/mysql-data    
    type: DirectoryOrCreate```
---
### 3. Persistent Volume Claim (PVC)

create manifests/pvc-mysql-data.yaml

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-data-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```

---

### 4. StatefulSet: MySQL with Toleration & PVC

create manifests/statefulset-mysql.yaml

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
  labels:
    app: mysql
spec:
  serviceName: mysql-headless
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      tolerations:
        - key: "workload"
          operator: "Equal"
          value: "worker"
          effect: "NoSchedule"
      containers:
        - name: mysql
          image: mysql:8.0
          env:
            - name: MYSQL_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-root-secret
                  key: password
          ports:
            - containerPort: 3306
              name: mysql
          volumeMounts:
            - name: mysql-data
              mountPath: /var/lib/mysql
              subPath: "" 
      volumes:
        - name: mysql-data
          persistentVolumeClaim:
            claimName: mysql-data-pvc 
```

---

### 5. Headless Service

create manifests/headless-service-mysql.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-headless
spec:
  clusterIP: None
  selector:
    app: mysql
  ports:
    - port: 3306
      targetPort: 3306
      name: mysql
```

### 6. Apply all manifests in order

```bash
kubectl apply -f manifests/
```
### Verify Deployment

```bash
kubectl get statefulset mysql
kubectl get pods -l app=mysql
kubectl get pvc mysql-data-pvc
kubectl get svc mysql-headless
```

---

## Verify MySQL is Operational

```bash
kubectl port-forward statefulset/mysql 3306:3306

# In another terminal, connect to a MySql client Pod
kubectl run mysql-client --rm -it --image=mysql:8.0 --restart=Never -- bash
mysql -h 127.0.0.1 -u root -p rootpassword
```

### DNS Resolution Test (Headless Service)

```bash
# Get pod name
POD_NAME=$(kubectl get pods -l app=mysql -o jsonpath="{.items[0].metadata.name}")

kubectl exec -it $POD_NAME -- cat /etc/resolv.conf
```

