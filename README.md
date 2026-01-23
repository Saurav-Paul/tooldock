# tooldock

> A lightweight, plugin-based CLI toolkit for personal development tools

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Go Version](https://img.shields.io/badge/Go-1.21+-00ADD8?logo=go)](https://go.dev/)
[![Docker](https://img.shields.io/badge/Docker-Supported-2496ED?logo=docker)](https://www.docker.com/)

## What is tooldock?

tooldock is a plugin manager for CLI tools. Install only the tools you need, when you need them.

```bash
# Install tooldock
curl -sfL https://raw.githubusercontent.com/Saurav-Paul/tooldock/main/install.sh | sh

# Install a plugin
tooldock plugin install ports

# Use it immediately
tooldock ports start -p 5432 --host wsl
```

## Features

- 🔌 **Plugin-based** - Install only what you need
- 📦 **Zero dependencies** - Single binary (~5MB)
- 🚀 **Fast** - Instant startup, minimal overhead
- 🔄 **Easy updates** - Update plugins independently
- 🛡️ **Secure** - Checksum verification
- 🐳 **Docker support** - Build without Go installation
- 🌍 **Cross-platform** - macOS, Linux, WSL

## Quick Start

### Installation

**Build from source (cross-platform):**

```bash
# Clone the repo
git clone https://github.com/Saurav-Paul/tooldock.git
cd tooldock

# Build for macOS Apple Silicon
docker compose run --rm -e GOOS=darwin -e GOARCH=arm64 dev go build -ldflags="-w -s" -o ../build/tooldock .

# Build for macOS Intel
docker compose run --rm -e GOOS=darwin -e GOARCH=amd64 dev go build -ldflags="-w -s" -o ../build/tooldock .

# Build for Linux
docker compose run --rm -e GOOS=linux -e GOARCH=amd64 dev go build -ldflags="-w -s" -o ../build/tooldock .

# Install
sudo cp build/tooldock /usr/local/bin/tooldock
tooldock --version
```

### Usage

```bash
# List available plugins
tooldock plugin list

# Install a plugin
tooldock plugin install ports

# Use the plugin
tooldock ports start -p 5432 --host user@server

# Update a plugin
tooldock plugin update ports

# Remove a plugin
tooldock plugin remove ports
```

## Documentation

<details>
<summary><strong>📖 Introduction</strong> - What is tooldock and why use it?</summary>

<br>

**tooldock** is a plugin manager that helps you organize and manage your CLI tools. Instead of installing every tool globally, install only what you need through plugins.

### Why tooldock?

- ✅ Keep your system clean - no global pollution
- ✅ Install tools on-demand
- ✅ Version-controlled toolset
- ✅ Share tools with your team
- ✅ Easy to update and remove

### How it works

1. **Core CLI**: Lightweight binary that manages plugins
2. **Plugin Registry**: JSON file listing available plugins (GitHub)
3. **Plugin Storage**: Plugins in `~/.tooldock/plugins/`
4. **Execution**: `tooldock <plugin>` delegates to the plugin

[Read full introduction →](docs/introduction.md)

</details>

<details>
<summary><strong>🔌 Available Plugins</strong> - Browse and install plugins</summary>

<br>

### Currently Available

#### ports - SSH Port Forwarding Manager
Manage SSH port forwards with a beautiful CLI interface.

```bash
tooldock plugin install ports
tooldock ports start -p 5432 --host wsl
tooldock ports list
```

**Features:**
- Start/stop/restart tunnels
- Beautiful terminal UI
- Auto-cleanup of stale tunnels
- Docker-like syntax

### Coming Soon

- **db-tools** - Database connection manager
- **api-client** - API testing tool
- **env-manager** - Environment variable manager
- **git-flow** - Enhanced Git workflow

### Plugin Commands

```bash
tooldock plugin list              # List all plugins
tooldock plugin search <query>    # Search plugins
tooldock plugin install <name>    # Install a plugin
tooldock plugin update <name>     # Update a plugin
tooldock plugin remove <name>     # Remove a plugin
```

[See all plugins and usage →](docs/plugins.md)

</details>

<details>
<summary><strong>💻 Development</strong> - Build and contribute</summary>

<br>

### Prerequisites

**Option 1: Docker (No Go needed)**
- Docker
- Docker Compose

**Option 2: Local Go**
- Go 1.21+

### Quick Start

**Using Docker:**

```bash
git clone https://github.com/Saurav-Paul/tooldock.git
cd tooldock

# Initialize and build
./docker.sh init
./docker.sh build

# Test
./docker.sh run version
```

**Using Go:**

```bash
git clone https://github.com/Saurav-Paul/tooldock.git
cd tooldock

# Build
go build -o tooldock .

# Test
./tooldock version
```

### Development Workflow

```bash
# Make changes
vim cmd/plugin.go

# Build
./docker.sh build  # or: make build

# Test
./docker.sh run plugin list
```

### Project Structure

```
tooldock/
├── cmd/          # Commands (plugin, root)
├── pkg/          # Packages (config, executor, registry)
├── docs/         # Documentation
└── build/        # Compiled binaries
```

[Full development guide →](docs/development.md)

### Docker Development

```bash
./docker.sh init         # Initialize
./docker.sh build        # Build for current platform
./docker.sh build-all    # Build all platforms
./docker.sh shell        # Interactive shell
./docker.sh run [args]   # Run tooldock
```

[Docker development guide →](docs/docker.md)

[Quick start guide →](docs/quickstart.md)

</details>

## Usage Examples

### Managing Plugins

```bash
# List all available plugins
tooldock plugin list

# Search for a plugin
tooldock plugin search port

# Install a plugin
tooldock plugin install ports

# Update all plugins
tooldock plugin update ports

# Remove a plugin
tooldock plugin remove ports
```

### Using Plugins

Once installed, use plugins directly:

```bash
# SSH port forwarding
tooldock ports start -p 5432 --host wsl
tooldock ports list
tooldock ports stop 5432

# Future plugins:
tooldock db-connect production
tooldock api-client POST /api/users
```

## Architecture

```
┌─────────────────────────────────────────────┐
│          tooldock (Core ~5MB)               │
│  • Plugin management                        │
│  • Registry handling                        │
│  • Plugin execution                         │
└─────────────────────────────────────────────┘
                  │
                  ├─ Plugin Registry (GitHub)
                  │  └─ plugins.json
                  │
                  ├─ ~/.tooldock/
                  │  ├─ plugins/
                  │  │  ├─ ports
                  │  │  └─ other-tools
                  │  └─ cache/
                  │     └─ registry.json
                  │
                  └─ Transparent Execution
                     └─ tooldock <plugin> [args...]
```

## Creating Plugins

Plugins are simple executables. Create one in any language:

```json
{
  "name": "my-tool",
  "description": "My useful tool",
  "version": "1.0.0",
  "url": "https://raw.githubusercontent.com/.../my-tool.sh",
  "type": "script",
  "checksum": "sha256:..."
}
```

See [Plugin Development Guide](docs/plugins.md#creating-your-own-plugin)

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md)

### Ways to Contribute

- 🐛 Report bugs
- 💡 Suggest features
- 🔌 Create plugins
- 📖 Improve documentation
- 🧪 Write tests

## Roadmap

- [x] Core plugin management
- [x] Docker support
- [x] Cross-platform builds
- [ ] Bash completion
- [ ] Plugin dependencies
- [ ] Self-update command
- [ ] Homebrew formula
- [ ] Plugin templates

## FAQ

<details>
<summary><strong>Do I need Go installed?</strong></summary>

No! You can build tooldock using Docker without installing Go. See [Docker Development Guide](docs/docker.md).

</details>

<details>
<summary><strong>How do I create a plugin?</strong></summary>

Any executable can be a plugin. Just create a script/binary and add it to the registry. See [Plugin Guide](docs/plugins.md#creating-your-own-plugin).

</details>

<details>
<summary><strong>Where are plugins stored?</strong></summary>

Plugins are installed in `~/.tooldock/plugins/`. The registry cache is in `~/.tooldock/cache/`.

</details>

<details>
<summary><strong>Can I use private plugins?</strong></summary>

Yes! Host your own `plugins.json` and update the registry URL in `pkg/config/config.go`.

</details>

<details>
<summary><strong>How do I uninstall tooldock?</strong></summary>

```bash
sudo rm /usr/local/bin/tooldock
rm -rf ~/.tooldock
```

</details>

## License

[MIT License](LICENSE) - feel free to use, modify, and distribute.

## Credits

Inspired by:
- [kubectl](https://kubernetes.io/docs/reference/kubectl/) + [krew](https://krew.sigs.k8s.io/)
- [asdf](https://asdf-vm.com/)
- [git](https://git-scm.com/)

---

<p align="center">
  Made with ❤️ for developers who love clean toolsets
</p>

<p align="center">
  <a href="docs/introduction.md">Introduction</a> •
  <a href="docs/plugins.md">Plugins</a> •
  <a href="docs/development.md">Development</a> •
  <a href="docs/docker.md">Docker</a> •
  <a href="docs/quickstart.md">Quick Start</a>
</p>
