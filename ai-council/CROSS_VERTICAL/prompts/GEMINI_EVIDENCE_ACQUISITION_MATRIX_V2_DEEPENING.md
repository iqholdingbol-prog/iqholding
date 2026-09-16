# GEMINI — EVIDENCE ACQUISITION MATRIX V2 / DEEPENING

**Date:** 2026-09-16
**Project:** IQ GROWTH / IQHOLDING
**Role:** Market Intelligence / External Evidence

## Mission
Your V1 was useful but incomplete and semantically unsafe in several places. Build the full executable evidence-acquisition system for VANSAM, Café Zacarías, Chocolates and IPCENTER.

Do not produce market conclusions. Do not treat search tasks, seller offers, engagement or competitor prices as proof of buyer willingness-to-pay or purchase.

## Hard semantic ladder

`QUERY != OBSERVATION`
`OBSERVATION != SIGNAL`
`SIGNAL != INTENT`
`INTENT != QUOTE`
`QUOTE != ACCEPTANCE`
`ACCEPTANCE != PAYMENT`
`PAYMENT != FULFILLMENT`
`FULFILLMENT != PROFIT`

For every evidence item/task, state **what it can prove** and **what it cannot prove**.

## Mandatory evidence classes

Use these explicitly where applicable:
- `OBSERVED_PUBLIC_OFFER`
- `SELLER_CLAIM`
- `PUBLIC_BUYER_SIGNAL`
- `FIRST_PARTY_INQUIRY`
- `FIRST_PARTY_DECLARED_BUDGET`
- `FIRST_PARTY_QUOTE`
- `QUOTE_ACCEPTED`
- `DEPOSIT_OR_PREPAYMENT`
- `PAYMENT_VERIFIED`
- `FULFILLMENT_VERIFIED`
- `REPEAT_PURCHASE`
- `COMPLAINT_OR_RETURN`
- `FIELD_OBSERVATION`
- `OFFICIAL_OR_PRIMARY_SOURCE`
- `ACCESS_LIMITATION`

Do not collapse them.

## Full backlog requirement

Take the prior V2 backlog and produce complete coverage.

For EACH business return:
- top 10 P0 acquisition tasks;
- next 10 P1 acquisition tasks;
- P2/defer/reject queue;
- at least 25 total weak/redundant/low-decision-value tasks rejected across the four businesses.

No decorative tasks.
No vanity metrics.
No weak proxies unless clearly labeled as weak context.

## Required row schema

Every P0/P1 task must include:
- business
- task_id
- exact decision question
- exact research question
- decision type
- reversibility: REVERSIBLE / PARTLY_REVERSIBLE / HARD_TO_REVERSE
- materiality: LOW / MEDIUM / HIGH without invented monetary threshold
- expected evidence class
- preferred source class
- platform/source family
- access state
- collector type exactly one or more of:
  - CHATGPT_WEB
  - HUMAN_PUBLIC
  - HUMAN_AUTHENTICATED
  - FIRST_PARTY_OWNER
  - API_AUTHORIZED
  - LICENSED
  - FIELD_OBSERVATION
- exact fields to capture
- source URL/reference requirement
- observed_at requirement
- geography/microzone
- freshness requirement and why
- verification method
- corroboration method
- duplicate risk
- seller-generated bias risk
- selection bias risk
- privacy risk
- cost/friction
- fallback source
- stop condition
- stop condition state: `COLLECTION_TARGET_TO_CALIBRATE` unless evidence justifies otherwise
- what this evidence CAN prove
- what this evidence CANNOT prove
- decision allowed if evidence is obtained
- decision still blocked after this evidence
- P0/P1/P2/REJECT

## Priority doctrine

When decision-relevant, prefer:
1. first-party transaction/payment/quote/order evidence;
2. direct first-party buyer inquiry/budget/rejection/return evidence;
3. verified current seller offer with exact price/stock/warranty/fulfillment;
4. official/primary source;
5. corroborated public buyer signals;
6. indirect public trend/proxy evidence.

Public competitor evidence is CONTEXT unless stronger evidence exists.

## VANSAM corrections

Do NOT ask public competitor menus to reveal a `real family budget ceiling`.
They can reveal only the current OFFER LANDSCAPE.

P0 must prioritize own:
- order/transaction mix;
- item/size mix;
- price actually paid;
- lost/abandoned order reason where observable;
- payment method;
- fulfillment time;
- cancellation/refund/rework;
- complaint;
- delivery result;
- repeat purchase;
- open/closed continuity;
- contribution when costs are available.

Public evidence can contextualize:
- competitor offers;
- public complaints;
- delivery terms;
- service promises;
- promotion patterns.

Do not calculate complaint prevalence from only negative reviews without denominator and sampling design.

## Café Zacarías corrections

Do not assume an active `Matte 250g` product unless explicitly documented.
The business has multiple lines, presentations and channels.

P0 should cover:
- actual current sale by line/presentation/channel;
- seller/route/point;
- stock loaded/sold/returned;
- price actually received;
- payment/receivable;
- reorder/repeat;
- wholesale inquiry/quote/acceptance;
- current competitor offer landscape by comparable presentation;
- actual customer objections where first-party evidence exists.

