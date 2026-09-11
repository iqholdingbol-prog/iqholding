# IQG-001.2 — Solicitud canónica de reauditoría independiente DeepSeek

Ticket: IQG-001.2
Modelo requerido: DeepSeek
Rol: Red Team, Security & Data Integrity Auditor
Fecha/hora: 2026-09-11 02:40 America/La_Paz
Commit objetivo: d564812dd3583e837b838654f14d6159c8a53d87
Tipo: SOLICITUD DE AUDITORÍA INDEPENDIENTE
Estado: PENDIENTE DE EJECUCIÓN POR DEEPSEEK

## Autoridad

El CEO aprobó IQG-001.2 y autoriza a DeepSeek a continuar la auditoría de seguridad e integridad. Esta revisión debe ser independiente: DeepSeek puede leer los informes anteriores como evidencia, pero no debe asumir como correctas las conclusiones de Codex ni de ChatGPT.

## Fuentes obligatorias

Leer como mínimo:

- `schemas/core_schema.sql` exactamente en commit `d564812dd3583e837b838654f14d6159c8a53d87`
- `ai-council/IQG-001/reports/2026-09-11_0212_codex.md`
- `ai-council/IQG-001/reports/2026-09-10_auditoria_deepseek.md`
- `docs/MASTER_CONTEXT.md`
- `docs/CURRENT_STATE.md`
- `docs/ARCHITECTURE.md`
- `docs/BACKLOG.md`
- `AI_TEAM_PROTOCOL.md`

## Misión

Reauditar desde cero la seguridad, aislamiento, integridad temporal y fiscal del esquema PostgreSQL 16 de IQG-001.2. Intentar refutar las afirmaciones de Codex. Separar siempre:

- HECHO CONFIRMADO
- RIESGO CONFIRMADO
- RIESGO CONDICIONADO
- HIPÓTESIS
- DATO NO VERIFICABLE SIN EJECUCIÓN

## Áreas obligatorias de revisión

### 1. RLS, tenant isolation y contexto

Verificar:

- `ENABLE ROW LEVEL SECURITY` + `FORCE ROW LEVEL SECURITY` en todas las tablas pertinentes.
- Que ninguna política permita cruce `company_id` / `branch_id`.
- `contexto_company_id()`, `contexto_branch_id()`, `contexto_usuario_id()` y todos los GUC `iqg.*`.
- `contexto_membresia_activa()` y su relación con `sucursal` / `usuario_sucursal`.
- Excepción de bootstrap y provisioning.
- Políticas corporativas cross-branch.
- Cualquier camino para spoofing de contexto antes o después de futuros GRANT de endpoint.
- Si el aislamiento actual es seguridad real o únicamente seguridad por ausencia total de acceso.

### 2. ACL y owners

Auditar específicamente:

- `iqg_owner`
- `iqg_app`
- `iqg_gateway`
- atributos NOLOGIN / NOSUPERUSER / NOBYPASSRLS / NOINHERIT
- grants temporales de instalación
- revocación antes del COMMIT
- ownership de schemas, tablas, vistas, secuencias y funciones SECURITY DEFINER
- default privileges
- EXECUTE público
- privilegios directos e indirectos por membresía
- posibilidad de SET ROLE o escalamiento

Determinar si H-01 y H-03 de la auditoría anterior están realmente cerrados o solo contenidos hasta que se implemente el gateway.

### 3. Anonimización y PII

Revisar:

- cifrado por sobres y referencias de clave externa
- ausencia de material de clave en SQL
- `anonimizar_cliente(...)`
- `anonimizacion_solicitud`
- redacción controlada de `iqg_core.registro_cambios`
- posibilidad de reidentificación
- PII histórica en JSONB, fiscal, operaciones, logs u otras columnas
- concurrencia entre anonimización y generación de factura
- bloqueo cuando existe factura pendiente
- qué ocurre con usuario y empresa persona física
- límites reales de destrucción criptográfica externa

No asumir GDPR ni ninguna obligación jurídica concreta sin verificar aplicabilidad; evaluar primero la capacidad técnica.

### 4. Roles, permisos, dominios e idempotencia

Verificar:

- roles/permisos corporativos y asignación por sucursal
- consistencia de activo/inactivo
- `dominio` / `dominio_valor`
- validación de códigos críticos
- unidades de medida
- moneda
- provisioning idempotente y concurrencia
- idempotencia de operaciones, pagos, movimientos y eventos fiscales
- posibilidad de duplicados por otras referencias

### 5. Separación `iqg_core` / `iqg_fiscal`

Verificar que:

- no existe documento fiscal operativo en `iqg_core`
- `iqg_fiscal` no contamina el registro operativo
- las FKs entre capas no abren fuga cross-tenant/cross-branch
- las funciones SECURITY DEFINER con search_path múltiple no permiten resolución insegura
- la bitácora fiscal no se audita recursivamente
- un tenant sin facturación activa no materializa factura, XML ni evento fiscal

