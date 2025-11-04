# Lab 13: Custom Docker Network for Microservices

## Overview
This lab demonstrates Docker networking concepts by deploying a microservices architecture with frontend and backend containers.

---

## Step 1: Clone the Repository

```bash
git clone https://github.com/Ibrahim-Adel15/Docker5.git
cd Docker5
```

---

## Step 2: Create Dockerfiles

### Backend Dockerfile

Create `Dockerfile` in the backend directory:

```dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY . .
RUN pip install flask
EXPOSE 5000
CMD ["python", "app.py"]
```

### Frontend Dockerfile

Create `Dockerfile` in the frontend directory:

```dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
EXPOSE 5000
CMD ["python", "app.py"]
```

---

## Step 3: Build Docker Images

### Build Backend Image

```bash
cd backend
docker build -t backend-app:v1 .
cd ..
```

### Build Frontend Image

```bash
cd frontend
docker build -t frontend-app:v1 .
cd ..
```

---

## Step 4: Create Custom Network

```bash
docker network create ivolve-network
```

---

## Step 5: Run Containers

### Run Backend Container

```bash
docker run -d \
  --name backend \
  --network ivolve-network \
  -p 5001:5000 \
  backend-app:v1
```

### Run Frontend1 Container (Custom Network)

```bash
docker run -d \
  --name frontend1 \
  --network ivolve-network \
  -p 5002:5000 \
  -e BACKEND_URL=http://backend:5000 \
  frontend-app:v1
```

### Run Frontend2 Container (Default Network)

```bash
docker run -d \
  --name frontend2 \
  -p 5003:5000 \
  -e BACKEND_URL=http://backend:5000 \
  frontend-app:v1
```

---

## Step 6: Verify Container Communication

### Test 1: Frontend1 to Backend (Should Work)

Frontend1 is on the same custom network as the backend, so they can communicate using container names.

**Method 1: Using Python (Already installed)**

```bash
docker exec -it frontend1 sh
# Test HTTP connection using Python
python -c "import urllib.request; print(urllib.request.urlopen('http://backend:5000').read().decode())"
exit
```

### Test 2: Frontend2 to Backend (Should Fail)

Frontend2 is on the default bridge network, so it cannot resolve the backend container name.

**Test with Python:**

```bash
docker exec -it frontend1 sh
# Test HTTP connection using Python
python -c "import urllib.request; print(urllib.request.urlopen('http://backend:5000').read().decode())"
exit
```

### Test 3: Access via Browser

- **Backend**: http://localhost:5001
- **Frontend1**: http://localhost:5002 (Can communicate with backend)
- **Frontend2**: http://localhost:5003 (Cannot communicate with backend by name)

---

## Step 7: Clean Up

### Stop and Remove Containers

```bash
docker stop backend frontend1 frontend2
docker rm backend frontend1 frontend2
```

### Delete Custom Network

```bash
docker network rm ivolve-network
```

