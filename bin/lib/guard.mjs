#!/usr/bin/env node
// PreToolUse hook for `factory run`: blocks any tool call the command's allowed-tools wouldn't
// permit, exactly as GitHub Actions would, and tells Claude what to use instead.
// usage (in hook settings): node guard.mjs <command.md>
import { loadRules, check } from './allow.mjs';

let raw = '';
for await (const chunk of process.stdin) raw += chunk;
const event = JSON.parse(raw || '{}');
const denied = check(loadRules(process.argv[2]), event.tool_name, event.tool_input);
if (denied) {
  process.stderr.write(
    `Blocked by the factory allowlist (the same call is denied in GitHub Actions): ${denied}. ` +
      'Edit files with the Edit/Write tools and use only the commands this task allows.',
  );
  process.exit(2);
}
