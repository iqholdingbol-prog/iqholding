# IQG-005 IPCENTER — Live Research Pass 7

Date: 2026-09-16
Author: ChatGPT / Chief Architect & AI Council Coordinator
Status: `LIVE_RESEARCH_CONTINUES`
Scope: Bolivia national B2C + B2B + financing + customs + data-quality evidence

## Executive finding

This pass materially expands the opportunity model. IPCENTER should not model only `who has cash now`. Bolivia's technology market shows at least three distinct purchase-capability states:

1. `CASH_BUYABILITY` — declared/current cash budget or immediate payment ability.
2. `FINANCED_BUYABILITY` — purchase becomes possible through approved installment/credit mechanisms.
3. `INSTITUTIONAL_BUYABILITY` — organization/company/public institution has a formal procurement need, budget/process and payment terms.

These must remain separate. Financing eligibility must never be inferred from social appearance. Institutional procurement must remain separate from consumer demand.

---

## A. B2C BUYER SIGNAL REGISTER — current public evidence

### B2C-001 — Sucre / gaming laptop
- city: Sucre
- date: 2026-03-17
- budget: Bs 8,000
- requested minimum: new laptop, 16 GB RAM, Intel i5 12th/13th gen, dedicated GPU around RTX 4050
- observed local offer: HP Victus around Bs 8,800 (user-reported)
- friction: low local variety, wants to know whether larger cities are cheaper
- signal state: `PUBLIC_ACTIVE_SEARCH + SELF_DECLARED_BUDGET`
- source class: Reddit public discussion

### B2C-002 — Santa Cruz / hard-to-find phone
- city: Santa Cruz de la Sierra
- date: 2026-06-08
- budget: Bs 3,100
- exact requests: Tecno Camon 30 Pro/Premier, Infinix Zero 40 5G, Vivo V50
- friction: cannot find exact requested models new or used
- preferences: camera, not expensive; rejects alternative Xiaomi suggestions based on prior experience
- signal state: `PUBLIC_ACTIVE_SEARCH + SELF_DECLARED_BUDGET + EXACT_MODEL_REQUEST + AVAILABILITY_GAP`

### B2C-003 — Oruro / laptop price uncertainty
- city: Oruro
- date: 2026-05-06
- need: wants good laptops, cannot find trustworthy current prices, complains search results are old
- friction: `PRICE_FRESHNESS + LOCAL_AVAILABILITY + MODEL_COMPARISON`
- signal state: `PUBLIC_ACTIVE_SEARCH`

### B2C-004 — Potosí / national shipping need
- city: Potosí
- date: 2026-04-14
- observed question: whether recommended stores in La Paz/Cochabamba can ship to Potosí
- friction: `TRUST + NATIONAL_FULFILLMENT`
- signal state: `PUBLIC_DELIVERY_REQUEST`

### B2C-005 — Santa Cruz / local vs import
- city: Santa Cruz
- date: 2026-08-27
- need: buy/upgrade gaming PC and laptop
- friction: local price vs USA import; warranty; brand availability; exact component availability
- observed discussion: import may be cheaper for some parts; local warranty matters; some brands/models are hard to find locally
- signal state: `PUBLIC_ACTIVE_SEARCH + LOCAL_VS_IMPORT`

### B2C-006 — Bolivia / courier for technology
- date: 2026-03-16
- need: import NAS + two 8 TB disks
- friction: previous surprise-cost experiences; wants reliable courier even if it costs more
- signal state: `PUBLIC_IMPORT_REQUEST + TRUST + TOTAL_COST_CONCERN`

### B2C-007 — La Paz / purchase timing uncertainty
- city: La Paz
- date: 2026-03-16
- buyer state: university student considering laptop purchase
- friction: price uncertainty and fear of future price increases
- signal state: `PUBLIC_ACTIVE_SEARCH + TIMING_CONCERN`

### B2C-008 — Cochabamba buyer / iPhone from Trinidad
- buyer city: Cochabamba
- seller-claimed city: Trinidad
- date: 2026-03-13
- product: new iPhone
- friction: price attractive but buyer wants confirmation seller/store actually exists
- signal state: `PUBLIC_TRUST_VERIFICATION_REQUEST`

---

## B. CURRENT RETAIL OFFER REGISTER — observed 2026

### OFFER-001 — Lenovo LOQ 15ARP10E
- seller: PC Falcon, Cochabamba
- observed post date: 2026-06-01
- configuration: Ryzen 7 7735HS / 16 GB / 512 GB / RTX 4050 6 GB
- price: Bs 9,600
- national shipping claim: yes
- verification state: `SOURCE_CLAIMED`
- freshness: `RECENT_2026`

