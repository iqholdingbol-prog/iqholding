# GEMINI — IQ GROWTH / IQG-005 IPCENTER
## SOCIAL-FIRST FORENSIC EVIDENCE RECOVERY V2

**CEO:** Iván Quea
**Coordinator:** ChatGPT
**Role:** Market Intelligence + External Evidence Lead

## Mission
Your V1 is rejected as incomplete and under-researched.

You used `ACCESS_LIMITATION` too early and introduced unsupported market claims. A simple independent public search already found IPCENTER public assets you marked UNKNOWN.

This V2 is not a rewrite of V1. It is a forensic collection mission.

**Rule:** `NOT_INDEXED != NOT_AVAILABLE`.

Use every legitimate public or authorized surface available. Do not bypass authentication, private accounts, access controls, CAPTCHAs, paywalls, platform restrictions or terms. When a surface cannot be accessed automatically, identify the exact authorized access path or human-capture requirement.

## Known seed evidence you must start from and independently verify
Public discovery has surfaced the following leads:
- Kyte catalog: `https://ipcentercbba.catalog.kyte.site/`
- phone: `+591 79153767`
- domain: `ipcenter.com.bo`
- address variants including `Calle Esteban Arce 591, Cochabamba` and older Gold Center / Av. Ayacucho references
- Instagram link/handle clues: `ipcenter`, `@ipcentercbba`
- Facebook link exists in public business directories
- public catalog includes brands/models/prices and one-year warranty statements

Do not accept these blindly. Resolve them across sources.

# PHASE 1 — IPCENTER ENTITY RESOLUTION

Search and cross-link using all combinations:
- `IPCENTER`
- `IP Center`
- `IPcenter Cochabamba`
- `79153767`
- `+59179153767`
- `ipcenter.com.bo`
- `ipcentercbba`
- address variants
- product model fingerprints from the Kyte catalog

For every discovered property create:

`ENTITY_EVIDENCE_REGISTER`

Fields:
- EVIDENCE_ID
- PLATFORM
- URL
- ACCOUNT/PAGE/HANDLE
- PHONE
- DOMAIN
- ADDRESS
- DISPLAY_NAME
- LAST_VISIBLE_ACTIVITY
- OBSERVED_AT
- SOURCE_DATE
- DIRECT_EVIDENCE
- CROSS_MATCH_FIELDS
- CURRENT/HISTORICAL/STALE/UNKNOWN
- CONFIDENCE

Do not merge identities merely because names look similar. Require at least one strong key such as phone/domain/address/direct cross-link, or multiple weaker independent matches.

# PHASE 2 — FACEBOOK FORENSIC COLLECTION

Search direct Facebook/public surfaces and web-indexed Facebook remnants for:
- IPCENTER page/profile
- posts
- comments
- reviews/recommendations
- public photos/videos
- Marketplace listings if attributable
- phone/domain/Instagram/WhatsApp cross-links
- historical product promotions
- public customer questions

Also search relevant competitor pages.

For each accessible post/comment/review collect:
- URL/object URL
- account/business
- date
- product/category
- public engagement counts if visible
- <=10-word evidence snippet OR faithful paraphrase
- signal classification
- location if explicitly stated
- price if explicitly stated
- confidence

Signal taxonomy initial:
- PRICE_INQUIRY
- PRICE_RESISTANCE
- PRODUCT_REQUEST
- AVAILABILITY_REQUEST
- COMPATIBILITY_QUESTION
- DELIVERY_REQUEST
- CITY_DEMAND
- WARRANTY_CONCERN
- TRUST_CONCERN
- PRODUCT_PREFERENCE
- SERVICE_COMPLAINT
- WAIT_TIME_COMPLAINT
- PURCHASE_INTENT
- PURCHASE_CLAIM
- RECOMMENDATION
- NEGATIVE_EXPERIENCE
- OTHER

Do not infer demographics, income, politics, health or other sensitive attributes.

# PHASE 3 — INSTAGRAM FORENSIC COLLECTION

Resolve all IPCENTER handle variants and linked profiles.

Collect public evidence where accessible:
- profile metadata
- bio/contact links
- posts/reels
- captions
- public comments
- product tags/names
- visible prices
- location/city
- hashtags
- engagement counts
- public customer questions

Search competitors and category conversation using relevant hashtags/queries for Bolivia and major cities.

