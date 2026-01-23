# Getting Started with tooldock

A beginner-friendly guide to running and testing tooldock.

## Prerequisites

You need Docker installed. That's it!

- [Install Docker Desktop](https://www.docker.com/products/docker-desktop)

## Step 1: Initialize the Project

This downloads Go dependencies inside Docker:

```bash
./docker.sh init
```

**What this does:**
- Starts a Docker container with Go installed
- Downloads all Go dependencies (libraries)
- Sets up the project for building

**Expected output:**
```
🔵 Initializing Go modules...
[downloading packages...]
✅ Initialization complete
```

## Step 2: Build the Binary

```bash
./docker.sh build
```

**What this does:**
- Compiles the Go code into an executable binary
- Creates `build/tooldock` file

**Expected output:**
```
🔵 Building tooldock...
✅ Build complete: build/tooldock
```

## Step 3: Test Basic Commands

Now you have a working `tooldock` binary! Let's test it:

```bash
# Check version
./docker.sh run version

# Show help
./docker.sh run help

# Try plugin list (will fail initially - that's expected!)
./docker.sh run plugin list
```

**Why does plugin list fail?**
Because it tries to fetch from GitHub, but the URL points to `yourname/tooldock-plugins` which doesn't exist yet. That's normal!

## Understanding What We Built

### The Code Structure

```
tooldock/
├── main.go              # Program entry point
├── cmd/
│   ├── root.go         # Main command logic
│   └── plugin.go       # Plugin commands (list, install, etc.)
└── pkg/
    ├── config/         # Configuration (paths, URLs)
    ├── executor/       # Runs plugins
    └── registry/       # Fetches plugin list from GitHub
```

### How It Works

1. **You run:** `tooldock plugin install ports`
2. **tooldock does:**
   - Fetches `plugins.json` from GitHub
   - Finds the "ports" entry
   - Downloads the plugin file
   - Saves to `~/.tooldock/plugins/ports`
   - Makes it executable

3. **You run:** `tooldock ports start -p 5432 --host wsl`
4. **tooldock does:**
   - Checks if `ports` plugin exists
   - Executes `~/.tooldock/plugins/ports start -p 5432 --host wsl`

## Testing the Binary

You can test the core functionality before setting up GitHub:

```bash
# Build for your platform (macOS ARM64 example)
docker compose run --rm -e GOOS=darwin -e GOARCH=arm64 dev go build -ldflags="-w -s" -o ../build/tooldock .

# Test basic commands
./build/tooldock --version
# Expected: tooldock version 1.0.0

./build/tooldock help
# Expected: Shows help message

# Plugin commands will fail until GitHub repos are set up
./build/tooldock plugin list
# Expected: Error fetching registry (no GitHub repo yet)
```

**This is normal!** You haven't set up the GitHub repository yet.

## Making It Fully Functional

To make plugin management work, you need to:

### Set Up Your GitHub Repositories

1. **Create `tooldock` repository**
   ```bash
   # On GitHub, create: yourname/tooldock
   git remote add origin https://github.com/yourname/tooldock.git
   git push -u origin main
   ```

2. **Create `tooldock-plugins` repository**
   ```bash
   # On GitHub, create: yourname/tooldock-plugins
   # Add this structure:
   tooldock-plugins/
   ├── plugins.json
   └── ports/
       └── ports.sh
   ```

3. **Create `plugins.json`**
   ```json
   {
     "version": "1.0",
     "plugins": [
       {
         "name": "ports",
         "description": "SSH port forwarding manager",
         "version": "1.0.0",
         "url": "https://raw.githubusercontent.com/yourname/tooldock-plugins/main/ports/ports.sh",
         "type": "script",
         "checksum": ""
       }
     ]
   }
   ```

4. **Update the registry URL**
   Edit `tooldock/pkg/config/config.go`:
   ```go
   const (
       PluginRegistryURL = "https://raw.githubusercontent.com/YOURNAME/tooldock-plugins/main/plugins.json"
   )
   ```

5. **Rebuild and test**
   ```bash
   # Build for macOS
   docker compose run --rm -e GOOS=darwin -e GOARCH=arm64 dev go build -ldflags="-w -s" -o ../build/tooldock .

   # Test it
   export TOOLDOCK_REGISTRY_URL=https://raw.githubusercontent.com/YOURNAME/tooldock-plugins/main/plugins.json
   ./build/tooldock plugin list
   ./build/tooldock plugin install ports
   ./build/tooldock ports --help
   ```

## Common Commands Reference

```bash
# Development
./docker.sh init              # Initialize (first time only)
./docker.sh build             # Build the binary
./docker.sh shell             # Open interactive shell

# Running tooldock
./docker.sh run <command>     # Run any tooldock command
./docker.sh run version       # Show version
./docker.sh run help          # Show help
./docker.sh run plugin list   # List plugins

# Building for all platforms
./docker.sh build-all         # Creates binaries for macOS/Linux/ARM

# Cleanup
./docker.sh clean             # Remove build artifacts
```

## Understanding Go Basics (For This Project)

### What is Go?
- A programming language by Google
- Creates fast, standalone executables
- Good for CLI tools

### Key Files

**main.go** - Entry point
```go
package main

func main() {
    // Program starts here
    cmd.Execute()  // Run the CLI
}
```

**go.mod** - Dependencies list
```
module github.com/yourname/tooldock

require github.com/spf13/cobra v1.8.0  // CLI framework
```

**cmd/root.go** - Main CLI logic
- Defines commands
- Handles plugin delegation

**cmd/plugin.go** - Plugin management
- `plugin list`, `plugin install`, etc.

### How Docker Helps

Without Docker, you'd need to:
1. Install Go
2. Set up Go environment
3. Install dependencies
4. Build manually

With Docker:
1. `./docker.sh init` - Everything set up automatically!
2. `./docker.sh build` - Just works!

## Troubleshooting

### "Connection refused" or "Failed to fetch registry"
**Cause:** GitHub repository doesn't exist yet
**Solution:** Either create the repos or test with local files

### "Permission denied"
**Cause:** Docker not running or needs permissions
**Solution:** Start Docker Desktop, or run with `sudo`

### "Command not found: docker"
**Cause:** Docker not installed
**Solution:** Install Docker Desktop

### Build fails
**Solution:** Clean and rebuild
```bash
./docker.sh clean
./docker.sh init
./docker.sh build
```

## What You've Built So Far

✅ **Core CLI** - Working command-line interface
✅ **Plugin Management** - Commands to install/remove plugins
✅ **Registry System** - Fetches plugin list from GitHub
✅ **Executor** - Runs installed plugins
✅ **Docker Support** - Build without installing Go
✅ **Cross-Platform** - Works on macOS/Linux/ARM

🔲 **Missing:** GitHub repositories (easy to add!)

## Next: Try It Out!

```bash
# 1. Initialize
./docker.sh init

# 2. Build
./docker.sh build

# 3. Test
./docker.sh run version
./docker.sh run help

# 4. See the binary
ls -lh build/
# You'll see: tooldock (the executable)
```

Want to install it on your system?

```bash
# Copy to your PATH
sudo cp build/tooldock /usr/local/bin/tooldock

# Now you can use it anywhere!
tooldock version
tooldock plugin list
```

## Ready to Continue?

Now that you understand the basics:
1. Try building: `./docker.sh init && ./docker.sh build`
2. Test it: `./docker.sh run version`
3. Ask me anything you're stuck on!
4. When ready, I can help you set up GitHub repos
