# IQG-120 — Síntesis crítica del Source Map Bolivia de Gemini

**Fecha:** 2026-09-12  
**Rol:** ChatGPT — Chief Architect / integración del AI Council  
**Entrada:** `2026-09-12_gemini_bolivia_source_map.md`

## 1. Veredicto

El informe de Gemini es **útil como índice de investigación**, pero **NO constituye todavía un Compliance Pack verificable ni una base suficiente para automatizar decisiones jurídicas**.

Estado adoptado:

`SOURCE_MAP_USABLE_AS_RESEARCH_INDEX / PROFESSIONAL_AND_PRIMARY_SOURCE_VERIFICATION_REQUIRED`

## 2. Problema principal de calidad de fuente

Gemini etiquetó varias entradas como `VERIFIED_PRIMARY_SOURCE`, pero el propio informe mezcla o menciona fuentes no primarias o indirectas como LexiVox, FAOLEX, Scribd y páginas institucionales que no son necesariamente la publicación oficial de la norma.

Regla canónica:

> Una entrada no puede ser `VERIFIED_PRIMARY_SOURCE` por el solo hecho de que el texto o una copia de la norma exista en Internet. Debe apuntar a la publicación/autoridad oficial apropiada y conservar procedencia verificable.

Por tanto, las etiquetas de verificación del informe Gemini se consideran **provisionales** hasta revalidación individual.

## 3. Verificaciones externas realizadas por ChatGPT

### 3.1 Constitución Política del Estado

Confirmada en la Gaceta Oficial del Estado Plurinacional de Bolivia como Constitución Política de 2009. Es fuente primaria apropiada para el piso constitucional de privacidad, intimidad y garantías.

### 3.2 Código de Comercio — Decreto Ley N° 14379

Confirmado en Gaceta Oficial. Para S.R.L., SEPREC además publica el trámite actual de transferencia de cuotas de capital y remite a los artículos 204.6, 209, 212, 214 y 215 del Código de Comercio.

El trámite SEPREC vigente exige, entre otros requisitos, testimonio de escritura pública de transferencia y aprobación de la Asamblea de Socios. Esto respalda nuestra regla arquitectónica de que una transferencia societaria formal no debe inferirse desde un simple movimiento de dinero o acuerdo informal.

### 3.3 Código Tributario y normativa fiscal

El Servicio de Impuestos Nacionales mantiene un `Compendio Tributario Actualizado` con textos actualizados al **31-08-2026**, incluyendo Ley 843, Ley 2492 y tomos específicos de facturación electrónica, padrón y regímenes especiales.

Esto implica que el Compliance Pack BO fiscal debe versionarse contra el compendio/RND vigentes y no contra una copia estática antigua.

### 3.4 Ley N° 453 — consumidores

Confirmada en Gaceta Oficial: Ley N° 453, de 4 de diciembre de 2013, Ley General de los Derechos de las Usuarias y los Usuarios y de las Consumidoras y los Consumidores.

### 3.5 Marco laboral

La Gaceta Oficial mantiene normativa reciente que remite expresamente a la Ley General del Trabajo, incluyendo normativa de derechos laborales adquiridos y disposiciones reglamentarias. El dominio laboral requiere validación profesional y seguimiento de normativa complementaria; no basta con citar la LGT de forma aislada.

## 4. Corrección crítica — protección de datos personales

Gemini afirmó categóricamente que Bolivia carece de una Ley General de Protección de Datos Personales.

No canonizamos esa frase en términos absolutos.

La evidencia oficial actual encontrada muestra:

- un texto `PL-605/2024-2025` titulado **Ley de Protección de Datos Personales**, cuyo documento legislativo dice que la Asamblea lo sancionó;
- un nuevo `PL-538/2025-2026` titulado **Proyecto de Ley Protección de Datos Personales**, que la Cámara de Diputados aún muestra en 2026 como `Proyecto de Ley en Tratamiento`;
- no se verificó en esta revisión una norma promulgada con número de Ley publicada en Gaceta que permita afirmar que existe actualmente una ley general plenamente vigente derivada de esos proyectos.

