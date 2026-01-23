# Deployment Checklist

This guide will help you deploy tooldock to GitHub and make it fully functional.

## Prerequisites

- GitHub account
- Git installed locally
- Docker installed (for building releases)

## Step 1: Create GitHub Repositories

You need to create two repositories:

### 1. Main Repository: `tooldock`

```bash
# On GitHub, create a new repository called "tooldock"
# Then push your local code:

cd /Users/saurav_paul/Developments/hobby-project/tools
git remote add origin https://github.com/Saurav-Paul/tooldock.git
git branch -M main
git add .
git commit -m "Initial commit: tooldock plugin manager"
git push -u origin main
```

### 2. Plugin Repository: `tooldock-plugins`

```bash
# On GitHub, create a new repository called "tooldock-plugins"
# Then create the plugin repo locally:

mkdir -p ~/tooldock-plugins/ports
cd ~/tooldock-plugins

# Copy your ports.sh plugin
cp /Users/saurav_paul/Developments/hobby-project/tools/ports.sh ports/

# Create plugins.json
cat > plugins.json << 'EOF'
{
  "version": "1.0",
  "plugins": [
    {
      "name": "ports",
      "description": "SSH port forwarding manager - forward and manage SSH tunnels easily",
      "version": "1.0.0",
      "url": "https://raw.githubusercontent.com/Saurav-Paul/tooldock-plugins/main/ports/ports.sh",
      "type": "script",
      "checksum": ""
    }
  ]
}
EOF

# Initialize git and push
git init
git add .
git commit -m "Add ports plugin"
git remote add origin https://github.com/Saurav-Paul/tooldock-plugins.git
git branch -M main
git push -u origin main
```

## Step 2: Update Registry URL

Update the default registry URL in your tooldock code:

```bash
# Edit tooldock/pkg/config/config.go
# Change line 9 from:
#   defaultRegistryURL = "https://raw.githubusercontent.com/Saurav-Paul/tooldock-plugins/main/plugins.json"
# To:
#   defaultRegistryURL = "https://raw.githubusercontent.com/Saurav-Paul/tooldock-plugins/main/plugins.json"
```

Replace `Saurav-Paul` with your actual GitHub username.

## Step 3: Build Release Binaries

Build tooldock for all platforms:

```bash
cd /Users/saurav_paul/Developments/hobby-project/tools

# Build all platforms
./docker.sh build-all

# This creates:
# - build/tooldock_darwin_amd64 (macOS Intel)
# - build/tooldock_darwin_arm64 (macOS Apple Silicon)
# - build/tooldock_linux_amd64 (Linux)
# - build/tooldock_linux_arm64 (Linux ARM)
```

## Step 4: Create GitHub Release

1. Go to your tooldock repository on GitHub
2. Click "Releases" → "Create a new release"
3. Tag: `v1.0.0`
4. Title: `tooldock v1.0.0`
5. Description:
   ```markdown
   ## tooldock v1.0.0

   First release of tooldock - a lightweight plugin manager for CLI tools.

   ### Features
   - Plugin management (install, update, remove)
   - Cross-platform support (macOS, Linux)
   - Docker-based development
   - First plugin: SSH port forwarding manager

   ### Installation

   Download the appropriate binary for your platform and install:

   ```bash
   # macOS Apple Silicon
   curl -L https://github.com/Saurav-Paul/tooldock/releases/download/v1.0.0/tooldock_darwin_arm64 -o tooldock
   chmod +x tooldock
   sudo mv tooldock /usr/local/bin/tooldock

   # macOS Intel
   curl -L https://github.com/Saurav-Paul/tooldock/releases/download/v1.0.0/tooldock_darwin_amd64 -o tooldock
   chmod +x tooldock
   sudo mv tooldock /usr/local/bin/tooldock

   # Linux
   curl -L https://github.com/Saurav-Paul/tooldock/releases/download/v1.0.0/tooldock_linux_amd64 -o tooldock
   chmod +x tooldock
   sudo mv tooldock /usr/local/bin/tooldock
   ```
   ```

