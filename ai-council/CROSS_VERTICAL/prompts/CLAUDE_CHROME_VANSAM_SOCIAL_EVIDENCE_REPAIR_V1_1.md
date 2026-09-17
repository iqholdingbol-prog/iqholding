# CLAUDE IN CHROME — VANSAM SOCIAL EVIDENCE REPAIR V1.1

You already completed `VANSAM SOCIAL EVIDENCE PRODUCTION V1` and created:

- `VANSAM_social_evidence_report_v1.md`
- `VANSAM_social_evidence_ledger_v1.csv`

DO NOT restart from zero.
DO NOT discard the 115-row corpus.
DO NOT repeat the entire 118-action crawl unless needed to recover missing provenance.

This is a **repair + targeted completion pass**.

## AUDIT STATUS

ChatGPT audit verdict:

`EXPLORATORY_CORPUS_PASS / DECISION_GRADE_LEDGER_FAIL_PENDING_REMEDIATION`

The browser execution and evidence discovery were useful. The current ledger is not yet decision-grade because the evidence contract, provenance and aggregation model were only partially implemented.

Your task is to repair those defects with real browser verification where needed.

==================================================
0. OPERATING MODE
==================================================

REAL BROWSER EXECUTION.
READ ONLY.

NO:
- publish
- comment
- like
- follow
- message
- contact seller
- modify profile
- change settings
- open private conversations
- collect unnecessary PII

If CAPTCHA/2FA/human authorization appears, stop only at that point and request that intervention.

==================================================
1. PRESERVE CURRENT CORPUS
==================================================

Treat the current 115 rows as an input corpus.

Do not silently delete rows.

Every V1 row must map to V1.1 through either:

- MATERIAL
- CONTEXT_ONLY
- DUPLICATE
- GEOGRAPHY_REJECTED
- OUT_OF_SCOPE
- UNRESOLVED

Add:

`row_status`
`exclusion_reason`

At the end, counts MUST reconcile exactly to total rows.

==================================================
2. IMPLEMENT THE FULL EVIDENCE CONTRACT
==================================================

V1.1 must contain structured fields for at least:

- evidence_id
- platform
- source_url_or_reference
- parent_evidence_id
- source_account
- source_type
- published_at_raw
- published_at_start
- published_at_end
- published_at_precision
- observed_at
- city
- microzone
- geography_scope
- product_or_service
- variant_or_presentation
- raw_observation
- supporting_observation_count
- aggregation_method
- seller_price
- currency
- stock_or_availability_claim
- delivery_claim_or_request
- signal_type
- evidence_class
- verification_state
- duplicate_group_id
- seller_generated_bias
- selection_bias
- algorithmic_visibility_bias
- freshness_state
- decision_relevance
- WHAT_THIS_CAN_PROVE
- WHAT_THIS_CANNOT_PROVE
- next_verification_action
- row_status
- exclusion_reason
- notes

UNKNOWN / NOT_APPLICABLE are valid.

DO NOT invent values to avoid nulls.

==================================================
3. FACEBOOK PROVENANCE — CRITICAL REPAIR
==================================================

V1 had Facebook descriptions such as:

`Grupo ANTÓJATE COMIDA CBBA...`

instead of direct reproducible source URLs.

Recover direct/canonical Facebook post URLs or permalinks for the material Facebook parent sources wherever the UI permits.

For each Facebook parent source:

- open the actual post/thread
- capture the permalink/canonical URL
- store it in `source_url_or_reference`

For child comment rows:

- set `parent_evidence_id`
- carry the canonical parent URL as provenance

If a URL genuinely cannot be recovered, DO NOT invent one.
Set:

`source_url_or_reference = SOURCE_URL_NOT_CAPTURED`

and explain the failed recovery in `notes` / `next_verification_action`.

A search-description alone is not sufficient provenance.

==================================================
4. TIKTOK / INSTAGRAM PROVENANCE
==================================================

For TikTok comment rows currently saying:

`mismo video TT-001, comentarios`

preserve `parent_evidence_id = TT-001`
and the canonical video URL.

Do the equivalent for other parent/child evidence.

Instagram direct post/Reel URLs should remain canonical where available.

==================================================
5. RAW OBSERVATION != AGGREGATED SIGNAL
==================================================

V1 sometimes combined many comments into a single `raw_observation`.

That is analytically useful, but it is not literally one raw observation.

Fix the semantics.

If one V1 row represents several equivalent comments:

- keep the row if useful
- set `aggregation_method = SEMANTIC_COLLAPSE_WITHIN_SOURCE`
- set an exact `supporting_observation_count` if known
- otherwise use `COUNT_LOWER_BOUND` / `COUNT_UNKNOWN`
- preserve representative excerpts
- preserve the parent source

If comments materially differ, split them into separate rows.

Do not use semantic-collapsed row counts as population prevalence.

Do not claim frequency unless the counting method is auditable.

==================================================
6. DATE / FRESHNESS NORMALIZATION
==================================================

Do not destroy raw dates.

Use:

`published_at_raw`
`published_at_start`
`published_at_end`
`published_at_precision`

Precision examples:

EXACT
DAY_RANGE
MONTH
APPROXIMATE
NOT_VISIBLE
UNKNOWN

Use controlled `freshness_state`:

CURRENT_WINDOW
RECENT
STALE
EXPIRED
UNKNOWN

Do not invent calendar dates from vague UI labels unless the conversion is unambiguous and record the derivation.

==================================================
7. BIAS MODEL
==================================================

Make bias row-level and explicit.

`seller_generated_bias`
Possible values:
YES
NO
POSSIBLE
UNKNOWN

