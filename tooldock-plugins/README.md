# tooldock Plugins

This directory contains all plugins available for tooldock.

## Available Plugins

### tunnel
SSH tunnel manager - forward and manage SSH tunnels with auto-discovery.

**[Full Documentation →](tunnel/README.md)**

**Install:**
```bash
tooldock plugin install tunnel
```

**Usage:**
```bash
tooldock tunnel start -p 5432 -H user@server
tooldock tunnel list
tooldock tunnel stop 5432
```

### ssh
Interactive SSH host manager - quickly connect to saved hosts and run remote commands.

**[Full Documentation →](ssh/README.md)**

**Install:**
```bash
tooldock plugin install ssh
```

**Usage:**
```bash
tooldock ssh                             # Interactive selection
tooldock ssh wsl                         # Direct connection
tooldock ssh wsl --run "docker ps"       # Run commands remotely
tooldock ssh wsl --script ./deploy.sh    # Execute local script
```

### snippet
Command snippet manager - save and run frequently used commands with variable substitution.

**[Full Documentation →](snippet/README.md)**

**Install:**
```bash
tooldock plugin install snippet
```

**Usage:**
```bash
tooldock snippet save deploy "cd /app && git pull"
tooldock snippet save greet "echo 'Hello {{name}}!'"
tooldock snippet run deploy
tooldock snippet run greet name=John
tooldock snippet list
```

### drop
Encrypted file transfer - compress, encrypt, upload/download files via a self-hosted Drop server.

**[Full Documentation →](https://github.com/Saurav-Paul/drop)**

**Install:**
```bash
tooldock plugin install drop
```

**Usage:**
```bash
tooldock drop secret.pdf                          # Encrypt + upload
tooldock drop secret.pdf -e 3d -m 5               # With expiry and max downloads
tooldock drop secret.pdf --admin                   # Admin mode (bypass limits)
tooldock drop get https://drop.example.com/x/file  # Download + decrypt
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
├── tunnel/              # Plugin directory
│   ├── README.md        # Plugin documentation
│   └── tunnel.sh        # Plugin executable
├── ssh/
│   ├── README.md
│   └── ssh.sh
└── snippet/
    ├── README.md
    └── snippet.sh
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
sha256sum tooldock-plugins/myplugin/myplugin.sh

# Add to plugins.json
"checksum": "sha256:yourhashhere"
```
