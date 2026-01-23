package executor

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/yourname/tooldock/pkg/config"
)

// IsPluginInstalled checks if a plugin is installed
func IsPluginInstalled(name string) bool {
	pluginPath := getPluginPath(name)
	_, err := os.Stat(pluginPath)
	return err == nil
}

// RunPlugin executes an installed plugin with the given arguments
func RunPlugin(name string, args []string) error {
	if !IsPluginInstalled(name) {
		return fmt.Errorf("plugin '%s' is not installed. Install it with: tooldock plugin install %s", name, name)
	}

	pluginPath := getPluginPath(name)

	// Create command
	cmd := exec.Command(pluginPath, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	// Run the plugin
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("plugin execution failed: %w", err)
	}

	return nil
}

// getPluginPath returns the full path to a plugin
func getPluginPath(name string) string {
	return filepath.Join(config.GetPluginDir(), name)
}
