# ssh - Interactive SSH Host Manager

A beautiful CLI tool for quickly connecting to your saved SSH hosts and running remote commands.

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Features](#features)
- [Usage](#usage)
  - [Interactive Mode](#interactive-mode)
  - [Direct Connection](#direct-connection)
  - [Remote Command Execution](#remote-command-execution)
- [SSH Config Setup](#ssh-config-setup)
- [Use Cases](#use-cases)
- [Advanced Usage](#advanced-usage)
- [Troubleshooting](#troubleshooting)
- [Tips & Best Practices](#tips--best-practices)

## Installation

```bash
tooldock plugin install ssh
```

## Quick Start

```bash
# Show interactive host selection
tooldock ssh

# Connect directly to a host
tooldock ssh wsl

# Run a command on remote host
tooldock ssh wsl docker ps
```

## Features

- ✅ Interactive numbered host selection
- ✅ Reads from ~/.ssh/config automatically
- ✅ Shows host details (user, hostname, port)
- ✅ Direct connection by hostname
- ✅ **NEW:** Remote command execution with full TTY support
- ✅ Support for interactive programs (vim, htop, Claude, etc.)
- ✅ Beautiful colored terminal UI
- ✅ Works with all SSH config features (ProxyJump, IdentityFile, etc.)

## Usage

### Interactive Mode

Simply run `tooldock ssh` to see a numbered list of your SSH hosts:

```bash
tooldock ssh
```

**Example output:**
```
╔════════════════════════════════════════════════════════════════╗
║                    SSH Host Selector                       ║
╚════════════════════════════════════════════════════════════════╝

   1. orb                  affpilot@orb
   2. wsl                  paul@100.68.177.104
   3. production           deploy@prod-server.com:2222

────────────────────────────────────────────────────────────────
Select host number (or q to quit):
```

**Actions:**
- Type a number (1-3) to connect to that host
- Type `q` or press Ctrl+C to quit

### Direct Connection

Connect to a host directly by name:

```bash
tooldock ssh wsl
tooldock ssh production
tooldock ssh orb
```

**Behavior:**
- If the host exists in `~/.ssh/config`, uses those settings
- If not found, attempts direct connection with the name as hostname

### Remote Command Execution

**NEW in v1.1.0:** Run commands on remote hosts without opening an interactive shell.

#### Basic Syntax

```bash
tooldock ssh <hostname> <command> [arguments...]
```

#### Examples

**Run a single command:**
```bash
# Check Docker containers
tooldock ssh wsl docker ps

# View system information
tooldock ssh orb uname -a

# Check disk usage
tooldock ssh production df -h
```

**Interactive programs (full TTY support):**
```bash
# Start Claude on remote machine
tooldock ssh wsl claude

# Edit a file with vim
tooldock ssh orb vim ~/config.yaml

# Monitor system resources
tooldock ssh production htop

# Interactive Python REPL
tooldock ssh wsl python3
```

**Complex commands (use quotes):**
```bash
# Change directory and run command
tooldock ssh wsl "cd ~/project && npm start"

# Pipe commands
tooldock ssh orb "docker ps | grep running"

# Multi-line commands
tooldock ssh production "
  cd /var/www/app
  git pull
  npm install
  pm2 restart app
"
```

**Development workflows:**
```bash
# Start development server
tooldock ssh wsl "cd ~/api && poetry run api --debug"

# Run tests
tooldock ssh orb "cd ~/project && npm test"

# View logs
tooldock ssh production "tail -f /var/log/app.log"

# Execute database migration
tooldock ssh wsl "cd ~/project && python manage.py migrate"
```

## SSH Config Setup

The plugin reads from `~/.ssh/config`. Here's an example configuration:

### Basic Configuration

```
Host wsl
  HostName 100.68.177.104
  User paul
  Port 22

Host production
  HostName prod-server.com
  User deploy
  Port 2222
  IdentityFile ~/.ssh/prod_key

Host staging
  HostName staging.example.com
  User developer
```

### Advanced Configuration

**Using ProxyJump (Bastion/Jump Host):**
```
Host bastion
  HostName jump.company.com
  User admin
  IdentityFile ~/.ssh/bastion_key

Host internal-db
  HostName db.internal.company.com
  User dbadmin
  ProxyJump bastion
  # Or use: ProxyCommand ssh -W %h:%p bastion
```

**Multiple Identity Files:**
```
Host github
  HostName github.com
  User git
  IdentityFile ~/.ssh/github_personal
  IdentityFile ~/.ssh/github_work
  IdentitiesOnly yes
```

**Connection Keep-Alive:**
```
Host *
  ServerAliveInterval 60
  ServerAliveCountMax 3
  TCPKeepAlive yes
```

**Compression for Slow Connections:**
```
Host remote-slow
  HostName slow-server.com
  User admin
  Compression yes
  CompressionLevel 6
```

## Use Cases

### 1. Quick Development Server Access

Connect to development servers with a single command:

```bash
# Interactive selection
tooldock ssh

# Direct connection
tooldock ssh dev-server

# Run command
tooldock ssh dev-server systemctl status nginx
```

### 2. Remote Development with Claude

Work with Claude on a remote machine:

```bash
# Start interactive Claude session
tooldock ssh wsl claude

# Perfect for:
# - Working on remote projects
# - Using Claude with WSL environment
# - Accessing Claude from anywhere
```

### 3. Container Management

Manage Docker containers on remote hosts:

```bash
# List containers
tooldock ssh production docker ps

# View logs
tooldock ssh production docker logs -f my-app

# Exec into container
tooldock ssh production docker exec -it my-app bash

# Docker Compose operations
tooldock ssh staging "cd ~/app && docker-compose up -d"
```

### 4. Database Operations

Interact with databases on remote servers:

```bash
# PostgreSQL
tooldock ssh db-server psql -U postgres -d mydb

# MySQL
tooldock ssh mysql-server mysql -u root -p

# Redis CLI
tooldock ssh cache-server redis-cli

# Run migration
tooldock ssh app-server "cd ~/project && python manage.py migrate"
```

### 5. Log Monitoring

Tail logs from remote servers:

```bash
# Application logs
tooldock ssh production "tail -f /var/log/app/error.log"

# System logs
tooldock ssh web-server "journalctl -f -u nginx"

# Docker logs
tooldock ssh api-server "docker logs -f api-container"
```

### 6. Deployment Operations

Deploy applications remotely:

```bash
# Pull and restart
tooldock ssh production "
  cd /var/www/app
  git pull origin main
  npm install
  pm2 restart app
"

# Build and deploy
tooldock ssh staging "
  cd ~/project
  git fetch --all
  git reset --hard origin/develop
  npm run build
  sudo systemctl restart app
"
```

### 7. System Administration

Perform system tasks:

```bash
# Check disk space
tooldock ssh server df -h

# Monitor resources
tooldock ssh server htop

# View running processes
tooldock ssh server ps aux | grep node

# System updates
tooldock ssh server "sudo apt update && sudo apt upgrade -y"
```

## Advanced Usage

### Using with SSH Agent

Forward your SSH agent to access further hosts:

```bash
# SSH config
Host jump-server
  HostName jump.company.com
  User admin
  ForwardAgent yes

# Now you can access internal hosts through jump server
tooldock ssh jump-server ssh internal-host
```

### Port Forwarding

Combine with `tooldock tunnel` for port forwarding:

```bash
# In one terminal: Start tunnel
tooldock tunnel start -p 8080 -H wsl

# In another: Run service
tooldock ssh wsl "cd ~/api && poetry run api"

# Access on localhost:8080 from your Mac
```

### Custom SSH Options

Add custom SSH options in your config:

```
Host custom-server
  HostName server.com
  User admin
  # Disable strict host key checking (be careful!)
  StrictHostKeyChecking no
  # Use specific cipher
  Ciphers aes256-ctr
  # Connection timeout
  ConnectTimeout 10
```

### SSH Multiplexing (Faster Connections)

Speed up repeated connections:

```
Host *
  ControlMaster auto
  ControlPath ~/.ssh/sockets/%r@%h:%p
  ControlPersist 600
```

Create socket directory:
```bash
mkdir -p ~/.ssh/sockets
```

Now subsequent connections to the same host will be instant!

## Troubleshooting

### "SSH config file not found"

**Cause:** No `~/.ssh/config` file exists.

**Solution:**
```bash
mkdir -p ~/.ssh
touch ~/.ssh/config
chmod 600 ~/.ssh/config
```

Add at least one host:
```
Host example
  HostName example.com
  User yourname
```

### "No hosts found in ~/.ssh/config"

**Cause:** No `Host` entries in your SSH config.

**Solution:**
Add hosts to `~/.ssh/config`:
```
Host myserver
  HostName server.example.com
  User myuser
```

### "Permission denied (publickey)"

**Cause:** SSH key authentication failed.

**Solutions:**

1. **Check if you have SSH keys:**
   ```bash
   ls -la ~/.ssh/
   ```

2. **Generate SSH keys if missing:**
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```

3. **Copy key to remote server:**
   ```bash
   ssh-copy-id user@hostname
   ```

4. **Verify key is added to ssh-agent:**
   ```bash
   ssh-add -l
   ssh-add ~/.ssh/id_ed25519  # If not listed
   ```

### "Connection timed out"

**Cause:** Cannot reach the server.

**Checks:**
1. Verify hostname: `ping hostname`
2. Check if SSH port is open: `nc -zv hostname 22`
3. Verify network connectivity
4. Check firewall rules

### "Host key verification failed"

**Cause:** Server's host key changed (MITM warning).

**Solution (if legitimate):**
```bash
# Remove old key
ssh-keygen -R hostname

# Or remove specific line from known_hosts
# Edit ~/.ssh/known_hosts and delete the line for that host

# Connect again - will add new key
tooldock ssh hostname
```

### Remote command not working

**Problem:** Command works in SSH but not with `tooldock ssh hostname command`

**Cause:** Environment differences (non-interactive vs interactive shell)

**Solutions:**

1. **Source profile explicitly:**
   ```bash
   tooldock ssh hostname "source ~/.bashrc && your-command"
   ```

2. **Use full paths:**
   ```bash
   tooldock ssh hostname "/usr/local/bin/node app.js"
   ```

3. **Use login shell:**
   ```bash
   ssh hostname "bash -l -c 'your-command'"
   ```

### Interactive program doesn't work

**Problem:** Interactive program (vim, htop) displays incorrectly

**Cause:** TTY allocation issue (shouldn't happen with this plugin, but if it does)

**Solution:**
The plugin uses `ssh -t` which allocates a pseudo-TTY. If issues persist:
```bash
# Try with explicit TTY allocation
ssh -tt hostname your-command
```

## Tips & Best Practices

### 1. Organize Your SSH Config

Group related hosts together with comments:

```
# ================================
# Development Servers
# ================================
Host dev-api
  HostName dev-api.company.com
  User developer

Host dev-db
  HostName dev-db.company.com
  User developer

# ================================
# Production Servers
# ================================
Host prod-api
  HostName api.company.com
  User deploy
  IdentityFile ~/.ssh/prod_key
```

### 2. Use Wildcards for Common Settings

```
Host *.company.com
  User deploy
  IdentityFile ~/.ssh/company_key
  ServerAliveInterval 60

Host dev-*
  User developer
  IdentityFile ~/.ssh/dev_key
```

### 3. Create Short Aliases

```
Host db
  HostName database-server.company.com
  User postgres

Host cache
  HostName redis.company.com
  User admin

Host ci
  HostName jenkins.company.com
  User jenkins
```

Usage:
```bash
tooldock ssh db
tooldock ssh cache
tooldock ssh ci
```

### 4. Security Best Practices

**Use strong SSH keys:**
```bash
# ED25519 (recommended)
ssh-keygen -t ed25519 -C "your_email@example.com"

# Or RSA 4096
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

**Disable password authentication:**
```
Host *
  PasswordAuthentication no
  ChallengeResponseAuthentication no
  PubkeyAuthentication yes
```

**Use different keys for different services:**
```
Host github
  HostName github.com
  User git
  IdentityFile ~/.ssh/github_key

Host work-server
  HostName work.com
  User admin
  IdentityFile ~/.ssh/work_key
```

### 5. Connection Persistence

Keep connections alive to avoid disconnects:

```
Host *
  ServerAliveInterval 60
  ServerAliveCountMax 3
  TCPKeepAlive yes
```

### 6. Jump Host Configuration

Access internal servers through bastion:

```
Host bastion
  HostName jump.company.com
  User admin

Host internal-*
  ProxyJump bastion
  User developer

Host internal-db
  HostName db.internal.company.com

Host internal-api
  HostName api.internal.company.com
```

Usage:
```bash
# Automatically jumps through bastion
tooldock ssh internal-db
```

## Requirements

- SSH client installed (`openssh-client`)
- `~/.ssh/config` file with Host entries
- Bash shell (macOS, Linux, WSL)

## Platform Support

- ✅ macOS (Intel & Apple Silicon)
- ✅ Linux (all distributions)
- ✅ WSL (Windows Subsystem for Linux)

## Version History

### 1.1.0 (2026-01-24)
- Added remote command execution
- Full TTY support for interactive programs
- Enhanced help documentation

### 1.0.0 (2026-01-23)
- Initial release
- Interactive host selection
- Direct connection support
- SSH config parsing
- Beautiful UI

## Contributing

Found a bug or want to add a feature? Contributions welcome!

1. Fork the repository
2. Edit `tooldock-plugins/ssh/ssh.sh`
3. Test your changes
4. Submit a pull request

## License

MIT License - see [LICENSE](../../LICENSE)
