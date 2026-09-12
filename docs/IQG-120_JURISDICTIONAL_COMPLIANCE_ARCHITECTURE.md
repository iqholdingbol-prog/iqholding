# IQG-120 — Jurisdictional Compliance Architecture

**Proyecto:** IQ GROWTH  
**Estado:** diseño canónico transversal previo a implementación  
**Fecha:** 2026-09-11  
**Autoridad:** Iván Quea — CEO / Product Owner  
**Arquitectura y síntesis:** ChatGPT  
**Implementación futura:** Codex  
**Auditoría futura:** DeepSeek  
**Evidencia jurídica por país:** fuentes oficiales + revisión profesional cuando corresponda

---

## 1. Propósito

IQ GROWTH debe poder operar en distintos países sin asumir que una misma regla societaria, laboral, tributaria, de privacidad, consumo, familia o procedimiento es válida en todas las jurisdicciones.

Principio central:

> **CORE UNIVERSAL + CAPA DE CUMPLIMIENTO POR JURISDICCIÓN + EVIDENCIA LEGAL VERSIONADA**

El Core modela hechos y relaciones universales. La capa jurisdiccional determina qué requisitos, restricciones, documentos, derechos, consentimientos, autorizaciones y obligaciones aplican en un país, región, sector y fecha determinados.

IQ GROWTH no sustituye a abogado, contador, autoridad pública ni juez. Debe ayudar a cumplir, conservar evidencia, impedir automatizaciones peligrosas y señalar cuándo una decisión requiere validación profesional.

---

## 2. Regla de aplicabilidad

Toda regla jurídica específica debe poder evaluarse al menos por:

- país;
- estado/departamento/provincia/municipio cuando corresponda;
- fecha de vigencia;
- forma jurídica de la empresa;
- actividad económica/sector;
- régimen tributario;
- tipo de relación: laboral, societaria, contractual, financiera, consumidor, datos, etc.;
- condición de la persona: natural/jurídica, trabajador, socio, cliente, proveedor, representante, menor cuando legalmente corresponda;
- evento jurídico u operativo relevante.

Nunca usar `country = X` como única condición si la norma exige más contexto.

---

## 3. Jerarquía de fuentes

El registro de cumplimiento debe distinguir fuentes como:

1. Constitución / norma fundamental.
2. Ley / código.
3. Decreto o reglamento.
4. Resolución de autoridad competente.
5. Norma sectorial.
6. Jurisprudencia o precedente relevante cuando tenga efecto jurídico aplicable.
7. Estatuto, escritura, contrato, convenio o acuerdo válido de la empresa.
8. Política interna, únicamente cuando no contradiga normas superiores.

Cada regla debe conservar:

- `legal_rule_id`;
- jurisdicción;
- dominio jurídico;
- autoridad emisora;
- tipo de fuente;
- identificador oficial de la norma;
- artículo/sección cuando corresponda;
- enlace/fuente oficial;
- fecha_publicación;
- `effective_from`;
- `effective_to` cuando exista;
- versión;
- estado: VIGENTE / DEROGADA / SUSPENDIDA / PENDIENTE_DE_VERIFICAR;
- texto resumido operativo;
- condición de aplicabilidad;
- efecto esperado en el sistema;
- evidencia requerida;
- fecha de última verificación;
- responsable/revisor;
- notas y excepciones.

No guardar una regla legal como texto suelto sin procedencia ni vigencia.

---

## 4. Historia legal sagrada

Una modificación normativa no debe reescribir retrospectivamente lo que era válido en una fecha anterior.

Ejemplo:

`NORMA A: vigente 2026-01-01 → 2026-12-31`

`NORMA B: vigente desde 2027-01-01`

Una operación de 2026 debe evaluarse con la regla vigente en 2026, salvo norma retroactiva válida que haya sido expresamente verificada.

La arquitectura debe preservar:

- regla aplicada;
- versión de regla;
- fecha de evaluación;
- evidencia disponible en ese momento;
- posteriores correcciones o reinterpretaciones como eventos nuevos.

---

## 5. Piso de protección de la persona

Además de cumplir la ley local, IQ GROWTH adopta como política de producto un piso de seguridad y dignidad que no debe relajarse por relaciones familiares o jerárquicas.

### 5.1 Persona antes que parentesco

Ser padre, madre, hijo, hermano, pareja, cónyuge, conviviente u otro familiar no crea ni elimina automáticamente derechos societarios, laborales, financieros, contractuales, de privacidad o acceso.

