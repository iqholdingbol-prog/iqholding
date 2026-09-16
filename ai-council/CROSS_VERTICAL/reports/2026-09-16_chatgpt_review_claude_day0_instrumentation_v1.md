# ChatGPT Review — Claude Day-0 Instrumentation & Decision Memory V1

Date: 2026-09-16
Reviewer: ChatGPT / Chief Architect & AI Council Coordinator
Status: `CLAUDE_DAY0_V1_ACCEPTED_WITH_MAJOR_CORRECTIONS_V2_REQUIRED`

## 1. Executive decision

Claude produced useful operational structure, especially:
- non-destructive correction/history;
- separation of order/sale/payment/cash observation;
- preservation of primary evidence;
- low-friction Day-0 capture;
- Decision Memory with snapshot of information available and simultaneous changes;
- explicit acknowledgment that Café/Chocolate capture must be tested in real operation.

However, V1 is not decision-grade as-is. It contains material semantic errors, unmeasured friction assumptions, stale business facts, and a lossy cross-vertical normalization that contradicts IQ GROWTH's own invariants.

Canonical disposition:
- `CONCEPT_DIRECTION = ACCEPT`
- `NUMERIC_FRICTION_BUDGETS = TO_MEASURE`
- `PAPER_FIRST_AS_UNIVERSAL_RULE = REJECT`
- `FIADO_AS_PAYMENT_METHOD = REJECT`
- `COMMON_5_FIELD_MOVEMENT_SCHEMA = REJECT`
- `DECISION_MEMORY_DIRECTION = ACCEPT_WITH_CORRECTIONS`
- `V11_DEFECTS = DOCUMENT_SUPPORTED, REVERIFY_AT_CUTOVER`
- `CHOCOLATE_CEIBO_AS_CURRENT_SUPPLIER = REJECT_STALE`
- `V2 = REQUIRED_BEFORE_CANONICALIZATION`

## 2. Evidence-grounded accepted findings

### 2.1 V11 financial incompleteness
Prior V11 audit supports that no payment field, payment amount, payment method, change or confirmation exists, and that the legacy closure is not a conciliable cash close. Historical V11 orders therefore cannot be silently treated as paid sales.

### 2.2 V11 data-integrity defects
Prior audit supports:
- `guardarEdicionCliente()` reconstruction can drop address/preferences fields;
- `historial/` stays at `pendiente` because ready-state updates only hit `pedidos/`;
- `numPedido = maxNum + 1` plus `set()` can overwrite on collision;
- order and customer dates use incompatible timestamp representations;
- phone is used as identity key and can split/merge customer identity.

These are `DOCUMENT_SUPPORTED` from the audited legacy artifact, not merely Claude assertions. They must still be reverified against the exact V11 cutover artifact before migration.

### 2.3 Non-destructive evidence
Accepted as a foundational invariant:
`CORRECTION != OVERWRITE`.
Primary evidence must be preserved; transcription or structured extraction references it and never silently replaces it.

## 3. Major corrections

### C1 — Friction values are hypotheses, not facts
Claude assigns values such as 5 seconds/order, 30 seconds/event, 60–90 seconds/day without measurement.

Required model:
- `friction_budget_state = HYPOTHESIS | MEASURED`
- role
- workflow/daypart
- device/modality
- measured duration distribution
- completion/error rate

Do not optimize capture against invented seconds.

### C2 — Do not infer tool inability from age
The claim that paper is mandatory because operators are older / have no digital history is unsupported. Age is not evidence of inability.

Required approach: compare capture modalities in a real pilot:
- preprinted tally/paper;
- photo of source document;
- voice note;
- WhatsApp/assisted capture;
- minimal mobile form;
- delegated capture.

Choose from measured compliance, time, completeness and error rate.

### C3 — If a datum is not captured, do not silently infer it
Claude's friction law says a high-friction datum is "inferred or abandoned". This is unsafe.

