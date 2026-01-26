# snippet - Command Snippet Manager

Save and run frequently used commands with powerful variable substitution.

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Features](#features)
- [Usage](#usage)
  - [Save Snippets](#save-snippets)
  - [Run Snippets](#run-snippets)
  - [List Snippets](#list-snippets)
  - [Show Snippet Details](#show-snippet-details)
  - [Remove Snippets](#remove-snippets)
- [Variable Substitution](#variable-substitution)
- [Use Cases](#use-cases)
- [Storage](#storage)

## Installation

```bash
tooldock plugin install snippet
```

## Quick Start

```bash
# Save a simple snippet
tooldock snippet save deploy "cd /app && git pull && npm run build"

# Run it
tooldock snippet run deploy

# Save snippet with variables
tooldock snippet save greet "echo 'Hello {{name}}!'"

# Run with variable
tooldock snippet run greet name=John
```

## Features

- ✅ Save frequently used commands
- ✅ Named variable substitution with `{{varname}}`
- ✅ Default values for optional variables `{{varname:default}}`
- ✅ List all saved snippets
- ✅ Show snippet details including variables
- ✅ Update existing snippets
- ✅ Remove snippets
- ✅ Beautiful colored terminal UI
- ✅ JSON storage for easy backup and portability

## Usage

### Save Snippets

Save a new snippet or update an existing one:

```bash
tooldock snippet save <name> "<command>" [--desc "description"]
```

**Examples:**

```bash
# Simple command
tooldock snippet save hello "echo 'Hello World'"

# Multi-line command
tooldock snippet save deploy "
  cd /var/www/app
  git pull origin main
  npm install
  npm run build
  pm2 restart app
"

# With description
tooldock snippet save docker-clean "docker system prune -af --volumes" --desc "Clean all Docker resources"

# With variables
tooldock snippet save greet "echo 'Hello {{name}}, welcome to {{place}}!'"

# With default values
tooldock snippet save greet "echo 'Hello {{name:World}}!'"
```

### Run Snippets

Execute a saved snippet:

```bash
tooldock snippet run <name> [key=value...]
```

**Examples:**

```bash
# Run simple snippet
tooldock snippet run deploy

# Run with variables
tooldock snippet run greet name=John place=London

# Use default values
tooldock snippet run greet              # Uses default "World"
tooldock snippet run greet name=Alice   # Uses "Alice"
```

### List Snippets

Display all saved snippets:

```bash
tooldock snippet list
# or
tooldock snippet ls
# or
tooldock snippet
```

**Output:**
```
╔════════════════════════════════════════════════════════════════╗
║                  Saved Snippets (3)                            ║
╚════════════════════════════════════════════════════════════════╝

  deploy
    Command: cd /app && git pull && npm run build
    Description: Deploy application

  greet
    Command: echo 'Hello {{name:World}}!'

  docker-clean
    Command: docker system prune -af --volumes
    Description: Clean all Docker resources
```

### Show Snippet Details

Display detailed information about a specific snippet:

```bash
tooldock snippet show <name>
```

**Example:**

```bash
tooldock snippet show greet
```

**Output:**
```
╔════════════════════════════════════════════════════════════════╗
║  Snippet: greet                                                ║
╚════════════════════════════════════════════════════════════════╝

Command:
  echo 'Hello {{name:World}}, you are {{age}} years old'

Variables:
  age (required)
  name (default: World)

Created: 2026-01-25T21:00:00Z
```

### Remove Snippets

Delete a saved snippet:

```bash
tooldock snippet remove <name>
# or
tooldock snippet rm <name>
```

**Example:**

```bash
tooldock snippet remove deploy
```

## Variable Substitution

Variables allow you to create reusable command templates.

### Required Variables

Use `{{varname}}` for required variables:

```bash
tooldock snippet save connect "ssh {{user}}@{{host}}"
tooldock snippet run connect user=admin host=server.com
# Executes: ssh admin@server.com
```

If you don't provide a required variable, you'll get an error:

```bash
tooldock snippet run connect user=admin
# ❌ Missing required variable: host
```

### Optional Variables with Defaults

Use `{{varname:default}}` for optional variables:

```bash
tooldock snippet save greet "echo 'Hello {{name:World}}!'"

# Use default
tooldock snippet run greet
# Executes: echo 'Hello World!'

# Override default
tooldock snippet run greet name=John
# Executes: echo 'Hello John!'
```

### Multiple Variables

Combine multiple variables in one snippet:

```bash
tooldock snippet save deploy "cd {{dir:/app}} && git checkout {{branch:main}} && git pull"

# All defaults
tooldock snippet run deploy
# Executes: cd /app && git checkout main && git pull

# Override some
tooldock snippet run deploy branch=develop
# Executes: cd /app && git checkout develop && git pull

# Override all
tooldock snippet run deploy dir=/var/www branch=feature
# Executes: cd /var/www && git checkout feature && git pull
```

## Use Cases

### 1. Deployment Commands

```bash
# Save deployment snippet
tooldock snippet save deploy "
  cd {{app_dir:/var/www/app}}
  git pull origin {{branch:main}}
  npm install
  npm run build
  pm2 restart {{app_name:app}}
" --desc "Deploy application"

# Deploy with defaults
tooldock snippet run deploy

# Deploy different branch
tooldock snippet run deploy branch=develop

# Deploy different app
tooldock snippet run deploy app_dir=/var/www/api app_name=api
```

### 2. Docker Operations

```bash
# Docker cleanup
tooldock snippet save docker-clean "docker system prune -af --volumes" --desc "Clean Docker"

# Container logs
tooldock snippet save docker-logs "docker logs -f {{container}}" --desc "Tail container logs"
tooldock snippet run docker-logs container=api

# Container exec
tooldock snippet save docker-exec "docker exec -it {{container:app}} {{cmd:bash}}"
tooldock snippet run docker-exec
tooldock snippet run docker-exec container=db cmd="psql -U postgres"
```

### 3. Git Workflows

```bash
# Feature branch creation
tooldock snippet save git-feature "git checkout -b feature/{{name}} && git push -u origin feature/{{name}}"
tooldock snippet run git-feature name=user-auth

# Squash and merge
tooldock snippet save git-squash "git reset --soft HEAD~{{count:5}} && git commit"
tooldock snippet run git-squash count=3

# Tag release
tooldock snippet save git-tag "git tag -a v{{version}} -m 'Release {{version}}' && git push origin v{{version}}"
tooldock snippet run git-tag version=1.2.0
```

### 4. Database Operations

```bash
# Database backup
tooldock snippet save db-backup "pg_dump -U {{user:postgres}} {{db}} > backup_$(date +%Y%m%d).sql"
tooldock snippet run db-backup db=myapp

# Database restore
tooldock snippet save db-restore "psql -U {{user:postgres}} {{db}} < {{file}}"
tooldock snippet run db-restore db=myapp file=backup.sql
```

### 5. File Operations

```bash
# Create project structure
tooldock snippet save mkproject "mkdir -p {{name}}/{src,tests,docs} && cd {{name}} && git init"
tooldock snippet run mkproject name=my-app

# Backup directory
tooldock snippet save backup "tar -czf {{name}}_$(date +%Y%m%d).tar.gz {{dir}}"
tooldock snippet run backup name=project dir=/path/to/project
```

### 6. Development Workflows

```bash
# Start dev server
tooldock snippet save dev "cd {{dir:~/project}} && npm run dev -- --port {{port:3000}}"
tooldock snippet run dev
tooldock snippet run dev port=8080

# Run tests
tooldock snippet save test "cd {{dir:~/project}} && npm test -- {{pattern:}}"
tooldock snippet run test pattern=api

# Build and serve
tooldock snippet save serve "cd {{dir:~/project}} && npm run build && npx serve dist -p {{port:5000}}"
tooldock snippet run serve port=8080
```

## Storage

Snippets are stored in JSON format at:

```
~/.tooldock/snippets.json
```

**Format:**

```json
{
  "version": "1.0",
  "snippets": {
    "deploy": {
      "command": "cd /app && git pull && npm run build",
      "description": "Deploy application to production",
      "created": "2026-01-25T21:00:00Z",
      "updated": "2026-01-25T21:00:00Z"
    },
    "greet": {
      "command": "echo 'Hello {{name:World}}!'",
      "description": "",
      "created": "2026-01-25T21:05:00Z",
      "updated": "2026-01-25T21:05:00Z"
    }
  }
}
```

### Backup

To backup your snippets:

```bash
cp ~/.tooldock/snippets.json ~/snippets-backup.json
```

### Share Snippets

Share your snippets file with teammates or across machines:

```bash
# Export from one machine
scp ~/.tooldock/snippets.json user@other-machine:~/

# Import on another machine
mkdir -p ~/.tooldock
cp ~/snippets.json ~/.tooldock/
```

## Tips & Best Practices

1. **Use descriptive names**: `deploy-prod` instead of `dp`
2. **Add descriptions**: Helps remember what the snippet does
3. **Use defaults wisely**: Set sensible defaults for commonly used values
4. **Quote properly**: Use single quotes in commands to avoid shell expansion
5. **Test first**: Run the command manually before saving as a snippet
6. **Version control**: Keep your `snippets.json` in a git repo for backup

## Version History

### 1.0.0 (2026-01-25)
- Initial release
- Save, run, list, show, remove commands
- Named variable substitution with defaults
- JSON storage format
- Beautiful terminal UI

## Contributing

Found a bug or want to add a feature? Contributions welcome!

1. Fork the repository
2. Edit `tooldock-plugins/snippet/snippet.sh`
3. Test your changes
4. Submit a pull request
