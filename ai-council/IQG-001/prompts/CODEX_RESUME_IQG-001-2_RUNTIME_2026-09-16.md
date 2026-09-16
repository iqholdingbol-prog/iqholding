# CODEX — IQG-001.2 RUNTIME REMEDIATION RESUME

Date: 2026-09-16
Coordinator: ChatGPT
CEO: Iván Quea
Repository: `iqholdingbol-prog/iqholding`
Target branch: `feature/iqg-001-2-runtime-remediation`

## Mission

Resume IQG-001.2 from the exact current repository/worktree state and finish the PostgreSQL 16 runtime remediation gate. Do not restart the work, do not redesign the Core, and do not move to IQG-001.3 or any vertical.

Current remote facts verified by ChatGPT:

- Branch exists: `feature/iqg-001-2-runtime-remediation`.
- `05b56870d2aa981c7befeb56203014517d6f20ce` = safety checkpoint documentation.
- `9081c2fadda89de8f2eed2051e030989a83c2c9c` = `IQG-001.2: agrega harness runtime PostgreSQL 16`.
- `33aa490615e6cf6e90b52bc2d4a879f9333edb7c` = `IQG-001.2: corrige préstamo temporal de owner`.
- GitHub Actions runs for `9081c2f` and `33aa490` both failed in step `Execute reproducible PostgreSQL 16 matrix`.
- The harness defines matrix A–W and is already committed. Do not replace it with another framework unless a demonstrated harness defect requires a minimal correction.

Historical local-state warning from the interrupted Codex session:

- There had been 13 edited files, including `tests/pg16/...`.
- `schemas/core_schema.sql` had a change rejected by automatic review at one point.
- Before interruption Codex was separating controlled global assertions from RLS assertions and correcting a PostgreSQL 16 bootstrap defect.
- Do not assume all prior local edits are already committed merely because the remote branch advanced.

## Non-negotiable safety rules

1. NEVER run destructive cleanup commands such as `git reset --hard`, `git clean`, destructive checkout, branch recreation, forced push, or delete uncommitted work.
2. NEVER discard, overwrite, or stash-and-forget local changes. Preserve evidence first.
3. Do not switch branches until the current worktree is fully inspected and any uncommitted work is accounted for.
4. Do not weaken RLS, FORCE RLS, role/ACL isolation, bootstrap security, anonymization, audit immutability, PII constraints, or tenant isolation merely to make tests green.
5. Do not edit tests to bless broken behavior. If a test is wrong, demonstrate why before changing it.
6. No IQG-001.3 production migration work.
7. No VANSAM, IPCENTER, Café Zacarías, Chocolates, Market Intelligence, social adapters, POS, CRM, or vertical code in this task.
8. No merge to `master`. Work only on the feature branch and produce an auditable checkpoint.

## Phase 0 — Recover the exact state first

Before making any edit, print and inspect:

```bash
git status --short
git branch --show-current
git rev-parse HEAD
git log --oneline --decorate -10
git diff --stat
git diff
git diff --cached --stat
git diff --cached
```

Then:

- confirm whether local HEAD is `33aa490...` or differs;
- identify every uncommitted/untracked file;
- compare local worktree with the remote feature branch;
- explicitly state whether the previously observed 13-file working set is fully committed, partially committed, or still present locally;
- preserve any local-only work before proceeding.

Do NOT ask the CEO to interpret Git state. Resolve it yourself safely.

## Phase 1 — Reproduce the real failure

First try the local matrix from repository root:

```powershell
pwsh -NoProfile -File tests/pg16/run.ps1 -Engine docker
```

If Docker is unavailable locally but Podman is available, use the supported engine. If neither is available, inspect the failed GitHub Actions run/logs using available GitHub/gh tooling and continue from exact evidence.

The current remote workflow failure is at:

`Execute reproducible PostgreSQL 16 matrix`

Do not guess the root cause.

Capture:

- first failing matrix ID;
- exact SQL/script/file;
- exact PostgreSQL error/code/message;
- whether failure is deterministic;
- whether the failure comes from DDL, harness, test assumption, environment, race/concurrency, or teardown.

Classify every failure as one of:

- `DDL_DEFECT`
- `HARNESS_DEFECT`
- `TEST_ASSUMPTION_DEFECT`
- `ENVIRONMENT_DEFECT`
- `CONCURRENCY_DEFECT`
- `UNKNOWN_NEEDS_REPRODUCTION`

## Phase 2 — Fix only demonstrated defects

Work failure-by-failure.

For each failure:

1. reproduce narrowly;
2. explain the violated invariant;
3. identify the smallest safe fix;
4. verify that the fix does not reduce security/isolation;
5. run the targeted assertion;
6. rerun the full A–W matrix.

Important security/semantic invariants that must remain true:

