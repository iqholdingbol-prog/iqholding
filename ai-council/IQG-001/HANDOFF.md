# IQG-001.2 — HANDOFF

## CURRENT_OWNER
**Codex**

## Objetivo del handoff
Tomar el veredicto DeepSeek `GO WITH CONDITIONS` sobre el commit `d564812dd3583e837b838654f14d6159c8a53d87`, cerrar las condiciones estáticas que no requieren esperar runtime y preparar la matriz PostgreSQL 16 efímera que valide las garantías que no pueden demostrarse por DDL.

## NEXT_OWNER
**DeepSeek** — revisión independiente posterior a la remediación/runtime.

## Resultado recibido
DeepSeek concluyó:
- esquema sólido y sustancialmente endurecido;
- `GO WITH CONDITIONS` hacia PostgreSQL 16 efímero;
- NO aprobado para producción;
- confianza del informe: 88%;
- confianza estimada de pasar runtime sin reabrir P0/P1: 55–65%.

## Trabajo obligatorio para Codex
1. Corregir/rediseñar `contexto_bootstrap_activo()` para que no use `current_user = 'iqg_owner'` como prueba del invocador dentro de `SECURITY DEFINER`.
2. No conceder `EXECUTE`/USAGE/DML amplios a `iqg_app` como parche. Definir y probar el contrato de acceso: `iqg_app` no debe tener SQL directo; el futuro gateway/endpoints deben ser mínimos y revisables.
3. Resolver `contexto_membresia_activa()` respecto a `usuario.activo` y `empresa.activo`.
4. Documentar/implementar la estrategia de unicidad para referencias externas/PII cifrada donde el negocio la requiera.
5. Documentar el alcance de anonimización y plan para `usuario`/`empresa`; implementar si forma parte del gate actual.
6. Revisar N-02: DeepSeek lo marcó P1 pero no lo incluyó entre C1–C5. Preferencia: evitar validación de dominio en UPDATE cuando el código no cambia, o justificar downgrade con evidencia.
7. Preparar harness reproducible PostgreSQL 16 efímero y matriz de pruebas.

## Puntos técnicos ya confirmados por documentación PostgreSQL 16
- `current_user` cambia durante la ejecución de una función `SECURITY DEFINER`; por tanto, dentro de una función owned by `iqg_owner`, `current_user = 'iqg_owner'` no identifica al invocador.
- Las expresiones RLS se ejecutan como parte de la consulta con los derechos del usuario de la consulta; el usuario debe poder acceder a funciones referenciadas por la política o recibirá `permission denied`.
- `SECURITY DEFINER` cambia los privilegios usados dentro de la función, pero no elimina la necesidad de diseñar explícitamente quién puede invocarla.

## Matriz runtime mínima
- DDL parse/execute completo en PostgreSQL 16 limpio;
- roles/ACL/schema/function privileges al COMMIT;
- 2 companies × 2 branches, lectura/escritura negativa cross-tenant;
- `current_user` vs `session_user` en helpers SECURITY DEFINER;
- acceso a helpers desde roles reales del harness;
- FORCE RLS y recursión de membership;
- bootstrap/provisioning concurrente e idempotente;
- pagos/reversos/precios concurrentes;
- fiscal snapshots/totales y constraint triggers diferidos;
- advisory locks y detección de deadlocks;
- rollback/restore.

## Entregables Codex
- commit de remediación en feature branch/PR;
- informe inmutable bajo `ai-council/IQG-001/reports/`;
- scripts/harness de PostgreSQL 16;
- resultados reproducibles de la matriz;
- lista explícita de hallazgos cerrados, aceptados o diferidos.

## CEO_ACTION_REQUIRED
`false`

## Regla de handoff
No pasar a DeepSeek como `REVIEW_IN_PROGRESS` hasta que exista commit/harness y evidencia runtime verificable.