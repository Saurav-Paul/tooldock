#!/bin/bash
#
# Snippet Manager
# Save and run frequently used commands with variable substitution
#
# Usage:
#   tooldock snippet save <name> "<command>" [--desc "description"]
#   tooldock snippet run <name> [key=value...]
#   tooldock snippet list
#   tooldock snippet show <name>
#   tooldock snippet remove <name>

set -euo pipefail

VERSION="1.0.0"
SNIPPETS_FILE="${HOME}/.tooldock/snippets.json"

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

# Initialize snippets file if it doesn't exist
init_snippets_file() {
    if [ ! -f "$SNIPPETS_FILE" ]; then
        mkdir -p "$(dirname "$SNIPPETS_FILE")"
        echo '{
  "version": "1.0",
  "snippets": {}
}' > "$SNIPPETS_FILE"
    fi
}

# Save a snippet
save_snippet() {
    local name=$1
    local command=$2
    local description="${3:-}"

    if [ -z "$name" ]; then
        echo -e "${RED}❌ Snippet name required${NC}"
        exit 1
    fi

    if [ -z "$command" ]; then
        echo -e "${RED}❌ Command required${NC}"
        exit 1
    fi

    init_snippets_file

    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Check if snippet exists
    local exists=$(jq -r ".snippets | has(\"$name\")" "$SNIPPETS_FILE")

    if [ "$exists" = "true" ]; then
        # Update existing snippet
        jq --arg name "$name" \
           --arg cmd "$command" \
           --arg desc "$description" \
           --arg ts "$timestamp" \
           '.snippets[$name] = {
               "command": $cmd,
               "description": $desc,
               "updated": $ts
           }' "$SNIPPETS_FILE" > "${SNIPPETS_FILE}.tmp" && mv "${SNIPPETS_FILE}.tmp" "$SNIPPETS_FILE"
        echo -e "${GREEN}✓ Updated snippet '${name}'${NC}"
    else
        # Create new snippet
        jq --arg name "$name" \
           --arg cmd "$command" \
           --arg desc "$description" \
           --arg ts "$timestamp" \
           '.snippets[$name] = {
               "command": $cmd,
               "description": $desc,
               "created": $ts,
               "updated": $ts
           }' "$SNIPPETS_FILE" > "${SNIPPETS_FILE}.tmp" && mv "${SNIPPETS_FILE}.tmp" "$SNIPPETS_FILE"
        echo -e "${GREEN}✓ Saved snippet '${name}'${NC}"
    fi
}

# List all snippets
list_snippets() {
    init_snippets_file

    local count=$(jq -r '.snippets | length' "$SNIPPETS_FILE")

    if [ "$count" -eq 0 ]; then
        echo -e "${YELLOW}No snippets found${NC}"
        echo -e "${DIM}Create one with: tooldock snippet save <name> \"<command>\"${NC}"
        exit 0
    fi

    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                  Saved Snippets (${count})                        ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    jq -r '.snippets | to_entries | .[] | @json' "$SNIPPETS_FILE" | \
    while IFS= read -r entry; do
        local name=$(echo "$entry" | jq -r '.key')
        local command=$(echo "$entry" | jq -r '.value.command')
        local desc=$(echo "$entry" | jq -r '.value.description // ""')

        echo -e "  ${GREEN}${name}${NC}"
        echo -e "    ${CYAN}Command:${NC} ${DIM}${command}${NC}"
        if [ -n "$desc" ]; then
            echo -e "    ${CYAN}Description:${NC} ${desc}"
        fi
        echo ""
    done
}

