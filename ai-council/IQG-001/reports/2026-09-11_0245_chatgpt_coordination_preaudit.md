# IQG-001.2 — Preauditoría de coordinación ChatGPT

Ticket: IQG-001.2
Modelo: ChatGPT
Rol: Chief Architect & AI Council Coordinator
Fecha/hora: 2026-09-11 02:45 America/La_Paz
Commit auditado: d564812dd3583e837b838654f14d6159c8a53d87
Fuentes leídas:
- schemas/core_schema.sql
- ai-council/IQG-001/reports/2026-09-11_0212_codex.md
- ai-council/IQG-001/reports/2026-09-10_auditoria_deepseek.md
Tipo: PREAUDITORÍA / COORDINACIÓN / REVISIÓN ESTÁTICA
Confianza: media-alta en hallazgos estáticos; media hasta ejecutar PostgreSQL 16

> Este documento NO es una auditoría DeepSeek. Su propósito es señalar hipótesis y riesgos que la reauditoría independiente debe confirmar o refutar.

## 1. Resumen ejecutivo

El commit d564812 corrige de forma sustancial los P0/P1 estructurales señalados en la auditoría DeepSeek anterior: introduce roles técnicos dedicados sin login ni BYPASSRLS, revocación total para aplicación/gateway, ownership controlado, RLS forzada, contexto con membresía activa, anonimización de cliente, RBAC corporativo, dominios, provisioning idempotente, separación iqg_core/iqg_fiscal y controles fiscales diferidos.

Sin embargo, todavía NO considero el artefacto listo para producción por tres razones principales:

1. La seguridad actual de iqg_app/iqg_gateway es fail-closed porque no tienen acceso a nada; la futura pasarela autenticada que abrirá contexto todavía no existe. El P0 de spoofing queda contenido, no probado en el escenario funcional final.
2. El DDL no fue ejecutado contra PostgreSQL 16 y el commit no tiene evidencia CI asociada. Sintaxis, ACL efectivas, FORCE RLS, constraint triggers, locks y rollback completo siguen sin verificación runtime.
3. Detecté una inconsistencia semántica fiscal que requiere revisión: `factura_xml.estado_envio_codigo = 'RECHAZADO'` exige `aceptado_por_fisco_en IS NOT NULL`, por lo que una fila rechazada debe poblar un campo cuyo nombre afirma aceptación. Además, `factura.estado_emision_codigo` pasa a `EMITIDA` al generar el XML local, antes de cualquier aceptación fiscal. Puede ser una convención válida si se documenta, pero hoy la nomenclatura puede producir historia fiscal engañosa.

Veredicto provisional de coordinación: GO WITH CONDITIONS.

## 2. RLS y contexto

### HECHO CONFIRMADO

El esquema aplica `ENABLE ROW LEVEL SECURITY` + `FORCE ROW LEVEL SECURITY` a las relaciones operativas/fiscales relevantes. Las políticas estrictas verifican `company_id`, `branch_id` y `contexto_membresia_activa()`. Las entidades corporativas agregan SELECT cross-branch dentro de la misma empresa, pero solo si existe membresía activa del contexto.

### HECHO CONFIRMADO

`sucursal` y `usuario_sucursal` usan políticas internas más estrechas para evitar recursión de `contexto_membresia_activa()`.

### HECHO CONFIRMADO

Los GUC `iqg.*` continúan siendo spoofables conceptualmente por una sesión SQL que pueda ejecutar `SET`; el diseño ya no los trata como identidad. La mitigación actual es ACL: `iqg_app` e `iqg_gateway` carecen de acceso a schemas, relaciones, secuencias y funciones.

### RIESGO CONDICIONADO

Cuando se cree la pasarela real y se concedan endpoints, debe demostrarse que el caller no puede elegir arbitrariamente company/branch/user. El gateway debe derivar el contexto desde identidad autenticada y autorización server-side, no desde parámetros del cliente.

Estado de H-01 anterior: PARCIALMENTE CERRADO / CONTENIDO. No se puede declarar cerrado en arquitectura funcional hasta existir y probar el gateway.

## 3. ACL: iqg_owner / iqg_app / iqg_gateway

### HECHO CONFIRMADO

Los tres roles están declarados NOLOGIN, NOSUPERUSER, NOBYPASSRLS, NOINHERIT, sin CREATEDB/CREATEROLE/REPLICATION.

### HECHO CONFIRMADO

El instalador recibe temporalmente iqg_owner, luego `RESET ROLE` + `REVOKE` antes de COMMIT. El verificador final falla si iqg_owner conserva miembros.

### HECHO CONFIRMADO