### OFFER-002 — ASUS TUF A16 FA607NUG
- seller: PC Falcon
- observed post date: 2026-05-29
- configuration: Ryzen 7 7445HS / 16 GB / 512 GB / RTX 4050 6 GB
- price: Bs 10,800
- national shipping claim: yes
- verification state: `SOURCE_CLAIMED`

### OFFER-003 — ASUS TUF A16 FA607NUG
- seller: Compustar
- observed current crawl: Sep 2026
- configuration: Ryzen 7 7445HS / 16 GB / 512 GB / RTX 4050 6 GB
- price: Bs 13,950
- verification state: `SOURCE_CLAIMED`

### OFFER-004 — ASUS TUF A16 FA607NUG
- seller/platform: CompraBolivia / PC.COM Bolivia
- observed current crawl: Sep 2026
- configuration: Ryzen 7 7445HS / 16 GB / 512 GB / RTX 4050 6 GB
- price: Bs 15,990
- WhatsApp purchase flow: yes
- page claim: official warranty / fast shipping (must be separately verified)
- verification state: `SOURCE_CLAIMED`

### OFFER-005 — Lenovo LOQ Ryzen 7 / RTX 4050
- seller: MI PC
- current crawl: Sep 2026
- configuration: Ryzen 7 7735HS / 16 GB / 512 GB / RTX 4050 6 GB
- price: Bs 12,650
- stock: “Últimas unidades”
- exact machine model code not confirmed equal to PC Falcon model
- verification state: `SOURCE_CLAIMED`
- note: do NOT perform 1:1 price spread calculation unless exact model/variant is confirmed.

### OFFER-006 — Lenovo LOQ Ryzen 5 / RTX 4050
- seller: MI PC
- current crawl: Sep 2026
- configuration: Ryzen 5 7235HS / 16 GB / 512 GB / RTX 4050 6 GB
- price: Bs 10,790
- stock: `SIN_STOCK`
- signal value: stock state is as important as listed price.

### OFFER-007 — MSI RTX 5070 Gaming Trio 12 GB
- seller: Punto Tecnológico
- current crawl: Sep 2026
- price: Bs 11,180
- stock: `AGOTADO`
- store claims guarantee/support and branches in Cochabamba/Santa Cruz
- verification state: `SOURCE_CLAIMED`

### OFFER-008 — iPhone 16 Pro 128 GB new
- seller: Tienda Amiga
- current crawl: Sep 2026
- price: Bs 17,499
- stock: available
- home delivery: available
- installment display: 12 installments (subject to customer profile/credit conditions)
- verification state: `SOURCE_CLAIMED`

### OFFER-009 — iPhone 16 Pro 128 GB CPO / Apple Certified Refurbished
- seller: Dismac
- current crawl: Sep 2026
- price: Bs 10,999
- stock: unavailable for delivery and pickup at observed time
- significance: condition changes price materially; product family alone is not enough.

### OFFER-010 — iPhone 16 Pro 256 GB seminuevo
- seller: Gadget (Tarija)
- current crawl: Sep 2026
- price: Bs 8,900
- stock: no stock
- condition: seminuevo
- store warranty: 3 months
- shipping claim: all Bolivia
- signal: exact condition + battery state + warranty must be explicit.

---

## C. FINANCING / BUYABILITY EXPANSION REGISTER

### FIN-001 — Tienda Amiga “Cuotitas”
- offers installment purchase up to 24 months for users with approved credit line.
- current computing catalog displays many laptops with installment amounts.
- implication: `CURRENT_CASH_BUDGET` is not the same as `PURCHASE_CAPABILITY_WITH_FINANCING`.

### FIN-002 — Dismac MiniCuotas
- advertises monthly installment financing up to 15 months.
- application may use identity, proof of address, employment/pay documentation or business visit/references.
- implication: credit eligibility is a separate first-party/regulated decision; IPCENTER must not infer it from social signals.

### FIN-003 — Casa21 CL21
- publishes laptops with normal price, CL21 price and 12-payment amounts.
- physical presence in El Alto.
- implication: credit/direct installment competition exists even at lower/mid laptop tickets.

### FIN-004 — BancoSol digital consumer credit
- digital application available to eligible current bank customers; initially supported in Santa Cruz, Cochabamba, La Paz and El Alto.
- implication: external financing can enlarge addressable purchase capability without IPCENTER becoming lender.

### Design consequence

Do not store one field `can_buy`.

