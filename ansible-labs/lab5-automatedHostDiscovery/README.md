
# Lab 5: Automated Host Discovery with Ansible Dynamic Inventory
### 1. Install AWS CLI
```bash
pip install awscli
```

### 2. Install Required Python Packages
```bash
pip install boto3 botocore
```

## AWS Academy Learner Lab Setup

### Step 1: Get AWS Credentials
1. Log into AWS Academy Learner Lab
2. Click the **"AWS Details"** button
3. Click **"Show"** button next to the AWS CLI credentials section
4. Copy the entire credential block

### Step 2: Configure AWS Credentials

Create or update `~/.aws/credentials`:
```bash
mkdir -p ~/.aws
```

Add the credentials from AWS Academy:
```ini
[default]
aws_access_key_id = ACCESS_KEY
aws_secret_access_key = SECRET_KEY
aws_session_token = SESSION_TOKEN
```

Configure the region in `~/.aws/config`:
```ini
[default]
region = us-east-1
output = json
```

### Step 3: Create EC2 Instance with Tag

1. Log into AWS Academy Learner Lab
2. Navigate to EC2 Dashboard
3. Click **"Launch Instances"**
4. Select Amazon Linux 2 AMI
5. Choose instance type (t2.micro recommended for free tier)
6. Click **"Next: Configure Instance Details"**
7. Click **"Next: Add Storage"** (leave defaults)
8. Click **"Next: Add Tags"**
9. **Add Tag:**
   - Key: `name`
   - Value: `ivolve`
10. Click **"Next: Configure Security Group"**
11. Allow SSH (port 22)
12. Click **"Review and Launch"** → **"Launch"**
13. Select or create a key pair and launch

**Verify Instance:**
```bash
aws ec2 describe-instances --filters "Name=tag:name,Values=ivolve" --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name,Tags[?Key==`name`].Value|[0]]' --output table
```

### Step 4: Create Ansible Configuration

Create `ansible.cfg`:
```ini
[defaults]
host_key_checking = False

inventory = inventory/aws_ec2.yaml

interpreter_python = auto_silent

enable_plugins = amazon.aws.aws_ec2

forks = 10

retry_files_enabled = True
retry_files_save_path = ./logs

log_path = ./logs/ansible.log

force_color = True

remote_user = ec2-user
private_key_file = ~/.ssh/newpair.pem #EC2 Instance Key Pair

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no
control_path = /tmp/ansible-ssh-%%h-%%p-%%r
pipelining = True

[inventory]
enable_plugins = amazon.aws.aws_ec2

```

### Step 5: Create Dynamic Inventory Configuration

Create `inventory/aws_ec2.yaml`:
```yaml
---
plugin: amazon.aws.aws_ec2
regions:
  - us-east-1
filters:
  tag:name: ivolve
  instance-state-name: running

keyed_groups:
  - key: placement.region
    parent_group: aws_region
    prefix: aws_region
    
  - key: tags.name
    parent_group: aws_tags
    prefix: tag

hostnames:
  - dns-name
  - private-ip-address
  - instance-id

compose:
  ansible_host: dns_name
  instance_id: instance_id
  instance_type: instance_type
  availability_zone: placement.availability_zone
  vpc_id: vpc_id
  security_groups: security_groups

vars:
  ansible_user: ec2-user
  ansible_port: 22
  ansible_connection: ssh
```

### Step 6: Install Required Ansible Collection

```bash
ansible-galaxy collection install amazon.aws
```

### List All Discovered Hosts

```bash
ansible-inventory -i inventory/aws_ec2.yaml --list
```

## Create Playbook: Ping All Discovered Hosts

Create `playbooks/ping_hosts.yml`:
```yaml
---
- name: Ping all discovered EC2 instances
  hosts: all
  gather_facts: no
  
  tasks:
    - name: Ping all hosts to verify connectivity
      ping:
      register: ping_result
      
    - name: Display ping results
      debug:
        msg: |
          Host: {{ inventory_hostname }}
          Status: {{ ping_result.ping }}
          Response Time: SUCCESS
```