# Ansible Automation Labs

A comprehensive guide for learning Ansible automation through hands-on labs. These labs cover initial Ansible configuration and automated web server deployment.

## Overview

These labs provide a practical introduction to Ansible automation framework. You'll learn how to:

- Install and configure Ansible
- Manage SSH keys for secure communication
- Create and manage inventory files
- Execute ad-hoc commands
- Write and execute Ansible playbooks
- Deploy automated infrastructure

**Lab 1:**
- Ansible installation and setup
- SSH key generation and distribution
- Inventory management
- Ad-hoc command execution

**Lab 2:**
- Playbook creation and execution
- Automated package installation (Nginx)
- Configuration management
- Firewall management
- Deployment verification

## Prerequisites

### System Requirements

- Two RHEL 9 virtual machines (or compatible Linux distribution)
- Minimum 2GB RAM per VM
- Network connectivity between VMs
- VMware, VirtualBox, or similar hypervisor (for lab environment)

### Software Requirements

- SSH client/server
- Python 3.x
- Internet access for package downloads
- Text editor (vi, nano, or similar)

### Network Requirements

- Both VMs on the same network or accessible network segment
- Network connectivity between control node and managed node
- Firewall rules allowing SSH (port 22) and HTTP (port 80) traffic

## Lab 1: Initial Ansible Configuration and Ad-Hoc Execution

### Objectives

- Install Ansible Automation Platform on control node
- Generate SSH keys for secure authentication
- Transfer public key to managed node
- Create and test inventory
- Execute ad-hoc commands

### Quick Start

#### 1. Install Ansible on Control Node

```bash
# Update system
sudo dnf update -y

# Install Ansible
sudo dnf install ansible-core -y

# Verify installation
ansible --version
```

#### 2. Generate SSH Keys

```bash
# Generate new SSH key pair
ssh-keygen -t rsa -b 4096

# Verify keys were created
ls -la ~/.ssh/
```

#### 3. Transfer Public Key to Managed Node

```bash
ssh-copy-id ziad@192.168.52.134
```

#### 4. Create Inventory File

```bash
# Create project directory
mkdir -p ~/ansible-labs/lab1-ansibleCnfg
cd ~/ansible-labs/lab1-ansibleCnfg

# Create inventory file
cat > inventory.ini << EOF
[managed_nodes]
web1 ansible_host=192.168.52.134 ansible_user=ziad

[all:vars]
ansible_python_interpreter=/usr/bin/python3
EOF
```

#### 5. Test Connection and Check Disk Space

```bash
ansible all -i inventory.ini -m ping

ansible all -i inventory.ini -m shell -a "df -h"
```

## Lab 2: Automated Web Server Configuration

### Objectives

- Write Ansible playbooks
- Automate Nginx installation
- Deploy custom web page
- Configure firewall rules
- Verify deployment

### Quick Start

#### 1. Create Project Structure

```bash
cd ~/ansible-lab
mkdir -p lab2-webserver/files
cd lab2-webserver
```

#### 2. Create Custom Web Page

```bash
cat > files/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Ansible Automated Web Server</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            padding: 50px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            background: rgba(255, 255, 255, 0.1);
            padding: 40px;
            border-radius: 10px;
        }
        h1 { font-size: 3em; }
        .badge {
            background: #4CAF50;
            padding: 10px 20px;
            border-radius: 5px;
            display: inline-block;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Success!</h1>
        <p>This web server was automatically configured using Ansible</p>
        <div class="badge">Nginx Web Server</div>
        <p style="margin-top: 30px; opacity: 0.8;">
            Deployed with Ansible | RHEL 9 | Automated Configuration
        </p>
    </div>
</body>
</html>
EOF
```

#### 2. Create Playbook

```bash
cat > webserver_setup.yml << 'EOF'
---
- name: Configure Nginx Web Server
  hosts: webservers
  become: yes
  
  tasks:
    - name: Install Nginx (from AppStream)
      dnf:
        name: nginx
        state: present
    
    - name: Start and enable Nginx service
      systemd:
        name: nginx
        state: started
        enabled: yes
    
    - name: Configure firewall to allow HTTP traffic
      command: firewall-cmd --permanent --add-service=http
      ignore_errors: yes
    
    - name: Configure firewall to allow HTTPS traffic
      command: firewall-cmd --permanent --add-service=https
      ignore_errors: yes
    
    - name: Reload firewall
      command: firewall-cmd --reload
      ignore_errors: yes
    
    - name: Backup original index.html
      copy:
        src: /usr/share/nginx/html/index.html
        dest: /usr/share/nginx/html/index.html.backup
        remote_src: yes
      ignore_errors: yes
    
    - name: Deploy custom web page
      copy:
        src: files/index.html
        dest: /usr/share/nginx/html/index.html
        owner: nginx
        group: nginx
        mode: '0644'
      notify: Restart Nginx
    
    - name: Ensure Nginx is running
      systemd:
        name: nginx
        state: started
  
  handlers:
    - name: Restart Nginx
      systemd:
        name: nginx
        state: restarted
EOF
```