Do not convert likes into sales.

# PHASE 4 — TIKTOK FORENSIC COLLECTION

Search TikTok public content and publicly indexed TikTok references for:

IPCenter terms:
- IPCENTER
- ipcentercbba
- phone/domain variants

Demand/problem terms, including Spanish/Bolivian wording:
- laptop gaming Bolivia
- laptop para arquitectura Bolivia
- laptop para AutoCAD Bolivia
- laptop para Lumion Bolivia
- laptop para ingeniería Bolivia
- MSI Bolivia
- Alienware Bolivia
- ASUS ROG Bolivia
- no encuentro laptop Bolivia
- importar laptop Bolivia
- comprar laptop EEUU Bolivia
- dónde comprar laptop Cochabamba / La Paz / Santa Cruz

Expand query vocabulary from actual observed language.

For each relevant public video/comment accessible:
- URL
- creator/account
- date
- text/caption/comment
- product/category
- city only if explicit
- engagement metrics if visible
- signal classification
- whether commercial/promotional/user-generated
- confidence

Do not use TikTok Research API unless eligibility is actually verified for this commercial project.

# PHASE 5 — WHATSAPP BUSINESS PUBLIC SURFACE

Distinguish strictly:

A. IPCENTER first-party WhatsApp data — not accessible externally; mark `FIRST_PARTY_REQUIRED`.
B. Public WhatsApp links/catalog/business profile surfaces discoverable from web/social/business pages.
C. Competitor private chats — `PRIVATE_UNAUTHORIZED`, do not access.

For public WhatsApp/catalog surfaces, capture where legitimately visible:
- wa.me URL
- phone
- business name
- catalog link
- visible product
- visible price
- description
- public business metadata
- source page that exposed the link

If catalog/profile is visible only through a human-authenticated WhatsApp client, report:
`HUMAN_AUTHENTICATED_CAPTURE_REQUIRED`
plus exact capture instructions and fields.

# PHASE 6 — MARKETPLACE / CATALOG / DELIVERY / YOUTUBE / OTHER SOCIAL

Search:
- Facebook Marketplace public/indexed surfaces
- Kyte catalogs
- MercadoLibre/other relevant marketplaces if active in Bolivia
- business catalogs
- YouTube
- public Telegram channels/groups only if genuinely public and relevant
- public forums/community pages
- Google Maps/reviews
- local business directories

Use these as corroborating sources, not substitutes for social evidence.

# PHASE 7 — IPCENTER HISTORICAL PRODUCT RECONSTRUCTION

Use the public Kyte catalog and any other verified historical assets to build:

`IPCENTER_PRODUCT_EVIDENCE_REGISTER`

Fields:
- PRODUCT_ID
- BRAND
- MODEL
- CONFIGURATION
- PRICE
- CURRENCY
- WARRANTY_TEXT
- SOURCE_URL
- SOURCE_DATE/UNKNOWN
- OBSERVED_AT
- CURRENT/HISTORICAL
- CONFIDENCE

Do not label old catalog prices as current 2026 prices.

# PHASE 8 — COMPETITOR SOCIAL MAP

Identify relevant Bolivia competitors through actual public social presence.

Prioritize:
- laptops/gaming/high-end
- import-on-demand
- tech sourcing
- cellphone premium
- drones
- B2B procurement
- specialized electronics

Do not stop at 4–5 businesses if discoverable evidence exists.

For each competitor:
- business
- city
- Facebook
- Instagram
- TikTok
- WhatsApp public link
- website/catalog
- latest visible activity date
- products/categories
- pricing visibility
- public customer questions/comments
- warranty language
- preorder/import/sourcing evidence
- source URLs
- confidence

# PHASE 9 — SOCIAL DEMAND SIGNAL DATASET

This is the central deliverable.

Build a row-level dataset of observed public market signals.

`SOCIAL_DEMAND_SIGNAL_REGISTER`

Fields:
- SIGNAL_ID
- PLATFORM
- SOURCE_URL
- DATE
- OBSERVED_AT
- ACCOUNT/BUSINESS
- USER_TYPE = BUSINESS / CREATOR / PUBLIC_USER / UNKNOWN
- CATEGORY
- PRODUCT/MODEL
- NEED
- SIGNAL_TYPE
- CITY_EXPLICIT
- PRICE_EXPLICIT
- QUANTITY_EXPLICIT
- SHORT_EVIDENCE/PARAPHRASE
- ENGAGEMENT_VISIBLE
- DUPLICATE_CLUSTER_ID
- POSSIBLE_PROMOTIONAL_CONTENT
- CONFIDENCE

