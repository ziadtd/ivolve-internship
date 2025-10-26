# Docker Lab 11: Managing Environment Variables Across Build and Runtime

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white)

A practical demonstration of managing Docker environment variables using three different methods: command-line arguments, environment files, and Dockerfile defaults.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Running the Application](#running-the-application)
- [Environment Variable Methods](#environment-variable-methods)
- [Testing & Verification](#testing--verification)
- [Cleanup](#cleanup)
- [Troubleshooting](#troubleshooting)
- [Learning Objectives](#learning-objectives)

## 🎯 Overview

This lab explores three distinct approaches to managing environment variables in Docker containers:

1. **Runtime Variables**: Passed via command-line flags (`-e`)
2. **Environment Files**: Loaded from external files (`--env-file`)
3. **Build-time Defaults**: Defined in the Dockerfile (`ENV`)

## ✅ Prerequisites

Before starting this lab, ensure you have:

- Docker installed and running ([Download Docker](https://www.docker.com/get-started))
- Git installed ([Download Git](https://git-scm.com/downloads))
- Basic understanding of Docker commands
- Terminal/Command Prompt access

## 📁 Project Structure

```
Docker-3/
├── app.py              # Flask application (from repository)
├── Dockerfile          # Docker image definition
├── staging.env         # Environment file for staging
└── README.md           # This file
```

## 🚀 Getting Started

### Step 1: Clone the Repository

```bash
git clone https://github.com/Ibrahim-Adel15/Docker-3.git
cd Docker-3
```

### Step 2: Create the Dockerfile

Create a file named `Dockerfile` in the project root:

```dockerfile
# Use Python base image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install Flask
RUN pip install flask

# Copy application code
COPY app.py .

# Set default environment variables for production
ENV APP_MODE=production
ENV APP_REGION=canada-west

# Expose port 8080
EXPOSE 8080

# Run the application
CMD ["python", "app.py"]
```

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

**Verify the build:**
```bash
docker images | grep flask-env-app
```

Expected output:
```
flask-env-app   latest    abc123def456    2 minutes ago    200MB
```

## 🏃 Running the Application

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
# or open http://localhost:8080 in your browser
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

## 📊 Environment Variable Methods

| Method | Priority | Use Case | Example | Override |
|--------|----------|----------|---------|----------|
| `-e` flag | **Highest** | Quick overrides, testing | `docker run -e VAR=value` | Overrides all |
| `--env-file` | **Medium** | Environment-specific configs | `docker run --env-file .env` | Overrides Dockerfile |
| `ENV` in Dockerfile | **Lowest** | Default/fallback values | `ENV VAR=value` | Can be overridden |

### Priority Example

If all three methods define the same variable:

```dockerfile
# Dockerfile
ENV APP_MODE=production
```

```env
# staging.env
APP_MODE=staging
```

```bash
# Command line
docker run -e APP_MODE=development --env-file staging.env image
```

**Result**: `APP_MODE=development` (command-line wins)

## 🧪 Testing & Verification

### Check Environment Variables Inside Container

```bash
# View all environment variables
docker exec flask-dev env

# Filter for specific variables
docker exec flask-dev env | grep APP

# Expected output:
# APP_MODE=development
# APP_REGION=us-east
```

### View Application Logs

```bash
docker logs flask-dev
```

### Inspect Container Details

```bash
docker inspect flask-dev | grep -A 10 "Env"
```

### Interactive Shell Access

```bash
docker exec -it flask-dev /bin/bash

# Inside container:
echo $APP_MODE
echo $APP_REGION
exit
```

## 🧹 Cleanup

### Remove Individual Containers

```bash
docker stop flask-dev flask-staging flask-prod
docker rm flask-dev flask-staging flask-prod
```

### Remove the Image

```bash
docker rmi flask-env-app:latest
```

### Complete Cleanup (One Command)

```bash
docker stop $(docker ps -aq --filter "ancestor=flask-env-app:latest") 2>/dev/null
docker rm $(docker ps -aq --filter "ancestor=flask-env-app:latest") 2>/dev/null
docker rmi flask-env-app:latest
```

### Remove All Stopped Containers and Unused Images

```bash
docker container prune -f
docker image prune -f
```

## 🔧 Troubleshooting

### Issue: Port Already in Use

**Error Message:**
```
Error: bind: address already in use
```

**Solution:**
```bash
# Find process using port 8080
lsof -i :8080  # macOS/Linux
netstat -ano | findstr :8080  # Windows

# Use a different port
docker run -d -p 8081:8080 --name flask-dev flask-env-app:latest
```

---

### Issue: Container Exits Immediately

**Check logs:**
```bash
docker logs flask-dev
```

**Verify app.py exists:**
```bash
docker run --rm flask-env-app:latest ls -la /app
```

**Run interactively for debugging:**
```bash
docker run -it --rm flask-env-app:latest /bin/bash
```

---

### Issue: Cannot Access Application

**Check if container is running:**
```bash
docker ps | grep flask-env-app
```

**Check container IP and port:**
```bash
docker port flask-dev
```

**Test from inside container:**
```bash
docker exec flask-dev curl localhost:8080
```

---

### Issue: Environment Variables Not Working

**Verify variables are set:**
```bash
docker exec flask-dev env | grep APP
```

**Check if app.py reads the variables correctly:**
```bash
docker exec flask-dev python -c "import os; print(os.getenv('APP_MODE'))"
```

## 🎓 Learning Objectives

By completing this lab, you will understand:

- ✅ How to define environment variables in a Dockerfile
- ✅ How to pass environment variables at runtime using `-e`
- ✅ How to use environment files with `--env-file`
- ✅ The precedence order of environment variable sources
- ✅ Best practices for managing configuration across environments
- ✅ How to debug and verify environment variables in containers

## 📚 Additional Resources

- [Docker ENV Instruction Reference](https://docs.docker.com/engine/reference/builder/#env)
- [Docker Run Environment Variables](https://docs.docker.com/engine/reference/commandline/run/#env)
- [Docker Compose Environment Variables](https://docs.docker.com/compose/environment-variables/)
- [12-Factor App Config](https://12factor.net/config)

## 🤝 Contributing

Feel free to submit issues or pull requests if you find any improvements!

## 📝 License

This project is provided for educational purposes.

---

**Happy Dockerizing! 🐳**

Made with ❤️ for Docker learners
