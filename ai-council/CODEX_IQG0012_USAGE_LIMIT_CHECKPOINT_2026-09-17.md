# CODEX IQG-001.2 — Usage-limit checkpoint

Date: 2026-09-17
Project: IQ GROWTH / IQHOLDING

## Verified remote state
Branch: `feature/iqg-001-2-runtime-remediation`
Remote head remains: `0f762492ccd2c9d4a2ab2aa19d5603a6c04323f9`
No new remote commit/push was visible at checkpoint time.

## Local Codex state reported by UI before usage exhaustion
The Codex turn ran for approximately 26m30s and then stopped because usage was exhausted.
The UI reported this turn edited 8 files with approximately `+547 / -143`.
Files explicitly visible included:
- `tests/pg16/run.ps1` (`+3 / -3`)
- `schemas/bootstrap_roles.sql` (`+24 / -0`)
- `tests/pg16/sql/00_test_support.sql` (`+41 / -33`)
- plus 5 additional files not expanded in the UI summary.

Important: the `8 files +547/-143` figure is the delta reported for this most recent Codex turn, not authoritative proof that the complete preserved worktree contains only 8 modified files. Earlier preserved state had a larger multi-file worktree. On resume, Codex must inspect the actual current worktree with Git before assuming counts.

## Safety rules
Do not click Deshacer.
Do not reset/clean/restore destructively.
Do not switch branch.
Do not merge master.
Do not force push.
Do not reconstruct from the remote checkpoint while the local worktree remains available.

## Exact resume procedure
When Codex usage returns, continue in the same Codex chat and first run:
- `git branch --show-current`
- `git rev-parse HEAD`
- `git status --short`
- `git diff --stat`
- `git diff --name-status`
- `git diff --check`

If branch/HEAD/worktree are as expected, continue the already-authorized self-review from the preserved local worktree.
If the worktree is unexpectedly clean, the branch changed, or HEAD changed without explanation, stop and report; do not auto-recover.

## Pending technical mission
Continue IQG-001.2 only:
1. complete file-by-file self-review and scope minimization;
2. validate Phase 0 privileged bootstrap / Phase 1 Core install / Phase 2 runtime separation;
3. validate bootstrap trust boundary and role invariants;
4. validate test harness does not secretly repair the system;
5. run available local validation;
6. commit only after self-review passes;
7. push only to `feature/iqg-001-2-runtime-remediation`;
8. execute PostgreSQL 16 runtime CI matrix A-W plus BOOT-01..10;
9. for each real FAIL: capture evidence -> root cause -> minimal fix -> full rerun;
10. DeepSeek technical re-audit only after sufficient runtime evidence.

Current gate: `NOT_READY_FOR_DEEPSEEK_REAUDIT`.
