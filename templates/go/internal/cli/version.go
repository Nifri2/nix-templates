package cli

import (
	"github.com/spf13/cobra"
)

type versionInfo struct {
	Name    string `json:"name"`
	Version string `json:"version"`
}

func newVersionCmd(version string) *cobra.Command {
	return &cobra.Command{
		Use:   "version",
		Short: "Print the version",
		Args:  cobra.NoArgs,
		RunE: func(cmd *cobra.Command, _ []string) error {
			info := versionInfo{Name: appName, Version: version}
			return emit(cmd, info, appName+" "+version)
		},
	}
}
