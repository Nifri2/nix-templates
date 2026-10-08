//! Command tree and output handling. One function per command.

use std::error::Error;
use std::process::ExitCode;

use clap::{Parser, Subcommand};
use serde::Serialize;

const APP_NAME: &str = env!("CARGO_PKG_NAME");
const VERSION: &str = env!("CARGO_PKG_VERSION");

type CmdResult = Result<(), Box<dyn Error>>;

#[derive(Parser)]
#[command(name = APP_NAME, about = "TODO: one line description")]
struct Cli {
    /// Machine-readable JSON output
    #[arg(long, global = true)]
    json: bool,

    #[command(subcommand)]
    command: Command,
}

// Register commands here, one variant per command.
#[derive(Subcommand)]
enum Command {
    /// Print the version
    Version,
}

#[derive(Serialize)]
struct VersionInfo {
    name: &'static str,
    version: &'static str,
}

/// Parses the arguments, runs the command and returns the process exit code.
pub fn run() -> ExitCode {
    // Checked on the raw arguments so that parse errors can honor --json too.
    let json = std::env::args().skip(1).any(|arg| arg == "--json");

    let cli = match Cli::try_parse() {
        Ok(cli) => cli,
        // --help and similar: clap prints to stdout, this is not a failure.
        Err(err) if !err.use_stderr() => {
            let _ = err.print();
            return ExitCode::SUCCESS;
        }
        Err(err) => {
            let text = err.to_string();
            let first = text.lines().next().unwrap_or("invalid arguments");
            print_error(json, first.trim_start_matches("error: "));
            return ExitCode::FAILURE;
        }
    };

    let result = match cli.command {
        Command::Version => version(cli.json),
    };

    match result {
        Ok(()) => ExitCode::SUCCESS,
        Err(err) => {
            print_error(cli.json, &err.to_string());
            ExitCode::FAILURE
        }
    }
}

fn version(json: bool) -> CmdResult {
    let info = VersionInfo {
        name: APP_NAME,
        version: VERSION,
    };
    emit(json, &info, &format!("{APP_NAME} {VERSION}"))
}

/// Writes the result of a command to stdout: `value` as one JSON document
/// when --json is set, otherwise the human readable text.
fn emit<T: Serialize>(json: bool, value: &T, human: &str) -> CmdResult {
    if json {
        println!("{}", serde_json::to_string(value)?);
    } else {
        println!("{human}");
    }
    Ok(())
}

/// Writes an error to stderr, as {"error": "..."} when --json is set.
fn print_error(json: bool, message: &str) {
    if json {
        eprintln!("{}", serde_json::json!({ "error": message }));
    } else {
        eprintln!("error: {message}");
    }
}
