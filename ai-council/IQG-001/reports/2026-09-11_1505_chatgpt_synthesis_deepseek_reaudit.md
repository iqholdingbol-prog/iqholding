# IQG-001.2 — Síntesis ChatGPT de reauditoría DeepSeek

**Ticket:** IQG-001.2  
**Modelo:** ChatGPT  
**Rol:** Chief Architect & AI Council Coordinator  
**Fecha:** 2026-09-11  
**Commit auditado por DeepSeek:** `d564812dd3583e837b838654f14d6159c8a53d87`  
**Fuente principal:** reauditoría externa DeepSeek recibida por el CEO el 2026-09-11  
**Tipo:** síntesis técnica y resolución de siguiente gate  

## Veredicto recibido
DeepSeek emitió `GO WITH CONDITIONS` hacia PostgreSQL 16 efímero. No existe aprobación para producción.

## Síntesis
La reauditoría es suficientemente amplia para cerrar el gate de revisión estática y pasar a remediación + validación runtime. Confirma mejoras sustanciales: 33 tablas, separación `iqg_core`/`iqg_fiscal`, hardening de roles/ACL, RLS generalizado, anonimización de cliente, dominios, idempotencia y fiscal outbox/snapshots.

## Condiciones prioritarias
1. **N-03 / C1 — `contexto_bootstrap_activo()`**: el uso de `current_user = 'iqg_owner'` dentro de una función `SECURITY DEFINER` no identifica al invocador. PostgreSQL 16 documenta que `current_user` cambia durante `SECURITY DEFINER`. Debe corregirse/rediseñarse antes del runtime.
2. **C2 — RLS y privilegios de funciones**: PostgreSQL 16 documenta que las expresiones de policy se ejecutan con los derechos del usuario de la consulta y éste debe poder acceder a funciones referenciadas. No se debe resolver concediendo acceso SQL amplio a `iqg_app`; el contrato correcto debe mantener acceso de aplicación a través de gateway/endpoints mínimos revisados.
3. **N-04 / C5 — activo**: membership debe respetar `usuario.activo` y `empresa.activo` o una garantía equivalente.
4. **N-05 / C3 — unicidad vs cifrado**: requiere ADR y decisión explícita sobre blind index/HMAC o clave externa única donde el negocio exija unicidad.
5. **N-01 / C4 — anonimización**: formalizar alcance actual y plan para `usuario`/`empresa`.
6. **N-02**: DeepSeek lo clasificó P1 pero no lo incluyó en C1–C5. Debe corregirse el trigger de dominio para no bloquear en UPDATE sin cambio de código, o justificarse un downgrade con evidencia.

## Matriz runtime obligatoria
- parse/execute del DDL completo en PostgreSQL 16 limpio;
- ACL/owners/schema/function privileges al COMMIT;
- RLS con 2 companies × 2 branches y pruebas negativas cross-tenant;
- `current_user`/`session_user` dentro de SECURITY DEFINER;
- permisos sobre funciones usadas por policies;
- membership bajo FORCE RLS y recursión;
- provisioning idempotente concurrente;
- pagos/reversos/precios concurrentes;
- fiscal snapshots/totales y constraint triggers diferidos;
- advisory locks/deadlocks;
- rollback/restore.

## Siguiente owner
**Codex** — remediación estática y harness PostgreSQL 16 en feature branch/PR.  
Después: **DeepSeek** reaudita evidencia runtime; **ChatGPT** sintetiza el siguiente gate.

## CEO_ACTION_REQUIRED
`false`

## Decisión de coordinación
`GO WITH CONDITIONS`
