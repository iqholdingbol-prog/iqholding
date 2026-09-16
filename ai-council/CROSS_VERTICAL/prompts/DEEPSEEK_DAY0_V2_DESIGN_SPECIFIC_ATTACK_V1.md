# DEEPSEEK — DAY-0 V2 DESIGN-SPECIFIC ADVERSARIAL ATTACK V1

**Date:** 2026-09-16  
**Project:** IQ GROWTH / IQHOLDING  
**Role:** Red Team / Data Integrity / Economic Integrity / Event Semantics

## Mission

Attack the exact Claude Day-0 Instrumentation V2 design after ChatGPT review. This is NOT another generic list of fraud or operational risks.

Your task is to prove where the proposed field/event contracts, reconciliation logic, offline model, money semantics, route/batch semantics, Decision Memory and universal event envelope can still create false truth or irreversible architecture mistakes.

Read first if accessible:

1. `ai-council/CROSS_VERTICAL/reports/2026-09-16_chatgpt_review_claude_day0_instrumentation_v2.md`
2. the exact Claude V2 response supplied with this mission.

If either source is not accessible and is not pasted into your context, respond exactly:

`SOURCE_ACCESS_FAILURE`

Do not pretend to have audited text you cannot see.

## Canonical constraints

Preserve these distinctions:

`ORDER != FULFILLMENT != SALE != RECEIVABLE != PAYMENT != CASH_MOVEMENT != REFUND != RETURN != CREDIT_NOTE`

`RAW EVIDENCE != EXTRACTION != CONFIRMED FACT`

`EVENT_ID != IDEMPOTENCY_KEY`

`DEVICE TIME != SERVER RECEIVED TIME != BUSINESS OCCURRED TIME`

`SELLER CLAIM != VERIFIED STOCK`

`CUSTOMER DECLARED REASON != TRUE WILLINGNESS TO PAY`

`OBSERVED EVENT != CAUSAL EXPLANATION`

`NO SILENT OVERWRITE`

## Attack method

For every defect use this exact structure:

`CLAUDE_CLAIM_OR_CONTRACT -> FAILURE MECHANISM -> FALSE STATE PRODUCED -> BUSINESS DECISION DAMAGED -> HOW TO REPRODUCE -> MINIMUM SAFE CORRECTION -> RESIDUAL RISK`

Do not reward complexity. If a simpler correction works, prefer it.

## 1. Money-state-machine attack

Attack Claude's definitions and 18 VANSAM reconciliation cases.

At minimum test:

- order before payment;
- payment before sale;
- deposit before procurement;
- partial payment;
- overpayment;
- credit/fiado;
- unidentified dine-and-dash;
- identified receivable;
- refund without physical return;
- physical return without refund;
- partial return;
- credit note;
- payment reversal/chargeback;
- incorrect payment method metadata;
- delivery charge retained by third party;
- tips;
- owner/staff consumption;
- complimentary/promotional item;
- gift card/store credit if later enabled;
- cash drawer expense;
- intercompany settlement.

Determine whether `SALE = delivered and revenue recognized` is semantically unsafe. Propose the smallest event/state separation needed without inventing accounting law.

## 2. Idempotency / duplicate / retry attack

Attempt to break `event_id` based duplicate protection.

Required cases:

- double tap creates two UUIDs;
- network timeout after server commit but before client ACK;
- retry from same device;
- retry from different device;
- offline replay after reinstall;
- two operators enter the same real order independently;
- two legitimate identical orders within seconds;
- restored local queue replays already acknowledged events;
- message arrives twice through future connector/webhook.

Distinguish:

`event_id`
`idempotency_key`
`business_operation_id`
`device_local_sequence`
`server_ack`
`correlation_id`

Do not recommend content+time deduplication as authoritative if it can merge valid transactions.

## 3. Offline temporal-order attack

Attack Claude's timestamp model.

Test:

- clock 45 minutes wrong;
- timezone wrong;
- device clock manually changed mid-shift;
- imported data uses another timezone;
- event captured offline for 8 hours;
- sequence A/B recorded on different devices with incompatible clocks;
- backfill intentionally claims earlier occurrence;
- sync order differs from actual business order.

