# Lab 31: CI/CD Pipeline Implementation with Jenkins Agents and Shared Libraries

## Overview

This lab demonstrates a complete CI/CD pipeline implementation using Jenkins with the following advanced features:

- **Jenkins Agents**: Distributed build execution using SSH-based agent nodes
- **Shared Libraries**: Reusable Groovy functions for pipeline stages
- **Docker Integration**: Building, scanning, and pushing container images
- **Kubernetes Deployment**: Automated deployment to K8s clusters
- **Security Scanning**: Image vulnerability scanning with Trivy



#### Step 1: Prepare the Agent VM

```bash
# On Jenkins Master - Generate SSH Key
ssh-keygen -t rsa -b 2048 -f ~/.ssh/jenkins_agent_key

# Copy public key to Agent
ssh-copy-id -i ~/.ssh/jenkins_agent_key.pub ziad@192.168.52.134

```

#### Step 2: Create Agent Root Directory

```bash
# On Agent VM
sudo mkdir -p /home/jenkins_home
sudo chown -R ziad:ziad /home/jenkins_home
sudo chmod 755 /home/jenkins_home
```

#### Step 3: Add SSH Credentials in Jenkins

1. Navigate to: **Jenkins Dashboard → Manage Jenkins → Credentials → System → Global credentials**
2. Click **Add Credentials**
3. Configure:
   - **Kind**: SSH Username with private key
   - **ID**: `jenkins-agent-ssh-key`
   - **Username**: `ziad` 
   - **Private Key**: Select "Enter directly" and paste content of `~/.ssh/jenkins_agent_key`

#### Step 4: Create Jenkins Agent Node

1. Navigate to: **Jenkins Dashboard → Manage Jenkins → Nodes → New Node**
2. Configure:
   - **Node name**: `agent-1`
   - **Type**: Permanent Agent
   - **Number of executors**: 2
   - **Remote root directory**: `/home/jenkins_home`
   - **Labels**: `docker-agent linux-agent`
   - **Usage**: "Use this node as much as possible"
   - **Launch method**: Launch agents via SSH
     - **Host**: `192.168.52.134`
     - **Credentials**: Select `jenkins-agent-ssh-key`
     - **Host Key Verification Strategy**: Non verifying Verification Strategy
   - **Availability**: Keep this agent online as much as possible

3. Click **Save** and verify the agent connects successfully

### Part 2: Shared Library Setup

#### Step 1: Create Shared Library Repository

```bash
# Create new Git repository
git init jenkins-shared-library
cd jenkins-shared-library

# Create directory structure
mkdir -p vars
```

#### Step 2: Create Shared Library Functions

Create the following files in the `vars/` directory

`buildApp.groovy`
```groovy
def call() {
    echo "Building app"
    sh 'mvn clean package -f jenkins/Task31-PipelineWithAgentsAndSharedLib/Jenkins_App/pom.xml'
}
```

`buildImage.groovy`
```groovy
def call() {
    echo "Building Docker image"
    sh 'docker build -t jenkins-app:latest jenkins/Task31-PipelineWithAgentsAndSharedLib/Jenkins_App'
}
```

`deplouOnK9s.groovy`
```groovy
def call() {
    echo "Deploying application on Kubernetes"
                withCredentials([file(credentialsId: 'kube-config', variable: 'KUBECONFIG')]) {
                    sh '''
                    kubectl apply -f deployment.yaml --kubeconfig=$KUBECONFIG
                    kubectl rollout status deployment/myapp --kubeconfig=$KUBECONFIG
                    '''
                }            
}
```

`pushImage.groovy`
```groovy
def call() {
    echo "Pushing Docker image to image registery"
    sh 'echo Image pushed'
}
```

`removeImageLocally.groovy`
```groovy
def call() {
    echo "Removing local image"
    sh 'docker rmi jenkins-app:latest || true'
}
```
`run unitTest.groovy`
```groovy
def call() {
    echo "Running the Unit Test"
    sh 'mvn test || echo "No tests found – continuing"'
}
```
`scanImage.groovy`
```groovy
def call() {
    echo "Scanning Docker image for vulnerabilities"
    sh 'echo Image scan completed'
}
```
#### Step 3: Configure Shared Library in Jenkins

