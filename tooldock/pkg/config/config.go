package config

import (
	"os"
	"path/filepath"
)

const (
	defaultRegistryURL = "https://raw.githubusercontent.com/Saurav-Paul/tooldock-plugins/main/plugins.json"
	AppName            = "tooldock"
	Version            = "1.0.0"
)

// GetRegistryURL returns the plugin registry URL
// Can be overridden with TOOLDOCK_REGISTRY_URL environment variable
func GetRegistryURL() string {
	if url := os.Getenv("TOOLDOCK_REGISTRY_URL"); url != "" {
		return url
	}
	return defaultRegistryURL
}

// GetPluginDir returns the directory where plugins are installed
func GetPluginDir() string {
	home, err := os.UserHomeDir()
	if err != nil {
		return ""
	}
	return filepath.Join(home, "."+AppName, "plugins")
}

// GetCacheDir returns the directory for cached data
func GetCacheDir() string {
	home, err := os.UserHomeDir()
	if err != nil {
		return ""
	}
	return filepath.Join(home, "."+AppName, "cache")
}

// EnsureDirectories creates necessary directories if they don't exist
func EnsureDirectories() error {
	dirs := []string{GetPluginDir(), GetCacheDir()}
	for _, dir := range dirs {
		if err := os.MkdirAll(dir, 0755); err != nil {
			return err
		}
	}
	return nil
}
