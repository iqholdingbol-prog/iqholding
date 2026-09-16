# IQG-002 — Cross-AI Synthesis: VANSAM Product Expansion V1

**Fecha:** 2026-09-16  
**Coordinación:** ChatGPT / Chief Architect  
**Inputs:** Claude Product Challenge V2 + Gemini Market Evidence V3 + DeepSeek Residual Red Team V2 + baseline/canonical docs IQ GROWTH  
**Estado:** `SYNTHESIS_READY_FOR_DATA_COLLECTION`  
**No implica:** autorización para lanzar hamburguesas, frappés, nuevos cafés/chocolates ni fijar precios finales.

## 1. Resultado ejecutivo

1. No existe evidencia suficiente para decidir todavía el menú final de hamburguesas, frappés o bebidas de chocolate.
2. Café ya existe operativamente en VANSAM mediante oferta/combos, pero el catálogo individual, volumen, attach rate, tiempos y contribución actuales siguen incompletos.
3. La investigación digital de Gemini no pudo obtener suficiente evidencia primaria 2026 en la microzona Av. Petrolera Km 4.5; la siguiente evidencia de mercado útil debe venir de levantamiento físico/local, no de más búsquedas genéricas.
4. El objetivo empresarial permanece: llevar VANSAM hacia **50–100 pizzas/día sostenibles** preservando contribución, calidad, continuidad y capacidad; los nuevos productos solo son válidos si apoyan o al menos no bloquean ese objetivo.
5. Ningún cálculo de break-even debe expresarse como `X pizzas/día` sin mix real de SKU/tamaño/categoría y sin separar estructura CURRENT de TARGET.
6. La estructura `CURRENT_ACTUAL_STRUCTURE` conocida sigue siendo ~Bs 6.675,33/mes como baseline parcial; Bs 8.180 no se acepta como current vigente y queda `UNVERIFIED_PRIOR / NEEDS_CONTEXT`.

## 2. Lo que el AI Council acepta

### Evidencia y decisiones
- separar `FACT / OBSERVED / CALCULATED / ESTIMATED / HYPOTHESIS / UNKNOWN`;
- una cifra material necesita provenance suficiente para saber quién la declaró/observó, cuándo, a qué negocio/período aplica y con qué confianza;
- ejemplos genéricos nunca alimentan una decisión VANSAM;
- nueva receta debe poder reproducirse por otra persona antes de escalar;
- costo de producto debe incluir insumos, empaque y demás variables materiales observadas; mermas/tiempos deben medirse, no inventarse;
- medir la capacidad por estaciones y por interferencia entre estaciones, no solo por horno;
- crecimiento de ventas no equivale automáticamente a mejora económica;
- canibalización debe juzgarse junto con contribución total, adquisición de clientes, capacidad y tiempos;
- `CHANGE_LEDGER` para registrar cambios de horno, personal, precio, receta, promoción, horario, etc.;
- no definir duración del piloto ni umbrales de stop con números arbitrarios.

### Arquitectura de producto
- **Combos:** `BUNDLE_WITH_COMPONENTS`, no SKU opaco que esconda sus componentes.
- **Mitad/mitad:** una venta de pizza con configuración/componentes/fracciones; no crear cientos de SKUs combinatorios.
- **Precio/costo histórico:** nuevos precios/compras crean nuevos hechos/versiones; nunca reescriben historia.
- **Core universal:** estas capacidades deben servir a futuros negocios; no hardcodear pizza.

## 3. Correcciones residuales a DeepSeek V2

### 3.1 Provenance
No toda cifra sin los cuatro campos exactos `SOURCE/SOURCE_DATE/APPLICABILITY/CONFIDENCE` se convierte automáticamente en `UNKNOWN`. Un hecho declarado por el CEO puede ser válido si tiene provenance/fecha de afirmación suficiente; el sistema debe completar metadata y degradar confianza cuando falte, no borrar el hecho.

### 3.2 Costos/lotes
No imponer que cada consumo de inventario deba referenciar físicamente un lote específico en todos los métodos. La trazabilidad disponible y el método de valoración configurado pueden ser FIFO, promedio ponderado, costo específico u otro validado. Lo inviolable es que el costo histórico posteado de una venta no sea reescrito silenciosamente; correcciones posteriores deben ser nuevos eventos/versiones.

### 3.3 Relaciones económicas
No canonizar un campo inferido `ECONOMIC_OWNER` como verdad automática. IQ GROWTH debe registrar relaciones, asignaciones y responsabilidades declaradas/evidenciadas y permitir `PENDING_CLASSIFICATION` cuando la naturaleza económica/legal no esté resuelta.

### 3.4 Stop rules
`DATA_INTEGRITY_FAILURE → IMMEDIATE_STOP` es demasiado amplio. Un error menor de captura puede requerir corrección/reconciliación, no cerrar un SKU. `IMMEDIATE_STOP` queda reservado para fallas materiales, riesgo de seguridad/compliance, corrupción grave o imposibilidad de confiar en la medición.

