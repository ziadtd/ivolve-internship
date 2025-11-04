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

