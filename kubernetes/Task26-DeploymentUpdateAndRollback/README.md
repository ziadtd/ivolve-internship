# Lab 26: Deployment Update and Rollback

A comprehensive guide to updating a Kubernetes deployment with a new Docker image, monitoring the rollout, verifying changes, and performing a rollback — including all commands, verification steps, and Docker image management.

---

### Step 1: Create Initial `index.html`

```bash
cat > frontend/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; margin-top: 20%; background: #f0f8ff; }
        h1 { color: #006400; }
    </style>
</head>
<body>
    <h1>Welcome from Egypt!</h1>
    <p>Exploring Kubernetes deployments and rollbacks.</p>
</body>
</html>
EOF
```

### Step 2: Create `Dockerfile`

```bash
cat > Dockerfile << 'EOF'
FROM nginx:alpine
COPY frontend/index.html /usr/share/nginx/html/index.html
EXPOSE 80
EOF
```

### Step 3: Build and Push Initial Image (`v1` - Egypt)

```bash
docker build -t ziadtd/frontend:v1 .
docker tag ziadtd/frontend:v1 ziadtd/frontend:v1 
docker push ziadtd/frontend:v1
```

### Step 4: Create Initial Kubernetes Deployment (`v1`)
create `deployment.yaml` to create Deployment and expose it to a Service 
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: ziadtd/frontend:v1
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
spec:
  type: NodePort
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30030
```

### Step 5: Deploy Initial Version

```bash
kubectl apply -f deployment.yaml
```

### Step 6: Verify Initial App (Egypt)

```bash
kubectl port-forward deployment/frontend-deployment 8080:80

# In another terminal:
curl http://localhost:30030
```

### Step 7: Update Source Code to Cairo

```bash
sed -i 's/Egypt/Cairo/g' frontend/index.html
```

Now `index.html` contains:
```html
<h1>Welcome from Cairo!</h1>
```

### Step 8: Build and Push Updated Image (`v2`)

```bash
docker build -t ziadtd/frontend:v2 .
docker tag ziadtd/frontend:v2 ziadtd/frontend:v2
docker push ziadtd/frontend:v2
```

### Step 9: Update Deployment to Use `v2`

Edit `deployment.yaml`:

```bash
kubectl set image deployment/frontend-deployment frontend=ziadtd/myapp:v2
```


Then re-apply:
```bash
kubectl apply -f deployment.yaml
```

### Step 10: Monitor & Verify Update

```bash
kubectl rollout status deployment/frontend-deployment
```



Re-check app:
```bash
curl http://localhost:30030
```