#### 3. Update Inventory for Lab 2

```bash
cat > inventory.ini << EOF
[webservers]
web1 ansible_host=192.168.52.134 ansible_user=ziad

[all:vars]
ansible_python_interpreter=/usr/bin/python3
EOF
```

#### 4. Validate and Run Playbook

```bash
ansible-playbook webserver_setup.yml --syntax-check

# Perform dry run
ansible-playbook -i inventory.ini webserver_setup.yml --check

ansible-playbook -i inventory.ini webserver_setup.yml -K

```

#### 5. Verify Deployment

```bash
curl http://192.168.52.134

ansible webservers -i inventory.ini -m shell -a "curl http://localhost"

ansible webservers -i inventory.ini -m shell -a "systemctl status nginx"

ansible webservers -i inventory.ini -m shell -a "ss -tuln | grep :80"
```

#### 6. Access Web Server

Open your browser and navigate to:
```
http://192.168.52.134
```

### Lab 2 Verification

```bash
✓ Playbook syntax valid
✓ Nginx installed successfully
✓ Custom web page deployed
✓ Firewall configured
✓ Web server accessible via browser
✓ Service enabled and running
```
# Lab 3: Structured Configuration Management with Ansible Roles

A comprehensive guide to creating and managing Ansible roles for Docker, Kubernetes CLI (kubectl), and Jenkins installation and configuration.

## Overview

Lab 3 teaches is about how to structure Ansible automation using roles. Roles provide a way to package tasks, handlers, templates, and variables in a reusable format.

### Learning Objectives

- Understand Ansible role structure
- Create custom roles for different applications
- Implement role variables and defaults
- Write handlers for service management
- Organize complex playbooks using roles
- Deploy multiple applications using a single playbook


## Role 1: Docker Installation

### Step 1: Create Docker Role Directory Structure

```bash
cd ~/ansible-labs/lab3-ansibleRoles
mkdir -p roles/docker/tasks
```

### Step 2: Create Docker Role Tasks

Create `roles/docker/tasks/main.yml`:

```yaml
---
- name: Remove old Docker packages if present
  yum:
    name:
      - docker
      - docker-client
      - docker-client-latest
      - docker-common
      - docker-latest
      - docker-latest-logrotate
      - docker-logrotate
      - docker-engine
    state: absent

- name: Install dependencies
  dnf:
    name:
      - yum-utils
      - device-mapper-persistent-data
      - lvm2
    state: present

- name: Add Docker repository
  command: >
    dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  args:
    creates: /etc/yum.repos.d/docker-ce.repo

- name: Install Docker Engine
  dnf:
    name:
      - docker-ce
      - docker-ce-cli
      - containerd.io
    state: present

- name: Start and enable Docker service
  systemd:
    name: docker
    state: started
    enabled: yes

```

## Role 2: Kubectl Installation

### Step 1: Create Kubectl Role Directory Structure

```bash
mkdir -p roles/kubectl/tasks
```

### Step 2: Create Kubectl Role Tasks

Create `roles/kubectl/tasks/main.yml`:

```yaml
---
- name: Download kubectl binary
  get_url:
    url: https://dl.k8s.io/release/v1.29.0/bin/linux/amd64/kubectl
    dest: /usr/local/bin/kubectl
    mode: '0755'

- name: Verify kubectl installation
  command: /usr/local/bin/kubectl version --client
  register: kubectl_version
  changed_when: false

- name: Show kubectl version
  debug:
    msg: "{{ kubectl_version.stdout }}"
```

## Role 3: Jenkins Installation

### Step 1: Create Jenkins Role Directory Structure

```bash
mkdir -p roles/jenkins/tasks
```

### Step 2: Create Jenkins Role Tasks

Create `roles/jenkins/tasks/main.yml`:

```yaml
---
- name: Install Java (required for Jenkins)
  dnf:
    name: java-17-openjdk
    state: present

- name: Add Jenkins repo
  get_url:
    url: https://pkg.jenkins.io/redhat-stable/jenkins.repo
    dest: /etc/yum.repos.d/jenkins.repo

- name: Import Jenkins GPG key
  rpm_key:
    key: https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    state: present

- name: Install Jenkins
  dnf:
    name: jenkins
    state: present

- name: Enable and start Jenkins
  systemd:
    name: jenkins
    state: started
    enabled: yes
```
## Main Playbook

### Create Main Deployment Playbook

