# GEMINI — EVIDENCE ACQUISITION MATRIX V1

Date: 2026-09-16
Project: IQ GROWTH / IQHOLDING
Role: Market Intelligence / External Evidence

## Mission
Your previous V2 correctly declared live social access limitations and produced 120 investigation tasks instead of fabricated observations. Do NOT repeat those searches as if they were evidence.

Convert that research backlog into an **executable evidence acquisition matrix** for human collectors, ChatGPT/web-accessible sources, first-party recovery and future authorized connectors.

Do not claim new live findings unless you actually have a source in this run.

## Required output

For every proposed investigation from the prior V2, classify and restructure it with these fields:
- business
- research_task_id
- exact research question
- decision it could change
- expected evidence type
- preferred source class
- platform/source family
- access state
- collector type: CHATGPT_WEB / HUMAN_PUBLIC / HUMAN_AUTHENTICATED / FIRST_PARTY_OWNER / API_AUTHORIZED / LICENSED / FIELD_OBSERVATION
- exact fields to capture
- freshness requirement
- verification method
- duplicate risk
- seller-generated bias risk
- privacy risk
- cost/friction
- fallback source if primary fails
- stop condition
- evidence value: P0/P1/P2 only as qualitative priority, not a numeric score
- reject/defer if the task is only a weak proxy

## Hard rules

`QUERY != OBSERVATION`
`OBSERVATION != SIGNAL`
`SIGNAL != DEMAND`
`DEMAND != PURCHASE`
`PURCHASE != PROFIT`

No source URL/reference + no observed content = no observation.

Do not use private third-party messages, bypass controls, infer sensitive traits, or cross-link ordinary people's identities across platforms without authorization.

## Priority doctrine

Prefer in this order when decision-relevant:
1. first-party transaction/payment/quote/order evidence;
2. direct public buyer request or complaint;
3. verified current seller offer with price/stock/warranty/fulfillment;
4. primary/official source;
5. corroborated public social evidence;
6. indirect trend/proxy evidence.

Weak proxies should be explicitly demoted or rejected.

## Re-rank the V2 backlog

For each business, identify:
- top 10 P0 acquisition tasks
- next 10 P1 tasks
- P2/defer/reject tasks

Explain WHY each P0 can change an actual decision.

## Acquisition packets

Produce four field-ready packets:
- VANSAM_EVIDENCE_PACKET
- CAFE_ZACARIAS_EVIDENCE_PACKET
- CHOCOLATES_EVIDENCE_PACKET
- IPCENTER_EVIDENCE_PACKET

Each packet must contain the smallest row schema a collector can fill from a phone without losing provenance.

## Coverage map

Return a matrix of what can realistically be collected by:
- ChatGPT public web
- human public browser/social session
- authorized first-party WhatsApp/POS/CRM
- field observation
- API/connector if later available

Do not mark a surface accessible unless your environment actually supports it.

## Stop wasting effort

Identify at least 25 searches from the old backlog that are weak, redundant, too broad, or unable to change a decision. Replace them only if you have a more decision-relevant task.

## Final output

Return:
- `P0_ACQUISITION_QUEUE`
- `P1_ACQUISITION_QUEUE`
- `DEFER_OR_REJECT_QUEUE`
- `HUMAN_CAPTURE_PACKETS`
- `CHATGPT_WEB_QUEUE`
- `FIRST_PARTY_RECOVERY_QUEUE`
- `ACCESS_GAPS`
- `DATA_QUALITY_CHECKS`

Do not deliver market conclusions from tasks that have not been executed.

Final line exactly:
`EVIDENCE ACQUISITION MATRIX READY FOR CHATGPT AUDIT`