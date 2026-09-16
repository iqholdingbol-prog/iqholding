# ChatGPT Review — DeepSeek Day-0 Instrumentation Red Team V1

Date: 2026-09-16
Reviewer: ChatGPT / Chief Architect & AI Council Coordinator
Status: `DEEPSEEK_DAY0_RED_TEAM_V1_USEFUL_BUT_INCOMPLETE_AND_SEMANTICALLY_CORRECTED`

## 1. Executive decision

DeepSeek produced a useful adversarial corpus, especially around unrecorded sales, cash/QR reconciliation, SKU errors, backfills, inventory drift, offline sync, shared credentials, Decision Memory rewriting and privacy. It also delivered 42 adversarial tests.

However, this output is **not accepted as canonical controls** and does **not close the Day-0 red-team gate**.

Two independent reasons:

1. The original prompt was not available to DeepSeek in its execution environment. The canonical prompt required explicit minimums and deliverables that were therefore not fully followed.
2. Several proposed invariants/controls collapse business semantics or over-control small-business operations.

Canonical status:

- `ADVERSARIAL_CORPUS = ACCEPTED_WITH_CORRECTIONS`
- `CANONICAL_INVARIANTS = NOT_ACCEPTED_AS_WRITTEN`
- `DAY0_TEST_PACK = PARTIALLY_ACCEPTED`
- `VERTICAL_SPECIFIC_RED_TEAM = NOT_DELIVERED`
- `MINIMUM_TRUSTWORTHY_DATASET = NOT_DELIVERED`
- `FINAL_RED_TEAM_GATE = OPEN`

## 2. Prompt-delivery defect

The intended prompt required:

- 50+ operational corruption modes;
- 30+ incentive-gaming modes;
- 25+ economic falsehoods;
- 20+ identity/privacy failures;
- 25+ Decision Memory poisoning modes;
- 40+ offline/manual tests;
- hard invariants classified MUST / SHOULD / CONTEXTUAL;
- a minimum trustworthy dataset;
- 15+ traps per vertical for VANSAM, Café Zacarías, Chocolates and IPCENTER;
- explicit final sections: CRITICAL_FAILURES, HIGH_RISK_FAILURES, MUST_HAVE_CONTROLS, DATA_NOT_TRUSTWORTHY_UNTIL, DECISION_MEMORY_GUARDRAILS, DAY0_ADVERSARIAL_TEST_PACK, OPEN_RISKS.

DeepSeek explicitly declared that the prompt file was unavailable. That limitation was real and must not be treated as model non-compliance alone. Council delivery must ensure prompts are reachable or pasted inline.

## 3. Strong accepted findings

### 3.1 Operational corruption mechanisms
Useful and accepted as attack patterns:

- cash sale without ticket;
- QR/payment claim without bank confirmation;
- split payment mis-recorded;
- refunds/reversals omitted;
- wrong SKU/size/extras;
- backfills and post-hoc KPI repair;
- initial stock declared without count;
- theoretical stock without physical reconciliation;
- waste used to hide shrinkage;
- offline lost events / replay / partial synchronization;
- shared identities and stale credentials;
- Decision Memory hindsight rewriting.

### 3.2 Append-only and provenance direction
Accepted directionally:

- corrections must not silently overwrite history;
- backfills need explicit marking;
- created/recorded time must be separate from declared occurrence time;
- decisions need actor and evidence links;
- AI inference must not become FACT silently.

### 3.3 Goodhart / KPI gaming
Accepted as principle: any KPI used as an incentive can become a target and lose measurement value. IQ GROWTH therefore needs cross-checking between outcome, process, economic and integrity metrics.

## 4. Material semantic corrections

### 4.1 `SALE must have PAYMENT` — REJECT
DeepSeek proposes: "Ninguna venta sin pago asociado" and test `DAY0-AT-01` says a sale without payment must be rejected.

This is incompatible with the canonical separation:

`ORDER != SALE != PAYMENT != CASH_MOVEMENT`

A legitimate sale may create an accounts receivable and remain unpaid.

Correct invariant:

> No SALE may be silently interpreted as PAYMENT. If consideration remains unpaid, the obligation/receivable state must be explicit.

### 4.2 `PAYMENT must have SALE` — REJECT AS ABSOLUTE
A payment may be:

- deposit/prepayment against an order/quotation;
- settlement of a receivable from an earlier sale;
- customer credit/top-up where supported;
- refund/reversal counterpart.

Correct invariant:

> Every payment/value-transfer event must have an explicit purpose/reference and must never be silently interpreted as revenue or sale.

### 4.3 Refund does not necessarily reverse the whole sale
Partial refunds, goodwill credits, warranty adjustments and price corrections may leave the underlying sale economically/historically valid.

Use separate events:

