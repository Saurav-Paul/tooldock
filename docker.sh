#!/bin/bash
#
# Docker helper script for tooldock development
# Usage: ./docker.sh <command>
#

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

show_help() {
    cat << EOF
${BLUE}tooldock Docker Helper${NC}

Usage: ./docker.sh <command> [args...]

Commands:
  ${GREEN}init${NC}         Initialize Go modules
  ${GREEN}build${NC}        Build the tooldock binary
  ${GREEN}build-all${NC}    Build for all platforms
  ${GREEN}test${NC}         Run tests
  ${GREEN}shell${NC}        Open a bash shell in the dev container
  ${GREEN}run${NC}          Run tooldock with arguments (e.g., ./docker.sh run plugin list)
  ${GREEN}clean${NC}        Clean build artifacts and Docker volumes
  ${GREEN}fmt${NC}          Format Go code
  ${GREEN}tidy${NC}         Tidy Go modules

Examples:
  ./docker.sh init                    # Initialize project
  ./docker.sh build                   # Build binary
  ./docker.sh run plugin list         # Run tooldock plugin list
  ./docker.sh shell                   # Open interactive shell
  ./docker.sh build-all               # Build for all platforms

EOF
}

init_project() {
    echo -e "${BLUE}Initializing Go modules...${NC}"
    docker compose run --rm dev go mod download
    docker compose run --rm dev go mod tidy
    echo -e "${GREEN}✅ Initialization complete${NC}"
}

build_binary() {
    echo -e "${BLUE}Building tooldock...${NC}"
    mkdir -p build
    docker compose run --rm dev go build -ldflags="-w -s" -o ../build/tooldock .
    echo -e "${GREEN}✅ Build complete: build/tooldock${NC}"
}

build_all_platforms() {
    echo -e "${BLUE}Building for all platforms...${NC}"

    mkdir -p build

    platforms=(
        "darwin/amd64"
        "darwin/arm64"
        "linux/amd64"
        "linux/arm64"
    )

    for platform in "${platforms[@]}"; do
        IFS='/' read -r os arch <<< "$platform"
        output="build/tooldock_${os}_${arch}"

        echo -e "${YELLOW}Building ${os}/${arch}...${NC}"
        docker compose run --rm -e GOOS=$os -e GOARCH=$arch dev \
            go build -ldflags="-w -s" -o "$output" .
    done

    echo -e "${GREEN}✅ Built all platform binaries in build/${NC}"
}

run_tests() {
    echo -e "${BLUE}Running tests...${NC}"
    docker compose run --rm dev go test -v ./...
}

open_shell() {
    echo -e "${BLUE}Opening development shell...${NC}"
    docker compose run --rm dev /bin/bash
}

run_tooldock() {
    if [ ! -f "build/tooldock" ]; then
        echo -e "${YELLOW}Binary not found. Building...${NC}"
        build_binary
    fi

    docker compose run --rm -v "$(pwd)/build:/app/build" dev /app/build/tooldock "$@"
}

clean_all() {
    echo -e "${BLUE}Cleaning...${NC}"
    rm -rf build/
    docker compose down -v
    echo -e "${GREEN}✅ Cleaned${NC}"
}

format_code() {
    echo -e "${BLUE}Formatting code...${NC}"
    docker compose run --rm dev go fmt ./...
    echo -e "${GREEN}✅ Code formatted${NC}"
}

tidy_modules() {
    echo -e "${BLUE}Tidying Go modules...${NC}"
    docker compose run --rm dev go mod tidy
    echo -e "${GREEN}✅ Modules tidied${NC}"
}

# Main command router
case "${1:-help}" in
    init)
        init_project
        ;;
    build)
        build_binary
        ;;
    build-all)
        build_all_platforms
        ;;
    test)
        run_tests
        ;;
    shell)
        open_shell
        ;;
    run)
        shift
        run_tooldock "$@"
        ;;
    clean)
        clean_all
        ;;
    fmt)
        format_code
        ;;
    tidy)
        tidy_modules
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${YELLOW}Unknown command: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
