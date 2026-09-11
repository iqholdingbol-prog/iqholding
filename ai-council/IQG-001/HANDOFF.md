# IQG-001.2 — HANDOFF

## CURRENT_OWNER
**Dola**

## Objetivo del handoff
Entregar a DeepSeek un paquete completo, verificable y autosuficiente para que pueda realizar una reauditoría independiente sin requerir que Iván copie/pegue conversaciones o miles de líneas.

## NEXT_OWNER
**DeepSeek**

## Artefactos mínimos del handoff
1. `schemas/core_schema.sql` del commit `d564812dd3583e837b838654f14d6159c8a53d87`.
2. `ai-council/IQG-001/reports/2026-09-11_0212_codex.md`.
3. `ai-council/IQG-001/reports/2026-09-10_auditoria_deepseek.md`.
4. `docs/MASTER_CONTEXT.md`.
5. Manifiesto con ticket, commit y alcance de auditoría.

## DeepSeek debe revisar
- RLS y contexto;
- ACL/ownership `iqg_owner`, `iqg_app`, `iqg_gateway`;
- anonimización/redacción;
- RBAC, dominios, idempotencia;
- separación `iqg_core` / `iqg_fiscal`;
- snapshots/totales fiscales;
- bloqueo de configuración fiscal;
- concurrencia/locks;
- límites de compatibilidad y ejecución PostgreSQL 16.

## Entregable esperado
Archivo nuevo e inmutable:
`ai-council/IQG-001/reports/<timestamp>_deepseek.md`

Debe terminar exactamente con uno de:
- `GO`
- `GO WITH CONDITIONS`
- `NO-GO`

## Siguiente handoff automático
- `GO` → Codex + DeepSeek: matriz runtime PostgreSQL 16.
- `GO WITH CONDITIONS` → Codex: corregir condiciones; luego DeepSeek reaudita.
- `NO-GO` → Codex: corregir P0/P1 antes de cualquier avance.

## CEO_ACTION_REQUIRED
`false`

## Regla de mínimo privilegio
No hacer público el repositorio completo solo para transportar estos artefactos. Preferir acceso específico, adjunto, bundle/ZIP o canal privado autorizado.