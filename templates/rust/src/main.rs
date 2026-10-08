//! Program entry point. All logic lives in the modules.

mod cli;

use std::process::ExitCode;

fn main() -> ExitCode {
    cli::run()
}
