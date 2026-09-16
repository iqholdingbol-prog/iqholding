# DEEPSEEK — MARKET MEMORY & DATA INTEGRITY RED TEAM V1

Date: 2026-09-16
Role: Red Team / Security / Data Integrity
Scope: IQ GROWTH universal Market Intelligence / Market Memory across four laboratories

## Mission

Try to break the proposed universal market-intelligence and Market Memory model BEFORE it is automated.

You are not asked to make it look safe. You are asked to find how it can become confidently wrong, manipulable, privacy-invasive, economically destructive, or contaminated across businesses.

Target laboratories:
- VANSAM
- Café Zacarías
- Chocolates (brand pending)
- IPCENTER

Core hypothesis under attack:

`SOURCE → RAW EVIDENCE → PROVENANCE → NORMALIZATION → SIGNAL → CORROBORATION → HYPOTHESIS → ACTION → REAL RESULT → LEARNING → MARKET MEMORY`

## Required repository reading

If repo access exists, read:
- `docs/IQG_UNIVERSAL_MARKET_INTELLIGENCE_DATA_MODEL_V1.md`
- `docs/IQG_INFORMATION_ADVANTAGE_DOCTRINE_V1.md`
- `ai-council/AI_COUNCIL_QUALITY_GATE_V1.md`
- `docs/CEO_CORRECTIONS_2026-09-15.md`
- `ai-council/IQG-005/reports/2026-09-16_cross_ai_synthesis_ipcenter_buyability_intelligence_v1.md`
- latest relevant VANSAM baseline/synthesis

If unavailable, say so. Never fabricate access.

## Non-negotiable doctrine

- `SIGNAL != FACT != SALE != PROFIT`.
- no individual wealth profiling from social appearance/geography;
- no unauthorized private data;
- no cross-platform dossiers for ordinary people;
- first-party data must remain tenant/company isolated;
- one business must not contaminate another;
- inferences must never silently harden into facts;
- stale evidence must not drive fresh decisions without explicit freshness semantics;
- no arbitrary risk scores/thresholds disguised as science.

## Attack program

### A. 50+ signal corruption attacks

Attack sources such as:
- Facebook
- TikTok
- Instagram
- WhatsApp first-party
- public WhatsApp catalogs
- Marketplace
- reviews
- delivery apps
- POS
- CRM
- quotes
- sales
- payments
- human field capture

Include:
- bots
- seller spam
- affiliate content
- giveaways
- duplicate reposts
- fake reviews
- competitor sabotage
- sarcasm
- old posts
- missing context
- viral entertainment
- reseller behavior
- creator/influencer bias
- platform algorithm bias
- city bias
- demographic sampling bias
- silent buyers
- B2B hidden demand
- promotion-driven distortions
- fake scarcity
- price bait
- stock bait
- unit/variant confusion

Format:
`ATTACK → CORRUPTED INFERENCE → DETECTION → MITIGATION → RESIDUAL RISK`

### B. 25+ Market Memory poisoning cases

Show how a wrong signal can become a persistent false belief.

Examples:
- seasonal chocolate gift demand stored as permanent baseline;
- one pizza promotion stored as taste preference;
- one viral coffee post treated as city demand;
- laptop out-of-stock treated as structural shortage;
- repeated seller posts mistaken for independent demand.

For each case:
`POISON INPUT → HOW IT ENTERS → HOW IT PROPAGATES → BUSINESS DAMAGE → REQUIRED DEFENSE`

### C. Causal attribution attacks

At least 20 ways IQ GROWTH could falsely claim an action caused a result.

Attack:
- seasonality
- payday effects
- competitor closure
- weather
- road blocks
- ad overlap
- price changes
- inventory changes
- staffing changes
- organic virality
- repeat buyers
- simultaneous campaigns

Define minimum evidence needed before writing a causal conclusion to Decision Memory.

### D. Cross-vertical contamination

Attempt to prove that a universal schema can create false equivalence.

Examples:
- restaurant “availability” vs laptop stock;
- coffee repeat cadence vs pizza repeat cadence;
- gift occasion vs technical urgency;
- price resistance across fundamentally different purchase frequencies.

Find at least 25 semantic collisions and propose the invariant or adapter boundary that prevents them.

### E. Entity resolution red team

Attack business/product/location/entity matching.

Include:
- same business with multiple names/pages;
- old/closed branches;
- duplicate seller pages;
- aliases;
- same SKU name with different specs;
- menu alias history;
- same coffee product under different packaging;
- chocolate seasonal packaging;
- exact laptop/phone variant issues.

Do NOT design person-level cross-platform identity resolution for ordinary users.

### F. Freshness and temporal integrity

Design separate semantics for:
- observed_at
- effective_at
- valid_from/valid_to where relevant
- freshness state
- verification state
- source update time
- transaction time

Attack what happens when they are conflated.

No arbitrary hour/day cutoffs unless labeled TO_CALIBRATE.

### G. Economic failure

At least 25 ways the system could increase activity while destroying profit.

Include:
- discounting to chase conversion
- low-margin viral SKU
- delivery cost
- support burden
- waste
- returns
- warranty
- paid content cost
- quote labor
- fulfillment complexity
- working capital
- stock aging
- cross-subsidy between businesses

Define the data needed to distinguish growth from margin-negative volume.

### H. Privacy/security/compliance boundaries

Draw strict lines for:
- public evidence
- public authenticated evidence
- first-party customer data
- consented private data
- employee field capture
- licensed provider data
- private unauthorized data

Attack:
- accidental leakage between IQHOLDING companies;
- exposing customer contact data to external models;
- storing raw chats forever;
- model outputs reproducing PII;
- exporting customer data into a shared market dataset;
- inference of sensitive traits.

Where legal interpretation is required, mark `LEGAL_REVIEW_REQUIRED` rather than invent law.

### I. Feedback-loop attacks

At least 20 self-reinforcing failures, e.g.:
`system recommends Hawaiian pizza → business promotes it more → it gets more sales → system concludes preference increased`.

Find equivalent loops in coffee, chocolate and technology.

### J. Adversarial test matrix

Create at least 40 test cases the future implementation must pass.

Fields:
- ID
- input/evidence
- expected classification
- prohibited conclusion
- expected system action
- audit requirement

### K. Kill criteria

Define conditions under which ChatGPT should stop an automated decision and require human review.

Use risk/evidence semantics, not arbitrary scores.

## Required output

A. Red-team verdict
B. 50+ signal attacks
C. 25+ Market Memory poisoning attacks
D. 20+ causal attribution attacks
E. 25+ semantic collisions
F. Entity-resolution attacks
G. Temporal/freshness integrity model
H. 25+ economic failures
I. Privacy/security boundaries
J. 20+ feedback loops
K. 40+ adversarial tests
L. Kill criteria
M. Claims to reject/downgrade now
N. Top 20 controls that must exist before automation

Final exact line:

`MARKET MEMORY DATA INTEGRITY RED TEAM READY FOR CHATGPT AUDIT`
