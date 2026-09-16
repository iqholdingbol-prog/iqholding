# IQ GROWTH — Information Advantage Doctrine V1

**Fecha:** 2026-09-16  
**Estado:** `CANONICAL_STRATEGIC_PRINCIPLE`  
**Autoridad:** Iván Quea — CEO / Product Owner

## 1. Declaración estratégica

IQ GROWTH debe evolucionar desde un sistema que organiza datos internos hacia un sistema que también construye una **ventaja informacional acumulativa** a partir de evidencia externa, first-party data y señales de mercado.

La tesis central es:

> Los negocios suelen operar con información incompleta. IQ GROWTH debe convertir señales dispersas del mercado en evidencia, hipótesis, acciones medibles y aprendizaje para ayudar a empresas a decidir mejor qué ofrecer, cómo operar y hacia dónde crecer.

La información es un activo estratégico solo cuando es verificable, atribuible, útil para decisiones y convertida en resultados observables.

## 2. Cambio de juego para el AI Council

A partir de esta doctrina, el AI Council debe trabajar bajo estas reglas:

- No limitar investigación de mercado a Google o páginas web indexadas.
- Buscar señales relevantes en Facebook, Instagram, TikTok, WhatsApp Business first-party, marketplaces, delivery apps, foros, reseñas, comentarios, catálogos visibles, fuentes licenciadas y captura humana estructurada.
- Distinguir ausencia de información en buscadores de ausencia real de información.
- Explotar al máximo cada fuente legítimamente accesible, paso a paso, usando APIs oficiales, cuentas propias/autorizadas, proveedores licenciados, observación pública y evidencia humana.
- No asumir que todo contenido subido a Internet es automáticamente público, libre de restricciones o reutilizable sin condiciones. El sistema debe registrar el modo de acceso, permisos, provenance y limitaciones de cada fuente.
- No evadir controles de acceso, no vulnerar cuentas privadas y no saltar autenticación o restricciones técnicas.
- No construir perfiles invasivos de individuos cuando el objetivo puede resolverse con señales agregadas de mercado.
- No inferir atributos sensibles de personas para decisiones comerciales.
- No unir identidades entre plataformas sin evidencia verificable o autorización.

## 3. Objetivo final

La capacidad no busca recolectar datos por recolectarlos. Busca responder con evidencia preguntas como:

- ¿Qué quiere la gente realmente?
- ¿Qué busca y no encuentra?
- ¿Qué precio cuestiona?
- ¿Qué producto prefiere?
- ¿Qué frustraciones repite?
- ¿Qué servicio espera?
- ¿Qué categorías están emergiendo?
- ¿Qué necesidades cambian por ciudad, canal, horario o segmento observable?
- ¿Qué competidor resuelve mejor una fricción concreta?
- ¿Qué acción puede ejecutar una empresa hoy para mejorar?
- ¿Qué resultado produjo esa acción?

La salida no debe ser una predicción absoluta. Debe ser una **estimación basada en señales**, con incertidumbre explícita, que se valida contra comportamiento real.

## 4. Invariante epistemológica

IQ GROWTH debe mantener separadas:

`OBSERVATION != SIGNAL != HYPOTHESIS != PREDICTION != ACTION != RESULT`

Ejemplo:

- comentario: “¿hacen delivery?” = `OBSERVATION`;
- clasificación: `DELIVERY_DEMAND` = `SIGNAL`;
- repetición multi-fuente = posible `HYPOTHESIS` de demanda no cubierta;
- estimación de comportamiento futuro = `PREDICTION` con confianza;
- habilitar una prueba de delivery = `ACTION`;
- ventas, margen y satisfacción observados = `RESULT`;
- comparación hipótesis vs resultado = `LEARNING`.

Nunca convertir una señal individual en una afirmación sobre todo el mercado.

## 5. Market Memory

IQ GROWTH debe desarrollar conceptualmente un `MARKET_MEMORY` acumulativo que conserve aprendizaje útil sobre:

- necesidades;
- fricciones;
- intención;
- productos;
- precios;
- disponibilidad;
- compatibilidad;
- canales;
- horarios;
- ciudades/zonas;
- satisfacción/quejas;
- respuesta a acciones;
- cambios temporales.

El Market Memory no debe ser una base de espionaje individual. Su foco primario es comprender patrones, necesidades y comportamiento de mercado útiles para crecimiento empresarial.

## 6. Fuente universal y contrato de evidencia

Todas las fuentes deben mapearse a un contrato común:

```text
SOURCE
→ RAW OBSERVATION
→ ACCESS / PERMISSION CLASS
→ PROVENANCE
→ NORMALIZATION
→ ENTITY / PRODUCT / NEED MATCH
→ AI CLASSIFICATION
→ SIGNAL
→ AGGREGATION
→ HYPOTHESIS / PREDICTION
→ ACTION
→ RESULT
→ LEARNING
```

El Core universal no debe hardcodear Facebook, TikTok, Instagram o WhatsApp. Cada plataforma es un `SOURCE_ADAPTER` que entrega evidencia normalizada al mismo contrato universal.

## 7. Clases de acceso

Conceptualmente registrar:

- `PUBLIC_WEB`
- `PUBLIC_AUTHENTICATED`
- `FIRST_PARTY`
- `USER_AUTHORIZED`
- `CUSTOMER_INTERACTION`
- `HUMAN_OBSERVED`
- `LICENSED_PROVIDER`
- `PRIVATE_CONSENTED`
- `PRIVATE_UNAUTHORIZED` — no recolectar
- `ACCESS_LIMITATION`

