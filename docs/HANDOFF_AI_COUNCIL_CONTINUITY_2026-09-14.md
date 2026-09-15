# IQ GROWTH — AI Council Continuity Handoff 2026-09-14

**Updated:** 2026-09-15
**Purpose:** preserve the active technical/product workstream across a new ChatGPT conversation so Codex, Claude, DeepSeek, Gemini and ChatGPT continue from the correct checkpoint rather than restarting.

## Canonical sources to load
1. `docs/MASTER_CONTEXT.md`
2. `docs/CEO_CONFIRMED_BUSINESS_FACTS.md`
3. `docs/CEO_CORRECTIONS_2026-09-15.md`
4. `docs/CURRENT_STATE.md`
5. `docs/EXECUTION_STATE.md`
6. `docs/BACKLOG.md`
7. `docs/HANDOFF_NEW_CHAT_2026-09-14.md`
8. `AI_TEAM_PROTOCOL.md`
9. `AI_TEAM_PROTOCOL_ADDENDUM_DOLA.md`
10. `ai-council/IQG-001/DECISIONS.md`
11. relevant reports under `ai-council/` for the ticket being resumed.
12. for IPCENTER work: `docs/IQG-005_IPCENTER_VERTICAL_V1.md`, `docs/IQG-005_IPCENTER_AS_IS_BASELINE_V1.md`, `docs/IQG-005_IPCENTER_DAY0_DATA_CONTRACT.md`, `docs/IQG-005_IPCENTER_GROWTH_BASELINE_V1.md`.

## Governance
- Iván: CEO / Product Owner / final authority.
- ChatGPT: Chief Architect + coordinator; maintains architecture, ticketing, routing, review and synthesis.
- Codex: principal engineer; code, tests, migrations, repository execution.
- Claude: product/systems challenger; UX, product logic, assumptions, overengineering review.
- DeepSeek: red team for security, integrity, concurrency and adversarial scenarios.
- Gemini: external evidence/market/law/competitor/standards research.
- Dola: lateral executive-assistant support only; not technical control tower.

Rule: `Iván define → ChatGPT coordina → especialista ejecuta → ChatGPT revisa → Iván decide only when a real CEO decision is required`.

## Laboratory philosophy — CEO correction 2026-09-15
VANSAM, Café Zacarías, Chocolates and IPCENTER are **real businesses and living laboratories**. They must grow economically while teaching IQ GROWTH. Do not treat them as mockups and do not create separate Core systems per business.

Laboratories:
- IQG-002 VANSAM — gastronomy/direct sale/service.
- IQG-003 Café Zacarías — agriculture/process/plant/distribution/export.
- IQG-004 Chocolates — procurement/manufacturing/distribution; brand pending.
- IQG-005 IPCENTER — Product Fit/sourcing/quotation/procurement/logistics/serials/warranty/digital demand.

## Active technical critical path

### IQG-001.2 — Core security/isolation
State: `CHECKPOINT_SAFE` / implementation paused previously because Codex quota was nearly exhausted.

Do not restart from scratch. Resume existing local feature work and verify preserved commits/checkpoint before touching code.

Known local Codex checkpoint from prior work:
- branch: `feature/iqg-001-2-runtime-remediation`
- local commits previously reported: `e4cc867` and `05b5687`
- `tests/pg16/` was intentionally partial/uncommitted at checkpoint; destructive reset/clean must be avoided until verified.

Remaining gate, consistent with `docs/BACKLOG.md`:
1. complete secure bootstrap / N-03 / C1;
2. validate active user/company context N-04/C5;
3. close anonymization scope N-01/C4;
4. close PII uniqueness design N-05/C3;
5. complete PostgreSQL 16 runtime harness;
6. execute RLS/roles/ACL/concurrency/rollback/restore matrix;
7. DeepSeek re-audit;
8. ChatGPT synthesis;
9. only then advance to next technical gate.

Next technical command intent:
`REANUDAR IQG-001.2 → COMPLETAR HARNESS PG16 → EJECUTAR MATRIZ → DEEPSEEK REAUDIT → CHATGPT SYNTHESIS`

Do not implement IQG-001.3 production migration, IQG-100 product code or IQG-005 vertical code before this gate closes.

### IQG-001.3 — V11 migration
- plan/addendum ready;
- production migration blocked until IQG-001.2 closes and Phase -1 is completed;
- remaining: freeze, backups/export, localStorage evidence, hashes, test importer, shadow import, reconciliation, rollback.

