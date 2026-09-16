# IQ GROWTH — UNIVERSAL MARKET INTELLIGENCE DATA MODEL V1

Date: 2026-09-16
Status: DESIGN_V1 / CROSS_VERTICAL / EVIDENCE_FIRST
Owner: IQHOLDING
Coordinator: ChatGPT

## Purpose

Build one reusable evidence and decision layer for IPCENTER, VANSAM, Café Zacarías, Chocolates and future verticals.

The goal is not to collect everything. The goal is to detect commercially relevant needs, verify them, test them, convert them into offers/actions, measure real outcomes, and learn.

The same Core must work across technology, restaurant, coffee, chocolate, retail and future services.

## Core principle

`OBSERVATION != SIGNAL != DEMAND != PURCHASE != PROFIT`

Universal learning loop:

`SOURCE -> RAW OBSERVATION -> PROVENANCE -> NORMALIZATION -> ENTITY/PRODUCT/NEED MATCH -> SIGNAL -> CORROBORATION -> HYPOTHESIS -> CONTROLLED ACTION -> QUOTE/OFFER -> TRANSACTION -> FULFILLMENT -> OUTCOME -> LEARNING -> MARKET MEMORY`

## Universal evidence record

Every externally or internally observed datum should be representable with these fields.

### Identity and tenancy
- `company_id`
- `branch_id` nullable where global
- `vertical_id`
- `evidence_id`
- `source_record_id` where available

### Source / provenance
- `source_type`: PUBLIC_WEB, PUBLIC_SOCIAL, PUBLIC_AUTHENTICATED, FIRST_PARTY, USER_AUTHORIZED, HUMAN_OBSERVED, LICENSED_PROVIDER, OFFICIAL_DOCUMENT, INTERNAL_TRANSACTION
- `platform`: facebook, instagram, tiktok, whatsapp, web, marketplace, delivery, google_reviews, reddit, pos, crm, bank, courier, etc.
- `source_url_or_ref`
- `source_account_or_entity`
- `observed_at`
- `captured_at`
- `collector_type`: AI, HUMAN, API, IMPORT, SYSTEM
- `raw_text_or_payload_ref`
- `evidence_hash_or_snapshot_ref` where appropriate

### Verification dimensions
Freshness and verification MUST remain separate.

`freshness_state`:
- FRESH
- RECENT
- STALE
- EXPIRED
- UNKNOWN

`verification_state`:
- DIRECTLY_VERIFIED
- SOURCE_CLAIMED
- THIRD_PARTY_CORROBORATED
- FIRST_PARTY_CONFIRMED
- OFFICIAL_DOCUMENT_SUPPORTED
- UNVERIFIED

### Data-quality controls
- `duplicate_cluster_id`
- `commercial_content_flag`
- `bot_or_automation_risk`
- `repost_flag`
- `seller_generated_flag`
- `anomaly_flag`
- `parser_confidence`
- `human_review_required`

### Geography
- `country`
- `department`
- `city`
- `microzone`
- `location_precision_state`

Never infer individual wealth from geography. Geography is an aggregate market context only.

### Entity / offering
- `business_entity_id` where resolvable
- `brand`
- `category`
- `product_or_service`
- `exact_variant_or_format`
- `condition` where applicable
- `seller_or_channel`

### Price / value
- `source_price_raw`
- `source_currency`
- `normalized_price`
- `normalized_currency`
- `fx_rate`
- `fx_source`
- `fx_observed_at`
- `shipping_cost`
- `total_cost_state`: CONFIRMED, CALCULATED_WITH_CONFIRMED_INPUTS, ESTIMATED_WITH_ASSUMPTIONS, UNKNOWN
- `price_sanity_check`

