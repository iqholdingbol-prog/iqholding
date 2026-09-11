# IQG-001 — FUNDACIÓN DEL NÚCLEO UNIVERSAL

## Objetivo
Definir y validar la base técnica universal de IQ GROWTH respetando aislamiento total, trazabilidad temporal, evolución controlada y separación entre núcleo y verticales.

## Subticket activo
`IQG-001.2` — Seguridad, integridad, RLS, ACL, anonimización y separación fiscal.

## Artefacto actual
- Commit objetivo: `d564812dd3583e837b838654f14d6159c8a53d87`
- Esquema: `schemas/core_schema.sql`

## Alcance de IQG-001.2
- aislamiento RLS por empresa/sucursal;
- contexto de ejecución confiable;
- ACL y ownership de `iqg_owner`, `iqg_app`, `iqg_gateway`;
- anonimización y redacción trazable;
- RBAC, dominios e idempotencia;
- separación `iqg_core` / `iqg_fiscal`;
- snapshots y totales fiscales;
- bloqueo de configuración fiscal;
- concurrencia y locks;
- preparación para validación real en PostgreSQL 16.

## Criterios de aceptación
1. Reauditoría independiente completa.
2. Sin P0 abiertos.
3. P1 cerrados o expresamente aceptados por el CEO con mitigación.
4. Veredicto explícito: `GO`, `GO WITH CONDITIONS` o `NO-GO`.
5. Informe de auditoría guardado como archivo nuevo e inmutable.
6. Antes de producción: ejecución real y matriz de integración en PostgreSQL 16.

## Fuera de alcance inmediato
- desplegar producción;
- migrar datos reales V11;
- abrir acceso directo de aplicación a tablas;
- construir agentes autónomos;
- desarrollar verticales Café/Chocolate.

## Regla de gobierno
ChatGPT integra. Dola controla estado y handoffs. Codex implementa. DeepSeek audita seguridad. Claude desafía producto/sistema. Iván decide cambios materiales.