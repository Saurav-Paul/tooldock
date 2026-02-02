#!/bin/bash
#
# SSH Tunnel Manager
# A simple, beautiful tool to manage SSH tunnels
#
# ╔════════════════════════════════════════════════════════════════════════╗
# ║                          INSTALLATION                                  ║
# ╚════════════════════════════════════════════════════════════════════════╝
#
# One-line install:
#   curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/tunnel.sh | sudo bash -s -- install
#
# Or manual install:
#   curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/tunnel.sh -o ports
#   chmod +x ports
#   sudo mv ports /usr/local/bin/ports
#
# ╔════════════════════════════════════════════════════════════════════════╗
# ║                             QUICK START                                ║
# ╚════════════════════════════════════════════════════════════════════════╝
#
# 1. Start a tunnel (forward same port):
#    tunnel start -p 5432 --host user@server.com
#    tunnel start -p 5432 --host paul@wsl
#
# 2. Start with different local/remote ports:
#    tunnel start -p 8080:3000 --host user@server.com
#    # Local 8080 → Remote 3000
#
# 3. View active tunnels:
#    ports
#    tunnel list
#
# 4. Stop a tunnel:
#    tunnel stop 5432
#
# 5. Restart a tunnel:
#    tunnel restart 5432
#
# ╔════════════════════════════════════════════════════════════════════════╗
# ║                            USAGE EXAMPLES                              ║
# ╚════════════════════════════════════════════════════════════════════════╝
#
# Forward PostgreSQL (same port on both sides):
#   tunnel start -p 5432 --host paul@wsl
#   # localhost:5432 → wsl:5432
#
# Forward with different ports:
#   tunnel start -p 8080:3000 --host user@server.com
#   # localhost:8080 → server:3000
#
# Forward to specific remote host:
#   tunnel start -p 5432 --host user@jumphost.com -remote db.internal:5432
#   # localhost:5432 → db.internal:5432 (via jumphost)
#
# Multiple tunnels:
#   tunnel start -p 5432 --host paul@wsl
#   tunnel start -p 3000 --host paul@wsl
#   tunnel start -p 8080:80 --host paul@wsl
#
# Quick view:
#   ports
#
# ╔════════════════════════════════════════════════════════════════════════╗
# ║                           CONFIGURATION                                ║
# ╚════════════════════════════════════════════════════════════════════════╝
#
# Environment Variables:
#   PORTS_DATA_DIR    - Directory for tunnel data (default: ~/.ssh)
#
# Configuration files:
#   ~/.ssh/active_tunnels.txt - Active tunnel registry
#
# ╔════════════════════════════════════════════════════════════════════════╗
# ║                            REQUIREMENTS                                ║
# ╚════════════════════════════════════════════════════════════════════════╝
#
# - bash 4.0+
# - ssh client
# - lsof (for port checking)
#
# ╔════════════════════════════════════════════════════════════════════════╗
# ║                              LICENSE                                   ║
# ╚════════════════════════════════════════════════════════════════════════╝
#
# MIT License - feel free to use, modify, and distribute
#
################################################################################

set -euo pipefail

# Configuration
TUNNEL_FILE="${PORTS_DATA_DIR:-$HOME/.ssh}/active_tunnels.txt"
VERSION="1.0.0"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Ensure data directory exists
mkdir -p "$(dirname "$TUNNEL_FILE")"
touch "$TUNNEL_FILE"

# ============================================================================
# Utility Functions
# ============================================================================

check_requirements() {
    local missing=()
    
    command -v ssh >/dev/null 2>&1 || missing+=("ssh")
    command -v lsof >/dev/null 2>&1 || missing+=("lsof")
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${RED}❌ Missing required commands: ${missing[*]}${NC}"
        echo -e "${YELLOW}Please install them and try again${NC}"
        exit 1
    fi
}

is_port_in_use() {
    lsof -sTCP:LISTEN -ti ":$1" >/dev/null 2>&1
}

get_pid_for_port() {
    lsof -ti ":$1" 2>/dev/null | head -1
}

