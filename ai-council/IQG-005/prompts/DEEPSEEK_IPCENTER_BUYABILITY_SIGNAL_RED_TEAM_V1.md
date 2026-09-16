# DEEPSEEK — IQG-005 IPCENTER
## BUYABILITY + SIGNAL-INTEGRITY RED TEAM V1

**CEO:** Iván Quea
**Coordinator:** ChatGPT
**Role:** Adversarial Reviewer — Data Integrity / Commercial Risk / Privacy / Security

## Mission
Try to break the current IPCENTER thesis before we build around it.

The emerging thesis is:

> IPCENTER can reduce the effort of buying technology in Bolivia by combining real demand signals, explicit buyer constraints, product-fit logic, live market evidence, national fulfillment, provenance, warranty clarity and sourcing.

Your job is NOT to make this thesis sound good.
Your job is to find where it is false, biased, economically weak, gameable, unsafe, stale, or operationally impossible.

Hard rule:
`SIGNAL != DEMAND != PURCHASE != PROFIT`.

Use states:
`CONFIRMED`, `CEO_REPORTED`, `DIRECT_PUBLIC_EVIDENCE`, `SYSTEM_MEASURED`, `SYSTEM_CALCULATED`, `EXTERNAL_EVIDENCE`, `ESTIMATED`, `INFERENCE`, `HYPOTHESIS`, `UNKNOWN`, `TO_MEASURE`, `REJECTED`, `LEGAL_REVIEW_REQUIRED`.

Do not invent laws, prices, conversion rates, margins, fraud rates or market sizes.

## Evidence snapshot to attack
- IPCENTER historically sold and shipped technology nationally, including La Paz, El Alto, Oruro, Potosí, Llallagua, Tarija, Trinidad, Santa Cruz, Sucre and Cobija. `CEO_REPORTED / HISTORICAL_FIRST_PARTY_TO_RECOVER`.
- Historical high-end laptops included MSI Leopard. `CEO_REPORTED`.
- Public buyer signals observed include explicit budgets around Bs 3,100, Bs 8,000, Bs 12,000–13,000 and Bs 15,000 for phones/laptops/PCs.
- Repeated public concerns include exact variant, warranty, new vs refurbished, trust, national shipping, local-vs-import, customs/final cost and hard-to-find products.
- Exact-model price comparisons show price alone is insufficient because stock/warranty/source differ.
- Bolivia has strong inequality; aggregated geography may help market planning but cannot prove an individual's ability to pay.
- Social data is incomplete, biased and exposed to bots, reposts, promotion and selection effects.
- Product Fit exists partially among competitors.

If repository access exists, read:
- `docs/IQG_INFORMATION_ADVANTAGE_DOCTRINE_V1.md`
- `ai-council/AI_COUNCIL_QUALITY_GATE_V1.md`
- `docs/IQG-005_IPCENTER_VERTICAL_V1.md`
- `docs/IQG-005_IPCENTER_DAY0_DATA_CONTRACT.md`
- `ai-council/IQG-005/reports/2026-09-16_ipcenter_national_competitor_demand_graph_v1.md`
- `ai-council/IQG-005/reports/2026-09-16_ipcenter_national_purchasing_power_demand_pass4.md`
- `ai-council/IQG-005/reports/2026-09-16_ipcenter_purchase_capability_intent_pass5.md`
- `ai-council/IQG-005/reports/2026-09-16_ipcenter_buyability_signal_pass6.md`

If unavailable, do not claim to have read them.

# TASK 1 — ATTACK THE BUYABILITY CONCEPT
Find every way “who can buy” can be misclassified.

Attack weak proxies such as:
- affluent neighborhood;
- expensive phone;
- profession;
- employer;
- visible lifestyle;
- follower count;
- social engagement;
- stated budget without purchase behavior;
- financing inquiry;
- historical purchase from years ago.

Design a safer `BUYABILITY_EVIDENCE_HIERARCHY` and identify what must never be inferred automatically.

# TASK 2 — FALSE DEMAND / SOCIAL SIGNAL POISONING
At least 40 attack scenarios covering:
- bots;
- astroturfing;
- seller spam;
- affiliate promotion;
- giveaways;
- duplicated posts;
- viral content unrelated to purchase intent;
- ironic/sarcastic comments;
- fake reviews;
- competitor manipulation;
- stale posts resurfacing;
- same person posting in many groups;
- quoted budgets that are hypothetical;
- reseller inquiries mistaken for end-customer demand;
- creator content causing temporary spikes;
- product-launch hype;
- platform demographic bias;
- city overrepresentation;
- silent high-value buyers invisible on public social.

For each:
`ATTACK -> HOW IT CORRUPTS DECISION -> DETECTION -> MITIGATION -> RESIDUAL RISK`.

# TASK 3 — MARKET COVERAGE BIAS
Attack the belief that social data reveals “what Bolivia wants”.

Explicitly analyze:
- Facebook vs TikTok vs Instagram vs WhatsApp first-party bias;
- urban vs rural visibility;
- age/platform effects without inventing demographic numbers;
- high-income buyers who buy privately;
- B2B buyers who rarely post publicly;
- cities with weak digital footprint but real purchasing power;
- marketplace-only behavior;
- offline referrals;
- historical IPCENTER customers absent from current social channels.

Define how to report `COVERAGE` and `BLIND_SPOTS` with every prediction.