### Need / signal
Universal `signal_type` vocabulary includes:
- PRODUCT_REQUEST
- SERVICE_REQUEST
- PRICE_INQUIRY
- PRICE_RESISTANCE
- AVAILABILITY_REQUEST
- DELIVERY_REQUEST
- CITY_DEMAND
- WAIT_TIME_CONCERN
- SERVICE_COMPLAINT
- QUALITY_COMPLAINT
- PRODUCT_PREFERENCE
- PROMOTION_INTEREST
- WARRANTY_CONCERN
- TRUST_CONCERN
- IMPORT_REQUEST
- HARD_TO_FIND_PRODUCT
- COMPATIBILITY_QUESTION
- PURCHASE_INTENT
- BUDGET_MENTION
- UPGRADE_INTENT
- REPLACEMENT_INTENT
- B2B_NEED
- RECOMMENDATION
- NEGATIVE_EXPERIENCE

### Buyer-state / commercial state
Public evidence should never be silently upgraded into first-party transaction truth.

Possible states:
- AWARENESS
- DESIRE
- ACTIVE_SEARCH
- EXPLICIT_NEED
- BUDGET_DISCLOSED
- QUOTE_REQUESTED
- QUOTE_SENT
- QUOTE_ACCEPTED
- DEPOSIT
- PURCHASE
- FULFILLMENT
- OUTCOME
- REPEAT

### Buyability evidence
Buyability is not inferred from appearance, neighborhood, device, job title or social following.

Store explicit evidence only:
- `declared_budget`
- `budget_scope`
- `budget_observed_at`
- `payment_preference`
- `financing_interest`
- `financing_state`: UNKNOWN, INTERESTED, APPLICATION_STARTED, APPROVED, REJECTED, NOT_APPLICABLE
- `prior_transaction_reference` only if first-party and authorized
- `deposit_state`
- `payment_state`

Use states such as:
- BUDGET_UNKNOWN
- DECLARED_BUDGET_BELOW_CURRENT_VERIFIED_OPTIONS
- BUDGET_ALIGNED_LOW_URGENCY
- BUDGET_ALIGNED_HIGH_INTENT
- TRANSACTION_COMMITTED

Do not claim present liquidity from historical purchases.

## Universal experiment record

Every growth action should be auditable:
- `hypothesis_id`
- `evidence_inputs[]`
- `hypothesis_text`
- `disconfirming_evidence_expected`
- `action_type`: CONTENT, OFFER, PREORDER, QUOTE, PROMOTION, PRICING_TEST, CHANNEL_TEST, PRODUCT_TEST, LOCATION_TEST
- `target_scope`
- `start_at`
- `end_at`
- `cost`
- `result_metric`
- `result_value`
- `decision_after_result`
- `learning`

## Universal decision rule

Weak evidence may justify cheap reversible actions.
Strong financial commitments require stronger evidence.

Suggested escalation logic, NOT fixed numeric thresholds:

`WEAK SIGNAL -> RESEARCH`
`CORROBORATED SIGNAL -> CONTENT / LOW-COST TEST`
`FIRST-PARTY INQUIRY -> QUOTE / OFFER`
`ACCEPTED QUOTE -> SOURCING / OPERATIONAL PREPARATION`
`DEPOSIT / PAYMENT -> PROCUREMENT / FULFILLMENT`
`REPEATED PROFITABLE SALES -> CONSIDER STOCK / SCALE`

Thresholds must be calibrated per vertical with real outcomes.

## Vertical adapters

### IPCENTER adapter
Additional fields:
- exact SKU/model
- CPU/GPU/RAM/storage
- region
- serial/IMEI when appropriate
- stock state
- warranty layers
- seller verification
- local/national/import option
- landed-cost inputs
- customer city / stock city / shipping path

Primary truth outcome: `QUOTE -> PAYMENT -> DELIVERED_PRODUCT -> WARRANTY/REPEAT`.

### VANSAM adapter
Additional fields:
- menu_item
- size
- flavor/toppings
- dine_in/takeaway/delivery
- order_time
- prep_start
- ready_time
- delivery_time
- price
- contribution when cost known
- complaint type
- rating
- repeat customer state
- daypart
- table/zone

