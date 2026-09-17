# ChatGPT Audit — Claude in Chrome VANSAM Social Evidence Production V1

**Date:** 2026-09-17  
**Project:** IQ GROWTH / IQHOLDING  
**Vertical:** VANSAM / Cochabamba  
**Auditor:** ChatGPT / AI Council Coordinator

## Verdict

`EXPLORATORY_CORPUS_PASS / DECISION_GRADE_LEDGER_FAIL_PENDING_REMEDIATION`

Claude in Chrome has now demonstrated real authenticated-browser execution against Facebook, TikTok and Instagram and produced a materially useful first corpus. This is a major access breakthrough versus Gemini V3.

However, the current V1 ledger is **not yet decision-grade** because provenance and evidence-contract requirements were only partially implemented. Do not discard the corpus. Repair it in place as V1.1; do not restart the research from zero.

## What passed

1. Real browser execution: 118 browser actions, 27 commands, no CAPTCHA/2FA/block reported.
2. Multi-platform acquisition completed across TikTok, Facebook, Instagram and Marketplace check.
3. Geographic false positives were explicitly rejected instead of silently mixed into Cochabamba.
4. Seller claims, public buyer signals, purchase claims and complaints were kept semantically distinct in many rows.
5. The report repeatedly warns that engagement != demand, posted price != paid price, and public purchase claim != verified purchase.
6. Duplicates and cross-posting were at least partially recognized.
7. Privacy discipline was acceptable for public research: no commenter names retained and a buyer phone was omitted.
8. The corpus surfaced useful hypotheses around location/hour/price friction, promotions, service delays, cold delivery, product-style disagreement and recommendation behavior without treating them as verified sales.

## Quantitative file audit

Attached CSV inspected programmatically:

- rows: 115
- columns: 17
- platform rows: TikTok 77, Facebook 24, Instagram 14
- unique evidence_id: yes
- evidence_class `—`: 16 rows
- direct/canonical-looking platform URLs in `source_url_or_reference`:
  - TikTok: 20 / 77
  - Facebook: 0 / 24
  - Instagram: 13 / 14

The report says 101 observations are material, 12 are rejected by geography/out-of-scope, and one row is an explicit duplicate. That arithmetic does not fully reconcile to 115, and the CSV contains 16 rows with no evidence class. V1.1 must make the material/excluded accounting deterministic.

## Critical findings

### C1 — Evidence contract was not implemented

The requested row contract contained materially more fields than the delivered 17-column CSV. Missing as dedicated fields include at least:

- `observed_at`
- `variant_or_presentation`
- `currency`
- `stock_or_availability_claim`
- `delivery_claim_or_request`
- `seller_generated_bias`
- `selection_bias`
- `algorithmic_visibility_bias`
- `decision_relevance`
- `WHAT_THIS_CAN_PROVE`
- `WHAT_THIS_CANNOT_PROVE`
- `next_verification_action`

Some concepts are buried in free-text `notes`, which is not sufficient for downstream normalization or reproducible audit.

**Severity:** CRITICAL for decision-grade ingestion.

### C2 — Facebook provenance is not reproducible

None of the 24 Facebook rows contains a direct Facebook URL in `source_url_or_reference`; they use descriptions such as group/search/thread references. This is insufficient for independent re-open/re-check.

For comment rows, referencing a parent evidence ID can be acceptable only if the parent row preserves a canonical permalink. TikTok mostly does this. Facebook currently does not.

**Required repair:** capture post/group permalink or canonical source reference for each Facebook parent source; child comment rows must carry `parent_evidence_id` plus the parent canonical URL. If a permalink cannot be recovered, mark `SOURCE_URL_NOT_CAPTURED` explicitly and record the recovery attempt.

**Severity:** CRITICAL.

### C3 — Raw observations and normalized/aggregated signals are conflated

Several rows combine multiple comments into one `raw_observation` (for example five-plus price questions, six-plus location questions, multiple quality comments). Semantic collapsing is useful for analysis, but it destroys the clean sequence:

`RAW OBSERVATION -> NORMALIZED SIGNAL -> AGGREGATION`

A row containing multiple comments is not a single raw observation.

**Required repair:** either:
1. keep each material raw comment as one raw row; or
2. explicitly mark aggregate rows and add `supporting_observation_count`, `aggregation_method`, `parent_evidence_id`, and representative excerpts, while preserving enough raw source references to re-audit the aggregation.

Do not use aggregated row counts as prevalence estimates.

**Severity:** HIGH.

### C4 — Saturation is overstated

Evidence supports **query-set saturation** in the executed TikTok and Instagram searches, not saturation of the Cochabamba social market.

