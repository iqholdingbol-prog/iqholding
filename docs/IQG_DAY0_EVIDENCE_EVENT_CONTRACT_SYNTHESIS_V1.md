# IQ GROWTH — Day-0 Evidence & Event Contract Synthesis V1

**Date:** 2026-09-17  
**Status:** `DESIGN_CANONICAL_DIRECTION_NOT_YET_IMPLEMENTATION_AUTHORIZED`  
**Inputs:** Claude Day-0 V2, ChatGPT audit, DeepSeek design-specific red team, existing Core/vertical doctrine.

## 1. Purpose

Define the minimum trustworthy information architecture for Day-0 capture across VANSAM, Café Zacarías, Chocolates and IPCENTER without forcing one vertical’s semantics into the Core.

The objective is not maximum data. It is:

`MAXIMUM DECISION TRUTH PER UNIT OF OPERATOR FRICTION`.

No production coding is authorized from this document while IQG-001.2 remains open.

## 2. Universal epistemic chain

`PRIMARY/RAW EVIDENCE`
→ `CAPTURED EVENT`
→ `VALIDATION`
→ `RECONCILIATION`
→ `BUSINESS STATE`
→ `DECISION`
→ `INTERVENTION`
→ `OUTCOME`
→ `DECISION MEMORY`
→ `DERIVED LEARNING`

Rules:

- `RAW_EVIDENCE != EXTRACTION != CONFIRMED_FACT`
- `OBSERVED_EVENT != CAUSAL_EXPLANATION`
- `CUSTOMER_DECLARED_REASON != TRUE_WILLINGNESS_TO_PAY`
- `SELLER_CLAIM != VERIFIED_STOCK`
- `UNKNOWN` is a first-class valid state.

## 3. Business-event invariants

Never collapse:

`ORDER != FULFILLMENT != SALE != RECEIVABLE != PAYMENT != CASH_MOVEMENT != REFUND != RETURN != CREDIT_NOTE`.

Also:

`SALE != REVENUE_RECOGNITION`.

Operational Core records the business event. Accounting recognition remains a separate capability/policy and can require specialist review.

`PAYMENT_METHOD` is separate from `PAYMENT_STATE`.

Example states may include `CLAIMED`, `CONFIRMED`, `FAILED`, `UNRECONCILED`; exact transition policy is configurable and must not invent universal time thresholds.

## 4. Identity, idempotency and operation correlation

Keep separate:

- `event_id`: immutable identity of the accepted event;
- `idempotency_key`: retry identity for one ingestion command/request;
- `business_operation_id`: correlation identity for one business intention/operation;
- `correlation_id`: optional grouping across a wider flow;
- `causation_id`: optional causal predecessor when meaningful;
- `correction_of`: explicit target when one event corrects another.

Authoritative duplicate prevention must rely on stable request/operation identity plus a defined uniqueness scope.

`content_hash + time_window` is never authoritative. It may only flag a possible duplicate for review.

## 5. Temporal model

Preserve separately when applicable:

- `business_occurred_at`
- `device_recorded_at`
- `server_received_at`
- `timezone/original_offset` where relevant
- `device/source_instance`
- `device_local_sequence`
- temporal/clock provenance

Wall-clock uncertainty does not automatically invalidate elapsed duration measured by a trustworthy monotonic source.

Do not reorder history silently to make timestamps look clean.

## 6. Correction semantics

All history-changing behavior is append-only from the business/audit perspective.

Use typed semantics instead of one generic contra-entry:

- metadata amendment;
- void;
- payment reversal;
- refund;
- return;
- credit note;
- replacement;
- compensating cash movement;
- inventory disposition;
- order amendment;
- no-financial-change correction.

A correction can change the current interpreted state without deleting the original captured history.

## 7. Evidence and provenance

Every decision-grade datum must be traceable to evidence/provenance appropriate to its materiality.

Candidate provenance states:

- system observed;
- human declared;
- source artifact;
- extracted from artifact;
- reconstructed from multiple artifacts;
- owner memory only;
- inferred;
- contradicted;
- unknown.

Do not equate document type with truth. Example: no invoice does not automatically mean cost unknown if other evidence supports the cost; conversely an invoice alone does not prove quantity received.

## 8. Cost knowledge

Separate at least conceptually:

- document/evidence type;
- cost observation;
- cost components;
- original currency/UOM;
- verification state;
- confidence/provenance;
- date/freshness.

No historical margin becomes a fact from owner memory alone.

An owner-reported estimate may exist as an estimate if explicitly labeled; it must not be promoted to verified cost.

## 9. Inventory / quantity ledger

Inventory reconciliation is based on typed signed movements by item and UOM.

Examples:

- load/inbound;
- sale consumption/outbound;
- return;
- sample;
- gift/promotional disposition;
- internal use;
- waste/damage;
- transfer inbound/outbound;
- transformation input/output;
- adjustment with explicit provenance.

Variance is derived from the signed ledger, not hardcoded as one subtraction formula.

Original UOM is preserved. Conversion requires a verified factor/mapping; otherwise converted value remains `UNKNOWN`.

## 10. Lot and batch lineage

Splits, merges, transformations, rework and repack preserve source links.

A merge with known quantities preserves proportions.

If proportions are unknown:

- preserve all source lot IDs;
- mark proportion/lineage precision as `UNKNOWN/DEGRADED`;
- never invent ratios.

A formula/version reference identifies the recipe/formulation version without requiring that restricted recipe contents be exposed.

## 11. Cash model

Keep distinct:

- cash session;
- opening float;
- cash movements;
- expected cash;
- physical cash count;
- difference/variance;
- cash handoff/deposit where applicable.

A difference is never silently erased.

Emergency/incomplete close may exist as an exception state rather than forcing operations to fabricate a count.

