# tooldock Usage Guide

Complete guide to installing and using tooldock and its plugins.

## Table of Contents

- [Installation](#installation)
- [Basic Commands](#basic-commands)
- [Plugin Management](#plugin-management)
- [Using Plugins](#using-plugins)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)

## Installation

### Option 1: Quick Install (Recommended)

Install tooldock from the latest GitHub release:

```bash
# macOS Apple Silicon
curl -L https://github.com/Saurav-Paul/tooldock/releases/download/v1.0.0/tooldock_darwin_arm64 -o tooldock
chmod +x tooldock
sudo mv tooldock /usr/local/bin/tooldock

# macOS Intel
curl -L https://github.com/Saurav-Paul/tooldock/releases/download/v1.0.0/tooldock_darwin_amd64 -o tooldock
chmod +x tooldock
sudo mv tooldock /usr/local/bin/tooldock

# Linux (x86_64)
curl -L https://github.com/Saurav-Paul/tooldock/releases/download/v1.0.0/tooldock_linux_amd64 -o tooldock
chmod +x tooldock
sudo mv tooldock /usr/local/bin/tooldock

# Linux (ARM64)
curl -L https://github.com/Saurav-Paul/tooldock/releases/download/v1.0.0/tooldock_linux_arm64 -o tooldock
chmod +x tooldock
sudo mv tooldock /usr/local/bin/tooldock
```

### Option 2: Build from Source

Requires Docker (no Go installation needed):

```bash
# Clone the repository
git clone https://github.com/Saurav-Paul/tooldock.git
cd tooldock

# Build for your platform
docker compose run --rm -e GOOS=darwin -e GOARCH=arm64 dev go build -ldflags="-w -s" -o ../build/tooldock .

# Install
sudo cp build/tooldock /usr/local/bin/tooldock
```

### Verify Installation

```bash
tooldock --version
# Output: tooldock version 1.0.0
```

## Basic Commands

### Getting Help

```bash
# Show general help
tooldock help
tooldock --help
tooldock -h

# Show version
tooldock --version
tooldock -v
```

### Plugin Commands

```bash
# List all available plugins
tooldock plugin list

# Search for a plugin
tooldock plugin search <query>

# Install a plugin
tooldock plugin install <name>

# Update a plugin
tooldock plugin update <name>

# Remove a plugin
tooldock plugin remove <name>
```

## Plugin Management

### Listing Plugins

View all available plugins and their installation status:

```bash
tooldock plugin list
```

**Example output:**
```
Available plugins:

✓ ports           SSH port forwarding manager - forward and manage SSH tunnels easily (v1.0.0)

✓ = installed
```

### Installing Plugins

Install a plugin from the registry:

```bash
tooldock plugin install ports
```

**Example output:**
```
📦 Installing ports v1.0.0...
✅ Successfully installed ports
💡 Usage: tooldock ports [args...]
```

**What happens:**
1. Fetches plugin metadata from GitHub
2. Downloads the plugin to `~/.tooldock/plugins/ports`
3. Makes it executable
4. Ready to use!

### Updating Plugins

Update an installed plugin to the latest version:

```bash
tooldock plugin update ports
```

**Example output:**
```
📦 Updating ports to v1.0.1...
✅ Successfully updated ports to v1.0.1
```

### Removing Plugins

Uninstall a plugin:

```bash
tooldock plugin remove ports
```

**Example output:**
```
✅ Successfully removed ports
```

### Searching Plugins

Search for plugins by name or description:

```bash
tooldock plugin search ssh
tooldock plugin search port
```

## Using Plugins

Once a plugin is installed, use it directly with tooldock:

```bash
tooldock <plugin-name> [arguments...]
```

### Example: Using the `ports` Plugin

The `ports` plugin manages SSH port forwarding tunnels.

#### Install the plugin

```bash
tooldock plugin install ports
```

#### View plugin help

```bash
tooldock ports --help
tooldock ports help
```

#### Start a tunnel

Forward localhost:5432 to remote server's port 5432:

```bash
tooldock ports start -p 5432 -H user@server.com
```

Forward with port remapping (local 8080 → remote 3000):

```bash
tooldock ports start -p 8080:3000 -H user@server.com
```

Forward through a jump host:

```bash
tooldock ports start -p 5432 -H user@jump.com -r db.internal:5432
```

#### List active tunnels

```bash
tooldock ports list
# or simply
tooldock ports
```

**Example output:**
```
╔════════════════════════════════════════════════════════════════╗
║                  Active SSH Tunnels (1)                       ║
╚════════════════════════════════════════════════════════════════╝

Port   → Remote             Host              PID     Status
─────────────────────────────────────────────────────────────────
5432   → localhost:5432    user@server.com   12345   ✓ Active
```

#### Stop a tunnel

```bash
tooldock ports stop 5432
```

#### Restart a tunnel

```bash
tooldock ports restart 5432
```

#### Stop all tunnels

```bash
tooldock ports stopall
```

## Configuration

### Plugin Storage

Plugins are stored in your home directory:

```
~/.tooldock/
├── plugins/       # Installed plugins
│   └── ports      # Each plugin is an executable
└── cache/         # Cached registry data
    └── registry.json
```

### Registry URL

The default registry URL is:
```
https://raw.githubusercontent.com/Saurav-Paul/tooldock/main/tooldock-plugins/plugins.json
```

**Override with environment variable:**

```bash
export TOOLDOCK_REGISTRY_URL=https://your-custom-url/plugins.json
tooldock plugin list
```

### Cache

The plugin registry is cached for 24 hours. To force a fresh fetch:

```bash
tooldock plugin update <plugin-name>
```

## Troubleshooting

### Plugin list shows "failed to fetch registry"

**Cause:** Cannot reach GitHub or registry URL is incorrect.

**Solutions:**
1. Check internet connection
2. Verify GitHub is accessible
3. Check if repository is public
4. Try again in a few minutes (GitHub may be rate-limiting)

### "plugin not found in registry"

**Cause:** The plugin doesn't exist in the registry.

**Solutions:**
1. Check spelling: `tooldock plugin list`
2. Search for it: `tooldock plugin search <query>`
3. Verify the plugin exists in [`tooldock-plugins/plugins.json`](https://github.com/Saurav-Paul/tooldock/blob/main/tooldock-plugins/plugins.json)

### Permission denied when installing plugins

**Cause:** Cannot write to `~/.tooldock/plugins/`

**Solution:**
```bash
# Check directory permissions
ls -la ~/.tooldock

# Fix permissions
chmod 755 ~/.tooldock
chmod 755 ~/.tooldock/plugins
```

### Plugin installed but "command not found"

**Cause:** Plugin not executable or tooldock not finding it.

**Solutions:**
```bash
# Check if plugin exists
ls -la ~/.tooldock/plugins/

# Make it executable
chmod +x ~/.tooldock/plugins/<plugin-name>

# Reinstall the plugin
tooldock plugin remove <plugin-name>
tooldock plugin install <plugin-name>
```

### Binary "cannot be opened" (macOS)

**Cause:** macOS Gatekeeper blocking the binary.

**Solutions:**

**Option 1: Remove quarantine attribute**
```bash
xattr -d com.apple.quarantine /usr/local/bin/tooldock
```

**Option 2: Allow in System Preferences**
1. Go to System Preferences → Security & Privacy
2. Click "Allow Anyway" for tooldock

### Plugin execution fails

**Cause:** Plugin requires dependencies or has errors.

**Solutions:**
1. Check plugin documentation
2. View plugin source: `cat ~/.tooldock/plugins/<plugin-name>`
3. Run plugin directly for debugging: `~/.tooldock/plugins/<plugin-name> --help`
4. Report issue to plugin maintainer

## Advanced Usage

### Using Custom Registry

Point to your own plugin registry:

```bash
export TOOLDOCK_REGISTRY_URL=https://myserver.com/plugins.json
tooldock plugin list
```

### Manual Plugin Installation

Install a plugin manually without the registry:

```bash
# Download plugin
curl -L https://url-to-plugin.sh -o ~/.tooldock/plugins/myplugin

# Make executable
chmod +x ~/.tooldock/plugins/myplugin

# Use it
tooldock myplugin --help
```

### Backup Your Plugins

```bash
# Backup installed plugins
tar -czf tooldock-backup.tar.gz ~/.tooldock/plugins/

# Restore
tar -xzf tooldock-backup.tar.gz -C ~/
```

### Uninstall tooldock

```bash
# Remove binary
sudo rm /usr/local/bin/tooldock

# Remove plugins and data
rm -rf ~/.tooldock
```

## Getting Help

- **Documentation**: [GitHub Repository](https://github.com/Saurav-Paul/tooldock)
- **Issues**: [Report a bug](https://github.com/Saurav-Paul/tooldock/issues)
- **Plugin Development**: [Plugin Guide](../tooldock-plugins/README.md)

## Next Steps

- [Create your own plugin](../tooldock-plugins/README.md)
- [View available plugins](../tooldock-plugins/)
- [Contribute to tooldock](../CONTRIBUTING.md)
