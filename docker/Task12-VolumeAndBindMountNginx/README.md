# Lab 12: Docker Volume and Bind Mount with Nginx

This lab demonstrates how to use Docker volumes and bind mounts with an Nginx container to persist logs and serve custom HTML content.

## Overview

- **Docker Volume**: Used to persist Nginx logs
- **Bind Mount**: Used to serve custom HTML files from the host machine

### Step 1: Create Docker Volume

Create a named volume called `nginx_logs` to persist Nginx log files:

```bash
docker volume create nginx_logs
```

---

### Step 2: Create Directory and HTML File

Create a directory structure for the bind mount:

```bash
mkdir -p nginx-bind/html
```

Navigate to the directory:

```bash
cd nginx-bind/html
```

Create an `index.html` file with custom content:

```bash
echo "Hello from Bind Mount" > index.html
```

---

### Step 3: Run Nginx Container

Run the Nginx container with both volume and bind mount:

```bash
docker run -d \
  --name nginx-lab \
  -p 8080:80 \
  -v nginx_logs:/var/log/nginx \
  -v $(pwd)/nginx-bind/html:/usr/share/nginx/html \
  nginx:latest
```

---

### Step 4: Verify Nginx Page

Test the Nginx web server using curl:

```bash
curl http://localhost:8080
```

**Expected output:**
```
Hello from Bind Mount
```

---

### Step 5: Modify HTML and Verify Changes

Update the `index.html` file on host machine:

```bash
echo "Hello from Bind Mount - Updated!" > nginx-bind/html/index.html
```

Verify the changes are reflected immediately (no container restart needed):

```bash
curl http://localhost:8080
```

**Expected output:**
```
Hello from Bind Mount - Updated!
```

### Step 6: Verify Logs in Volume

```bash
docker exec nginx-lab ls -la /var/log/nginx
```

View the access log:

```bash
docker exec nginx-lab cat /var/log/nginx/access.log
```

View the error log:

```bash
docker exec nginx-lab cat /var/log/nginx/error.log
```

### Step 7: Cleanup

Stop and remove the Nginx container:

```bash
docker stop nginx-lab
docker rm nginx-lab
```

Remove the Docker volume:

```bash
docker volume rm nginx_logs
```
