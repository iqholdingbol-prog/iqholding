# IQG-001 — STATUS

```text
TICKET: IQG-001.2
STATUS: BLOCKED_EXTERNAL_REVIEW
CURRENT_OWNER: Dola
NEXT_OWNER: DeepSeek
CEO_ACTION_REQUIRED: false
LAST_ARTIFACT_COMMIT: d564812dd3583e837b838654f14d6159c8a53d87
LAST_VERIFIED_IMPLEMENTER_REPORT: ai-council/IQG-001/reports/2026-09-11_0212_codex.md
PREVIOUS_INDEPENDENT_AUDIT: ai-council/IQG-001/reports/2026-09-10_auditoria_deepseek.md
NEXT_ACTION: entregar Audit Package completo y verificable a DeepSeek
NEXT_GATE: DeepSeek verdict
```

## Estado ejecutivo
Codex completó la corrección estática de P0/P1 solicitada y el CEO autorizó continuar con la reauditoría. El trabajo no está cerrado porque falta la auditoría independiente final sobre el commit objetivo y luego la ejecución real en PostgreSQL 16.

## Reglas de transición
- DeepSeek `GO` → `READY_FOR_PG16_RUNTIME_TESTS` → owner Codex/DeepSeek.
- DeepSeek `GO WITH CONDITIONS` → `CHANGES_REQUIRED` → owner Codex.
- DeepSeek `NO-GO` → `BLOCKED_SECURITY` → owner Codex, prioridad P0/P1.
- Cambio arquitectónico irreversible → `CEO_DECISION` → owner Iván.

## Regla Dola
No pedir al CEO un siguiente paso si puede derivarse de estas transiciones.