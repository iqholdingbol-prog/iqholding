# IQG-005 IPCENTER — BUYABILITY SIGNAL PASS 6
## Date: 2026-09-16
## Status: LIVE EVIDENCE COLLECTION CONTINUES

## Core question
Who can actually buy, what do they want, where do they want to buy it, and what blocks the transaction?

## Observed public demand signals (illustrative, not prevalence estimates)
- Public Bolivia discussion: buyer asks what a decent gaming laptop costs and participants discuss price bands, durability, portability and use case. Exact population inference prohibited.
- Public Sucre discussion: explicit Bs 8,000 budget, minimum desired specs and willingness to consider larger-city sellers if cheaper.
- Public Bolivia discussion: explicit Bs 12,000–13,000 PC-component budget with US-family transport option.
- Public Bolivia discussion: explicit Bs 15,000 budget for complete gaming PC including monitor.
- Public Santa Cruz user: saved Bs 3,100 for a phone and names three exact models not found locally; explicit availability gap.
- Public Oruro user: asks for current real laptop prices and indicates difficulty finding current price information.
- Public buyers repeatedly compare local vs import based on final cost, warranty, availability and trust.

## Current public supply examples
- PC Components Santa Cruz exposes a budget selector up to Bs 50,000 and examples of custom-build bands; it explicitly markets build-to-budget.
- MSR Computers lists MSI RTX 5060 8GB Ventus 3X OC at Bs 5,210 with 12-month warranty and national shipping at observation time.
- Punto Tecnológico lists the same named GPU family at Bs 5,850 but marked out of stock at observation time. This shows why price intelligence must include stock state and date.
- Tienda Amiga lists iPhone 17 Pro 256GB at Bs 16,999 and other iPhone models with installment terms; its contact location is Equipetrol Norte, Santa Cruz.
- A Santa Cruz retailer listing shows 2026 prices across Samsung and Apple tiers, from sub-Bs1,000 entry phones through Bs12,000+ flagships, illustrating large category/ticket dispersion.
- Public Móvil Plus catalog (May 2026) exposes iPhone 17-series prices by capacity and SIM/eSIM variant, showing that exact variant matters materially.

## Structural finding
The recommendation model must not ask only “what is your budget?”. It must resolve:
BUDGET + USE_CASE + MOBILITY + EXACT_VARIANT + NEW/USED/REFURB + WARRANTY + CITY + LOCAL/INTERCITY/IMPORT + TIME_TO_DELIVERY.

## Evidence hierarchy
TRANSACTION > DEPOSIT > ACCEPTED_QUOTE > EXPLICIT_BUDGET + CONCRETE_NEED > PRODUCT_REQUEST > SOCIAL_INTEREST.

## Important anti-patterns
- Neighborhood ≠ individual wealth.
- Stated budget ≠ transaction capability until validated by quote/acceptance/payment.
- Listed price ≠ available price; stock state matters.
- Same GPU/model family ≠ exact comparable product unless variant/configuration matches.
- Social interest ≠ demand prevalence.

## Working product concept (not canonical final)
A customer should be able to state need + budget + city in simple language. The system should invisibly reconcile:
1. technical fit,
2. current Bolivia availability,
3. local vs intercity vs import options,
4. exact variant,
5. final cost context,
6. warranty/trust,
7. fulfillment time,
8. historical outcome feedback.

This is a hypothesis to test, not a final product decision.
