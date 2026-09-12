# Claude — Legal-Risk Challenge IQG-110 / IQG-120 / IQG-121

**Fecha:** 2026-09-11  
**Origen:** respuesta externa de Claude al segundo challenge jurídico  
**Estado:** evidencia de challenger; no canónica por sí sola

## Veredicto Claude

**LEGAL-RISK ARCHITECTURE NEEDS REFINEMENT**

## Hallazgos centrales

Claude reaudita sus propias recomendaciones previas y retira dos de ellas:

- `propietario_economico`: **REJECT**. El software no debe adjudicar propiedad; debe registrar fuentes, declaraciones, acuerdos, reclamaciones, controversias y resoluciones provenientes de autoridad competente.
- clasificación obligatoria de dinero al ingreso: **REJECT**. Se sustituye por `PENDING_CLASSIFICATION`, preservando primero el hecho económico y dejando la calificación para un actor autorizado con evidencia y trazabilidad.

También modifica:

- gasto personal: no puede convertirse unilateralmente en deuda; registrar hecho y requerir reconocimiento/decisión antes de crear cuenta por cobrar;
- aporte de trabajo: alto riesgo jurídico y dependiente de jurisdicción;
- cuenta corriente: cualquier saldo consolidado debe marcarse como inferencia del sistema, no como deuda jurídicamente exigible.

## Estados epistemológicos adicionales propuestos

- `SYSTEM_INFERRED`
- `THIRD_PARTY_ATTESTED`
- `VERIFICATION_EXPIRED`
- `UNVERIFIABLE`
- `WITHDRAWN`
- `CONTRADICTED`

Claude destaca que son afirmaciones diferentes:

1. existe un documento;
2. el documento dice X;
3. X produce efecto jurídico.

IQ GROWTH no debe inferir automáticamente la tercera a partir de la primera.

## No adjudicación y disputas

Claude recomienda:

- congelación quirúrgica, nunca paralizar operación corriente innecesariamente;
- autoridad para abrir controversia y mecanismo antiabuso;
- notificación a partes afectadas;
- separación de funciones entre apertura y cierre;
- estados intermedios cuando una decisión todavía no sea firme;
- detección automática de contradicciones entre fuentes;
- `DISPUTE` + `LEGAL HOLD` con preservación versionada.

## Compliance Pack

Campos adicionales propuestos:

- `verification_status`
- `verified_by`
- `next_review_date`
- `source_tier`
- `supersedes`
- `superseded_by`
- `scope_limitations`
- `applies_to_operations_dated_from/to`

Cada operación debe sellar `rule_version_applied`. Una reevaluación posterior crea una nueva evaluación; nunca reescribe la original.

## IA

Claude propone cuatro niveles:

A. automático: detectar contradicciones, verificaciones caducadas, pendientes, cálculos explícitamente inferidos;
B. recomendación con aprobación: clasificación, promociones/precios y acciones operativas no jurídicas;
C. revisión profesional: laboral, societario, tributario, contractual, sucesorio y datos personales cuando exista impacto material;
D. nunca autónomo: despidos/sanciones, salarios, equity, distribuciones, propiedad, movimientos de dinero, eliminación de evidencia, cierre de disputas, conclusiones jurídicas, reglas no verificadas.

## Observaciones de ChatGPT previas a canonización

No se adoptan literalmente dos absolutos de Claude:

1. `no existe ninguna ruta de borrado físico`: debe reemplazarse por borrado controlado cuando jurídicamente proceda, bloqueado por legal hold/retención válida y siempre auditado;
2. `ante incertidumbre conservar`: solo se acepta como preservación temporal bajo revisión, nunca como retención indefinida por defecto.

Las reglas jurídicas específicas siguen siendo `JURISDICTION_DEPENDENT` y deben validarse con fuente oficial y/o profesional competente.

**CEO_ACTION_REQUIRED:** false.
