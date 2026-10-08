// Helper for e2e tests: runs the real program in a separate process.
import { resolve } from "node:path";

const root = resolve(import.meta.dir, "..");

export type Result = { exitCode: number; stdout: string; stderr: string };

export async function run(...args: string[]): Promise<Result> {
  const proc = Bun.spawn([process.execPath, "run", "src/main.ts", ...args], {
    cwd: root,
    stdout: "pipe",
    stderr: "pipe",
  });
  const [stdout, stderr, exitCode] = await Promise.all([
    new Response(proc.stdout).text(),
    new Response(proc.stderr).text(),
    proc.exited,
  ]);
  return { exitCode, stdout, stderr };
}
