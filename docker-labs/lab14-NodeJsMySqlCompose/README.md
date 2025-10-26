# Lab 14: Containerized Node.js and MySQL Stack Using Docker Compose

This lab demonstrates how to containerize a Node.js application with MySQL database using Docker Compose, including health checks, logging, and publishing to DockerHub.

### Step 1: Clone the Application

```bash
git clone https://github.com/Ibrahim-Adel15/kubernets-app.git
cd kubernets-app
```

### Step 2: Create Dockerfile

Create a `Dockerfile` in the project root:

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```

### Step 3: Create Docker Compose File

Create a `docker-compose.yml` file:

```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: nodejs-app
    ports:
      - "3000:3000"
    environment:
      - DB_HOST=db
      - DB_USER=root
      - DB_PASSWORD=rootpassword
      - DB_NAME=ivolve
    volumes:
      - ./app/logs:/app/logs
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped
    networks:
      - app-network

  db:
    image: mysql:8.0
    container_name: mysql-db
    environment:
      - MYSQL_ROOT_PASSWORD=rootpassword
      - MYSQL_DATABASE=ivolve
    volumes:
      - db_data:/var/lib/mysql
    ports:
      - "3306:3306"
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-prootpassword"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped
    networks:
      - app-network

volumes:
  db_data:
    driver: local

networks:
  app-network:
    driver: bridge
```

### Step 4: Build and Run the Stack

```bash
docker-compose up -d

docker-compose logs -f

docker-compose ps
```

## Verification Steps

### 1. Verify Application is Working

```bash
# Check if containers are running
docker-compose ps
```

### 2. Verify Health Endpoint

```bash
# Test health endpoint
curl http://localhost:3000/health
```

### 3. Verify Ready Endpoint

```bash
# Test ready endpoint
curl http://localhost:3000/ready
```

### Step 4: Verify Application Logs

```bash
ls -la ./app/logs/

cat ./app/logs/app.log
```

### Step 5: Test Database Connection

```bash
docker exec -it mysql-db mysql -uroot -pziad123 -e "SHOW DATABASES;"

docker exec -it mysql-db mysql -uroot -pziad123 -e "USE ivolve; SHOW TABLES;"
```

## Push Docker Image to DockerHub

### 1. Login to DockerHub

```bash
docker login
```

### 2. Tag the Image

```bash
docker tag kubernets-app_app:latest ziadtd/nodejs-mysql-app:latest
docker tag kubernets-app_app:latest ziadtd/nodejs-mysql-app:v1.0
```

### 3. Push to DockerHub

```bash
# Push the images
docker push ziadtd/nodejs-mysql-app:latest
docker push ziadtd/nodejs-mysql-app:v1.0
```