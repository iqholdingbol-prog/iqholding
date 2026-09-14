# IQ GROWTH — AI Council Continuity Handoff 2026-09-14

**Purpose:** preserve the active technical/product workstream across a new ChatGPT conversation so Codex, Claude, DeepSeek, Gemini and ChatGPT continue from the correct checkpoint rather than restarting.

## Canonical sources to load
1. `docs/MASTER_CONTEXT.md`
2. `docs/CEO_CONFIRMED_BUSINESS_FACTS.md`
3. `docs/CURRENT_STATE.md`
4. `docs/EXECUTION_STATE.md`
5. `docs/BACKLOG.md`
6. `docs/HANDOFF_NEW_CHAT_2026-09-14.md`
7. `AI_TEAM_PROTOCOL.md`
8. `AI_TEAM_PROTOCOL_ADDENDUM_DOLA.md`
9. `ai-council/IQG-001/DECISIONS.md`
10. relevant reports under `ai-council/` for the ticket being resumed.

## Governance
- Iván: CEO / Product Owner / final authority.
- ChatGPT: Chief Architect + coordinator; maintains architecture, ticketing, routing, review and synthesis.
- Codex: principal engineer; code, tests, migrations, repository execution.
- Claude: product/systems challenger; UX, product logic, assumptions, overengineering review.
- DeepSeek: red team for security, integrity, concurrency and adversarial scenarios.
- Gemini: external evidence/market/law/competitor/standards research.
- Dola: lateral executive-assistant support only; not technical control tower.

Rule: `Iván define → ChatGPT coordina → especialista ejecuta → ChatGPT revisa → Iván decide only when a real CEO decision is required`.

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

Do not implement IQG-001.3 production migration or IQG-100 product code before this gate closes.

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

### IQG-100 — Growth Engine
Design largely complete; no coding until core gate allows it.

Current VANSAM work resumes at:
`CATÁLOGO VIGENTE → VENTAS POR SKU/TAMAÑO → TIEMPOS → STOCK/COMPRAS → PERSONAL → INCIDENCIAS → ECONOMÍA REAL`

VANSAM operating calendar is non-negotiable:
- Wednesday through Monday = 6 operating days;
- Tuesday = planned closed; nobody works Tuesday.

### Claude
Do not ask Claude to redesign from zero. Use Claude only for focused product/system challenges against current canonical specs, especially:
- menu/catalog complexity versus margin/operational burden when enough sales data exists;
- owner/operator UX of Daily Decision Engine when fresh data supports it;
- later coherence review at IQG-001.4.

### DeepSeek
Use only when there is a concrete adversarial target:
- IQG-001.2 runtime/security re-audit after Codex remediation;
- later integrity/fraud review for incidents, attendance, stock/cash and multibrand flows.

### Gemini
Use for fresh external evidence only when needed: market, regulation, competitors, sources, pricing context. Do not use Gemini to replace internal operational truth.

## Other project tracks already designed
- IQG-003 Café Don Zacarías: agriculture → harvest → benefit/drying → Huayna Potosí current production → phased move to Senkata → plant → distribution.
- IQG-004 Chocolates La Florita: purchased cacao today, possible own cacao agriculture in Mayaya later, manufacturing, formulations, multichannel sales.
- Senkata masterplan is phased; current coffee production is in Huayna Potosí, not Senkata.
- Shared facility/multibrand distribution architecture exists for Café + Chocolate without mixing inventory, ownership, margin or cash.
- IQG-110+ legal/compliance/defensibility architecture exists; implementation deferred by sequence.

## Anti-loss rule
A fresh chat must not infer the whole project from memory alone. Before continuing technical/product work, load `docs/BACKLOG.md`, `docs/HANDOFF_NEW_CHAT_2026-09-14.md`, this file, and the relevant canonical ticket/spec. If any chat recollection conflicts with the latest CEO-confirmed record or repository state, the repository + latest CEO correction wins.

**State:** `NEW_CHAT_CONTINUITY_READY`
