# ChatGPT Review — DeepSeek Day-0 V2 Design-Specific Red Team

**Date:** 2026-09-17  
**Project:** IQ GROWTH / IQHOLDING  
**Reviewer:** ChatGPT — Chief Architect / AI Council Coordinator  
**Source:** DeepSeek response ending `CLAUDE DAY0 V2 DESIGN-SPECIFIC RED TEAM READY FOR CHATGPT SYNTHESIS`

## Verdict

`DEEPSEEK_DAY0_V2_RED_TEAM_STRONG_AND_USEFUL_BUT_REQUIRES_SEMANTIC_CORRECTIONS_BEFORE_CANON`

DeepSeek finally received the complete Claude V2 source and executed a design-specific attack. It materially improved the design, delivered >60 adversarial tests, minimum Day-0 datasets and a useful final reconciliation. However, it also introduced several new overgeneralizations, internal contradictions and implementation assumptions. Its output is red-team evidence, not canonical specification.

## Strong contributions accepted

1. Confirms `SALE` must not collapse fulfillment or accounting revenue recognition.
2. Confirms `event_id != idempotency_key != business_operation_id`.
3. Confirms offline chronology requires multiple temporal facts, not one timestamp.
4. Confirms generic `contra-asiento` is too broad; correction semantics must be typed.
5. Confirms Café route variance must account for all legitimate dispositions/transfers.
6. Confirms lot merge should preserve source lineage and explicitly degrade precision when proportions are unknown.
7. Confirms non-monetary settlement must not hide inside a generic payment method.
8. Confirms IPCENTER must be modeled as an event/state graph rather than a fixed linear chain.
9. Confirms Decision Memory must distinguish post-hoc rationale/confounders from pre-decision evidence.
10. Confirms permanent retention is not a universal invariant.
11. Confirms decision evidence must scale with materiality/reversibility rather than binary global blocks.
12. Produces 65 design-specific adversarial tests and separate minimum datasets for the four verticals.

## Material corrections to DeepSeek

### D1 — Do not make time-window/content dedup authoritative
DeepSeek sometimes recommends `business_operation_id + actor + window`, and elsewhere `content_hash + window`, for deduplication. This is unsafe as an authority because two legitimate identical operations can occur close together. Authoritative idempotency must come from a stable request/operation token generated before submission and enforced by a uniqueness scope. Content/time similarity is only a duplicate-detection heuristic requiring review.

### D2 — `idempotency_key` is not necessarily mandatory on every immutable domain event
It is mandatory for idempotent ingestion/commands where retries can occur. The accepted event may retain the originating idempotency metadata, but the universal event envelope should not be bloated merely to make every event look like a command. Preserve the distinction between COMMAND/REQUEST identity and DOMAIN EVENT identity.

### D3 — `causation_id` is not required merely because corrections can chain
`correction_of` expresses the record being corrected. `causation_id` answers a different question: what event caused this event. Both may exist, but neither should substitute for the other. `causation_id` should be optional and earned by use case.

### D4 — clock quality should be measured, not hidden behind invented `LOW/HIGH` thresholds
Prefer raw/verifiable facts such as offset, source, verification time and `clock_state` where a state is genuinely observable. Do not invent universal drift bands.

### D5 — unknown clock does not automatically invalidate all durations
If start/end are measured by a monotonic clock on the same device, elapsed duration may remain trustworthy even when wall-clock time is uncertain. Temporal precision and duration precision are separate.

### D6 — payment metadata correction cannot simply ignore economic side effects
Changing CASH to QR may require correction of the expected cash ledger if the original posting affected it. Preserve append-only source history and correct the ledger effect explicitly where needed; do not merely use the final label.

### D7 — `WASTE_PRE_PREP` is semantically unsafe
An ingredient not used is not necessarily waste. It may return to available inventory. Distinguish reservation release, recoverable input, actual waste and remake.

### D8 — route variance needs signed movements, not a fixed subtraction list
Inbound transfer increases route stock; outbound transfer decreases it. Route reconciliation should be based on typed signed inventory movements by item/UOM, not one hardcoded subtraction formula.

### D9 — responsibility is evidence, not a default field assertion
Damage by courier/supplier/business may be disputed. Record `responsibility_state` and evidence, allowing `UNKNOWN/DISPUTED`, rather than treating `responsible_party` as fact.

### D10 — coproduct cost allocation is an accounting/economic policy, not a mandatory Day-0 truth
Preserve multi-output transformation and quantities first. Allocation can remain `UNALLOCATED` until policy exists. Do not force BY_WEIGHT/BY_VALUE merely to obtain a margin.

### D11 — unknown shelf life does not imply FIFO is safe
Unknown shelf life should create an explicit risk/hold/review state appropriate to the product. FIFO is not a universal safety rule.

### D12 — no-invoice does not imply unknown cost
DeepSeek correctly says this in analysis, but test T-47 again maps no invoice directly to `cost_state=UNKNOWN`. Cost knowledge and document type remain separate.

### D13 — WhatsApp price discussion is not a pending sale
DeepSeek still leaves `PENDING_VERIFICATION` on the historical price conversation. Correct model: INQUIRY/OFFER/QUOTE exists; SALE does not exist unless separate evidence supports it. Do not create a provisional sale object from a price discussion.

### D14 — historical family delivery disposition and settlement must remain separate
`GIFT / LOAN / CREDIT_SALE / UNKNOWN` describes commercial disposition. `UNRECORDED_PAYMENT` is a settlement hypothesis and should not share the same enum.

