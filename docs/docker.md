# Docker Development Guide

This guide explains how to develop and build tooldock using Docker, without installing Go locally.

## Prerequisites

- Docker
- Docker Compose

## Quick Start

### 1. Initialize the Project

```bash
# Initialize Go modules and download dependencies
./docker.sh init
```

### 2. Build the Binary

```bash
# Build for your current platform
./docker.sh build

# The binary will be in: build/tooldock
```

### 3. Run tooldock

```bash
# Run directly
./docker.sh run version

# List plugins
./docker.sh run plugin list

# Install a plugin
./docker.sh run plugin install ports
```

### 4. Build for All Platforms

```bash
# Build for macOS (amd64, arm64) and Linux (amd64, arm64)
./docker.sh build-all

# Binaries will be in build/:
# - tooldock_darwin_amd64
# - tooldock_darwin_arm64
# - tooldock_linux_amd64
# - tooldock_linux_arm64
```

## Docker Helper Script

The `docker.sh` script provides convenient commands:

```bash
./docker.sh <command> [args...]
```

### Available Commands

| Command | Description |
|---------|-------------|
| `init` | Initialize Go modules |
| `build` | Build the tooldock binary |
| `build-all` | Build for all platforms |
| `test` | Run tests |
| `shell` | Open interactive bash shell |
| `run [args]` | Run tooldock with arguments |
| `clean` | Clean build artifacts and Docker volumes |
| `fmt` | Format Go code |
| `tidy` | Tidy Go modules |

### Examples

```bash
# Initialize project
./docker.sh init

# Build
./docker.sh build

# Run with arguments
./docker.sh run plugin list
./docker.sh run version

# Open interactive shell for development
./docker.sh shell

# Inside the shell:
go test ./...
go build -o build/tooldock .
exit

# Format code
./docker.sh fmt

# Clean everything
./docker.sh clean
```

## Using Makefile with Docker

Alternatively, use `make` with Docker targets:

```bash
# Initialize
make docker-init

# Build
make docker-build

# Build all platforms
make docker-build-all

# Run (pass args with ARGS variable)
make docker-run ARGS="plugin list"
make docker-run ARGS="version"

# Open shell
make docker-shell

# Clean
make docker-clean
```

## Docker Compose Services

The `docker-compose.yml` defines three services:

### 1. `dev` - Development Environment

Interactive development container with Go tools:

```bash
# Start interactive shell
docker compose run --rm dev bash

# Run Go commands
docker compose run --rm dev go test ./...
docker compose run --rm dev go build .
```

### 2. `build` - Build Service

Builds the binary:

```bash
docker compose run --rm build
```

### 3. `run` - Runtime Service

Runs the built binary:

```bash
docker compose run --rm run version
docker compose run --rm run plugin list
```

## Development Workflow

### Standard Workflow

```bash
# 1. Initialize (first time only)
./docker.sh init

# 2. Make code changes
vim cmd/plugin.go

# 3. Build
./docker.sh build

# 4. Test
./docker.sh run plugin list

# 5. Format and tidy
./docker.sh fmt
./docker.sh tidy
```

### Interactive Development

```bash
# Open shell
./docker.sh shell

# Now you're inside the container with Go installed
go run . version
go test ./...
go build -o build/tooldock .

# Exit when done
exit
```

## File Structure

```
tooldock/
├── Dockerfile              # Multi-stage Docker build
├── docker-compose.yml      # Docker Compose services
├── docker.sh              # Helper script
└── build/                 # Build output (created by Docker)
    ├── tooldock          # Binary for your platform
    ├── tooldock_darwin_amd64
    ├── tooldock_darwin_arm64
    ├── tooldock_linux_amd64
    └── tooldock_linux_arm64
```

## Volumes

Docker Compose uses volumes to persist data:

- **Source code**: Mounted as volume so changes are immediately visible
- **Go modules**: Cached in named volume for faster builds
- **Build output**: Written to `build/` directory on host

## Troubleshooting

### "Permission denied" errors

If you get permission errors with the built binary:

```bash
chmod +x build/tooldock
```

### Clean start

If something goes wrong, clean everything:

```bash
./docker.sh clean
./docker.sh init
./docker.sh build
```

### Check Docker status

```bash
# List running containers
docker compose ps

# View logs
docker compose logs

# Stop all services
docker compose down
```

## CI/CD Integration

You can use the Docker setup in CI/CD pipelines:

```yaml
# Example GitHub Actions
- name: Build with Docker
  run: |
    ./docker.sh init
    ./docker.sh build-all
```

## Advantages of Docker Development

✅ **No local Go installation needed**
✅ **Consistent build environment**
✅ **Easy multi-platform builds**
✅ **Isolated from host system**
✅ **Works on any OS with Docker**
✅ **CI/CD ready**

## Next Steps

1. Initialize: `./docker.sh init`
2. Build: `./docker.sh build`
3. Run: `./docker.sh run version`
4. Develop: `./docker.sh shell`

Happy coding! 🐳
