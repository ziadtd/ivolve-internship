# Build Tools Labs: Maven & Gradle

## Overview

This repository contains comprehensive labs demonstrating how to build and package Java applications using two popular build automation tools: **Apache Maven** and **Gradle**. These labs cover installation, project setup, testing, building artifacts, and running packaged applications on RHEL 9.

# Lab 6: Building and Packaging Java Applications with Gradle

## Overview

Gradle is a flexible, powerful build automation tool that combines the best features of Maven and Ant. This lab demonstrates the complete Gradle build lifecycle.

---

## Step-by-Step Instructions

### 1. Install Gradle on RHEL 9

#### Install Java Development Kit (JDK)

```bash
java -version

sudo dnf install java-17-openjdk java-17-openjdk-devel -y

java -version
javac -version
```

#### Manual Installation of Gradle

```bash
# Download Gradle
wget https://services.gradle.org/distributions/gradle-8.0-bin.zip

sudo dnf install unzip -y

unzip gradle-8.0-bin.zip
sudo mv gradle-8.0 /opt/gradle

sudo ln -s /opt/gradle/bin/gradle /usr/local/bin/gradle

gradle --version
```

#### Set Environment Variables 

```bash
# Edit ~/.bashrc
nano ~/.bashrc

export GRADLE_HOME=/opt/gradle
export PATH=$PATH:$GRADLE_HOME/bin

source ~/.bashrc
```

---

### 2. Clone the Source Code

```bash
git clone https://github.com/Ibrahim-Adel15/build1.git
cd build1
```

---

### 3. Run Unit Tests

Execute all unit tests in the project:

```bash
gradle test
```

**Expected Output:**
- Test compilation
- Test execution results
- Test summary (BUILD SUCCESSFUL or BUILD FAILED)
- Detailed test report in `build/reports/tests/test/index.html`

View test reports:
```bash
firefox build/reports/tests/test/index.html
# or
cat build/reports/tests/test/index.html
```

---

### 4. Build the Application

Generate the JAR artifact in the `build/libs/` directory:

```bash
gradle clean build
```

**What this command does:**
- `clean`: Removes previous build artifacts
- `build`: Compiles source code, runs tests, and creates the JAR file

**Expected Output:**
- Generated artifact: `build/libs/ivolve-app.jar`

Verify the artifact was created:
```bash
ls -lh build/libs/ivolve-app.jar
```

List all generated artifacts:
```bash
ls -lh build/libs/
```

---

### 5. Run the Application

Execute the packaged JAR file:

```bash
java -jar build/libs/ivolve-app.jar
```

**Expected Output:**
- `Hello iVolve Trainee`
---

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