### 5.2 Privacidad y datos

La arquitectura debe soportar según la jurisdicción:

- finalidad y base jurídica/consentimiento cuando corresponda;
- minimización de datos;
- acceso restringido por necesidad;
- rectificación;
- oposición/eliminación cuando legalmente aplique;
- retención y eliminación programada;
- trazabilidad de accesos y cambios;
- protección de datos sensibles;
- exportación/portabilidad cuando aplique;
- respuesta a solicitudes de titulares;
- preservación obligatoria cuando exista deber legal que impida eliminar.

Una solicitud de eliminación nunca debe destruir registros que la ley obligue a conservar; debe resolverse por política jurisdiccional documentada.

### 5.3 No discriminación

El sistema no debe inferir trato económico, laboral, acceso o sanción por parentesco u otras características protegidas por la jurisdicción.

### 5.4 Revisión humana de decisiones materiales

Ningún agente IA debe ejecutar autónomamente decisiones adversas o jurídicamente materiales como:

- despido;
- reducción salarial;
- sanción laboral;
- modificación de participación societaria;
- transferencia de propiedad;
- renuncia de derechos;
- distribución de utilidades;
- otorgamiento/revocación de poderes jurídicos;
- admisión o rechazo de una obligación legal;
- decisiones crediticias reguladas cuando corresponda;
- eliminación definitiva de evidencia legal;
- discriminación o perfilado con efecto jurídico relevante.

La IA puede detectar, explicar y preparar; la decisión debe seguir el flujo humano/legal aplicable.

### 5.5 Derecho a explicación y trazabilidad

Toda recomendación de alto impacto debe conservar:

- datos utilizados;
- regla/política aplicada;
- actor que aprobó;
- motivo;
- fecha;
- versión del modelo/regla cuando corresponda;
- posibilidad de revisión/corrección.

---

## 6. Dominios jurídicos mínimos

La capa jurisdiccional debe poder incorporar packs independientes para:

### J1 — Privacidad y protección de datos
Derechos del titular, bases de tratamiento, consentimiento, seguridad, retención, transferencias y incidentes.

### J2 — Laboral
Contratación, jornada, salario, beneficios, estabilidad, seguridad ocupacional, sanciones, terminación, documentación y derechos irrenunciables cuando existan.

### J3 — Societario / corporativo
Constitución, participación, aportes, transferencias, asambleas, representación, poderes, utilidades, modificaciones y registro.

### J4 — Tributario / fiscal
Régimen, obligaciones, facturación, impuestos, retenciones, declaraciones, documentos y conservación.

### J5 — Consumidor
Información, publicidad, precios, reclamos, garantías, calidad, no discriminación y derechos del usuario/consumidor.

### J6 — Contratos / obligaciones
Consentimiento, documentos, vigencia, prestaciones, incumplimiento, garantías y terminación.

### J7 — Familia / sucesión cuando impacte la empresa
Solo cuando sea jurídicamente relevante para propiedad, representación, herencia, comunidad de bienes, tutela u otras relaciones. El parentesco por sí mismo nunca debe crear reglas financieras automáticas.

### J8 — Contabilidad / reportes
Reglas de registro, cierre, evidencia, conservación y clasificación aplicables.

### J9 — Sector regulado
Salud, finanzas, alimentos, telecomunicaciones, transporte u otros sectores con obligaciones especiales.

---

## 7. Compliance Pack por país

Cada país debe tener un paquete versionado, por ejemplo:

`compliance/BO/`

`compliance/PE/`

`compliance/CL/`

`compliance/AR/`

`compliance/US/`

etc.

Un pack NO debe ser una copia de leyes dentro del código. Debe contener reglas operativas verificadas y referencias oficiales.

Estructura conceptual:

```text
compliance/BO/
  privacy/
  labor/
  corporate/
  tax/
  consumer/
  contracts/
  family_successions/
  accounting/
  sectors/
  sources/
  CHANGELOG.md
```

Cada pack debe tener versionado y revisión periódica.

---

## 8. Bolivia como jurisdicción inicial

Bolivia será el primer pack real porque VANSAM, Café Zacarías, Chocolates La Florita e IQHOLDING operan inicialmente allí.

Fuentes iniciales verificadas que demuestran la necesidad de la capa:

