---
id: save-todos
name: Save Hot TODOs
version: 0.1
last_verified: 2026-01-20
dependencies: []
outputs:
  - "docs/TODOS.md"
---

# Skill: Save Hot TODOs

## Purpose
Capture lightweight, informal TODO or reminder lines into `docs/TODOS.md` so they stay visible and easy to summarize.

## When to Use
- The user explicitly asks to "save a todo", "write a reminder", "add to hot TODOs", or similar.
- During or after discussions when the intent is clearly to record an action item, not to generate reminder text for external use.
- Do **not** trigger for offhand mentions like "we'll want to remember to..." unless the user directs Codex to store it.

## Inputs (Required)
- The TODO/reminder text. Include any useful context (scope, file/module, owner) if provided.

## Outputs (Required)
- New entry appended to `docs/TODOS.md` following the format below.

## Procedure
1) Confirm the item is meant to be stored (explicit request). If ambiguous, ask once for confirmation.
2) Normalize into a single-line Markdown checklist entry:
   - Format: `- [ ] <concise action> — <context/why if given> (added YYYY-MM-DD)`
   - Keep on one line; drop fluff; retain key nouns and constraints.
3) Append the entry to the end of `docs/TODOS.md`.
4) If multiple items, add one line per item.
5) Echo back the added lines to the user.

## Notes
- Leave unchecked boxes (`[ ]`)—completion is tracked elsewhere.
- If the user asks to mark an item done, add a new line with `[x]` and date; do not delete history unless instructed.