### 6. Snapshots y totales fiscales

Intentar romper:

- origen exacto de `factura_linea`
- correspondencia con `operacion_linea`
- moneda, cantidad, unidad, precios, bruto, descuento, impuesto y total
- constraint triggers diferidos
- factura sin líneas
- líneas agregadas después de fiscalizar
- operación modificada después de snapshot
- factura duplicada
- reintentos
- semántica de `EMITIDA`, `RECHAZADA`, `GENERADO`, `ENVIADO`, `ACEPTADO`, `RECHAZADO`
- semántica temporal de `fecha_emision_confirmada` y `aceptado_por_fisco_en`

Especialmente determinar si se registra una fecha de “confirmación/emisión” antes de una aceptación real y si eso puede producir historia fiscal semánticamente falsa.

### 7. Bloqueo de configuración fiscal

Revisar:

- `fiscal_configuracion_bloqueada`
- `tg_aplicar_politica_fiscal_empresa`
- advisory locks por company
- carrera entre dos sucursales
- carrera configuración vs emisión
- primer documento simultáneo
- qué atributos quedan congelados y cuáles deberían permanecer versionables
- si `ON CONFLICT (company_id) DO NOTHING` conserva correctamente la primera evidencia

### 8. Concurrencia

Analizar al menos:

- dos cierres fiscales simultáneos
- dos devoluciones parciales del mismo pago
- dos reemplazos de precio
- dos provisionamientos con misma clave
- operación vs inserción tardía de línea
- anonimización vs emisión fiscal
- cambios de configuración fiscal entre sucursales
- locks `FOR UPDATE`, `FOR KEY SHARE` y advisory locks
- deadlocks potenciales y orden de locks
- colisiones benignas del hash de advisory lock
- throughput por serialización a nivel company

### 9. PostgreSQL 16 — ejecución real pendiente

La auditoría debe diferenciar análisis estático de evidencia ejecutada. Si DeepSeek no dispone de PostgreSQL 16 real, debe marcar como NO VERIFICADO:

- parseo completo del DDL
- sintaxis de roles/membership options
- creación y owner de objetos
- comportamiento FORCE RLS bajo SECURITY DEFINER
- constraint triggers DEFERRABLE
- funciones PL/pgSQL
- advisory locks
- privilegios efectivos de `iqg_owner`, `iqg_app`, `iqg_gateway`
- rollback completo del bootstrap ante error

No declarar producción-ready sin ejecutar la matriz en PostgreSQL 16.

## Matriz mínima de pruebas requerida para GO de ejecución

1. Instalar desde cero en PostgreSQL 16.
2. Reinstalación/reintento esperado según estrategia de migración.
3. Dos companies × dos branches.
4. Sin contexto: cero lectura/escritura.
5. Contexto falso: cero fuga.
6. Usuario sin membresía activa: cero acceso.
7. Rol de aplicación sin privilegios directos.
8. Gateway sin endpoints: cero acceso.
9. Futuro endpoint SECURITY DEFINER: contexto sobrescrito solo después de autenticar.
10. Anonimización completa de cliente y bitácora.
11. Anonimización bloqueada con factura pendiente.
12. Provisioning simultáneo con misma idempotency key.
13. Reversos de pago concurrentes sin exceder original.
14. Reemplazos de precio concurrentes sin bifurcar cadena.
15. Emisión fiscal simultánea en dos sucursales.
16. Totales fiscales incorrectos: COMMIT rechazado.
17. Línea fiscal que no coincide: rechazada.
18. Intento de cambiar régimen/configuración tras primera factura: rechazado.
19. Tenant sin facturación: cero filas en `iqg_fiscal`.
20. Restauración/rollback de migración en entorno aislado.

## Formato obligatorio del informe DeepSeek

Guardar un NUEVO archivo, no sobrescribir auditorías anteriores:

`ai-council/IQG-001/reports/YYYY-MM-DD_HHMM_deepseek_reaudit.md`

Debe contener:

1. Resumen ejecutivo.
2. Estado de cada P0/P1 anterior: CERRADO / PARCIAL / ABIERTO / NO VERIFICABLE.
3. Nuevos hallazgos P0/P1/P2/P3.
4. Matriz de aislamiento RLS/ACL.
5. Revisión de anonimización.
6. Revisión RBAC/dominios/idempotencia.
7. Revisión fiscal completa.
8. Concurrencia.
9. Limitaciones de PostgreSQL 16.
10. Condiciones de release.
11. Nivel de confianza.
12. Veredicto final en la ÚLTIMA LÍNEA, exactamente uno de:

`GO`
`GO WITH CONDITIONS`
`NO-GO`

No aceptar como evidencia una afirmación de Codex sin verificarla contra el DDL o una ejecución real.

GO WITH CONDITIONS