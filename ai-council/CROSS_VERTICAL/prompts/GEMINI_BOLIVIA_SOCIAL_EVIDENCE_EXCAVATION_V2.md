# GEMINI — BOLIVIA SOCIAL EVIDENCE EXCAVATION V2

Date: 2026-09-16
Role: Market Intelligence / External Evidence
Scope: VANSAM + Café Zacarías + Chocolates + IPCENTER

## Mission

Excavate current, decision-useful evidence about what people in Bolivia want to buy, where, at what price/budget, through which channels, with what friction, and with what level of purchase intent.

The goal is not a market overview. The goal is row-level evidence that can feed IQ GROWTH Market Memory.

Priority surfaces:
- Facebook public Pages/Groups/Marketplace where legitimately accessible
- TikTok public posts/comments/search
- Instagram public accounts/posts/comments
- WhatsApp public business links/catalogs and FIRST-PARTY/authorized channels only
- Google Maps/reviews
- delivery platforms
- public web catalogs
- Reddit/forums
- local directories
- official/statistical sources where relevant

No unauthorized private access. No fabricated browsing. If a surface is blocked, record the access state and move to another legitimate source.

## Required repository reading

If access exists, read:
- `docs/IQG_UNIVERSAL_MARKET_INTELLIGENCE_DATA_MODEL_V1.md`
- `docs/IQG_INFORMATION_ADVANTAGE_DOCTRINE_V1.md`
- `ai-council/AI_COUNCIL_QUALITY_GATE_V1.md`
- `docs/CEO_CORRECTIONS_2026-09-15.md`
- current VANSAM baseline/synthesis
- current IPCENTER live-research passes/synthesis

If unavailable, say so explicitly.

## Evidence contract

Every observation must contain as many of these fields as the source truly supports:

`observed_at`
`source_url`
`platform`
`source_type`
`access_state`
`city`
`microzone`
`business/entity`
`category`
`product/service`
`variant/configuration`
`raw_language_excerpt`
`price`
`currency`
`budget_mentioned`
`availability/stock/capacity_claim`
`delivery/shipping`
`warranty/trust claim`
`purchase_intent_state`
`signal_category`
`evidence_class`
`confidence`
`bias/false-positive risk`
`duplicate_group`
`decision_relevance`

Quotes must be brief. Do not invent missing fields.

## Buyer-state discipline

Use these states where evidence supports them:
- AWARENESS
- DESIRE
- ACTIVE_SEARCH
- EXPLICIT_NEED
- BUDGET_DISCLOSED
- QUOTE_REQUESTED
- PRICE_ACCEPTED
- DEPOSIT/PAYMENT_CLAIM
- PURCHASE_CLAIM
- VERIFIED_FIRST_PARTY_PURCHASE
- FULFILLED
- REPEAT

Do not promote a public comment to a purchase.

## Vertical missions

### A. VANSAM — minimum 30 meaningful observations

Seek evidence about:
- pizza flavors/toppings people request or praise;
- price points and price resistance;
- portion/size expectations;
- delivery vs takeaway vs salon;
- wait-time complaints;
- service complaints;
- combo/bundle behavior;
- late-night demand;
- family vs individual purchase occasions;
- competitor menu simplification/complexity;
- coffee/chocolate/frappé attachment where observed;
- social content that produces explicit buying questions, not just views.

Prioritize Cochabamba and the relevant competitive geography.

### B. Café Zacarías — minimum 30 meaningful observations

Seek evidence about:
- torrado vs specialty preferences;
- bean vs ground;
- roast/profile language;
- 250g/500g/1kg and other package sizes;
- household vs reseller/retail demand;
- direct producer/origin value;
- price resistance;
- brewing method;
- freshness;
- street-vendor/micro-retail channels;
- WhatsApp ordering;
- hotel/restaurant/café demand signals;
- city expansion signals;
- Bolivian-origin preference.

Do not assume specialty-café audiences represent mass-market coffee buyers.

### C. Chocolates — minimum 30 meaningful observations

Seek evidence about:
- self-consumption vs gifting vs resale;
- occasion: birthday, Valentine's, Mother's Day, Christmas, corporate gifts, etc.;
- cocoa percentage;
- sugar/no-sugar preferences;
- format/weight;
- packaging;
- price/budget;
- local cacao/Bolivian origin;
- seasonal demand;
- where people buy;
- WhatsApp/Instagram ordering;
- gift personalization;
- retail/reseller signals.

Separate seasonal spikes from baseline demand.

### D. IPCENTER — minimum 30 meaningful observations

Seek evidence about:
- exact laptop/phone/GPU/drone/specialized-tech model;
- exact configuration;
- explicit budget;
- city;
- local vs another city vs import;
- stockout/hard-to-find;
- new/refurbished/open-box;
- warranty;
- seller trust;
- delivery/shipping;
- financing interest;
- architecture/engineering/creator/gaming/workload;
- exact product availability and price;
- national purchase intent.

Keep B2C separate from B2B/procurement.

## Source coverage requirements

For each vertical produce a source coverage matrix:
`PLATFORM | QUERIES ATTEMPTED | RESULTS FOUND | ACCESS LIMITATION | USEFUL OBSERVATIONS | DUPLICATES | QUALITY NOTES`

Do not rely on Google results alone.

If direct Facebook/TikTok/Instagram access fails:
- record `ACCESS_LIMITATION`;
- use legitimate public index/link hubs/caches/search results where appropriate;
- do not call inaccessible content “verified”;
- produce a precise human-authenticated capture backlog for material gaps.

## Search expansion

Generate at least 120 follow-up research questions total, minimum 30 per vertical.

Each must include:
- exact query variants;
- target platform;
- expected evidence;
- decision changed;
- false-positive risk;
- stop condition.

Do not generate filler queries.

## Cross-source corroboration

Identify observations that appear across multiple independent surfaces.

Separate:
- independent corroboration;
- duplicated syndication;
- same seller reposting;
- same user cross-posting where identifiable only at the content/entity level without building person dossiers.

## Opportunity signals

Do NOT create a single arbitrary opportunity score.

Keep dimensions separate:
- purchase intent strength
- explicit budget/payment evidence
- unmet need/shortage
- price resistance
- competitive intensity
- fulfillment friction
- evidence strength
- freshness
- economic unknowns

## Contradictions

Produce at least 25 contradictions requiring further evidence, e.g.:
- high engagement but low transaction evidence;
- cheaper local price but no stock;
- strong social demand but poor margin;
- premium neighborhood but no purchase evidence;
- frequent seasonal gifting but weak year-round chocolate demand.

## Required output

A. Access & source coverage report
B. Row-level evidence dataset — VANSAM (30+)
C. Row-level evidence dataset — Café Zacarías (30+)
D. Row-level evidence dataset — Chocolates (30+)
E. Row-level evidence dataset — IPCENTER (30+)
F. Cross-source corroboration register
G. Duplicate/contamination register
H. 25+ contradiction register
I. Geographic gaps
J. Channel gaps
K. Buyer-state findings
L. Opportunity-signal dimensions without composite score
M. 120+ follow-up research backlog
N. Human-authenticated capture backlog
O. Claims that evidence does NOT support

Final exact line:

`BOLIVIA SOCIAL EVIDENCE EXCAVATION V2 READY FOR CHATGPT AUDIT`
