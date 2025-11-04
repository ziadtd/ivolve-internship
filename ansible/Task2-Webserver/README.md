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

Open browser and navigate to:
```
http://192.168.52.134
```
