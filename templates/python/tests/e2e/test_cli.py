"""End-to-end tests: run the installed program and assert on exit code, stdout and stderr.

Fast tests run on every commit (`task test`).
Mark slow ones with `@pytest.mark.full`: they only run in `task e2e`.
"""

import json
import shutil
import subprocess

import pytest

APP = "projectname"


def run(*args: str) -> subprocess.CompletedProcess[str]:
    exe = shutil.which(APP)
    assert exe, f"{APP} is not installed in this environment, run `task setup`"
    return subprocess.run([exe, *args], capture_output=True, text=True, check=False, timeout=30)


def test_version_prints_human_form() -> None:
    result = run("version")
    assert result.returncode == 0
    assert result.stdout.startswith(f"{APP} ")
    assert result.stderr == ""


def test_version_json_is_one_document() -> None:
    result = run("version", "--json")
    assert result.returncode == 0
    doc = json.loads(result.stdout)
    assert doc["name"] == APP
    assert doc["version"]
    assert result.stderr == ""


@pytest.mark.full
def test_json_flag_works_before_the_command() -> None:
    result = run("--json", "version")
    assert result.returncode == 0
    assert json.loads(result.stdout)["name"] == APP


@pytest.mark.full
def test_unknown_command_fails_with_message_on_stderr() -> None:
    result = run("no-such-command")
    assert result.returncode == 1
    assert result.stderr.startswith("error: ")
    assert result.stdout == ""


@pytest.mark.full
def test_unknown_command_with_json_reports_json_error() -> None:
    result = run("no-such-command", "--json")
    assert result.returncode == 1
    assert isinstance(json.loads(result.stderr)["error"], str)
    assert result.stdout == ""
