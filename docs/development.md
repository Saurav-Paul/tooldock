# Development Guide

This guide covers everything you need to know about developing tooldock.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Building](#building)
- [Testing](#testing)
- [Contributing](#contributing)

## Prerequisites

Choose one of the following development environments:

### Option 1: Docker (Recommended)

**No Go installation needed!**

- Docker
- Docker Compose

See [Docker Development Guide](./docker.md) for detailed instructions.

### Option 2: Local Go Environment

- Go 1.21 or higher
- Make (optional, for using Makefile)

## Getting Started

### Clone the Repository

```bash
git clone https://github.com/yourname/tooldock.git
cd tooldock
```

### Using Docker (Recommended)

```bash
# Initialize project
./docker.sh init

# Build
./docker.sh build

# Run
./docker.sh run version
./docker.sh run plugin list
```

See [Docker Development Guide](./docker.md) for all Docker commands.

### Using Local Go

```bash
# Download dependencies
go mod download

# Build
go build -o tooldock .

# Run
./tooldock version
```

## Project Structure

```
tooldock/
├── main.go                      # Application entry point
├── go.mod                       # Go module definition
├── go.sum                       # Dependency checksums
│
├── cmd/                         # Command implementations
│   ├── root.go                 # Root command & plugin delegation
│   └── plugin.go               # Plugin management commands
│
├── pkg/                         # Shared packages
│   ├── config/                 # Configuration & paths
│   │   └── config.go
│   ├── executor/               # Plugin execution logic
│   │   └── executor.go
│   └── registry/               # Plugin registry management
│       └── registry.go
│
├── docs/                        # Documentation
│   ├── introduction.md
│   ├── plugins.md
│   ├── development.md
│   ├── docker.md
│   └── quickstart.md
│
├── build/                       # Build output (gitignored)
│   └── tooldock*               # Compiled binaries
│
├── Dockerfile                   # Docker build configuration
├── docker-compose.yml          # Docker services
├── docker.sh                   # Docker helper script
├── Makefile                    # Build automation
├── install.sh                  # One-line installer
└── README.md                   # Main documentation
```

### Key Directories

#### `cmd/`
Contains all CLI commands:
- `root.go` - Main command, handles plugin delegation
- `plugin.go` - Plugin management (list/install/update/remove)

#### `pkg/config/`
Configuration and path management:
- Plugin directory: `~/.tooldock/plugins/`
- Cache directory: `~/.tooldock/cache/`
- Registry URL configuration

#### `pkg/executor/`
Handles plugin execution:
- Checks if plugin is installed
- Executes plugin with arguments
- Handles stdin/stdout/stderr

#### `pkg/registry/`
Manages plugin registry:
- Fetches from GitHub
- Caches locally (24-hour TTL)
- Handles plugin downloads
- Checksum verification

## Building

### Build for Current Platform

**With Docker:**
```bash
./docker.sh build
# Output: build/tooldock
```

**With Go:**
```bash
make build
# or
go build -o build/tooldock .
```

### Build for All Platforms

**With Docker:**
```bash
./docker.sh build-all
```

**With Go:**
```bash
make build-all
```

This creates:
- `build/tooldock_darwin_amd64` - macOS Intel
- `build/tooldock_darwin_arm64` - macOS Apple Silicon
- `build/tooldock_linux_amd64` - Linux x86-64
- `build/tooldock_linux_arm64` - Linux ARM64

### Install Locally

**With Docker:**
```bash
# Build first
./docker.sh build

# Then install manually
sudo cp build/tooldock /usr/local/bin/tooldock
```

**With Go:**
```bash
make install
```

## Testing

### Run Tests

**With Docker:**
```bash
./docker.sh test
```

**With Go:**
```bash
make test
# or
go test -v ./...
```

### Manual Testing

```bash
# Build
./docker.sh build  # or: make build

# Test commands
./build/tooldock version
./build/tooldock plugin list
./build/tooldock --help
```

### Test Plugin Installation

```bash
# Build and install
sudo cp build/tooldock /usr/local/bin/tooldock

# Install a plugin
tooldock plugin install ports

# Test the plugin
tooldock ports --help
```

## Development Workflow

### Standard Workflow

```bash
# 1. Make changes
vim cmd/plugin.go

# 2. Format code (with Docker)
./docker.sh fmt

# 3. Build
./docker.sh build

# 4. Test
./docker.sh run plugin list

# 5. Run tests
./docker.sh test
```

### Interactive Development (Docker)

```bash
# Open shell with Go tools
./docker.sh shell

# Inside the container:
go run . version
go test ./...
go build -o build/tooldock .

# Exit when done
exit
```

### Using Makefile

```bash
# Show all available commands
make help

# Docker commands
make docker-init
make docker-build
make docker-run ARGS="plugin list"
make docker-shell

# Local Go commands (if Go installed)
make build
make test
make install
```

## Code Style

### Go Conventions

- Follow standard Go formatting: `gofmt`
- Use meaningful variable names
- Add comments for exported functions
- Keep functions small and focused
- Handle errors explicitly

### Format Code

```bash
# With Docker
./docker.sh fmt

# With Go
make fmt
# or
go fmt ./...
```

## Adding New Features

### Adding a New Command

1. Create command file in `cmd/`:
```go
// cmd/mycommand.go
package cmd

import "github.com/spf13/cobra"

var myCommand = &cobra.Command{
    Use:   "mycommand",
    Short: "Description",
    RunE: func(cmd *cobra.Command, args []string) error {
        // Implementation
        return nil
    },
}

func init() {
    rootCmd.AddCommand(myCommand)
}
```

2. Build and test:
```bash
./docker.sh build
./build/tooldock mycommand
```

### Adding Package Functionality

1. Create new package in `pkg/`:
```bash
mkdir -p pkg/mypackage
```

2. Implement functionality:
```go
// pkg/mypackage/mypackage.go
package mypackage

func DoSomething() error {
    // Implementation
    return nil
}
```

3. Use in commands:
```go
import "github.com/yourname/tooldock/pkg/mypackage"

// In your command:
mypackage.DoSomething()
```

## Configuration

### Updating Plugin Registry URL

Edit `pkg/config/config.go`:

```go
const (
    PluginRegistryURL = "https://raw.githubusercontent.com/YOUR_USERNAME/tooldock-plugins/main/plugins.json"
    // ...
)
```

### Updating Module Path

After forking, update `go.mod`:

```go
module github.com/YOUR_USERNAME/tooldock
```

Then update all imports in `.go` files.

## Debugging

### Enable Verbose Logging

Add debug prints:
```go
import "log"

log.Printf("Debug: %+v\n", someVariable)
```

### Check Plugin Paths

```bash
# Plugin directory
ls -la ~/.tooldock/plugins/

# Cache directory
ls -la ~/.tooldock/cache/
```

### Test Registry Fetch

```bash
# Manually test registry URL
curl -s https://raw.githubusercontent.com/yourname/tooldock-plugins/main/plugins.json
```

## Troubleshooting

### "Command not found" after install

Check if `/usr/local/bin` is in PATH:
```bash
echo $PATH
export PATH="/usr/local/bin:$PATH"
```

### Docker build fails

Clean and rebuild:
```bash
./docker.sh clean
docker compose build --no-cache
./docker.sh init
./docker.sh build
```

### Go module issues

```bash
# With Docker
./docker.sh tidy

# With Go
go mod tidy
go mod download
```

## Contributing

### Before Submitting PR

1. Format code: `./docker.sh fmt`
2. Run tests: `./docker.sh test`
3. Update documentation if needed
4. Test the build: `./docker.sh build-all`

### Pull Request Checklist

- [ ] Code is formatted (`go fmt`)
- [ ] Tests pass
- [ ] Documentation updated
- [ ] Commit messages are clear
- [ ] No unnecessary files committed

See [CONTRIBUTING.md](../CONTRIBUTING.md) for detailed guidelines.

## Release Process

### Creating a Release

1. Update version in `pkg/config/config.go`
2. Commit changes
3. Create git tag:
```bash
git tag v1.0.0
git push origin v1.0.0
```

4. Build all platforms:
```bash
./docker.sh build-all
```

5. Create GitHub Release with binaries

### Testing Release

```bash
# Test installation script
curl -sfL https://raw.githubusercontent.com/yourname/tooldock/main/install.sh | sh
```

## Resources

- [Go Documentation](https://golang.org/doc/)
- [Cobra (CLI framework)](https://github.com/spf13/cobra)
- [Docker Documentation](https://docs.docker.com/)

## Getting Help

- Open an issue on GitHub
- Check existing issues
- Read the [FAQ](./faq.md)
- Join discussions

## Next Steps

- [Learn Docker Development](./docker.md)
- [Read Quick Start Guide](./quickstart.md)
- [Browse Available Plugins](./plugins.md)
