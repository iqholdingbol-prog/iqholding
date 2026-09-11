# IQG-001 — STATUS

```text
TICKET: IQG-001.2
STATUS: CHANGES_REQUIRED
CURRENT_OWNER: Codex
NEXT_OWNER: DeepSeek
CEO_ACTION_REQUIRED: false
LAST_ARTIFACT_COMMIT: d564812dd3583e837b838654f14d6159c8a53d87
LAST_VERIFIED_IMPLEMENTER_REPORT: ai-council/IQG-001/reports/2026-09-11_0212_codex.md
LATEST_EXTERNAL_REVIEW: DeepSeek reaudit 2026-09-11 — GO WITH CONDITIONS
NEXT_ACTION: remediar condiciones estáticas y preparar matriz PostgreSQL 16 efímera
NEXT_GATE: READY_FOR_PG16_RUNTIME_TESTS
```

## Estado ejecutivo
DeepSeek completó la reauditoría independiente del commit `d564812dd3583e837b838654f14d6159c8a53d87` y emitió `GO WITH CONDITIONS`. El esquema NO está aprobado para producción. El siguiente trabajo corresponde a Codex: cerrar/remediar las condiciones estáticas y preparar una matriz real de pruebas PostgreSQL 16 antes de una nueva revisión independiente.

## Condiciones y hallazgos a tratar antes/durante el gate runtime
1. **N-03 / C1 — bootstrap SECURITY DEFINER:** `contexto_bootstrap_activo()` usa `current_user = 'iqg_owner'`. PostgreSQL 16 documenta que `current_user` cambia durante `SECURITY DEFINER`, por lo que esta comprobación no autentica al invocador y debe corregirse o rediseñarse antes del runtime.
2. **C2 — RLS + permisos de funciones:** PostgreSQL 16 documenta que las expresiones de política se ejecutan con los derechos del usuario de la consulta y éste debe poder acceder a las funciones referenciadas. La arquitectura debe mantener `iqg_app` sin acceso SQL directo y probar el contrato del futuro gateway/endpoints; no conceder permisos amplios por reflejo.
3. **N-04 / C5 — activo:** `contexto_membresia_activa()` debe considerar `usuario.activo` y `empresa.activo`, o existir una garantía equivalente verificable.
4. **N-05 / C3 — unicidad y cifrado:** documentar ADR del tradeoff y decidir blind index/HMAC o claves externas únicas donde la unicidad sea requisito.
5. **N-01 / C4 — anonimización:** documentar alcance actual (cliente) y plan explícito para `usuario`/`empresa`; si el requisito ya aplica al MVP, implementar antes del gate.
6. **N-02 — validación de dominios en UPDATE:** DeepSeek lo clasificó P1 pero lo omitió de C1–C5. Codex debe corregir el trigger para validar solo cuando cambia el código o justificar técnicamente una severidad menor con evidencia.

## Matriz PostgreSQL 16 obligatoria
Debe probar como mínimo:
- instalación completa del DDL y COMMIT;
- postura ACL/owners y ausencia de privilegios residuales;
- RLS con 2 companies × 2 branches y pruebas de fuga negativas;
- comportamiento de `SECURITY DEFINER`, `current_user` y `session_user`;
- permisos necesarios para funciones usadas por políticas;
- recursión/lectura de `contexto_membresia_activa()` bajo FORCE RLS;
- provisioning idempotente concurrente;
- constraint triggers fiscales diferidos;
- cadena fiscal y advisory locks/deadlocks;
- reversos/pagos/precios concurrentes;
- rollback/restore del esquema.

## Reglas de transición
- Correcciones estáticas + harness listos → `READY_FOR_PG16_RUNTIME_TESTS` → owner Codex/DeepSeek.
- Runtime sin P0/P1 material → revisión DeepSeek/ChatGPT → decidir siguiente gate.
- Runtime reabre P0/P1 → `BLOCKED_SECURITY` → owner Codex.
- Cambio arquitectónico material → `CEO_DECISION` → owner Iván.

## Regla Dola
No pedir al CEO un siguiente paso mientras pueda derivarse de este estado y de las transiciones anteriores.