Hay verificadores de ownership para schemas, relaciones y funciones SECURITY DEFINER, además de verificadores de privilegios efectivos para iqg_app/iqg_gateway.

### HECHO CONFIRMADO

Los default privileges del owner revocan privilegios a PUBLIC/app/gateway.

### LIMITACIÓN

Sin PostgreSQL 16 real no se ha demostrado que todos los GRANT/REVOKE/options utilizados se comporten exactamente como se espera en runtime ni que no exista una diferencia de versión/sintaxis.

Estado H-03 anterior: ESTÁTICAMENTE CERRADO; RUNTIME NO VERIFICADO.

## 4. Anonimización y PII

### HECHO CONFIRMADO

Cliente usa sobres cifrados, referencia de clave externa y no guarda material de clave en SQL.

### HECHO CONFIRMADO

`anonimizar_cliente(...)` crea solicitud inmutable, elimina sobres PII operativos del cliente, lo desactiva y redacta los campos PII históricos en `iqg_core.registro_cambios` dentro de la misma transacción.

### HECHO CONFIRMADO

La anonimización se bloquea si existe factura fiscal pendiente de materialización para el cliente.

### RIESGO / ALCANCE INCOMPLETO

La capacidad cubre cliente y bitácora operativa relacionada. No cubre aún ciclo de anonimización de usuario ni de empresa cuando la empresa sea persona física. Codex reconoce esta limitación.

Estado H-02 anterior: CERRADO PARA CLIENTE OPERATIVO; PARCIAL PARA IDENTIDADES PERSONA/USUARIO Y POLÍTICA GLOBAL.

## 5. RBAC, dominios e idempotencia

### HECHO CONFIRMADO

Rol/permiso son corporativos por company; usuario_rol mantiene asignación por sucursal.

### HECHO CONFIRMADO

`contexto_tiene_permiso()` exige membresía activa, rol activo, rol_permiso activo y permiso activo.

### HECHO CONFIRMADO

Existen `dominio` y `dominio_valor`, más validadores de unidad de medida para línea/movimiento.

### HECHO CONFIRMADO

Provisioning usa `(origen_idempotencia, clave_idempotencia)` como reserva global y el esquema incorpora idempotencia compuesta en hechos críticos.

### PUNTO PARA DEEPSEEK

Verificar si estado inactivo de empresa/usuario se integra completamente en `contexto_membresia_activa()` y si no existe ruta donde una membresía todavía activa sobreviva lógicamente a una identidad desactivada.

## 6. Separación iqg_core / iqg_fiscal

### HECHO CONFIRMADO

Las tablas fiscales viven en `iqg_fiscal`: factura, factura_linea, factura_xml, evento_emision_factura y registro_cambios fiscal.

### HECHO CONFIRMADO

La auditoría fiscal está separada de `iqg_core.registro_cambios`, evitando autoauditoría recursiva.

### HECHO CONFIRMADO

Cuando `facturacion_fiscal_activa` es false, el trigger de programación retorna sin crear factura.

### RIESGO CONDICIONADO

Las funciones SECURITY DEFINER fiscales usan `search_path = iqg_core, iqg_fiscal, pg_temp`. Los objetos se referencian en general de forma schema-qualified, pero DeepSeek debe revisar exhaustivamente cualquier resolución de nombre no cualificada y objetos temporales que puedan interferir.

## 7. Snapshots y totales fiscales

### HECHO CONFIRMADO

`tg_validar_factura_linea_origen()` compara factura/operación y snapshot contra la línea operativa: número, descripción, unidad, cantidad, moneda, precio, bruto, descuento, impuesto y total.

### HECHO CONFIRMADO

Constraint triggers diferidos verifican al COMMIT que exista al menos una línea y que los totales de factura cuadren exactamente.

### HECHO CONFIRMADO

La programación fiscal bloquea la operación `FOR UPDATE`, materializa factura una vez (`ON CONFLICT (company_id, branch_id, operacion_id) DO NOTHING`) y después copia las líneas.

### HALLAZGO NUEVO — P1 SEMÁNTICA FISCAL

La tabla `factura_xml` define:

- `ACEPTADO`: exige `aceptado_por_fisco_en IS NOT NULL`
- `RECHAZADO`: también exige `aceptado_por_fisco_en IS NOT NULL`

Por definición nominal, un documento rechazado no fue aceptado. Usar `aceptado_por_fisco_en` como timestamp de respuesta para rechazo produce una contradicción semántica en la historia. Recomiendo reemplazarlo por un campo neutral como `respondido_por_fisco_en`, o separar `aceptado_en` / `rechazado_en`.

