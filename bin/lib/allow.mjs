// The factory's model of Claude Code permissions for a plugin command: which tool calls the
// command's `allowed-tools` frontmatter permits. Shared by the local guard hook (enforces it)
// and report.mjs (audits a transcript), so local runs behave like GitHub Actions.
import { readFileSync } from 'node:fs';

// Tools Claude Code allows without a rule, and read-only shell commands it auto-approves.
const alwaysOk = new Set(['TodoWrite', 'TaskCreate', 'TaskUpdate', 'TaskList', 'TaskGet', 'ToolSearch', 'Skill', 'LS', 'BashOutput']);
const readOnlyShell = ['cd', 'pwd', 'echo', 'true', 'test', '[', 'wc', 'sort', 'uniq', 'which', 'grep', 'find', 'diff', 'sed -n', 'head', 'tail', 'cat', 'ls', 'stat', 'file'];

export function loadRules(commandPath) {
  const front = readFileSync(commandPath, 'utf8').match(/^---\n([\s\S]*?)\n---/)?.[1] ?? '';
  const line = front.match(/^allowed-tools:\s*(.+)$/m)?.[1] ?? '';
  const allowed = line.split(/,\s*(?![^(]*\))/).map((s) => s.trim()).filter(Boolean);
  return {
    tools: new Set(allowed.filter((a) => !a.includes('('))),
    bash: allowed.map((a) => a.match(/^Bash\((.+?)(?::\*|\s\*)?\)$/)?.[1]).filter(Boolean),
  };
}

function bashOk(rules, cmd) {
  // Each part of a compound command must be allowed. Quoted strings are blanked first so
  // `grep "a\|b"` isn't mistaken for a pipe; heredoc bodies are dropped.
  const unquoted = cmd.replace(/<<-?\s*'?(\w+)'?[\s\S]*?\n\1\b/g, '').replace(/'[^']*'|"(?:\\.|[^"\\])*"/g, '""');
  const parts = unquoted.split(/&&|\|\||;|\|(?!\|)|\n/).map((p) => p.trim()).filter(Boolean);
  return parts.every((p) => {
    const bare = p.replace(/^(\w+=\S+\s+)+/, '').replace(/^\(+|\)+$/g, '').trim();
    if (!bare || bare.startsWith('#')) return true;
    // Writing files through redirection needs Edit/Write; only /dev/null and fd duplication are fine.
    if (/(^|[^0-9&<])\d*>>?\s*(?!&|\/dev\/null)\S/.test(bare)) return false;
    return [...rules.bash, ...readOnlyShell].some((pre) => bare === pre || bare.startsWith(pre + ' '));
  });
}

/** Returns null when allowed, or a short description of the denied call. */
export function check(rules, name, input = {}) {
  if (name === 'Bash') return bashOk(rules, input.command ?? '') ? null : `Bash: ${String(input.command).split('\n')[0].slice(0, 160)}`;
  if (rules.tools.has(name) || alwaysOk.has(name) || name.startsWith('mcp__github')) return null;
  return name;
}
