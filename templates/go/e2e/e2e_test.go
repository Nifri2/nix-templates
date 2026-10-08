// Package e2e runs the real program end to end with testscript.
//
// Each .txtar file under testdata/ is one scenario: commands plus assertions
// on exit code, stdout and stderr. To add a test, add a file. No Go needed.
//
//	testdata/smoke/  fast, runs on every commit (task test)
//	testdata/full/   everything else (task e2e)
package e2e

import (
	"os"
	"testing"

	"github.com/rogpeppe/go-internal/testscript"

	"projectname/internal/cli"
)

func TestMain(m *testing.M) {
	// Registers the program under its name, so scripts can call `exec projectname ...`.
	// It runs the same cli.Main as main.go, in a separate process.
	testscript.Main(m, map[string]func(){
		"projectname": func() { os.Exit(cli.Main("test")) },
	})
}

func TestSmoke(t *testing.T) {
	testscript.Run(t, testscript.Params{Dir: "testdata/smoke"})
}

func TestFull(t *testing.T) {
	if testing.Short() {
		t.Skip("full e2e suite is skipped in -short mode, run `task e2e`")
	}
	testscript.Run(t, testscript.Params{Dir: "testdata/full"})
}
