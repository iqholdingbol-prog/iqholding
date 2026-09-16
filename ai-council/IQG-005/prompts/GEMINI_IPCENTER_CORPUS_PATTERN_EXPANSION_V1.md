# GEMINI — IQG-005 IPCENTER
## CORPUS PATTERN MINING + SEARCH EXPANSION V1

**CEO:** Iván Quea
**Coordinator:** ChatGPT
**Role:** Market Intelligence Pattern Miner / Search Expansion Analyst

## Mission
Do NOT retry the failed live-social scraping mission if your environment lacks live web access.

Your new job is to extract more intelligence from the evidence already collected, discover hidden patterns, identify contradictions and generate high-value next searches for ChatGPT to verify live.

Hard rule:
> NO SOURCE = NO FACT.

If live web access is available, you may verify specific claims with direct URLs. If it is not available, do not simulate or invent browsing.

Use states:
`CONFIRMED`, `CEO_REPORTED`, `DIRECT_PUBLIC_EVIDENCE`, `EXTERNAL_EVIDENCE`, `ESTIMATED`, `INFERENCE`, `HYPOTHESIS`, `UNKNOWN`, `TO_VERIFY`, `FIRST_PARTY_REQUIRED`.

## Evidence snapshot
Current observed evidence includes:
- IPCENTER historically sold and shipped nationwide: La Paz, El Alto, Oruro, Potosí, Llallagua, Tarija, Trinidad, Santa Cruz, Sucre and Cobija. `CEO_REPORTED / HISTORICAL_FIRST_PARTY_TO_RECOVER`.
- Historical high-end laptop activity included MSI Leopard. `CEO_REPORTED`.
- Public buyer signals already found include explicit budgets around:
  - Bs 3,100 for a specific phone search in Santa Cruz with availability friction;
  - Bs 8,000 for a new gaming laptop from Sucre, with willingness to buy from another city;
  - Bs 12,000–13,000 for a gaming PC/components with local-vs-US-import comparison;
  - Bs 15,000 for a gaming PC including monitor.
- Public buyers repeatedly discuss:
  - exact model/variant;
  - new vs refurbished;
  - warranty;
  - whether a seller is real;
  - national shipping;
  - local-vs-import cost;
  - customs/final landed cost;
  - unavailable or hard-to-find products;
  - architecture/rendering/software use cases.
- Competitors operate multi-channel funnels using combinations of Facebook, TikTok, Instagram, WhatsApp, catalogs, physical stores, WhatsApp communities and national shipping.
- Product Fit already exists partially among competitors.
- Same exact-model product can have different price, stock and warranty states; therefore price-only comparison is insufficient.
- Bolivia is highly unequal and aggregate purchasing-power zones exist, but geography does not prove individual wealth.

If repository access exists, read:
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

If unavailable, state that explicitly and work from this evidence snapshot only.

# TASK 1 — PATTERN MINING
From the supplied corpus, identify recurring structures in:
- buyer need;
- budget;
- product specificity;
- city/destination;
- willingness to buy from another city;
- local-vs-import dilemma;
- trust/warranty concerns;
- hard-to-find product requests;
- use-case/software requests;
- national fulfillment.

For every pattern provide:
`PATTERN -> SUPPORTING OBSERVATIONS -> CONTRADICTING OBSERVATIONS -> CONFIDENCE -> WHAT WOULD VERIFY/FALSIFY IT`.

Do not generalize to all Bolivia from a handful of posts.

# TASK 2 — LANGUAGE MINING
Extract the language buyers actually use or are likely to use based on the observed corpus structure.

Separate:
- phrases directly observed in supplied evidence;
- semantic variants you propose for future search.

Label proposed variants `SEARCH_EXPANSION`, not market evidence.

Build query families for:
- budget declarations;
- where-to-buy questions;
- availability complaints;
- model-specific searches;
- architecture/engineering/design workloads;
- import-vs-local;
- warranty/trust;
- refurbished/new;
- national delivery;
- hard-to-find electronics;
- phones;
- laptops;
- GPUs/components;
- drones;
- auto parts;
- B2B technology procurement.

# TASK 3 — NATIONAL GEOGRAPHIC GAPS
Build a `GEOGRAPHIC_EVIDENCE_GAP_MAP`.

Cities/areas to consider include, but are not limited to:
Santa Cruz, La Paz, El Alto, Cochabamba, Sucre, Oruro, Potosí, Tarija, Trinidad, Cobija, Llallagua and other economically relevant centers.

For each geography classify:
- historical IPCENTER evidence;
- current public demand evidence;
- current competitor evidence;
- price/stock evidence;
- purchasing-power context evidence;
- missing data.