get_uptime() {
    local timestamp=$1
    local now=$(date +%s)
    local duration=$((now - timestamp))
    local hours=$((duration / 3600))
    local minutes=$(((duration % 3600) / 60))
    
    if [ $hours -gt 0 ]; then
        echo "${hours}h ${minutes}m"
    else
        echo "${minutes}m"
    fi
}

parse_port_mapping() {
    local mapping=$1
    local local_port
    local remote_port

    if [[ $mapping == *:* ]]; then
        # Format: 8080:3000
        local_port="${mapping%%:*}"
        remote_port="${mapping##*:}"
    else
        # Format: 5432 (same port for both)
        local_port="$mapping"
        remote_port="$mapping"
    fi

    echo "$local_port|$remote_port"
}

remove_tunnel_entry() {
    local port=$1
    local temp_file="${TUNNEL_FILE}.tmp"

    # Use grep to filter out the line (cross-platform, no backup files)
    if [ -f "$TUNNEL_FILE" ]; then
        grep -v "^$port|" "$TUNNEL_FILE" > "$temp_file" 2>/dev/null || true
        mv "$temp_file" "$TUNNEL_FILE"
    fi
}

validate_port() {
    local port=$1

    # Check if port is numeric
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}❌ Invalid port number: $port (must be numeric)${NC}"
        return 1
    fi

    # Check if port is in valid range
    if [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo -e "${RED}❌ Invalid port number: $port (must be between 1 and 65535)${NC}"
        return 1
    fi

    return 0
}

# ============================================================================
# Core Functions
# ============================================================================

start_tunnel() {
    local port_mapping=""
    local host=""
    local remote_host="localhost"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--port)
                port_mapping="$2"
                shift 2
                ;;
            -H|--host)
                host="$2"
                shift 2
                ;;
            -r|--remote)
                remote_host="$2"
                shift 2
                ;;
            *)
                echo -e "${RED}❌ Unknown option: $1${NC}"
                return 1
                ;;
        esac
    done
    
    # Validation
    if [ -z "$port_mapping" ]; then
        echo -e "${RED}❌ Port mapping is required${NC}"
        echo "Usage: tunnel start -p <port[:remote_port]> --host <user@host> [-remote <remote_host>]"
        echo ""
        echo "Examples:"
        echo "  tunnel start -p 5432 --host paul@wsl"
        echo "  tunnel start -p 8080:3000 --host user@server.com"
        echo "  tunnel start -p 5432 --host user@jump.com -remote db.internal:5432"
        return 1
    fi
    
    if [ -z "$host" ]; then
        echo -e "${RED}❌ SSH host is required${NC}"
        echo "Usage: tunnel start -p <port[:remote_port]> --host <user@host>"
        echo "Example: tunnel start -p 5432 --host paul@wsl"
        return 1
    fi
    
    # Parse port mapping
    IFS='|' read -r local_port remote_port <<< "$(parse_port_mapping "$port_mapping")"

    # Validate ports
    validate_port "$local_port" || return 1
    validate_port "$remote_port" || return 1

    # Build remote destination
    local remote_dest
    if [[ $remote_host == *:* ]]; then
        # Remote host already has port
        remote_dest="$remote_host"
    else
        # Add port to remote host
        remote_dest="$remote_host:$remote_port"
    fi
    
    # Check if local port already in use
    if is_port_in_use "$local_port"; then
        echo -e "${RED}❌ Port $local_port is already in use${NC}"
        local existing_pid=$(get_pid_for_port "$local_port")
        if ps -p "$existing_pid" -o command= 2>/dev/null | grep -q "ssh.*-L"; then
            echo -e "${YELLOW}   This looks like an existing tunnel. Stop it first with: tunnel stop $local_port${NC}"
        fi
        return 1
    fi
    
    # Start the tunnel
    echo -e "${BLUE}🚀 Starting tunnel...${NC}"
    local ssh_error
    if ! ssh_error=$(ssh -fN -L "$local_port:$remote_dest" "$host" 2>&1); then
        echo -e "${RED}❌ Failed to start tunnel${NC}"
        if [ -n "$ssh_error" ]; then
            echo -e "${YELLOW}SSH Error: $ssh_error${NC}"
        else
            echo -e "${YELLOW}Check your SSH connection and credentials${NC}"
        fi
        return 1
    fi
    
    # Wait and verify
    sleep 0.5
    if is_port_in_use "$local_port"; then
        local pid=$(get_pid_for_port "$local_port")
        echo "$local_port|$remote_dest|$host|$pid|$(date +%s)" >> "$TUNNEL_FILE"
        echo -e "${GREEN}✅ Tunnel active!${NC}"
        echo -e "   ${GREEN}localhost:$local_port${NC} → ${BLUE}$remote_dest${NC} via ${YELLOW}$host${NC}"
    else
        echo -e "${RED}❌ Tunnel failed to start (check SSH connection)${NC}"
        return 1
    fi
}

