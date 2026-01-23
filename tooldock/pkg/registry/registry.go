package registry

import (
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"time"

	"github.com/Saurav-Paul/tooldock/pkg/config"
)

type Plugin struct {
	Name        string `json:"name"`
	Description string `json:"description"`
	Version     string `json:"version"`
	URL         string `json:"url"`
	Type        string `json:"type"` // "script" or "binary"
	Checksum    string `json:"checksum"`
}

type Registry struct {
	Version string   `json:"version"`
	Plugins []Plugin `json:"plugins"`
}

// FetchRegistry downloads the plugin registry from GitHub
func FetchRegistry() (*Registry, error) {
	resp, err := http.Get(config.GetRegistryURL())
	if err != nil {
		return nil, fmt.Errorf("failed to fetch registry: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("failed to fetch registry: status %d", resp.StatusCode)
	}

	var registry Registry
	if err := json.NewDecoder(resp.Body).Decode(&registry); err != nil {
		return nil, fmt.Errorf("failed to parse registry: %w", err)
	}

	// Cache the registry
	cacheRegistry(&registry)

	return &registry, nil
}

// GetCachedRegistry returns the cached registry if available and fresh
func GetCachedRegistry() (*Registry, error) {
	cachePath := filepath.Join(config.GetCacheDir(), "registry.json")

	// Check if cache exists and is less than 24 hours old
	info, err := os.Stat(cachePath)
	if err == nil && time.Since(info.ModTime()) < 24*time.Hour {
		data, err := os.ReadFile(cachePath)
		if err == nil {
			var registry Registry
			if err := json.Unmarshal(data, &registry); err == nil {
				return &registry, nil
			}
		}
	}

	// Cache is stale or doesn't exist, fetch fresh
	return FetchRegistry()
}

// cacheRegistry saves the registry to cache
func cacheRegistry(registry *Registry) error {
	cachePath := filepath.Join(config.GetCacheDir(), "registry.json")
	data, err := json.MarshalIndent(registry, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(cachePath, data, 0644)
}

// FindPlugin finds a plugin by name in the registry
func (r *Registry) FindPlugin(name string) *Plugin {
	for _, p := range r.Plugins {
		if p.Name == name {
			return &p
		}
	}
	return nil
}

// DownloadPlugin downloads a plugin from the given URL
func DownloadPlugin(plugin *Plugin) error {
	resp, err := http.Get(plugin.URL)
	if err != nil {
		return fmt.Errorf("failed to download plugin: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("failed to download plugin: status %d", resp.StatusCode)
	}

	// Read the content
	content, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Errorf("failed to read plugin content: %w", err)
	}

	// Verify checksum if provided
	if plugin.Checksum != "" {
		hash := sha256.Sum256(content)
		checksum := fmt.Sprintf("sha256:%x", hash)
		if checksum != plugin.Checksum {
			return fmt.Errorf("checksum mismatch: expected %s, got %s", plugin.Checksum, checksum)
		}
	}

	// Write to plugin directory
	pluginPath := filepath.Join(config.GetPluginDir(), plugin.Name)
	if err := os.WriteFile(pluginPath, content, 0755); err != nil {
		return fmt.Errorf("failed to write plugin: %w", err)
	}

	return nil
}

// GetInstalledPlugins returns a list of installed plugin names
func GetInstalledPlugins() ([]string, error) {
	pluginDir := config.GetPluginDir()
	entries, err := os.ReadDir(pluginDir)
	if err != nil {
		if os.IsNotExist(err) {
			return []string{}, nil
		}
		return nil, err
	}

	var plugins []string
	for _, entry := range entries {
		if !entry.IsDir() && entry.Name()[0] != '.' {
			plugins = append(plugins, entry.Name())
		}
	}
	return plugins, nil
}

// RemovePlugin removes an installed plugin
func RemovePlugin(name string) error {
	pluginPath := filepath.Join(config.GetPluginDir(), name)
	if err := os.Remove(pluginPath); err != nil {
		if os.IsNotExist(err) {
			return fmt.Errorf("plugin %s is not installed", name)
		}
		return fmt.Errorf("failed to remove plugin: %w", err)
	}
	return nil
}
