# ChatGPT Audit — Gemini Evidence Acquisition Matrix V1

**Date:** 2026-09-16
**Project:** IQ GROWTH / IQHOLDING
**Reviewed artifact:** Gemini `EVIDENCE ACQUISITION MATRIX V1`
**Prompt:** `ai-council/CROSS_VERTICAL/prompts/GEMINI_EVIDENCE_ACQUISITION_MATRIX_V1.md`

## Verdict

`GEMINI_EVIDENCE_MATRIX_V1_PARTIALLY_USEFUL_BUT_MISSION_INCOMPLETE_AND_EVIDENCE_SEMANTICS_UNSAFE`

Gemini correctly avoided fabricating live social observations and attempted to prune weak research tasks, but the response does not satisfy the requested matrix and repeatedly confuses observed seller/competitor evidence with buyer willingness-to-pay, purchase probability, or causal sales thresholds.

## Major compliance gaps

The prompt required every prior V2 investigation to be classified/restructured, plus top 10 P0 and next 10 P1 per business, P2/defer/reject queues, four acquisition packets, a coverage map, at least 25 dropped searches, and final queues for human capture, ChatGPT web, first-party recovery and access gaps.

Gemini returned only a handful of tasks per business and omitted most required structures. Therefore the response cannot serve as the canonical acquisition matrix.

## Critical semantic corrections

### 1. Competitor price != willingness-to-pay ceiling
A competitor menu/post/catalog price is an `OBSERVED_OFFER`, not evidence of the maximum price a family will pay. Likes/comments likewise do not establish purchase.

Correct use: competitor price landscape, product composition, stated delivery/warranty/fulfillment terms, and public objections.

Willingness-to-pay requires stronger evidence such as first-party quote acceptance/rejection, controlled offer tests, completed purchase, deposit/payment, or appropriately designed experiments.

### 2. Public social engagement != demand
Questions such as `¿precio?`, `¿dónde entregas?`, likes, shares or comments are intent/supporting signals only. They must not be converted to `DEMAND` or `PURCHASE` without stronger evidence.

### 3. Seller offer != transaction
Marketplace/catalog offers indicate what sellers ask, not what buyers paid. Seller claims such as `vendido` require provenance and should remain seller-claimed unless independently corroborated.

### 4. Arbitrary thresholds are not facts
Statements such as `si la diferencia es > Bs 800 IPCENTER pierde la venta` or `si es menor la garantía local cierra el trato` are unsupported. They must be removed or converted to hypotheses requiring first-party testing.

Numeric stop conditions such as 15 menus, 20 reviews, 15 brands, 5 policies, 20 offers, 4 carriers, 10 SKUs or 20 objections may be operational sampling targets, but must be labeled `COLLECTION_TARGET_TO_CALIBRATE`; they are not evidence sufficiency thresholds.

## Business-specific corrections

### VANSAM
- Public competitor combo prices can map the offer landscape but cannot reveal a `real family budget ceiling`.
- Delivery complaint shares from negative reviews cannot estimate prevalence in the market without a defined denominator and sampling design.
- Owner replies do not verify that a complaint was objectively true; they are additional evidence only.
- P0 should prioritize first-party transactions, lost orders/abandonment, item mix, fulfillment time, delivery outcomes, complaint/rework/refund, payment and repeat behavior before social proxies.

### Café Zacarías
- Do not assume a canonical `Matte 250g` SKU unless documented as active/approved.
- Competitor specialty prices cannot reveal the price at which a Zacarías customer rejects a bag.
- `required_margin_%` from restaurants/hotels may be commercially sensitive and often unavailable; the more actionable first-party evidence is wholesale quote, requested terms, MOQ, accepted/rejected price, payment terms, delivery requirements and actual reorder.
- Public competitor evidence remains context, not demand proof.

### Chocolates
- Seasonal public offers and interaction do not identify a `sweet spot` purchase price.
- `high interaction` is not purchase evidence.
- Thermal logistics research is useful only after product stability/handling requirements are defined; avoid assuming all chocolate requires refrigerated 3PL.
- Expansion-city logistics should be gated by actual product specification, margin and route demand evidence.

### IPCENTER
- Remove the invented Bs 800 price-difference threshold and the claim that local warranty `closes the deal`.
- Exact-SKU one-to-one offer comparison is valuable if stock, condition, warranty, taxes, shipping, seller identity and observed date are normalized.
- Public trust objections are useful qualitative signals but should be crossed with first-party lost-sale reasons and completed transactions.
- B2C remains immediate learning priority; B2B workstation research is a separate lane and should not displace B2C evidence acquisition.

## Access and ethics corrections

`Mystery shopping` must not rely on false identity, false reservation, fabricated purchase commitment or unnecessary burden on third parties. Prefer public catalog capture, legitimate price/term inquiry, first-party historical evidence, or field observation.

No private third-party messages, bypass, unauthorized scraping, or cross-platform identity linking.

## Required V2 changes

1. Reconstruct the full backlog coverage instead of a small shortlist.
2. Separate `OFFER_LANDSCAPE`, `BUYER_SIGNAL`, `FIRST_PARTY_INTENT`, `QUOTE`, `ACCEPTANCE`, `PAYMENT`, `FULFILLMENT`, `OUTCOME`.
3. For every research question state exactly what the evidence can and cannot prove.
4. Prioritize first-party transaction/quote/payment evidence over public proxies.
5. Use the exact collector/access taxonomy from the prompt.
6. Add privacy, cost/friction, access state and expected evidence class fields.
7. Produce the four phone-ready human capture packets.
8. Produce explicit `CHATGPT_WEB_QUEUE`, `FIRST_PARTY_RECOVERY_QUEUE`, `HUMAN_PUBLIC_QUEUE`, `FIELD_OBSERVATION_QUEUE`, `ACCESS_GAPS`.
9. Drop at least 25 weak/redundant tasks with reason.
10. Treat stop counts only as `COLLECTION_TARGET_TO_CALIBRATE` unless empirically justified.

## Canonical status

The artifact is useful as a small set of candidate acquisition ideas. It is **not** evidence, does not establish market conclusions, and is not yet the executable IQ GROWTH evidence acquisition system.
