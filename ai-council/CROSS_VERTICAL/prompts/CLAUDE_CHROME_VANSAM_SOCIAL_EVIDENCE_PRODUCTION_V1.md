# CLAUDE IN CHROME — VANSAM SOCIAL EVIDENCE PRODUCTION V1

**Date:** 2026-09-17  
**Project:** IQ GROWTH / IQHOLDING  
**Collector:** Claude in Chrome  
**Target:** VANSAM / Cochabamba  
**Mode:** read-only authenticated social research

## Verified capability precondition

The browser capability test already demonstrated authenticated read-only access to:
- Facebook search, public posts, comments, group search and Marketplace search;
- TikTok search, videos, comments, comment scrolling and profiles;
- Instagram search, posts/Reels, comments, comment scrolling and profiles.

No CAPTCHA, 2FA or browser blocker was encountered in the test.

## Mission

Execute real social evidence collection for VANSAM in Cochabamba. Do not return a research plan. Browse, open results, expand comments, follow public commercial profiles, search groups/pages/Marketplace, deduplicate and preserve provenance.

The purpose is not to produce a market verdict. The purpose is to build an auditable evidence corpus about what buyers and sellers are actually expressing.

## Read-only rules

Do not publish, comment, react, like, follow, send messages, contact sellers, modify profiles/settings, open Messenger/private chats, or collect unnecessary personal data.

Use only public content or content legitimately visible to the authenticated account. Do not cross-link private individuals across platforms.

## Truth ladder

`QUERY != OBSERVATION != SIGNAL != INTENT != QUOTE != ACCEPTANCE != PAYMENT != FULFILLMENT != PROFIT`

`POSTED_PRICE != PRICE_PAID`

`SELLER_STOCK_CLAIM != VERIFIED_STOCK`

`PUBLIC_PURCHASE_CLAIM != VERIFIED_PURCHASE`

`ENGAGEMENT != DEMAND`

## Geography

Primary geography: Cochabamba, Bolivia.

Reject or separately quarantine results from other countries/cities unless they are explicitly relevant as context. Do not silently mix Paraguay, Peru, Mexico, etc. with Cochabamba.

## Source priority

1. Facebook groups/pages/posts/comments visible to the authorized session.
2. TikTok videos/comments/profiles.
3. Instagram Reels/posts/comments/profiles.
4. Facebook Marketplace only when it contains relevant commercial evidence; do not force Marketplace when results are mainly equipment/accessories.

## Search expansion

Do not use only one query. Generate and execute variations around:

- pizza cochabamba
- pizzeria cochabamba
- pizza delivery cochabamba
- donde comer pizza cochabamba
- recomiendan pizza cochabamba
- mejor pizza cochabamba
- pizza familiar cochabamba
- pizza 2x1 cochabamba
- pizza promo cochabamba
- pizza precio cochabamba
- pizza delivery tarde cochabamba
- pizza fria cochabamba
- pizza quemada cochabamba
- mala atencion pizzeria cochabamba
- cuanto tarda pizza cochabamba
- hacen delivery pizza cochabamba
- pizza para llevar cochabamba
- pizza noche cochabamba

Also search buyer-language variants naturally encountered in comments/groups, including:
`precio`, `cuanto`, `donde queda`, `delivery`, `envian`, `tarda`, `recomiendan`, `muy caro`, `barato`, `quemado`, `frio`, `demora`, `mala atencion`, `quiero`, `tienen`, `hay`, `disponible`, `para llevar`.

## Evidence classes

Use only when supported:
- `OBSERVED_PUBLIC_OFFER`
- `SELLER_CLAIM`
- `PUBLIC_BUYER_SIGNAL`
- `PUBLIC_PURCHASE_CLAIM`
- `PUBLIC_COMPLAINT`
- `RECOMMENDATION_REQUEST`
- `PRICE_INQUIRY`
- `PRICE_RESISTANCE`
- `AVAILABILITY_REQUEST`
- `DELIVERY_REQUEST`
- `SERVICE_COMPLAINT`
- `QUALITY_COMPLAINT`
- `TRUST_CONCERN`
- `PRODUCT_REQUEST`

Never upgrade a public claim into verified purchase/payment/fulfillment.

## Row-level evidence contract

For every unique material observation record:

