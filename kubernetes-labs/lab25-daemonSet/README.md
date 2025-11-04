# Lab 25: Node-Wide Pod Management with DaemonSet

 Deploy Prometheus **node-exporter** as a **DaemonSet** that runs one Pod per node, tolerates all taints, exposes node metrics, and (bonus) integrate with Prometheus deployed via Helm.

---
## Step 1: Create a Namespace

create `namespace.yaml`

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: monitoring
```

Apply:

```bash
kubectl apply -f namespace.yaml
```

---

## Step 2: Deploy Node Exporter as a DaemonSet

create `daemonset.yaml`

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: monitoring
  labels:
    app: node-exporter
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      tolerations:
        - operator: "Exists"
      hostNetwork: true
      hostPID: true
      containers:
        - name: node-exporter
          image: prom/node-exporter:v1.8.1
          ports:
            - name: metrics
              containerPort: 9100
          args:
            - "--path.rootfs=/host"
          volumeMounts:
            - name: rootfs
              mountPath: /host
              readOnly: true
      volumes:
        - name: rootfs
          hostPath:
            path: /
```

Apply:

```bash
kubectl apply -f daemonset.yaml
```

---

## Step 3: Expose Node Exporter Service

**File:** `service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: node-exporter
  namespace: monitoring
  labels:
    app: node-exporter
spec:
  type: ClusterIP
  ports:
    - name: metrics
      port: 9100
      targetPort: 9100
  selector:
    app: node-exporter
```

Apply:

```bash
kubectl apply -f service.yaml
```

---

## Step 4: Validation

Check DaemonSet

```bash
kubectl -n monitoring get daemonset
```

Confirm One Pod per Node

```bash
kubectl -n monitoring get pods -o wide
```

Validate Metrics Endpoint


```bash
curl http://192.168.52.133:9100/metrics
```

Expected output includes:

```
# HELP node_cpu_seconds_total Seconds the CPUs spent in each mode.
# HELP node_memory_MemAvailable_bytes ...
...
```

---

## Bonus: Deploy Prometheus via Helm

### 1. Add Helm Repo

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### 2. Create Custom Values File

create `prometheus-values.yaml`

```yaml
serviceAccounts:
  server:
    create: true

server:
  extraScrapeConfigs:
    - job_name: 'node-exporter'
      static_configs:
        - targets:
            - 'node-exporter.monitoring.svc.cluster.local:9100'
```

### 3. Install Prometheus

```bash
helm install prometheus prometheus-community/prometheus \
  --namespace monitoring \
  -f helm/prometheus-values.yaml
```

### 4. Port-Forward to Prometheus UI

```bash
kubectl -n monitoring port-forward svc/prometheus-server 9090:80
```

Access:http://localhost:9090

Search for:

```
node_cpu_seconds_total
```
