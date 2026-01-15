# Bootstrap Server

A 2-phase Ansible playbook for securely bootstrapping and hardening new servers following infrastructure best practices.

## 📋 Overview

This playbook implements a secure server setup in two distinct phases:

- **Phase 1 (Bootstrap)**: Runs as `root` - creates a non-root user with sudo access and disables root SSH
- **Phase 2 (Hardening)**: Runs as the bootstrap user - hardens SSH and configures firewall

> ⚠️ **Important**: After Phase 1 completes, root SSH access is disabled. All subsequent operations must use the bootstrap user.

## 🏗️ Project Structure

```
.
├── ansible.cfg
├── inventory               # Your server hosts
├── site.yml               # Main 2-phase playbook
├── requirements.yml       # Ansible collections
├── group_vars/
│   └── servers.yml       # Host group variables
└── roles/
    ├── bootstrap_user/   # Phase 1: User creation & root disable
    │   ├── defaults/main.yml
    │   ├── handlers/main.yml
    │   ├── meta/main.yml
    │   └── tasks/main.yml
    ├── ssh_hardening/    # Phase 2: SSH security
    │   ├── defaults/main.yml
    │   ├── handlers/main.yml
    │   ├── meta/main.yml
    │   └── tasks/main.yml
    └── firewall/         # Phase 2: Firewall setup
        ├── defaults/main.yml
        ├── handlers/main.yml
        ├── meta/main.yml
        └── tasks/
            ├── main.yml
            ├── ufw.yml
            └── firewalld.yml
```

## 🚀 Quick Start

### 1. Install Ansible Collections

```zsh
ansible-galaxy collection install -r requirements.yml -p collections/ --force
```

### 2. Configure Your Inventory

Edit `inventory` file with your server(s):
```ini
[servers]
your-server ansible_host=1.2.3.4
```

### 3. Configure Variables

Edit `group_vars/servers.yml`:
```yaml
bootstrap_user: your_username
bootstrap_pubkey: "{{ lookup('file', '~/.ssh/id_ed25519.pub') }}"
ssh_port: 22
firewall_allowed_ports:
  - 22   # SSH
  - 80   # HTTP
  - 443  # HTTPS
```

### 4. Initial Server Setup (First Time Only)

If your server blocks root SSH by default, manually add your SSH key:

```zsh
# Connect via console/web panel, then:
mkdir -p /root/.ssh
nano /root/.ssh/authorized_keys
# Paste your public key from ~/.ssh/id_ed25519.pub

# Set permissions
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
```

### 5. Test Connection

```zsh
# Test SSH
ssh root@your-server-ip

# Test Ansible connectivity
ansible servers -m ping -i inventory
```

Expected output:
```zsh
your-server | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

### 6. Run Playbook

```zsh
# Dry run (check mode)
ansible-playbook -i inventory site.yml --check

# Full deployment
ansible-playbook -i inventory site.yml
```

## 📦 Roles

### Phase 1: `bootstrap_user` (runs as root)

**Tasks**:
- Install sudo package
- Create bootstrap user in sudo/wheel group
- Add SSH public key for passwordless login
- Configure passwordless sudo (NOPASSWD)
- Disable root SSH login

### Phase 2: `ssh_hardening` (runs as bootstrap user)

**Tasks**:
- Disable password authentication
- Configure SSH port
- Disable empty passwords
- Set MaxAuthTries limit
- Disable X11 forwarding

### Phase 2: `firewall` (runs as bootstrap user)

**Supports**:
- UFW (Debian/Ubuntu)
- firewalld (RHEL/CentOS/Fedora)

**Tasks**:
- Install and configure firewall
- Allow SSH and specified ports
- Set default deny incoming policy
- Enable firewall service

## 🔐 Security Features

✅ Non-root user with sudo access  
✅ SSH key-only authentication  
✅ Root SSH login disabled  
✅ Password authentication disabled  
✅ Limited authentication attempts  
✅ Host firewall enabled  
✅ Default deny incoming policy  

## 🛠️ Supported Platforms

- Ubuntu 20.04+
- Debian 11+
- RHEL/CentOS/Rocky/AlmaLinux 8+
- Fedora 38+

## 📝 Advanced Usage

### Run Specific Phase

```zsh
# Only bootstrap (Phase 1)
ansible-playbook -i inventory site.yml --limit servers --tags bootstrap

# Only hardening (Phase 2)
ansible-playbook -i inventory site.yml --tags hardening
```

### Override Variables

Create `host_vars/your-server.yml`:
```yaml
ssh_port: 2222
firewall_allowed_ports:
  - 2222
  - 80
  - 443
  - 3000
```

### Verbose Output

```zsh
ansible-playbook -i inventory site.yml -vvv
```

## ⚠️ Important Notes

1. **Phase 1 runs ONCE** on new servers only
2. **Keep SSH connection open** during Phase 1 until you verify the new user can connect
3. **Test sudo access** immediately: `ssh hoang@server 'sudo whoami'`
4. **Never re-run Phase 1** on configured servers (root SSH is disabled)
5. **Backup** your inventory and group_vars before major changes

## 📄 License

MIT

## 👤 Author

lcaohoanq
