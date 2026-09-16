# CLAUDE — IQG-005 IPCENTER
## MAGIC BUYABILITY + PRODUCT DECISION CHALLENGE V1

**CEO:** Iván Quea
**Coordinator:** ChatGPT
**Role:** Product / UX / Decision-System Challenger

## Mission
Design how IPCENTER can make buying technology in Bolivia feel almost magical to the customer while using only evidence-backed information.

The customer should not have to research 30 stores, compare variants, understand importation, calculate landed cost, validate warranty, check stock, or know hardware deeply. IPCENTER should absorb that complexity.

But there is a hard rule:

> MAGIC = COMPLEXITY HIDDEN BY GOOD DATA + GOOD DECISION LOGIC.
> MAGIC != INVENTED CERTAINTY.

Do not invent prices, demand, stock, income, margins, conversion rates, market sizes, warranty terms, shipping times, or customer ability to pay.

Use evidence states explicitly:
`CONFIRMED`, `CEO_REPORTED`, `DIRECT_PUBLIC_EVIDENCE`, `SYSTEM_MEASURED`, `SYSTEM_CALCULATED`, `EXTERNAL_EVIDENCE`, `ESTIMATED`, `INFERENCE`, `HYPOTHESIS`, `UNKNOWN`, `TO_MEASURE`, `FIRST_PARTY_REQUIRED`.

## Current evidence snapshot
Treat these as input facts with their stated status; do not generalize beyond them:

- IPCENTER historically sold and shipped technology nationally, including La Paz, El Alto, Oruro, Potosí, Llallagua, Tarija, Trinidad, Santa Cruz, Sucre and Cobija. `CEO_REPORTED / HISTORICAL_FIRST_PARTY_TO_RECOVER`.
- Historical high-end laptop activity included MSI Leopard. `CEO_REPORTED`.
- Public buyer signals already observed include:
  - Santa Cruz buyer with ~Bs 3,100 seeking specific Tecno/Infinix/Vivo models and reporting availability difficulty.
  - Sucre buyer with ~Bs 8,000 seeking a new gaming laptop and considering purchase from a larger city.
  - Buyer with ~Bs 12,000–13,000 comparing local PC component purchase vs importing from the US.
  - Buyer with ~Bs 15,000 seeking a complete gaming PC including monitor.
  - Architecture users asking for laptops for AutoCAD / SketchUp / Revit / Lumion.
  - Buyers repeatedly asking about trust, exact variant, new vs refurbished, warranty, shipping, customs, final landed cost and local-vs-import tradeoffs.
- Same exact-model prices can differ while stock and warranty differ; therefore `PRICE != BEST_OPTION`.
- Bolivia has strong inequality and meaningful high-purchasing-power microzones, but location must never be treated as proof that an individual is wealthy.
- Public social evidence is biased, incomplete and not representative of the whole population.
- Product Fit already exists partially among competitors; generic “we recommend a laptop for your needs” is not enough differentiation.

If repository access exists, read before answering:
- `docs/IQG_INFORMATION_ADVANTAGE_DOCTRINE_V1.md`
- `ai-council/AI_COUNCIL_QUALITY_GATE_V1.md`
- `docs/IQG-005_IPCENTER_VERTICAL_V1.md`
- `docs/IQG-005_IPCENTER_AS_IS_BASELINE_V1.md`
- `docs/IQG-005_IPCENTER_DAY0_DATA_CONTRACT.md`
- `ai-council/IQG-005/reports/2026-09-16_chatgpt_national_social_forensic_pass2.md`
- `ai-council/IQG-005/reports/2026-09-16_ipcenter_national_competitor_demand_graph_v1.md`
- `ai-council/IQG-005/reports/2026-09-16_ipcenter_national_purchasing_power_demand_pass4.md`
- `ai-council/IQG-005/reports/2026-09-16_ipcenter_purchase_capability_intent_pass5.md`
- `ai-council/IQG-005/reports/2026-09-16_ipcenter_buyability_signal_pass6.md`

