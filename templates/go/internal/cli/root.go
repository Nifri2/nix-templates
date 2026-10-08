// Package cli defines the command tree. One file per command.
package cli

import (
	"github.com/spf13/cobra"
)

const appName = "projectname"

// Main runs the CLI and returns the process exit code.
// It is the single entry point for main.go and for the e2e harness.
func Main(version string) int {
	root := newRoot(version)
	if err := root.Execute(); err != nil {
		printError(root, err)
		return 1
	}
	return 0
}

func newRoot(version string) *cobra.Command {
	root := &cobra.Command{
		Use:           appName,
		Short:         "TODO: one line description",
		SilenceUsage:  true,
		SilenceErrors: true,
	}
	root.PersistentFlags().Bool("json", false, "machine-readable JSON output")

	// Register commands here, one line per command.
	root.AddCommand(newVersionCmd(version))

	return root
}
