# DEEPSEEK — DAY-0 INSTRUMENTATION RED TEAM V1

Date: 2026-09-16
Project: IQ GROWTH / IQHOLDING
Role: Red Team / Security / Data Integrity

## Mission
Attack the proposed concept of Day-0 first-party instrumentation for VANSAM, Café Zacarías, Chocolates and IPCENTER before it becomes software.

Do not redesign the Core. Do not invent business facts. Your job is to show how seemingly simple manual/first-party capture can generate false operational truth, bad economics, privacy risk, fraud opportunity or misleading Decision Memory.

Assume Day-0 will initially contain some combination of manual entry, POS, notebook, WhatsApp, cash, QR, operator-entered events and later synchronization.

## Required attacks

### 1. Operational data corruption
At least 50 concrete attack/failure modes across:
- skipped entries
- late/backfilled entries
- wrong SKU/variant
- wrong quantity/unit
- wrong price
- cash not reconciled
- payment recorded without receipt
- sale recorded without fulfillment
- fulfillment without sale
- duplicate transaction
- accidental deletion
- clock/timestamp drift
- offline replay
- operator shortcuts
- shared credentials
- fabricated customer data
- missing refunds/reversals
- unrecorded waste/merma
- inventory drift
- route/mobile commerce gaps

For each: mechanism, corrupted decision, detection, prevention, residual risk.

### 2. Incentive gaming
At least 30 ways employees/owners could game KPIs or data capture intentionally or unintentionally. Include production bonuses, wait-time metrics, complaints, sales, shrinkage, cash close, customer identity and repeat-rate metrics.

### 3. Economic falsehoods
At least 25 ways Day-0 data could make an unprofitable business look healthy or vice versa. Distinguish contribution, cash, gross sales, refunds, working capital, inventory, unpaid receivables, owner labor and shared-resource costs.

### 4. Identity/privacy failure
At least 20 risks involving customer phone numbers, WhatsApp, names, cross-platform identity, employee attribution and sensitive inference. Apply strict separation between authorized CRM identity and aggregate/de-identified Market Memory.

### 5. Decision Memory poisoning
At least 25 ways a decision log can become self-serving history: missing alternatives, hindsight rewriting, cherry-picked evidence, optimistic expected outcomes, post-hoc justification, deleted counterevidence, operator blame, etc.

### 6. Offline/manual adversarial tests
Design at least 40 tests that a Day-0 capture process must survive before automation. Include power loss, no internet, duplicate sync, partial shift, two operators, cash discrepancy, wrong date, reversal after close, stock transfer, anonymous customer, customer refusing phone, damaged item, free replacement, internal consumption, sample/gift, and intercompany movement.

### 7. Hard invariants
Propose candidate invariants, but do not invent arbitrary numeric thresholds. Examples:
- no sale silently equals payment
- no cash movement silently equals revenue
- no corrected record overwrites original history
- every backfill is marked as backfill
- every material manual correction has actor/time/reason
- every synchronization is idempotent

Classify each invariant as MUST / SHOULD / CONTEXTUAL.

### 8. Minimum trustworthy dataset
Try to prove that the Day-0 set is too large or too small. Return the smallest set that can support useful decisions without creating a false sense of precision.

### 9. Vertical-specific traps
Give at least 15 traps per vertical:
- VANSAM
- Café Zacarías
- Chocolates
- IPCENTER

### 10. Final verdict
Return:
- `CRITICAL_FAILURES`
- `HIGH_RISK_FAILURES`
- `MUST_HAVE_CONTROLS`
- `DATA_NOT_TRUSTWORTHY_UNTIL`
- `DECISION_MEMORY_GUARDRAILS`
- `DAY0_ADVERSARIAL_TEST_PACK`
- `OPEN_RISKS`

Do not propose fake certainty. Do not require enterprise-grade controls where a simpler control works. Cost of control must be proportional to risk.

Final line exactly:
`DAY0 INSTRUMENTATION RED TEAM READY FOR CHATGPT AUDIT`