If those files are unavailable, do not pretend to have read them. Work from this prompt and mark missing context.

# TASK 1 — DEFINE THE CUSTOMER'S REAL JOB
Do not describe IPCENTER as “a tech store”.

Define the customer jobs-to-be-done behind requests such as:
- “Tengo Bs 9.000 y necesito laptop para arquitectura en Potosí.”
- “Quiero esta GPU exacta, pero no sé si importar o comprar aquí.”
- “¿Esta tienda de otra ciudad es real?”
- “Quiero iPhone nuevo, no reacondicionado, y garantía clara.”
- “Necesito una pieza difícil de encontrar.”

Separate:
`DESIRE -> NEED -> INTENT -> BUDGET -> CONSTRAINTS -> QUOTE -> ACCEPTANCE -> PAYMENT -> FULFILLMENT -> OUTCOME`.

Show what information becomes materially more valuable at each stage.

# TASK 2 — DESIGN THE MINIMUM-MAGIC INTAKE
Design the smallest number of questions IPCENTER should ask a customer before it can produce useful options.

Candidate fields include:
- city / destination
- what they need to accomplish
- software or workload
- exact model if already known
- budget or acceptable range
- urgency
- new / used / open-box tolerance
- warranty requirement
- local-only / national shipping / import tolerance
- portability / performance / battery / screen / other constraints

Challenge every field. Remove questions that can be inferred safely from evidence or asked later.

Output:
`MINIMUM_INTAKE_V1`
with:
- question
- why it changes the decision
- whether required now / later / inferable
- risk if omitted

# TASK 3 — BUYABILITY WITHOUT WEALTH PROFILING
Design a buyability model that does NOT infer individual wealth from neighborhood, photos, surnames, occupation stereotypes, device type or social appearance.

Allowed stronger evidence should include:
- explicit budget
- quote accepted/rejected
- deposit
- completed purchase
- historical ticket
- financing request / payment mode if voluntarily provided
- first-party purchase history

Aggregate territorial proxies may inform market planning, but must not determine an individual's ability to pay.

Create:
`BUYABILITY_EVIDENCE_LADDER`
from weakest to strongest signal.

Explain how to distinguish:
- wants it but cannot currently buy;
- can buy but is not ready;
- high purchase intent and budget aligned;
- budget unknown;
- business/B2B purchase where budget logic differs.

# TASK 4 — DECISION ENGINE
Design the decision logic behind the user-facing simplicity.

For a customer request, the system may compare:
- local exact-match stock
- same-city alternatives
- national exact-match stock
- national near-equivalents
- import-on-demand exact match
- import-on-demand better fit

For every candidate, specify which fields must be known before it can be shown as a credible option:
- exact model/variant
- condition
- seller/source
- source timestamp
- stock status
- price
- currency
- shipping
- landed cost state
- warranty
- expected delivery state
- compatibility/fit
- evidence provenance
- confidence

Do NOT invent arbitrary numeric weights. If a scoring mechanism is useful, define dimensions and calibration method, not fake coefficients.

# TASK 5 — PRODUCT FIT BEYOND COMPETITORS
Generic fit advice is not enough.

Design a stronger capability:
`NEED -> WORKLOAD -> REQUIREMENTS -> EXACT PRODUCT VARIANTS -> CURRENT BOLIVIA OPTIONS -> IMPORT OPTIONS -> TOTAL COST -> WARRANTY -> DELIVERY -> RISK -> RECOMMENDATION`.

Show how this works for at least:
1. architecture/rendering laptop;
2. gaming PC budget build;
3. hard-to-find phone;
4. exact GPU/component;
5. one non-computer category such as drone or specialized electronic.

Use examples only as product logic. Mark any unverified numbers `ILLUSTRATIVE_ONLY_NOT_FOR_DECISION`.

# TASK 6 — THE “MAGIC” USER EXPERIENCE
Design the customer-facing output so it feels simple.

The customer should see no more complexity than necessary.

