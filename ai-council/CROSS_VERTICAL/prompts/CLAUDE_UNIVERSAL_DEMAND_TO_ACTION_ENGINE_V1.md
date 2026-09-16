# CLAUDE — UNIVERSAL DEMAND-TO-ACTION ENGINE CHALLENGE V1

Date: 2026-09-16
Role: Product / Systems Challenger
Scope: IQ GROWTH cross-vertical architecture

## Mission

Attempt to prove or break the hypothesis that IQ GROWTH can use one universal demand-to-action intelligence model across VANSAM, Café Zacarías, Chocolates (brand pending), and IPCENTER without reducing any of them to a generic CRM/marketing abstraction.

The business objective is not to collect data. It is to identify where a real customer need intersects with ability/willingness to buy, present the right offer/channel/timing, measure the result, and learn.

Core idea to challenge:

`OBSERVATION → SIGNAL → CORROBORATION → HYPOTHESIS → CONTROLLED ACTION → TRANSACTION/OUTCOME → LEARNING → MARKET MEMORY`

No invented numbers. No arbitrary thresholds. No generic consultant language.

## Required repository reading

If repository access exists, read at minimum:
- `docs/IQG_UNIVERSAL_MARKET_INTELLIGENCE_DATA_MODEL_V1.md`
- `docs/IQG_INFORMATION_ADVANTAGE_DOCTRINE_V1.md`
- `ai-council/AI_COUNCIL_QUALITY_GATE_V1.md`
- `docs/CEO_CORRECTIONS_2026-09-15.md`
- `docs/IQG-005_IPCENTER_VERTICAL_V1.md`
- `docs/IQG-100_VANSAM_BASELINE_V1.md`
- relevant 2026-09-16 IQG-005 synthesis/reviews

If access does not exist, state that explicitly and work only from supplied context. Never pretend to have read a source.

## Hard constraints

1. Universal Core must not hardcode pizza, coffee, chocolate, laptop, cellphone, drone, etc.
2. Vertical adapters may add domain semantics.
3. `SIGNAL != DEMAND != PURCHASE != PROFIT`.
4. `ORDER != SALE != PAYMENT != CASH_MOVEMENT != FULFILLMENT`.
5. No individual wealth inference from neighborhood, photos, device, appearance, surname or social profile.
6. Social data is evidence, not truth.
7. First-party transaction evidence has different semantics from public-market evidence.
8. Historical facts must not be overwritten by newer assumptions.
9. Do not create a giant autonomous-agent architecture if a smaller system works.
10. “Magic for the user” means complexity hidden behind correct data and transparent uncertainty, not fake certainty.

## Tasks

### A. Universal primitives test

For each proposed primitive below, decide:
- UNIVERSAL_CORE
- REUSABLE_CAPABILITY
- VERTICAL_ADAPTER
- COMPANY_CONFIG
- REJECT_AS_OVERGENERALIZED

Primitives to test:
- observation
- source/provenance
- signal
- need
- buyer state
- budget/payment readiness
- product/service candidate
- offer
- price
- availability/capacity
- channel
- location
- fulfillment
- trust
- friction
- experiment/test
- conversion event
- transaction
- satisfaction
- repeat
- economic contribution
- market memory
- decision memory

Explain why each belongs where it does.

### B. Ready-to-buy customer model

Design a universal state machine that can represent a person who is ready or nearly ready to buy, but does not falsely equate a social signal with liquidity.

It must work for:
- someone wanting pizza tonight;
- someone buying coffee for home/resale;
- someone buying chocolate as a gift;
- someone with Bs X seeking an exact laptop/phone.

Separate:
- explicit need
- urgency
- willingness to pay
- stated budget
- accepted price
- payment ability actually demonstrated
- payment
- fulfillment
- repeat

### C. Minimum intake by vertical

For each of the four businesses, define the MINIMUM information needed before the system can make a useful next action.

For each field classify:
- REQUIRED_NOW
- ASK_LATER
- INFERABLE_WITH_LOW_RISK
- MUST_NOT_INFER

The goal is maximum usefulness with minimum customer friction.

### D. Decision-changing data

For every vertical identify the 15 highest-value data points that could materially change a real business decision.

For every data point provide:
- decision changed;
- source type;
- freshness requirement conceptually;
- risk if wrong;
- whether public evidence is enough or first-party evidence is required.

No arbitrary day counts unless evidence supports them; use TO_CALIBRATE where needed.

### E. Cross-vertical experiment engine

Design one experiment contract usable across all four businesses:

`HYPOTHESIS → TARGET → OFFER/ACTION → CHANNEL → START/END → COST → EXPOSURE → RESPONSE → TRANSACTION → MARGIN/CONTRIBUTION → RESULT → LEARNING`

Show four concrete examples, one per business, using only known facts or clearly labeled hypothetical values.

### F. Market Memory vs Decision Memory

Define what belongs in:
- Market Memory
- Customer/CRM history
- Decision Memory
- Transaction ledger
- Operational metrics

Prevent leakage where an inference becomes a “fact” merely because it was stored.

### G. What must NOT be universal

Find at least 20 concepts that should remain vertical-specific or company-configured.

Examples may include kitchen prep time, roast profile, cocoa %, GPU TGP, but do not stop there.

### H. Product/UX challenge

Design how the user-facing experience can feel simple while the back end remains evidence-heavy.

For each vertical show:
- customer input;
- invisible reasoning/data work;
- simple response/action;
- uncertainty disclosure when needed.

### I. Anti-bloat challenge

Identify at least 20 tempting features we should NOT build yet and the evidence gate that would justify them later.

### J. Failure modes

At least 30 cross-vertical failures in format:

`FAILURE → HOW IT HURTS GROWTH → EARLY SIGNAL → MITIGATION → RESIDUAL RISK`

Include:
- signal mistaken for demand;
- seasonality mistaken for baseline;
- price without stock;
- content engagement without conversion;
- stale data;
- wrong product variant;
- operational bottleneck invalidating marketing;
- margin-negative growth;
- duplicate customers;
- channel attribution errors;
- cross-business data contamination.

### K. Acceptance criteria

End with a proposed Quality Gate for the universal demand-to-action layer: what evidence would convince you that the model is truly reusable across the four laboratories without becoming generic or unsafe.

## Required output

A. Executive challenge verdict
B. Universal primitives matrix
C. Buyer-state machine
D. Minimum intake × 4 businesses
E. Decision-changing data × 4
F. Universal experiment contract
G. Market Memory / Decision Memory separation
H. What must remain vertical-specific
I. User-facing “magic” patterns
J. Anti-bloat list
K. 30+ failure modes
L. Quality Gate
M. Top 15 questions ChatGPT must resolve next

Final exact line:

`UNIVERSAL DEMAND-TO-ACTION CHALLENGE READY FOR CHATGPT AUDIT`