Do not infer price rejection threshold from competitor prices.

For B2B capture actual:
- requested volume;
- quote;
- accepted/rejected;
- declared reason;
- payment terms;
- delivery requirement;
- reorder.

Do not assume counterpart will disclose its internal margin requirement.

## Chocolates corrections

Do not infer `sweet spot` purchase price from public offer engagement.

Separate:
- observed seasonal OFFER LANDSCAPE;
- public buyer signals;
- own quote/order/payment evidence;
- gifting occasion;
- box/presentation;
- unit economics;
- delivery/temperature incidents;
- repeat/reorder.

Do not assume refrigerated 3PL is necessary before product stability/handling requirements are documented.

Expansion logistics is gated by:
product requirement + contribution + route demand + verified logistics quote.

## IPCENTER corrections

Remove unsupported claims such as:
- `difference > Bs 800 loses the sale`;
- `below that, local warranty closes the deal`.

Those may only exist as `HYPOTHESIS_TO_TEST` if there is first-party evidence.

Exact-SKU comparison must normalize:
- exact model/part number/configuration;
- condition;
- seller;
- stock status;
- observed date/time;
- price/currency;
- taxes/fees when known;
- shipping;
- warranty;
- return policy;
- delivery lead time;
- provenance.

Prioritize B2C live learning:
- customer request;
- city;
- use case/exact model;
- budget where declared;
- quote;
- accepted/rejected;
- reason when known;
- payment/deposit;
- fulfillment;
- warranty outcome.

Keep B2B as a separate lane. Do not let it displace B2C priority.

## Access integrity

Do not mark a surface accessible unless the current collector can actually access it.

For every task assign one or more real routes:
- CHATGPT_WEB
- HUMAN_PUBLIC
- HUMAN_AUTHENTICATED
- FIRST_PARTY_OWNER
- API_AUTHORIZED
- LICENSED
- FIELD_OBSERVATION

If access is not currently available:
`ACCESS_LIMITATION`

Then provide a legitimate fallback.

No private third-party data.
No bypass.
No unauthorized scraping.
No ordinary-person cross-platform identity linking.
No sensitive-trait inference.

## Mystery-shopping rule

Do not rely on false identity, fabricated purchase commitment, fake reservation, or unnecessary burden on another business.

Legitimate public price/term inquiry is acceptable when the collector does not misrepresent material facts.

## Four phone-ready capture packets

Produce:
- `VANSAM_EVIDENCE_PACKET`
- `CAFE_ZACARIAS_EVIDENCE_PACKET`
- `CHOCOLATES_EVIDENCE_PACKET`
- `IPCENTER_EVIDENCE_PACKET`

Each packet must contain the SMALLEST row schema a collector can fill on a phone while preserving provenance.

Each packet must include:
- capture_id
- business
- collector
- captured_at
- observed_at if different
- source class
- platform/source
- URL/reference/photo/chat/order/receipt reference
- city/microzone
- entity/business/seller
- product/service/variant
- raw observed text or fact
- price/budget/currency if present
- stock/availability if present
- warranty/fulfillment if present
- buyer-state/evidence-class
- confidence
- bias note
- duplicate group
- privacy classification
- decision relevance
- verification state

Keep optional fields optional. Do not force fields irrelevant to a vertical.

## Coverage map

Return a matrix showing what can realistically be collected by:
- ChatGPT public web
- human public browser/social session
- human authenticated session
- authorized first-party WhatsApp/POS/CRM
- field observation
- future API/connector
- licensed provider

For each surface include:
- current accessibility
- what evidence class it can yield
- major bias
- major limitation
- fallback.

## Final required queues

Return exactly these sections:
1. `P0_ACQUISITION_QUEUE`
2. `P1_ACQUISITION_QUEUE`
3. `DEFER_OR_REJECT_QUEUE`
4. `HUMAN_CAPTURE_PACKETS`
5. `CHATGPT_WEB_QUEUE`
6. `HUMAN_PUBLIC_QUEUE`
7. `FIRST_PARTY_RECOVERY_QUEUE`
8. `FIELD_OBSERVATION_QUEUE`
9. `ACCESS_GAPS`
10. `DATA_QUALITY_CHECKS`
11. `UNSUPPORTED_CLAIMS_REMOVED_FROM_V1`
12. `SELF_AUDIT`

## Self-audit

At the end, inspect your own matrix for at least 20 failure modes:
- proxy mistaken for purchase;
- seller claim mistaken for fact;
- stale price;
- duplicate seller/post;
- same product non-comparable variant;
- engagement inflation;
- missing denominator;
- geography mismatch;
- seasonality;
- source selection bias;
- first-party sample bias;
- price without stock;
- stock without exact variant;
- warranty ambiguity;
- shipping omitted;
- tax/fee omitted;
- false identity link;
- privacy leakage;
- unsupported causal conclusion;
- arbitrary sufficiency threshold.

For each: failure -> detection -> correction.

No market conclusion from unexecuted tasks.
No invented thresholds.
No invented demand.
No invented willingness-to-pay.
No invented conversion.

Final line exactly:
`EVIDENCE ACQUISITION MATRIX V2 DEEPENING READY FOR CHATGPT AUDIT`
