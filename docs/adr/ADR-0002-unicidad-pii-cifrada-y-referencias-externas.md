# ADR-0002 — Unicidad de PII cifrada y referencias externas

**Estado:** Aceptado para IQG-001.2
**Fecha:** 2026-09-11
**Decisores:** IQ GROWTH Architecture / Codex

## Contexto

El núcleo guarda datos personales como sobres AES-256-GCM emitidos fuera de
PostgreSQL. Los ciphertext no son una representación canónica del texto
original: un valor igual puede producir sobres distintos. Las columnas
`referencia_clave_*_externa` identifican la clave, sobre o custodio
criptográfico; no representan el identificador de negocio de una operación.

El esquema sí tiene invariantes técnicos ya definidos: claves de idempotencia
por tenant/sucursal para operaciones, pagos y movimientos; una factura por
operación; una línea fiscal por línea operativa; una versión XML por factura; y
un evento de outbox por factura/tipo.

## Decisión

1. No crear `UNIQUE` sobre ciphertext de identificador fiscal, identidad de
   usuario, correo ni PII de cliente.
2. No crear `UNIQUE` sobre `referencia_clave_operativa_externa`,
   `referencia_clave_externa` ni `referencia_clave_fiscal_externa`. Una clave o
   referencia de custodio puede proteger más de un registro legítimamente.
3. Mantener las unicidades técnicas existentes de idempotencia, factura,
   líneas fiscales, XML y outbox.
4. Si un proveedor externo requiere deduplicación, se diseñará un nuevo campo
   técnico opaco con fuente y alcance explícitos. No se reutilizará una
   referencia criptográfica para ese propósito.
5. Si un requisito real exige búsqueda o unicidad de PII, se abrirá una ADR
   específica antes de implementar un blind index/HMAC.

## Requisitos de una ADR posterior de blind index/HMAC

La ADR posterior debe definir como mínimo:

1. Invariante de negocio y alcance exacto: global, empresa, sucursal, país,
   proveedor, emisor o comercio.
2. Normalización canónica previa a tokenizar.
3. Algoritmo de token/HMAC y custodio de la clave fuera de PostgreSQL.
4. Rotación, reindexación, colisiones, observabilidad y control de acceso.
5. Efecto sobre anonimización, derecho de supresión, retención y auditoría.
6. Constraint tenant-aware y migración reversible de datos existentes.

## Consecuencias

- No se filtra igualdad de PII por convertir el cifrado en determinista.
- Se evita bloquear usos legítimos de claves de cifrado compartidas o rotadas.
- La duplicación de un proveedor se resuelve con una identidad técnica de
  proveedor, no por el ciphertext ni por la referencia de clave.
- El arnés inspecciona que no aparezca una unicidad impropia por ciphertext y
  prueba los invariantes de idempotencia ya declarados.