`selection_bias`
Record whether the observation comes from top/relevant comments, partial scroll, seller-selected content, etc.

`algorithmic_visibility_bias`
YES / POSSIBLE / UNKNOWN / NOT_APPLICABLE

IMPORTANT:
Do NOT call influencer content `paid` unless the platform explicitly marks a paid collaboration or there is direct evidence.
Otherwise use `PROMOTIONAL_OR_INFLUENCER_BIAS_POSSIBLE`.

==================================================
8. PROOF BOUNDARIES
==================================================

Every material row must state:

WHAT_THIS_CAN_PROVE
WHAT_THIS_CANNOT_PROVE

Examples:

PRICE_INQUIRY can prove:
- a public account asked for price under that content

It cannot prove:
- willingness to pay
- purchase
- demand prevalence

PUBLIC_PURCHASE_CLAIM can prove:
- a commenter publicly claimed to have consumed/bought

It cannot prove:
- verified purchase
- verified product quality
- complaint prevalence

OBSERVED_PUBLIC_OFFER can prove:
- an offer was publicly displayed at observation time

It cannot prove:
- stock
- transaction price
- sales volume
- profitability

==================================================
9. SATURATION LANGUAGE — REPAIR
==================================================

Do NOT claim market saturation.

Use structured collection states:

QUERY_SET_SATURATION_OBSERVED_TIKTOK
QUERY_SET_SATURATION_OBSERVED_INSTAGRAM
SELLER_CONTENT_DOMINANCE_OBSERVED_FACEBOOK
MARKET_SATURATION_NOT_ESTABLISHED

Explain exactly which executed query set saturated.

==================================================
10. RECONCILE COUNTS
==================================================

V1 reported:
115 total
101 material
12 geography/out-of-scope
1 explicit duplicate

but that does not fully reconcile and the CSV contains context rows with evidence class `—`.

V1.1 must output a reconciliation table whose statuses sum EXACTLY to the final ledger row count.

No approximate arithmetic.

==================================================
11. TARGETED MISSING COLLECTION — DO NOT FULL-RECRAWL
==================================================

After repairing provenance/schema, execute only targeted missing work:

A. Search VANSAM itself across accessible public platforms.

B. Deep-check the highest-signal competitor entities already discovered:
- Porta Nuova
- Malcriada
- Picolina
- La Casa del Sabor

C. Run the missing query families that were not separately executed:
- pizza familiar cochabamba
- pizza 2x1 cochabamba
- pizza para llevar cochabamba
- pizza noche cochabamba
- pizza quemada cochabamba
- cuanto tarda pizza cochabamba
- hacen delivery pizza cochabamba

D. Target café/frappé/chocolate gaps:
- frappe cochabamba
- chocolate caliente cochabamba
- cafeteria cochabamba
- cafe y pizza cochabamba

E. Facebook buyer-side 2026 only where possible:
- alguien sabe pizza cochabamba
- recomienden pizza cochabamba
- pedi pizza cochabamba
- llego frio pizza cochabamba
- demora pizza cochabamba

Do not expand indefinitely once targeted work stops adding material categories/entities.

==================================================
12. DO NOT CONTACT BUSINESSES
==================================================

Do not verify promo validity by messaging/calling sellers in this pass.

If promo status cannot be established from public evidence:

`verification_state = UNVERIFIED_CURRENT_VALIDITY`

We can authorize direct contact separately later.

==================================================
13. OUTPUT FILES
==================================================

Create:

`VANSAM_social_evidence_ledger_v1_1.csv`
`VANSAM_social_evidence_report_v1_1.md`

Do not overwrite V1.

==================================================
14. REPORT STRUCTURE
==================================================

Return:

1. REPAIR_SUMMARY
2. ROW_RECONCILIATION
3. PROVENANCE_RECOVERY
4. SCHEMA_COMPLIANCE
5. TARGETED_SEARCHES_EXECUTED
6. PLATFORM_COVERAGE
7. MATERIAL_EVIDENCE_LEDGER_SUMMARY
8. BUYER_SIDE_SIGNALS
9. SELLER_SIDE_OFFERS
10. PRICE_AND_PROMOTION_OBSERVATIONS
11. DELIVERY_AND_SERVICE_SIGNALS
12. QUALITY_SIGNALS
13. RECOMMENDATION_AND_PRODUCT_REQUEST_SIGNALS
14. VANSAM_PUBLIC_FOOTPRINT
15. CONTRADICTIONS
16. DUPLICATES_COLLAPSED
17. GEOGRAPHY_REJECTIONS
18. BIAS_AND_LIMITATIONS
19. PROOF_BOUNDARIES
20. EVIDENCE_GAPS
21. FIRST_PARTY_DATA_NEEDED_NEXT
22. COLLECTION_SATURATION_STATUS
23. UNRESOLVED_PROVENANCE
24. NEXT_VERIFICATION_ACTIONS

NO MARKET VERDICT.

==================================================
15. COMPLETION GATE
==================================================

Before declaring completion, self-check:

- all V1 rows accounted for
- final row totals reconcile exactly
- Facebook parent sources have canonical URL OR explicit URL_NOT_CAPTURED
- child comment rows have parent evidence link
- required structured fields exist
- aggregate rows expose counts/method
- no market saturation claim
- no likes/views interpreted as demand
- no public claim interpreted as verified sale
- no old price silently treated as current
- no geography false positive mixed into Cochabamba

Final exact line:

`VANSAM SOCIAL EVIDENCE V1.1 READY FOR CHATGPT REAUDIT`

EXECUTE NOW.