### HALLAZGO NUEVO — P1/P2 SEMÁNTICA DE EMISIÓN

`completar_emision_factura()` inserta un `factura_xml` en estado `GENERADO` y acto seguido cambia `factura.estado_emision_codigo` de `PENDIENTE_EMISOR` a `EMITIDA`. El trigger `tg_proteger_factura()` fija `fecha_emision_confirmada = clock_timestamp()` para `EMITIDA` y también para `RECHAZADA`.

Codex deja claro que `EMITIDA` no significa aceptación fiscal, sino documento generado por el emisor. Técnicamente puede ser válido, pero el nombre `fecha_emision_confirmada` y la transición antes de `ENVIADO/ACEPTADO` son ambiguos. El modelo debe tener semántica explícita antes de producción para evitar que analytics, soporte o integraciones interpreten `EMITIDA` como aceptada por la autoridad.

DeepSeek debe decidir si esto es solo naming/documentación o un defecto de integridad semántica que exige cambio de DDL.

## 8. Bloqueo de configuración fiscal

### HECHO CONFIRMADO

`tg_aplicar_politica_fiscal_empresa()` usa advisory lock por company y consulta `fiscal_configuracion_bloqueada` al cambiar país, régimen, obligación/voluntariedad o versión de regla.

### HECHO CONFIRMADO

El trigger de programación fiscal usa el mismo advisory lock antes de snapshot/configuración, reduciendo carrera entre cambio fiscal y emisión.

### HECHO CONFIRMADO

`fiscal_configuracion_bloqueada` tiene UNIQUE(company_id), por lo que una sola evidencia corporativa congela la configuración después de la primera factura en cualquier branch.

### PUNTO PARA DEEPSEEK

Revisar si congelar de forma permanente país/régimen/activación después de primera factura es el comportamiento de dominio correcto o si algunas correcciones legales deberían modelarse como nuevas versiones futuras sin reescribir facturas pasadas. La Historia Sagrada exige no alterar pasado, pero no necesariamente prohibir toda evolución futura de configuración.

## 9. Concurrencia

### HECHO CONFIRMADO

- reversos de pago bloquean el pago padre `FOR UPDATE`;
- reemplazo de precio usa locks y unique successor;
- emisión bloquea operación `FOR UPDATE`;
- política fiscal/emisión comparte advisory lock por company;
- provisioning tiene reserva idempotente global.

### DATO NO VERIFICABLE SIN EJECUCIÓN

No se han medido deadlocks ni orden real de adquisición bajo carga. Tampoco throughput cuando múltiples sucursales fiscalizan y cada cierre toma advisory lock a nivel company.

DeepSeek debe revisar especialmente orden de locks: operación row lock vs advisory company lock vs locks sobre factura/lineas, y política fiscal company lock vs filas de empresa/factura, buscando ciclos.

## 10. PostgreSQL 16

### HECHO CONFIRMADO

Codex no dispuso de `psql`, Docker, Podman ni servidor PostgreSQL 16. La revisión fue estática.

### HECHO CONFIRMADO

El commit no presenta status checks/CI asociados visibles desde GitHub.

### CONDICIÓN OBLIGATORIA

Antes de cualquier GO de producción, ejecutar una instalación limpia y matriz de integración en PostgreSQL 16, incluyendo aislamiento multiempresa, ACL, FORCE RLS, provisioning concurrente, anonimización, pagos concurrentes, fiscal simultáneo, totales diferidos y bloqueo de configuración.

## 11. Condiciones de release propuestas

1. DeepSeek reaudita independientemente este commit.
2. Resolver o aceptar explícitamente el hallazgo semántico `RECHAZADO` + `aceptado_por_fisco_en`.
3. Fijar semántica inequívoca de `EMITIDA` y `fecha_emision_confirmada`.
4. Ejecutar el DDL completo en PostgreSQL 16 real.
5. Ejecutar matriz de 2 empresas × 2 sucursales y pruebas de fuga.
6. Implementar y auditar el trust gateway antes de conceder cualquier EXECUTE/USAGE a aplicación.
7. Verificar rollback/restore de la migración.
8. No declarar producción-ready hasta cerrar P0/P1 runtime.

## 12. Nivel de confianza

- ACL/ownership estático: 90%
- RLS/modelo estático: 85%
- anonimización cliente: 85%
- fiscal snapshots/totales estáticos: 85%
- concurrencia runtime: 55%
- compatibilidad PostgreSQL 16 ejecutada: 0% de evidencia runtime
- seguridad del futuro gateway: 0% implementado todavía

## Veredicto de coordinación

GO WITH CONDITIONS
