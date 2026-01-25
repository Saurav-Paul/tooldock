# tunnel - SSH Port Forwarding Manager

A beautiful CLI tool for managing SSH port forwarding tunnels.

## Installation

```bash
tooldock plugin install tunnel
```

## Quick Start

```bash
# Forward a port
tooldock tunnel start -p 5432 -H user@server

# List active tunnels
tooldock tunnel list

# Stop a tunnel
tooldock tunnel stop 5432
```

## Features

- ✅ Start/stop/restart SSH port forwarding tunnels
- ✅ Beautiful colored terminal UI with status indicators
- ✅ Auto-cleanup of stale tunnels
- ✅ Support for jump hosts (bastion servers)
- ✅ Port remapping (forward local:8080 to remote:3000)
- ✅ List all active tunnels with process information
- ✅ Cross-platform (macOS, Linux, WSL)

## Commands

### Start a Tunnel

Forward a local port to a remote server:

```bash
tooldock tunnel start -p <port> -H <user@host> [-r <remote>]
```

**Options:**
- `-p, --port` - Port mapping (local or local:remote)
- `-H, --host` - SSH host (user@hostname)
- `-r, --remote` - Remote destination (default: localhost)

**Examples:**

Forward localhost:5432 → server:5432
```bash
tooldock tunnel start -p 5432 -H paul@wsl
```

Forward localhost:8080 → server:3000 (port remapping)
```bash
tooldock tunnel start -p 8080:3000 -H user@server.com
```

Forward through jump host
```bash
tooldock tunnel start -p 5432 -H user@jump.com -r db.internal:5432
```

### List Active Tunnels

```bash
tooldock tunnel list
# or simply
tooldock ports
```

**Example output:**
```
╔════════════════════════════════════════════════════════════════╗
║                  Active SSH Tunnels (2)                       ║
╚════════════════════════════════════════════════════════════════╝

Port   → Remote             Host              PID     Status
─────────────────────────────────────────────────────────────────
5432   → localhost:5432    paul@wsl          12345   ✓ Active
8080   → localhost:3000    user@server.com   12346   ✓ Active
```

### Stop a Tunnel

```bash
tooldock tunnel stop <port>
```

**Example:**
```bash
tooldock tunnel stop 5432
```

### Restart a Tunnel

Restart an existing tunnel (useful if connection dropped):

```bash
tooldock tunnel restart <port>
```

**Example:**
```bash
tooldock tunnel restart 5432
```

### Stop All Tunnels

```bash
tooldock tunnel stopall
```

### Show Help

```bash
tooldock tunnel help
tooldock tunnel --help
```

### Show Version

```bash
tooldock tunnel version
```

## Use Cases

### Database Development

Forward PostgreSQL from remote server:
```bash
tooldock tunnel start -p 5432 -H user@db-server
psql -h localhost -p 5432 -U dbuser
```

### Web Development

Forward development server:
```bash
tooldock tunnel start -p 3000 -H user@dev-server
# Access at http://localhost:3000
```

### Accessing Internal Services

Access service behind jump host:
```bash
tooldock tunnel start -p 8080 -H user@bastion.com -r internal-app:8080
# Access internal app at http://localhost:8080
```

### Multiple Ports

Forward multiple services:
```bash
tooldock tunnel start -p 5432 -H user@server  # PostgreSQL
tooldock tunnel start -p 6379 -H user@server  # Redis
tooldock tunnel start -p 3000 -H user@server  # App
```

## Tunnel Management

### Tunnel Registry

Tunnels are tracked in `~/.ssh_tunnels`:

```
port|local_port|remote_host|pid|ssh_host
5432|5432|localhost:5432|12345|paul@wsl
```

### Auto-Cleanup

The tool automatically cleans up:
- Stale tunnel entries (process no longer running)
- Completed SSH processes
- Invalid tunnel configurations

### Process Tracking

Each tunnel is tracked by its SSH process ID. The tool:
- Verifies the process is still running
- Checks if it's actually an SSH tunnel
- Updates status indicators accordingly

## Troubleshooting

### "Port already in use"

**Cause:** Another process is using the port.

**Solution:**
```bash
# Check what's using the port (macOS/Linux)
lsof -i :5432

# Stop existing tunnel if it's stale
tooldock tunnel stop 5432

# Or use a different local port
tooldock tunnel start -p 5433:5432 -H user@server
```

### "SSH connection failed"

**Cause:** Cannot connect to remote host.

**Solutions:**
1. Verify SSH access: `ssh user@host`
2. Check SSH keys are set up
3. Verify hostname/IP is correct
4. Check network connectivity

### "Tunnel shows as active but not working"

**Cause:** SSH process may have crashed.

**Solution:**
```bash
# Restart the tunnel
tooldock tunnel restart 5432

# Or stop and start fresh
tooldock tunnel stop 5432
tooldock tunnel start -p 5432 -H user@server
```

### "Cannot find tunnel file"

**Cause:** Registry file doesn't exist.

**Solution:**
```bash
# The file is created automatically
# Just start a new tunnel
tooldock tunnel start -p 5432 -H user@server
```

## Advanced Usage

### Background Execution

Tunnels run in the background automatically. They persist even if you close the terminal.

### Persistent Tunnels

Add to your shell profile (~/.bashrc or ~/.zshrc):

```bash
# Start tunnels on login
tooldock tunnel start -p 5432 -H paul@wsl 2>/dev/null
tooldock tunnel start -p 3000 -H user@dev-server 2>/dev/null
```

### Custom SSH Options

The tool uses `ssh -f -N -L`, which:
- `-f` - Runs in background
- `-N` - No remote command execution
- `-L` - Local port forwarding

For custom SSH options, run SSH directly:
```bash
ssh -f -N -L 5432:localhost:5432 \
    -o ServerAliveInterval=60 \
    -o ServerAliveCountMax=3 \
    user@server
```

## Requirements

- SSH client installed
- SSH access to remote servers
- Bash shell (macOS, Linux, WSL)
- `lsof` command (usually pre-installed)

## Platform Support

- ✅ macOS (Intel & Apple Silicon)
- ✅ Linux (all distributions)
- ✅ WSL (Windows Subsystem for Linux)
- ❌ Native Windows (use WSL)

## Security

- Uses your existing SSH keys and configuration
- No credentials stored by the tool
- Tunnels are user-scoped (not system-wide)
- All SSH security features apply

## Version History

### 1.0.0 (2026-01-23)
- Initial release
- Basic tunnel management
- Beautiful UI with colors
- Auto-cleanup of stale tunnels
- Cross-platform support

## Contributing

Found a bug or want to add a feature? Contributions welcome!

1. Fork the repository
2. Edit `tooldock-plugins/ports/ports.sh`
3. Test your changes
4. Submit a pull request

## License

MIT License - see [LICENSE](../../LICENSE)
