# IQ GROWTH — Bolivia Compliance Source Registry

**Jurisdicción:** BO — Estado Plurinacional de Bolivia  
**Estado:** registro canónico de fuentes; NO es asesoría jurídica ni Compliance Pack ejecutable  
**Fecha de corte inicial:** 2026-09-12

## Principio

Este archivo registra fuentes candidatas y verificadas para construir posteriormente reglas jurisdiccionales de IQ GROWTH.

Una fuente `VERIFIED_PRIMARY` confirma procedencia oficial; **no significa que IQ GROWTH pueda interpretar automáticamente todos sus efectos jurídicos**.

Estados:

- `VERIFIED_PRIMARY` — fuente primaria oficial verificada.
- `VERIFIED_OFFICIAL_OPERATIONAL` — instrucción/trámite oficial vigente de autoridad competente.
- `PRIMARY_REVIEW_REQUIRED` — existe marco oficial, pero falta revisión artículo por artículo/versión consolidada.
- `LEGISLATIVE_STATUS_UNRESOLVED` — existen antecedentes/proyectos oficiales y debe determinarse su estado jurídico exacto antes de usar reglas.
- `CANDIDATE` — pendiente de verificación primaria.

---

## BO-SRC-001 — Constitución Política del Estado

**Estado:** `VERIFIED_PRIMARY`  
**Autoridad/fuente:** Gaceta Oficial del Estado Plurinacional de Bolivia  
**Publicación:** 2009-02-07  
**Dominios IQG:** privacidad, intimidad, garantías, derechos fundamentales, protección de privacidad  
**Uso permitido ahora:** piso constitucional y source map  
**Uso NO permitido ahora:** convertir automáticamente una garantía constitucional en procedimiento operativo sin revisión del marco aplicable.

---

## BO-SRC-002 — Código de Comercio — Decreto Ley N° 14379

**Estado:** `VERIFIED_PRIMARY`  
**Autoridad/fuente:** Gaceta Oficial del Estado Plurinacional de Bolivia  
**Fecha norma:** 1977-02-25  
**Dominios IQG:** sociedades comerciales, S.R.L., cuotas, gobierno societario, actos mercantiles  
**Nota:** SEPREC remite actualmente a este Código para trámites societarios.

---

## BO-SRC-003 — SEPREC Trámite 17: Transferencia de Cuotas de Capital de S.R.L.

**Estado:** `VERIFIED_OFFICIAL_OPERATIONAL`  
**Autoridad:** Servicio Plurinacional de Registro de Comercio — SEPREC  
**Dominios IQG:** transferencia de cuotas / evidencia societaria  
**Marco legal publicado por SEPREC:** Código de Comercio, artículos 204.6, 209, 212, 214 y 215  
**Requisitos relevantes publicados:** testimonio de escritura pública de transferencia, aprobación por Asamblea de Socios, registro/publicación y demás requisitos aplicables.

**Invariante derivado permitido:** IQ GROWTH no debe inferir una transferencia formal de cuotas desde un préstamo, trabajo, parentesco o movimiento informal de dinero.

---

## BO-SRC-004 — Código Tributario Boliviano — Ley N° 2492

**Estado:** `VERIFIED_PRIMARY`  
**Autoridad/fuente:** Servicio de Impuestos Nacionales — SIN  
**Dominios IQG:** obligaciones tributarias, registros, respaldo documental, facturación, deberes formales  
**Fuente de mantenimiento:** Compendio Tributario Actualizado del SIN.

---

## BO-SRC-005 — Ley N° 843 y normativa tributaria consolidada

**Estado:** `VERIFIED_PRIMARY` para presencia en compendio oficial; `PRIMARY_REVIEW_REQUIRED` para reglas operativas concretas  
**Autoridad/fuente:** SIN  
**Fecha de corte oficial observada:** Compendio actualizado al 31-08-2026  
**Dominios IQG:** IVA, IT, IUE y demás reglas tributarias aplicables según actividad/régimen.

**Regla:** ninguna fórmula fiscal de IQ GROWTH debe derivarse de una copia histórica cuando exista compendio/RND más reciente.

---

