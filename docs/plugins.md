# Available Plugins

This document lists all available plugins for tooldock and how to use them.

## Plugin Management Commands

```bash
# List all available plugins
tooldock plugin list

# Search for a plugin
tooldock plugin search <keyword>

# Install a plugin
tooldock plugin install <name>

# Update a plugin
tooldock plugin update <name>

# Remove a plugin
tooldock plugin remove <name>
```

## Currently Available Plugins

### ports - SSH Port Forwarding Manager

**Status**: ✅ Available
**Version**: 1.0.0
**Type**: Bash Script

A beautiful CLI tool to manage SSH port forwards, similar to VS Code's port forwarding feature.

#### Features
- Start/stop/restart SSH tunnels
- List active tunnels with uptime
- Docker-like port mapping syntax
- Auto-cleanup of stale tunnels
- Beautiful terminal UI

#### Installation

```bash
tooldock plugin install ports
```

#### Usage

```bash
# Forward same port
tooldock ports start -p 5432 --host user@server.com

# Forward different ports
tooldock ports start -p 8080:3000 --host user@server.com

# Via jump host
tooldock ports start -p 5432 --host jump.com -remote db.internal:5432

# List active tunnels
tooldock ports list
# or just:
tooldock ports

# Stop a tunnel
tooldock ports stop 5432

# Restart a tunnel
tooldock ports restart 5432

# Stop all tunnels
tooldock ports stopall
```

#### Examples

```bash
# Forward PostgreSQL
tooldock ports start -p 5432 --host paul@wsl

# Forward local 8080 to remote 3000
tooldock ports start -p 8080:3000 --host dev-server

# Multiple tunnels
tooldock ports start -p 5432 --host wsl
tooldock ports start -p 3000 --host wsl
tooldock ports start -p 8080:80 --host wsl
```

---

## Coming Soon

The following plugins are planned or under development:

### db-tools - Database Connection Manager
- Quick connect to databases
- Saved connection profiles
- Multiple database support (PostgreSQL, MySQL, MongoDB)

### api-client - API Testing Tool
- Send HTTP requests from CLI
- Save and organize requests
- Environment variables support

### env-manager - Environment Variable Manager
- Manage .env files across projects
- Encrypted secrets storage
- Environment switching

### git-flow - Enhanced Git Workflow
- Simplified branch management
- PR creation from CLI
- Commit message templates

## Creating Your Own Plugin

Want to add your own tool? It's easy! See our [Plugin Development Guide](./creating-plugins.md).

### Quick Start

1. **Create your executable** (bash script, Go binary, Python script, etc.)
2. **Host it on GitHub** (in your tooldock-plugins repository)
3. **Add to plugins.json**:

```json
{
  "name": "my-tool",
  "description": "A useful development tool",
  "version": "1.0.0",
  "url": "https://raw.githubusercontent.com/username/tooldock-plugins/main/my-tool/my-tool.sh",
  "type": "script",
  "checksum": "sha256:..."
}
```

4. **Test it**:

```bash
tooldock plugin install my-tool
tooldock my-tool --help
```

### Plugin Requirements

- Must be executable
- Should accept `--help` flag
- Should have proper error handling
- Should return appropriate exit codes

### Plugin Best Practices

- ✅ Clear, helpful error messages
- ✅ Colorful, beautiful output
- ✅ Fast startup time
- ✅ Minimal dependencies
- ✅ Good documentation

## Plugin Statistics

| Plugin | Downloads | Rating | Last Updated |
|--------|-----------|--------|--------------|
| ports  | -         | ⭐⭐⭐⭐⭐ | 2026-01-23   |

## Contributing Plugins

We welcome contributions! To add your plugin:

1. Fork the `tooldock-plugins` repository
2. Add your plugin to the appropriate directory
3. Update `plugins.json`
4. Submit a Pull Request

See [CONTRIBUTING.md](./contributing.md) for detailed guidelines.

## Plugin Support

If you encounter issues with a plugin:

1. Check the plugin's documentation: `tooldock <plugin> --help`
2. Report issues on GitHub
3. Join our community discussions

## Security

All plugins are:
- ✅ Checksum verified
- ✅ Downloaded over HTTPS
- ✅ Reviewed before addition to registry
- ✅ Open source and auditable

**Note**: Only install plugins from trusted sources. Review the code before installing if you're unsure.