External signals should capture:
- pizza/flavor requests
- price comparisons
- delivery demand
- wait-time complaints
- service complaints
- portion/quality comments
- competitor menu/promotions
- content engagement only as weak evidence

Primary truth outcome: `ORDER -> SALE -> PAYMENT -> PREP/FULFILLMENT -> SATISFACTION -> REPEAT`.

### Café Zacarías adapter
Additional fields:
- product line
- torrado/specialty
- origin/lot
- varietal if verified
- roast level/date
- grind
- format/weight
- channel
- wholesale/retail
- seller/route
- price
- repeat frequency
- quality evidence / cup score only when documented

External signals should capture:
- price sensitivity
- roast preference
- ground vs whole-bean
- preparation method
- origin interest
- freshness/date interest
- retail vs wholesale demand
- delivery/city demand

Primary truth outcome: `PRODUCT_PRESENTATION -> CHANNEL -> SALE -> REPEAT -> LOT/PRODUCT LEARNING`.

### Chocolates adapter
Brand name remains `BRAND_NAME_PENDING` until CEO confirms.

Additional fields:
- cacao percentage
- product form
- weight
- flavor/inclusion
- gifting vs self-consumption
- packaging
- occasion
- retail/wholesale
- price
- cacao/input lot where relevant

External signals should capture:
- dark/milk/white preference
- cacao percentage
- sugar/no-sugar requests
- gift occasions
- package/size preference
- price sensitivity
- city/channel demand
- wholesale/store requests

Primary truth outcome: `PRODUCT/OCCASION -> PURCHASE -> REPEAT / GIFT RESPONSE -> PRODUCT LEARNING`.

## Cross-vertical insight examples

A universal system can learn patterns without collapsing vertical meaning:
- WhatsApp may be a conversion channel across IPCENTER, coffee, chocolate and restaurant, but the commercial event differs by vertical.
- Price resistance is universal; unit economics are vertical-specific.
- City/microzone is universal context; geography never proves individual purchasing power.
- Social engagement is discovery evidence across verticals; first-party transactions are stronger truth.
- Delivery friction is universal; technology shipping, pizza delivery and packaged coffee logistics require different adapters.

## Privacy and ethics boundaries

Do not:
- build secret cross-platform dossiers on ordinary people;
- infer individual wealth from neighborhood, clothing, device or public social profile;
- infer sensitive traits;
- connect identities across platforms without authorization;
- bypass private/closed groups or access controls;
- use commercial customer data for unrelated political persuasion.

Use:
- public business/market evidence;
- aggregated territorial statistics;
- first-party commercial interactions;
- user-authorized data;
- human-authenticated capture where legitimate;
- licensed providers where appropriate.

## Automation horizon

Future system architecture should support pluggable source adapters:

`ADAPTER -> RAW_EVIDENCE_STORE -> NORMALIZER -> ENTITY_RESOLUTION -> SIGNAL_CLASSIFIER -> QUALITY_FILTER -> MARKET_MEMORY -> DECISION_ENGINE -> ACTION/EXPERIMENT -> OUTCOME -> LEARNING`

Adapters may include:
- web/search
- Facebook public/authorized
- Instagram public/authorized
- TikTok public/authorized
- WhatsApp first-party/public catalog
- marketplaces
- delivery platforms
- Google/reviews
- POS/CRM
- bank/payment imports
- courier/logistics
- official procurement feeds
- human evidence collector

The Core must not hardcode a platform. Platforms are replaceable adapters.

## Current gate

This document defines the universal data/decision contract only.

DO NOT begin cross-vertical production coding while IQG-001.2 Core runtime/security gate remains open.

Next validation sequence:
1. Claude cross-vertical product/decision challenge.
2. DeepSeek cross-vertical data-integrity/security red team.
3. Gemini cross-vertical external-evidence expansion.
4. ChatGPT synthesis + live verification.
5. Only after Core gate: technical implementation planning.

Status: `UNIVERSAL_MARKET_INTELLIGENCE_DATA_MODEL_V1_READY_FOR_AI_COUNCIL_CHALLENGE`
