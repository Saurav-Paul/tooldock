# Introduction to tooldock

**tooldock** is a lightweight, plugin-based CLI toolkit designed for managing personal development tools. Instead of installing every tool globally, tooldock lets you install only what you need through a simple plugin system.

## What is tooldock?

tooldock is inspired by tools like `kubectl` + `krew`, `asdf`, and `git`. It provides:

- 🔌 **Plugin Architecture** - Add tools as plugins, install only what you need
- 📦 **Zero Dependencies** - Single binary (~5MB), runs anywhere
- 🚀 **Fast & Lightweight** - Minimal overhead, instant startup
- 🔄 **Easy Updates** - Update plugins independently
- 🛡️ **Secure** - Checksum verification for all plugins
- 🌍 **Cross-Platform** - Works on macOS, Linux, and WSL

## Why tooldock?

### The Problem

As developers, we accumulate dozens of CLI tools over time:
- Port forwarding managers
- Database clients
- API testing tools
- Custom scripts
- Utility commands

Managing these tools becomes a hassle:
- ❌ Global installations clutter your system
- ❌ Version conflicts between tools
- ❌ Hard to share your toolset with others
- ❌ Difficult to keep tools updated
- ❌ No central management

### The Solution

tooldock provides a unified interface for all your tools:
- ✅ Install tools on-demand
- ✅ One command to list, install, update, and remove
- ✅ Share your plugin registry with teams
- ✅ Keep your system clean
- ✅ Version-controlled tool configurations

## How It Works

```
┌─────────────────────────────────────────────────┐
│                                                 │
│              tooldock (Core CLI)                │
│                    ~5MB                         │
│                                                 │
└─────────────────────────────────────────────────┘
                      │
                      ├─ Plugin Registry (GitHub)
                      │  └─ plugins.json
                      │
                      ├─ ~/.tooldock/plugins/
                      │  ├─ ports
                      │  ├─ db-connect
                      │  └─ api-tester
                      │
                      └─ Transparent Execution
                         └─ tooldock <plugin> [args]
```

1. **Core CLI**: Lightweight Go binary that manages plugins
2. **Plugin Registry**: JSON file listing available plugins (hosted on GitHub)
3. **Plugin Storage**: Plugins stored in `~/.tooldock/plugins/`
4. **Execution**: When you run `tooldock <plugin>`, it delegates to the plugin

## Key Concepts

### Plugin Registry

A simple JSON file that lists all available plugins:

```json
{
  "version": "1.0",
  "plugins": [
    {
      "name": "ports",
      "description": "SSH port forwarding manager",
      "version": "1.0.0",
      "url": "https://raw.githubusercontent.com/.../ports.sh",
      "type": "script",
      "checksum": "sha256:..."
    }
  ]
}
```

### Plugin Types

Plugins can be:
- **Scripts** - Bash, Python, Ruby, etc.
- **Binaries** - Compiled Go, Rust, C programs
- **Anything executable** - As long as it's executable, it works

### Transparent Execution

When you install a plugin, you use it directly:

```bash
# Install
tooldock plugin install ports

# Use it
tooldock ports start -p 5432 --host server.com

# Not like this:
# tooldock run ports start ...  ❌
```

The `tooldock` command automatically detects and executes installed plugins.

## Quick Example

```bash
# 1. Install tooldock
curl -sfL https://raw.githubusercontent.com/yourname/tooldock/main/install.sh | sh

# 2. See what's available
tooldock plugin list

# 3. Install a plugin
tooldock plugin install ports

# 4. Use it immediately
tooldock ports start -p 5432 --host wsl
tooldock ports list
tooldock ports stop 5432

# 5. Update when needed
tooldock plugin update ports

# 6. Remove if you don't need it
tooldock plugin remove ports
```

## Design Philosophy

### Keep It Simple
- Single binary, no runtime dependencies
- Plain text configuration (JSON)
- Standard Unix conventions

### Keep It Fast
- Minimal overhead (~10ms startup)
- Lazy loading of plugins
- Efficient caching

### Keep It Clean
- No global pollution
- Isolated plugin storage
- Easy cleanup

### Keep It Extensible
- Any language for plugins
- Simple plugin format
- Git-based distribution

## Use Cases

### Personal Toolkit
Manage your own collection of development tools:
```bash
tooldock plugin install ports
tooldock plugin install db-tools
tooldock plugin install api-client
```

### Team Sharing
Share a plugin registry with your team:
```bash
# Everyone uses the same tools
tooldock plugin install company-vpn
tooldock plugin install deployment-tools
```

### Environment-Specific Tools
Different tools for different projects:
```bash
# Project A
tooldock plugin install legacy-db-client

# Project B (different environment)
tooldock plugin install modern-api-tools
```

## What's Next?

- [Browse Available Tools](./plugins.md)
- [Get Started with Development](./development.md)
- [Learn Docker Development](./docker.md)
- [Quick Start Guide](./quickstart.md)
