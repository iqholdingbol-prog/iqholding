# CLAUDE — VANSAM SOCIAL EVIDENCE NORMALIZATION V1.2

MODE: DATA-ONLY REMEDIATION

Use the existing:
- `VANSAM_social_evidence_ledger_v1_1.csv`
- `VANSAM_social_evidence_report_v1_1.md`

Do **not** run another broad browser crawl.
Do **not** discard or overwrite V1/V1.1.
Do **not** add new market conclusions.
Do **not** contact businesses.

Objective: make the existing corpus safe for machine ingestion without changing what the evidence actually says.

## Gate from ChatGPT reaudit

`EVIDENCE_CORPUS_PASS / ANALYTICS_DATASET_FAIL_PENDING_SMALL_SCHEMA_NORMALIZATION`

## 1. Preserve all rows

Start from all 246 V1.1 rows.
No row may silently disappear.
Keep the original `evidence_id` stable.

Create:
- `VANSAM_social_evidence_ledger_v1_2.csv`
- `VANSAM_social_evidence_report_v1_2.md`

## 2. Fix duplicate semantics

Current `duplicate_group_id` mixes true duplicates, business/entity clusters and topic clusters.

Required model:

`duplicate_group_id`
- only same underlying content/event or true repost/cross-post.
- use `NOT_APPLICABLE` when not a true duplicate set.

Add:
- `entity_cluster_id`
- `topic_cluster_id`

Examples that must **not** remain duplicate groups merely because they share topic/entity:
- DG-LOC
- DG-PRICE-INQ
- DG-BRICKS
- DG-PORTANUOVA
- DG-CASASABOR

Retain true cross-post/repost duplicate groups only when the underlying content is actually the same.

Do not infer identity between ordinary people across platforms.

## 3. Separate raw observation from signal

Add:
- `raw_observation_id`
- `raw_observation_scope`

A raw atomic source item is one identifiable post/video/comment/reply/offer observation.
One raw observation may map to multiple signal rows.

If the exact atomic comment identity cannot be reconstructed from V1.1:
- use a deterministic source-local synthetic ID;
- mark `raw_observation_scope = AGGREGATED_WITHIN_SOURCE` when the existing row contains multiple comments and atomic identity is unavailable;
- never pretend it is an individual comment ID.

Do not claim the existing sum of `supporting_observation_count` is a count of unique comments or unique people.

In the report rename the 444 interpretation to:
`SUPPORTING_SIGNAL_OCCURRENCES_SUM`

and explicitly state:
`UNIQUE_RAW_OBSERVATION_COUNT_NOT_ESTABLISHED`
unless the mapping actually proves it.

## 4. Normalize signal code

Current free-text `signal_type` is not canonical.

Add:
- `signal_type_code`
- `signal_detail`

`signal_type_code` must be a controlled enum aligned to the evidence taxonomy, preferably the existing normalized `evidence_class` where appropriate.

Do not use compound codes such as:
`PRICE_INQUIRY + AVAILABILITY_REQUEST`.

If one raw observation contains two materially distinct signals, represent them as separate signal rows referencing the same `raw_observation_id`.

Preserve the old `signal_type` column for lineage, but mark it `legacy_free_text` in the report and prohibit analytics on it.

## 5. Normalize seller vs promotional bias

Canonical `seller_generated_bias` enum:
- YES
- NO
- POSSIBLE
- UNKNOWN
- NOT_APPLICABLE

Add:
`promotion_bias_state`:
- NONE
- POSSIBLE
- EXPLICIT_PLATFORM_LABEL
- UNKNOWN
- NOT_APPLICABLE

Add:
`promotion_bias_detail`

Examples:
- explicit “Colaboración pagada” => EXPLICIT_PLATFORM_LABEL
- explicit “Contenido promocional” => EXPLICIT_PLATFORM_LABEL
- suspected creator promotion without label => POSSIBLE

Do not call content paid without explicit evidence.

## 6. Make URL machine-pure

Add:
- `source_url`
- `source_reference_note`

