# ChatGPT Re-audit — Claude in Chrome VANSAM Social Evidence V1.1

Date: 2026-09-17
Scope: `VANSAM_social_evidence_report_v1_1.md` + `VANSAM_social_evidence_ledger_v1_1.csv`

## Gate

**EVIDENCE_CORPUS_PASS / ANALYTICS_DATASET_FAIL_PENDING_SMALL_SCHEMA_NORMALIZATION**

The browser collection itself is accepted as a real read-only evidence-gathering execution. The corpus is useful for qualitative evidence review, source revisit and hypothesis generation. It is **not yet approved as a canonical analytics/decision dataset** because several data semantics remain unsafe for downstream aggregation.

No new broad VANSAM crawl is required. The next step is a small data-only normalization pass over the existing 246-row corpus.

## Verified structural facts

- CSV has exactly 246 rows and 39 columns.
- No empty cells.
- `evidence_id` is unique across all 246 rows.
- Row status totals reconcile exactly: MATERIAL 179, CONTEXT_ONLY 41, DUPLICATE 2, GEOGRAPHY_REJECTED 8, OUT_OF_SCOPE 10, UNRESOLVED 6.
- Origins reconcile: 115 preserved V1 rows + 30 split rows + 101 targeted-collection rows = 246.
- Material rows by platform reconcile: TikTok 143, Facebook 26, Instagram 10.
- Material evidence-class totals reconcile to 179.
- All 140 `comment` rows have a non-empty `parent_evidence_id`; every referenced parent exists in the ledger; every comment source reference begins with a URL.
- Every MATERIAL row has populated `WHAT_THIS_CAN_PROVE`, `WHAT_THIS_CANNOT_PROVE`, and `next_verification_action`.
- Provenance repair materially improved Facebook reproducibility; unresolved missing URLs are quarantined rather than promoted to material evidence.
- No verified-payment, verified-fulfillment or repeat-purchase claim was introduced.

## What V1.1 fixed correctly

1. Preserved V1 rather than overwriting it.
2. Reconciled all rows explicitly.
3. Added parent-child provenance.
4. Recovered canonical/permalink Facebook sources where possible.
5. Separated materially different signals that had been collapsed into single rows.
6. Downgraded unsupported claims that promotional/influencer content was paid.
7. Corrected the 2022 Facebook date.
8. Correctly changed market-wide saturation to query-set saturation.
9. Added explicit proof boundaries per material row.
10. Preserved `NOT_FOUND != NO_DATA_EXISTS` and `PUBLIC_CLAIM != VERIFIED_SALE` semantics.

## Remaining findings

### P1 — `duplicate_group_id` is not actually a duplicate key

The field is used for at least three different concepts:
1. true duplicate/cross-post identity,
2. business/entity clustering,
3. topical/signal clustering.

Examples observed directly in the ledger:
- `DG-LOC` groups unrelated location/availability observations across different businesses and sources.
- `DG-PRICE-INQ` groups unrelated price, location and delivery signals.
- `DG-BRICKS`, `DG-PORTANUOVA`, `DG-CASASABOR` cluster many distinct observations about one business.

If downstream code collapses rows by `duplicate_group_id`, it will destroy valid independent evidence.

Required remediation:
- reserve `duplicate_group_id` strictly for the same underlying content/event or true repost/cross-post;
- move business/topic grouping into separate fields such as `entity_cluster_id` and/or `topic_cluster_id`.

### P1 — RAW OBSERVATION and SIGNAL are not fully separated

The 179 material rows are signal records. Some source comments/posts can generate more than one signal row, while other rows semantically collapse several comments.

The sum of `supporting_observation_count` across MATERIAL rows is 444, but without a stable atomic `raw_observation_id`, this cannot safely be interpreted as 444 unique raw comments/posts. A single source comment can support more than one signal after semantic splitting.

Required remediation:
- introduce `raw_observation_id` or another deterministic atomic source-item key;
- allow one raw observation to map to N signal rows;
- treat the current 444 as support-occurrence metadata, not unique-comment count, unique-person count or prevalence;
- never use it for market prevalence.

### P1 — `signal_type` is not normalized

The column has more than one hundred distinct free-text forms, including compound values such as `PRICE_INQUIRY + AVAILABILITY_REQUEST`, explanatory suffixes and product-specific prose.

`evidence_class` is already much cleaner and is the safer normalized analytical code.

Required remediation:
- make `evidence_class` the canonical signal code, or add a strict `signal_type_code` enum;
- move descriptive nuance into `signal_detail` / notes;
- do not aggregate directly on the current free-text `signal_type`.

