# Cross-AI Synthesis — Universal Market Intelligence & Decision Engine V1

Date: 2026-09-16
Coordinator: ChatGPT / Chief Architect & AI Council Coordinator
Status: `SYNTHESIS_READY / DESIGN_DIRECTION_ACCEPTED / LIVE_EVIDENCE_COLLECTION_CONTINUES`

## 1. Inputs reviewed

This synthesis integrates:
- Claude cross-vertical challenge: useful critique of over-universalization and demand-first assumptions, with corrections.
- DeepSeek Market Memory red team: accepted with material corrections; strong on contamination, causality, semantic collision, feedback loops and margin-negative growth.
- Gemini Bolivia social evidence excavation V2: useful research backlog, but live-evidence quota not met because of declared access limitations.
- Canonical IQ GROWTH Core and Universal Market Intelligence documents.

## 2. Main architectural conclusion

Market Intelligence is **not** the Growth Engine itself. It is one evidence-producing layer feeding a broader decision engine.

Canonical direction:

`BUSINESS STATE + MARKET EVIDENCE + ECONOMICS + CONSTRAINTS + OBJECTIVE -> DECISION / ACTION -> EXECUTION -> OUTCOME -> MEMORY`

Where:

### Business State
- resources
- capacity
- inventory/lots/serialized units
- people/roles
- operating calendar
- cost structure
- cash/working-capital state where available
- operational incidents/constraints

### Market Evidence
- public/social evidence
- first-party customer evidence
- competitor offers
- prices/availability
- buyer needs/intention/budget where explicitly observed
- complaints/preferences
- delivery/trust/warranty friction

### Economics
- contribution
- landed cost / direct cost
- channel cost
- fulfillment cost
- working-capital implications
- risk/returns/warranty where relevant

### Constraints
- production capacity
- biological cycles
- kitchen throughput
- stock / supplier availability
- capital
- logistics
- compliance

## 3. Universal vs optional

### Universal structural capabilities
- provenance/evidence
- organization/company/branch isolation
- parties/relationships
- item/service identity
- temporally valid price/cost
- inventory/resource state
- order/sale/payment/cash separation
- audit history
- decision record
- experiment/action record
- outcome record

### Reusable optional capabilities
- buyer-state ladder
- quotation lifecycle
- BOM/recipe
- batch/lot traceability
- serial/IMEI traceability
- landed cost
- production order
- delivery/logistics
- messaging/CRM
- supplier verification
- financing-state tracking

### Vertical adapters
Restaurant, agro/coffee, chocolate manufacturing/distribution and technology sourcing each retain their own domain semantics.

## 4. Memory architecture

Do not build one undifferentiated "Market Memory".

Separate at minimum:

1. `RAW_EVIDENCE_MEMORY`
2. `MARKET_SIGNAL_MEMORY`
3. `DECISION_MEMORY`
4. `EXPERIMENT_MEMORY`
5. `TRANSACTION_OUTCOME_MEMORY`
6. `DERIVED_LEARNING_MEMORY`

Every derived learning must be traceable backward to evidence and interventions.

Suggested lineage:

`LEARNING -> OUTCOME -> ACTION/EXPERIMENT -> HYPOTHESIS -> SIGNAL -> RAW EVIDENCE -> SOURCE`

## 5. Intervention-awareness requirement

The system must record its own actions before learning from the resulting market state.

Required fields/concepts should include:
- intervention/action id
- start/end
- target scope
- cost
- promotion/channel/price/content change
- baseline window
- comparison/holdout method when feasible
- outcome window
- confounders observed

This prevents self-fulfilling loops such as:

`promote product -> product sells more -> system concludes natural demand rose -> promote more`.

## 6. Semantic isolation

Shared labels must not imply shared meaning across verticals.

Use explicit semantic namespaces / concept types. Examples:
- restaurant.inventory.raw_material
- coffee.inventory.green_lot
- chocolate.inventory.finished_goods
- technology.inventory.serialized_unit

