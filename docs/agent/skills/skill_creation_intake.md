---
id: skill-creation-intake
name: Skill Creation Intake
description: Structured questioning loop to clarify a new skill before drafting or coding it.
version: 0.1
last_verified: 2026-01-20
dependencies: []
outputs: []
---

# Skill: Skill Creation Intake

## Purpose
Elicit and confirm the intent, scope, and constraints of a new skill by asking the user focused, repeated questions before any skill scaffolding starts.

## Inputs (Required)
- User request to create or update a skill.

## Outputs (Required)
- A concise requirements brief covering: goal, triggers, boundaries, reusable resources, and success criteria.

## Procedure
1) **Opening check (ask 2x):** Ask the user for the primary goal of the skill and a concrete example of when it should trigger. Follow with a second question that probes what would *not* be in scope.
2) **Use-case loop (ask 2x):** Request at least two distinct example user prompts that should invoke the skill; then ask for one prompt that should *not* invoke it.
3) **Resource probe (ask 2x):** Ask whether scripts, reference docs, or assets are needed; then ask what existing files or systems the skill must integrate with.
4) **Constraint probe (ask 2x):** Ask for hard constraints (runtime limits, file locations, confidentiality rules); then ask about preferred output formats or mandatory fields.
5) **Risk + dependency check:** Ask if the skill depends on other skills, tools, or approvals; note any cross-skill coupling.
6) **Reflect and confirm:** Summarize the gathered answers as a short requirements brief and ask the user to confirm or edit. Do not proceed to implementation steps until explicit confirmation.
7) **Implement**: If the user confirms the contents, write it to disk.
8) **Record**: Update relevant indexes and context files so they know about the new skill.

## Guardrails
- Keep questions short; never bundle more than two asks per message.
- If answers are vague or conflicting, loop once more on the unclear item before proceeding.
- Stop and escalate if the user cannot provide at least one positive and one negative trigger example.
