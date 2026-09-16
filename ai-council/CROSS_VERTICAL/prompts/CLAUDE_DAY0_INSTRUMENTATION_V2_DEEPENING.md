# CLAUDE — DAY-0 INSTRUMENTATION & DECISION MEMORY V2 / DEEPENING

Date: 2026-09-16
Project: IQ GROWTH / IQHOLDING
Role: Product/Systems Challenger

## Mission
Rebuild your Day-0 proposal at a stricter standard. V1 was useful but contained material semantic errors, unsupported friction assumptions, stale business facts, and a lossy universal schema.

Read FIRST:
- `ai-council/CROSS_VERTICAL/reports/2026-09-16_chatgpt_review_claude_day0_instrumentation_v1.md`
- `docs/CEO_CORRECTIONS_2026-09-15.md`
- `docs/IQG-100_VANSAM_BASELINE_V1.md`
- `docs/IQG-003_CAFE_ZACARIAS_VERTICAL_V1.md`
- `docs/IQG-004_CHOCOLATES_LA_FLORITA_VERTICAL_V1.md`
- `docs/IQG-005_IPCENTER_DAY0_DATA_CONTRACT.md`
- `docs/IQG_CORE_UNIVERSAL_BUSINESS_MODEL_V1.md`

If any file is inaccessible, state exactly which one. Do not pretend to have read it.

Do not code. Do not redesign Core tables. Do not invent business facts, timings, thresholds or operator abilities.

## Non-negotiable corrections from V1

1. Friction seconds are `TO_MEASURE`, never facts without timed observation.
2. Do not infer inability to use software from age. Test modalities.
3. High-friction missing data becomes `UNKNOWN/NOT_CAPTURED` unless auditable derivation exists.
4. `FIADO` is NOT a payment method. Separate receivable/credit terms from payment.
5. `CASH_COUNT` is an observation, not the cash ledger.
6. VANSAM Day-0 MUST include continuity/open-close/lost-hours because it is a known causal confounder.
7. VANSAM must have order-level service timestamps where they can be captured automatically.
8. Purchase photos are raw evidence; cost only becomes decision-grade after item/qty/UOM/supplier/date/cost mapping.
9. Waste must be quantity + UOM + reason/stage or explicitly unknown.
10. Use operator roles, not hardcoded people, in the contract.
11. Café must preserve original UOM and current channel/route/seller reality.
12. Do not claim unknown yield or guessed pricing as fact unless source confirms.
13. Chocolates: cacao origin/supply Alto Beni is confirmed; do NOT assume a specific current supplier such as El Ceibo without reconfirmation.
14. Chocolate batch capture must reference batch/product/formulation version/input UOM/output/waste even if formula details are access-restricted.
15. IPCENTER Day-0 is historical recovery PLUS the existing live request→quote→decision→procurement→sale/payment→fulfillment/warranty chain.
16. Rejection reason is customer-declared evidence, not a true price ceiling.
17. Split Decision Memory into system-observed decision event vs human-declared rationale.
18. Causal attribution must be state+method+evidence, not a boolean/system-calculated shortcut.
19. `DERIVED_LEARNING` is allowed only as explicitly derived/versioned/uncertain, never as fact.
20. Reject the five-field universal movement schema. A shared event envelope may exist, but ORDER/SALE/PAYMENT/CASH/PRODUCTION/INVENTORY remain semantically distinct.
21. Low-N satisfaction can still surface material incidents; do not discard categorically.
22. No fixed two-week threshold. Pilot sufficiency is event/cycle/reliability based.

## Required depth

### A. FIELD-LEVEL CONTRACT — EACH VERTICAL
For VANSAM, Café Zacarías, Chocolates, IPCENTER create a field-level table with at minimum:
- field/event name
- semantic definition
- business object/event it belongs to
- source type
- primary evidence
- actor/role responsible
- capture moment
- capture modality candidates
- required/optional/derived/unknown
- original UOM/currency handling
- server timestamp vs user-entered timestamp
- validation rule
- correction/supersession rule
- offline behavior
- duplicate/idempotency key concept
- privacy sensitivity
- estimated friction state: `UNMEASURED` unless measured
- exact decision(s) enabled
- exact decision(s) that remain blocked if missing
- failure mode if captured wrong

Do not compress this into generic prose.

### B. CAPTURE MODALITY EXPERIMENT
For Café and Chocolates, design a real falsification test comparing at least:
- paper/tally
- photo-assisted transcription
- voice note
- WhatsApp/delegated capture
- minimal mobile form

Define what evidence would make each modality win/lose:
- completion rate
- missing-field rate
- correction rate
- time-to-capture
- time-to-digitize
- reconciliation error
- operator abandonment

NO invented pass thresholds. State `TO_CALIBRATE`.

### C. VANSAM — RECONCILIATION
Design minimum Day-0 reconciliation for:
- order
- fulfillment/sale
- receivable
- payment(s)
- cash movement
- cash session
- cash count
- QR/transfer evidence
- cancellation
- refund/reversal
- delivery fee
- purchase expense/payment