Return a minimum temporal contract capable of expressing uncertainty without silently rewriting `occurred_at`.

## 4. Correction / reversal / amendment attack

Attack the phrase "contra-asiento" wherever Claude uses it.

Determine when the correct mechanism is:

- metadata amendment;
- void;
- reversal;
- refund;
- return;
- credit note;
- replacement event;
- compensating cash movement;
- inventory disposition;
- no financial change.

Show at least 20 cases where using one generic correcting event would corrupt semantics.

## 5. VANSAM operational contract attack

Attack the selected VANSAM fields and the fact that Claude did not provide the requested full field-by-field contract.

Find minimum P0 vs later fields.

Specifically test:

- continuity/opening;
- kitchen timestamps;
- order amendments;
- split payments;
- half-and-half/modifiers;
- delivery fees;
- customer identity optionality;
- anonymous cash sale;
- waste;
- internal consumption;
- cash close;
- stock consumption;
- duplicate touch/sync;
- offline outage.

Return fields that are missing, redundant, overly blocking, or too expensive for Day-0.

## 6. Café route + lot lineage attack

Attack:

`ROUTE_SESSION`
`STOCK_LOAD`
`STOCK_RETURN`
`ROUTE_SALE`
`ROUTE_CASH`
`ROUTE_VARIANCE`
`LOT_SPLIT`
`LOT_MERGE`
`transformation_event`

Required cases:

- sample/gift on route;
- damage;
- internal use;
- transfer between sellers/routes;
- cash sale + QR sale;
- receivable;
- stock returned in damaged condition;
- stock transferred to another route without returning to warehouse;
- UOM conversion later verified;
- source lots merged with known proportions;
- merge proportions unknown;
- coproducts;
- partial process at two locations;
- quantity measurement error corrected later.

Prove whether `loaded - sold - returned` is enough. Preserve lineage when possible; degrade precision explicitly when not.

## 7. Chocolates batch/disposition attack

Attack batch semantics with at least 20 concrete failure cases:

- formula version changed mid-batch;
- packaging-only change;
- raw material no invoice but payment proof exists;
- raw material invoice exists but wrong quantity received;
- rework;
- mixed source lots;
- promotional giveaway;
- sample;
- staff consumption;
- donation;
- damage/melting;
- consignment;
- wholesale return rights;
- price-list vs applied transaction price;
- partial lot recall;
- finished-goods relabeling;
- batch split;
- batch merge/repack;
- expired product;
- uncertain shelf life.

Do not collapse all non-sales dispositions into `INTERNAL_CONSUMPTION`.

## 8. IPCENTER graph attack

The proposed sequence is too linear. Attack it as a graph.

Required paths:

- inquiry -> quote -> reject;
- inquiry -> deposit -> procurement -> payment balance -> fulfillment;
- quote -> accepted -> supplier stock disappears;
- procurement -> supplier cancellation;
- payment before physical item exists;
- fulfillment before final payment under agreed credit;
- return/warranty replacement;
- customer changes exact variant after deposit;
- supplier sends wrong serial/model;
- historical WhatsApp price with no sale;
- bank transfer with unknown transaction link.

Identify which references establish causality between events without forcing one fixed order.

## 9. Decision Memory / causality attack

Attack:

`DECISION_EVENT`
`DECISION_RATIONALE`
`EVIDENCE_SNAPSHOT_REF`
`INTERVENTION_EVENT`
`CONFOUNDER_EVENT`
`OUTCOME_OBSERVATION`
`CAUSALITY_ASSESSMENT`
`DERIVED_LEARNING`

Required distinctions:

- observed confounder event vs confounder hypothesis;
- human rationale vs AI recommendation rationale;
- decision made offline then entered later;
- evidence snapshot selected after outcome is known;
- omitted counterevidence;
- multiple simultaneous interventions;
- learning remains valid until contradicted vs arbitrary expiry;
- experiment with multiple factors;
- reversible observation vs causal claim.

