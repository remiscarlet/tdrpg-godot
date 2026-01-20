---
id: refresh-context
name: Refresh Context
version: 0.1
last_verified: 2026-01-20
scope: repo-wide
dependencies: []
outputs: []
---

# Skill: Refresh Context

## Purpose
Reload project context by reading root `AGENTS.md` and all files under `docs/agent/` on explicit user request.

## When to Use
- The user explicitly asks to "refresh context", "reload context", "refresh your context", or similar.
- Use context clues for explicit refresh intent (e.g., "Before we start, refresh context").

Do NOT use when:
- The user asks about a specific file only (e.g., "What's in AGENTS.md?").
- The user is asking general project questions without a refresh request.

## Inputs (Required)
- Explicit user request to refresh or reload context.

## Outputs (Required)
- None (context reload only).

## Procedure
1) Read root `AGENTS.md`.
2) Enumerate all files under `docs/agent/` (recursive).
3) Read each file under `docs/agent/`.
4) Briefly confirm completion to the user.

## Guardrails
- If the request is ambiguous, ask once for confirmation.
- Do not read outside repo root.
- Keep it lightweight: only read `AGENTS.md` and `docs/agent/**`.
