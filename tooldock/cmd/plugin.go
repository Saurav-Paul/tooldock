package cmd

import (
	"fmt"
	"strings"

	"github.com/spf13/cobra"
	"github.com/yourname/tooldock/pkg/registry"
)

var pluginCmd = &cobra.Command{
	Use:   "plugin",
	Short: "Manage tooldock plugins",
	Long:  `Install, remove, update, and list available plugins for tooldock.`,
}

var pluginListCmd = &cobra.Command{
	Use:   "list",
	Short: "List available and installed plugins",
	Long:  `List all available plugins from the registry and show which ones are installed.`,
	RunE: func(cmd *cobra.Command, args []string) error {
		// Fetch registry
		reg, err := registry.GetCachedRegistry()
		if err != nil {
			return fmt.Errorf("failed to fetch plugin registry: %w", err)
		}

		// Get installed plugins
		installed, err := registry.GetInstalledPlugins()
		if err != nil {
			return fmt.Errorf("failed to get installed plugins: %w", err)
		}

		installedMap := make(map[string]bool)
		for _, name := range installed {
			installedMap[name] = true
		}

		// Display plugins
		fmt.Println("Available plugins:")
		fmt.Println()

		for _, plugin := range reg.Plugins {
			status := "  "
			if installedMap[plugin.Name] {
				status = "✓ "
			}
			fmt.Printf("%s%-15s %s (v%s)\n", status, plugin.Name, plugin.Description, plugin.Version)
		}

		fmt.Println()
		fmt.Println("✓ = installed")
		return nil
	},
}

var pluginInstallCmd = &cobra.Command{
	Use:   "install [plugin]",
	Short: "Install a plugin",
	Long:  `Download and install a plugin from the registry.`,
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		pluginName := args[0]

		// Fetch registry
		reg, err := registry.GetCachedRegistry()
		if err != nil {
			return fmt.Errorf("failed to fetch plugin registry: %w", err)
		}

		// Find plugin
		plugin := reg.FindPlugin(pluginName)
		if plugin == nil {
			return fmt.Errorf("plugin '%s' not found in registry", pluginName)
		}

		// Check if already installed
		installedPlugins, err := registry.GetInstalledPlugins()
		if err != nil {
			return err
		}
		for _, installed := range installedPlugins {
			if installed == pluginName {
				fmt.Printf("⚠️  Plugin '%s' is already installed\n", pluginName)
				fmt.Printf("💡 Use 'tooldock plugin update %s' to update it\n", pluginName)
				return nil
			}
		}

		// Download plugin
		fmt.Printf("📦 Installing %s v%s...\n", plugin.Name, plugin.Version)
		if err := registry.DownloadPlugin(plugin); err != nil {
			return fmt.Errorf("failed to install plugin: %w", err)
		}

		fmt.Printf("✅ Successfully installed %s\n", plugin.Name)
		fmt.Printf("💡 Usage: tooldock %s [args...]\n", plugin.Name)
		return nil
	},
}

var pluginRemoveCmd = &cobra.Command{
	Use:     "remove [plugin]",
	Aliases: []string{"uninstall", "rm"},
	Short:   "Remove an installed plugin",
	Long:    `Uninstall a plugin from your system.`,
	Args:    cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		pluginName := args[0]

		if err := registry.RemovePlugin(pluginName); err != nil {
			return err
		}

		fmt.Printf("✅ Successfully removed %s\n", pluginName)
		return nil
	},
}

var pluginUpdateCmd = &cobra.Command{
	Use:   "update [plugin]",
	Short: "Update an installed plugin",
	Long:  `Download and install the latest version of a plugin.`,
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		pluginName := args[0]

		// Check if plugin is installed
		installedPlugins, err := registry.GetInstalledPlugins()
		if err != nil {
			return err
		}

		isInstalled := false
		for _, installed := range installedPlugins {
			if installed == pluginName {
				isInstalled = true
				break
			}
		}

		if !isInstalled {
			return fmt.Errorf("plugin '%s' is not installed", pluginName)
		}

		// Fetch fresh registry (not cached)
		reg, err := registry.FetchRegistry()
		if err != nil {
			return fmt.Errorf("failed to fetch plugin registry: %w", err)
		}

		// Find plugin
		plugin := reg.FindPlugin(pluginName)
		if plugin == nil {
			return fmt.Errorf("plugin '%s' not found in registry", pluginName)
		}

		// Remove old version
		if err := registry.RemovePlugin(pluginName); err != nil {
			return fmt.Errorf("failed to remove old version: %w", err)
		}

		// Download new version
		fmt.Printf("📦 Updating %s to v%s...\n", plugin.Name, plugin.Version)
		if err := registry.DownloadPlugin(plugin); err != nil {
			return fmt.Errorf("failed to update plugin: %w", err)
		}

		fmt.Printf("✅ Successfully updated %s to v%s\n", plugin.Name, plugin.Version)
		return nil
	},
}

var pluginSearchCmd = &cobra.Command{
	Use:   "search [query]",
	Short: "Search for plugins",
	Long:  `Search for plugins by name or description.`,
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		query := strings.ToLower(args[0])

		// Fetch registry
		reg, err := registry.GetCachedRegistry()
		if err != nil {
			return fmt.Errorf("failed to fetch plugin registry: %w", err)
		}

		// Get installed plugins
		installed, err := registry.GetInstalledPlugins()
		if err != nil {
			return fmt.Errorf("failed to get installed plugins: %w", err)
		}

		installedMap := make(map[string]bool)
		for _, name := range installed {
			installedMap[name] = true
		}

		// Search and display matching plugins
		fmt.Printf("Search results for '%s':\n\n", query)

		found := false
		for _, plugin := range reg.Plugins {
			if strings.Contains(strings.ToLower(plugin.Name), query) ||
				strings.Contains(strings.ToLower(plugin.Description), query) {
				found = true
				status := "  "
				if installedMap[plugin.Name] {
					status = "✓ "
				}
				fmt.Printf("%s%-15s %s (v%s)\n", status, plugin.Name, plugin.Description, plugin.Version)
			}
		}

		if !found {
			fmt.Println("No plugins found matching your query.")
		}

		fmt.Println()
		return nil
	},
}

func init() {
	rootCmd.AddCommand(pluginCmd)
	pluginCmd.AddCommand(pluginListCmd)
	pluginCmd.AddCommand(pluginInstallCmd)
	pluginCmd.AddCommand(pluginRemoveCmd)
	pluginCmd.AddCommand(pluginUpdateCmd)
	pluginCmd.AddCommand(pluginSearchCmd)
}
