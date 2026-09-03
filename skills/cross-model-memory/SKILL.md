---
name: cross-model-memory
description: Coordinate Codex, Grok 4.6 high, Claude Fable 5.1 high, and a shared memory MCP across sessions without uncontrolled recursive model calls. Use when a task needs cross-model handoff, shared project history, memory verification, or bounded multi-model work. Codex is the default conductor unless the user explicitly chooses another order or owner.
---

# Cross-Model Memory

Note: this skill was written against a specific memory MCP server called `ai-memory` in the author's own setup. `ai-memory` is not part of this kit; it is simply the author's cross-session memory server. Any MCP-compatible memory server (vector store, note database, or similar) can fill the same role. Replace the tool name below with whichever memory MCP you actually run.

The three-role architecture (conductor, volume, judgment) is the automatic default, not an obligation. Without a user override, Codex owns decomposition, source changes, integration, evidence checks, and closure. The user's explicit workflow may change the starting model, order, phase owner, or receiving model.

## Routing

1. Follow an explicit user-defined sequence first. A valid example is Fable planning, Codex implementation, then Grok coverage or review.
2. Otherwise, send volume, coverage, comparison, research, and gap finding to `grok-delegation`.
3. Otherwise, send rare holistic interpretation, adversarial critique, narrative, copy, and hard conceptual judgment to `fable-advisor`.
4. Keep implementation and final verification in Codex by default.
5. Avoid recursive or self-directed model calls. A user-defined sequence may include multiple models when every transition has an explicit owner, bounded scope, and observable endpoint.

## Shared memory

Current code, tests, configuration, databases, and source artifacts override historical memory.

Before delegating a task that depends on history, query your memory MCP and include only the minimum relevant context in the task. Prefer a handoff when another session or model must resume work. Do not copy full transcripts into prompts.

For Grok, always state the exact workspace, project, and scope in the prompt for a memory query or handoff call. Its HTTP MCP has no implicit project context.

For Claude memory retrieval, do not use permission mode `plan`. Plan mode blocks MCP calls and may create a plan file. Start a one-shot Fable 5.1 high session with:

- permission mode `manual`
- `--strict-mcp-config`
- one temporary MCP configuration containing only your memory server
- the memory server's auth token referenced from the environment, never embedded
- only `ToolSearch` and the named read-only memory tool allowed
- Bash, Edit, Write, NotebookEdit, WebFetch, WebSearch, Task, and Skill denied
- browser and session persistence disabled

After the read, discard temporary configuration and any test-only page. A durable page, learning, deletion, or shared handoff requires the corresponding memory-server skill and the user's authorization.

## Evidence contract

Every delegated task must specify the objective, supplied evidence, expected output, size limit, uncertainty rule, and stopping condition. Codex compares the result with primary evidence before accepting it. Human authorization remains mandatory for irreversible, public, financial, legal, destructive, or identity-related actions.
