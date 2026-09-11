# EXECUTION_STATE.md
## IQ GROWTH — Estado Ejecutivo Operativo
### Última actualización: 2026-09-11

> Este archivo es la memoria operativa de corto plazo. Dola debe leerlo antes de coordinar trabajo activo y actualizarlo cuando cambien estado, responsable, bloqueo o siguiente acción.

## TICKET ACTIVO
- `IQG-001.2` — Seguridad, integridad y Doble Régimen Fiscal

## OBJETIVO ACTUAL
Cerrar las condiciones de la reauditoría DeepSeek y preparar/ejecutar una matriz reproducible de validación runtime PostgreSQL 16 antes de cualquier decisión de producción.

## ESTADO
- `CHANGES_REQUIRED`

## CURRENT_OWNER
- `Codex` — remediación estática + harness PostgreSQL 16.

## NEXT_OWNER
- `DeepSeek` — revisión independiente posterior a remediación y resultados runtime.

## ARTEFACTO OBJETIVO
- Commit auditado: `d564812dd3583e837b838654f14d6159c8a53d87`
- Esquema: `schemas/core_schema.sql`
- Informe Codex previo: `ai-council/IQG-001/reports/2026-09-11_0212_codex.md`
- Auditoría DeepSeek anterior: `ai-council/IQG-001/reports/2026-09-10_auditoria_deepseek.md`
- Reauditoría DeepSeek final recibida externamente: 2026-09-11, veredicto `GO WITH CONDITIONS`.

## ÚLTIMO RESULTADO VERIFICADO
DeepSeek completó revisión estática integral y autorizó avanzar hacia PostgreSQL 16 efímero con condiciones. NO existe aprobación de producción.

Hallazgos/condiciones prioritarios:
1. `contexto_bootstrap_activo()` usa `current_user` dentro de `SECURITY DEFINER`; requiere corrección/rediseño.
2. RLS + permisos de funciones debe probarse con el contrato real de acceso; no abrir SQL directo a `iqg_app` como parche.
3. `contexto_membresia_activa()` no contempla `usuario.activo` / `empresa.activo`.
4. Definir tradeoff de unicidad de referencias/PII cifrada.
5. Formalizar alcance de anonimización para `usuario` / `empresa`.
6. Revisar N-02: validación de dominios en UPDATE fue clasificada P1 por DeepSeek pero omitida de sus condiciones finales.

## BLOQUEO ACTUAL
No hay bloqueo externo. El bloqueo es técnico: condiciones estáticas + falta de evidencia runtime PostgreSQL 16.

## SIGUIENTE ACCIÓN
1. Codex crea feature branch/PR de remediación.
2. Corrige los hallazgos estáticos aceptados y documenta ADRs necesarios.
3. Implementa harness reproducible PostgreSQL 16 efímero.
4. Ejecuta matriz multi-tenant, ACL/RLS, SECURITY DEFINER, concurrencia y fiscal.
5. Publica commit + informe + evidencia.
6. DeepSeek reaudita resultados y ChatGPT sintetiza el siguiente gate.

## CEO_ACTION_REQUIRED
- `false`

## REGLA DE CONTINUIDAD
Dola debe reconstruir siempre:
`OBJETIVO → ÚLTIMA DECISIÓN → ÚLTIMO ARTEFACTO → ÚLTIMO RESULTADO → BLOQUEO → SIGUIENTE PASO`.
Si no puede reconstruir los seis elementos con evidencia, debe consultar las fuentes de verdad antes de responder.