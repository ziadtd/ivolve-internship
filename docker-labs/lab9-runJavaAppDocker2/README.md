
## Lab 9: Build with Pre-Built JAR

### Overview
In this lab, we first build the JAR locally, then create an optimized Docker image with only the runtime dependencies.

### Step 1: Clone the Application Code


```bash
git clone https://github.com/Ibrahim-Adel15/Docker-1.git
cd Docker-1
```

---

### Step 2: Build the JAR File

Build the JAR file locally using Maven:

```bash
mvn clean package
```
---

### Step 3: Create Dockerfile for Lab 9

Create a file named `Dockerfile` with the following content:

```dockerfile
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/demo-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

---

### Step 4: Build App2 Image

Build the Docker image and note the **build time** and **image size**:

```bash
# Build the image and time it
time docker build -t image2 .
```

Check the image size:
```bash
docker images | grep image2
```
**Observations for Lab 9:**
- **Build Time**: ~10-30 seconds (just copying files)
- **Image Size**: ~350-450 MB (40-50% smaller than Lab 8)
- **Note**: Much faster and smaller due to pre-built JAR

---

### Step 5: Run Container

Run a container from the built image:

```bash
docker run -d -p 8080:8080 image2
```

Verify the container is running:
```bash
docker ps
```
---

### Step 6: Test the Application

Test that the application is running correctly:

```bash
curl http://localhost:8080

```