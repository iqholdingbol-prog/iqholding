# ChatGPT Re-audit — Claude in Chrome VANSAM Social Evidence V1.1

Date: 2026-09-17
Scope: `VANSAM_social_evidence_report_v1_1.md` + `VANSAM_social_evidence_ledger_v1_1.csv`

## Gate

**V1_1_CONTRACT_PASS / DECISION_GRADE_PENDING_SMALL_DATA_NORMALIZATION**

The collector materially improved over V1. The corpus is usable as external evidence after a small non-browser normalization patch. No new broad crawl is required before proceeding to the next vertical.

## Verified structural facts

- CSV has exactly 246 rows and 39 columns.
- No empty cells.
- Row status totals reconcile exactly: MATERIAL 179, CONTEXT_ONLY 41, DUPLICATE 2, GEOGRAPHY_REJECTED 8, OUT_OF_SCOPE 10, UNRESOLVED 6.
- Origins reconcile: 115 preserved V1 rows + 30 split rows + 101 targeted-collection rows = 246.
- `evidence_id` is unique across all 246 rows.
- All 140 rows whose `source_type` contains `comment` have a non-empty `parent_evidence_id`, and every referenced parent exists in the same ledger.
- Material rows by platform reconcile: TikTok 143, Facebook 26, Instagram 10.
- Material evidence-class totals reconcile to 179.
- Sum of `supporting_observation_count` across material rows = 444. This is support-count metadata, not prevalence and not necessarily a count of unique people.
- Every MATERIAL row has populated `WHAT_THIS_CAN_PROVE`, `WHAT_THIS_CANNOT_PROVE`, and `next_verification_action`.
- No MATERIAL row uses `SOURCE_URL_NOT_CAPTURED` as source reference.
- Provenance repair materially improved Facebook reproducibility; unresolved missing URLs are quarantined rather than promoted to material evidence.

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

### P1 — `freshness_state` is not internally consistent with the report's own rule

The report defines:
- CURRENT_WINDOW = 30 days or less
- RECENT = 31 days to 6 months
- STALE = more than 6 months
- EXPIRED = declared promotion already expired

However, at least 21 rows do not follow that deterministic rule. Examples include several August 2026 rows classified RECENT even though they are within 30 days of observed_at=2026-09-17, `FB-010` classified RECENT despite end date 2026-09-16, and `TT-057-B` classified STALE with end date 2026-06-13 (~96 days).

This is a data-normalization defect, not a browser-evidence defect. Fix deterministically from normalized date fields, preserving EXPIRED and legitimate UNKNOWN cases.

### P1 — `decision_relevance` has no canonical rubric

The ledger assigns HIGH/MEDIUM/LOW to all rows, but no deterministic scoring/rubric is defined in the report or contract. These labels must not enter decision logic as decision-grade data.

Action: either add a documented deterministic rubric and recompute, or rename/downgrade the field to `collector_relevance_heuristic` and exclude it from canonical decision logic.

### P2 — `seller_generated_bias` is not a single controlled enum

Observed values include:
- YES
- NO
- POSSIBLE
- UNKNOWN
- NOT_APPLICABLE
- PROMOTIONAL_OR_INFLUENCER_BIAS_POSSIBLE
- YES (propio)
- YES_EXPLICIT_LABEL (Colaboración pagada)
- YES_EXPLICIT_LABEL (Contenido promocional)

For machine ingestion, normalize the canonical field to a controlled enum and place the evidentiary detail (explicit paid/promotional platform label, own-account content, influencer suspicion) in a separate note/qualifier field or `notes`.

### P2 — user-facing summary overstates VANSAM absence

The strongest supported statement is:

> No public buyer conversation about VANSAM was found in the executed queries.

Do not promote this to:

> VANSAM has no public customer conversation on the three platforms.

Absence in the queried/visible corpus is not proof of global absence.

### P2 — support count must not be read as unique observations/users

The report states 444 comments/posts support the 179 material rows. Because rows can represent semantic splits and source-level aggregation, this number must be treated as `supporting_observation_count` sum, not unique people, unique comments globally, prevalence, or market share.

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

## Next action

Do **not** run another broad VANSAM crawl now. Apply a data-only V1.1 normalization patch with no browsing except if needed to resolve an already-known provenance gap. Then freeze the VANSAM collector contract as the template for the next vertical.

Next vertical after patch: IPCENTER, with two distinct evidence lanes kept separate:
1. nationwide public-market evidence,
2. authorized first-party WhatsApp/ManyChat/contact recovery.

No production Market Intelligence coding before the IQG-001.2 Core gate is closed.
