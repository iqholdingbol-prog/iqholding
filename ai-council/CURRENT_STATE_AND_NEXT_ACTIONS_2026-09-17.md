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

No Claude V3 now. Reopen only for new evidence/material contradiction/specialist question.

### DEEPSEEK
**State:** `DAY0_V2_DESIGN_SPECIFIC_RED_TEAM_DONE_AND_AUDITED`

Design-specific attack delivered 65 tests. Useful findings were accepted with semantic corrections; DeepSeek output is not copied blindly into canon.

### CHATGPT
**State:** `DAY0_SEMANTIC_SYNTHESIS_DONE`

Artifacts:
- `ai-council/CROSS_VERTICAL/reports/2026-09-17_chatgpt_review_deepseek_day0_v2_design_specific_red_team.md`
- `docs/IQG_DAY0_EVIDENCE_EVENT_CONTRACT_SYNTHESIS_V1.md`

Current synthesis status: `DESIGN_DIRECTION_NOT_FOR_PRODUCTION_CODING`.

## Market evidence acquisition

### GEMINI
**State:** `V3_ACCESS_INTEGRITY_PASS_LIVE_EVIDENCE_ZERO`

Gemini V3 correctly declared its environment limits and produced zero fabricated observations. It could not access live Facebook, Instagram, TikTok, WhatsApp first-party logs or usable web search in that runtime.

Audit artifact:
- `ai-council/CROSS_VERTICAL/reports/2026-09-17_chatgpt_review_gemini_social_reality_excavation_v3.md`

Do **not** request Gemini V4 for the same live social excavation unless:
- Gemini receives new network/platform access;
- a real corpus is supplied to it;
- or there is a new specialist question that does not require inaccessible live sources.

Gemini V3 also repeated several rejected assumptions (unsupported Café `matte 250g`, B2B hotel margin question, cold-chain assumption, arbitrary IPCENTER `> Bs 10,000`, arbitrary freshness/B2B cutoffs). These are not canonical.

## Evidence execution lanes — NOW ACTIVE

The project now moves from AI-theory loops to real evidence acquisition.

### Lane A — ChatGPT Public Web
Collect row-level public evidence where standard web/search can reach:
- indexed public pages;
- public business sites/catalogs;
- public reviews/directories;
- public social snippets/pages where accessible;
- public forums;
- current public offers.

Each row must preserve source/reference, observed date, access/evidence class, what it proves and what it cannot prove.

### Lane B — Human Authenticated Social Capture
Use for Facebook/TikTok/Instagram/Marketplace or other authenticated-public surfaces not reliably accessible to automated web.

Human capture tasks must state exact platform/query/page/group/profile, fields, screenshot/reference requirement, privacy limits, evidence class and decision relevance.

### Lane C — First-Party Authorized Evidence
Highest-value evidence:
- VANSAM POS/order/payment/customer interactions and authorized business WhatsApp where available;
- Café route/seller/point records, sales, payments/receivables and wholesale inquiries;
- Chocolates receipts/batches/sales/returns/damage/customer/wholesale evidence;
- IPCENTER historical authorized chats, quotes, invoices, transfers, shipping, warranty artifacts and live B2C evidence when reactivated.

### Lane D — Field Observation
Use where digital sources cannot answer operating reality: traffic, routes, stock handling, point activity, production/fulfillment and physical offer verification.

## Immediate next work while Codex is blocked

### P1 — Build `EVIDENCE ACQUISITION OPERATING PLAN V1`
Reconcile:
- Gemini V3 access reality;
- Gemini prior acquisition-matrix work;
- Day-0 evidence/event synthesis;
- canonical business facts;
- current source-access constraints.

Every high-priority question must have:
1. primary acquisition lane;
2. fallback lane;
3. exact evidence class;
4. minimum fields;
5. proof boundary (`CAN_PROVE` / `CANNOT_PROVE`);
6. stop condition;
7. decision affected.

### P2 — Execute first live public-web evidence
Do not wait for a perfect architecture. Start with decision-relevant evidence that ChatGPT can actually collect now, while preserving provenance.

### P3 — Prepare phone-ready human capture packets
Only for gaps that public web cannot close. Keep them minimal and reproducible.

### P4 — Begin first-party recovery/capture
Prioritize highest-value owned evidence rather than weak public proxies.

### P5 — No production coding of Day-0 contract yet
Codex remains exclusively on IQG-001.2 until the Core gate closes.

## Anti-loop rule
Do not create V3/V4 rounds merely because another model can produce more text. Reopen a specialist only when there is:
- new evidence;
- a material contradiction;
- an unresolved specialist question;
- critical noncompliance;
- or a failed real-world/runtime test.

## Immediate next action
**ChatGPT builds and begins executing `EVIDENCE ACQUISITION OPERATING PLAN V1` while the Codex worktree remains untouched until usage returns.**