Try to create a system that looks auditable but still rewrites history honestly-looking.

## 10. Universal event envelope attack

Attack every proposed envelope field:

`event_id`
`event_type`
`schema_version`
`tenant_id/company_id`
`location_id`
`occurred_at`
`recorded_at`
`timestamp_source`
`clock_verified`
`actor_role`
`actor_id`
`capture_modality`
`evidence_refs`
`correction_of`
`sync_state`
`confidence_state`
`payload`

Test whether it also needs or should avoid:

- `idempotency_key`;
- `producer/source_system`;
- `device/source_instance`;
- `correlation_id`;
- `causation_id`;
- `principal_type`;
- `provenance_class`;
- `business_operation_id`;
- schema registry reference.

Reject unnecessary fields. Do not turn the envelope into another giant universal entity.

Check whether `vansam.order.created` is improper hardcoding. Prefer reusable domain namespace where justified.

## 11. Retention/privacy attack

Claude proposed permanent evidence retention in several rows.

Attack:

- PII in receipts/photos;
- customer phones;
- WhatsApp screenshots;
- audit narratives;
- backups;
- Decision Memory references;
- historical artifacts;
- deletion/anonymization request;
- legal hold;
- evidence required for accounting/warranty vs unnecessary retained PII.

Return a lifecycle model, not legal conclusions. Mark jurisdiction-specific obligations `LEGAL_REVIEW_REQUIRED`.

## 12. Decision-gate attack

Attack all 40 decision rows, especially these candidate overblocks:

- price changes;
- VANSAM hamburger test;
- Café continuing to sell while costing is incomplete;
- route/channel test;
- Senkata investment;
- IPCENTER reopening;
- IPCENTER stock purchase;
- delivery to a new city;
- intercompany transfer.

Classify decisions as:

`CONTINUE_CURRENT_OPERATION`
`REVERSIBLE_TEST`
`MATERIAL_CHANGE`
`IRREVERSIBLE_CAPITAL_DECISION`

For each gate, demand evidence proportional to materiality/reversibility rather than perfect knowledge.

## 13. Minimum trustworthy Day-0 dataset

After attacking everything, produce the minimum viable trusted dataset separately for:

- VANSAM;
- Café Zacarías;
- Chocolates;
- IPCENTER.

For each field/event classify:

`MUST_DAY0`
`SHOULD_DAY0`
`LATER`
`REJECT`

For every `MUST_DAY0`, state the exact decision or reconciliation that fails without it.

Do not optimize for number of fields. Optimize for truth per unit of operator friction.

## 14. Test pack

Produce at least 60 design-specific adversarial tests mapped to the exact proposed contracts.

Each test must include:

`PRECONDITION -> ACTION -> EXPECTED EVENT GRAPH -> FORBIDDEN FALSE STATE -> PASS CRITERION`

No arbitrary numeric thresholds.

## 15. Final reconciliation

Return four lists:

`ACCEPT_FROM_CLAUDE_V2`
`ACCEPT_WITH_CORRECTION`
`REJECT`
`MISSING`

Then return:

- `CRITICAL_ARCHITECTURAL_FAILURES`
- `SEMANTIC_COLLISIONS`
- `IDEMPOTENCY_FAILURES`
- `OFFLINE_FAILURES`
- `ECONOMIC_FALSEHOODS`
- `PRIVACY_RETENTION_FAILURES`
- `MINIMUM_TRUSTWORTHY_DATASET`
- `DAY0_V2_ADVERSARIAL_TEST_PACK`
- `RESIDUAL_RISKS`
- `RECOMMENDED_CANONICAL_INVARIANTS`

## Discipline

Do not invent business facts.
Do not invent legal rules.
Do not invent thresholds.
Do not give generic fraud lists already covered by V1.
Do not redesign the whole Core.
Do not make controls more expensive than the risk they mitigate.

Final line exactly:

`CLAUDE DAY0 V2 DESIGN-SPECIFIC RED TEAM READY FOR CHATGPT SYNTHESIS`