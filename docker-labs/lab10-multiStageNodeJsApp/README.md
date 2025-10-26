# Lab 10: Multi-Stage Docker Build for Java Application

##  Lab Overview

This lab demonstrates how to implement Docker multi-stage builds to create optimized container images for a Java application. 

## Step 1: Clone the Application Repository

Clone the source code from GitHub:

```bash
git clone https://github.com/Ibrahim-Adel15/Docker-1.git
cd Docker-1
```

## Step 2: Create the Multi-Stage Dockerfile

Create a file named `Dockerfile` in the project root directory with the following content:

```dockerfile
# Stage 1
FROM maven:sapmachine AS builder
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Stage 2
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

## Step 3: Build the Docker Image

Build the image and tag it as `app3`:

```bash
docker build -t app3:latest .
```

### Check the Image Size

```bash
docker images app3
```

```
REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
app3         latest    abc123def456   30 seconds ago   245MB
```

**Size Comparison:**
- **Single-stage build** (with Maven & JDK): ~700-800MB
- **Multi-stage build** (JRE only): ~245-280MB
- **Size reduction**: Approximately 65-70% smaller

---

## Step 4: Run the Container

Start a container from the image:

```bash
docker run -d -p 8080:8080 --name app3-container app3:latest
```

---

## Step 5: Test the Application

```bash
curl http://localhost:8080
```

## Step 6: Stop the Container

Stop the running container:

```bash
docker stop app3-container
```
---

## Step 7: Delete the Container

Remove the stopped container:

```bash
docker rm app3-container
```