No individual user dossier. Do not attempt cross-platform identity resolution of ordinary people.

# PHASE 10 — CROSS-SOURCE CORROBORATION

Create `CORROBORATION_CLUSTERS`.

A cluster may be:
- same product/model need
- same city need
- same price objection
- same compatibility problem
- same trust/warranty problem

For each cluster:
- number of observations
- platforms represented
- date range
- unique source objects
- commercial vs user-generated mix
- known bias
- evidence strength

Do NOT claim population prevalence from social samples.

# PHASE 11 — BOT / DUPLICATE / PROMOTION FILTER

Before aggregation, flag:
- exact duplicate text
- reposts
- same source syndicated
- obvious ads
- giveaway comments
- bot-like repetition
- creator campaigns
- affiliate/promotional content

Do not count these as independent demand observations.

# PHASE 12 — SEARCH COVERAGE LOG

For transparency, provide a search log:
- platform
- query
- date searched
- result/access status
- relevant objects found
- block reason if any
- next authorized method

Allowed access states:
- DIRECT_PUBLIC_EVIDENCE
- PUBLIC_AUTHENTICATED_VISIBLE
- FIRST_PARTY_REQUIRED
- API_PERMISSION_REQUIRED
- HUMAN_AUTHENTICATED_CAPTURE_REQUIRED
- LICENSED_PROVIDER_REQUIRED
- NOT_FOUND_AFTER_EXHAUSTIVE_SEARCH
- PRIVATE_UNAUTHORIZED
- UNKNOWN

Do not write `ACCESS_LIMITATION` without specifying which of the above applies.

# PHASE 13 — SELF-AUDIT OF V1

Explicitly audit and classify every material V1 assertion as:
- KEEP
- CORRECT_WITH_SOURCE
- DOWNGRADE_TO_HYPOTHESIS
- REJECT
- UNKNOWN

Mandatory claims to revisit:
- 44k audience as a moat
- past ad efficiency
- competitor activity HIGH
- demand HIGH/MEDIUM
- 30–40% Bolivia premium
- +25–45% traditional price delta
- 1–3% freight insurance
- 7–21 day customs timing
- 6–12 month local warranty
- strong drone/agriculture demand
- low/zero observable AI use by competitors
- manual WhatsApp photo evidence as market norm
- B2B procurement opportunity
- `base cautiva`
- `CAC = $0`

# PHASE 14 — EVIDENCE-ONLY SYNTHESIS

Only after collection, answer:
- what IPCENTER digital assets are actually recoverable?
- what public social demand signals exist?
- what problems repeat across more than one source/platform?
- what remains unknowable without first-party access?
- which hypotheses deserve a controlled commercial test?

Do not select a final wedge.
Do not recommend inventory purchase.
Do not claim demand from likes/followers alone.

# REQUIRED OUTPUT

A. V1 SELF-AUDIT
B. IPCENTER ENTITY RESOLUTION
C. FACEBOOK EVIDENCE DATASET
D. INSTAGRAM EVIDENCE DATASET
E. TIKTOK EVIDENCE DATASET
F. WHATSAPP PUBLIC-SURFACE DATASET
G. OTHER PLATFORM/CATALOG DATASET
H. HISTORICAL PRODUCT REGISTER
I. COMPETITOR SOCIAL MAP
J. SOCIAL DEMAND SIGNAL REGISTER
K. CORROBORATION CLUSTERS
L. BOT/DUPLICATE/PROMOTION FLAGS
M. SEARCH COVERAGE LOG
N. UNKNOWN / FIRST-PARTY REQUIRED
O. HUMAN CAPTURE TASKS
P. EVIDENCE-ONLY SYNTHESIS
Q. FULL SOURCE REGISTER

Every factual row must include a direct URL or explicitly state why a direct URL cannot be produced.

Final line exactly:

`IPCenter SOCIAL-FIRST EVIDENCE PACK READY FOR CHATGPT AUDIT`

or, if blocked:

`IPCenter SOCIAL-FIRST EVIDENCE PACK BLOCKED: <specific access paths still required>`
