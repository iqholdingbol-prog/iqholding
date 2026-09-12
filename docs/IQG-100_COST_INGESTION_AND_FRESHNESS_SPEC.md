# IQG-100 — Cost Ingestion & Freshness Specification

**Estado:** diseño canónico previo a implementación  
**Fecha:** 2026-09-12  
**Primer laboratorio:** VANSAM

## 1. Propósito

Mantener costos suficientemente frescos y trazables para que IQ GROWTH no calcule margen con precios obsoletos ni reescriba el pasado cuando cambia el costo de compra.

Principio:

> **CADA COMPRA ES UN HECHO FECHADO. UN PRECIO NUEVO NO REESCRIBE UN PRECIO ANTIGUO.**

## 2. Formas de captura

El usuario autorizado podrá registrar compras mediante:

1. texto libre asistido;
2. formulario simple;
3. foto de factura/nota;
4. importación estructurada futura;
5. integración con proveedor/facturación futura.

### Ejemplo de texto libre

`harina quintal 300`

`cebolla 5`

`queso mozzarella 70 kg`

La IA propone estructura; el humano confirma cuando sea necesario.

## 3. Extracción IA/OCR

De una foto o documento, el sistema puede proponer:

- proveedor;
- fecha del documento;
- fecha de recepción;
- producto/insumo;
- presentación;
- unidad;
- cantidad;
- precio total;
- precio unitario;
- moneda;
- impuestos/descuentos cuando estén claramente soportados;
- correspondencia con catálogo interno.

Toda extracción conserva provenance y estado:

- `SYSTEM_INFERRED`;
- `CONFIRMED_BY_USER`;
- `AMBIGUOUS`;
- `REJECTED`.

No persistir como hecho definitivo una lectura ambigua solo porque el OCR produjo un valor.

## 4. Recepción por lote

Cada ingreso de stock debe crear un evento/lote con al menos:

- `inventory_receipt_id`;
- insumo canónico;
- cantidad;
- unidad normalizada;
- costo total;
- costo unitario;
- proveedor;
- fecha recepción;
- fecha documento declarada;
- evidencia/documento cuando exista;
- actor que confirmó;
- estado de calidad.

## 5. Historia sagrada de costos

Ejemplo:

`Harina — lote A — 50 kg — Bs 290 — 2026-09-01`

`Harina — lote B — 50 kg — Bs 400 — 2026-09-15`

La recepción del lote B:

- NO modifica el lote A;
- NO modifica ventas históricas;
- NO recalcula silenciosamente costos históricos;
- sí cambia la valoración futura según el método de consumo/inventario aprobado.

## 6. Último precio no es costo real consumido

IQ GROWTH debe distinguir:

- `LAST_PURCHASE_PRICE`;
- `CURRENT_INVENTORY_COST`;
- `RECIPE_ESTIMATED_COST`;
- `ACTUAL/ALLOCATED_COGS` cuando exista suficiente trazabilidad.

Usar el último precio de mercado para todo el stock puede ser falso si todavía queda inventario comprado a otro costo.

El método de valoración/consumo (por ejemplo promedio ponderado u otro) debe definirse posteriormente con criterio contable/operativo apropiado y no inventarse en el MVP.

## 7. Detección de anomalías

Cuando un nuevo dato se aleja materialmente de historia reciente, el sistema no debe rechazarlo automáticamente.

Debe probar hipótesis de error:

- cero adicional/faltante;
- unidad incorrecta;
- presentación distinta;
- cantidad total vs precio unitario;
- moneda incorrecta;
- OCR dudoso;
- duplicado;
- proveedor/producto equivocado.

Luego mostrar:

`POSIBLE_ANOMALIA_COSTO`

con:
- valor anterior;
- valor nuevo;
- diferencia absoluta/relativa;
- unidad/presentación;
- razón detectada;
- solicitud de confirmar/corregir/justificar.

La tolerancia no será una cifra universal fija: se calibrará por insumo y volatilidad.

## 8. Evidencia externa/web

Una consulta web o fuente de mercado puede ayudar a detectar si un aumento parece plausible.

Pero:

- no sustituye factura/nota/proveedor;
- no sobrescribe un precio confirmado;
- se marca como `EXTERNAL_REFERENCE`;
- debe registrar fuente y fecha;
- nunca convierte por sí sola un precio en verdad interna.

## 9. Roles y permisos

Debe poder existir un rol estrecho como `STOCK_INPUT_OPERATOR` que pueda:

- cargar compras;
- adjuntar foto/nota;
- confirmar extracción;
- corregir antes de cierre.

No debe por ese permiso poder:

- cambiar costos históricos;
- modificar ventas;
- cambiar precios de venta;
- modificar salarios/equity;
- borrar evidencia;
- aprobar excepciones materiales que requieran otro rol.

## 10. Frescura

Por insumo se debe medir:

- `LAST_PURCHASE_AT`;
- `LAST_CONFIRMED_COST_AT`;
- días desde actualización;
- volatilidad observada;
- stock disponible estimado/confirmado;
- confiabilidad.

Un costo viejo reduce `DATA_CONFIDENCE` de recomendaciones dependientes de ese insumo.

## 11. Impacto en margen

Un cálculo de margen debe poder explicar qué costo utilizó y por qué.

Ejemplo:

`MARGEN_ESTIMADO_PIZZA_X`

- precio venta: Bs 69;
- receta versión: R12;
- costo queso: fuente lote/promedio vigente;
- costo harina: fuente lote/promedio vigente;
- empaque: costo confirmado;
- fecha cálculo;
- calidad del dato.

No mostrar “ganancia neta real” si el sistema solo conoce receta + último costo.

## 12. MVP VANSAM

Para el primer piloto basta con:

- catálogo de insumos críticos;
- captura rápida manual;
- foto/OCR como capacidad deseable pero no gate obligatorio hasta probar fiabilidad;
- costo fechado;
- no retroactividad;
- alerta de anomalía;
- confirmación humana;
- uso del costo fresco en estimación de receta.

Inventario contable completo, valoración fiscal y automatización de compras quedan fuera hasta que el Core y reglas correspondientes estén listos.

## 13. Definición de éxito

La capacidad es útil si reduce fuertemente el trabajo de mantener costos y evita que una cifra errónea contamine el motor económico.

Debe poder responder:

- ¿qué compramos?;
- ¿cuánto?;
- ¿a qué precio?;
- ¿cuándo?;
- ¿quién lo confirmó?;
- ¿qué evidencia existe?;
- ¿qué cambió respecto a antes?;
- ¿qué cálculos futuros quedan afectados?;

sin modificar lo ocurrido en periodos anteriores.