stop_tunnel() {
    local port=$1

    if [ -z "$port" ]; then
        echo -e "${RED}❌ Please specify a port${NC}"
        echo "Usage: tunnel stop <port>"
        return 1
    fi

    # Validate port number
    validate_port "$port" || return 1

    # Get tunnel info from registry
    local tunnel_info=$(grep "^$port|" "$TUNNEL_FILE" 2>/dev/null)

    if [ -z "$tunnel_info" ]; then
        echo -e "${RED}❌ No tunnel found on port $port${NC}"
        return 1
    fi

    # Extract the PID from the tunnel registry
    IFS='|' read -r _ _ _ pid _ <<< "$tunnel_info"

    # Check if the process is still running and is an SSH tunnel
    if ps -p "$pid" -o command= 2>/dev/null | grep -q "ssh.*-L"; then
        # It's alive and is an SSH tunnel, kill it
        if kill "$pid" 2>/dev/null; then
            remove_tunnel_entry "$port"
            echo -e "${GREEN}✅ Stopped tunnel on port $port${NC}"
        else
            echo -e "${RED}❌ Failed to stop tunnel${NC}"
            return 1
        fi
    else
        # Process is dead or not an SSH tunnel anymore
        remove_tunnel_entry "$port"
        echo -e "${YELLOW}⚠️  Tunnel was not running (cleaned up stale entry)${NC}"
    fi
}

restart_tunnel() {
    local port=$1

    if [ -z "$port" ]; then
        echo -e "${RED}❌ Please specify a port${NC}"
        echo "Usage: tunnel restart <port>"
        return 1
    fi

    # Validate port number
    validate_port "$port" || return 1

    # Get tunnel info before stopping
    local tunnel_info=$(grep "^$port|" "$TUNNEL_FILE" 2>/dev/null)
    
    if [ -z "$tunnel_info" ]; then
        echo -e "${RED}❌ No tunnel found on port $port${NC}"
        return 1
    fi
    
    IFS='|' read -r local_port remote_dest host _ _ <<< "$tunnel_info"
    
    echo -e "${BLUE}🔄 Restarting tunnel on port $port...${NC}"
    stop_tunnel "$port"
    sleep 0.5
    
    # Restart with original parameters
    echo -e "${BLUE}🚀 Starting tunnel...${NC}"
    local ssh_error
    if ! ssh_error=$(ssh -fN -L "$local_port:$remote_dest" "$host" 2>&1); then
        echo -e "${RED}❌ Failed to restart tunnel${NC}"
        if [ -n "$ssh_error" ]; then
            echo -e "${YELLOW}SSH Error: $ssh_error${NC}"
        else
            echo -e "${YELLOW}Check your SSH connection and credentials${NC}"
        fi
        return 1
    fi
    
    sleep 0.5
    if is_port_in_use "$local_port"; then
        local pid=$(get_pid_for_port "$local_port")
        echo "$local_port|$remote_dest|$host|$pid|$(date +%s)" >> "$TUNNEL_FILE"
        echo -e "${GREEN}✅ Tunnel restarted!${NC}"
        echo -e "   ${GREEN}localhost:$local_port${NC} → ${BLUE}$remote_dest${NC} via ${YELLOW}$host${NC}"
    else
        echo -e "${RED}❌ Tunnel failed to restart${NC}"
        return 1
    fi
}

