# IQG-100 — Daily Decision Engine Specification

**Proyecto:** IQ GROWTH  
**Estado:** canónico para diseño de producto; previo a implementación  
**Autoridad:** Iván Quea — CEO / Product Owner  
**Arquitectura y síntesis:** ChatGPT  
**Depende de:** `IQG-100_MVP_WEDGE_SPEC.md`, `IQG-100_VANSAM_30_DAY_PILOT.md`

---

## 1. Propósito

Definir el comportamiento mínimo del primer producto de IQ GROWTH:

> **convertir datos económicos y operativos suficientemente confiables en una sola decisión prioritaria y medible para el dueño.**

El motor no es un chatbot, un dashboard ni un sistema autónomo de gestión.

Ciclo obligatorio:

`HECHO → ESTADO ECONÓMICO → BRECHA → CANDIDATOS DE ACCIÓN → UNA NEXT_BEST_ACTION → APROBACIÓN → EJECUCIÓN → RESULTADO → APRENDIZAJE`

---

## 2. Salida diaria mínima

La primera pantalla debe responder en menos de 10 segundos:

1. **Estado:** `EN_OBJETIVO`, `BAJO_OBJETIVO` o `DATOS_INSUFICIENTES`.
2. **Margen de contribución observado/estimado** del periodo.
3. **Objetivo de cobertura** del mismo periodo.
4. **Brecha/excedente estimado**.
5. **Traducción operacional** opcional: tickets/unidades equivalentes.
6. **Una sola acción recomendada**.
7. **Razón** de la recomendación.
8. **Impacto esperado** como rango o banda, no promesa.
9. **Confianza**.
10. **Frescura de datos**.

No mostrar `ganancia neta`, `utilidad distribuible` ni causalidad absoluta sin contabilidad/evidencia suficiente.

---

## 3. Estados económicos

### EN_OBJETIVO

`margen_contribucion_periodo >= objetivo_cobertura_periodo`

Mostrar excedente sobre objetivo, pero no llamarlo utilidad neta.

### BAJO_OBJETIVO

`margen_contribucion_periodo < objetivo_cobertura_periodo`

Mostrar la brecha en Bs y, cuando sea útil, equivalentes operacionales estimados.

### DATOS_INSUFICIENTES

Se activa cuando los datos mínimos no permiten una estimación responsable.

En este estado el sistema no genera una recomendación económica fuerte. Debe indicar qué dato falta y cuál es la acción de corrección de datos más útil.

---

## 4. Calidad del cálculo

Toda salida económica conserva:

- periodo evaluado;
- fuente de ventas;
- método de costo variable;
- versión de costos fijos;
- calendario usado;
- `DATA_FRESHNESS`;
- `DATA_COMPLETENESS`;
- `DATA_CONFIDENCE`;
- supuestos materiales.

### Niveles de confianza iniciales

**ALTA:** datos de ventas completos + costos vigentes verificados + calendario correcto.

**MEDIA:** ventas confiables + algún costo aproximado o parcialmente desactualizado.

**BAJA:** faltan componentes relevantes o existen estimaciones dominantes.

Con confianza BAJA, la UI debe evitar lenguaje imperativo fuerte y priorizar recolección/corrección de datos.

---

## 5. Generación de candidatos de acción

El MVP solo puede generar candidatos pertenecientes a categorías previamente permitidas.

### A1 — Recuperación de clientes

Requisito: identidad/contacto utilizable y recencia suficiente.

Ejemplo: clientes que antes compraban y no regresaron durante una ventana relevante.

### A2 — Mix / producto

Requisito: ventas por producto/categoría + contribución aproximada.

Ejemplo: impulsar una opción con contribución favorable cuando existe demanda compatible.

### A3 — Disponibilidad / faltante

Requisito: evidencia de faltante, indisponibilidad o riesgo inmediato.

### A4 — Continuidad operacional

Requisito: cierre/horario/personal/equipo que amenaza horas de venta planificadas.

### A5 — Capacidad / flujo

Requisito: evidencia de espera, cola, retraso o capacidad insuficiente.

### A6 — Acción comercial local simple

Requisito: acción de bajo costo, medible y ejecutable sin integración compleja.

### A7 — Precio/promoción

Solo puede proponerse con evidencia suficiente y siempre requiere aprobación humana explícita. No es la categoría preferida por defecto.

---

## 6. Filtro de elegibilidad

Un candidato NO puede competir por `NEXT_BEST_ACTION` si:

- depende de datos con confianza insuficiente;
- requiere una capacidad no disponible;
- implica una acción jurídica/laboral/fiscal/societaria de alto impacto;
- ejecutarla puede causar daño material difícil de revertir;
- exige integración externa inexistente;
- no tiene responsable potencial;
- no puede medirse razonablemente después;
- contradice una restricción operativa conocida;
- ya existe una acción incompatible en ejecución.

El motor debe preferir `NO_RECOMMENDATION_WITH_REASON` antes que inventar una acción.

---

## 7. Priorización del MVP

No usar una fórmula pseudocientífica con decimales arbitrarios como si fuera verdad económica.

El orden inicial es determinista por bandas:

