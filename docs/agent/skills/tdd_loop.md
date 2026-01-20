---
id: tdd-loop
name: Test-Driven Development Loop
version: 1.0
scope: generic
dependencies: ["docs/context/TESTING.md"]
last_verified: 2026-01-19
---

# Skill: TDD Loop (Red → Green → Refactor)

## Purpose
Implement changes by writing/adjusting tests first, proving failure, then making the smallest change to pass, then refactoring safely.

## When to Use
Default for all implementation work unless an explicit exemption applies.

## Inputs (Required)
- Acceptance criteria (behavioral)
- Test location conventions (where tests live, how to run them)

## Outputs (Required)
- New or updated test(s)
- Evidence of:
  - RED: test fails for the right reason
  - GREEN: test passes after minimal code change
  - REFACTOR: cleanup without behavior change (tests still pass)
- A short TDD trace summary (template below)

## Procedure
0) ENSURE: You have loaded the TESTING.md context file for testing conventions.
1) Identify smallest testable unit of behavior that advances the acceptance criteria.
2) Write or update a test that captures that behavior.
3) Run the smallest relevant test command.
   - Confirm it FAILS for the expected reason (RED).
4) Implement the minimum code to make it pass.
5) Re-run the tests and confirm pass (GREEN).
6) Refactor for readability/structure while keeping tests green (REFACTOR).
7) Repeat in small slices until acceptance criteria are met.

## Test Selection Guidance
- Prefer the fastest scope that provides confidence:
  - single test -> file -> package -> full suite
- If failure is integration-level, write an integration test or a repro harness.

## Exemptions (Allowed but must be recorded)
You may skip RED-first only if:
- The change is purely mechanical (rename, formatting) and covered by existing tests.
- The work is exploratory/prototyping and explicitly marked as such.
- The environment makes RED impractical (e.g., engine/editor-driven UI wiring).
In all cases, record the exemption reason in the final summary.

## TDD Trace Template (Required in final response)
- Tests added/changed:
  - <path>: <what it asserts>
- RED evidence:
  - Ran: <command> -> <expected failure>
- GREEN evidence:
  - Ran: <command> -> pass
- Refactor notes:
  - <what was refactored, if any>
- Exemptions:
  - None | <reason>