Reasons:
- several required queries were not executed separately;
- Facebook remained seller-heavy and incompletely explored;
- VANSAM itself was not searched;
- coffee/frappé/chocolate coverage was thin;
- Google Maps/reviews and first-party sources were outside this pass.

Replace broad `SATURATION_OBSERVED` with structured statuses such as:

- `QUERY_SET_SATURATION_OBSERVED_TIKTOK`
- `QUERY_SET_SATURATION_OBSERVED_INSTAGRAM`
- `SELLER_CONTENT_DOMINANCE_OBSERVED_FACEBOOK`
- `MARKET_SATURATION_NOT_ESTABLISHED`

**Severity:** HIGH.

### C5 — Material-row accounting is ambiguous

The report states 115 total rows, 101 material, 12 rejected/out-of-scope, one explicit duplicate. The CSV also has 16 rows with evidence class `—`, including some contextual records and exclusions. The inclusion/exclusion rule is not machine-auditable.

**Required repair:** add:
- `row_status`: `MATERIAL`, `CONTEXT_ONLY`, `DUPLICATE`, `GEOGRAPHY_REJECTED`, `OUT_OF_SCOPE`, `UNRESOLVED`
- `exclusion_reason`

Then provide totals that sum exactly to 115.

**Severity:** HIGH.

### C6 — Freshness/date values are not normalized

`published_at` mixes ISO dates, ranges, approximate dates, `sin fecha`, and prose. `freshness` also mixes prose labels. This is workable for human review but poor for downstream computing.

**Required repair:** preserve raw date text but add normalized fields:
- `published_at_raw`
- `published_at_start`
- `published_at_end`
- `published_at_precision`
- `freshness_state`: `CURRENT_WINDOW`, `RECENT`, `STALE`, `EXPIRED`, `UNKNOWN`

Do not invent dates.

**Severity:** MEDIUM/HIGH.

### C7 — Bias fields must be explicit, not buried in notes

The report correctly discusses seller/influencer/algorithm/selection bias, but rows do not expose these as structured fields.

**Required repair:** structured booleans/enums with `UNKNOWN` allowed. Do not classify influencer content as paid unless paid collaboration is explicitly visible; otherwise use `PROMOTIONAL_OR_INFLUENCER_BIAS_POSSIBLE`.

**Severity:** MEDIUM.

### C8 — Some useful report-level claims remain hypotheses only

Examples:
- repeated location/hour/price questions may indicate information friction, but not measured lost conversion;
- recommendation mentions may indicate top-of-mind visibility, not market share;
- complaints about delay/cold product are public complaint signals, not verified operating performance rates;
- a reported app markup is unverified and cannot become a cost assumption.

The report generally handles these boundaries well. V1.1 should encode them per row in `CAN_PROVE` / `CANNOT_PROVE`.

## Accepted evidence directions — not business conclusions

The following survive the audit as **hypotheses/signals worth testing**, not as market facts:

1. Location, opening hours and contact information repeatedly appear as public information requests.
2. Price questions recur when seller content omits price.
3. Promotion rules and delivery applicability create clarification questions.
4. Public complaints exist around wait time and cold delivered product.
5. Pizza-style preference is heterogeneous; strong opposing comments exist.
6. Peer recommendation threads can surface competitor consideration sets but are contaminated by self-promotion and stale posts.
7. TikTok currently provides richer visible buyer-comment evidence than Instagram in this collection environment.

## Explicitly not accepted as decision-grade conclusions

Do not infer from V1:

- Cochabamba market share
- total demand
- conversion rate
- willingness-to-pay distribution
- competitor sales volume
- true complaint prevalence
- profitability of price points/promotions
- verified delivery performance
- verified food-safety defects
- causal impact of missing price/location/hour information
- representative consumer demographics

## Remediation strategy

Do **not** rerun the entire 118-action collection from zero.

Use the same Claude conversation and current browser context to execute `VANSAM_SOCIAL_EVIDENCE_REPAIR_V1_1`:

1. load existing report + ledger;
2. repair schema and provenance;
3. recover Facebook permalinks where possible;
4. distinguish raw vs aggregate observations;
5. reconcile all row counts;
6. normalize status/date/bias fields;
7. run only targeted missing queries and unresolved checks;
8. search VANSAM itself and the highest-signal competitors;
9. produce V1.1 files;
10. return for ChatGPT re-audit.

No market verdict. No production IQG ingestion yet.

## Gate

`VANSAM_SOCIAL_V1_NOT_READY_FOR_DECISION_GRADE_INGESTION`

Next acceptable state after successful repair:

`VANSAM_SOCIAL_V1_1_READY_FOR_CHATGPT_REAUDIT`