### 3.5 Controles
La regla “ningún control sin riesgo medido” es demasiado rígida. Controles básicos, baratos y universales (por ejemplo cierre de caja, permisos mínimos y trazabilidad) pueden existir como baseline preventivo. Controles invasivos/costosos sí requieren proporcionalidad y justificación.

### 3.6 Calendario P0/P1
Se rechaza `P0 esta semana / P1 próximo mes` como calendario automático. La prioridad depende de cuándo VANSAM opere, disponibilidad de datos y costo de recolección. La clasificación P0–P3 es de prioridad, no un SLA arbitrario.

## 4. Estado de las categorías pendientes

### Hamburguesas
`PRODUCT_CONCEPT / DATA_REQUIRED`.
No decidir cantidad de SKUs, precio, papas, tamaño ni lanzamiento hasta tener receta candidata, costos reales, MOQ/vida útil, estación/equipo y evidencia local suficiente.

### Café
`EXISTS_CURRENTLY / PERFORMANCE_UNKNOWN`.
Existen usos/combos actuales, pero falta medir unidades, attach rate, horario, costo y tiempo. “Subexplotado” permanece hipótesis.

### Frappés
`MENU_PENDING / HYPOTHESIS`.
No está cerrado el menú actual/futuro. No afirmar que funciona de noche ni que falla por daypart sin evidencia.

### Chocolate
`CATEGORY_SPLIT_REQUIRED`.
Separar bebida de chocolate preparada en VANSAM de producto terminado de la marca de Chocolates; ambos tienen economía, operación e inventario distintos.

## 5. P0 real — paquete mínimo de verdad operativa

### P0-A — ventas/pedidos
Para el siguiente ciclo operativo limpio miércoles→lunes:
- order/ticket id;
- fecha/hora;
- productos y tamaño;
- mitad/mitad/componentes;
- combo y componentes;
- precio cobrado;
- descuento/ajuste;
- modalidad salón/llevar/delivery;
- método de pago;
- total del pedido.

Esto permite calcular por primera vez ticket real, mix y contribución ponderada cuando los costos estén disponibles.

### P0-B — café actual
Registrar cada café/combination vendido durante la misma ventana:
- presentación;
- unidades;
- precio;
- si fue combo/individual;
- hora;
- preparación actual;
- costo conocido o `UNKNOWN`.

### P0-C — capacidad
Medir una muestra operativa de pedidos reales:
- caja;
- armado;
- horno;
- listo/entrega;
- identificar simultaneidad y espera.

No asumir de antemano cuál es el recurso escaso.

### P0-D — estructura y compras
- mantener `CURRENT` separado de `TARGET`;
- registrar compras reales con fecha/unidad/precio/proveedor/evidencia;
- no reescribir costo histórico.

### P0-E — mercado físico
Después del límite digital documentado por Gemini, levantar microzona con protocolo simple y trazable: producto, precio, incluye, espera, presentación, evidencia disponible. No inferir ventas de competidores por una sola observación.

## 6. Lo que se puede hacer ahora

- seguir vendiendo y capturando el menú vigente;
- completar los dos días faltantes del ciclo actual si son comparables, o iniciar un ciclo limpio completo;
- medir café que ya se vende;
- registrar cambios operativos en `CHANGE_LEDGER`;
- inventariar equipo real de barra/cocina;
- construir recetas candidatas solo como `DRAFT`, sin precio/costo inventado;
- preparar modelo de bundle, mitad/mitad y costos históricos en diseño, sin desviar a Codex del gate IQG-001.2.

## 7. Lo que NO se decide todavía

- número final de hamburguesas/cafés/frappés/chocolates;
- precios finales;
- papas sí/no;
- equipo nuevo;
- personal adicional por categoría;
- duración/umbrales del piloto;
- break-even en pizzas/día;
- Hawaiana como hero definitivo;
- expansión de horario;
- política legal/contable entre negocios/marcas.

## 8. Routing del AI Council

- **Claude:** VANSAM Product Challenge V2 cerrado; no otra iteración hasta nueva evidencia.
- **Gemini:** VANSAM market web research cerrado en `FIELD_RESEARCH_REQUIRED`; puede reasignarse a IPCENTER digital/market evidence.
- **DeepSeek:** VANSAM Residual Red Team V2 cerrado; siguiente ticket técnico será reauditar IQG-001.2 cuando Codex entregue runtime evidence.
- **Codex:** continuar exclusivamente IQG-001.2 cuando recupere uso; preservar working tree y cambios PG16.
- **ChatGPT:** mantener síntesis, data contract y decisiones; elevar al CEO solo decisiones materiales.

## 9. Gate

`VANSAM_PRODUCT_EXPANSION_DECISION = BLOCKED_BY_REAL_DATA`

No es un bloqueo del negocio. Es un bloqueo únicamente para declarar menú/precios definitivos sin evidencia.

Trabajo autorizado mientras tanto:

`CAPTURAR DATOS REALES → MEDIR OPERACIÓN → LEVANTAR MERCADO FÍSICO → COSTEAR RECETAS CANDIDATAS → REEVALUAR`

**CEO_ACTION_REQUIRED:** false para iniciar medición; CEO decide después sobre inversiones, lanzamiento final y política comercial.