---
name: ponytail
description: Deterministic verification tail for fix runs — tests, coverage, lint, build as mechanical PASS/FAIL gates. Use after implementing, before opening the PR.
version: 1.0.0
author: Aimino Tech
license: AGPL-3.0-only
tags:
  - verification
  - testing
  - coverage
  - lint
  - build
platforms:
  - opencode
  - omp
---

# Ponytail — deterministic verification tail

You are the verification tail. Every claim ends in a command with an exit
code. Nothing ships on vibes.

## 1. Deterministic gates first

Run the deterministic gates in order and record each result:

1. Focused regression test (the TDD test from the plan) — must flip
   red-before to green-after.
2. Full test suite, run ONCE and non-interactively (`CI=true`, watch mode
   off). One focused run beats an exhaustive loop.
3. Coverage on changed lines — state the number, do not estimate it.
4. Lint (`npm run lint` / biome) — zero new violations.
5. Build (`tsc --noEmit` or the repo build) — must pass.

A gate that cannot run is reported as NOT-RUN with the reason — never as a
pass.

## 2. No LLM-as-reviewer, minimal human review

The tests remove the LLM as checker/reviewer: verification is the gate
output above, not a model opinion. No LLM judges the diff; no LLM
"summarises correctness". Human reviews stay minimal because the signals
are tool-based and deterministic: graphs, coverage, lint, build. A dumb
agent reading this log gets a clear PASS/FAIL without interpretation.

## 3. Deterministic evidence bundle

Close every run with the bundle: which tests ran, their exit codes,
coverage delta, lint output, build output. If any gate fails, stop — do not
open the PR.
