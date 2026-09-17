# IQG-001 — DECISIONS

## 2026-09-10 — Constitución del proyecto
**DECISIÓN CEO:** IQ GROWTH se rige por cinco principios: Universalidad, Aislamiento Total, Historia Sagrada, Arquitectura Evolutiva y Valor antes que Funciones.

**EVIDENCIA:** `docs/MASTER_CONTEXT.md`.

---

## 2026-09-11 — Continuidad de IQG-001.2
**DECISIÓN CEO:** IQG-001.2 está aprobado para continuar a reauditoría independiente de DeepSeek sobre el commit `d564812dd3583e837b838654f14d6159c8a53d87`.

**CONDICIÓN:** el cierre requiere veredicto `GO`, `GO WITH CONDITIONS` o `NO-GO` y evidencia guardada en GitHub.

---

## 2026-09-11 — Modelo operativo de Dola
**DECISIÓN CEO:** Dola debe reducir al mínimo la intervención manual de Iván y no usar al CEO como mensajero entre IAs.

Se adoptan estas reglas:
1. GitHub y los documentos canónicos son fuente de verdad operativa.
2. Toda tarea no trivial debe tener ticket/identificador.
3. Las IAs intercambian artefactos e informes, no conversaciones transportadas por Iván.
4. Dola debe reconstruir contexto antes de actuar y no depender exclusivamente de memoria conversacional.
5. Dola debe derivar el siguiente paso cuando el workflow ya lo determina.
6. Objetivo de `CEO Action Count`: 0 por defecto; 1 solo cuando exista decisión material real.
7. No ampliar acceso o exposición de repositorios si existe una alternativa de mínimo privilegio.

## Regla
Las decisiones nuevas se agregan; no se reescriben retrospectivamente decisiones históricas.

---

## 2026-09-16 — Bootstrap privilegiado de infraestructura PostgreSQL 16
**DECISIÓN CEO:** Se autoriza una frontera explícita de
`PRIVILEGED_BOOTSTRAP_PRINCIPAL` para el bootstrap inicial de infraestructura
PostgreSQL 16. La solución se divide físicamente en Phase 0 (roles), Phase 1
(instalación inicial del Core bajo ownership controlado) y Phase 2 (runtime
normal).

**INVARIANTES NO NEGOCIABLES:** `iqg_owner` termina `NOLOGIN`, `NOSUPERUSER`,
`NOCREATEDB`, `NOCREATEROLE`, `NOREPLICATION`, `NOBYPASSRLS`, `NOINHERIT` y
con `ZERO MEMBERS`. `iqg_app`, `iqg_gateway` e `iqg_bootstrap_invoker` jamás
reciben `iqg_owner`, `SUPERUSER` ni `BYPASSRLS`. No se abren schemas a
`PUBLIC`, no se agregan grants amplios y el principal privilegiado no se
reutiliza en runtime.

**CAPACIDAD, NO NOMBRE:** el arnés PostgreSQL 16 puede usar el `postgres`
efímero del contenedor como principal de infraestructura. Producción debe
demostrar las capacidades requeridas sin depender de ese nombre ni de que un
rol IQG tenga superuser. En PostgreSQL 16, esas capacidades pueden ser
superuser-equivalentes según el proveedor por los locks de catálogos y la
transferencia de ownership. Si un proveedor no puede preservar los invariantes,
el despliegue falla `DEPLOYMENT_CAPABILITY_INCOMPATIBLE`.

**RELACIÓN CON ADR-0001:** esta decisión no modifica la capacidad operacional
`iqg_bootstrap_invoker` ni su contrato de provisioning. Esa capacidad pertenece
al runtime controlado y no es el principal de infraestructura de Phase 0.

**EVIDENCIA REQUERIDA ANTES DE CIERRE:** matriz A–W y BOOT-01 a BOOT-10 en
PostgreSQL 16 real/efímero, incluyendo fallo cerrado, rollback, reejecución y
dump/restore. Esta decisión autoriza la implementación; no declara IQG-001.2
ni producción aprobados.
