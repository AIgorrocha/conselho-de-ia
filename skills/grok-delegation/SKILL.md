---
name: grok-delegation
description: Delegate bounded read-only work to the official Grok CLI on the user's subscription, locked to grok-4.6 at high reasoning (xhigh only for a task that meets the complexity criterion). Use when the user asks to use Grok or when cross-model routing assigns volume, research, comparison, coverage, gap finding, or another task with a verifiable endpoint to Grok. Do not use for final approval or unsupervised source changes.
---

# Grok Delegation

Use Grok as a read-only fork while Codex remains the default conductor and final verifier. If the user explicitly defines another sequence or receiving owner, follow that workflow instead.

This skill governs a textual delegation started by Codex. It does not govern a separate Grok Build terminal assigned as its own dedicated execution terminal. That terminal may edit only its explicitly owned files, but still cannot commit, push, deploy, access credentials, perform destructive work, send anything, or cause another external effect without separate human authorization.

Invoke the official executable directly. Paths below assume the default install locations on Windows; adjust for your own home directory or platform.

```powershell
$delegationRoot = "~\.grok-delegation"
$workingDirectory = Join-Path $delegationRoot "cwd"
$env:GROK_HOME = $delegationRoot
$env:GROK_AUTH_PATH = "~\.grok\auth.json"
$env:HOME = Join-Path $delegationRoot "home"
$env:USERPROFILE = $env:HOME
$env:GROK_MEMORY = "0"
$env:RUST_LOG = "off"
foreach ($sensitiveName in @(
    "AI_MEMORY_AUTH_TOKEN",
    "ANTHROPIC_API_KEY",
    "OPENAI_API_KEY",
    "XAI_API_KEY",
    "GEMINI_API_KEY",
    "GOOGLE_API_KEY",
    "GITHUB_TOKEN",
    "GH_TOKEN",
    "DATABASE_URL",
    "SUPABASE_SERVICE_ROLE_KEY",
    "GROK_AUTH_PROVIDER_COMMAND",
    "GROK_CLI_CHAT_PROXY_BASE_URL",
    "GROK_MODELS_BASE_URL",
    "GROK_LOG_FILE"
)) {
    Remove-Item "Env:$sensitiveName" -ErrorAction SilentlyContinue
}
$maxTurns = 4
$isComplex = $false  # $true only when the task meets the global complexity criterion
$reasoningEffort = if ($isComplex) { 'xhigh' } else { 'high' }
$toolAllowlist = if ($needsWeb) {
    "web_search,web_fetch"
} elseif ($needsEvidenceFiles) {
    "read_file,grep,list_dir"
} else {
    $null
}
$allBuiltInTools = "run_terminal_cmd,grep,read_file,search_replace,list_dir,web_search,web_fetch,todo_write,task"
$grokArgs = @(
    '-p', $task,
    '--model', 'grok-4.6',
    '--reasoning-effort', $reasoningEffort,
    '--permission-mode', 'plan',
    '--sandbox', 'read-only',
    '--no-subagents',
    '--max-turns', "$maxTurns",
    '--output-format', 'json',
    '--no-auto-update',
    '--no-alt-screen',
    '--verbatim',
    '--cwd', $workingDirectory
)
if ($null -ne $toolAllowlist) {
    $grokArgs += @('--tools', $toolAllowlist)
} else {
    $grokArgs += @('--disallowed-tools', $allBuiltInTools)
}
if (-not $needsWeb) {
    $grokArgs += '--disable-web-search'
}
& '~\.grok\bin\grok.exe' @grokArgs
```

On Windows inside Codex, the `exec_command` invocation must set `tty: true`. Grok 1.0.5 can return no captured stdout through the non-PTY Codex pipe even when the executable and login are healthy. PTY output can contain terminal control bytes around the JSON. Strip ANSI bytes and parse the complete object from the first `{` through the last `}`. Version 1.0.5 returns final response in the top-level `text` field, with `stopReason`, `usage`, `num_turns` and `modelUsage` beside it. An empty or unparsable object is a runtime failure, never a review result.

Never pass `--tools ""`. Grok 1.0.5 ignores an empty allowlist and restores its default toolset. A tool-free review must pass `--disallowed-tools` with every official built-in ID: `run_terminal_cmd`, `grep`, `read_file`, `search_replace`, `list_dir`, `web_search`, `web_fetch`, `todo_write` and `task`. Keep `--no-subagents` as a second boundary.

Textual delegation always runs under `~\.grok-delegation`, outside every Git worktree. Never point `--cwd` at the source repository. Prefer an embedded evidence pack. For a larger sanitized corpus, place only the allowlisted files under the isolated `cwd`, set `$needsEvidenceFiles = $true`, and keep source names, clients, credentials, secrets, gitignored files, and raw transcripts out. Do not grant shell or write tools. The OAuth subscription is referenced through `GROK_AUTH_PATH`; never copy or print `auth.json`, and clear `XAI_API_KEY` so the call cannot switch to metered API auth.

The isolated profile has no active global rules, skills, MCP, memory, telemetry, trace upload, codebase index, environment-file loading, or repository access. A measured one-turn smoke test fell from roughly 20,600 to 11,500 total tokens after isolating the profile. Fixed context is still material, so avoid microcalls and use one bounded call for a useful corpus and measurable endpoint.

Every `$task` must be self-contained and include one primary question, an allowlist of files or sources, the expected deliverable, an 800-word default cap, evidence requirements, and stopping conditions. Include this stagnation rule: stop inconclusive after two consecutive turns without a new source, finding, count, or objective reduction of the gap. Never include secrets or full transcripts.

Use one call per independent subtask by default. Four turns is the default ceiling. Six turns is the absolute ceiling and is allowed only for bulk research with a defined universe, measurable endpoint, and source cap. Split larger work before launch. Do not use eight turns.

A second call for the same subtask requires a verifiable runtime failure or a named missing evidence item. Narrow the second scope by at least half or target only that missing item. Never repeat a broad prompt. Up to three calls may run concurrently only when scopes and evidence do not overlap.

Grok should process the large corpus and return only counts, concise findings, gaps, and source references. Do not inject raw corpus or long Grok output into Codex. Treat a contradictory answer, missing verdict, interrupted run, or max-turn stop as incomplete.

Do not use workspace discovery for a small independent code review. If the user explicitly requests Grok review, Codex prepares a diff or evidence pack of at most 20,000 characters and requests one response without repository tools. Otherwise Codex reviews the small local change because it has lower total cost.

Use the JSON result to record `num_turns`, duration, outcome, and `modelUsage` token fields when present. A missing cost field is unknown, not zero. Do not enable external telemetry or prompt logging for this accounting.

Keep `--permission-mode plan` and `--sandbox read-only` unless the user explicitly authorizes Grok to write. Codex, or the receiving owner explicitly chosen by the user, confronts the result with current code, data, tests, or primary sources before integrating it.

If authentication fails, stop and report the gap. Do not fall back to another Grok model, a metered API key, reasoning below high, or the community bridge without the user's authorization.
