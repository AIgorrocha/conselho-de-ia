---
name: claude-worker
description: Run one bounded Claude Code leaf task through the portable PowerShell adapter. Sonnet 5.5 is the authoring default; Opus 5.5 is available for an explicitly requested read-only cross-review.
---

# Claude worker

This optional adapter is for callers that need a constrained Claude CLI
process. A native Claude Code session should use its native subagents instead.

## Requirements and safety

- Windows PowerShell 5.1 or PowerShell 7, Claude CLI authenticated through its
  existing subscription login, and an existing task file and workspace.
- On Windows, the adapter launches the native `claude.exe` through
  `ProcessStartInfo`. It searches PATH for `claude.exe`, then
  `%USERPROFILE%\.local\bin\claude.exe`. It rejects `.ps1`, `.cmd`, and `.bat`
  launch shims because `UseShellExecute` is disabled. Pass
  `-ClaudeExecutable <path-to-native-claude.exe>` when the binary is elsewhere.
  On Unix, it can resolve a native `claude` executable from PATH.
- The caller must authorize any writing. Default is read-only. `-Write` enables
  only Claude's `Edit` and `Write` tools, in addition to `Read`, `Glob`, and
  `Grep`.
- Opus is read-only. The CLI runs restricted, without hooks, MCP servers,
  browser, shell, web tools, agents, or session persistence. API credential
  environment variables are cleared for the child and restored afterward.
- Claude is a leaf worker. No recursive agents or model calls. The caller
  retains integration and final verification.
- Each run has a real process timeout. Default is 180 seconds, adjustable from
  1 to 1800. Max turns defaults to four and is capped at eight. The timeout
  takes precedence and returns process exit code 124.

## Example

Copy `bin/claude-worker.ps1` from this kit to a trusted local tools folder.
Use a dedicated temporary or project workspace, never a folder containing
unrelated client data.

```powershell
powershell -NoProfile -File .\claude-worker.ps1 `
  -TaskFile .\task.md `
  -Workspace .\work `
  -Model claude-sonnet-5-5 `
  -Effort high `
  -MaxTurns 4 `
  -TimeoutSeconds 180
```

Add `-ClaudeExecutable <path-to-native-claude.exe>` on Windows when automatic
discovery does not find the native binary. Windows PowerShell 5.1 is supported;
the target must still be the native executable, not a PowerShell or command
shim.

For explicit authoring authorization, add `-Write`. For an Opus review, set
`-Model claude-opus-5-5`; `-Write` is rejected for that model. Validate the
resolved settings without calling Claude by adding `-DryRun`.