- Constitución Política del Estado: protección de privacidad y posibilidad de conocer, objetar, rectificar o eliminar datos registrados por medios físicos/electrónicos cuando afecten intimidad, privacidad personal/familiar, imagen, honra o reputación.
- Ministerio de Trabajo: la relación laboral es un vínculo jurídico propio y existen derechos laborales que no deben confundirse con relación societaria o familiar.
- SEPREC / Código de Comercio: actos societarios como transferencia de cuotas en una S.R.L. tienen requisitos formales y registrales.
- Servicio de Impuestos Nacionales: las obligaciones tributarias dependen de actividad, régimen y tipo de contribuyente y la normativa se actualiza mediante leyes, decretos y resoluciones.
- Ley 453: existen derechos específicos de usuarias, usuarios, consumidoras y consumidores.

Estas referencias son punto de partida, no un pack BO completo.

---

## 9. Motor de decisión jurídica

El sistema debe distinguir cuatro resultados:

### ALLOWED
La acción está permitida bajo reglas vigentes verificadas y permisos internos.

### REQUIRES_EVIDENCE
Puede proceder solo si se adjunta/valida documento, autorización, acta, contrato, factura, consentimiento u otra evidencia.

### REQUIRES_HUMAN_LEGAL_REVIEW
La regla es ambigua, de alto impacto, depende de interpretación profesional o existe conflicto entre fuentes.

### BLOCKED
Una regla verificada prohíbe la acción o faltan condiciones obligatorias no subsanables automáticamente.

La IA nunca debe convertir incertidumbre jurídica en `ALLOWED` por inferencia.

---

## 10. Conflictos de normas y ambigüedad

Cuando dos reglas aparenten conflicto:

1. no resolver mediante IA como si fuera sentencia;
2. preservar ambas fuentes;
3. aplicar jerarquía/competencia solo si está formalmente modelada y verificada;
4. marcar `REQUIRES_HUMAN_LEGAL_REVIEW` cuando persista incertidumbre;
5. registrar la decisión humana/profesional y su fundamento.

---

## 11. Cambios regulatorios

Cada pack debe soportar:

- fecha de última revisión;
- alerta de norma nueva/modificada;
- comparación de versiones;
- lista de funciones afectadas;
- estado de remediación;
- fecha límite cuando exista;
- evidencia de prueba antes de activar cambios en producción.

Una actualización legal nunca se despliega silenciosamente si modifica derechos, obligaciones o cálculos materiales.

---

## 12. Separación entre cumplimiento y asesoría jurídica

IQ GROWTH puede:

- mostrar obligaciones configuradas;
- exigir documentos;
- impedir acciones no autorizadas;
- conservar evidencia;
- alertar vencimientos;
- explicar qué regla configurada produjo un bloqueo;
- generar checklist y borradores;
- escalar a revisión profesional.

IQ GROWTH no debe presentarse como:

- abogado;
- juez;
- autoridad tributaria;
- autoridad laboral;
- notario;
- certificador automático de legalidad.

---

## 13. Relación con IQG-110

`IQG-110_UNIVERSAL_BUSINESS_RELATIONSHIPS_SPEC.md` define las relaciones universales.

IQG-120 define qué condiciones jurídicas debe cumplir cada relación según jurisdicción.

Ejemplo:

`R6 PRÉSTAMO` es universal.

Pero interés permitido, impuestos, documentación, registro, límites o tratamiento contable/fiscal dependen del pack jurisdiccional correspondiente.

`R2 PARTICIPACIÓN SOCIETARIA` es universal.

Pero forma de transferencia, aprobación, escritura, registro y efectos dependen de la forma jurídica y país.

---

## 14. Regla para IA y automatización

Toda automatización jurídica/material debe obedecer:

`HECHO VERIFICADO → REGLA VIGENTE → APLICABILIDAD → EVIDENCIA → AUTORIZACIÓN → ACCIÓN → AUDITORÍA`

Nunca:

`INFERENCIA IA → ACCIÓN JURÍDICA AUTOMÁTICA`

---

## 15. Gate de implementación

Antes de implementar un pack de país:

1. fuentes oficiales identificadas;
2. vigencia verificada;
3. reglas operativas separadas de interpretación;
4. revisión de seguridad/integridad por DeepSeek;
5. revisión jurídica profesional para dominios de alto impacto cuando corresponda;
6. pruebas con casos permitidos, bloqueados y ambiguos;
7. trazabilidad de versión;
8. plan de actualización normativa.

No pasa a Codex mientras IQG-001.2 siga consumiendo su cuota crítica.

**CEO_ACTION_REQUIRED:** false.
