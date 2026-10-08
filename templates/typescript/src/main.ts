#!/usr/bin/env bun
// Program entry point. All logic lives in the modules.
import { main } from "./cli.ts";

process.exit(await main(process.argv.slice(2)));
