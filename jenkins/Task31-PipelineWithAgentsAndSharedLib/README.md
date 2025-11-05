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
```groovy
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
```

#### Step 3: Create Kubernetes Deployment File

Create `k8s/deployment.yaml`

#### Step 4: Configure Jenkins Credentials

Add the following credentials in Jenkins:


#### Step 5: Create Jenkins Pipeline Job

1. Navigate to: **Jenkins Dashboard → New Item**
2. Enter name: `Lab31-CICD-Pipeline`
3. Select: **Pipeline**
4. Configure:
   - **Pipeline Definition**: Pipeline script from SCM
   - **SCM**: Git
   - **Repository URL**: `https://github.com/Ibrahim-Adel15/Jenkins_App.git`
   - **Script Path**: `Jenkinsfile`
5. Click **Save**

### Running the Pipeline Manually

1. Navigate to pipeline job
2. Click **Build Now**
3. Monitor execution in **Console Output**
