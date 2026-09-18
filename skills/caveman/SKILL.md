---
name: caveman
description: Terse final verification pass for fix runs — mechanical checks only, minimal words, minimal human review. Use as the last gate before the PR.
version: 1.0.0
author: Aimino Tech
license: AGPL-3.0-only
tags:
  - verification
  - review
  - deterministic
platforms:
  - opencode
  - omp
---

# Caveman — final verification pass

Small words. Hard gates. Ship or stop.

## Rules

- Tests first. Red before, green after. No green → no PR.
- Deterministic checks only: tests, coverage, lint, build. Each with exit
  code recorded. Graphs/counts beat prose.
- No LLM-as-reviewer: no model grades the diff, no model "reviews" the
  work. The gates are the review. Human reviews stay minimal — the log
  must let a dumb agent call PASS/FAIL with zero interpretation.
- Short output: one line per gate (name, command, exit code, number).
  Drop filler. Code facts beat commentary.
- Fail closed: any red gate, missing evidence, or NOT-RUN gate stops the
  run. Write `result.json` with the failure anyway — never fake a pass.