### D15 — serial verification against supplier offer may be impossible
Supplier offers often do not contain unit serials. Physical item verification should compare actual received item/serial against procurement/order/specification and supplier delivery evidence, not assume the offer had the serial.

### D16 — permanent-retention legal claims must remain `LEGAL_REVIEW_REQUIRED`
DeepSeek states that permanent retention “violates right of deletion”. That is too categorical without jurisdiction/context. Canonical statement: permanent retention creates privacy/legal risk and may conflict with applicable obligations/rights; policy requires legal review.

### D17 — `DO_NOT_LINK` across channels is too absolute
Authorized first-party CRM identity resolution can be legitimate. Prohibit unauthorized cross-platform identity linking; allow authorized first-party linkage under defined purpose/permissions.

### D18 — reopening IPCENTER is not `CONTINUE_CURRENT_OPERATION`
IPCENTER is paused. A low-capital request→source→quote pilot is a `REVERSIBLE_TEST` or controlled reactivation, not continuation of an ongoing operation.

### D19 — count of blocked decisions is not itself evidence of poor adoption
“25 blocked” does not prove the system is obstructive. The issue is whether gates are proportional, explainable, bypassable by authorized human decision with an audit trail, and aligned with risk.

## Minimum-dataset corrections

### VANSAM
- `order_id` is identity, not idempotency. Add command/request idempotency separately.
- `order.created_at = server` is not universally valid offline; preserve business/device/server times.
- `ready_at` should not automatically be pushed to LATER: when captured automatically it is low-friction and directly relevant to known service/capacity constraints.
- Customer identity should be a configurable business requirement; do not silently move it to LATER if the VANSAM CRM flow requires it.
- Waste fields are conditionally mandatory when waste occurs, not a field burden on every order.

### Café Zacarías
- `route_sale.paid` boolean is rejected; preserve SALE/RECEIVABLE/PAYMENT separately.
- `route_cash` must not collapse expected cash, counted cash and handoff.
- Route reconciliation uses signed movements by item/UOM.

### Chocolates
- Supplier may be unknown or internal source; provenance is more important than forcing a supplier value.
- Cost state must separate evidence/document from cost knowledge.
- All MUST fields are conditional on the event/object existing; do not require impossible objects before operations occur.

### IPCENTER
- Live requests may originate from phone/in-person without a persistent source artifact; raw declared request/provenance is enough.
- Physical item, deposit, warranty, fulfillment etc. are `MUST_WHEN_APPLICABLE`, not globally mandatory fields for every request.

## Adversarial-test corrections

DeepSeek’s 65-test pack is valuable but not executable canon without edits. Key defects:

- T-05 cross-device dedup by content/window is unsafe.
- T-16 “refund without sale” should generally fail/quarantine; otherwise it is a different payout/adjustment type, not a refund.
- T-19 overpayment -> CHANGE_OUT only applies to cash; electronic overpayment needs another settlement path.
- T-23 tip should be an allocation/component linked to the payment; total payment still reconciles the full amount.
- T-24 complimentary giveaway must not collapse into `INTERNAL_CONSUMPTION`.
- T-28 changing product may be an amendment before fulfillment; not necessarily VOID + new ORDER.
- T-31 closing without count should support emergency/incomplete close state rather than necessarily hard-block operation.
- T-45 physical intercompany transfer must still be recordable even when transfer price policy is `UNDEFINED/PENDING`.
- T-47 contradicts DeepSeek’s own no-invoice/cost distinction.
- T-62 deletion/anonymization across audit logs/backups requires lifecycle/legal design, not unconditional propagation semantics.

## Canonical direction after Claude V2 + DeepSeek

Preserve these invariants:

1. `ORDER != FULFILLMENT != SALE != RECEIVABLE != PAYMENT != CASH_MOVEMENT != REFUND != RETURN != CREDIT_NOTE`.
2. `SALE != REVENUE_RECOGNITION`.
3. `PAYMENT_STATE != PAYMENT_METHOD` and `CLAIMED != CONFIRMED`.
4. `EVENT_ID != IDEMPOTENCY_KEY != BUSINESS_OPERATION_ID`.
5. Idempotency authority is a stable request/operation token + uniqueness scope; content/time are heuristics only.
6. `BUSINESS_OCCURRED_AT`, `DEVICE_RECORDED_AT`, `SERVER_RECEIVED_AT` remain distinct; duration quality can differ from wall-clock quality.
7. `NO SILENT OVERWRITE`; corrections are typed append-only semantic events.
8. Evidence/provenance state is distinct from business truth.
9. UOM original is preserved; conversions require verified mapping/factor.
10. Inventory reconciliation is a signed movement ledger by item/UOM; variance is derived.
11. Lot lineage is preserved through split/merge/transformation; unknown proportions degrade precision, not history.
12. Decision Memory preserves what was known when the decision occurred; post-hoc additions are explicitly marked.
13. Derived learning is reviewable/supersedable and never silently becomes fact; `valid_to` is optional.
14. Retention is lifecycle/policy-driven, not forever by default.
15. Decision gates scale with materiality, irreversibility, uncertainty and authority; human overrides remain auditable where policy allows.
16. Unknown is a valid explicit state.

## Gate

No Claude V3 is required now. The next action is ChatGPT semantic synthesis into a canonical Day-0 evidence/event contract. No production coding of this contract is authorized while IQG-001.2 remains open.
