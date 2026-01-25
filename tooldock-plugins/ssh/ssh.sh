#!/bin/bash
#
# SSH Host Manager
# Interactive SSH connection manager that reads from ~/.ssh/config
#
# Usage:
#   tooldock ssh              # Interactive host selection
#   tooldock ssh <hostname>   # Direct connection
#   tooldock ssh --help       # Show help

set -euo pipefail

VERSION="1.0.0"
SSH_CONFIG="${HOME}/.ssh/config"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

# Parse SSH config and extract Host entries
get_hosts() {
    if [ ! -f "$SSH_CONFIG" ]; then
        echo -e "${RED}❌ SSH config file not found: $SSH_CONFIG${NC}" >&2
        exit 1
    fi

    # Extract Host entries, exclude wildcards
    grep "^Host " "$SSH_CONFIG" | \
        awk '{print $2}' | \
        grep -v '\*' | \
        sort -u
}

# Get host details from SSH config
get_host_details() {
    local hostname=$1
    local user=""
    local host=""
    local port=""

    # Parse the config for this host
    local in_host=false
    while IFS= read -r line; do
        if [[ $line =~ ^Host[[:space:]]+${hostname}$ ]]; then
            in_host=true
            continue
        elif [[ $line =~ ^Host[[:space:]] ]]; then
            in_host=false
        fi

        if [ "$in_host" = true ]; then
            if [[ $line =~ ^[[:space:]]*HostName[[:space:]]+(.*) ]]; then
                host="${BASH_REMATCH[1]}"
            elif [[ $line =~ ^[[:space:]]*User[[:space:]]+(.*) ]]; then
                user="${BASH_REMATCH[1]}"
            elif [[ $line =~ ^[[:space:]]*Port[[:space:]]+(.*) ]]; then
                port="${BASH_REMATCH[1]}"
            fi
        fi
    done < "$SSH_CONFIG"

    # Build connection string
    local details=""
    [ -n "$user" ] && details="${user}@"
    [ -n "$host" ] && details="${details}${host}" || details="${details}${hostname}"
    [ -n "$port" ] && details="${details}:${port}"

    echo "$details"
}

# Show interactive host menu
show_menu() {
    local hosts=()
    while IFS= read -r host; do
        hosts+=("$host")
    done < <(get_hosts)

    if [ ${#hosts[@]} -eq 0 ]; then
        echo -e "${RED}❌ No hosts found in $SSH_CONFIG${NC}"
        exit 1
    fi

    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                    SSH Host Selector                       ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Display hosts
    local i=1
    for host in "${hosts[@]}"; do
        local details=$(get_host_details "$host")
        printf "  ${CYAN}%2d${NC}. ${GREEN}%-20s${NC} ${DIM}%s${NC}\n" "$i" "$host" "$details"
        ((i++))
    done

    echo ""
    echo -e "${BLUE}────────────────────────────────────────────────────────────────${NC}"
    echo -e -n "${YELLOW}Select host number (or q to quit): ${NC}"

    read -r choice

    # Handle quit
    if [[ $choice == "q" ]] || [[ $choice == "Q" ]]; then
        echo -e "${BLUE}Cancelled${NC}"
        exit 0
    fi

    # Validate choice
    if ! [[ $choice =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#hosts[@]} ]; then
        echo -e "${RED}❌ Invalid selection${NC}"
        exit 1
    fi

    # Get selected host
    local selected_host="${hosts[$((choice - 1))]}"

    echo -e "${GREEN}🔗 Connecting to ${selected_host}...${NC}"
    echo ""

    # Connect
    ssh "$selected_host"
}

# Direct connection
connect_to_host() {
    local hostname=$1
    shift  # Remove hostname from arguments
    local cmd_args=("$@")

    # Check if host exists in config
    if ! get_hosts | grep -q "^${hostname}$"; then
        echo -e "${YELLOW}⚠️  Host '$hostname' not found in SSH config${NC}"
        echo -e "${BLUE}Attempting direct connection...${NC}"
    else
        if [ ${#cmd_args[@]} -gt 0 ]; then
            echo -e "${GREEN}🚀 Running on ${hostname}: ${cmd_args[*]}${NC}"
        else
            echo -e "${GREEN}🔗 Connecting to ${hostname}...${NC}"
        fi
    fi

    echo ""

    # If command arguments provided, run with -t for interactive support
    if [ ${#cmd_args[@]} -gt 0 ]; then
        ssh -t "$hostname" "${cmd_args[@]}"
    else
        ssh "$hostname"
    fi
}

show_help() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                  SSH Host Manager v${VERSION}                 ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}Usage:${NC}"
    echo ""
    echo -e "  ${YELLOW}tooldock ssh${NC}"
    echo -e "    Show interactive host selection menu"
    echo ""
    echo -e "  ${YELLOW}tooldock ssh <hostname>${NC}"
    echo -e "    Connect directly to a host"
    echo -e "    ${DIM}Example: tooldock ssh wsl${NC}"
    echo ""
    echo -e "  ${YELLOW}tooldock ssh <hostname> <command>${NC}"
    echo -e "    Run a command on remote host (interactive)"
    echo -e "    ${DIM}Example: tooldock ssh wsl claude${NC}"
    echo -e "    ${DIM}Example: tooldock ssh wsl docker ps${NC}"
    echo ""
    echo -e "  ${YELLOW}tooldock ssh --help${NC}"
    echo -e "    Show this help message"
    echo ""
    echo -e "  ${YELLOW}tooldock ssh --version${NC}"
    echo -e "    Show version information"
    echo ""
    echo -e "${GREEN}Features:${NC}"
    echo -e "  • Reads hosts from ${CYAN}~/.ssh/config${NC}"
    echo -e "  • Interactive numbered selection"
    echo -e "  • Shows host details (user, hostname, port)"
    echo -e "  • Direct connection by hostname"
    echo -e "  • Run remote commands interactively"
    echo ""
    echo -e "${GREEN}Example SSH Config:${NC}"
    echo -e "  ${DIM}Host wsl${NC}"
    echo -e "  ${DIM}  HostName localhost${NC}"
    echo -e "  ${DIM}  User paul${NC}"
    echo -e "  ${DIM}  Port 22${NC}"
    echo ""
}

show_version() {
    echo "SSH Host Manager v${VERSION}"
}

# Main
main() {
    case "${1:-}" in
        -h|--help|help)
            show_help
            ;;
        -v|--version|version)
            show_version
            ;;
        "")
            show_menu
            ;;
        *)
            connect_to_host "$@"
            ;;
    esac
}

main "$@"
