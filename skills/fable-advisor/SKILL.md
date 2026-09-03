---
name: fable-advisor
description: Delegate rare, bounded, read-only judgment to the official Claude Code CLI using Fable 5.1 at high effort. Use only when the Codex conductor needs holistic interpretation, adversarial critique, narrative, copy, human experience analysis, or a difficult conceptual decision. Do not use for bulk research, continuous authorship, source changes, or final approval.
---

# Fable Advisor

Codex is the default conductor and Fable is normally a rare read-only advisor. The user may explicitly start with Fable, assign planning to Fable, or define another bounded sequence between models.

## Fixed runtime

- CLI: `~\.local\bin\claude.exe` (adjust for your own install path or platform)
- Model: `claude-fable-5-1`
- Effort: `high` (never `max` by default)
- Permission mode: `default`, with an explicit read-only tool allowlist
- MCPs: none by default
- Browser: disabled
- Session persistence: disabled

Do not substitute Sonnet, Opus, another model, or another effort level unless the user explicitly authorizes it.

## Invocation

Build one self-contained task with objective, evidence, constraints, requested output, word cap, and stopping condition. Then run:

```powershell
$emptyMcp = '{"mcpServers":{}}'
& '~\.local\bin\claude.exe' -p $task `
  --model claude-fable-5-1 `
  --effort high `
  --permission-mode default `
  --allowedTools "Read,Glob,Grep" `
  --disallowedTools "Edit,Write,NotebookEdit,Bash,WebFetch,WebSearch,Task,Skill" `
  --mcp-config $emptyMcp `
  --strict-mcp-config `
  --no-chrome `
  --no-session-persistence
```

When local evidence is needed, give exact paths and permit only read-oriented tools. Do not use plan mode for these calls because it may create a plan artifact. Never include credentials or unrestricted directories.

## Contract

1. By default, Fable interprets or critiques. When the user explicitly assigns planning or spec ownership to Fable, it may own that phase. It still does not publish, approve, or make an irreversible decision without explicit human authorization.
2. Use one bounded call per independent question. Do not open an ongoing advisory conversation.
3. Default output cap is 800 words. Fable receives assembled evidence, never a bulk corpus or an open-ended research assignment.
4. Do not retry unless the runtime failed or source confrontation exposes one named evidence gap. Never repeat the same broad prompt.
5. Require claims to cite the supplied evidence and mark uncertainty.
6. Codex checks the answer against source, code, data, tests, calculations, and rules before using it.
7. If Fable conflicts with evidence, evidence wins. If the decision is irreversible, public, financial, legal, destructive, or identity-related, stop for human authorization.
