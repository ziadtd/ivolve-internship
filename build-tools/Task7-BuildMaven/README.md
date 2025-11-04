# Lab 7: Building and Packaging Java Applications with Maven

## Overview

Apache Maven is a mature, widely-used build automation and project management tool. This lab demonstrates the complete Maven build lifecycle.


## Step-by-Step Instructions

### 1. Install Maven on RHEL 9

#### Install Java Development Kit (JDK)

```bash
java -version

# If not installed, install OpenJDK 17
sudo dnf install java-17-openjdk java-17-openjdk-devel -y
```

#### Install Maven via DNF Package Manager

```bash
sudo dnf install maven -y

mvn --version
```

#### Set Environment Variables 

```bash
nano ~/.bashrc

# Add these lines
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export MAVEN_HOME=/opt/maven
export PATH=$PATH:$MAVEN_HOME/bin


source ~/.bashrc

mvn --version
```

---

### 2. Clone the Source Code

```bash
git clone https://github.com/Ibrahim-Adel15/build2.git
cd build2
```

---

### 3. Run Unit Tests

Execute all unit tests in the project:

```bash
mvn test
```

**Expected Output:**
- Test compilation
- Test execution results
- Test summary (BUILD SUCCESS or BUILD FAILURE)
- Surefire test reports in `target/surefire-reports/`

---

### 4. Build the Application

Generate the JAR artifact in the `target/` directory:

```bash
mvn clean package
```

**What this command does:**
- `clean`: Removes the previous build artifacts
- `package`: Compiles source code, runs tests, and creates the JAR file

**Expected Output:**
- Generated artifact: `target/hello-ivolve-1.0-SNAPSHOT.jar`

Verify the artifact was created:
```bash
ls -la target/hello-ivolve-1.0-SNAPSHOT.jar
```

---

### 5. Run the Application

Execute the packaged JAR file:

```bash
java -jar target/hello-ivolve-1.0-SNAPSHOT.jar
```

**Expected Output:**
- `Hello iVolve Trainee`
---