### P1 — `decision_relevance` has no canonical rubric

The ledger assigns HIGH/MEDIUM/LOW, but no deterministic scoring rubric/version is defined in the collector contract.

This is model judgment, not evidence.

Required remediation:
- either remove it from the evidence truth layer; or
- rename to `collector_relevance_heuristic` and explicitly exclude it from canonical decision logic; or
- introduce a versioned deterministic rubric and recompute.

### P1 — `freshness_state` is partly policy and partly inconsistent

The report defines:
- CURRENT_WINDOW = 30 days or less
- RECENT = 31 days to 6 months
- STALE = more than 6 months
- EXPIRED = declared promotion already expired

Those thresholds are collector policy, not market fact, and the ledger contains rows that do not consistently follow the stated deterministic rule.

Required remediation:
- preserve normalized publication dates as evidence;
- add `freshness_policy_version` if bucket labels are retained;
- recompute deterministically from dates under that policy;
- preserve EXPIRED only when expiry is actually evidenced;
- downstream logic must be able to recalculate freshness under another policy.

### P2 — `seller_generated_bias` mixes multiple dimensions

Observed values include:
- YES
- NO
- POSSIBLE
- UNKNOWN
- NOT_APPLICABLE
- PROMOTIONAL_OR_INFLUENCER_BIAS_POSSIBLE
- YES (propio)
- explicit paid/promotional platform-label values

The useful information should be separated:
- `seller_generated_bias`: YES / NO / POSSIBLE / UNKNOWN / NOT_APPLICABLE
- `promotion_bias_state`: NONE / POSSIBLE / EXPLICIT_PLATFORM_LABEL / UNKNOWN
- preserve observed platform label in a detail field.

### P2 — source URL field is human-auditable but not machine-pure

Many comment rows append prose such as `(comentarios del padre TT-001)` to the URL. Human provenance remains usable, but canonical ingestion should separate:
- `source_url` = pure canonical URL;
- `source_reference_note` = parent/reference prose;
- `parent_evidence_id` remains independent.

### P2 — user-facing summary overstates VANSAM absence

Strongest supported wording:

`NO_PUBLIC_BUYER_CONVERSATION_FOUND_IN_EXECUTED_QUERIES`

Do not promote this to an absolute claim that VANSAM has no public customer conversation on the three platforms. Not-found is query/session/platform scoped.

### P2 — Porta Nuova “independent sources” is not demonstrated

The corpus supports that Porta Nuova is recommended/mentioned in five evidence rows/source contexts. It does not prove five independent people or independent sources because commenter identities are intentionally not retained or cross-platform linked.

Use:
`MENTIONED_OR_RECOMMENDED_IN_5_EVIDENCE_CONTEXTS`

Do not use:
`5 independent sources`
unless independence is separately demonstrated.

### P2 — Instagram material count mismatch in pasted summary

Canonical CSV/report reconcile to **10 MATERIAL Instagram rows**. A pasted summary saying 9 is a transcription mismatch; the file is authoritative.

## Accepted evidence posture

After the normalization patch, V1.1 may be ingested as **EXTERNAL_EVIDENCE / PUBLIC_UNVERIFIED** and **SELLER_CLAIM_UNVERIFIED**, preserving source/date/geography/bias/proof boundaries.

It must not support claims of:
- verified purchase,
- verified delivery,
- verified repeat purchase,
- market prevalence,
- market share,
- willingness-to-pay,
- competitor sales volume,
- profitability,
- global absence of VANSAM mentions.

## Approved use now

- qualitative evidence review;
- source revisit;
- contradiction hunting;
- hypothesis generation;
- collector-method validation;
- designing first-party questions for VANSAM.

## Not approved yet

- prevalence estimates;
- frequency ranking from raw row counts;
- demand estimation;
- automated duplicate collapse using current `duplicate_group_id`;
- automated decision gates using current `decision_relevance`;
- canonical Market Intelligence training/aggregation.

## Required next action

Do **not** run another broad VANSAM crawl.

Apply a small V1.2 data-only normalization pass to the existing corpus:
1. fix duplicate-vs-cluster semantics;
2. introduce atomic raw-observation identity/mapping;
3. normalize signal code;
4. version/recompute freshness policy;
5. remove/version decision-relevance heuristic;
6. split seller-generated vs promotional bias;
7. make source URL machine-pure;
8. preserve every existing row and provenance;
9. no new market conclusions.

Only after this normalization should the collector contract be reused for IPCENTER national public research and the separate authorized first-party WhatsApp/ManyChat/contact-recovery lane.

No production Market Intelligence coding before the IQG-001.2 Core gate is closed.
