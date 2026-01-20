---
id: remove-todos
name: Remove Hot TODOs
version: 0.1
last_verified: 2026-01-20
dependencies: []
outputs:
  - "docs/TODOS.md"
---

# Skill: Remove Hot TODOs

## Purpose
Delete existing checklist entries from `docs/TODOS.md` when the user explicitly asks to remove or clear a saved TODO/reminder.

## When to Use
- The user explicitly says to "remove/delete/drop" a TODO/reminder/hot item.
- Trigger matches the save-todos skill phrases but with removal intent.
- Do **not** trigger on casual mentions about forgetting or deprioritizing unless the user directs Codex to remove it.

## Inputs (Required)
- Identifier for the item to remove: exact text snippet, summary phrase, or list position. Ask once if ambiguous.

## Outputs (Required)
- The specified line removed from `docs/TODOS.md`. Report which line was removed (or if none matched).

## Procedure
1) Confirm removal intent if the phrasing could be read as informational rather than a request.
2) Open `docs/TODOS.md` and locate the target line:
   - Prefer exact substring match; if multiple matches, ask the user to disambiguate.
3) Remove the matching checklist line entirely (do not leave blank lines).
4) If nothing matches, tell the user and ask for a clearer snippet.
5) Echo back the removed line(s) to the user.

## Notes
- Keep remaining items exactly as-is; preserve ordering.
- If the user instead wants to mark done, use save-todos to add a `[x]` entry rather than deleting history unless they explicitly request deletion.
