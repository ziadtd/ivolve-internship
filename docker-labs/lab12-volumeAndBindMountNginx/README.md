# Lab 12: Docker Volume and Bind Mount with Nginx

This lab demonstrates how to use Docker volumes and bind mounts with an Nginx container to persist logs and serve custom HTML content.

## Overview

- **Docker Volume**: Used to persist Nginx logs
- **Bind Mount**: Used to serve custom HTML files from the host machine

## Prerequisites

- Docker installed on your machine
- Basic understanding of Docker commands
- Terminal/Command line access

## Lab Steps

### Step 1: Create Docker Volume

Create a named volume called `nginx_logs` to persist Nginx log files:

```bash
docker volume create nginx_logs
```

Verify the volume was created:

```bash
docker volume ls
```

Inspect the volume to see its mount point:

```bash
docker volume inspect nginx_logs
```

**Expected output** (example):
```json
[
    {
        "CreatedAt": "2025-10-26T10:00:00Z",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/nginx_logs/_data",
        "Name": "nginx_logs",
        "Options": null,
        "Scope": "local"
    }
]
```

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

Verify the file was created:

```bash
cat index.html
```

Return to the parent directory:

```bash
cd ../..
```

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

**Parameters explained:**
- `-d`: Run container in detached mode
- `--name nginx-lab`: Name the container
- `-p 8080:80`: Map port 8080 on host to port 80 in container
- `-v nginx_logs:/var/log/nginx`: Mount volume for logs
- `-v $(pwd)/nginx-bind/html:/usr/share/nginx/html`: Bind mount for HTML files
- `nginx:latest`: Use the latest Nginx image

Verify the container is running:

```bash
docker ps
```

### Step 4: Verify Nginx Page

Test the Nginx web server using curl:

```bash
curl http://localhost:8080
```

**Expected output:**
```
Hello from Bind Mount
```

You can also open your browser and navigate to `http://localhost:8080`

### Step 5: Modify HTML and Verify Changes

Update the `index.html` file on your host machine:

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

Check the logs stored in the nginx_logs volume by accessing them through the container:

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

You can also inspect the volume's actual location on the host:

```bash
# Get the volume mountpoint
docker volume inspect nginx_logs --format '{{ .Mountpoint }}'

# View logs directly (requires root/sudo access)
sudo ls -la $(docker volume inspect nginx_logs --format '{{ .Mountpoint }}')
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

Verify the volume was deleted:

```bash
docker volume ls
```

Optional - Remove the bind mount directory:

```bash
rm -rf nginx-bind
```

## Key Concepts

### Docker Volume vs Bind Mount

| Feature | Docker Volume | Bind Mount |
|---------|---------------|------------|
| **Management** | Managed by Docker | Managed by user |
| **Location** | Docker storage directory | Any host path |
| **Portability** | Portable across hosts | Path-dependent |
| **Performance** | Optimized by Docker | Direct filesystem access |
| **Use Case** | Database storage, logs | Development, config files |

### Volume Benefits
- Data persists even after container deletion
- Can be shared between containers
- Managed by Docker CLI
- Better performance on Mac/Windows

### Bind Mount Benefits
- Direct access to host filesystem
- Immediate file changes reflected in container
- Good for development workflows
- Simple path mapping

## Troubleshooting

### Container fails to start
```bash
# Check container logs
docker logs nginx-lab

# Check if port 8080 is already in use
netstat -tuln | grep 8080
# or on Mac/Linux
lsof -i :8080
```

### Cannot access Nginx page
```bash
# Verify container is running
docker ps

# Check container IP and port mapping
docker port nginx-lab

# Test from within the container
docker exec nginx-lab curl localhost:80
```

### Bind mount not working
```bash
# Verify the path exists and has correct permissions
ls -la nginx-bind/html

# Check the actual mount inside container
docker exec nginx-lab ls -la /usr/share/nginx/html
```

### Volume not persisting data
```bash
# Inspect volume
docker volume inspect nginx_logs

# Check if volume is properly mounted
docker inspect nginx-lab | grep -A 10 Mounts
```

## Expected Results

✅ Docker volume `nginx_logs` created and verified  
✅ Directory structure `nginx-bind/html` created  
✅ Custom `index.html` file created and served  
✅ Nginx container running with volume and bind mount  
✅ Web page accessible via curl and browser  
✅ Changes to HTML reflected immediately  
✅ Logs persisted in volume  
✅ Volume successfully deleted after cleanup  

## Additional Commands

### View all volumes
```bash
docker volume ls
```

### Remove all unused volumes
```bash
docker volume prune
```

### Inspect container mounts
```bash
docker inspect nginx-lab | grep -A 20 Mounts
```

### Follow Nginx logs in real-time
```bash
docker logs -f nginx-lab
```

## Conclusion

This lab demonstrated:
- Creating and managing Docker volumes for persistent storage
- Using bind mounts for live file updates
- Running Nginx with custom configurations
- Verifying data persistence across container lifecycle
- Proper cleanup of Docker resources

## Author

Lab completed on: October 26, 2025

---

**Note**: Replace `$(pwd)` with `${PWD}` on Windows PowerShell or use absolute paths if relative paths don't work in your environment.
