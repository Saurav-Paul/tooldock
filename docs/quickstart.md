# Quick Start Guide

This guide will help you get tooldock up and running in minutes.

## Step 1: Build the Project

```bash
cd tooldock

# Download dependencies
go mod download

# Build the binary
make build

# Or build and install to /usr/local/bin
make install
```

## Step 2: Test Locally

```bash
# Check version
./build/tooldock version

# List available plugins (will show error initially - that's expected)
./build/tooldock plugin list
```

## Step 3: Set Up Plugin Registry

For testing, you can create a local plugins.json file or host it on GitHub.

### Option A: Local Testing

Create `test-plugins.json`:

```json
{
  "version": "1.0",
  "plugins": [
    {
      "name": "ports",
      "description": "SSH port forwarding manager",
      "version": "1.0.0",
      "url": "file:///path/to/your/ports.sh",
      "type": "script",
      "checksum": ""
    }
  ]
}
```

Then modify `pkg/config/config.go` to point to your local file during development.

### Option B: GitHub Setup

1. Create a new repo: `tooldock-plugins`
2. Create directory structure:
   ```
   tooldock-plugins/
   ├── plugins.json
   └── ports/
       └── ports.sh
   ```
3. Upload your `ports.sh` to `ports/` directory
4. Create `plugins.json`:
   ```json
   {
     "version": "1.0",
     "plugins": [
       {
         "name": "ports",
         "description": "SSH port forwarding manager",
         "version": "1.0.0",
         "url": "https://raw.githubusercontent.com/Saurav-Paul/tooldock-plugins/main/ports/ports.sh",
         "type": "script",
         "checksum": ""
       }
     ]
   }
   ```
5. Update `pkg/config/config.go` with your GitHub username

## Step 4: Install Your First Plugin

```bash
# List available plugins
./build/tooldock plugin list

# Install ports plugin
./build/tooldock plugin install ports

# Use the plugin
./build/tooldock ports --help
./build/tooldock ports start -p 5432 --host user@server
```

## Step 5: Customize

### Add Your GitHub Username

Replace `Saurav-Paul` in these files:
- `pkg/config/config.go` - PluginRegistryURL
- `go.mod` - module path
- `README.md` - all URLs
- `install.sh` - REPO variable

### Build for Release

```bash
# Build for all platforms
make build-all

# Binaries will be in build/ directory:
# - tooldock_darwin_amd64
# - tooldock_darwin_arm64
# - tooldock_linux_amd64
# - tooldock_linux_arm64
```

## Step 6: Create GitHub Release

1. Create a git tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. Create GitHub release with binaries:
   - Go to GitHub → Releases → New Release
   - Upload all platform binaries from `build/`
   - Publish release

3. Test installation:
   ```bash
   curl -sfL https://raw.githubusercontent.com/Saurav-Paul/tooldock/main/install.sh | sh
   ```

## Common Issues

### "Failed to fetch plugin registry"
- Check your internet connection
- Verify the registry URL is correct
- Make sure the GitHub repo is public

### "Plugin execution failed"
- Make sure the plugin file is executable
- Check the shebang line (#!/bin/bash)
- Verify the plugin downloaded correctly

### "Command not found: tooldock"
- Make sure `/usr/local/bin` is in your PATH
- Try running with full path: `/usr/local/bin/tooldock`

## Development Workflow

```bash
# Make changes to code
# ...

# Test locally
make dev plugin list

# Build and install
make install

# Test the installed version
tooldock plugin list
```

## Next Steps

- Add more plugins to your registry
- Set up GitHub Actions for automated releases
- Create a Homebrew formula
- Add bash completion
- Share with friends!
