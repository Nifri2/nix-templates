// Command tree and output handling. One function per command.
import pkg from "../package.json" with { type: "json" };

const APP_NAME = pkg.name;
const VERSION = pkg.version;

/** An expected failure. The message is shown to the user without a stack trace. */
export class CliError extends Error {}

type Context = { json: boolean; args: string[] };
type Command = { summary: string; run: (ctx: Context) => void | Promise<void> };

// Register commands here, one entry per command.
const commands: Record<string, Command> = {
  version: { summary: "print the version", run: version },
};

function version(ctx: Context): void {
  emit(ctx, { name: APP_NAME, version: VERSION }, `${APP_NAME} ${VERSION}`);
}

/** Writes the result of a command to stdout: JSON with --json, otherwise the human text. */
function emit(ctx: Context, value: unknown, human: string): void {
  console.log(ctx.json ? JSON.stringify(value) : human);
}

/** Writes an error to stderr, as {"error": "..."} with --json. */
function printError(json: boolean, message: string): void {
  console.error(json ? JSON.stringify({ error: message }) : `error: ${message}`);
}

function usage(): string {
  const lines = Object.entries(commands).map(([name, cmd]) => `  ${name.padEnd(12)}${cmd.summary}`);
  return [
    `usage: ${APP_NAME} <command> [--json]`,
    "",
    "commands:",
    ...lines,
    "",
    "options:",
    "  --json      machine-readable JSON output",
  ].join("\n");
}

/** Parses the arguments, runs the command and returns the process exit code. */
export async function main(argv: string[]): Promise<number> {
  // --json is accepted before and after the command name.
  const json = argv.includes("--json");
  const [name, ...args] = argv.filter((arg) => arg !== "--json");

  try {
    if (name === "--help" || name === "-h") {
      console.log(usage());
      return 0;
    }
    if (name === undefined) {
      throw new CliError("missing command, see --help");
    }
    const command = commands[name];
    if (command === undefined) {
      throw new CliError(`unknown command '${name}', see --help`);
    }
    await command.run({ json, args });
    return 0;
  } catch (err) {
    if (err instanceof CliError) {
      printError(json, err.message);
      return 1;
    }
    throw err;
  }
}