Por tanto, el estado canónico será:

`GENERAL_DATA_PROTECTION_LAW_STATUS = REQUIRES_PRIMARY_SOURCE_AND_PROFESSIONAL_VERIFICATION`

No se afirmará ni `EXISTS` ni `DOES_NOT_EXIST` automáticamente hasta completar esa verificación.

Mientras tanto, IQ GROWTH mantiene como piso verificable la Constitución y cualquier normativa sectorial aplicable.

## 5. Qué aceptamos del mapa Gemini

Se aceptan como dominios prioritarios de investigación:

- societario / S.R.L.;
- laboral;
- tributario / fiscal;
- privacidad / datos;
- consumidor;
- contratos / obligaciones;
- documento y firma electrónica;
- seguridad / evidencia digital;
- familia/sucesión solo cuando impacte una relación empresarial;
- normativa sectorial y municipal cuando materialmente corresponda.

También se acepta que SIN, SEPREC y Ministerio de Trabajo deben ser fuentes con seguimiento periódico.

## 6. Qué NO aceptamos todavía

No se canonizan sin verificación adicional:

- artículos exactos citados por Gemini cuando la fuente primaria no fue inspeccionada;
- vigencia de cada norma solo porque Gemini la marcó `Vigente`;
- afirmación de ausencia de una autoridad general de protección de datos;
- afirmación general de ausencia de obligaciones de notificación de brechas;
- afirmaciones sobre responsabilidad de IA en Bolivia;
- jurisdicción/competencia exacta de ATT, ASFI, VDDUC u otras autoridades para una función concreta de IQ GROWTH;
- validez probatoria de logs de IQ GROWTH;
- efectos jurídicos de firma/documento electrónico en un caso específico;
- tratamiento contable/fiscal de métricas internas de IQ GROWTH.

Todo eso permanece `JURISDICTION_DEPENDENT`.

## 7. Regla de construcción del Compliance Pack BO

Una regla BO solo puede pasar de `CANDIDATE` a `VERIFIED` si conserva como mínimo:

- autoridad competente;
- fuente oficial primaria;
- norma/artículo;
- fecha de publicación;
- `effective_from` / `effective_to` cuando corresponda;
- versión;
- alcance;
- limitaciones;
- verificador humano/profesional cuando la interpretación sea material;
- fecha de última revisión;
- `next_review_date`;
- hash o referencia inmutable de la fuente consultada;
- `rule_version_applied` cuando se use en una evaluación.

Si falta cualquiera de los elementos jurídicamente necesarios, el resultado no puede ser `ALLOWED` por inferencia de IA.

## 8. Priorización para revisión profesional

Primera ola recomendada para Bolivia:

1. Constitución Política del Estado — privacidad y garantías.
2. Código de Comercio + trámites SEPREC — S.R.L. y actos societarios.
3. Ley General del Trabajo + reglamentación vigente — relación laboral.
4. Ley 2492 + Ley 843 + RND/Compendio SIN actualizado — fiscal.
5. Ley 453 — consumidores y condiciones comerciales.
6. Ley 164 y normativa/reglamentos aplicables — documento/firma digital.
7. Código Civil / Código Procesal Civil — contratos y tratamiento de evidencia, bajo revisión profesional.
8. Estado legislativo real de protección de datos personales en 2026.

## 9. Decisión de producto

Este mapa **NO autoriza** a IQ GROWTH a:

- decir `cumple con la ley boliviana`;
- calcular obligaciones jurídicas definitivas;
- certificar validez de contratos;
- certificar propiedad;
- resolver relaciones laborales;
- resolver derechos societarios o sucesorios;
- tratar una regla legislativa en proyecto como norma vigente.

Sí autoriza a continuar construyendo el inventario de fuentes y el modelo de versionado de reglas.

## 10. Siguiente gate

Antes de crear reglas automáticas BO:

`SOURCE CANDIDATE → PRIMARY SOURCE VERIFICATION → PROFESSIONAL REVIEW WHEN MATERIAL → RULE VERSION → TEST CASES → ACTIVATION`

**CEO_ACTION_REQUIRED:** false.
