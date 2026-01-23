# ssh - Interactive SSH Host Manager

A beautiful CLI tool for quickly connecting to your saved SSH hosts.

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
```

## Features

- ✅ Interactive numbered host selection
- ✅ Reads from ~/.ssh/config automatically
- ✅ Shows host details (user, hostname, port)
- ✅ Direct connection by hostname
- ✅ Beautiful colored terminal UI
- ✅ Works with all SSH config features

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

   1. wsl                  paul@100.68.177.104
   2. production           user@prod-server.com:2222
   3. staging              user@staging.example.com

────────────────────────────────────────────────────────────────
Select host number (or q to quit):
```

Just type the number and press Enter to connect!

### Direct Connection

Connect to a host directly by name:

```bash
tooldock ssh wsl
tooldock ssh production
```

If the host is not in your SSH config, it will attempt a direct connection.

### Show Help

```bash
tooldock ssh --help
tooldock ssh help
```

### Show Version

```bash
tooldock ssh --version
```

## SSH Config Setup

The plugin reads from `~/.ssh/config`. Here's an example configuration:

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

All standard SSH config directives are supported (IdentityFile, ProxyJump, etc.).

## Use Cases

### Quick Development Server Access

```bash
# Add dev servers to ~/.ssh/config
tooldock ssh
# Select from the list
```

### Jump Through Bastion Hosts

Your SSH config can include ProxyJump:

```
Host internal-db
  HostName db.internal
  User admin
  ProxyJump bastion.company.com
```

Then simply:
```bash
tooldock ssh internal-db
```

### Multiple Environments

Organize all your environments in one place:

```
Host prod-api
  HostName api.prod.company.com
  User deploy

Host staging-api
  HostName api.staging.company.com
  User deploy

Host dev-api
  HostName localhost
  Port 2222
```

Quick switching:
```bash
tooldock ssh  # Shows all environments
```

## Requirements

- SSH client installed
- `~/.ssh/config` file with Host entries
- Bash shell

## Tips

### Organize Your SSH Config

Group related hosts together:

```
# Development
Host dev-web
  HostName dev.example.com
  User developer

# Staging
Host staging-web
  HostName staging.example.com
  User deployer

# Production
Host prod-web
  HostName prod.example.com
  User deploy
```

### Use Wildcards for Common Settings

```
Host *.example.com
  User deploy
  IdentityFile ~/.ssh/company_key

Host dev-web
  HostName dev.example.com

Host prod-web
  HostName prod.example.com
```

### Quick Aliases

Create short, memorable host names:

```
Host db
  HostName database-server.company.com
  User postgres

Host cache
  HostName redis.company.com
  User admin
```

Then:
```bash
tooldock ssh db
tooldock ssh cache
```

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
Add some hosts to `~/.ssh/config`:
```
Host myserver
  HostName server.example.com
  User myuser
```

### Host appears but connection fails

**Cause:** SSH configuration issue.

**Solution:**
Test the SSH connection directly:
```bash
ssh -v hostname
```

This will show verbose output to help diagnose the issue.

## Version History

### 1.0.0 (2026-01-23)
- Initial release
- Interactive host selection
- Direct connection support
- SSH config parsing
- Beautiful UI

## Contributing

Found a bug or want to add a feature? Contributions welcome!

## License

MIT License - see [LICENSE](../../LICENSE)