1. **Seguridad/eligibilidad** — primero debe ser una acción permitida.
2. **Impacto económico potencial:** `ALTO / MEDIO / BAJO`.
3. **Confianza de evidencia:** `ALTA / MEDIA / BAJA`.
4. **Urgencia:** `HOY / 72H / SEMANA`.
5. **Esfuerzo/costo:** `BAJO / MEDIO / ALTO`.
6. **Reversibilidad:** preferir acciones reversibles cuando impacto/confianza sean similares.
7. **No repetición:** penalizar una acción repetida recientemente sin nueva evidencia.

La primera acción después de filtrar y ordenar es la `NEXT_BEST_ACTION`.

Los empates deben registrar la regla de desempate aplicada.

---

## 8. Contrato de una recomendación

Cada recomendación debe tener como mínimo:

- `action_id`;
- company/branch;
- fecha/hora;
- problema detectado;
- evidencia usada;
- brecha económica asociada cuando corresponda;
- acción propuesta;
- categoría;
- impacto esperado: banda/rango;
- costo/esfuerzo esperado;
- confianza;
- urgencia;
- reversibilidad;
- responsable sugerido;
- aprobación requerida;
- estado;
- baseline;
- ventana de medición;
- confusores conocidos;
- resultado observado;
- aprendizaje final.

Estados mínimos:

`PROPOSED → APPROVED | REJECTED → EXECUTED → MEASURED → LEARNED`

También:

`EXPIRED`, `CANCELLED`, `INCONCLUSIVE`.

---

## 9. Pantalla principal del dueño

La primera capa debe caber conceptualmente en una sola pantalla.

```text
VANSAM · HOY

ESTADO ECONÓMICO        BAJO OBJETIVO
BRECHA ESTIMADA         -Bs 180
OBJETIVO DE COBERTURA   Bs XXX

SIGUIENTE MEJOR ACCIÓN
14 clientes con historial útil están inactivos desde hace >21 días.
Preparar un mensaje de recuperación para revisión.

IMPACTO ESPERADO        MEDIO
ESFUERZO                BAJO
CONFIANZA               MEDIA
DATOS ACTUALIZADOS      21:42

[PREPARAR ACCIÓN]

¿Por qué esta acción?   [VER EVIDENCIA]
```

### Segunda capa

Puede mostrar:
- fórmula/supuestos;
- ventas y contribución;
- fuentes;
- candidatos descartados;
- historial de acciones;
- resultado de acciones anteriores.

Nunca obligar al dueño a abrir la segunda capa para entender qué hacer.

---

## 10. Aprobación y ejecución

Automático:
- cálculo;
- detección;
- priorización;
- creación de borrador;
- medición posterior.

Con aprobación humana:
- mensaje a cliente;
- descuento/promoción;
- cambio de precio;
- orden/compra;
- acción externa con costo;
- cualquier acción material.

El MVP no necesita ejecutar por API. Puede preparar el texto/acción y abrir la herramienta correspondiente.

---

## 11. Medición del resultado

Para una acción ejecutada se compara contra un baseline adecuado, sin afirmar causalidad fuerte por defecto.

Registrar:

- qué pasó después;
- periodo de observación;
- métrica objetivo;
- resultado observado;
- costo real de la acción;
- confusores;
- confianza;
- clasificación de aprendizaje.

Clasificación:

`FUNCIONO`, `PARCIAL`, `NO_FUNCIONO`, `INCONCLUSO`, `DANO`.

Una acción que funcionó una vez no se convierte automáticamente en regla universal.

---

## 12. Aprendizaje

El aprendizaje del MVP es local a empresa/sucursal.

Inicialmente IQ GROWTH puede aprender:
- acciones aceptadas/rechazadas;
- tiempos de ejecución;
- respuesta observable;
- categorías útiles;
- fricciones;
- datos que faltaron.

No usar información de otro tenant para recomendar sin política futura explícita de agregación/anonimización.

---

## 13. Guardrails de producto

El motor nunca debe:

- inventar una venta, costo o cliente;
- confundir pedido con pago;
- llamar utilidad neta a una estimación de contribución;
- ejecutar una promoción automáticamente;
- afirmar que IQ GROWTH causó una mejora observada;
- generar diez recomendaciones simultáneas;
- esconder baja calidad de datos;
- usar IA como única justificación;
- priorizar una acción porque sea llamativa en lugar de económicamente relevante.

---

## 14. VANSAM como primer vertical

El motor universal trabaja con dinero, hechos, clientes, disponibilidad y capacidad.

La capa VANSAM puede traducir:
- brecha → pizzas/tickets equivalentes;
- capacidad → tiempos de preparación;
- disponibilidad → apertura/cierre;
- mix → pizzas/bebidas/categorías.

No introducir `pizza` como concepto obligatorio del Core.

---

## 15. Gate de implementación

Este documento no autoriza desarrollo inmediato.

Antes de entregar a Codex:

1. IQG-001.2 debe cerrar;
2. IQG-001.3 debe estabilizar la migración;
3. Día 0 de VANSAM debe tener datos revalidados;
4. contratos técnicos deben derivarse de esta especificación;
5. el CEO debe aprobar el alcance técnico final.

**CEO_ACTION_REQUIRED:** false.
