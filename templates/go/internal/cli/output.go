package cli

import (
	"encoding/json"
	"fmt"
	"os"
	"slices"

	"github.com/spf13/cobra"
)

// emit writes the result of a command to stdout: v as one JSON document
// when --json is set, otherwise the human readable text.
func emit(cmd *cobra.Command, v any, human string) error {
	if jsonMode(cmd) {
		return json.NewEncoder(cmd.OutOrStdout()).Encode(v)
	}
	_, err := fmt.Fprintln(cmd.OutOrStdout(), human)
	return err
}

// printError writes err to stderr, as {"error": "..."} when --json is set.
func printError(root *cobra.Command, err error) {
	if jsonMode(root) {
		_ = json.NewEncoder(root.ErrOrStderr()).Encode(map[string]string{"error": err.Error()})
		return
	}
	_, _ = fmt.Fprintln(root.ErrOrStderr(), "error:", err)
}

// jsonMode reports whether --json was given. The raw argument check covers
// errors that happen before cobra has parsed the flags, e.g. an unknown command.
func jsonMode(cmd *cobra.Command) bool {
	if on, err := cmd.Root().PersistentFlags().GetBool("json"); err == nil && on {
		return true
	}
	return slices.Contains(os.Args[1:], "--json")
}