## BO-SRC-006 — Ley N° 453 de Derechos de Usuarios y Consumidores

**Estado:** `VERIFIED_PRIMARY`  
**Autoridad/fuente:** Gaceta Oficial del Estado Plurinacional de Bolivia  
**Fecha:** 2013-12-04  
**Dominios IQG:** consumidor, información, publicidad, condiciones comerciales, reclamos  
**Revisión profesional:** requerida antes de convertir artículos en controles contractuales/marketing automatizados.

---

## BO-SRC-007 — Marco laboral: Ley General del Trabajo + normativa complementaria

**Estado:** `PRIMARY_REVIEW_REQUIRED`  
**Autoridad/fuente:** Gaceta Oficial / Ministerio de Trabajo según norma  
**Dominios IQG:** relación laboral, salario, beneficios, condiciones, terminación, documentación  
**Evidencia actual:** Gaceta mantiene normativa reciente que remite expresamente a la Ley General del Trabajo y derechos laborales adquiridos.

**Regla:** no construir el pack laboral desde una única versión histórica de la LGT; debe incluir reglamentación/modificaciones vigentes y revisión profesional.

---

## BO-SRC-008 — Protección general de datos personales

**Estado:** `LEGISLATIVE_STATUS_UNRESOLVED`  
**Evidencia oficial observada:**

1. `PL-605/2024-2025` — texto titulado “Ley de Protección de Datos Personales”; el documento legislativo indica que la Asamblea sancionó el texto.
2. `PL-538/2025-2026` — “Proyecto de Ley Protección de Datos Personales”, listado por Cámara de Diputados en 2026 como `Proyecto de Ley en Tratamiento`.
3. En la verificación de 2026-09-12 no se identificó de forma inequívoca una publicación en Gaceta con número de Ley promulgada que permita cerrar el estado jurídico de esos proyectos.

**Regla de producto:**

`NO AUTOMATION FROM GENERAL DATA LAW UNTIL STATUS VERIFIED`

Mientras tanto pueden usarse como fuentes verificadas las garantías constitucionales y normas sectoriales que correspondan.

**Requiere:** abogado boliviano + búsqueda final en Gaceta/Asamblea antes de cualquier regla productiva.

---

## BO-SRC-009 — Ley N° 164 / documento y firma digital

**Estado:** `PRIMARY_REVIEW_REQUIRED`  
**Dominio IQG:** documento digital, firma digital, comunicaciones electrónicas  
**Acción pendiente:** recuperar y verificar publicación primaria y reglamentación aplicable antes de modelar efectos probatorios o contractuales.

---

## BO-SRC-010 — Código Civil / Código Procesal Civil

**Estado:** `CANDIDATE` para el Compliance Pack hasta revisión primaria específica  
**Dominios IQG:** contratos, obligaciones, evidencia/procedimiento  
**Regla:** IQ GROWTH no atribuirá valor probatorio definitivo a sus logs solo por almacenar hash/timestamp; la diferencia entre `EVIDENCE_OF_SYSTEM_EVENT` y `PROOF_OF_LEGAL_TRUTH` se mantiene.

---

# Fuentes dinámicas a vigilar

Prioridad alta de seguimiento:

1. SIN — Compendio Tributario, RND, facturación y regímenes.
2. SEPREC — procedimientos y requisitos registrales.
3. Ministerio de Trabajo / Gaceta — salario, planillas, normativa laboral y reglamentaria.
4. Asamblea Legislativa / Gaceta — estado de protección de datos y normas digitales.
5. Autoridades sectoriales cuando IQ GROWTH incorpore funciones reguladas.

# Gate de activación de una regla BO

`CANDIDATE_SOURCE`
→ `PRIMARY_SOURCE_VERIFIED`
→ `LEGAL/ACCOUNTING REVIEW WHEN MATERIAL`
→ `RULE_VERSION_CREATED`
→ `TEST CASES`
→ `APPROVED`
→ `ACTIVE`

Si la fuente está pendiente, contradicha, caducada o su estado jurídico no está resuelto:

`BLOCK_AND_ESCALATE`

No usar inferencia de IA para promoverla a `ACTIVE`.

**CEO_ACTION_REQUIRED:** false.