`REFUND / CREDIT_NOTE / PAYMENT_REVERSAL / SALE_REVERSAL / RETURN`

with explicit relationships.

### 4.4 QR screenshot is weak evidence
Customer screenshots are forgeable and cannot be decision-grade proof of settlement.

Preferred evidence hierarchy:

`BANK/PROVIDER_CONFIRMED > BUSINESS_ACCOUNT_OBSERVED > CUSTOMER_SCREENSHOT > CUSTOMER_CLAIM`

### 4.5 Phone number is not customer identity
Do not automatically deduplicate customers by phone/correo. Shared numbers, changed numbers and family phones exist.

Phone is an attribute/identifier candidate, not immutable identity.

### 4.6 Offline time semantics
"Use server time" is insufficient for offline operation.

Preserve at least:

- `occurred_at_declared/device`;
- `recorded_at_local` when available;
- `synced_at_server`;
- clock/offset evidence when available;
- confidence/anomaly state.

Never rewrite an offline event's occurrence as the later sync time.

### 4.7 Sync ordering by timestamp — REJECT
Device clocks can drift. Correct direction:

- client-generated immutable event IDs;
- idempotency keys;
- server acknowledgements;
- explicit causal/reference relations;
- conflict resolution;
- replay-safe processing.

Timestamp ordering alone is not enough.

### 4.8 `atomic sync` as universal requirement — REVISE
Distributed/offline clients cannot rely on one global atomic sync transaction. Require idempotent batches, resumability, acknowledgements, reconciliation and deterministic conflict handling.

## 5. Control-proportionality corrections

The following are not universal MUSTs and require threat/risk evidence:

- camera-based customer counting;
- biometrics;
- double signatures for every cash count;
- photo/testigo for every waste event;
- supervisor PIN for every correction;
- double approval for all support access;
- geolocation for login attribution.

Use:

`CONTROL_STRENGTH ∝ MATERIALITY + FRAUD_RISK + REVERSIBILITY + EVIDENCE_GAP`

Do not turn a small business into a bank when a simpler reconciliation provides adequate control.

## 6. Economic semantics corrections

### 6.1 Margin layers must remain distinct
Do not collapse:

- gross margin;
- contribution margin;
- operating result;
- accounting profit;
- cash flow;
- working capital;
- return on capital.

A contribution metric does not become invalid merely because depreciation or owner labor is not allocated; it must be labeled with its scope and cost coverage.

### 6.2 Historical cost must never be "updated"
A historical lot cost remains historical. The risk is using a stale cost as if it were current for a new quote/decision.

Separate:

- `historical_applied_cost`;
- `current_observed_cost`;
- `cost_freshness`;
- `cost_method`.

### 6.3 Exchange-rate treatment
No fixed rule such as "official + parallel" becomes canon. FX source, date, purpose, accounting treatment and legal/compliance review must be explicit.

## 7. Privacy corrections

Accepted:

- no cross-platform identity linking without authorization;
- no wealth profiling from neighborhood/device/followers;
- PII should not leak into Market Memory narratives.

Revisions:

- encryption-at-column is not automatically the correct control for every PII field;
- backup deletion/suppression mechanics require architecture + legal review; immutable backups may require expiry/crypto-erasure/logical suppression strategies rather than mutation;
- authorized first-party CRM may contain identifiable data while Market Memory remains aggregate/de-identified by default.

## 8. Missing required depth

The output did not meet several explicit prompt requirements:

- Incentive gaming: did not deliver the requested 30+ dedicated modes.
- Economic falsehoods: delivered ~10 dedicated DR cases, not 25+.
- Identity/privacy: delivered 8 dedicated PR cases, not 20+.
- Decision Memory poisoning: delivered 6 dedicated DM cases, not 25+.
- Hard invariants were not classified MUST / SHOULD / CONTEXTUAL.
- Minimum trustworthy dataset was not produced.
- 15+ vertical-specific traps for each of four businesses were not produced.
- Required final verdict sections were not produced.

The 42-test pack is useful but inherits several semantic errors above and therefore cannot be adopted verbatim.

## 9. DeepSeek V1 disposition

Keep as an adversarial source register, not a canonical specification.

Before final red-team closure, DeepSeek must attack the **actual Claude Day-0 V2 design**, not another generic concept. That will provide new evidence and avoid an AI loop.

Next DeepSeek round should therefore wait until Claude V2 is available, then run against exact fields/events/reconciliation rules.

## 10. Gate

`DEEPSEEK_DAY0_RED_TEAM_V1_USEFUL_BUT_INCOMPLETE_AND_SEMANTICALLY_CORRECTED`

No implementation should treat the listed 18 "invariants" or 42 tests as canonical until reconciled against Claude V2, Core event semantics and the vertical contracts.