Use separate states:
- `DECLARED_CASH_BUDGET`
- `IMMEDIATE_PAYMENT_CONFIRMED`
- `FINANCING_INTEREST`
- `FINANCING_ELIGIBILITY_UNKNOWN`
- `FINANCING_APPROVED` (only when supported by authorized first-party/partner result)
- `INSTITUTIONAL_BUDGET_PROCESS`

---

## D. B2B / INSTITUTIONAL DEMAND REGISTER — high-value evidence

This is a major expansion beyond social listening. Public procurement is direct demand evidence, not social interest.

### B2B-001 — YPFB GNEE
- publication: 2026-09-10
- process: Adquisición de Equipos de Computación - GNEE
- item: 48 portable computers/laptops
- reference unit price: Bs 40,000
- reference total: Bs 1,920,000
- source type: SICOES-replicated procurement record
- state: `DOCUMENT_SUPPORTED / PROCUREMENT_DEMAND`
- caution: price is procurement reference, not consumer market price.

### B2B-002 — ASFI
- 2026 official procurement page lists `Adquisición de Equipos de Computación`, CUCE 26-0203-00-1684876-1-1.
- source: official ASFI.
- state: `DIRECT_OFFICIAL_PROCUREMENT_EVIDENCE`.

### B2B-003 — Petrobras Bolivia PAC 2026
- official plan includes `Compra de LAPTOP` and `Compra de WorkStation para reservorio y exploración`, scheduled around Sep 2026.
- state: `DIRECT_OFFICIAL_PLANNED_DEMAND`.
- implication: specialized workstation sourcing is a real B2B use case, not only a consumer hypothesis.

### B2B-004 — UCB Sucre
- 2026 procurement request for Dell Pro 14 with Core Ultra 5 235U, 16 GB DDR5, 512 GB SSD, Spanish keyboard, Wi-Fi 6E, minimum 1-year factory warranty.
- requires prices in BOB, offer validity and delivery time.
- state: `DIRECT_INSTITUTIONAL_DEMAND`.

### B2B-005 — UCB Tarija / high-end laptop
- Jan 2026 request: ASUS ROG Strix G18, Core Ultra 9 275HX, RTX 5070 Ti or superior, 32 GB DDR5+, 1–2 TB NVMe.
- state: `DIRECT_INSTITUTIONAL_HIGH_END_DEMAND`.

### B2B-006 — UCB Tarija / Mac + RTX 5070
- Mar 2026 request includes MacBook Pro 14 M4 Pro and a Core Ultra 9 275HX laptop with 32 GB DDR5, 2 TB and RTX 5070.
- requires real delivery time, warranty and invoicing; delays subject to penalties.
- state: `DIRECT_INSTITUTIONAL_HIGH_END_DEMAND`.

### B2B-007 — UCB Tarija / gaming-class laptop Aug 2026
- request includes ASUS Vivobook gaming-class laptop with i5-210H, 16 GB, 512 GB, RTX 3050 6 GB or similar.
- state: `DIRECT_INSTITUTIONAL_DEMAND`.

### B2B-008 — FAO Bolivia
- June 2026 invitation to bid for laptops for RECEM Valles.
- formal UNGM procurement channel.
- state: `DIRECT_INSTITUTIONAL_DEMAND`.

### B2B-009 — ANH
- 2026 procurement planning includes computers, audiovisual equipment, editing workstation/island and a Bs 345,000 acquisition of computing equipment.
- state: `DIRECT_OFFICIAL_PLANNED_DEMAND`.

### B2B-010 — Vías Bolivia
- 2026 procurement record includes acquisition of portable computers for regional offices.
- state: `DOCUMENT_SUPPORTED_PROCUREMENT_DEMAND`.

### B2B implication

IPCenter potential should not be modeled only as consumer/import-on-demand. There is a separate possible future capability:

`NEED SPECIFICATION → COMPLIANT SOURCING → FORMAL QUOTE → DOCUMENTATION → WARRANTY → DELIVERY → INVOICE → ACCEPTANCE`.

This is a different workflow from B2C and should remain separated in the vertical design until validated economically.

---

## E. CUSTOMS / IMPORT FACT REGISTER

Official Bolivian Customs current public guidance:

- Express courier applies to urgent shipments with FOB value <= USD 1,000 and weight <= 40 kg.
- Above those thresholds, import-for-consumption regime with customs broker intervention applies.
- Courier company handles the expedited declaration process and relevant customs responsibilities.
- Postal franchise is a separate regime with smaller thresholds.

Design consequence:

`LANDED_COST_ENGINE` must include at least:
- exact product/category,
- FOB value,
- weight,
- shipment regime,
- freight,
- insurance if applicable,
- applicable duties/taxes/authorizations,
- exchange-rate source/date,
- customs broker/process requirements if threshold exceeded,
- domestic fulfillment.

