# ADR-0003 — Alcance de anonimización operativa y retención

**Estado:** Aceptado para IQG-001.2; ampliaciones de usuario/empresa diferidas
**Fecha:** 2026-09-11
**Decisores:** IQ GROWTH Architecture / Codex

## Contexto

`iqg_core.cliente` ya tiene un flujo específico de anonimización: exige
membresía y permiso, registra una solicitud append-only, bloquea documentos
fiscales aún pendientes, limpia sobres operativos y sus referencias de clave,
desactiva el cliente y redacta únicamente las claves PII de snapshots de la
auditoría operativa. La capa fiscal no se borra ni se redacta.

`iqg_core.usuario` y `iqg_core.empresa` también contienen PII cifrada, pero no
existe todavía una política universal aprobada de retención, cierre,
suspensión, identidad laboral, custodia de claves y conservación fiscal para
esas entidades.

## Decisión

1. El alcance implementado y verificable de IQG-001.2 es la anonimización de
   `cliente` en la capa operativa privada.
2. La anonimización de cliente no elimina hechos operativos, UUIDs técnicos,
   solicitudes, auditoría no PII, factura, XML, outbox ni evidencia fiscal.
3. `usuario` no se anonimiza automáticamente en este ticket. Requiere una
   solicitud append-only propia, una transición de desactivación de
   membresías, reglas de permisos, redacción de auditoría y una decisión de
   retención laboral/contractual antes de retirar sus sobres.
4. `empresa` no se anonimiza en este ticket. Requiere una ADR de cierre de
   tenant que separe datos privados eliminables de identidad legal, régimen,
   retención y evidencia fiscal que deba conservarse.
5. No se implementa `DELETE` destructivo para aparentar cumplimiento. Toda
   extensión debe preservar relaciones históricas y distinguir anonimización
   operativa de retención legal/fiscal.

## Consecuencias

- C4 se puede validar para cliente sin afirmar cobertura universal de todas
  las categorías de PII.
- Las ampliaciones a usuario y empresa quedan como trabajo explícito, no como
  comportamiento implícito o borrado accidental.
- El arnés debe probar la ruta de cliente, su idempotencia, la redacción de
  auditoría operativa y la conservación intacta de la capa fiscal.
