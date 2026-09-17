# AI Council — Current State and Next Actions

**Date:** 2026-09-17  
**Project:** IQ GROWTH / IQHOLDING

## Purpose
Single operational register for current AI Council state. This file is coordination metadata, not a replacement for canonical business/architecture documents.

## Current technical critical path

### CODEX — IQG-001.2
**State:** `ACTIVE_BUT_TEMPORARILY_BLOCKED_BY_USAGE_LIMIT`

Branch: `feature/iqg-001-2-runtime-remediation`

Known remote checkpoint before current local worktree: `0f762492ccd2c9d4a2ab2aa19d5603a6c04323f9`

Current local worktree reported by Codex UI:
- 17 files modified
- approximately `+1271 / -306`
- includes `schemas/bootstrap_roles.sql`, `schemas/core_schema.sql`, `tests/pg16/sql/00_test_support.sql`, plus 14 additional files

Do not reset, clean, restore destructively, switch branch, merge master, or start another Codex task.

Next exact Codex action when usage returns:
1. safe recovery check of branch/HEAD/worktree;
2. file-by-file self-review and scope minimization;
3. verify bootstrap trust boundary and security invariants;
4. local static/parser validation;
5. atomic commit(s) only if self-review passes;
6. push only to feature branch;
7. GitHub Actions runtime matrix A-W plus BOOT-01..10;
8. first real FAIL -> evidence -> root cause -> minimal fix -> full rerun;
9. DeepSeek technical re-audit only when runtime evidence is sufficient.

Gate remains: `NOT_READY_FOR_DEEPSEEK_REAUDIT` until demonstrated otherwise.

## Cross-vertical Day-0 / Evidence architecture

### CLAUDE
**State:** `DAY0_V2_DONE_AND_AUDITED`

Claude V2 materially improved Day-0 instrumentation but was not canonical. Key remaining problems were attacked by DeepSeek.

### DEEPSEEK
**State:** `DAY0_V2_DESIGN_SPECIFIC_RED_TEAM_DONE_AND_AUDITED`

DeepSeek received a self-contained packet and delivered a design-specific adversarial review with 65 tests. Useful findings were accepted with semantic corrections; DeepSeek output is not copied blindly into canon.

### CHATGPT
**State:** `DAY0_SEMANTIC_SYNTHESIS_DONE`

Artifacts:
- `ai-council/CROSS_VERTICAL/reports/2026-09-17_chatgpt_review_deepseek_day0_v2_design_specific_red_team.md`
- `docs/IQG_DAY0_EVIDENCE_EVENT_CONTRACT_SYNTHESIS_V1.md`

Current synthesis status: `DESIGN_DIRECTION_NOT_FOR_PRODUCTION_CODING`.

No Claude V3 and no DeepSeek V2 at this point unless new evidence or a material contradiction appears.

## Market evidence acquisition

### GEMINI
**State:** `V2_PROMPT_READY_RESPONSE_PENDING`

Prompt:
`ai-council/CROSS_VERTICAL/prompts/GEMINI_EVIDENCE_ACQUISITION_MATRIX_V2_DEEPENING.md`

Mission:
- 10 P0 + 10 P1 acquisition tasks per business;
- distinguish query/observation/signal/intent/quote/acceptance/payment/fulfillment/profit;
- exact `CAN_PROVE` / `CANNOT_PROVE` per task;
- phone-ready capture packets for VANSAM, Café Zacarías, Chocolates and IPCENTER;
- ChatGPT Web / Human Public / First-Party Recovery / Field Observation queues;
- 25+ weak/redundant tasks rejected;
- access gaps and data-quality checks;
- no invented market conclusions.

## Next parallel work while Codex is blocked

Priority order:

### P1 — Complete Gemini V2
Do not start another theoretical AI round until Gemini V2 is received and audited.

### P2 — Build the Evidence Acquisition Operating Plan
After Gemini V2, ChatGPT should reconcile:
- Gemini acquisition matrix;
- Day-0 evidence/event synthesis;
- canonical business facts;
- existing first-party datasets;
- access constraints.

Deliverable should separate:
1. evidence ChatGPT can collect on public web;
2. evidence requiring human public/authenticated capture;
3. evidence already owned first-party;
4. field observation;
5. API/licensed future paths.

### P3 — Execute real evidence collection, not more theory
First live targets should be evidence that can change near-term decisions:
- VANSAM: continuity, own order/item/size mix, paid prices, payment method, timing, cancellations/rework/complaints, repeat, delivery results, cost/contribution where confirmed;
- Café Zacarías: route/session/load/sold/returned/cash/variance, real line/presentation/channel sales, UOM, wholesale inquiries/quotes/reorders;
- Chocolates: raw material receipt, batch/input/output/waste/rework, presentation/channel sales, applied price, returns/damage, customer/wholesale evidence;
- IPCENTER: first-party historical recovery plus live B2C request->quote->decision->deposit/payment->fulfillment evidence when operation resumes.

### P4 — No production coding of Day-0 contract yet
Codex remains exclusively on IQG-001.2 until the Core gate closes.

## Council routing rule

`Codex builds critical-path infrastructure.`  
`Claude challenges product/operational semantics.`  
`DeepSeek attacks false truth, data integrity, economics and security.`  
`Gemini maps and expands legitimate external evidence acquisition.`  
`ChatGPT coordinates, cross-checks, rejects contradictions and decides the next gate.`

## Anti-loop rule
Do not create V3/V4 rounds merely because another model can produce more text. Reopen a specialist only when there is:
- new evidence;
- a material contradiction;
- an unresolved specialist question;
- critical noncompliance;
- or a failed real-world/runtime test.

## Immediate next action
**Wait for Gemini V2 response and audit it.**

In parallel, preserve Codex worktree untouched until usage returns, then continue the already-authorized IQG-001.2 self-review -> commit/push -> runtime CI path.
