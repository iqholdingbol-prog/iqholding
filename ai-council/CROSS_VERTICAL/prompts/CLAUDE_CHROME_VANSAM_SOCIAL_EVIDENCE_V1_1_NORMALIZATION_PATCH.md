# CLAUDE IN CHROME — VANSAM SOCIAL EVIDENCE V1.1 NORMALIZATION PATCH

This is a DATA-ONLY PATCH.

Do not perform a broad crawl.
Do not redo the 119 browser actions.
Do not overwrite V1 or V1.1.
Do not contact any business.
Do not change substantive raw observations unless a contradiction is demonstrated by the existing source material.

Inputs already created:
- VANSAM_social_evidence_ledger_v1_1.csv
- VANSAM_social_evidence_report_v1_1.md

Create:
- VANSAM_social_evidence_ledger_v1_1a.csv
- VANSAM_social_evidence_report_v1_1a.md

## 1. Freshness normalization

Use observed_at as the reference date.

Canonical deterministic rule:
- EXPIRED: preserve when a promotion has a declared end and is already expired.
- UNKNOWN: preserve only where publication timing is genuinely insufficient for classification.
- CURRENT_WINDOW: normalized publication end date is <= 30 days before observed_at.
- RECENT: >30 days and <=183 days before observed_at.
- STALE: >183 days before observed_at.

Recompute `freshness_state` from normalized date fields for every row not overridden by EXPIRED or legitimate UNKNOWN.

Return a change ledger:
`evidence_id | old_freshness | new_freshness | reason`.

Do not change published_at_raw/start/end merely to fit freshness.

## 2. Decision relevance

`decision_relevance=HIGH/MEDIUM/LOW` has no approved canonical rubric.

Do not allow it to masquerade as decision-grade data.

Choose the minimal compatible fix:
- preserve the column for backwards compatibility,
- set every value to `COLLECTOR_HEURISTIC_NOT_CANONICAL`,
- preserve the previous HIGH/MEDIUM/LOW value in `notes` as `legacy_collector_relevance=<value>`.

Do not invent a scoring rubric in this patch.

## 3. seller_generated_bias enum

Normalize `seller_generated_bias` to exactly one of:
- YES
- NO
- POSSIBLE
- UNKNOWN
- NOT_APPLICABLE

Mappings:
- `YES (propio)` -> YES
- `YES_EXPLICIT_LABEL (Colaboración pagada)` -> YES
- `YES_EXPLICIT_LABEL (Contenido promocional)` -> YES
- `PROMOTIONAL_OR_INFLUENCER_BIAS_POSSIBLE` -> POSSIBLE

Preserve the evidentiary qualifier in `notes`:
- own-account content
- explicit platform label: paid collaboration
- explicit platform label: promotional content
- promotional/influencer bias possible

Do not call content paid unless the explicit platform label proves it.

## 4. VANSAM absence wording

Canonical statement:

`No public buyer conversation about VANSAM was found in the executed queries.`

Never state:

`VANSAM has no public customer conversation on Facebook/TikTok/Instagram.`

Preserve:
`NOT_FOUND != NO_DATA_EXISTS`.

## 5. Support count wording

The sum of `supporting_observation_count` may be reported as:

`sum of row-level supporting-observation counts`

It must NOT be described as:
- unique people,
- unique customers,
- unique comments globally,
- prevalence,
- market share,
- demand volume.

## 6. Integrity checks

Before saving V1.1a verify:
- exactly 246 rows
- exactly 39 columns unless a schema change is explicitly necessary (prefer no schema change)
- 179 MATERIAL
- 41 CONTEXT_ONLY
- 2 DUPLICATE
- 8 GEOGRAPHY_REJECTED
- 10 OUT_OF_SCOPE
- 6 UNRESOLVED
- unique evidence_id
- no empty cells
- all comment parent_evidence_id values resolve to an evidence_id in the ledger
- all MATERIAL rows retain proof boundaries and source reference
- no MATERIAL row becomes VERIFIED sale/payment/fulfillment/repeat purchase
- no source/provenance is silently removed

## 7. Output

Return:
1. PATCH_SUMMARY
2. FRESHNESS_CHANGES
3. DECISION_RELEVANCE_NORMALIZATION
4. SELLER_BIAS_NORMALIZATION
5. INTEGRITY_CHECKS
6. FILES_CREATED
7. FINAL_GATE

Final exact line:

`VANSAM SOCIAL EVIDENCE V1.1A READY FOR CHATGPT FINAL GATE`

Execute now using the existing files. Browser navigation is not required unless an existing file cannot be read.