# Lab 10: Multi-Stage Docker Build for Java Application

##  Lab Overview

This lab demonstrates how to implement Docker multi-stage builds to create optimized container images for a Java application. You'll learn how to separate build and runtime environments to reduce image size and improve security.

---

##  Lab Objectives

By completing this lab, you will:
- Create a multi-stage Dockerfile for a Java/Maven application
- Understand the benefits of multi-stage builds
- Build and optimize Docker images
- Deploy and test containerized applications
- Manage container lifecycle (run, stop, delete)

---
## Step 1: Clone the Application Repository

Clone the source code from GitHub:

```bash
git clone https://github.com/Ibrahim-Adel15/Docker-1.git
cd Docker-1
```

**What you'll find:**
- Java application source code
- Maven project configuration (pom.xml)
- Application dependencies

---

## 📝 Step 2: Create the Multi-Stage Dockerfile

Create a file named `Dockerfile` in the project root directory with the following content:

```dockerfile
# ============================================
# Stage 1: Build Stage (Maven + JDK)
# ============================================
FROM maven:3.8.6-openjdk-11 AS builder

# Set the working directory
WORKDIR /app

# Copy the entire application source code
COPY . .

# Build the application and create JAR file
RUN mvn clean package -DskipTests

# ============================================
# Stage 2: Runtime Stage (JRE Only)
# ============================================
FROM openjdk:11-jre-slim

# Set the working directory
WORKDIR /app

# Copy only the JAR file from the builder stage
COPY --from=builder /app/target/*.jar app.jar

# Expose the application port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### 🔍 Dockerfile Breakdown

#### Stage 1: Builder Stage
| Component | Purpose |
|-----------|---------|
| `FROM maven:3.8.6-openjdk-11 AS builder` | Base image with Maven and JDK for compilation |
| `WORKDIR /app` | Sets working directory inside container |
| `COPY . .` | Copies all source code into the container |
| `RUN mvn clean package` | Compiles code and creates JAR file |

#### Stage 2: Runtime Stage
| Component | Purpose |
|-----------|---------|
| `FROM openjdk:11-jre-slim` | Lightweight base image with only Java Runtime |
| `COPY --from=builder` | Copies JAR from first stage (build artifacts only) |
| `EXPOSE 8080` | Documents that app listens on port 8080 |
| `ENTRYPOINT` | Defines command to run the application |

---

## 🏗️ Step 3: Build the Docker Image

Build the image and tag it as `app3`:

```bash
docker build -t app3:latest .
```

**Expected output:**
```
[+] Building 45.2s (12/12) FINISHED
 => [internal] load build definition
 => [internal] load .dockerignore
 => [stage-0 1/4] FROM docker.io/library/maven:3.8.6-openjdk-11
 => [stage-1 1/3] FROM docker.io/library/openjdk:11-jre-slim
 => CACHED [stage-0 2/4] WORKDIR /app
 => [stage-0 3/4] COPY . .
 => [stage-0 4/4] RUN mvn clean package -DskipTests
 => [stage-1 2/3] WORKDIR /app
 => [stage-1 3/3] COPY --from=builder /app/target/*.jar app.jar
 => exporting to image
 => => writing image sha256:abc123...
 => => naming to docker.io/library/app3:latest
```

### 📊 Check the Image Size

View the created image and note its size:

```bash
docker images app3
```

**Expected output:**
```
REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
app3         latest    abc123def456   30 seconds ago   245MB
```

**💡 Size Comparison:**
- **Single-stage build** (with Maven & JDK): ~700-800MB
- **Multi-stage build** (JRE only): ~245-280MB
- **Size reduction**: Approximately 65-70% smaller!

---

## 🚀 Step 4: Run the Container

Start a container from the image:

```bash
docker run -d -p 8080:8080 --name app3-container app3:latest
```

**Command explanation:**
- `-d`: Run in detached mode (background)
- `-p 8080:8080`: Map container port 8080 to host port 8080
- `--name app3-container`: Assign a friendly name to the container
- `app3:latest`: The image to use

### ✅ Verify Container is Running

```bash
docker ps
```

**Expected output:**
```
CONTAINER ID   IMAGE         COMMAND                  CREATED         STATUS         PORTS                    NAMES
a1b2c3d4e5f6   app3:latest   "java -jar app.jar"      10 seconds ago  Up 9 seconds   0.0.0.0:8080->8080/tcp   app3-container
```

---

## 🧪 Step 5: Test the Application

### Option 1: Using curl
```bash
curl http://localhost:8080
```

### Option 2: Using wget
```bash
wget -qO- http://localhost:8080
```

### Option 3: Using a Web Browser
Open your browser and navigate to:
```
http://localhost:8080
```

### View Application Logs

Check the application logs to see if it's running correctly:

```bash
docker logs app3-container
```

**Example output:**
```
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::                (v2.x.x)

Application started on port 8080
```

---

## 🛑 Step 6: Stop the Container

Stop the running container:

```bash
docker stop app3-container
```

**Verify it's stopped:**
```bash
docker ps -a
```

**Expected output:**
```
CONTAINER ID   IMAGE         COMMAND                  CREATED         STATUS                     PORTS     NAMES
a1b2c3d4e5f6   app3:latest   "java -jar app.jar"      2 minutes ago   Exited (0) 5 seconds ago             app3-container
```

---

## 🗑️ Step 7: Delete the Container

Remove the stopped container:

```bash
docker rm app3-container
```

**Verify deletion:**
```bash
docker ps -a | grep app3-container
```

**Expected result:** No output (container successfully deleted)

---

## 📊 Multi-Stage Build Advantages

### Why Use Multi-Stage Builds?

| Benefit | Description | Impact |
|---------|-------------|--------|
| **Smaller Image Size** | Only runtime dependencies included | 65-70% size reduction |
| **Enhanced Security** | No build tools in production image | Reduced attack surface |
| **Faster Deployment** | Smaller images transfer quickly | Improved CI/CD pipeline |
| **Better Organization** | Clear separation of concerns | Easier to maintain |
| **No Manual Cleanup** | Docker handles intermediate layers | Simpler Dockerfile |

### Before vs After Comparison

```
┌─────────────────────────────────────┐
│   Single-Stage Build (~700MB)       │
│                                     │
│  ├── Maven                          │
│  ├── JDK                           │
│  ├── Source Code                   │
│  ├── Dependencies                  │
│  ├── Build Tools                   │
│  └── JAR File                      │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│   Multi-Stage Build (~250MB)        │
│                                     │
│  ├── JRE (Runtime only)            │
│  └── JAR File                      │
└─────────────────────────────────────┘
```

---

## 🔧 Additional Docker Commands

### Container Management

```bash
# View all containers (running and stopped)
docker ps -a

# View container resource usage
docker stats app3-container

# Access container shell
docker exec -it app3-container bash

# View detailed container information
docker inspect app3-container

# Follow logs in real-time
docker logs -f app3-container
```

### Image Management

```bash
# List all images
docker images

# Remove an image
docker rmi app3:latest

# View image history
docker history app3:latest

# Save image to tar file
docker save app3:latest -o app3-backup.tar

# Load image from tar file
docker load -i app3-backup.tar
```

### Cleanup Commands

```bash
# Remove all stopped containers
docker container prune

# Remove unused images
docker image prune

# Remove all unused resources (containers, images, networks)
docker system prune -a
```

---

## 🐛 Troubleshooting

### Issue 1: Port Already in Use

**Error:** `bind: address already in use`

**Solution:**
```bash
# Find what's using port 8080
lsof -i :8080

# Use a different port
docker run -d -p 8081:8080 --name app3-container app3:latest
```

### Issue 2: Container Exits Immediately

**Solution:**
```bash
# Check logs for errors
docker logs app3-container

# Run interactively to debug
docker run -it --rm app3:latest
```

### Issue 3: Build Fails During Maven Phase

**Solution:**
```bash
# Rebuild without cache
docker build --no-cache -t app3:latest .

# Check Maven dependencies
docker run -it maven:3.8.6-openjdk-11 bash
```

### Issue 4: Cannot Connect to Application

**Solution:**
```bash
# Verify container is running
docker ps

# Check if port is exposed
docker port app3-container

# Test from inside container
docker exec app3-container curl localhost:8080
```

---

## 📚 Key Concepts Learned

### 1. Multi-Stage Builds
- Separate build environment from runtime environment
- Use `AS` keyword to name build stages
- Reference previous stages with `COPY --from=`

### 2. Image Optimization
- Use slim/alpine variants when possible
- Copy only necessary files to final stage
- Minimize number of layers

### 3. Docker Best Practices
- Use specific version tags (not `latest` in production)
- Leverage build cache for faster builds
- Document exposed ports and volumes

---

## ✅ Lab Completion Checklist

Mark each task as you complete it:

- [ ] Cloned the repository successfully
- [ ] Created Dockerfile with multi-stage build
- [ ] Built the Docker image successfully
- [ ] Noted and compared image sizes
- [ ] Ran the container successfully
- [ ] Tested the application (received response)
- [ ] Viewed container logs
- [ ] Stopped the container successfully
- [ ] Deleted the container successfully
- [ ] Understood multi-stage build benefits

---

## 🎓 Learning Resources

### Official Documentation
- [Docker Multi-Stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker CLI Reference](https://docs.docker.com/engine/reference/commandline/cli/)

### Additional Reading
- [Maven in Docker](https://hub.docker.com/_/maven)
- [OpenJDK Docker Images](https://hub.docker.com/_/openjdk)
- [Container Security Best Practices](https://docs.docker.com/engine/security/)

---

## 📝 Lab Report Template

Use this template to document your lab completion:

```
Lab 10: Multi-Stage Docker Build
Student Name: [Your Name]
Date: [Date]

Results:
- Image Size (Multi-stage): _____ MB
- Image Size (Comparison): _____ MB
- Size Reduction: _____ %
- Application Port: 8080
- Test Result: [Success/Failure]

Commands Used:
1. git clone https://github.com/Ibrahim-Adel15/Docker-1.git
2. docker build -t app3:latest .
3. docker run -d -p 8080:8080 --name app3-container app3:latest
4. curl http://localhost:8080
5. docker stop app3-container
6. docker rm app3-container

Key Learnings:
[Your observations and insights]
```

---

## 🤝 Contributing

Found an issue or want to improve this lab? Contributions are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/improvement`)
3. Commit your changes (`git commit -m 'Add improvement'`)
4. Push to the branch (`git push origin feature/improvement`)
5. Open a Pull Request

---

## 📄 License

This lab is provided for educational purposes as part of Docker training.

---

## 👨‍💻 Author

Created for Docker Training - Lab 10

**Repository:** https://github.com/Ibrahim-Adel15/Docker-1

---

**Happy Dockerizing! 🐳**

*Last Updated: October 2025*