## 12. Non-monetary settlement

Barter/payment-in-kind must not hide in a generic payment-method enum.

Capture:

- asset/service received;
- quantity/UOM if meaningful;
- valuation state;
- relation to receivable/settlement;
- provenance.

Monetary value may remain `UNKNOWN`.

## 13. Decision Memory

Keep separate:

- `DECISION_EVENT`
- `DECISION_RATIONALE`
- `EVIDENCE_SNAPSHOT_REF`
- `INTERVENTION_EVENT`
- `OBSERVED_CONFOUNDER_EVENT`
- `CONFOUNDER_HYPOTHESIS`
- `OUTCOME_OBSERVATION`
- `CAUSALITY_ASSESSMENT`
- `DERIVED_LEARNING`

Rationale recorded after the decision must be visibly post-hoc.

Evidence selected after outcome is known must not masquerade as the original decision evidence set.

Derived learning:

- remains derived;
- is scope-bound;
- has evidence refs;
- exposes uncertainty/counterevidence;
- is reviewable/supersedable;
- may have optional expiry/review due;
- never silently becomes a fact.

## 14. Universal event envelope — minimal direction

The envelope should remain thin. Candidate fields:

- `event_id`
- `event_type`
- `schema_version/schema_ref`
- tenant/company context
- optional branch/location context
- temporal metadata
- principal/source-system context
- provenance/evidence refs
- optional idempotency/correlation/causation metadata when applicable
- correction relation when applicable
- typed payload

Do not place business-specific facts in the envelope.

Prefer reusable domain event namespaces such as `commerce.order.created`; company/vertical names belong to tenant/config/adapter context unless a true extension requires a dedicated namespace.

Transfer source/destination locations belong in the typed payload, not necessarily as generic top-level location fields.

## 15. Retention / privacy lifecycle

Reject `retain forever` as a universal rule.

Design lifecycle:

`capture → active evidence → retention policy → archive/minimize → anonymize/delete where appropriate → legal-hold exception where applicable`.

Specific obligations are `LEGAL_REVIEW_REQUIRED`.

Authorized first-party CRM linkage can exist. Unauthorized cross-platform identity linking of ordinary people remains prohibited.

## 16. Decision gates

The system should classify decision context, not pretend perfect knowledge is always required.

Recommended classes:

- `CONTINUE_CURRENT_OPERATION`
- `REVERSIBLE_TEST`
- `MATERIAL_CHANGE`
- `IRREVERSIBLE_CAPITAL_DECISION`

Evidence requirements scale with:

- economic materiality;
- irreversibility;
- uncertainty;
- operational/security risk;
- decision authority.

Human/CEO decisions that occur despite insufficient evidence must be recorded as such rather than hidden or fabricated.

## 17. Vertical Day-0 direction

### VANSAM

Core Day-0 emphasis:

- order identity + retry/idempotency semantics;
- items/mix;
- applied price;
- payment method + payment confirmation state;
- split payments;
- cash session/count/variance;
- actual opening/service end and unplanned closure evidence;
- automatic order lifecycle timestamps where technically reliable;
- order amendment;
- waste/remake/internal consumption when they occur;
- delivery charge beneficiary/settlement;
- customer/CRM identity according to current company configuration, not a universal Core requirement.

Do not push `ready_at` to LATER if it can be automatically captured with negligible friction; it directly supports service-capacity analysis.

### Café Zacarías

Core Day-0 emphasis:

- route/session/seller/channel;
- stock load/return and signed dispositions;
- sale vs receivable vs payment separation;
- physical cash reconciliation;
- lot/source/UOM preservation;
- process/transformation events;
- transfers between routes/locations;
- route variance derived by item/UOM;
- lot split/merge lineage.

Reject `route_sale.paid` boolean as a replacement for payment semantics.

### Chocolates

Core Day-0 emphasis:

- raw-material receipt + provenance;
- batch/formulation-version reference;
- source lot inputs and quantities;
- outputs and inventory unit of record;
- waste/rework;
- packaging/repack lineage;
- applied price vs price policy/version;
- consignment/return/damage disposition;
- cost evidence state separate from document type.

### IPCENTER

Live graph, not linear workflow:

`REQUEST ↔ REQUIREMENTS ↔ CANDIDATES ↔ SUPPLIER_OFFERS ↔ QUOTES ↔ CUSTOMER_DECISIONS ↔ DEPOSIT/PAYMENTS ↔ PROCUREMENT ↔ PHYSICAL_ITEMS ↔ FULFILLMENT ↔ SALE/AR ↔ WARRANTY/INCIDENTS`

Links express relationships; one fixed sequence is forbidden.

Requirements retain source/provenance: customer explicit, advisor interpretation, system extraction confirmed/unconfirmed.

Historical recovery must never create a SALE from a price conversation alone.

## 18. Implementation gate

This synthesis is architecture/design direction only.

Do not start production implementation of this Day-0 contract until:

1. IQG-001.2 runtime/security gate is closed;
2. Codex/DeepSeek technical re-audit chain is complete;
3. final field-level P0 configuration per lab is reconciled with actual operator workflows;
4. real friction is measured rather than assumed.

## 19. Council status

- Claude Day-0 V2: useful, not canonical by itself.
- DeepSeek design-specific attack: strong, corrected by ChatGPT.
- ChatGPT semantic synthesis: complete at architecture direction level.
- Gemini external evidence work remains separate from first-party Day-0 capture.
- Codex remains exclusively on IQG-001.2 until its gate closes.

**Final status:** `DAY0_EVIDENCE_EVENT_CONTRACT_SYNTHESIS_V1_READY_AS_DESIGN_DIRECTION_NOT_FOR_PRODUCTION_CODING`
