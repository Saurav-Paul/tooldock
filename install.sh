#!/bin/bash
#
# tooldock installer
# One-line install: curl -sfL https://raw.githubusercontent.com/Saurav-Paul/tooldock/main/install.sh | sh
#

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
REPO="Saurav-Paul/tooldock"
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="tooldock"

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64|arm64)
        ARCH="arm64"
        ;;
    *)
        echo -e "${RED}Unsupported architecture: $ARCH${NC}"
        exit 1
        ;;
esac

case "$OS" in
    darwin|linux)
        ;;
    *)
        echo -e "${RED}Unsupported OS: $OS${NC}"
        exit 1
        ;;
esac

echo -e "${BLUE}Installing tooldock for $OS/$ARCH...${NC}"

# Get latest release
LATEST_RELEASE=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST_RELEASE" ]; then
    echo -e "${RED}Failed to get latest release${NC}"
    exit 1
fi

echo -e "${BLUE}Latest version: $LATEST_RELEASE${NC}"

# Download URL
BINARY_URL="https://github.com/$REPO/releases/download/${LATEST_RELEASE}/tooldock_${OS}_${ARCH}"

# Download binary
TMP_DIR=$(mktemp -d)
TMP_FILE="$TMP_DIR/$BINARY_NAME"

echo -e "${BLUE}Downloading from $BINARY_URL...${NC}"
if ! curl -sL "$BINARY_URL" -o "$TMP_FILE"; then
    echo -e "${RED}Failed to download binary${NC}"
    rm -rf "$TMP_DIR"
    exit 1
fi

# Make executable
chmod +x "$TMP_FILE"

# Move to install directory
if [ -w "$INSTALL_DIR" ]; then
    mv "$TMP_FILE" "$INSTALL_DIR/$BINARY_NAME"
else
    echo -e "${BLUE}Installing to $INSTALL_DIR (requires sudo)${NC}"
    sudo mv "$TMP_FILE" "$INSTALL_DIR/$BINARY_NAME"
fi

# Cleanup
rm -rf "$TMP_DIR"

echo -e "${GREEN}✅ tooldock installed successfully!${NC}"
echo ""
echo -e "${BLUE}Quick start:${NC}"
echo -e "  ${GREEN}tooldock plugin list${NC}      # List available plugins"
echo -e "  ${GREEN}tooldock plugin install ports${NC}  # Install a plugin"
echo -e "  ${GREEN}tooldock ports --help${NC}     # Use an installed plugin"
echo ""