Do not infer that absence of posts means absence of demand.

# TASK 4 — CATEGORY GAP MAP
Compare evidence depth for:
- high-end/gaming laptops;
- creator/engineering/workstation laptops;
- custom gaming PCs;
- GPUs/components;
- premium phones;
- hard-to-find phones;
- drones;
- specialized electronics;
- auto parts;
- B2B procurement.

For each category report:
`WHAT_WE_KNOW / WHAT_WE_ONLY_HYPOTHESIZE / WHAT_CHATGPT_SHOULD_SEARCH_NEXT`.

# TASK 5 — BUYER-STATE MODEL
Develop a state model using only observable/first-party evidence:

`AWARENESS -> DESIRE -> ACTIVE_SEARCH -> EXPLICIT_NEED -> BUDGET_DISCLOSED -> QUOTE_REQUESTED -> QUOTE_ACCEPTED -> DEPOSIT -> PURCHASE -> DELIVERY -> OUTCOME`.

Explain which public signals may suggest each state and which states cannot be reliably inferred without first-party data.

# TASK 6 — EMERGING-DEMAND DETECTION
Design a method to detect an emerging product or need before competitors react.

Potential evidence classes:
- repeated model requests;
- increased search-language diversity around same need;
- repeated stockout complaints;
- exact-model price dispersion;
- competitor product additions;
- repeated “where can I get this?” questions;
- first-party quote frequency;
- quote-to-sale conversion;
- supplier availability changes;
- new product launches.

Do not invent a trend threshold. Mark calibration requirements.

# TASK 7 — CONTRADICTION MINING
Find contradictions that should trigger more research, such as:
- buyers say local is expensive but local price may be competitive after import cost;
- a city appears low-income in aggregate but historical high-ticket buyers exist;
- a product appears demanded socially but may not convert;
- competitors claim national shipping but coverage may differ;
- “new” vs “refurbished” language may be inconsistent.

Create:
`CONTRADICTION -> WHY IT MATTERS -> EVIDENCE NEEDED`.

# TASK 8 — SEARCH BACKLOG FOR CHATGPT
Generate a deep, prioritized-by-decision-impact search backlog for ChatGPT's live research.

Do NOT use fake numeric scores.

Each item must include:
- exact research question;
- exact query variants;
- target platforms/sources;
- expected evidence type;
- decision it could change;
- how to avoid false positives;
- stop condition for sufficient evidence.

Create at least 50 high-value searches distributed across cities, categories and buyer problems.

# TASK 9 — HISTORICAL IPCENTER DATA RECOVERY PLAN
Design what we should recover from old first-party data to turn historical national sales into a training/calibration asset.

Possible sources:
- old WhatsApp Business conversations;
- order books;
- bank/QR payment records;
- courier records;
- invoices/receipts;
- old Facebook messages/leads;
- spreadsheets;
- product photos/catalogs.

Define the minimum useful fields and how to reconcile inconsistent historical records without inventing facts.

# TASK 10 — CONTENT-TO-DEMAND LOOP
Design how IPCENTER can use market intelligence to show users what they are actually searching for without pretending to know more than the evidence supports.

Example conceptual loop:
`MARKET SIGNAL -> CONTENT HYPOTHESIS -> CONTENT/QUOTE TEST -> LEAD QUALITY -> PURCHASE RESULT -> LEARNING`.

Separate:
- educational content;
- demand-testing content;
- product availability content;
- preorder interest;
- actual stock.

# REQUIRED OUTPUT
A. CORPUS PATTERN MAP
B. DIRECTLY OBSERVED LANGUAGE VS SEARCH-EXPANSION LANGUAGE
C. GEOGRAPHIC EVIDENCE GAP MAP
D. CATEGORY GAP MAP
E. BUYER-STATE MODEL
F. EMERGING-DEMAND DETECTION METHOD
G. CONTRADICTION REGISTER
H. 50+ LIVE-RESEARCH SEARCH BACKLOG FOR CHATGPT
I. HISTORICAL IPCENTER DATA RECOVERY PLAN
J. CONTENT-TO-DEMAND LEARNING LOOP
K. TOP 20 HYPOTHESES WORTH TESTING
L. TOP 20 CLAIMS WE MUST NOT MAKE YET

## Quality Gate
Fail if you:
- pretend to have browsed when you could not;
- invent sources or URLs;
- treat proposed search vocabulary as observed buyer language;
- claim national prevalence from sparse evidence;
- return generic market advice;
- omit falsification criteria.

Final line exactly:
`IPCenter CORPUS PATTERN EXPANSION READY FOR CHATGPT AUDIT`
