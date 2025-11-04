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