### IQG-001.4 — final core audit
Still pending after 001.2/001.3 readiness:
- Claude coherence/product review;
- DeepSeek security/integrity/isolation break attempt;
- ChatGPT architecture/debt synthesis;
- Iván release approval.

## Active product/data parallel path

### IQG-100 — Growth Engine / VANSAM first
Design largely complete; no coding until core gate allows it.

Current VANSAM work resumes at:
`CATÁLOGO VIGENTE → VENTAS POR SKU/TAMAÑO → TIEMPOS → STOCK/COMPRAS → PERSONAL → INCIDENCIAS → ECONOMÍA REAL`

VANSAM operating calendar is non-negotiable:
- Wednesday through Monday = 6 operating days;
- Tuesday = planned closed; nobody works Tuesday.

CEO business target: **50–100 pizzas/day sustainable**, then evaluate branch replication once economics/capacity are proven.

Catalog progress already known:
- pizza menu/combos/beverages captured;
- Napoboom = Napolitana alias;
- Hawaiana strongest hero-product signal;
- remaining individual coffees/chocolates/frappes/hamburgers and unresolved costs/prices may be added with `PENDING/UNKNOWN` rather than blocking the catalog.

### IQG-003 Café Zacarías
- canonical name is Café Zacarías, not Café Don Zacarías.
- already sells in El Alto and should begin prospective measurement now.
- current/relevant channels: carts/vehicles, fixed/mobile street stalls, shops, kiosks, sellers.
- target B2B: restaurants, cafés, hotels, wholesale.
- 4 commercial lines: 2 torrados + 2 specials.
- Senkata plant + finca development continue as real business tracks.
- future green-coffee export; exact quality score/document to verify before commercial claim.

### IQG-004 Chocolates
- brand name is pending; current Florita/Flora/La Florita references are not final.
- cacao sourcing region confirmed by CEO: Alto Beni, Bolivia.
- shared Senkata facility with separate inventory/lots/formulas/economics.

### IQG-005 IPCENTER
State: `DESIGN + AS_IS + DATA`, no vertical coding yet.

Purpose:
- reactivate an existing technology/import business profitably;
- leverage historical brand, WhatsApp Business/contact base and Facebook community;
- CEO-reported ~44k Facebook followers remains `TO_VERIFY` as exact metric;
- evolve from high-end laptop import identity to intelligent sourcing/procurement of hard-to-find products;
- start narrow and expand by evidence: laptops/cellphones → drones/reparts/specialized products;
- IA may research/compare/recommend with real sources; human approval remains for purchases/material risk.

IPCenter tests a universal chain:
`REQUEST != QUOTE != ORDER != PROCUREMENT != SALE != PAYMENT != CASH_MOVEMENT != FULFILLMENT`.

Do not hardcode `laptop`, `drone`, `Miami`, `courier` or auto part into Core.

### Claude
Do not ask Claude to redesign from zero. Use Claude for focused challenges:
- VANSAM menu complexity/margin/operational burden when enough data exists;
- Daily Decision Engine UX;
- IPCENTER Product Fit/quotation workflow only after AS-IS inputs are sufficient;
- later coherence review at IQG-001.4.

### DeepSeek
Use only with concrete adversarial targets:
- IQG-001.2 runtime/security re-audit after Codex remediation;
- later integrity/fraud review for incidents, attendance, stock/cash and multibrand flows;
- IPCENTER later: supplier/evidence integrity, quote tampering, serial/warranty/fulfillment, multitenant isolation.

### Gemini
Use for fresh external evidence only: market, regulation, competitors, pricing, import/compliance sources, standards. Do not use Gemini to replace internal operational truth.

## Other project tracks
- Senkata masterplan remains phased; current Café Zacarías production is in Huayna Potosí, not Senkata.
- Shared facility/multibrand distribution architecture exists for Café + Chocolates without mixing inventory, ownership, margin or cash.
- IQG-110+ legal/compliance/defensibility architecture exists; implementation deferred by sequence.

## Anti-loss rule
A fresh chat must not infer the whole project from memory alone. Before continuing technical/product work, load `docs/BACKLOG.md`, `docs/HANDOFF_NEW_CHAT_2026-09-14.md`, this file, `docs/CEO_CORRECTIONS_2026-09-15.md` and the relevant canonical ticket/spec. If chat recollection conflicts with latest CEO-confirmed record or repository state, the repository + latest CEO correction wins.

**State:** `NEW_CHAT_CONTINUITY_READY_2026-09-15`
