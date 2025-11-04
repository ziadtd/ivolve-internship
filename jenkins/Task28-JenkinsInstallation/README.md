# Lab 28: Jenkins Installation on RHEL 9

## Overview

This lab demonstrates the installation and configuration of Jenkins as a service. Jenkins is deployed on one or both nodes of a 2-node Kubernetes cluster managed by kubeadm.


### Step 1: System Preparation

Update the system packages:

```bash
sudo dnf update -y
```

### Step 2: Install Java (OpenJDK 17)

Jenkins requires Java to run. Install OpenJDK 17:

```bash
sudo dnf install java-17-openjdk java-17-openjdk-devel -y

# Verify Java installation
java -version
```

### Step 3: Add Jenkins Repository

Add the official Jenkins repository to your system:

```bash
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo

# Import Jenkins GPG key
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
```

### Step 4: Install Jenkins

Install Jenkins using dnf:

```bash
sudo dnf install jenkins -y

# Verify installation
rpm -qi jenkins
```

### Step 5: Configure Jenkins Service

Jenkins is automatically configured as a systemd service during installation. Verify the service configuration:

```bash
sudo systemctl status jenkins

sudo systemctl enable --now jenkins
```

### Step 6: Configure Firewall

Allow Jenkins traffic through the firewall:

```bash
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
```

### Step 7: Retrieve Initial Admin Password

Jenkins requires an initial admin password for first-time setup:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Step 8: Access Jenkins Web Interface

1. Open a web browser
2. Navigate to: `http://192.168.52.134:8080`
3. Enter the initial admin password from Step 7
4. Choose "Install suggested plugins" or "Select plugins to install"
5. Create the first admin user
6. Configure Jenkins URL
7. Click "Start using Jenkins"

