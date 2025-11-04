# Docker Lab 11: Managing Environment Variables Across Build and Runtime
## Overview

This lab explores three distinct approaches to managing environment variables in Docker containers:

1. **Runtime Variables**: Passed via command-line flags (`-e`)
2. **Environment Files**: Loaded from external files (`--env-file`)
3. **Build-time Defaults**: Defined in the Dockerfile (`ENV`)

---

### Step 1: Clone the Repository

```bash
git clone https://github.com/Ibrahim-Adel15/Docker-3.git
cd Docker-3
```

---

### Step 2: Create the Dockerfile

Create a file named `Dockerfile` in the project root:

```dockerfile
FROM python:3.9-slim
WORKDIR /app
RUN pip install flask
COPY app.py .
ENV APP_MODE=production
ENV APP_REGION=canada-west
EXPOSE 8080
CMD ["python", "app.py"]
```

---

### Step 3: Create the Environment File

Create a file named `staging.env`:

```env
APP_MODE=staging
APP_REGION=us-west
```

### Step 4: Build the Docker Image

```bash
docker build -t flask-env-app:latest .
```

---

## Running the Application

### Method 1: Development Environment (Command-line Variables)

Pass environment variables directly via the `-e` flag:

```bash
docker run -d -p 8080:8080 \
  -e APP_MODE=development \
  -e APP_REGION=us-east \
  --name flask-dev \
  flask-env-app:latest
```

**Access the application:**
```bash
curl http://localhost:8080
```

**Stop and remove:**
```bash
docker stop flask-dev && docker rm flask-dev
```

---

### Method 2: Staging Environment (Environment File)

Load variables from the `staging.env` file:

```bash
docker run -d -p 8080:8080 \
  --env-file staging.env \
  --name flask-staging \
  flask-env-app:latest
```

**Access the application:**
```bash
curl http://localhost:8080
```

**Stop and remove:**
```bash
docker stop flask-staging && docker rm flask-staging
```

---

### Method 3: Production Environment (Dockerfile Defaults)

Run without specifying environment variables (uses defaults from Dockerfile):

```bash
docker run -d -p 8080:8080 \
  --name flask-prod \
  flask-env-app:latest
```

**Access the application:**
```bash
curl http://localhost:8080
```

**Stop and remove:**
```bash
docker stop flask-prod && docker rm flask-prod
```