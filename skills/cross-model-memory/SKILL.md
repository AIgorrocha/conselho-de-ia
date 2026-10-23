---
name: cross-model-memory
description: Coordinate Claude planning, Codex execution and independent Astra review with required shared ai-memory, native leaf agents and optional bounded cross-review.
---

# Cross-model coordination

The user chooses objective and permissions. The course flow selected on
2026-10-23 plans with Claude Opus/Sonnet, passes a sanitized plan to a new Codex
App session for Sol/Luna execution, runs tests, then requests independent Astra
high review. Each phase stays native. Do not run two writers on the same files.
This is a chosen preference, not a universal quality ranking or a requirement
to use two vendors for every small task. Starting in Codex and consulting Claude
through the existing connector is an alternative.

## Native routing

| Main platform | Conductor | Native leaf agents |
|---|---|---|
| Codex | `gpt-6-astra`, high by default; `gpt-6.1-sol`, high when explicitly chosen | `gpt-6.1-sol`, high for medium work; `gpt-6-luna`, high for simple bounded work |
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
  Opus 5.5 high; Claude may ask Codex Astra high. Grok may ask either. One
  bounded review per need. The conductor confronts findings with local source,
  code, tests, or primary evidence.
- Fable is a legacy option only when the user explicitly requests it. It is
  not in default routing.

## Memory and evidence

Shared ai-memory is required in this taught architecture. Installation and
organization are covered in the next lesson; the public memoria/ model is not
an installed server. Without setup, declare the pending layer and use a manual
PASSAGEM.md rehearsal, not a claim of complete architecture. LLM providers and
generative consolidation remain optional.

Current source, tests, configuration, and records outrank old memory. Query a
compatible memory service before work that depends on past decisions. Send
only relevant history. A handoff preserves session continuity; a durable page
records a lasting decision or learning. Follow the memory service's own skill
for writes. Do not put secrets or customer data in prompts or memory without
explicit authorization and the required checks.

MCP connects compatible authorized clients, not every app. memory_query
retrieves history; memory_read_page fetches the full decision. memory_message_send
delivers to another project's inbox only when explicitly authorized by the human.
Memory is not messaging. Namespaces do not provide security isolation, and shared
memory does not automatically transfer conversations, permissions or execution.

The official openai/codex-plugin-cc offers rescue for task delegation and transfer
for importing a reviewed synthetic Claude session into Codex. Review is read-only.
Check availability and runtime; do not assume rescue enables native leaf chains.
Use sanitized PASSAGEM.md and a new Codex App session as the manual fallback.
The plugin is not the memory connection. Never import private transcripts.

Each delegated task names objective, evidence, allowed scope, owner, expected
output, size limit, timeout or turn cap, uncertainty rule, and stopping
condition. Claude external calls default to four turns, max eight for one
coherent bounded package and use a real caller timeout. Grok defaults to four,
max six for measurable bulk work. No loops; two attempts without progress
stop as inconclusive. No model is final authority.