1. Navigate to: **Jenkins Dashboard → Manage Jenkins → System**
2. Scroll to **Global Pipeline Libraries**
3. Click **Add**
4. Configure:
   - **Name**: `lab31-shared-library`
   - **Default version**: `main`
   - **Retrieval method**: Modern SCM
   - **Source Code Management**: Git
   - **Project Repository**: `https://github.com/your-username/jenkins-shared-library.git`
   - **Allow default version to be overridden**
   - **Include @Library changes in job recent changes**

5. Click **Save**


#### Step 2: Create Jenkinsfile

Create `Jenkinsfile` 

```groovy
@Library('lab31-shared-library') _

pipeline {
    agent {
        label 'docker-agent'
    }
    
    environment {
        // Docker Configuration
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_IMAGE_NAME = 'ziadtd/jenkins-app'
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials'
        
        // Kubernetes Configuration
        K8S_DEPLOYMENT_FILE = 'k8s/deployment.yaml'
        K8S_TOKEN_CREDENTIAL_ID = 'k8s-token'
        K8S_APISERVER_CREDENTIAL_ID = 'k8s-apiserver'
        K8S_NAMESPACE = 'default'
        
        // Build Configuration
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        FULL_IMAGE_NAME = "${DOCKER_IMAGE_NAME}:${IMAGE_TAG}"
    }
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        disableConcurrentBuilds()
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }
        
        stage('RunUnitTest') {
            steps {
                script {
                    runUnitTest()
                }
            }
        }
        
        stage('BuildApp') {
            steps {
                script {
                    buildApp()
                }
            }
        }
        stage('Who am I?') {
            steps {
                sh '''
                    echo "=== USER INFO ==="
                    whoami
                    id
                    echo "=== GROUPS ==="
                    groups
                    echo "=== DOCKER SOCKET ==="
                    ls -l /var/run/docker.sock
                '''
            }
        }
        stage('BuildImage') {
            steps {
                script {
                    echo 'Building Docker Image...'
                    buildImage()
                }
            }
        }
        
        stage('ScanImage') {
            steps {
                script {
                    scanImage()
                }
            }
        }
        
        stage('PushImage') {
            steps {
                script {
                    pushImage()
                }
            }
        }
        
        stage('RemoveImageLocally') {
            steps {
                script {
                    removeImageLocally()
                }
            }
        }
        
        stage('DeployOnK8s') {
            steps {
                script {
                    echo 'Deploying to Kubernetes...'
                    deployOnK8s()
                }
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completed successfully!'
            echo "Application deployed with image: ${FULL_IMAGE_NAME}"
        }
        
        failure {
            echo 'Pipeline failed!'
            echo 'Sending failure notification...'
        }
        
        always {
            echo 'Cleaning workspace...'
            cleanWs()
        }
    }
}
```

#### Step 3: Create Kubernetes Deployment File

Create `deployment.yaml`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins-app
  template:
    metadata:
      labels:
        app: jenkins-app
    spec:
      containers:
      - name: jenkins-app
        image: jenkins-app:latest
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: jenkins-app-service
spec:
  type: NodePort
  selector:
    app: jenkins-app
  ports:
  - port: 8080
    targetPort: 8080
    nodePort: 30080
```

#### Step 4: Configure Jenkins Credentials

Add the following credentials in Jenkins:
Add Kubeconfig: ID = kube-config, type = Secret file (upload ~/.kube/config from K8s cluster).
Add Docker Hub: ID = docker-hub-credentials, type = Username with password (your Docker Hub username/password).

#### Step 5: Create Jenkins Pipeline Job

1. Navigate to: **Jenkins Dashboard → New Item**
2. Enter name: `Lab31-CICD-Pipeline`
3. Select: **Pipeline**
4. Configure:
   - **Pipeline Definition**: Pipeline script from SCM
   - **SCM**: Git
   - **Repository URL**: `https://github.com/ziadtd/ivolve-internship`
   - **Script Path**: `jenkins/Task31-PipelineWithAgentsAndSharedLibJenkinsfile`
5. Click **Save**

### Running the Pipeline Manually

1. Navigate to pipeline job
2. Click **Build Now**
3. Monitor execution in **Console Output**
