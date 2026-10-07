---
name: fable-advisor
description: Legacy connector, outside default routing. Use only if the user explicitly requests Fable and accepts that its availability has not been validated for the current architecture.
---

# Legacy Fable connector

Retired from the default architecture on 2026-10-07. Do not select it for
planning, implementation, routine review, or mandatory final judgment.
The user must explicitly request Fable before this legacy connector is used.

The active architecture uses platform-native agents and optional read-only
cross-review through `claude-worker`. Prefer that documented route unless the
user explicitly chose this legacy model. Never silently substitute a model.

## Legacy invocation

Only from a complete copy of this kit:

```powershell
.\bin\fable-advisor.cmd "One bounded read-only question"
```

The wrapper requires `config/claude-nohooks.json` beside the kit's bin
folder and fails closed if that file is missing. It launches the existing
native Claude executable under the user's `.local/bin` directory. It disables
hooks, MCP discovery, browser, session persistence, edits, shell and agent
tools, and clears Anthropic API overrides for the child invocation.

The historical model ID is `claude-fable-5-1`, effort high, four requested
turns. This route is not part of the current runtime smoke tests. The caller
must impose its own wall-clock cap before use; the wrapper's turn limit is
not a hard time or spending limit. Do not send secrets or client data.

Return evidence, uncertainty and a verdict in at most 400 words. The native
conductor verifies the claims against source and tests. The legacy model
never approves publication or irreversible actions. No loops or redelegation.
