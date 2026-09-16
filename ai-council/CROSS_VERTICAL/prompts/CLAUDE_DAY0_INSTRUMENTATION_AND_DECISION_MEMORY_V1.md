# CLAUDE — DAY-0 INSTRUMENTATION & DECISION MEMORY V1

Date: 2026-09-16
Project: IQ GROWTH / IQHOLDING
Role: Product/Systems Challenger

## Mission
Design the minimum viable **Day-0 instrumentation** needed for VANSAM, Café Zacarías, Chocolates and IPCENTER so IQ GROWTH can start collecting decision-grade first-party evidence **before** advanced automation exists.

Do not code. Do not redesign the Core. Do not invent sales, prices, margins, demand or customer behavior.

Your task is to answer: **what must each business capture, who captures it, when, with how much friction, and which decisions become possible from those fields?**

Use the canonical architecture:
`CORE UNIVERSAL -> CAPABILITIES -> VERTICAL ADAPTER -> COMPANY CONFIG`

Use the evidence principle:
`NO SOURCE -> NO FACT`
`ORDER != SALE != PAYMENT != CASH_MOVEMENT`
`OBSERVATION != SIGNAL != DEMAND != PURCHASE != PROFIT`

## Required outputs

### 1. Day-0 operating truth map
For each of the four businesses, map the real operating events that can be captured from day one. Include at minimum:
- sale/order/request
- payment/cash state
- item/product/variant
- quantity/unit
- price actually charged
- channel/location
- timestamp
- operator/collector
- fulfillment state
- customer identity only where justified and authorized
- cost/provenance state where available
- exception/incident

Mark each field as:
`REQUIRED_DAY0`, `OPTIONAL_DAY0`, `LATER`, or `DO_NOT_CAPTURE`.

### 2. Friction budget
For every capture step estimate qualitatively:
- who performs it
- when
- time/friction burden
- failure risk
- whether it can be inferred safely or must be explicit

Do not invent numeric time thresholds unless evidence exists.

### 3. Minimum forms / screens / paper fallback
For each business define the smallest practical capture surface:
- VANSAM front-of-house / kitchen / close
- Café sales / lot / roast / route / wholesale
- Chocolates production / sale / wholesale / batch
- IPCENTER inquiry / quote / sourcing / payment / delivery

Include an **offline/manual fallback** that still preserves provenance.

### 4. Decision Memory contract
Define what must be stored whenever a material business decision is made:
- decision_id
- business/company/branch
- decision owner
- decision time
- objective
- evidence used
- assumptions
- alternatives considered
- chosen action
- expected outcome
- reversal criteria
- actual outcome
- post-decision learning state

Do not allow inference to be persisted as fact.

### 5. Which decisions become possible
For each Day-0 datum, state the concrete decision it can support. If a datum does not change a decision, challenge whether it should exist.

### 6. Anti-overinstrumentation
Identify at least 30 tempting fields/features that should NOT be collected yet because they create burden, privacy risk, false precision or no decision value.

### 7. Transition path
Show how Day-0 manual capture can later migrate into IQ GROWTH without rewriting history. Preserve raw source, original unit, original price, timestamps and provenance.

### 8. Cross-vertical boundary test
Identify what is truly universal vs capability vs vertical-specific vs company-config. At least 25 boundary decisions.

### 9. Failure conditions
List at least 25 ways this instrumentation could fail operationally: skipped entry, fake completion, wrong SKU, wrong time, missing payment, duplicate customer, backfilled data, operator gaming, offline gaps, etc.

### 10. Final recommendation
Return:
- `DAY0_MINIMUM_UNIVERSAL_SET`
- `VANSAM_DAY0_SET`
- `CAFE_DAY0_SET`
- `CHOCOLATE_DAY0_SET`
- `IPCENTER_DAY0_SET`
- `DECISION_MEMORY_V1`
- `DO_NOT_BUILD_YET`
- `OPEN_CONTRADICTIONS`

Do not propose another AI round.
Do not write code.
Do not claim market truth.

Final line exactly:
`DAY0 INSTRUMENTATION AND DECISION MEMORY READY FOR CHATGPT AUDIT`