Para cada observación conservar como mínimo:

- plataforma/fuente;
- URL u object reference cuando exista;
- `observed_at`;
- `collected_at`;
- modo de acceso;
- evidencia original o referencia;
- clasificador/versión cuando derive una señal;
- confidence;
- estado de vigencia/frescura;
- tenant/company ownership para first-party data.

## 8. Social signal taxonomy — primera familia conceptual

Señales potenciales, configurables y no exhaustivas:

- `PRODUCT_REQUEST`
- `PRICE_INQUIRY`
- `PRICE_SENSITIVITY`
- `DELIVERY_DEMAND`
- `CITY_DEMAND`
- `AVAILABILITY_PROBLEM`
- `HARD_TO_FIND_PRODUCT`
- `COMPATIBILITY_QUESTION`
- `QUALITY_COMPLAINT`
- `SERVICE_COMPLAINT`
- `WAIT_TIME_COMPLAINT`
- `WARRANTY_CONCERN`
- `TRUST_CONCERN`
- `PRODUCT_PREFERENCE`
- `PROMOTION_INTEREST`
- `IMPORT_REQUEST`
- `USE_CASE`
- `PURCHASE_INTENT_SIGNAL`

La taxonomía debe evolucionar con evidencia real y no convertirse en un catálogo infinito.

## 9. Predicción responsable

El objetivo futuro es anticipar necesidades y comportamiento empresarial/mercado mejor que una empresa que solo mira ventas pasadas.

Pero IQ GROWTH no debe afirmar que “sabe lo que la gente quiere” por una sola fuente.

Toda predicción debe declarar:

- población/fuente observada;
- periodo;
- cobertura;
- tamaño de muestra cuando corresponda;
- sesgos conocidos;
- plataformas incluidas/excluidas;
- confianza;
- evidencia contradictoria;
- resultado posterior para calibración.

`PREDICTION` debe mejorar con feedback real, no con confianza verbal de la IA.

## 10. Multi-source fusion

El valor surge al cruzar fuentes:

```text
SOCIAL SIGNALS
+ FIRST-PARTY CRM/WHATSAPP
+ SALES
+ INVENTORY
+ COST
+ CAPACITY
+ COMPETITOR EVIDENCE
+ LOCATION / CHANNEL
+ HUMAN FIELD EVIDENCE
→ DECISION SUPPORT
```

Una tendencia de TikTok no debe poder ordenar por sí sola una compra de inventario. Debe cruzarse con economía, operación y validación real.

## 11. Uso por laboratorios

### VANSAM

Detectar y validar:
- preferencias;
- fricciones de atención;
- tiempos;
- delivery demand;
- sensibilidad a precio;
- hero-product signals;
- horarios/ocasiones;
- competencia local visible en redes.

### Café Zacarías

Detectar y validar:
- presentaciones demandadas;
- zonas/canales;
- consumo por ocasión;
- preguntas/preferencias;
- oportunidades B2B y venta móvil.

### Chocolates

Detectar y validar:
- sabores;
- ocasiones de regalo/consumo;
- presentaciones;
- precios percibidos;
- canales y distribución.

### IPCENTER

Detectar y validar:
- productos difíciles de conseguir;
- Product Fit por uso;
- compatibilidad;
- demanda por ciudad;
- presupuesto;
- import requests;
- warranty/trust concerns;
- categorías emergentes;
- B2B procurement needs.

## 12. Restricciones inviolables

- No romper autenticación ni controles de acceso.
- No asumir que “está en Internet” significa “es público y libre de uso”.
- No acceder a mensajes privados de terceros sin autorización.
- No recolectar o inferir atributos sensibles sin una necesidad legítima y base adecuada; por defecto, no hacerlo.
- No utilizar información individual para manipular vulnerabilidades personales.
- No mezclar first-party data entre tenants/empresas.
- No permitir que datos externos no verificados se conviertan silenciosamente en hechos.
- No ocultar sesgo de plataforma o muestra.
- No permitir compras/material decisions automáticas basadas solo en social signals.

## 13. Directiva del AI Council

A partir de 2026-09-16:

**ChatGPT** debe coordinar la arquitectura de información, provenance, síntesis multi-fuente y decisión.

**Gemini** debe explorar fuentes externas, APIs, social listening, evidencias públicas y limitaciones de acceso, sin reducir “Internet” a buscadores.

**Claude** debe convertir señales en producto/UX/decisiones y desafiar acumulación inútil de datos.

**DeepSeek** debe atacar privacidad, seguridad, identidad, manipulación, bots, sesgo, poisoning y data integrity.

**Codex** implementará únicamente cuando el Core y los gates técnicos lo permitan; no debe saltar IQG-001.2 por esta doctrina.

**Iván** mantiene autoridad final sobre decisiones materiales, inversión, política y prioridades.

## 14. Criterio de éxito

IQ GROWTH tendrá ventaja informacional cuando pueda demostrar repetidamente:

`SEÑAL EXTERNA/INTERNA → HIPÓTESIS → ACCIÓN → RESULTADO ECONÓMICO/OPERATIVO → APRENDIZAJE`

con mejor precisión y velocidad que operar únicamente por intuición.

El objetivo no es acumular “toda la información de Internet”. El objetivo es construir la **mejor evidencia accesible, trazable y útil para cada decisión**, aumentar cobertura progresivamente y aprender de los resultados reales.

**Estado:** `INFORMATION_ADVANTAGE_DOCTRINE_DEFINED_V1`
