# tooldock Plugins

This directory contains all plugins available for tooldock.

## Available Plugins

### ports
SSH port forwarding manager - forward and manage SSH tunnels easily.

**Install:**
```bash
tooldock plugin install ports
```

**Usage:**
```bash
tooldock ports start -p 5432 -H user@server
tooldock ports list
tooldock ports stop 5432
```

### ssh
Interactive SSH host manager - quickly connect to saved hosts.

**Install:**
```bash
tooldock plugin install ssh
```

**Usage:**
```bash
tooldock ssh           # Interactive selection
tooldock ssh wsl       # Direct connection
```

## Adding a New Plugin

1. **Create plugin directory:**
   ```bash
   mkdir -p tooldock-plugins/myplugin
   ```

2. **Add your plugin script:**
   ```bash
   # Make sure it's executable
   chmod +x tooldock-plugins/myplugin/myplugin.sh
   ```

3. **Update plugins.json:**
   ```json
   {
     "name": "myplugin",
     "description": "Brief description of what it does",
     "version": "1.0.0",
     "url": "https://raw.githubusercontent.com/Saurav-Paul/tooldock/main/tooldock-plugins/myplugin/myplugin.sh",
     "type": "script",
     "checksum": ""
   }
   ```

4. **Commit and push:**
   ```bash
   git add tooldock-plugins/
   git commit -m "Add myplugin to tooldock"
   git push
   ```

5. **Test installation:**
   ```bash
   tooldock plugin list
   tooldock plugin install myplugin
   ```

## Plugin Structure

```
tooldock-plugins/
├── plugins.json          # Registry file
├── README.md            # This file
└── ports/               # Plugin directory
    └── ports.sh         # Plugin executable
```

## Plugin Requirements

- Must be executable (shell script, binary, or any executable)
- Must handle its own argument parsing
- Should provide help with `--help` flag
- Should be self-contained (include all dependencies or document them)

## Checksum Generation

To add security checksums to your plugins:

```bash
# Generate SHA256 checksum
sha256sum tooldock-plugins/ports/ports.sh

# Add to plugins.json
"checksum": "sha256:yourhashhere"
```
