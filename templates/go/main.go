// Command projectname is the program entry point. All logic lives in internal/.
package main

import (
	"os"

	"projectname/internal/cli"
)

// version is set at build time: -ldflags "-X main.version=...".
var version = "dev"

func main() {
	os.Exit(cli.Main(version))
}