Rule:
- derive only when inputs + derivation are auditable;
- otherwise mark `UNKNOWN` / `NOT_CAPTURED`.

### C4 — `FIADO` is not a payment method
A credit sale with no funds received is not a PAYMENT.

Required separation:
- SALE / FULFILLMENT event;
- ACCOUNTS_RECEIVABLE / amount_due / credit_terms;
- PAYMENT only when value is actually received;
- PAYMENT_METHOD = CASH / QR / TRANSFER / CARD / other verified medium;
- split and partial payments supported;
- reversal/refund separately represented.

### C5 — Cash count is not the cash ledger
Opening/closing `CASH_COUNT` is an observation. The system also needs cash-session and cash-movement logic so expected cash can be reconciled against counted cash.

Minimum concepts:
`CASH_SESSION`, `CASH_COUNT`, `CASH_MOVEMENT`, `EXPECTED_CASH`, `COUNTED_CASH`, `DIFFERENCE`.

### C6 — VANSAM Day-0 omits the biggest known confounder: continuity
Canonical baseline identifies continuity as first-level. Day-0 must preserve actual opening/closing and unplanned closures/hours lost.

P0:
- planned schedule ref;
- `actual_open_at`;
- last dine-in service;
- last takeaway service;
- cleanup end when measured;
- unplanned closure / lost hours / reason;
- operator/shift context.

### C7 — VANSAM needs order-level service timestamps, not station micromanagement
Per-station timing may wait, but order-level `created_at`, `ready_at`, `fulfilled_at/cancelled_at` is decision-critical because wait time/oven bottleneck is a known problem. Prefer automatic timestamps to avoid operator friction.

### C8 — Purchase photo + total amount is not enough to update cost
A photo is raw evidence. To update decision-grade cost, structured capture must eventually resolve:
- supplier/source;
- date;
- item;
- presentation/unit;
- quantity;
- total and unit cost;
- transport/extra cost where material;
- catalog mapping;
- extraction confidence + human confirmation when ambiguous.

If unresolved, preserve image and mark cost `UNKNOWN/PENDING_EXTRACTION`, not "real cost updated".

### C9 — Waste must be costable
`what was thrown away` is insufficient unless quantity + UOM + reason/stage can be captured reliably. Day-0 waste design must define minimum costable evidence and an explicit unknown state.

### C10 — Do not hardcode Samira/Nicolás/Flora into the model
Named people may be current operators, but Day-0 contract must use roles/assignments and preserve who actually performed the event. Company config maps current people to roles.

### C11 — Café Day-0 must preserve original UOM and current commercial channels
A kg-only notebook violates universal UOM and can discard operational reality such as lata/qq/saco.

Use `quantity + original_uom`, with conversion only when verified.

Also, current Café activity includes mobile/fixed sellers/routes/channels. Day-0 cannot only capture production lot + generic sale. Minimum commercial capture must support:
- seller/point/route/channel;
- stock loaded/returned or opening/closing position where practical;
- units/value sold;
- payment/cash evidence;
- returns/shortages;
- source evidence.

Otherwise IQ GROWTH cannot learn which current distribution channel actually works.

### C12 — Café statements about unknown yields/pricing are hypotheses
"Nobody knows green-to-roast yield" and "price is a guess" are unsupported unless CEO/operator confirms. Mark as `TO_MEASURE`, not fact.

### C13 — Chocolate supplier statement is stale
Latest CEO correction says cacao origin/supply in Alto Beni is confirmed but specific historical suppliers must not be assumed current without reconfirmation. `El Ceibo` cannot be carried forward as current supplier truth.

### C14 — Chocolate Day-0 needs batch identity + output + input UOM, not only free text
To calculate product cost later while preserving recipe confidentiality:
- batch_id;
- product/variant;
- formulation_version_ref where available;
- input item + quantity + UOM + source lot when available;
- output quantity/weight;
- waste/rework;
- source evidence;
- sales channel/payment separately.

Detailed formula may remain restricted; the batch must still reference the version used.

