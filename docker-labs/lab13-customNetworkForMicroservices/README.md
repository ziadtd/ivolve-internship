# Lab 13: Custom Docker Network for Microservices

## Overview
This lab demonstrates Docker networking concepts by deploying a microservices architecture with frontend and backend containers. We'll explore container communication within custom networks versus the default bridge network.

## Architecture
- **Backend Service**: Flask API running on port 5000
- **Frontend Services**: Two instances (frontend1 and frontend2) running on port 5000
- **Networks**: 
  - Custom network (`ivolve-network`) for backend and frontend1
  - Default bridge network for frontend2

---

## Prerequisites
- Docker installed and running
- Git installed
- Basic understanding of Docker and networking concepts

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
# Use Python base image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy application files
COPY . .

# Install Flask
RUN pip install flask

# Expose port 5000
EXPOSE 5000

# Run the application
CMD ["python", "app.py"]
```

### Frontend Dockerfile

Create `Dockerfile` in the frontend directory:

```dockerfile
# Use Python base image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy application files
COPY . .

# Install dependencies from requirements.txt
RUN pip install -r requirements.txt

# Expose port 5000
EXPOSE 5000

# Run the application
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

### Verify Images

```bash
docker images | grep -E "backend-app|frontend-app"
```

---

## Step 4: Create Custom Network

```bash
docker network create ivolve-network
```

### Verify Network Creation

```bash
docker network ls
docker network inspect ivolve-network
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

### Verify Running Containers

```bash
docker ps
```

---

## Step 6: Verify Container Communication

### Test 1: Frontend1 to Backend (Should Work)

Frontend1 is on the same custom network as the backend, so they can communicate using container names.

**Method 1: Using Python (Already installed)**

```bash
# Access frontend1 container
docker exec -it frontend1 sh

# Test HTTP connection using Python
python -c "import urllib.request; print(urllib.request.urlopen('http://backend:5000').read().decode())"

# Or use requests if installed
python -c "import requests; print(requests.get('http://backend:5000').text)"

# Exit container
exit
```

**Method 2: Install curl inside container (temporary)**

```bash
docker exec -it frontend1 sh

# Update and install curl
apt-get update && apt-get install -y curl

# Test connection
curl http://backend:5000

# Exit
exit
```

**Method 3: From host machine**

```bash
# Check containers can resolve each other
docker exec frontend1 getent hosts backend

# Check backend logs when frontend1 makes requests
docker logs backend
```

**Expected Result**: ✅ Success - DNS resolution and communication work

### Test 2: Frontend2 to Backend (Should Fail)

Frontend2 is on the default bridge network, so it cannot resolve the backend container name.

```bash
# Try to resolve backend from frontend2
docker exec frontend2 getent hosts backend

# This will show: no output or error (DNS resolution fails)
```

**Test with Python:**

```bash
docker exec frontend2 python -c "import socket; print(socket.gethostbyname('backend'))"
```

**Expected Result**: ❌ Failure - `socket.gaierror: [Errno -2] Name or service not known`

### Test 3: Network Connectivity Tests (From Host)

```bash
# Test 1: Check DNS resolution in custom network
docker exec frontend1 getent hosts backend
# Output: 172.18.0.2  backend (IP will vary)

# Test 2: Check DNS resolution in default network  
docker exec frontend2 getent hosts backend
# Output: (empty - DNS fails)

# Test 3: Check network connectivity
docker exec frontend1 nc -zv backend 5000
# Output: backend (172.18.0.2:5000) open

# Test 4: View container IPs
docker inspect -f '{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -q)
```

### Test 3: Access via Browser

- **Backend**: http://localhost:5001
- **Frontend1**: http://localhost:5002 (Can communicate with backend)
- **Frontend2**: http://localhost:5003 (Cannot communicate with backend by name)

### Test 4: Network Inspection

```bash
# Check which containers are on ivolve-network
docker network inspect ivolve-network

# Check which containers are on default bridge
docker network inspect bridge
```

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

### Verify Deletion

```bash
docker network ls
```

### Optional: Remove Images

```bash
docker rmi backend-app:v1 frontend-app:v1
```

---

## Key Concepts Demonstrated

### 1. Custom Networks vs Default Bridge
- **Custom Networks**: 
  - Automatic DNS resolution between containers
  - Better isolation and security
  - Containers can communicate using container names
  
- **Default Bridge Network**:
  - No automatic DNS resolution
  - Containers must use IP addresses to communicate
  - Less suitable for production environments

### 2. Container Communication
- Containers on the same custom network can communicate using service names
- Containers on different networks are isolated from each other
- Port mapping (-p) allows external access to container services

### 3. Environment Variables
- Use `-e` flag to pass configuration (e.g., backend URLs)
- Enables flexible container configuration without code changes

---

## Troubleshooting

### Issue: Cannot connect to backend from frontend1

```bash
# Check if both containers are on the same network
docker network inspect ivolve-network

# Check backend logs
docker logs backend

# Check frontend1 logs
docker logs frontend1
```

### Issue: Port already in use

```bash
# Find process using the port
sudo lsof -i :5001

# Or use different ports when running containers
docker run -d --name backend --network ivolve-network -p 5010:5000 backend-app:v1
```

### Issue: Network already exists

```bash
# Remove existing network (stop containers first)
docker stop $(docker ps -aq)
docker network rm ivolve-network
docker network create ivolve-network
```

---

## Network Architecture Diagram

```
┌─────────────────────────────────────────┐
│         ivolve-network (Custom)         │
│                                         │
│  ┌──────────┐          ┌──────────┐   │
│  │ Backend  │◄────────►│Frontend1 │   │
│  │  :5000   │          │  :5000   │   │
│  └──────────┘          └──────────┘   │
│       ▲                                 │
└───────┼─────────────────────────────────┘
        │
        │ No Communication
        │
┌───────┼─────────────────────────────────┐
│       ▼         bridge (Default)        │
│  ┌──────────┐                           │
│  │Frontend2 │                           │
│  │  :5000   │                           │
│  └──────────┘                           │
└─────────────────────────────────────────┘

External Access:
- Backend: localhost:5001
- Frontend1: localhost:5002
- Frontend2: localhost:5003
```

---

## Learning Outcomes

✅ Created and managed custom Docker networks  
✅ Built Docker images for microservices  
✅ Deployed multi-container applications  
✅ Understood network isolation and container communication  
✅ Practiced Docker networking best practices  
✅ Learned DNS resolution in Docker networks  

---

## Additional Resources

- [Docker Networking Documentation](https://docs.docker.com/network/)
- [Docker Compose for Multi-Container Apps](https://docs.docker.com/compose/)
- [Best Practices for Docker Networks](https://docs.docker.com/network/bridge/)

---

## Author
Ibrahim Adel

## License
MIT License

---

## Notes
- Always use custom networks for production deployments
- Avoid using the default bridge network for multi-container applications
- Use Docker Compose for managing complex multi-container setups
- Implement proper security measures (secrets, network policies) in production
