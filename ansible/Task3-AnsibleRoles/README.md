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

Update  `inventory.ini`:

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