Create `lab3-ansibleRoles/site.yml`:

```yaml
---
- name: Configure Docker, Kubectl, and Jenkins on Worker Node
  hosts: servers
  become: yes

  roles:
    - docker
    - kubectl
    - jenkins
```

## Updated Inventory

Update your `inventory.ini`:

```ini

[servers]
managed-node ansible_host=192.168.52.134 ansible_user=ziad ansible_ssh_private_key_file=~/.ssh/id_rsa
```

## Running the Playbook

### Step 1: Validate Playbook

```bash
cd ~/ansible-labs/lab3-ansibelRoles
ansible-playbook site.yml --syntax-check
```

### Step 2: Perform Dry Run

```bash
ansible-playbook -i inventory.ini site.yml --check
```

### Step 3: Execute Playbook

```bash

ansible-playbook -i inventory.ini playbooks/deploy_devops_stack.yml -K


# Run specific role only
ansible-playbook -i inventory.ini playbooks/deploy_devops_stack.yml -t docker
```

# Lab 4: Securing Sensitive Data with Ansible Vault

## Overview

Lab 4 is about how to use Ansible Vault to encrypt and manage sensitive credentials while automating MySQL database setup. You'll install MySQL, create the iVolve database, and create a user with full privileges—all while keeping passwords encrypted.

### Learning Objectives

- Master Ansible Vault for encrypting sensitive data
- Create and manage encrypted variable files
- Automate MySQL installation with Ansible
- Create databases and users programmatically
- Implement secure credential management
- Validate database connections

## Quick Start

### Step 1: Create Encrypted Vault File

```bash
# Create vault file with sensitive data
ansible-vault  group_vars/.all.yaml
```

When the editor opens, add:

```yaml
---
db_root_password: "Root@123456!@#"
db_user: "ivolve_user"
db_user_password: "iVolve@123456!@#"
db_name: "iVolve"
db_host: "localhost"
```

### Step 2: Create MySQL Role Files

Create `mysql.yml`:

```yaml
---
- name: Install and configure MySQL with Vault-protected credentials
  hosts: mysql_server
  become: yes
  vars_files:
    - group_vars/all.yml

  tasks:
    - name: Ensure MySQL server is installed
      ansible.builtin.package:
        name: mysql-server
        state: present

    - name: Start and enable MySQL service
      ansible.builtin.service:
        name: mysqld
        state: started
        enabled: true

    - name: Ensure MySQL Python client is installed
      ansible.builtin.package:
        name: python3-PyMySQL
        state: present

    - name: Create iVolve database
      community.mysql.mysql_db:
        name: "{{ db_name }}"
        state: present
        login_user: root
        login_password: ""
        login_unix_socket: /var/lib/mysql/mysql.sock

    - name: Create user with privileges on iVolve DB
      community.mysql.mysql_user:
        name: "{{ db_user }}"
        password: "{{ db_password }}"
        priv: "{{ db_name }}.*:ALL"
        state: present
        login_user: root
        login_password: ""
        login_unix_socket: /var/lib/mysql/mysql.sock

    - name: Validate by listing databases
      ansible.builtin.shell: |
        mysql -u {{ db_user }} -p{{ db_password }} -e "SHOW DATABASES;"
      register: db_output
      changed_when: false

    - name: Show DB validation output
      ansible.builtin.debug:
        var: db_output.stdout_lines
```

### Step 3: Update Inventory

Update `inventory.ini`:

```ini
[mysql_server]
managed-node ansible_host=192.168.52.134 ansible_user=ziad ansible_ssh_private_key_file=~/.ssh/id_rsa

```

### Step 7: Run Playbook

```bash
cd ~/ansible-labs/lab4-ansibleVault

# Validate syntax
ansible-playbook mysql.yml --syntax-check

# Dry run
ansible-playbook mysql.yml --check

# Execute
ansible-playbook mysql.yml -K
```

## Verification Methods

### Method 1: Verify Service Status

```bash
ansible mysql_server -i inventory.ini -m shell -a "sudo systemctl status mysqld"
```

### Method 2: Check MySQL Version

```bash
ansible mysql_server -i inventory.ini -m shell -a "mysql --version"
```

### Method 3: Connect to Database as Root

```bash
# SSH to managed node
ssh ziad@192.168.52.134

sudo mysql -u root -p

# Inside MySQL:
SHOW DATABASES;
SELECT USER, HOST FROM mysql.user;
EXIT;
```

### Method 4: Test iVolve User Connection

```bash
# From managed node
mysql -u ziad_ivolve -p -h localhost iVolve

# Enter password: 

# Inside MySQL:
SHOW DATABASES;
SHOW GRANTS FOR CURRENT_USER();
EXIT;
```