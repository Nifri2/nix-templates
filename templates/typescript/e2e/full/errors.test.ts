// Full e2e suite. Files in e2e/full/ only run in `task e2e`.
import { expect, test } from "bun:test";
import { run } from "../run.ts";

test("unknown command fails with a message on stderr", async () => {
  const result = await run("no-such-command");
  expect(result.exitCode).toBe(1);
  expect(result.stderr).toStartWith("error: unknown command");
  expect(result.stdout).toBe("");
});

test("unknown command with --json reports a JSON error", async () => {
  const result = await run("no-such-command", "--json");
  expect(result.exitCode).toBe(1);
  expect(typeof JSON.parse(result.stderr).error).toBe("string");
  expect(result.stdout).toBe("");
});

test("--json is accepted before the command", async () => {
  const result = await run("--json", "version");
  expect(result.exitCode).toBe(0);
  expect(JSON.parse(result.stdout).name).toBeString();
});
