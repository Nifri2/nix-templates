// End-to-end smoke tests. Files in e2e/smoke/ run on every commit (`task test`).
import { expect, test } from "bun:test";
import pkg from "../../package.json" with { type: "json" };
import { run } from "../run.ts";

test("version prints the human form", async () => {
  const result = await run("version");
  expect(result.exitCode).toBe(0);
  expect(result.stdout).toBe(`${pkg.name} ${pkg.version}\n`);
  expect(result.stderr).toBe("");
});

test("version --json prints one JSON document", async () => {
  const result = await run("version", "--json");
  expect(result.exitCode).toBe(0);
  expect(JSON.parse(result.stdout)).toEqual({ name: pkg.name, version: pkg.version });
  expect(result.stderr).toBe("");
});
