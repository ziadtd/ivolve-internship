# Lab 4: Securing Sensitive Data with Ansible Vault

## Overview

Lab 4 is about how to use Ansible Vault to encrypt and manage sensitive credentials while automating MySQL database setup. Install MySQL, create the iVolve database, and create a user with full privileges—all while keeping passwords encrypted.

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