# Show a specific snippet
show_snippet() {
    local name=$1

    if [ -z "$name" ]; then
        echo -e "${RED}❌ Snippet name required${NC}"
        exit 1
    fi

    init_snippets_file

    local exists=$(jq -r ".snippets | has(\"$name\")" "$SNIPPETS_FILE")

    if [ "$exists" != "true" ]; then
        echo -e "${RED}❌ Snippet '${name}' not found${NC}"
        exit 1
    fi

    local command=$(jq -r ".snippets[\"$name\"].command" "$SNIPPETS_FILE")
    local description=$(jq -r ".snippets[\"$name\"].description // \"\"" "$SNIPPETS_FILE")
    local created=$(jq -r ".snippets[\"$name\"].created // \"\"" "$SNIPPETS_FILE")
    local updated=$(jq -r ".snippets[\"$name\"].updated // \"\"" "$SNIPPETS_FILE")

    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  Snippet: ${GREEN}${name}${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Command:${NC}"
    echo -e "  ${command}"
    echo ""

    if [ -n "$description" ]; then
        echo -e "${CYAN}Description:${NC}"
        echo -e "  ${description}"
        echo ""
    fi

    # Extract and show variables
    local vars=$(echo "$command" | grep -o '{{[^}]*}}' | sort -u || true)
    if [ -n "$vars" ]; then
        echo -e "${CYAN}Variables:${NC}"
        while IFS= read -r var; do
            # Remove {{ and }}
            local var_name=$(echo "$var" | sed 's/{{//g' | sed 's/}}//g')
            if [[ $var_name == *":"* ]]; then
                local name_part=$(echo "$var_name" | cut -d':' -f1)
                local default_part=$(echo "$var_name" | cut -d':' -f2-)
                echo -e "  ${YELLOW}${name_part}${NC} ${DIM}(default: ${default_part})${NC}"
            else
                echo -e "  ${YELLOW}${var_name}${NC} ${DIM}(required)${NC}"
            fi
        done <<< "$vars"
        echo ""
    fi

    if [ -n "$created" ]; then
        echo -e "${DIM}Created: ${created}${NC}"
    fi
    if [ -n "$updated" ] && [ "$updated" != "$created" ]; then
        echo -e "${DIM}Updated: ${updated}${NC}"
    fi
}

# Remove a snippet
remove_snippet() {
    local name=$1

    if [ -z "$name" ]; then
        echo -e "${RED}❌ Snippet name required${NC}"
        exit 1
    fi

    init_snippets_file

    local exists=$(jq -r ".snippets | has(\"$name\")" "$SNIPPETS_FILE")

    if [ "$exists" != "true" ]; then
        echo -e "${RED}❌ Snippet '${name}' not found${NC}"
        exit 1
    fi

    jq "del(.snippets[\"$name\"])" "$SNIPPETS_FILE" > "${SNIPPETS_FILE}.tmp" && mv "${SNIPPETS_FILE}.tmp" "$SNIPPETS_FILE"
    echo -e "${GREEN}✓ Removed snippet '${name}'${NC}"
}

# Get variable value from args
get_var_value() {
    local var_name=$1
    shift
    local args=("$@")

    for arg in "${args[@]}"; do
        if [[ $arg == "${var_name}="* ]]; then
            echo "${arg#*=}"
            return 0
        fi
    done
    return 1
}

# Substitute variables in command
substitute_variables() {
    local command=$1
    shift
    local args=("$@")

    # Process all {{var}} or {{var:default}} patterns
    local result="$command"
    local vars_in_cmd=$(echo "$command" | grep -o '{{[^}]*}}' || true)

    if [ -n "$vars_in_cmd" ]; then
        while IFS= read -r var_pattern; do
            [ -z "$var_pattern" ] && continue

            # Remove {{ and }}
            local var_content=$(echo "$var_pattern" | sed 's/{{//g' | sed 's/}}//g')

            if [[ $var_content == *":"* ]]; then
                # Has default value
                local var_name=$(echo "$var_content" | cut -d':' -f1)
                local default_value=$(echo "$var_content" | cut -d':' -f2-)

                local value
                if [ ${#args[@]} -gt 0 ] && value=$(get_var_value "$var_name" "${args[@]}"); then
                    result=$(echo "$result" | sed "s|$var_pattern|$value|g")
                else
                    result=$(echo "$result" | sed "s|$var_pattern|$default_value|g")
                fi
            else
                # No default value - required
                local var_name="$var_content"
                local value
                if [ ${#args[@]} -gt 0 ] && value=$(get_var_value "$var_name" "${args[@]}"); then
                    result=$(echo "$result" | sed "s|$var_pattern|$value|g")
                else
                    echo -e "${RED}❌ Missing required variable: ${var_name}${NC}" >&2
                    exit 1
                fi
            fi
        done <<< "$vars_in_cmd"
    fi

    echo "$result"
}

# Run a snippet
run_snippet() {
    local name=$1
    shift
    local args=("$@")

    if [ -z "$name" ]; then
        echo -e "${RED}❌ Snippet name required${NC}"
        exit 1
    fi

    init_snippets_file

    local exists=$(jq -r ".snippets | has(\"$name\")" "$SNIPPETS_FILE")

    if [ "$exists" != "true" ]; then
        echo -e "${RED}❌ Snippet '${name}' not found${NC}"
        exit 1
    fi

    local command=$(jq -r ".snippets[\"$name\"].command" "$SNIPPETS_FILE")

    # Substitute variables
    local final_command
    if [ ${#args[@]} -gt 0 ]; then
        final_command=$(substitute_variables "$command" "${args[@]}")
    else
        final_command=$(substitute_variables "$command")
    fi

    echo -e "${GREEN}🚀 Running snippet '${name}':${NC}"
    echo -e "${DIM}${final_command}${NC}"
    echo ""

    # Execute the command
    eval "$final_command"
}

show_help() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                Snippet Manager v${VERSION}                    ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}Usage:${NC}"
    echo ""
    echo -e "  ${YELLOW}tooldock snippet save <name> \"<command>\" [--desc \"description\"]${NC}"
    echo -e "    Save a new snippet or update existing one"
    echo -e "    ${DIM}Example: tooldock snippet save deploy \"cd /app && git pull\"${NC}"
    echo -e "    ${DIM}Example: tooldock snippet save greet \"echo 'Hello {{name}}'\"${NC}"
    echo ""
    echo -e "  ${YELLOW}tooldock snippet run <name> [key=value...]${NC}"
    echo -e "    Run a saved snippet with variable substitution"
    echo -e "    ${DIM}Example: tooldock snippet run deploy${NC}"
    echo -e "    ${DIM}Example: tooldock snippet run greet name=John${NC}"
    echo ""
    echo -e "  ${YELLOW}tooldock snippet list${NC}"
    echo -e "    List all saved snippets"
    echo ""
    echo -e "  ${YELLOW}tooldock snippet show <name>${NC}"
    echo -e "    Show details of a specific snippet"
    echo -e "    ${DIM}Example: tooldock snippet show deploy${NC}"
    echo ""
    echo -e "  ${YELLOW}tooldock snippet remove <name>${NC}"
    echo -e "    Remove a saved snippet"
    echo -e "    ${DIM}Example: tooldock snippet remove deploy${NC}"
    echo ""
    echo -e "  ${YELLOW}tooldock snippet --help${NC}"
    echo -e "    Show this help message"
    echo ""
    echo -e "  ${YELLOW}tooldock snippet --version${NC}"
    echo -e "    Show version information"
    echo ""
    echo -e "${GREEN}Variables:${NC}"
    echo -e "  Use ${YELLOW}{{varname}}${NC} for required variables"
    echo -e "  Use ${YELLOW}{{varname:default}}${NC} for optional variables with defaults"
    echo ""
    echo -e "  ${DIM}Example:${NC}"
    echo -e "    ${DIM}tooldock snippet save greet \"echo 'Hello {{name:World}}'\"${NC}"
    echo -e "    ${DIM}tooldock snippet run greet              # Uses 'World'${NC}"
    echo -e "    ${DIM}tooldock snippet run greet name=John    # Uses 'John'${NC}"
    echo ""
}

show_version() {
    echo "Snippet Manager v${VERSION}"
}

# Main
main() {
    case "${1:-}" in
        save)
            shift
            local name="${1:-}"
            local command="${2:-}"
            local description=""

            shift 2 2>/dev/null || true

            # Parse --desc flag
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    --desc)
                        description="${2:-}"
                        shift 2
                        ;;
                    *)
                        shift
                        ;;
                esac
            done

            save_snippet "$name" "$command" "$description"
            ;;
        list|ls)
            list_snippets
            ;;
        show)
            shift
            show_snippet "${1:-}"
            ;;
        remove|rm)
            shift
            remove_snippet "${1:-}"
            ;;
        run)
            shift
            run_snippet "$@"
            ;;
        -h|--help|help)
            show_help
            ;;
        -v|--version|version)
            show_version
            ;;
        "")
            list_snippets
            ;;
        *)
            echo -e "${RED}❌ Unknown command: ${1}${NC}"
            echo -e "${DIM}Run 'tooldock snippet --help' for usage information${NC}"
            exit 1
            ;;
    esac
}

main "$@"