6. Attach the binaries from `build/` directory
7. Click "Publish release"

## Step 5: Test the Installation

On a fresh machine (or after removing local builds):

```bash
# Download and install
curl -L https://github.com/Saurav-Paul/tooldock/releases/download/v1.0.0/tooldock_darwin_arm64 -o tooldock
chmod +x tooldock
sudo mv tooldock /usr/local/bin/tooldock

# Test it
tooldock --version
tooldock plugin list

# Install and use ports plugin
tooldock plugin install ports
tooldock ports --help
```

## Step 6: Update Documentation

Replace all instances of `Saurav-Paul` in documentation:

```bash
cd /Users/saurav_paul/Developments/hobby-project/tools

# Find all files with Saurav-Paul placeholder
grep -r "Saurav-Paul" .

# Update these files:
# - README.md
# - GETTING_STARTED.md
# - docs/introduction.md
# - docs/development.md
# - tooldock/go.mod
```

## Verification Checklist

Before announcing your project:

- [ ] Both repositories created and pushed
- [ ] Registry URL updated in code
- [ ] Release created with all platform binaries
- [ ] Installation tested on at least one platform
- [ ] `tooldock plugin list` shows ports plugin
- [ ] `tooldock plugin install ports` works
- [ ] `tooldock ports --help` displays help
- [ ] All documentation updated (no Saurav-Paul placeholders)
- [ ] README.md looks good on GitHub

## Optional Enhancements

### Add Install Script

Create `install.sh` in your tooldock repo:

```bash
#!/bin/sh
set -e

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case $ARCH in
    x86_64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
esac

BINARY="tooldock_${OS}_${ARCH}"
URL="https://github.com/Saurav-Paul/tooldock/releases/latest/download/${BINARY}"

echo "Installing tooldock..."
echo "Platform: ${OS}/${ARCH}"

# Download
curl -L "$URL" -o tooldock
chmod +x tooldock

# Install
sudo mv tooldock /usr/local/bin/tooldock

echo "✅ tooldock installed successfully!"
tooldock --version
```

Then users can install with:
```bash
curl -sfL https://raw.githubusercontent.com/Saurav-Paul/tooldock/main/install.sh | sh
```

### Add GitHub Actions

Create `.github/workflows/release.yml` to automate builds:

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: actions/setup-go@v4
        with:
          go-version: '1.21'

      - name: Build binaries
        run: |
          cd tooldock
          GOOS=darwin GOARCH=amd64 go build -ldflags="-w -s" -o ../build/tooldock_darwin_amd64 .
          GOOS=darwin GOARCH=arm64 go build -ldflags="-w -s" -o ../build/tooldock_darwin_arm64 .
          GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o ../build/tooldock_linux_amd64 .
          GOOS=linux GOARCH=arm64 go build -ldflags="-w -s" -o ../build/tooldock_linux_arm64 .

      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          files: build/*
```

## Troubleshooting

**Plugin list shows 404 error**
- Check that tooldock-plugins repository is public
- Verify the registry URL in `pkg/config/config.go`
- Make sure `plugins.json` is in the root of tooldock-plugins repo

**Binary won't run on macOS**
- You may need to allow it: `System Preferences → Security & Privacy`
- Or remove quarantine: `xattr -d com.apple.quarantine /usr/local/bin/tooldock`

**Cannot install to /usr/local/bin**
- Use sudo: `sudo cp build/tooldock /usr/local/bin/`
- Or install to user directory: `cp build/tooldock ~/.local/bin/`

## Next Steps

After deployment:

1. Share your project on social media
2. Add more plugins to tooldock-plugins
3. Create a Homebrew formula for easier macOS installation
4. Add bash/zsh completions
5. Create a website/landing page

---

**Remember**: Replace all instances of `Saurav-Paul` with your actual GitHub username before deploying!
