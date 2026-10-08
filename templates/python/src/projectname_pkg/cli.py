"""Command tree and output handling. One function per command."""

import argparse
import json
import sys
from importlib.metadata import version as package_version
from typing import Any, NoReturn

APP_NAME = "projectname"


class CliError(Exception):
    """An expected failure. The message is shown to the user without a traceback."""


class _Parser(argparse.ArgumentParser):
    def error(self, message: str) -> NoReturn:
        # argparse would print usage and exit(2). Raise instead, so main() reports it.
        raise CliError(message)


def build_parser() -> argparse.ArgumentParser:
    # --json is accepted before and after the command name.
    shared = _Parser(add_help=False)
    shared.add_argument(
        "--json",
        action="store_true",
        default=argparse.SUPPRESS,
        help="machine-readable JSON output",
    )

    parser = _Parser(prog=APP_NAME, description="TODO: one line description", parents=[shared])
    commands = parser.add_subparsers(dest="command", required=True, metavar="<command>")

    # Register commands here, one block per command.
    version = commands.add_parser("version", help="print the version", parents=[shared])
    version.set_defaults(run=cmd_version)

    return parser


def cmd_version(args: argparse.Namespace) -> None:
    version = package_version(APP_NAME)
    emit(args, {"name": APP_NAME, "version": version}, f"{APP_NAME} {version}")


def emit(args: argparse.Namespace, value: Any, human: str) -> None:
    """Write the result of a command to stdout: JSON with --json, otherwise the human text."""
    if getattr(args, "json", False):
        print(json.dumps(value))
    else:
        print(human)


def print_error(as_json: bool, message: str) -> None:
    """Write an error to stderr, as {"error": "..."} with --json."""
    if as_json:
        print(json.dumps({"error": message}), file=sys.stderr)
    else:
        print(f"error: {message}", file=sys.stderr)


def main(argv: list[str] | None = None) -> int:
    """Parse the arguments, run the command and return the process exit code."""
    argv = sys.argv[1:] if argv is None else argv
    # Checked on the raw arguments so that parse errors can honor --json too.
    as_json = "--json" in argv
    try:
        args = build_parser().parse_args(argv)
        args.run(args)
    except CliError as err:
        print_error(as_json, str(err))
        return 1
    return 0