`source_url` must contain only a URL or:
- SOURCE_URL_NOT_CAPTURED
- NOT_APPLICABLE

Move prose like:
`(comentarios del padre TT-001)`
into `source_reference_note`.

Keep `parent_evidence_id` separately.

Do not invent URLs.

## 7. Freshness is policy, not evidence

Preserve:
- published_at_raw
- published_at_start
- published_at_end
- published_at_precision
- observed_at

Add:
`freshness_policy_version = IQG_COLLECTOR_FRESHNESS_V1`

Document the policy explicitly if retaining:
- CURRENT_WINDOW <= 30 days
- RECENT 31 days to 6 months
- STALE > 6 months
- EXPIRED only when an expiry/end condition is actually evidenced
- UNKNOWN when publication timing cannot support a bucket

Recompute `freshness_state` deterministically and consistently.

Search snapshots/profile checks are collection metadata, not necessarily market-content publication dates. Do not force them into content freshness semantics if NOT_APPLICABLE is more correct.

## 8. Decision relevance is not evidence

Current HIGH/MEDIUM/LOW has no approved decision rubric.

Rename/copy to:
`collector_relevance_heuristic`

Add:
`collector_relevance_rule_version = UNVERSIONED_LEGACY_V1_1`

Add:
`canonical_decision_relevance = NOT_ESTABLISHED`

Do not use the heuristic as a decision gate.

Do not invent a scoring rubric in this pass.

## 9. Correct interpretation language

VANSAM:
Use only:
`NO_PUBLIC_BUYER_CONVERSATION_FOUND_IN_EXECUTED_QUERIES`

Never:
`VANSAM has no public customer conversation`.

Porta Nuova:
Use:
`MENTIONED_OR_RECOMMENDED_IN_5_EVIDENCE_CONTEXTS`

Do not claim five independent people/sources because identity independence was not demonstrated.

Instagram material count:
Canonical V1.1 file count = 10 MATERIAL rows.

## 10. Preserve proof boundaries

Every MATERIAL row must retain:
- WHAT_THIS_CAN_PROVE
- WHAT_THIS_CANNOT_PROVE
- next_verification_action

No public claim may become:
- VERIFIED_PURCHASE
- PAYMENT_VERIFIED
- FULFILLMENT_VERIFIED
- REPEAT_PURCHASE_VERIFIED
unless new first-party evidence exists. This pass has no such new evidence.

## 11. Validation before finish

Report exact checks:
- row count remains 246 unless extra signal rows are strictly necessary to normalize a compound signal; if row count changes, reconcile OLD -> NEW exactly;
- original evidence_id lineage preserved;
- no blank canonical fields;
- duplicate_group_id contains only true duplicate sets;
- signal_type_code controlled enum only;
- seller_generated_bias controlled enum only;
- source_url contains pure URL/sentinel only;
- freshness policy deterministic;
- no unversioned decision gate;
- no unique-comment/person claim from support counts;
- no market prevalence claim.

## 12. Output

Return:
1. NORMALIZATION_SUMMARY
2. ROW_RECONCILIATION
3. DUPLICATE_VS_CLUSTER_REMEDIATION
4. RAW_OBSERVATION_MAPPING
5. SIGNAL_CODE_NORMALIZATION
6. BIAS_NORMALIZATION
7. URL_NORMALIZATION
8. FRESHNESS_RECOMPUTATION
9. RELEVANCE_DOWNGRADE
10. INTERPRETATION_CORRECTIONS
11. VALIDATION_RESULTS
12. REMAINING_LIMITATIONS
13. FILES_CREATED
14. FINAL_GATE

Final gate must be one of:
- `VANSAM_SOCIAL_EVIDENCE_V1_2_READY_FOR_CHATGPT_REAUDIT`
- `VANSAM_SOCIAL_EVIDENCE_V1_2_BLOCKED`

Do not browse unless a source cannot be normalized without revisiting it; if browsing is necessary, state the exact row and reason before using it.