list_tunnels() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}              📋 Active SSH Tunnels                    ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    local has_tunnels=false
    local stale_entries=()
    
    # Read and validate tunnels
    while IFS='|' read -r port remote host pid timestamp; do
        [ -z "$port" ] && continue

        # Check if port is actually listening AND it's an SSH tunnel
        if is_port_in_use "$port"; then
            # Verify it's actually an SSH tunnel
            if ps -p "$pid" -o command= 2>/dev/null | grep -q "ssh.*-L"; then
                has_tunnels=true
                local uptime=$(get_uptime "$timestamp")

                echo -e "  ${GREEN}●${NC} Port ${GREEN}$port${NC}"
                echo -e "    ├─ Remote: ${BLUE}$remote${NC}"
                echo -e "    ├─ Host: ${YELLOW}$host${NC}"
                echo -e "    └─ Uptime: ${MAGENTA}$uptime${NC}"
                echo ""
            else
                # Port is in use but not by our SSH tunnel
                stale_entries+=("$port")
            fi
        else
            stale_entries+=("$port")
        fi
    done < "$TUNNEL_FILE" 2>/dev/null
    
    # Clean up stale entries
    if [ ${#stale_entries[@]} -gt 0 ]; then
        for port in "${stale_entries[@]}"; do
            remove_tunnel_entry "$port"
        done
    fi
    
    if [ "$has_tunnels" = false ]; then
        echo -e "  ${DIM}No active tunnels${NC}"
        echo -e "  ${BLUE}💡 Start one with: tunnel start -p <port> --host <user@host>${NC}"
        echo ""
    fi
    
    echo -e "${BLUE}────────────────────────────────────────────────────────────────${NC}"
}

stop_all_tunnels() {
    echo -e "${YELLOW}⚠️  This will stop ALL SSH tunnels. Continue? (y/N)${NC}"
    read -r confirm || {
        echo ""  # Newline after Ctrl+D
        echo -e "${BLUE}Cancelled${NC}"
        return 0
    }

    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Cancelled${NC}"
        return 0
    fi
    
    local count=0
    while IFS='|' read -r port remote host pid timestamp; do
        [ -z "$port" ] && continue
        # Use the pid from the registry file directly
        if [ ! -z "$pid" ] && ps -p "$pid" >/dev/null 2>&1; then
            if kill "$pid" 2>/dev/null; then
                ((count++))
                echo -e "${GREEN}  ✓ Stopped tunnel on port $port${NC}"
            fi
        fi
    done < "$TUNNEL_FILE" 2>/dev/null
    
    > "$TUNNEL_FILE"  # Clear the file

    echo -e "${GREEN}✅ Stopped $count tunnel(s)${NC}"
}

cleanup_orphaned_tunnels() {
    echo -e "${YELLOW}🧹 Cleaning up orphaned SSH tunnel processes...${NC}"
    echo ""

    # Find all SSH tunnel processes (ssh -fN -L)
    local pids=$(ps aux | grep "ssh.*-fN.*-L" | grep -v grep | awk '{print $2}')

    if [ -z "$pids" ]; then
        echo -e "${BLUE}No orphaned tunnels found${NC}"
        return 0
    fi

    echo -e "${CYAN}Found SSH tunnel processes:${NC}"
    ps aux | grep "ssh.*-fN.*-L" | grep -v grep | awk '{printf "  PID %s: %s\n", $2, substr($0, index($0,$11))}'
    echo ""

    echo -e "${YELLOW}⚠️  Kill these processes? (y/N)${NC}"
    read -r confirm || {
        echo ""
        echo -e "${BLUE}Cancelled${NC}"
        return 0
    }

    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Cancelled${NC}"
        return 0
    fi

    local count=0
    for pid in $pids; do
        if kill "$pid" 2>/dev/null; then
            ((count++))
            echo -e "${GREEN}✅ Killed process $pid${NC}"
        fi
    done

    # Clear the registry file
    > "$TUNNEL_FILE"

    echo ""
    echo -e "${GREEN}✅ Cleaned up $count orphaned tunnel(s)${NC}"
}

show_help() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                   SSH Tunnel Manager v${VERSION}                ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}Commands:${NC}"
    echo ""
    echo -e "  ${YELLOW}tunnel start -p <port[:remote_port]> --host <user@host> [-remote <host>]${NC}"
    echo -e "    Start a new tunnel"
    echo -e "    ${DIM}Examples:${NC}"
    echo -e "      ${CYAN}tunnel start -p 5432 --host paul@wsl${NC}"
    echo -e "      ${DIM}# Forward localhost:5432 → wsl:5432${NC}"
    echo ""
    echo -e "      ${CYAN}tunnel start -p 8080:3000 --host user@server.com${NC}"
    echo -e "      ${DIM}# Forward localhost:8080 → server:3000${NC}"
    echo ""
    echo -e "      ${CYAN}tunnel start -p 5432 --host user@jump.com -remote db.internal:5432${NC}"
    echo -e "      ${DIM}# Forward localhost:5432 → db.internal:5432 (via jump.com)${NC}"
    echo ""
    echo -e "  ${YELLOW}tunnel stop <port>${NC}"
    echo -e "    Stop a tunnel"
    echo -e "    ${DIM}Example: ${CYAN}tunnel stop 5432${NC}"
    echo ""
    echo -e "  ${YELLOW}tunnel restart <port>${NC}"
    echo -e "    Restart an existing tunnel"
    echo -e "    ${DIM}Example: ${CYAN}tunnel restart 5432${NC}"
    echo ""
    echo -e "  ${YELLOW}tunnel list${NC} ${DIM}(or just${NC} ${YELLOW}ports${NC}${DIM})${NC}"
    echo -e "    Show all active tunnels"
    echo ""
    echo -e "  ${YELLOW}tunnel stopall${NC}"
    echo -e "    Stop all tunnels"
    echo ""
    echo -e "  ${YELLOW}tunnel cleanup${NC}"
    echo -e "    Find and kill orphaned SSH tunnel processes"
    echo -e "    ${DIM}Use this if tunnels aren't showing in list but ports still work${NC}"
    echo ""
    echo -e "  ${YELLOW}tunnel version${NC}"
    echo -e "    Show version information"
    echo ""
    echo -e "  ${YELLOW}tunnel help${NC}"
    echo -e "    Show this help message"
    echo ""
    echo -e "${GREEN}Options:${NC}"
    echo -e "  ${CYAN}-p, --port${NC}      Port mapping (format: local or local:remote)"
    echo -e "  ${CYAN}-H, --host${NC}      SSH host (format: user@hostname)"
    echo -e "  ${CYAN}-r, --remote${NC}    Remote destination (default: localhost)"
    echo ""
}