- installer/bootstrap capability cannot be forged by setting GUC values;
- `iqg_app` and `iqg_gateway` cannot become `iqg_owner`;
- bootstrap privilege is temporary and leaves no residual owner membership after commit;
- application/gateway do not receive unintended schema/table/sequence/function access;
- RLS + FORCE RLS hold for tenant relations;
- cross-company and cross-branch reads/writes fail where required;
- inactive user/company context blocks access as specified;
- user/company context semantics are server-enforced, not client-trusted;
- customer anonymization is idempotent and does not violate audit requirements;
- PII uniqueness/invariants remain correct;
- append-only price, payment/reversal, cash, fiscal snapshot, outbox and audit semantics remain intact;
- rollback leaves no partial schema/role state;
- dump/restore and DDL re-execution behave as intended;
- concurrency tests test actual separate sessions, not simulated sequential behavior.

## Phase 3 — Explicitly verify unresolved remediation areas

Do not assume these are solved merely because the harness reaches them. Produce evidence for each relevant remediation item:

### N-03 / C1 — Secure bootstrap
- legitimate bootstrap succeeds;
- malicious GUC/session impersonation fails;
- direct SQL path is denied;
- no residual elevated membership remains.

### N-04 / C5 — Active user/company context
- active context works;
- inactive user blocks membership/access;
- inactive company blocks membership/access;
- branch/company scope cannot be crossed.

### N-01 / C4 — Anonymization
- customer anonymization is idempotent;
- required audit history remains valid;
- redaction does not break tenant/audit invariants.

### N-05 / C3 — PII uniqueness
- uniqueness semantics are tested against the intended normalized/current-state rules;
- anonymization does not produce collisions or reopen identity leakage paths.

If the existing A–W matrix already proves an item, point to the exact test/assertion. If not, add the smallest necessary test.

## Phase 4 — Full runtime gate

The target is a clean full run of matrix A–W on PostgreSQL 16.

Required matrix coverage includes at minimum:

A installation
B rollback on injected failure
C roles/owner/ACL
D current_user/session_user SECURITY DEFINER semantics
E bootstrap legitimate/malicious/direct-SQL denial
F ENABLE + FORCE RLS
G 2 companies × 2 branches synthetic fixture
H read isolation
I cross-scope write rejection
J inactive user
K inactive company
L idempotent base roles/permissions
M domain-code update behavior
N operation-line unit validator
O append-only prices + successor race
P payment/reversal + over-reversal race
Q cash/currency/unit coherence
R operational audit + timestamp sealing + immutability
S customer anonymization + audit redaction + idempotence
T fiscal snapshot + deferred totals + transactional outbox
U corporate advisory lock during fiscal configuration/issuance
V deadlock detection in isolated QA objects
W dump/restore + DDL re-execution

No matrix item may be marked PASS unless it actually executed successfully.

## Phase 5 — CI confirmation

After a local full green run:

- review `git diff` carefully;
- make coherent commits with descriptive messages;
- push only to `feature/iqg-001-2-runtime-remediation`;
- verify GitHub Actions for the new HEAD;
- if CI differs from local, classify and fix the CI-specific defect without weakening the matrix.

The target is:

`PostgreSQL 16 ephemeral matrix = SUCCESS`

Do not stop at local success if CI remains red.

## Phase 6 — Evidence package for DeepSeek + ChatGPT

Create or update an audit report under:

`ai-council/IQG-001/reports/`

Include:

- starting HEAD;
- final HEAD;
- exact files changed;
- each failure encountered;
- failure classification;
- root cause;
- fix applied;
- tests added/changed and why;
- complete A–W result table;
- local execution result;
- GitHub Actions run ID/URL and conclusion;
- remaining known risks;
- any test assumptions that still require architectural review;
- `git status --short` at end.

Also include a concise section:

`DEEPSEEK_REAUDIT_INPUT`

with the exact claims DeepSeek should try to falsify.

## Definition of done

This task is complete only when ALL are true:

- exact local state safely recovered;
- no prior work lost;
- all real defects encountered are documented;
- full matrix A–W passes locally;
- GitHub Actions PostgreSQL 16 matrix passes on the feature branch;
- no security invariant was weakened to obtain green tests;
- worktree is understood and checkpointed;
- audit report is committed;
- no merge to master;
- no IQG-001.3 or vertical work started.

Do not declare the Core gate passed. Final gate remains:

`CODEX RUNTIME EVIDENCE → DEEPSEEK TECHNICAL RE-AUDIT → CHATGPT SYNTHESIS → CEO/GATE DECISION`

## Final response required from Codex

Return only after doing the work, with:

1. `STATE_RECOVERED`
2. starting/final commit SHA
3. exact first failure and root cause
4. fixes applied
5. A–W matrix result
6. local result
7. CI run ID + result
8. files changed
9. remaining risks
10. audit-report path
11. final `git status --short`
12. whether it is ready for DeepSeek re-audit: YES/NO

Final line exactly:

`IQG-001.2 RUNTIME REMEDIATION READY FOR DEEPSEEK RE-AUDIT`