# TASK 4 — STALE MARKET EVIDENCE
Break the system using:
- stale stock;
- stale prices;
- exchange-rate changes;
- deleted listings;
- product substitutions;
- seller renaming;
- fake “available” products;
- quote-only pricing;
- warranty terms changed after publication;
- national shipping promise without actual coverage.

Design freshness states and invalidation rules.
Do not invent time thresholds unless marked `TO_CALIBRATE`.

# TASK 5 — EXACT VARIANT / COMPATIBILITY FAILURE
Attack categories where an almost-correct recommendation is dangerous commercially:
- laptops with different GPU wattage/configurations;
- phones with SIM/eSIM/storage/region variants;
- GPUs with exact model/condition differences;
- auto parts with VIN/OEM fit;
- drones with ecosystem/regulatory/service constraints;
- chargers/accessories with connector/power compatibility.

Define where the system must stop and require human verification.

# TASK 6 — TRUST / SELLER VERIFICATION ATTACK
Assume malicious or careless sellers can manipulate the system.

Attack:
- fake addresses;
- fake business pages;
- copied reviews;
- stock photos;
- stolen catalog content;
- spoofed WhatsApp numbers;
- fake tracking;
- switched product at delivery;
- serial mismatch;
- refurbished sold as new;
- warranty that cannot actually be honored.

Design evidence needed for seller/source confidence without pretending absolute certainty.

# TASK 7 — ECONOMIC FAILURE
Attack the business model even if recommendations are technically good.

Consider:
- quote labor cost;
- low conversion;
- customers using IPCENTER research then buying elsewhere;
- price competition compressing margin;
- warranty burden;
- return/DOA exposure;
- national logistics cost;
- exchange-rate risk;
- supplier cancellation;
- customer refusing deposit;
- very high support load on complex categories;
- B2B payment terms;
- working-capital risk;
- fraud/chargeback/payment-proof risks.

Do not invent profitability numbers.
Create `ECONOMIC_DATA_REQUIRED_BEFORE_SCALE`.

# TASK 8 — PRIVACY / PROFILING RED TEAM
Attack the idea of predicting “who can buy”.

Define a hard line between:
- legitimate first-party purchase evidence;
- voluntary explicit budget;
- aggregate territorial planning;
- prohibited or unjustified individual wealth profiling.

Do not infer sensitive traits.
Do not recommend building hidden dossiers across platforms.
Cross-platform identity linkage of ordinary people should remain `DO_NOT_LINK` unless explicit authorization/verified first-party context exists.

Flag any area requiring `LEGAL_REVIEW_REQUIRED` rather than inventing legal conclusions.

# TASK 9 — MULTITENANT / DATA-SEPARATION RISK
IQ GROWTH is multi-company/multi-rubro.

Attack how IPCENTER customer/supplier/social intelligence could leak across companies or become improperly reused.

Include:
- first-party WhatsApp data;
- customer purchase history;
- supplier quotes;
- competitor evidence;
- shared resources;
- future external tenants.

Define controls conceptually; do not redesign Core code.

# TASK 10 — PREDICTION FALSIFICATION
For candidate predictions such as:
- “this product will sell in city X”;
- “this budget band is underserved”;
- “this model is emerging”;
- “this microzone has premium demand”;
- “import-on-demand beats local stock here”;

design tests that could PROVE THE HYPOTHESIS WRONG.

Use:
`HYPOTHESIS -> DISCONFIRMING EVIDENCE -> CHEAP TEST -> STOP CONDITION -> LEARNING`.

No arbitrary numeric stop thresholds unless `TO_CALIBRATE`.

# TASK 11 — WHAT DATA WOULD CHANGE YOUR MIND?
Produce a ranked-by-importance set of evidence gaps, but do not use fake numeric scores.

For each gap:
- decision affected;
- cheapest credible way to obtain data;
- whether public / first-party / human capture / supplier evidence;
- risk if we proceed without it.

# REQUIRED OUTPUT
A. THESIS ATTACK SUMMARY
B. BUYABILITY MISCLASSIFICATION MATRIX
C. 40+ SIGNAL-POISONING ATTACKS
D. COVERAGE / BLIND-SPOT MODEL
E. FRESHNESS / STALE-EVIDENCE MODEL
F. EXACT-VARIANT FAILURE MATRIX
G. TRUST / SELLER-VERIFICATION ATTACK
H. ECONOMIC FAILURE ANALYSIS
I. PRIVACY / PROFILING BOUNDARIES
J. MULTITENANT DATA-SEPARATION RISKS
K. PREDICTION FALSIFICATION TESTS
L. ECONOMIC_DATA_REQUIRED_BEFORE_SCALE
M. TOP EVIDENCE GAPS
N. CLAIMS THAT SHOULD CURRENTLY BE REJECTED OR DOWNGRADED
O. SAFE ACTIONS THAT REMAIN VALID EVEN UNDER UNCERTAINTY

## Quality Gate
Fail if you:
- produce a generic cybersecurity list;
- invent law or regulation;
- invent numerical risk probabilities;
- equate public data with representative data;
- treat neighborhood as individual wealth;
- propose excessive controls with no business proportionality;
- fail to provide concrete falsification tests.

Final line exactly:
`IPCenter BUYABILITY SIGNAL RED TEAM READY FOR CHATGPT SYNTHESIS`
