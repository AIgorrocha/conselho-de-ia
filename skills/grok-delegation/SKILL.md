---
name: grok-delegation
description: Delegate bounded, read-only bulk reading, research, normalization, comparisons, and gap finding to the official Grok CLI using its existing subscription login. Uses grok-4.7 high by default; xhigh needs an explicit complexity reason. Never falls back to a paid API key.
---

# Grok delegation

Use Grok 4.7 for bounded volume work. The calling conductor owns scope,
integration, and final verification. This skill covers textual delegation,
not a dedicated terminal where the user explicitly assigned Grok file edits.

## Invocation boundaries

- Use the official Grok CLI and its existing subscription OAuth login. Do not
  create, copy, print, or fall back to an API key or metered endpoint.
- Run in an isolated profile outside the source repository. Pass only a
  sanitized evidence pack or allowlisted copies. Read-only, no shell, no
  subagents, no repository discovery, no MCP or inherited project environment.
- On Windows, invoke through a PTY (`tty: true`). Empty output without PTY is
  a runtime failure. Remove ANSI control codes before parsing JSON.
- Default `grok-4.7`, `high`, four turns. `xhigh` only with a written reason
  tied to task complexity. Maximum six turns for bounded bulk work.
- Caller sets a wall-clock timeout. One call per subtask; retry only after a
  verifiable runtime failure or a named evidence gap, with smaller scope.
- Never send secrets, client data, full transcripts, or personal filesystem
  paths. A missing verdict or max-turn stop is incomplete, not approval.

## PowerShell outline

Adjust the CLI discovery and isolated root for your platform. `GROK_AUTH_PATH`
references the existing interactive subscription login; never copy its file.

```powershell
$delegationRoot = Join-Path $env:USERPROFILE ".grok-delegation"
$workingDirectory = Join-Path $delegationRoot "cwd"
$isolatedProfile = Join-Path $delegationRoot "home"
New-Item -ItemType Directory -Path $delegationRoot, $workingDirectory, $isolatedProfile -Force | Out-Null
$env:GROK_HOME = $delegationRoot
$env:GROK_AUTH_PATH = Join-Path $env:USERPROFILE ".grok\auth.json"
$env:USERPROFILE = $isolatedProfile
$env:GROK_MEMORY = "0"
$env:RUST_LOG = "off"
foreach ($name in @(
    "XAI_API_KEY", "ANTHROPIC_API_KEY", "OPENAI_API_KEY", "GEMINI_API_KEY",
    "GOOGLE_API_KEY", "GITHUB_TOKEN", "GH_TOKEN", "DATABASE_URL"
)) {
    Remove-Item "Env:$name" -ErrorAction SilentlyContinue
}

$grok = (Get-Command grok -ErrorAction Stop).Source
$maxTurns = 4
$reasoningEffort = "high" # use xhigh only with a written complexity reason
$argsList = @(
    "-p", $task,
    "--model", "grok-4.7",
    "--reasoning-effort", $reasoningEffort,
    "--permission-mode", "plan",
    "--sandbox", "read-only",
    "--no-subagents",
    "--max-turns", "$maxTurns",
    "--output-format", "json",
    "--no-auto-update",
    "--no-alt-screen",
    "--cwd", $workingDirectory,
    "--disallowed-tools",
    "run_terminal_cmd,grep,read_file,search_replace,list_dir,web_search,web_fetch,todo_write,task",
    "--disable-web-search"
)
& $grok @argsList
```

For a web-only lookup or an evidence pack, replace the denylist with a
task-specific allowlist containing only `web_search,web_fetch` or
`read_file,grep,list_dir` through `--tools`. For web lookup also remove
`--disable-web-search`; keep shell, edits, and agent tools denied. Never pass
an empty `--tools` value. On Windows,
the shell invocation must enable PTY. Put the complete evidence and question
in one bounded prompt; do not expose the source repository as `--cwd`.

## Deliverable and verification

Ask for a short verdict, counts, findings, gaps, and source references. Default
answer cap is 400 words. Stop after two consecutive turns with no new source,
finding, count, or measurable reduction of the gap. Record `num_turns`,
duration, outcome, and token fields when present; missing cost is unknown.
The conductor checks claims against primary evidence before integrating them.

## Model catalogue

If the isolated profile reports `unknown model id`, inspect `grok models` in
the interactive and isolated profiles before retrying. A fresh profile may
have an outdated catalogue. If the interactive catalogue already offers 4.7,
refresh the isolated catalogue using the CLI or copy only its verified model
metadata cache. Never copy authentication files or downgrade to another model
silently. Stop if 4.7 is unavailable for the authenticated subscription.