Never infer import cost from a flat percentage.

---

## F. WARRANTY / SUPPORT EVIDENCE

### Lenovo Bolivia
- official Bolivia support site provides warranty lookup by serial, parts, repair tracking, support and warranty services.
- useful for IPCENTER Passport: manufacturer warranty state can be checked separately from seller warranty.

### MSI LATAM
- official support exposes warranty policy, RMA state, product registration, serial identification, seller/service-location discovery.
- exact Bolivia service-center availability still must be verified before promising local MSI warranty execution.

Design consequence:

Separate:
- `MANUFACTURER_WARRANTY_STATUS`
- `SELLER_WARRANTY`
- `IPCenter_COMMERCIAL_WARRANTY`
- `LOCAL_SERVICE_EXECUTION_PATH`

They are not equivalent.

---

## G. DATA QUALITY FAILURES FOUND — critical for IQ GROWTH

### DQ-001 — currency parsing / conversion corruption

PcActual search results exposed prices such as US$ 1,199 but absurd BOB values around Bs 992,460, and US$ 2,018 mapped to values above Bs 1.5 million.

This is a data-extraction/conversion anomaly, not a real market price.

Rule:
`SOURCE_DISPLAYED_PRICE` and `SYSTEM_CONVERTED_PRICE` must be stored separately.

Never trust derived currency conversion without:
- exchange-rate provenance,
- currency detection,
- sanity checks,
- outlier flagging.

### DQ-002 — suspicious low/outlier listing

A PC Gamer Bolivia page displayed an Acer Nitro RTX 4060 around Bs 4,835 with national shipping and one-year warranty claims. This is materially below several comparable current gaming-laptop offers and requires direct current verification before use.

State:
`OUTLIER_PRICE / REVERIFY_REQUIRED`.

### DQ-003 — model-family false matching

LOQ / TUF / ROG family names are insufficient for price comparison. Exact SKU/model + CPU + GPU + RAM + storage + screen + OS/keyboard/region/condition must be matched.

### DQ-004 — price without stock

Current retailer evidence repeatedly shows listed prices while product state is `SIN_STOCK` or `AGOTADO`.

Rule:
`PRICE_RECORD != BUYABLE_OFFER`.

Buyable offer requires current stock/availability state.

---

## H. NEW STRATEGIC HYPOTHESES — not facts

### H1 — Financing is a material buyability multiplier
Evidence: multiple national retailers actively sell technology on installments and expose monthly payment amounts.
Status: `HYPOTHESIS_SUPPORTED_BY_MARKET_STRUCTURE`.
Need: measure whether target IPCENTER customers actually prefer/use financing and economics of partner financing vs cash/import-on-demand.

### H2 — B2B specialized sourcing may be at least as important as consumer premium tech
Evidence: current 2026 institutional requests include high-end ROG/RTX 5070-class laptops, workstations, standardized business laptops and bulk procurements.
Status: `HYPOTHESIS_WITH_DIRECT_DEMAND_EVIDENCE`.
Need: assess eligibility, procurement compliance, working capital, payment delay, guarantee requirements and margin.

### H3 — Product availability/freshness is a competitive product, not merely a database field
Evidence: public buyers explicitly complain about old prices, missing exact models and cross-city search; retailer pages show prices with no stock.
Status: `SUPPORTED_HYPOTHESIS`.

### H4 — Consumer and institutional buyability require separate engines
B2C: intent/budget/financing/trust/fulfillment.
B2B: specification/compliance/budget/process/invoice/guarantees/delivery acceptance/payment terms.
Status: `ARCHITECTURAL_HYPOTHESIS`.

---

## I. NEXT LIVE RESEARCH PRIORITIES

1. Build exact 1:1 price-match register for 10–20 SKUs across 3+ Bolivian sellers each.
2. Map current financing/credit mechanisms and economics without IPCENTER acting as lender.
3. Expand B2B procurement register by city, sector, requested spec, quantity, reference amount and deadline.
4. Verify current national courier routes, insurance/declared-value coverage and claim processes for high-value electronics.
5. Map manufacturer vs seller warranty by Lenovo, Dell, ASUS, MSI, Apple, HP.
6. Continue city-level consumer signals: Potosí, Oruro, Sucre, Tarija, Trinidad, Cobija, El Alto.
7. Search exact hard-to-find products/models and repeated requests.
8. Recover historical IPCENTER first-party records when CEO authorizes/provides access.

## State

`PASS7_COMPLETE / LIVE_RESEARCH_CONTINUES / NO_INVENTORY_DECISION_YET`
