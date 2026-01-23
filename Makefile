.PHONY: build install clean test run help docker-build docker-run docker-shell docker-init docker-clean

# Variables
BINARY_NAME=tooldock
VERSION=$(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
BUILD_DIR=build
INSTALL_PATH=/usr/local/bin

# Build flags
LDFLAGS=-ldflags "-X github.com/Saurav-Paul/tooldock/pkg/config.Version=$(VERSION)"

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ''
	@echo 'Docker targets:'
	@echo '  docker-init          Initialize with Docker'
	@echo '  docker-build         Build with Docker'
	@echo '  docker-build-all     Build all platforms with Docker'
	@echo '  docker-run           Run with Docker'
	@echo '  docker-shell         Open shell in Docker'
	@echo '  docker-clean         Clean Docker volumes'

build: ## Build the binary
	@echo "Building $(BINARY_NAME) $(VERSION)..."
	@mkdir -p $(BUILD_DIR)
	cd tooldock && go build $(LDFLAGS) -o ../$(BUILD_DIR)/$(BINARY_NAME) .
	@echo "✅ Built: $(BUILD_DIR)/$(BINARY_NAME)"

build-all: ## Build for all platforms
	@echo "Building for all platforms..."
	@mkdir -p $(BUILD_DIR)
	cd tooldock && GOOS=darwin GOARCH=amd64 go build $(LDFLAGS) -o ../$(BUILD_DIR)/$(BINARY_NAME)_darwin_amd64 .
	cd tooldock && GOOS=darwin GOARCH=arm64 go build $(LDFLAGS) -o ../$(BUILD_DIR)/$(BINARY_NAME)_darwin_arm64 .
	cd tooldock && GOOS=linux GOARCH=amd64 go build $(LDFLAGS) -o ../$(BUILD_DIR)/$(BINARY_NAME)_linux_amd64 .
	cd tooldock && GOOS=linux GOARCH=arm64 go build $(LDFLAGS) -o ../$(BUILD_DIR)/$(BINARY_NAME)_linux_arm64 .
	@echo "✅ Built all platform binaries in $(BUILD_DIR)/"

install: build ## Build and install to /usr/local/bin
	@echo "Installing to $(INSTALL_PATH)..."
	@sudo cp $(BUILD_DIR)/$(BINARY_NAME) $(INSTALL_PATH)/$(BINARY_NAME)
	@echo "✅ Installed: $(INSTALL_PATH)/$(BINARY_NAME)"

uninstall: ## Uninstall from /usr/local/bin
	@echo "Uninstalling from $(INSTALL_PATH)..."
	@sudo rm -f $(INSTALL_PATH)/$(BINARY_NAME)
	@echo "✅ Uninstalled"

clean: ## Clean build artifacts
	@echo "Cleaning..."
	@rm -rf $(BUILD_DIR)
	@echo "✅ Cleaned"

test: ## Run tests
	cd tooldock && go test -v ./...

run: build ## Build and run
	$(BUILD_DIR)/$(BINARY_NAME)

fmt: ## Format code
	cd tooldock && go fmt ./...

lint: ## Run linter
	cd tooldock && golangci-lint run

deps: ## Download dependencies
	cd tooldock && go mod download
	cd tooldock && go mod tidy

dev: ## Run in development mode
	cd tooldock && go run . $(ARGS)

# Docker targets
docker-init: ## Initialize project using Docker
	./docker.sh init

docker-build: ## Build using Docker
	./docker.sh build

docker-build-all: ## Build all platforms using Docker
	./docker.sh build-all

docker-run: ## Run using Docker (use ARGS="plugin list")
	./docker.sh run $(ARGS)

docker-shell: ## Open shell in Docker container
	./docker.sh shell

docker-test: ## Run tests in Docker
	./docker.sh test

docker-clean: ## Clean Docker volumes and build artifacts
	./docker.sh clean