### C15 — IPCENTER Day-0 is recovery + new request capture
Historical recovery is P0, but it does not replace the existing IPCENTER Day-0 request-to-outcome contract.

Any live inquiry must retain request text, channel, city, need, budget if volunteered, requirements version, candidate, supplier offer provenance, quote version, customer decision, procurement/payment/fulfillment/warranty events.

Historical "margin" must not be reconstructed as fact unless historical cost evidence supports it.

### C16 — Rejection reason is not a true price ceiling
A rejection reason is `CUSTOMER_DECLARED` and can be partial, strategic or multi-causal. It is valuable evidence but cannot be upgraded into a real willingness-to-pay ceiling without additional evidence.

### C17 — Decision Memory must separate event from rationale
Reject "only a human writes Decision Memory" as a blanket rule.

Required split:
- `DECISION_EVENT`: system-observed when an authorized action actually occurs;
- `DECISION_RATIONALE`: human-declared explanation/expectation/alternatives;
- `EVIDENCE_SNAPSHOT_REF`: versioned references/hashes, not necessarily copied payload;
- `INTERVENTIONS/CONFOUNDERS`;
- `OUTCOME_OBSERVATION`;
- `CAUSALITY_STATE`.

The system may record the event automatically; it must never fabricate human rationale.

### C18 — Attribution is not a simple `SYSTEM_CALCULATED` field
Use a state/method model:
`NOT_ESTABLISHED`, `ASSOCIATION_ONLY`, `EXPERIMENT_SUPPORTED`, `QUASI_EXPERIMENT_SUPPORTED`, etc., with method, evidence, confounders and uncertainty.

### C19 — Derived Learning is allowed, but never silently promoted to fact
Do not adopt "system never writes learning" literally. IQ GROWTH may produce a `DERIVED_LEARNING` object if it retains provenance, scope, sample/window, method, uncertainty, contradictory evidence, validity period and supersession path.

### C20 — The proposed five-field universal movement record is too lossy
Reject:
`fecha · tipo_movimiento · contraparte · cantidad · valor`
as the universal target schema.

It collapses distinctions Claude itself correctly defended: order, sale, payment, cash, inventory, production, process and evidence.

A universal event envelope can be shared, but domain entities/events remain distinct. Minimum envelope direction:
- event_id;
- company/operating unit;
- event_type;
- occurred_at_server / observed_at where applicable;
- actor;
- source/evidence ref;
- referenced domain entity ids;
- quantity + UOM when applicable;
- money + currency when applicable;
- evidence/verification state;
- correction/supersession refs.

### C21 — Satisfaction should not be discarded categorically
Low sample size limits aggregate inference, but a single serious complaint can still be operationally material. Keep satisfaction/complaint capture optional or event-triggered; do not equate low N with zero operational signal.

### C22 — Two-week pilot is not a universal evidence threshold
Pilot window should be tied to sufficient operational cycles/events and capture reliability, not a fixed two-week rule. Café may require event-based/season-stage testing; VANSAM can use consecutive open-day cycles.

## 4. Cross-vertical invariant proposed

Day-0 must optimize for `DECISION VALUE / CAPTURE COST`, but all capture decisions must preserve truth-state:

`NOT_CAPTURED != ZERO`
`UNKNOWN != FALSE`
`CUSTOMER_DECLARED != VERIFIED`
`ORDER != SALE != PAYMENT != CASH_MOVEMENT`
`RAW_EVIDENCE != TRANSCRIPTION != DERIVED_VALUE`
`CORRECTION != OVERWRITE`

## 5. Gate

Do not canonicalize Claude V1.

Required next step: Claude V2 must rework the proposal against these corrections and produce a field-level minimum viable capture contract, evidence provenance, modality test, error controls, and decision mapping per vertical.

DeepSeek Day-0 red team should independently attack the revised concept; final canonicalization waits for ChatGPT synthesis of Claude V2 + DeepSeek + existing canonical business documents.
