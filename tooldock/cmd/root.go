package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
	"github.com/Saurav-Paul/tooldock/pkg/config"
	"github.com/Saurav-Paul/tooldock/pkg/executor"
)

var rootCmd = &cobra.Command{
	Use:   "tooldock",
	Short: "A lightweight plugin-based CLI toolkit",
	Long: `tooldock is a personal CLI toolkit that allows you to install and manage
various development tools as plugins.

Install plugins with 'tooldock plugin install <name>' and use them directly
with 'tooldock <plugin> [args...]'`,
	Version: config.Version,
	// Don't show usage on error
	SilenceUsage: true,
}

// Execute runs the root command
func Execute() error {
	// Ensure directories exist
	if err := config.EnsureDirectories(); err != nil {
		return fmt.Errorf("failed to create directories: %w", err)
	}

	// Check if the first argument is an installed plugin
	if len(os.Args) > 1 {
		potentialPlugin := os.Args[1]

		// Skip if it's a known command
		if potentialPlugin != "plugin" && potentialPlugin != "help" &&
			potentialPlugin != "version" && potentialPlugin != "--help" &&
			potentialPlugin != "-h" && potentialPlugin != "--version" &&
			potentialPlugin != "-v" {

			// Check if it's an installed plugin
			if executor.IsPluginInstalled(potentialPlugin) {
				// Execute the plugin
				return executor.RunPlugin(potentialPlugin, os.Args[2:])
			}
		}
	}

	return rootCmd.Execute()
}

func init() {
	rootCmd.SetVersionTemplate("tooldock version {{.Version}}\n")
}
