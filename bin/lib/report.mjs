#!/usr/bin/env node
// Reads a `claude -p --output-format stream-json` transcript from a factory run and reports:
//   - the final result and its FACTORY_RESULT line
//   - turns and cost
//   - every tool call the command's `allowed-tools` would NOT have permitted.
// Locally Claude may run with looser permissions than in GitHub Actions, so this audit is how a
// local run proves the same work would have been allowed there.
//
// usage: report.mjs <transcript.jsonl> <command.md>
// exit:  0 done and clean, 1 blocked/failed/missing result, 2 permission gaps
import { readFileSync } from 'node:fs';
import { loadRules, check } from './allow.mjs';

const [transcriptPath, commandPath] = process.argv.slice(2);
const lines = readFileSync(transcriptPath, 'utf8').split('\n').filter(Boolean);
const events = lines.flatMap((l) => {
  try { return [JSON.parse(l)]; } catch { return []; }
});

const rules = loadRules(commandPath);

const gaps = [];
const toolCounts = {};
for (const e of events) {
  if (e.type !== 'assistant') continue;
  for (const c of e.message?.content ?? []) {
    if (c.type !== 'tool_use') continue;
    toolCounts[c.name] = (toolCounts[c.name] ?? 0) + 1;
    const denied = check(rules, c.name, c.input);
    if (denied) gaps.push(denied);
  }
}

const result = events.findLast((e) => e.type === 'result');
const text = result?.result ?? '';
const status = text.match(/FACTORY_RESULT:\s*(.*)$/m)?.[1]?.trim() ?? '(no FACTORY_RESULT line)';

console.log('──────── agent summary ────────');
console.log(text.trim() || '(no result text)');
console.log('──────── run stats ────────');
console.log(`result:     ${status}`);
console.log(`turns:      ${result?.num_turns ?? '?'}   cost: $${(result?.total_cost_usd ?? 0).toFixed(2)} (API-equivalent)   time: ${Math.round((result?.duration_ms ?? 0) / 1000)}s`);
console.log(`tools:      ${Object.entries(toolCounts).map(([k, v]) => `${k}×${v}`).join(' ') || 'none'}`);
if (gaps.length) {
  console.log(`permission gaps (would be denied in GitHub Actions; add to allowed-tools or change the prompt):`);
  for (const g of [...new Set(gaps)]) console.log(`  - ${g}`);
} else {
  console.log('permissions: every tool call is covered by allowed-tools');
}

if (!result || result.is_error || !/^done\b/.test(status)) process.exit(1);
if (gaps.length) process.exit(2);
