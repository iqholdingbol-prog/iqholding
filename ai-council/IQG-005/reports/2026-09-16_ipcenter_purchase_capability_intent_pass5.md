# IQG-005 IPCENTER — PURCHASE CAPABILITY + INTENT FORENSIC PASS 5

Date: 2026-09-16
Coordinator: ChatGPT
Status: NATIONAL_DEMAND_AND_BUYABILITY_MODEL_ACTIVE

## Objective
Move beyond generic demand and generic purchasing-power proxies. The operational question is:

WHO CAN REALISTICALLY BUY + WHAT THEY WANT + WHERE THEY WANT TO BUY IT + WHAT FRICTION PREVENTS PURCHASE?

Do not infer individual wealth from appearance, social profile, neighborhood or sensitive attributes. Use observable commercial evidence and aggregated territorial context.

## Evidence classes for purchase capability
Strongest to weakest practical evidence:
1. PAID_ORDER / HISTORICAL_TICKET
2. DEPOSIT / CONFIRMED_PURCHASE
3. QUOTE_REQUEST_WITH_EXPLICIT_BUDGET
4. EXPLICIT_BUDGET
5. PRICE_ACCEPTANCE / PRICE_RESISTANCE
6. PRODUCT_SPECIFIC_PURCHASE_INTENT
7. BUSINESS_USE / PROFESSIONAL_USE CASE
8. TERRITORIAL AGGREGATE PURCHASING-POWER PROXY
9. GENERAL SOCIAL INTEREST

No arbitrary score is canonized yet.

## Current observed buyer-budget signals
- Sucre, March 2026: buyer seeking a new gaming laptop around Bs8,000; explicitly compares local limited selection with larger-city supply and is pointed toward Santa Cruz. Source: Reddit public conversation.
- Bolivia, April 2026: buyer with Bs12,000–13,000 budget planning a gaming PC, with explicit US-vs-local component split.
- Bolivia, April 2026: buyer with Bs15,000 budget wants a complete gaming PC including monitor.
- Bolivia, March 2026: discussion indicates meaningful buyer consideration across roughly Bs6k–20k+ laptop tiers; these are user claims, not population statistics.
- Current local retail evidence: Compustar gamer catalog shows products roughly Bs9,590–27,160, including RTX 4050/5050/5060/5070 laptops. This demonstrates that a current market offer exists across medium/high-ticket tiers; it does not prove demand at every price.
- Sucre/Oruro March 2026 gaming catalog shows roughly Bs7,950–23,600 and national shipping, with cash-on-delivery options in multiple cities. This demonstrates cross-city sales architecture and price tiers.

## Current observed intent/friction signals
- Santa Cruz: users compare local buying vs import from USA, with guarantee and price as explicit trade-offs; specific concern about RAM/GPU/motherboard availability and brand variety.
- Cochabamba/La Paz: recent buyers report concerns about refurbished equipment, inflated prices and lack of variety; some immediately ask about direct US sourcing.
- Cochabamba buyer considering iPhone from Trinidad asks first whether the store physically exists and whether it is trustworthy. Trust precedes price advantage.
- Potosí: user asks whether sellers in La Paz/Cochabamba can ship there. This is explicit geographic demand + fulfillment friction.
- Oruro: user asks for real/current laptop prices and fit by use case.
- National: gaming-PC seller reports customers increasingly arriving with AI-generated quotes disconnected from Bolivian price/scarcity reality. This reveals a potential IPCENTER capability: Bolivia-grounded price + availability intelligence.
- National: users explicitly ask where a particular drone model is cheaper by department.
- Auto parts: users distinguish common locally stocked parts from specific items sourced via Amazon/eBay/Chile; a potential seller explicitly says their main problem is not knowing what parts/brands are most demanded.

## Purchasing-power context
INE EH2024 exposes public-use household and personal income variables. Mean monthly household income in the dataset is about Bs5,847.8 and mean personal income about Bs1,667. These national means must NOT be used as thresholds for IPCENTER: distribution is broad and the high-ticket market is a minority segment. INE also publishes 2011–2025 departmental income series, which should be incorporated as an aggregate context layer, not as an individual decision rule.

## Required model
For each signal/customer interaction, conceptually separate:
- DESIRE
- INTENT
- EXPLICIT_BUDGET
- QUOTE_REQUEST
- PRICE_ACCEPTANCE / RESISTANCE
- DEPOSIT
- PURCHASE
- REPEAT_PURCHASE

For geography, track:
- CITY
- MICROZONE when explicitly observed/aggregated
- SOURCE PLATFORM
- PRODUCT / CATEGORY
- EXPLICIT PRICE / BUDGET
- AVAILABILITY
- LOCAL vs IMPORT preference
- WARRANTY need
- TRUST need
- DELIVERY need
- COMPATIBILITY / USE CASE

## Product-demand clusters now supported by evidence
1. Gaming laptops / PCs — explicit budgets, local-vs-import tradeoff, current retail range, national shipping.
2. Architecture / engineering / productivity laptops — repeated software/use-case questions around AutoCAD, Revit, Lumion and related workloads.
3. Premium phones — trust/authenticity/store-existence concern can dominate apparent low price.
4. Drones — buyers ask where to buy specific models and where they are cheaper; agricultural/professional drone ecosystem exists in Santa Cruz.
5. Hard-to-find components — GPU, motherboard, specific brand/model availability repeatedly drives import consideration.
6. Auto parts — specific compatibility and sourcing demand exists, but category requires stronger fit/part-number controls.

## IPCENTER design implication
The likely useful user experience is not a static catalog. It should progressively answer:

NEED -> USE CASE -> BUDGET -> CITY -> EXACT FIT -> LOCAL OPTIONS -> IMPORT OPTIONS -> REAL CURRENT PRICE -> LANDING COST / DELIVERY -> WARRANTY -> TRUST / PROVENANCE -> QUOTE -> PURCHASE

This should feel simple to the customer while the intelligence layer does the difficult cross-source work behind the scenes.

## Evidence rule
SOCIAL INTEREST != PURCHASING POWER.
NEIGHBORHOOD != INDIVIDUAL WEALTH.
FOLLOWER != CUSTOMER.
EXPLICIT BUDGET > inferred affordability.
PAID TRANSACTION > social signal.

## Next research passes
- Build city-by-city and microzone aggregated buyability context.
- Expand explicit-budget and purchase-intent dataset from public social/community signals.
- Build exact current product/price/availability snapshots across major national sellers.
- Recover IPCENTER historical first-party sales and WhatsApp history when authorized; this becomes the strongest training evidence for national demand and conversion.
- Detect unmet-demand categories before inventory commitment.

PASS 5 COMPLETE — NATIONAL PURCHASE CAPABILITY + INTENT MODEL ACTIVE
