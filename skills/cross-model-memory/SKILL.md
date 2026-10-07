---
name: cross-model-memory
description: Coordinate platform-native Codex or Claude sessions, optional Grok volume reading, optional read-only cross-review, and a compatible shared memory service without recursive calls.
---

# Cross-model coordination

The user chooses the platform and objective. Keep the main session on the
platform where it started. Do not move task state between active Codex and
Claude work unless requested.

## Native routing

| Main platform | Conductor | Native leaf agents |
|---|---|---|
| Codex | `gpt-6.1-sol`, medium by default, high for complex work | `gpt-6-luna`, high by default, medium for simple bounded work |
| Claude Code | `claude-opus-5-5`, medium by default, high for complex work | `claude-sonnet-5-5`, high by default, medium for simple bounded work |

- Every real work session assigns at least one useful bounded task to a native
  subagent. For small tasks, delegate a meaningful verification.
- The conductor plans briefly, assigns file ownership, uses parallel workers
  only for independent tasks, sequences dependent work, integrates and proves
  the final result.
- Maximum three concurrent children. Leaf workers and cross-reviewers do not
  spawn agents or call another model. No recursive delegation.
- Agent spawning is instruction policy, not an automatic background hook.
  New settings apply to new sessions, not already open ones.

## Optional external calls

- Use `grok-4.7` high for bounded bulk reading, research, normalization,
  comparison, and gaps. Use the `grok-delegation` skill. Textual delegation is
  isolated and read-only, uses the existing subscription OAuth login, and
  requires PTY on Windows. Never use a paid API key fallback. `xhigh` requires
  an explicit complexity reason.
- Cross-review is optional, read-only, and non-recursive. Codex may ask Claude
  Opus 5.5 high; Claude may ask Codex Sol 6.1 high. Grok may ask either. One
  bounded review per need. The conductor confronts findings with local source,
  code, tests, or primary evidence.
- Fable is a legacy option only when the user explicitly requests it. It is
  not in default routing.

## Memory and evidence

Current source, tests, configuration, and records outrank old memory. Query a
compatible memory service before work that depends on past decisions. Send
only relevant history. A handoff preserves session continuity; a durable page
records a lasting decision or learning. Follow the memory service's own skill
for writes. Do not put secrets or customer data in prompts or memory without
explicit authorization and the required checks.

Each delegated task names objective, evidence, allowed scope, owner, expected
output, size limit, timeout or turn cap, uncertainty rule, and stopping
condition. Claude external calls default to four turns, max eight for one
coherent bounded package and use a real caller timeout. Grok defaults to four,
max six for measurable bulk work. No loops; two attempts without progress
stop as inconclusive. No model is final authority.
