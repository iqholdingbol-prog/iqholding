# IQ GROWTH — New Chat Handoff 2026-09-14

**Purpose:** ensure continuity when moving to a fresh ChatGPT conversation without losing the current project state.

## Canonical sources to load first
1. `docs/MASTER_CONTEXT.md`
2. `docs/CEO_CONFIRMED_BUSINESS_FACTS.md`
3. `docs/CURRENT_STATE.md`
4. `docs/EXECUTION_STATE.md`
5. `docs/IQG_CORE_UNIVERSAL_BUSINESS_MODEL_V1.md`
6. `docs/IQG-100_VANSAM_AS_IS_DATA_BASELINE_V1.md`
7. `docs/IQG-100_VANSAM_BASELINE_V1.md`
8. `docs/IQG-100_VANSAM_PEOPLE_ACCOUNTABILITY_SPEC.md`
9. `docs/IQG-100_VANSAM_RESPONSIBILITY_MATRIX_V1.md`
10. `docs/IQG-120_FORMALITY_SPECTRUM_AND_LABOR_COST_MODEL.md`

## Non-negotiable VANSAM facts
- VANSAM operates **6 days per week: Wednesday through Monday**.
- **Tuesday = PLANNED_CLOSED. Nobody works Tuesday.**
- Customer opening: 16:00.
- Dine-in service until 23:00.
- Takeaway until 23:30.
- After commercial close, each worker cleans their own area before leaving.
- Current approximate physical layout: local ~8x8 m; salon ~6x8 m; kitchen ~2x8 m.
- Main 23-inch touchscreen = cashier/front-of-house primary terminal.
- 13-inch slower screen = lightweight kitchen display.
- 42-inch TV = customer order confirmation / cross-sell / status display.
- Current flow is manual: customer orders/pays at cashier; order written on paper/notebook; cashier verbally communicates order to kitchen; Samira currently assembles/bakes; cashier delivers.
- When helper is absent, Iván may cover cashier operationally today, but strategic target is **Iván outside daily operation**.
- Samira currently covers administration, dough, purchasing/restocking and weekend hamburgers; strategic target is that VANSAM eventually works without operational dependence on Samira.
- Future hornero/armador proposed at Bs 3,300; future mesera/cajera proposed Bs 1,800–2,000 but legal/journey validation pending.
- Incidents must be immutable/auditable; Samira may view but not edit/delete. Functional responsibility does not automatically mean blame.

## Current VANSAM data baseline already known
- Planned operating days normalized monthly: 26.
- Current known costs before stable staffing: rent 2,000; electricity 450; water 150; internet 50; Samira assigned 2,500; part-time helper 88 Bs/shift Mon/Wed/Fri/Sat.
- Known current monthly structure incl. helper: ~Bs 6,675.33.
- Current when-open performance: ~12 pizzas/day average, ~Bs 800 gross sales/day, range 8–16 pizzas/day.
- Last 30-day calendar performance is not representative because VANSAM was closed roughly 3+ weeks; do not use it as normal monthly baseline.
- Growth target is not capped at 30–50 pizzas/day; stages can be 30, 50, 100+ subject to capacity, demand and margin.
- Existing pizza cost snapshot and margins are already documented in `docs/IQG-100_VANSAM_BASELINE_V1.md`; do not ask CEO to repeat them unless a price has changed.
- Purchase price history is non-retroactive: new purchase price affects future only, never historical cost records.

## Current design/governance principles
- IQ GROWTH must serve many rubros, sizes and formal/informal/transitioning businesses.
- Core universal; verticals/adapters are specific. Business adapts by configuration, not by rewriting Core.
- Formality model = observed reality + verified obligation + compliance gap + transition plan.
- `ORDER != SALE`, `SALE != PAYMENT`, `PAYMENT != CASH MOVEMENT`.
- History is sacred: no silent overwrite.
- Iván directs; ChatGPT coordinates; Codex builds; Claude challenges; DeepSeek red-teams; Gemini provides external evidence; Dola supports the CEO.

## CURRENT PRIORITY — resume here
Do **not** continue with interior/facade image generation unless CEO explicitly asks.
The current path is to close VANSAM operational/economic data so IQ GROWTH can calculate and decide.

### Sequence
1. **CATÁLOGO VIGENTE REAL**
   - pizzas that remain / doubtful / retire;
   - P/M/G prices;
   - hamburgers;
   - beverages;
   - coffees;
   - chocolates/frappes;
   - current actual prices.

2. **VENTAS REALES POR PRODUCTO**
   - begin with one complete VANSAM operating cycle: **Wednesday→Monday = 6 operating days**;
   - capture sales by SKU/size, not just daily Bs;
   - do not invent 7-day windows.

3. **TIEMPOS REALES**
   - order time → kitchen → oven → ready → delivery;
   - 15–30 orders are enough to begin bottleneck analysis.

4. **STOCK CRÍTICO + COMPRAS**
   - mozzarella, flour, meats, drinks, boxes, sauces, etc.;
   - quantity, purchase date, actual purchase price, supplier/evidence when available;
   - stockout date/time/incidence.

5. **PERSONAL REAL**
   - entry/exit;
   - role actually performed;
   - absence/delay;
   - compare theoretical role vs actual work.

6. **INCIDENCIAS**
   - stockouts, dough, topping, equipment, delays, service, cashier/system errors;
   - reporter, responsible process, response, evidence, outcome;
   - immutable history.

7. **ECONOMÍA REAL**
   - product margin;
   - sales mix;
   - daily coverage;
   - break-even;
   - scenarios: CURRENT / EQUIPPED / FORMAL ESTIMATED / AUTONOMOUS.

## Exact next request to CEO
Ask for the **current menu/catalog**, preferably photo or text, and for each product a simple status:
`SE QUEDA / DUDOSO / RETIRAR`.

From that input produce:
- `MENÚ VANSAM V1`;
- IQ GROWTH catalog mapping;
- product/price/cost/margin matrix;
- initial prune recommendations based on operational complexity + margin + actual demand once sales data begins.

## Anti-loss rule
If the new chat conflicts with this handoff or `CEO_CONFIRMED_BUSINESS_FACTS.md`, use the **latest CEO correction** and update the canonical document rather than relying on generic assumptions or chat memory.