show_version() {
    echo "SSH Tunnel Manager v${VERSION}"
}

install_script() {
    local install_path="/usr/local/bin/ports"
    
    echo -e "${BLUE}Installing SSH Tunnel Manager...${NC}"
    
    # Check if running with sudo or as root
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}❌ Installation requires sudo privileges${NC}"
        echo -e "${YELLOW}Run: curl -fsSL <url> | sudo bash -s -- install${NC}"
        exit 1
    fi
    
    # Copy script to /usr/local/bin
    cp "$0" "$install_path"
    chmod +x "$install_path"
    
    echo -e "${GREEN}✅ Installed to $install_path${NC}"
    echo -e "${GREEN}✅ You can now use 'ports' command${NC}"
    echo ""
    echo -e "${BLUE}Quick start:${NC}"
    echo -e "  ${CYAN}tunnel start -p 5432 --host user@server.com${NC}"
    echo -e "  ${CYAN}tunnel start -p 8080:3000 --host paul@wsl${NC}"
    echo -e "  ${CYAN}ports${NC}  ${DIM}# View active tunnels${NC}"
    echo ""
}

# ============================================================================
# Main Command Router
# ============================================================================

main() {
    # Check requirements
    check_requirements
    
    # Handle install command specially
    if [ "${1:-}" = "install" ]; then
        install_script
        exit 0
    fi
    
    case "${1:-list}" in
        start)
            shift
            start_tunnel "$@"
            ;;
        stop)
            stop_tunnel "${2:-}"
            ;;
        restart)
            restart_tunnel "${2:-}"
            ;;
        list|ls|"")
            list_tunnels
            ;;
        stopall|clear)
            stop_all_tunnels
            ;;
        cleanup)
            cleanup_orphaned_tunnels
            ;;
        version|-v|--version)
            show_version
            ;;
        help|-h|--help)
            show_help
            ;;
        *)
            echo -e "${RED}❌ Unknown command: $1${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"