- `evidence_id`
- `platform`
- `source_url_or_reference`
- `source_business_or_account`
- `source_type`
- `published_at` if visible
- `observed_at`
- `city`
- `microzone` if supported
- `product_or_service`
- `variant_or_presentation` if supported
- `raw_observation` (brief, preserve meaning)
- `seller_price` if explicitly visible
- `currency`
- `stock_or_availability_claim` if any
- `delivery_claim_or_request` if any
- `signal_type`
- `evidence_class`
- `verification_state`
- `duplicate_group_id` if applicable
- `seller_generated_bias`
- `selection_bias`
- `algorithmic_visibility_bias`
- `freshness_state`
- `decision_relevance`
- `WHAT_THIS_CAN_PROVE`
- `WHAT_THIS_CANNOT_PROVE`
- `next_verification_action`

Do not force irrelevant fields.

## Buyer-side versus seller-side

Keep separate:

### Buyer-side
Questions, requests, recommendations, complaints, stated preferences, price objections, delivery requests, product requests.

### Seller-side
Menus, promotions, prices, stated delivery coverage, stated hours, product assortment, marketing claims.

Do not let seller-side volume masquerade as buyer demand.

## Deep comment excavation

When a post/video has substantial comments, do not read only the first screen. Scroll enough to detect whether new signal categories continue appearing. Expand comment threads when useful. Record unique evidence, not every redundant comment.

## Group research

Use legitimate group search/results visible to the account. Search relevant Cochabamba food/delivery/recommendation groups.

Extract commercial signals, not member identities. Do not export unnecessary names, photos, phone numbers or private profile details.

## Deduplication

Collapse duplicates when the same business/post/video/promotion is reposted or cross-posted. Use `duplicate_group_id`.

Do not treat a copied post across multiple groups as independent market evidence.

## Contradiction hunting

Actively search for contradictions such as:
- seller says delivery is fast vs comments reporting delays;
- seller says product is premium vs quality complaints;
- attractive promotion vs price objections;
- high engagement vs service complaints;
- repeated recommendation requests with conflicting answers.

Record both sides. Do not resolve the contradiction by intuition.

## Saturation rule

Continue query expansion and comment excavation until either:

`SATURATION_OBSERVED`: new searches are returning predominantly the same entities and signal categories with little incremental decision value;

or

`ACCESS_BLOCKED` / usage limit.

Do not stop after only a few examples just because you can already write a summary.

## Target depth

Aim for a useful corpus of roughly 40–80 unique material evidence rows if naturally available before saturation. This is a workload target, not a statistical sufficiency threshold. Quality and independence outrank quota.

If fewer are available, report the real count and why.

## No conclusions beyond evidence

Do not infer:
- VANSAM willingness-to-pay;
- VANSAM conversion;
- competitor sales volume;
- market share;
- population prevalence;
- profitability;
- demographic profile of customers;

unless actual evidence supports it. Public social evidence is primarily contextual/behavioral signal.

## Output

Maintain an incremental ledger while browsing so evidence is not reconstructed from memory at the end.

Return these sections:

1. `EXECUTION_SUMMARY`
2. `SEARCHES_EXECUTED`
3. `PLATFORMS_COVERED`
4. `ROW_LEVEL_EVIDENCE_LEDGER`
5. `BUYER_SIDE_SIGNALS`
6. `SELLER_SIDE_OFFER_LANDSCAPE`
7. `PRICE_AND_PROMOTION_OBSERVATIONS`
8. `DELIVERY_AND_SERVICE_SIGNALS`
9. `QUALITY_SIGNALS`
10. `RECOMMENDATION_AND_PRODUCT_REQUEST_SIGNALS`
11. `CONTRADICTIONS`
12. `DUPLICATES_COLLAPSED`
13. `GEOGRAPHY_FALSE_POSITIVES_REJECTED`
14. `PLATFORM_BIAS_AND_LIMITATIONS`
15. `EVIDENCE_GAPS`
16. `FIRST_PARTY_DATA_NEEDED_NEXT`
17. `SATURATION_STATUS`
18. `NEXT_COLLECTION_PASS`

For every material finding cite or reference the exact source row(s).

Final line exactly:

`VANSAM SOCIAL EVIDENCE PRODUCTION V1 READY FOR CHATGPT AUDIT`
