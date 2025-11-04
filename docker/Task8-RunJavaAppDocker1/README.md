
## Lab 8: Single-Stage Build with Maven

### Overview
In this lab, we build the application **inside the Docker container** using a Maven base image. This approach is simpler but results in larger images.

### Step 1: Clone the Application Code

```bash
git clone https://github.com/Ibrahim-Adel15/Docker-1.git
cd Docker-1
```

Verify the project structure:
```bash
ls -la
```

---

### Step 2: Create Dockerfile for Lab 8

Create a file named `Dockerfile` with the following content:

```dockerfile
FROM maven:sapmachine
WORKDIR /app
COPY . .
RUN mvn package
CMD ["java","-jar","target/demo-0.0.1-SNAPSHOT.jar"]
EXPOSE 8080
```
---

### Step 3: Build App1 Image

Build the Docker image and note the **build time** and **image size**:

```bash
# Build the image and time it
time docker build -t image1  .
```

Check the image size:
```bash
docker images | grep image1
```
---

### Step 4: Run Container

Run a container from the built image:

```bash
docker run -d -p 8080:8080  image1
```

Verify the container is running:
```bash
docker ps
```

---

### Step 5: Test the Application

Test that the application is running correctly:

```bash
# Test basic endpoint
curl http://localhost:8080

# Test with verbose output
curl -v http://localhost:8080
```
---