Do not aggregate "stock", "margin", "ticket", "lot", "quality" or similar labels cross-vertical without a defined semantic mapping.

## 7. Evidence authority model

No single fixed rule like "one source is never enough" is universal.

Evidence strength must consider:
- source authority
- first-party vs external
- directness
- freshness
- corroboration
- materiality of the decision
- reversibility
- uncertainty

A first-party payment or official legal source may support a material fact alone; a social post normally cannot.

## 8. Prediction doctrine

Prediction is allowed only as a versioned hypothesis with uncertainty.

`PREDICTION != FACT`

Required concepts:
- prediction scope
- evidence window
- confidence/uncertainty
- expected outcome
- observed outcome
- error score
- calibration history

The system must be able to prove when it was wrong.

## 9. Privacy and identity

Separate identifiable CRM/customer data from aggregate/de-identified Market Memory.

Rules:
- first-party authorized customer identity may exist in CRM;
- Market Memory is aggregate/de-identified by default;
- no cross-platform identity resolution of ordinary people without authorization;
- no wealth inference from neighborhood/device/appearance;
- no private third-party data access or bypass.

## 10. Day-0 instrumentation

Lack of digital capture does not exclude Café Zacarías or Chocolates.

They begin with Day-0 instrumentation:
- manual sale capture
- route/vendor capture
- stock issued/returned
- quantity sold
- price
- channel
- date/time
- lot/batch where relevant
- buyer type if legitimately known

`NOT_DIGITIZED != NOT_OBSERVABLE`

## 11. Gemini evidence status

Gemini V2 did not deliver 120 live observations. It delivered 120 research tasks.

Therefore:
- do not treat its backlog as market evidence;
- do not create demand scores from it;
- use it to guide legitimate evidence collection;
- re-use Gemini later when a real captured corpus exists.

## 12. Current implementation gate

Do not implement the Market Memory/Decision Engine in production code yet.

Reason:
- IQG-001.2 Core runtime gate is still active under Codex;
- cross-vertical architecture has improved but requires a stable evidence contract before code;
- live external evidence collection remains incomplete.

Allowed now:
- documentation refinement;
- evidence schema refinement;
- manual/first-party Day-0 collection design;
- source adapter contract design at conceptual level;
- adversarial test catalog.

Blocked now:
- production Market Memory code;
- automated causal engine;
- global demand score;
- automatic investment decisions;
- cross-platform personal identity graph.

## 13. Next evidence priorities

### VANSAM
- complete clean-cycle POS/order/payment sample;
- product/size mix;
- prep/fulfillment times;
- contribution by SKU/size where costs known;
- complaints/repeat data;
- public competitor/review evidence with provenance.

### Café Zacarías
- Day-0 lot/inventory/channel sales capture;
- actual prices by line/format/channel;
- batch/roast dates;
- reseller/vendor movement;
- current demand evidence by channel/city.

### Chocolates
- Day-0 production batch + sales/channel capture;
- packaging/occasion/seasonality evidence;
- cost by lot;
- current wholesale/retail demand evidence.

### IPCENTER
- recover historical first-party transactions/quotes/logistics when authorized;
- exact current SKU price/stock/warranty map;
- buyer requests with city/use/budget/timing;
- national fulfillment and warranty evidence.

## 14. Final status

`CROSS_VERTICAL_DESIGN_DIRECTION = ACCEPTED_WITH_REFINEMENT`

`MARKET_INTELLIGENCE = EVIDENCE_LAYER`

`DECISION_ENGINE = BUSINESS_STATE + MARKET_EVIDENCE + ECONOMICS + CONSTRAINTS + OBJECTIVE`

`MARKET_MEMORY_CODE = BLOCKED_UNTIL_CORE_GATE_AND_EVIDENCE_CONTRACT`

`LIVE_EVIDENCE_COLLECTION = ACTIVE`
