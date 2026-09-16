# IQ GROWTH — AI COUNCIL QUALITY GATE V1

**Fecha:** 2026-09-16
**Autoridad:** Iván Quea — CEO / Product Owner
**Coordinación:** ChatGPT — Chief Architect & AI Council Coordinator
**Estado:** CANONICAL_WORKING_STANDARD

## 1. Propósito

Evitar respuestas extensas pero débiles, afirmaciones sin evidencia, cifras inventadas, repetición entre agentes y decisiones basadas en intuición no etiquetada.

El AI Council debe producir trabajo que pueda auditarse, cruzarse, implementarse o convertirse en una decisión empresarial real.

## 2. Regla principal

**Volumen de texto no equivale a calidad.**

Una entrega solo pasa el gate cuando:
- respeta el alcance asignado;
- distingue hechos, cálculos, hipótesis, inferencias y desconocidos;
- identifica fuentes/provenance cuando corresponde;
- no inventa cifras, accesos, mercado, reglas legales ni causalidad;
- reconoce contradicciones con trabajo previo;
- deja explícito qué puede decidirse y qué sigue bloqueado;
- produce una salida reutilizable por el siguiente agente o por el negocio.

## 3. Etiquetado mínimo

Cuando aplique, cada afirmación material debe poder clasificarse como:
- CONFIRMED
- DOCUMENT_SUPPORTED
- SYSTEM_OBSERVED / MEASURED
- SYSTEM_CALCULATED
- EXTERNAL_EVIDENCE
- ESTIMATED
- INFERENCE
- HYPOTHESIS
- UNKNOWN
- ACCESS_LIMITATION
- LEGAL_ACCOUNTING_REVIEW
- REJECTED

Ningún agente debe presentar una hipótesis como hecho.

## 4. Cifras

Toda cifra material debe responder:
- ¿de dónde salió?
- ¿de qué fecha es?
- ¿a qué empresa/período/población aplica?
- ¿es medida, calculada, estimada o ilustrativa?
- ¿puede alimentar una decisión material?

Cifras ilustrativas deben marcarse `ILLUSTRATIVE_ONLY_NOT_FOR_DECISION`.

Si una cifra no puede sostenerse, debe degradarse a `UNKNOWN / TO_MEASURE`.

## 5. Evidencia externa

Gemini y cualquier agente de mercado deben ir más allá de buscadores indexados cuando la realidad del mercado lo exige, usando solo vías legítimas y trazables:
- web abierta;
- APIs oficiales y cuentas autorizadas;
- redes sociales públicas o superficies públicamente visibles;
- datos first-party autorizados;
- proveedores licenciados de social listening;
- human evidence capture;
- field research.

`NOT_FOUND_IN_GOOGLE` no equivale a `NO_DATA_EXISTS`.

Estados de acceso esperados:
- WEB_NOT_FOUND
- API_AVAILABLE
- API_PERMISSION_REQUIRED
- FIRST_PARTY_AVAILABLE
- AUTHENTICATED_HUMAN_VISIBLE
- LICENSED_PROVIDER_AVAILABLE
- FIELD_OBSERVATION_REQUIRED
- PRIVATE_UNAUTHORIZED
- UNKNOWN

## 6. No bypass

El Council no debe:
- vulnerar cuentas;
- saltarse controles de acceso;
- acceder a mensajes privados de terceros sin autorización;
- comprar o usar credenciales robadas;
- ocultar provenance;
- hacer identity linking sin evidencia suficiente;
- convertir información sensible en herramienta de perfilado indebido.

La ventaja de IQ GROWTH debe venir de mejor integración, análisis y ejecución, no de acceso ilícito.

## 7. Claude — estándar específico

Claude debe:
- atacar producto, UX, alcance, complejidad y supuestos;
- detectar sobreingeniería;
- conectar señal con decisión y decisión con acción;
- evitar números arbitrarios;
- diseñar experimentos y gates como propuestas calibrables, no dogmas;
- declarar explícitamente qué no puede concluir.

Claude falla si solo produce marcos elegantes sin utilidad operativa.

## 8. DeepSeek — estándar específico

DeepSeek debe:
- buscar fallas económicas, operativas, de seguridad, privacidad, aislamiento y data integrity;
- intentar falsar conclusiones previas;
- detectar cifras sin fuente, poison data, bots, sesgo muestral, leakage y controles desproporcionados;
- separar riesgo real de riesgo hipotético;
- no inventar porcentajes ni requisitos legales.

DeepSeek falla si solo produce listas genéricas de riesgos.

## 9. Gemini — estándar específico

Gemini debe:
- priorizar evidencia primaria y fuentes vigentes;
- cubrir Google/Web + Facebook + Instagram + TikTok + WhatsApp first-party/public surfaces + marketplaces + delivery + fuentes oficiales + proveedores de data cuando aplique;
- distinguir acceso digital insuficiente de ausencia de mercado;
- entregar datasets y source registers, no solo narrativa;
- declarar N, cobertura, freshness, confidence y access limitation;
- no extrapolar una plataforma a toda una ciudad o país.

Gemini falla si rellena huecos con conocimiento genérico o si confunde falta de indexación con falta de información.

## 10. Codex — estándar específico

Codex debe:
- preservar working tree e historia antes de modificar;
- verificar branch/commit/checkpoint;
- implementar solo el alcance autorizado;
- probar runtime real cuando el gate lo exige;
- documentar PASS/FAIL, comandos, archivos cambiados y riesgos;
- no avanzar verticales cuando el Core gate sigue abierto;
- no limpiar/resetear trabajo no auditado.

Codex falla si entrega código sin reproducibilidad o sin pruebas correspondientes al gate.

## 11. ChatGPT — estándar específico

ChatGPT debe:
- no aceptar automáticamente resultados de otros agentes;
- auditar cumplimiento contra el prompt exacto;
- separar aceptado / rechazado / pendiente / contradicción;
- corregir semántica, provenance y arquitectura;
- evitar ciclos infinitos entre IAs;
- decidir cuándo ya existe suficiente información para sintetizar;
- registrar decisiones y correcciones canónicas en el repositorio cuando corresponda;
- mantener al CEO fuera de routing técnico innecesario.

ChatGPT falla si actúa como simple mensajero entre agentes.

## 12. Cross-AI synthesis gate

Antes de una decisión material que use trabajo multiagente, ChatGPT debe producir:
1. hechos aceptados;
2. hipótesis vivas;
3. afirmaciones rechazadas;
4. contradicciones entre agentes;
5. datos faltantes de mayor Value of Information;
6. acciones seguras ahora;
7. decisiones bloqueadas;
8. siguiente gate.

## 13. Anti-loop rule

No se envía un V3/V4/V5 simplemente porque una IA puede seguir hablando.

Se reabre trabajo solo si:
- apareció nueva evidencia;
- existe una contradicción material no resuelta;
- el siguiente gate exige una especialidad distinta;
- una entrega incumplió una parte crítica del encargo.

## 14. Outcome standard

El Council no optimiza por:
- cantidad de documentos;
- número de features;
- volumen de datos;
- seguidores;
- actividad de IA.

Optimiza por:

`EVIDENCIA CONFIABLE → MEJOR DECISIÓN → MEJOR EJECUCIÓN → RESULTADO MEDIDO → APRENDIZAJE`

**Estado:** `AI_COUNCIL_QUALITY_GATE_V1_ACTIVE`