Provide at least 15 edge cases:
- split cash+QR
- partial payment
- fiado paid next day
- cancelled after partial prep
- refund
- cash expense from drawer
- delivery fee collected separately
- duplicated order
- device offline
- late payment confirmation
- wrong payment method corrected
- cash count difference
- reopened order
- complimentary item
- owner consumption / non-sale

For each edge case show what events exist and what MUST NOT be inferred.

### D. VANSAM — OPERATIONAL TRUTH
Include P0 continuity and service evidence:
- planned schedule vs actual open/close
- lost hours and reason
- order created/ready/fulfilled/cancelled timestamps
- staff/role coverage at shift level
- critical incident
- sales mix
- payment/cash quality
- purchase-cost freshness
- waste

Explicitly distinguish automatically captured vs operator-entered data.

### E. CAFÉ — CURRENT BUSINESS, NOT FUTURE EXPORT FANTASY
Day-0 must cover the business as it operates now:
- farm/process events where occurring
- lot/process yield with original UOM
- current production/roasting/packaging
- current El Alto sellers/points/routes/channels
- stock loaded / sold / returned when operationally feasible
- sale/payment/cash evidence
- channel economics

Then separately mark what belongs later to export/compliance.

Produce at least 20 concrete operational scenarios, including:
- mixed UOM
- same lot split across destinations
- seller takes stock and returns remainder
- sale without identified customer
- cash collected later
- damaged/returned package
- lot transformed in stages/locations
- unverified conversion factor

### F. CHOCOLATES — MANUFACTURING + SALES
Build minimum batch and sales truth without exposing formula unnecessarily.

Include:
- raw material receipt
- batch id
- product/variant
- formulation version ref
- input quantities/UOM
- output units/weight
- waste/rework
- packaging
- stock movement
- seller/channel/route
- sale/payment
- returns/damage
- evidence

At least 20 edge cases.

Do NOT name a current supplier unless canonical evidence supports it.

### G. IPCENTER — RECOVERY + LIVE DAY-0
Reconcile your proposal against `IQG-005_IPCENTER_DAY0_DATA_CONTRACT.md`.

Separate:
1. historical recovery;
2. live first-party request capture;
3. external supplier evidence;
4. customer decision;
5. procurement;
6. physical item;
7. fulfillment;
8. sale/payment;
9. warranty/incidents.

For historical recovery, design provenance states:
- source artifact exists
- owner memory only
- reconstructed from multiple artifacts
- unknown

Never reconstruct historical margin as fact without cost evidence.

At least 20 recovery ambiguity cases.

### H. DECISION MEMORY V2
Define distinct objects/concepts:
- DECISION_EVENT
- DECISION_RATIONALE
- EVIDENCE_SNAPSHOT_REF
- INTERVENTION_EVENT
- CONFOUNDER_EVENT
- OUTCOME_OBSERVATION
- CAUSALITY_ASSESSMENT
- DERIVED_LEARNING

For each define:
- who/what can create it
- mutable vs append-only
- source/provenance
- correction path
- expiry/review
- what it may NEVER claim

### I. UNIVERSAL EVENT ENVELOPE
Propose an envelope ONLY, not a single movement entity.

Stress test it against at least:
- pizza order
- QR payment
- cash count
- coffee drying event
- coffee route stock load
- chocolate production batch
- chocolate wholesale sale
- IPCENTER supplier quote
- IPCENTER payment
- warranty incident

If the envelope loses material meaning, revise it.

### J. DATA QUALITY / RECONCILIATION
For each vertical define:
- primary source
- secondary/corroborating source
- reconciliation cadence concept
- unresolved discrepancy state
- late-entry handling
- backfill handling
- correction handling
- duplicate handling
- evidence retention

No silent overwrite.

### K. DECISION-BLOCK MATRIX
Build a matrix of at least 40 decisions across the four verticals:
- decision
- minimum evidence needed
- evidence currently available
- missing evidence
- reversible/irreversible
- economic materiality
- permitted action now
- blocked action

Do not rank businesses or invent ROI.

### L. WHAT WE SHOULD NOT CAPTURE
For each proposed exclusion, prove why it is not decision-relevant now and identify the trigger that would make it necessary later.

Do not use "low sample" as a blanket reason to ignore incident/safety/complaint evidence.

## Required self-attack

At the end, attack your own V2 with at least 30 failure modes. For each:
`ASSUMPTION -> HOW IT FAILS -> WHAT EVIDENCE WOULD DISPROVE IT -> DESIGN RESPONSE`.

## Output discipline

Every claim must be tagged conceptually as one of:
`CANONICAL_FACT`, `DOCUMENT_SUPPORTED`, `SYSTEM_OBSERVED`, `SYSTEM_CALCULATED`, `OWNER_REPORTED`, `HYPOTHESIS`, `TO_MEASURE`, `UNKNOWN`, `REJECTED`.

No unsupported numeric thresholds.
No age-based assumptions.
No mixing of order/sale/payment/cash.
No vendor/supplier invention.
No "average ticket" without order count.
No false causal claims.
No hiding unknowns.

## Final line

`DAY0 INSTRUMENTATION V2 DEEPENING READY FOR CHATGPT AUDIT`
