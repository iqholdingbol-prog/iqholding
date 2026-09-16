# IQG-002 — ChatGPT Review of Claude Product Challenge V2

**Fecha:** 2026-09-16  
**Revisor:** ChatGPT — Chief Architect / AI Council Coordinator  
**Estado:** `CHALLENGE_ACCEPTED_WITH_MATERIAL_CORRECTIONS`  

## 1. Veredicto
La respuesta V2 de Claude mejora sustancialmente respecto a su primera versión: audita sus propios errores, separa hipótesis/unknowns, introduce economía unitaria, intercompany economics, capacity model, cannibalization model, launch gates y un data request priorizado.

Sin embargo, no debe canonizarse como decisión. Mantiene errores numéricos y varias reglas excesivamente fuertes o todavía no demostradas.

## 2. Correcciones materiales

### 2.1 Costos fijos actuales
Claude registra Bs 8.180/mes como `CEO_CONFIRMED`. Esto NO coincide con el baseline canónico vigente, que registra ~Bs 6.675,33/mes de estructura actual conocida antes de contratación estable. Cualquier cálculo derivado de Bs 8.180 debe marcarse `STALE/CONFLICTING_PRIOR` y recalcularse desde el baseline vigente.

### 2.2 Bs 66,67 no es ticket promedio
`Bs 800 / 12 pizzas = Bs 66,67` es una relación agregada de ventas por pizza-equivalente. No es ticket promedio porque las ventas incluyen bebidas, café y otros productos y no conocemos todavía el número de tickets/pedidos. Debe mantenerse como `AGGREGATE_REVENUE_PER_PIZZA_EQUIVALENT`, no `AVERAGE_TICKET`.

### 2.3 Punto de equilibrio por unidades
La banda 8,8–19,8 pizzas/día presentada por Claude depende de supuestos de costos/margen y de tratar márgenes de SKU individuales como proxies. No debe utilizarse hasta disponer de mix real y estructura vigente. Estado: `TO_RECALCULATE`.

### 2.4 “Marca registrada”
La evidencia de menú/branding permite afirmar que VANSAM usa `Pizza & Coffee` como identidad/comunicación. No permite afirmar registro legal de marca. Estado correcto: `DOCUMENT_SUPPORTED_BRANDING`; registro jurídico: `UNKNOWN/TO_VERIFY`.

### 2.5 Café ya existente vs “subexplotado”
Está documentado que existen combos/café en la oferta. No está demostrado que esté subexplotado. `COFFEE_ALREADY_OFFERED = SUPPORTED`; `UNDEREXPLOITED = HYPOTHESIS` hasta medir attach rate, unidades y contribución.

### 2.6 Frappé/daypart
La hipótesis de que el frappé pertenece principalmente a mediodía/calor y queda debilitado porque VANSAM abre 16:00 no tiene evidencia suficiente. Mantener `HYPOTHESIS/TO_VERIFY`, especialmente porque la investigación externa de mercado todavía no ha demostrado patrones horarios robustos.

### 2.7 Riesgos cualitativos ALTO/MEDIO
Los niveles de riesgo por categoría en la tabla de Claude son juicios preliminares sin datos suficientes. No son facts. Deben tratarse como `EXPERT_HYPOTHESIS` hasta medir receta, estación, volumen, merma y demanda.

### 2.8 Intercompany transfer value
Es correcto que propiedad común ≠ costo cero y que deben separarse costos/márgenes/inventarios. Pero la regla “ambas empresas deben mostrar contribución positiva o no transferir” es demasiado fuerte. La política de transferencia puede responder a estrategia de grupo, precios de mercado, impuestos/contabilidad y objetivos comerciales. Lo inviolable es trazabilidad y consolidación correcta; el criterio económico final se define con política aprobada y asesoramiento fiscal/contable donde corresponda.

### 2.9 Capacity scenarios 12/30/50/100
Las restricciones propuestas por Claude para cada escala son hipótesis, no mediciones. No asumir “12 = demanda, no capacidad”, “30 = horno”, “50 = caja/personal”, “100 = espacio” sin time study/capacity study. Estado: `CAPACITY_HYPOTHESIS`.

### 2.10 Pilot duration
3 ciclos pre + 4 ciclos pilot + 1 evaluación es un diseño propuesto, no estándar canónico. Puede ser útil como punto inicial, pero debe adaptarse a número de observaciones, estabilidad de operación y cambios simultáneos. Un cambio de horno no obliga necesariamente a descartar todo: crea un `PHASE_BOUNDARY`/nuevo régimen y exige separar periodos.

### 2.11 Stop condition “pizzas < 8”
No usar caída bajo 8 pizzas como condición automática de retirada: puede estar causada por demanda externa, clima, cierre parcial, stockout, publicidad o cambio de operación. Toda stop condition debe combinar señal económica/operativa + atribución razonable.

### 2.12 Launch gates
Gate MARKET no puede pasar con “una fuente independiente” como regla general. Debe requerir evidencia proporcional a la decisión. Gate OPERABILITY tampoco exige utilización cero adicional de la estación más cargada; puede aumentar utilización si queda dentro de capacidad/SLAs y mejora contribución. Gate PERMANENT “2 ciclos” es también `PROPOSED_THRESHOLD`, no verdad.

### 2.13 One SKU per gate
“Un SKU por gate, nunca dos” es útil para atribución pero demasiado rígido. La regla superior es `ONE_MATERIAL_CHANGE_AT_A_TIME_WHERE_FEASIBLE`; productos compartiendo base/estación pueden requerir pilotaje familiar si se conserva trazabilidad.

### 2.14 No new SKU before oven stabilizes
No debe ser barrera absoluta para categorías ortogonales. Sí debe existir change ledger y segmentación temporal para evitar falsa atribución. Si un producto no usa ni comparte recursos con el cambio de horno, puede estudiarse/pilotearse si el diseño controla confusores.

## 3. Elementos aceptados
Se aceptan como arquitectura de análisis, sujetos a datos reales:
- fact/hypothesis/unknown registers;
- unit economics por SKU;
- MOQ + vida útil + working capital;
- ownership/margin/cost intercompany separados;
- station-level capacity model;
- cannibalization vs acquisition vs margin dilution vs capacity displacement;
- change ledger;
- launch gates por evidencia;
- pre-mortem;
- P0/P1/P2/P3 data request por value of information.

## 4. P0 ajustado
Antes de decidir nuevos SKUs, priorizar:
1. completar una ventana limpia de ventas por SKU/tamaño (ya existen 4 días parciales; no pedirlos nuevamente); completar los días faltantes o un ciclo nuevo completo si no corresponden al mismo ciclo;
2. medir café actual: unidades, tickets/attach rate, método de preparación y precio/costo vigente;
3. inventario físico de estación de barra/plancha/licuadora/equipos realmente disponibles;
4. compras/costos actuales documentados relevantes;
5. tiempos reales por estación/pedido suficientes para capacity study;
6. recetas candidatas solo cuando exista decisión de desarrollar la categoría.

## 5. Routing
Claude V2 queda como input válido para síntesis, pero no autoridad final.

Siguiente revisión adversarial: DeepSeek debe atacar específicamente:
- consistencia numérica del baseline;
- assumptions de transfer economics;
- arbitrariedad de pilot/gates;
- causalidad/cannibalization;
- categorías/daypart;
- data-integrity y leakage.

Gemini V3 debe entregar evidencia externa verificable antes de cerrar MARKET gates.

**Estado final:** `READY_FOR_DEEPSEEK_CHALLENGE_AND_EVIDENCE_SYNTHESIS_WITH_CORRECTIONS`
