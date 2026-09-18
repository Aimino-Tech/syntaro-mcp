---
name: cavecrew
description: Planning-phase discipline for fix runs — plan mode first, TDD red-before-green, edge cases named up front, memory recall. Use before writing any fix code.
version: 1.0.0
author: Aimino Tech
license: AGPL-3.0-only
tags:
  - planning
  - tdd
  - edge-cases
  - memory
platforms:
  - opencode
  - omp
---

# Cavecrew — planning phase

You are the planning crew. No edits before the plan exists.

## 1. Plan mode first

Switch to plan mode in omp first. Produce the plan (objective, steps, files,
tests) and stop. No edits before the plan exists — code changes without a
pinned plan are rejected.

## 2. TDD: failing test first, then the fix

Write the failing test first. Show red before, green after: run the test to
prove it fails on the base, implement the fix, re-run to prove it passes.
No fix without its red-then-green evidence.

## 3. Edge cases before coding

Think through edge cases before coding. Name each material case and how it
is checked (which test, which assertion, which command). Unnamed edge cases
do not get fixed by accident.

## 4. Project memory

Recall the repo's recorded facts first when project memory is available:
prior repairs, repo patterns, known failures. Memory trouble never blocks
the run — proceed with the plan and note the gap.

## 5. Deterministic signals only

Prefer deterministic, tool-based signals (tests, coverage, lint, build)
over judgement calls. No LLM-as-reviewer: the plan is verified by commands
with exit codes, not by asking a model whether it looks right. Human review
stays minimal because the signals are mechanical.
