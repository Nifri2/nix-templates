//! End-to-end tests: run the real binary and assert on exit code, stdout and stderr.
//!
//! Fast tests run on every commit (`task test`).
//! Mark slow ones with `#[ignore = "full"]`: they only run in `task e2e`.

use assert_cmd::Command;
use serde_json::Value;

const NAME: &str = env!("CARGO_PKG_NAME");
const VERSION: &str = env!("CARGO_PKG_VERSION");

fn bin() -> Command {
    Command::new(env!("CARGO_BIN_EXE_projectname"))
}

fn text(bytes: &[u8]) -> String {
    String::from_utf8(bytes.to_vec()).expect("output is valid utf-8")
}

#[test]
fn version_prints_human_form() {
    let out = bin().arg("version").assert().success().get_output().clone();
    assert_eq!(text(&out.stdout), format!("{NAME} {VERSION}\n"));
    assert!(out.stderr.is_empty());
}

#[test]
fn version_json_is_one_document() {
    let out = bin()
        .args(["version", "--json"])
        .assert()
        .success()
        .get_output()
        .clone();
    let doc: Value = serde_json::from_slice(&out.stdout).expect("stdout is JSON");
    assert_eq!(doc["name"], NAME);
    assert_eq!(doc["version"], VERSION);
    assert!(out.stderr.is_empty());
}

#[test]
#[ignore = "full"]
fn unknown_command_fails_with_message_on_stderr() {
    let out = bin()
        .arg("no-such-command")
        .assert()
        .failure()
        .get_output()
        .clone();
    assert!(text(&out.stderr).starts_with("error: "));
    assert!(out.stdout.is_empty());
}

#[test]
#[ignore = "full"]
fn unknown_command_with_json_reports_json_error() {
    let out = bin()
        .args(["no-such-command", "--json"])
        .assert()
        .failure()
        .get_output()
        .clone();
    let doc: Value = serde_json::from_slice(&out.stderr).expect("stderr is JSON");
    assert!(doc["error"].is_string());
    assert!(out.stdout.is_empty());
}
