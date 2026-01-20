---
id: git-commit
name: Git Commit Workflow
version: 1.0
last_verified: 2026-01-20
scope: repo-wide
dependencies: []
outputs: []
---

# Skill: Git Commit Workflow

## Purpose
Create a local git commit after work is finished. Guardrails: only run once the user explicitly confirms they are "ready to git commit"; do not use mid-iteration or during general git discussions. Never push.

## Inputs (Required)
- Explicit confirmation that the task is complete and we are "ready to git commit".
- Current `git status` output (to list modified/untracked files).
- List of files the agent created in this task (if unclear, ask the user).
- Commit message drafted per repo style guide (short, imperative, sentence case).

## Outputs (Required)
- A local git commit created (not pushed).
- Short checklist summarizing staged files, commit message, and push status.

## Procedure
1) **Pre-flight**
   - Re-confirm with the user that they are ready to commit and not still iterating.
   - Run `git status` to enumerate modified and untracked files.

2) **Stage files with consent**
   - Automatically stage new files the agent created in this task: `git add <agent-created files>`.
   - For each modified or untracked file not explicitly created by the agent, ask the user for approval before staging. If approved, `git add <file>`; if not, leave unstaged and note it.

3) **Verify staging**
   - Show staged vs unstaged: `git status --short`. Confirm the staged set with the user if anything looks unexpected.

4) **Craft commit message**
   - Follow repo style: short, imperative, sentence case (e.g., "Add git commit helper skill"). Avoid trailing punctuation.
   - Confirm the message with the user.

5) **Commit**
   - Run `git commit -m "<message>"`.
   - Do **not** run `git push`.

6) **Report checklist (output)**
   - Provide a concise checklist including: staged files, commit message used, commands run, any files deliberately left unstaged, and an explicit note that no push was performed.

## Notes
- If any staging/commit step fails, surface the error and resolve before retrying.
- If the working tree is dirty after the commit, highlight remaining files and ask for next steps.
