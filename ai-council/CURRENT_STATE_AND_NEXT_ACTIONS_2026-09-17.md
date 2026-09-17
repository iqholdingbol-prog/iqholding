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

### CLAUDE — Day-0 design
**State:** `DAY0_V2_DONE_AND_AUDITED`

No Day-0 Claude V3 now. Reopen design loop only for new evidence/material contradiction/specialist question.

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

### CLAUDE IN CHROME — authenticated social browser worker
**State:** `ACCESS_PROVEN / VANSAM_V1_EXPLORATORY_PASS / DECISION_GRADE_REMEDIATION_REQUIRED`

Authenticated read-only browser test passed for:
- Facebook search, public posts/comments, group search and Marketplace;
- TikTok search, videos, comments, comment scrolling and profiles;
- Instagram search, posts/Reels, comments, scrolling and profiles.

VANSAM Social Evidence Production V1 executed 2026-09-17:
- 115 ledger rows;
- reported 101 useful Cochabamba observations;
- TikTok, Facebook and Instagram covered;
- no CAPTCHA/2FA/block;
- geography false positives and several duplicate groups identified.

ChatGPT audit verdict:
`EXPLORATORY_CORPUS_PASS / DECISION_GRADE_LEDGER_FAIL_PENDING_REMEDIATION`

Critical defects:
- full evidence contract not implemented;
- Facebook rows lack reproducible direct permalinks;
- raw observations and semantic aggregations are conflated;
- broad saturation language overstates query-set saturation;
- material/excluded counts do not fully reconcile;
- dates/freshness/bias/proof boundaries need structured fields.

Artifacts:
- `ai-council/CROSS_VERTICAL/reports/2026-09-17_chatgpt_audit_claude_chrome_vansam_social_evidence_v1.md`
- `ai-council/CROSS_VERTICAL/prompts/CLAUDE_CHROME_VANSAM_SOCIAL_EVIDENCE_REPAIR_V1_1.md`

Next Claude action:
repair V1 in place as V1.1; do not restart the crawl from zero.

## Evidence execution lanes — NOW ACTIVE

### Lane A — ChatGPT Public Web
Collect row-level public evidence where standard web/search can reach:
- indexed public pages;
- public business sites/catalogs;
- public reviews/directories;
- public social snippets/pages where accessible;
- public forums;
- current public offers.

Each row must preserve source/reference, observed date, access/evidence class, what it proves and what it cannot prove.

### Lane B — Claude Authenticated Social Browser
Use Claude in Chrome for legitimately authenticated/public Facebook, TikTok, Instagram, Marketplace and similar surfaces where normal web search is weak.

Rules:
- read-only by default;
- no posting, messaging, liking, following or profile changes during evidence collection;
- preserve canonical source URL/permalink and parent-child provenance;
- no unnecessary PII;
- no unauthorized identity linking across ordinary people;
- human intervention limited to login/2FA/CAPTCHA/authorization.

### Lane C — First-Party Authorized Evidence
Highest-value evidence:
- VANSAM POS/order/payment/customer interactions and authorized business WhatsApp where available;
- Café route/seller/point records, sales, payments/receivables and wholesale inquiries;
- Chocolates receipts/batches/sales/returns/damage/customer/wholesale evidence;
- IPCENTER historical authorized chats, ManyChat/owned-contact recovery, quotes, invoices, transfers, shipping, warranty artifacts and live B2C evidence when reactivated.

First-party data must preserve historical vs current status and consent/contactability separately. `PHONE_KNOWN != MARKETING_OPT_IN`.

### Lane D — Field Observation
Use where digital sources cannot answer operating reality: traffic, routes, stock handling, point activity, production/fulfillment and physical offer verification.

## Immediate next work while Codex is blocked

### P1 — Repair VANSAM social evidence V1 to V1.1
Use existing 115-row corpus. Fix provenance, schema, aggregation semantics, count reconciliation and targeted missing queries. No full recrawl.

### P2 — Re-audit VANSAM V1.1
ChatGPT re-audits before any decision-grade ingestion or cross-vertical replication.

### P3 — IPCENTER first-party recovery
After VANSAM collector semantics are repaired, start a separate Claude chat for authorized IPCENTER evidence:
- WhatsApp Business read-only access test;
- historical contact/conversation inventory;
- ManyChat recovery if original workspace can be recovered;
- preserve names/phones as first-party contact data only where legitimately held;
- no outbound messaging during recovery/audit.

IPCENTER geographic scope: Bolivia nationally, preserving city/destination where known.

### P4 — Café Zacarías / Chocolates social acquisition
Initial geography: El Alto + La Paz. National expansion only after local acquisition method is stable.

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
**Run Claude Chrome `VANSAM_SOCIAL_EVIDENCE_REPAIR_V1_1`, then ChatGPT re-audits the repaired corpus. Keep IPCENTER WhatsApp linked but untouched until the VANSAM collector contract is repaired.**