Propose a compact result card with, for example:
- best fit for stated need;
- why;
- exact product/variant;
- current price state;
- availability state;
- delivery to city;
- warranty;
- confidence / last verified;
- 1–2 alternatives with meaningful tradeoffs.

Challenge whether “best” should be one answer or conditional answers such as:
- best immediate;
- best value;
- best exact-match;
- best import option.

Do not choose a winner when evidence is insufficient.

# TASK 7 — TRUST / IPCENTER PASSPORT
Turn trust into a concrete product capability, not marketing language.

Define what a customer should be able to verify:
- supplier/source evidence where appropriate;
- exact variant;
- serial/IMEI where relevant;
- condition;
- photos/evidence checkpoints;
- purchase/order state;
- shipping/tracking;
- receipt;
- warranty terms;
- delivery/acceptance evidence.

Separate generic Core provenance from IPCENTER-specific user experience.

# TASK 8 — NATIONAL FULFILLMENT
Design the decision logic for Bolivia-wide customers.

Do not assume the nearest seller is best.

The system must be able to compare:
`CITY_OF_CUSTOMER x CITY_OF_STOCK x SHIPPING x TIME x PRICE x WARRANTY x TRUST x EXACT_FIT`.

Include small/remote markets such as Cobija, Trinidad, Llallagua and Potosí instead of assuming high-ticket demand exists only in Santa Cruz/La Paz/Cochabamba.

# TASK 9 — PREDICTION WITHOUT FANTASY
Design how IQ GROWTH can move from reactive search toward anticipation.

Possible signals:
- repeated product requests;
- growing model mentions;
- explicit budgets clustering;
- availability complaints;
- local stock gaps;
- competitor stockouts;
- new technology launches;
- repeated software/use-case needs;
- first-party quote-to-sale history.

Build:
`OBSERVATION -> SIGNAL -> CORROBORATION -> HYPOTHESIS -> CONTROLLED TEST -> PURCHASE RESULT -> LEARNING`.

Explain what minimum evidence is necessary before:
- publishing content;
- offering preorder;
- negotiating supplier access;
- stocking inventory.

# TASK 10 — PREMORTEM
Give at least 25 concrete ways this product could fail commercially or operationally.

Include:
- stale stock;
- fake seller evidence;
- wrong variant;
- bad product-fit recommendation;
- exchange-rate shifts;
- hidden shipping/import cost;
- warranty ambiguity;
- over-automation;
- excessive questions;
- incorrect buyability inference;
- biased social samples;
- recommendation that optimizes price but destroys trust;
- inability to fulfill nationally.

For each:
`FAILURE -> EARLY SIGNAL -> PREVENTION -> RECOVERY`.

# REQUIRED OUTPUT
A. CUSTOMER JOB MODEL
B. MINIMUM_INTAKE_V1
C. BUYABILITY_EVIDENCE_LADDER
D. NATIONAL DECISION ENGINE
E. PRODUCT-FIT DIFFERENTIATION
F. MAGIC UX SPEC
G. IPCENTER PASSPORT / TRUST MODEL
H. NATIONAL FULFILLMENT LOGIC
I. PREDICTION-TO-EXPERIMENT LOOP
J. DATA REQUIRED NOW
K. DATA NOT WORTH COLLECTING
L. 25+ FAILURE PREMORTEM
M. WHAT IPCENTER SHOULD NOT BUILD YET
N. TOP 10 PRODUCT QUESTIONS CHATGPT SHOULD NOW RESEARCH WITH LIVE EVIDENCE

## Quality Gate
Fail this assignment if you:
- invent numeric thresholds;
- infer wealth from an individual’s neighborhood or appearance;
- confuse social attention with demand;
- assume current stock/price without a dated source;
- make a generic UX framework without mapping it to purchase decisions;
- merely restate the prompt.

Final line exactly:
`IPCenter MAGIC BUYABILITY PRODUCT CHALLENGE READY FOR CHATGPT SYNTHESIS`
