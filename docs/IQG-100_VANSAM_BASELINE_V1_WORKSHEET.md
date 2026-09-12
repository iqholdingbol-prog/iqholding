# IQG-100 — VANSAM BASELINE V1 Worksheet

**Estado:** PREPARING — no usar para decisiones automáticas todavía
**Fecha de apertura:** 2026-09-12
**Objetivo:** convertir datos actuales de VANSAM en el primer baseline económico/operativo verificable del piloto IQ GROWTH.

## Regla de evidencia

Todo dato debe tener estado:

- `CONFIRMED_CURRENT`
- `DOCUMENT_SUPPORTED`
- `SYSTEM_OBSERVED`
- `UNVERIFIED_PRIOR`
- `ESTIMATED`
- `STALE`
- `UNKNOWN`

Ningún `UNVERIFIED_PRIOR` entra al motor de decisión hasta confirmarse.

---

## 1. Calendario operativo

| Campo | Valor previo | Estado | Confirmar |
|---|---:|---|---|
| Días abiertos/semana | UNKNOWN | UNKNOWN | pendiente |
| Hora apertura | UNKNOWN | UNKNOWN | pendiente |
| Hora cierre | UNKNOWN | UNKNOWN | pendiente |
| Días cerrados previstos/mes | UNKNOWN | UNKNOWN | pendiente |
| Cierres no planificados últimos 30 días | UNKNOWN | UNKNOWN | pendiente |

## 2. Costos fijos mensuales

| Concepto | Valor previo Bs | Estado | Valor actual |
|---|---:|---|---:|
| Alquiler | 2.000 | UNVERIFIED_PRIOR | pendiente |
| Luz | 450 | UNVERIFIED_PRIOR | pendiente |
| Agua | 150 | UNVERIFIED_PRIOR | pendiente |
| Internet | 50 | UNVERIFIED_PRIOR | pendiente |
| Samira — remuneración | 2.500 | UNVERIFIED_PRIOR | pendiente |
| Ayudante/mesera/otro fijo | UNKNOWN | UNKNOWN | pendiente |
| Otros costos fijos | UNKNOWN | UNKNOWN | pendiente |

### Personal variable conocido históricamente

- Ayudante por días: `70 Bs/turno + cena ~18 Bs`, previamente 3–4 días/semana — `UNVERIFIED_PRIOR`.
- Hornero/armador: contratación propuesta históricamente, no asumir como costo actual.

## 3. Ventas y volumen actual

| Campo | Valor previo | Estado | Valor actual |
|---|---:|---|---:|
| Pizzas/día aproximadas | ~10 | UNVERIFIED_PRIOR | pendiente |
| Histórico anterior | 15–20/día | UNVERIFIED_PRIOR | solo referencia |
| Días pico históricos | hasta ~35 | UNVERIFIED_PRIOR | solo referencia |
| Ticket promedio Bs | UNKNOWN | UNKNOWN | pendiente |
| Ventas netas/día Bs | UNKNOWN | UNKNOWN | pendiente |
| Pedidos/día | UNKNOWN | UNKNOWN | pendiente |
| Cancelaciones | UNKNOWN | UNKNOWN | pendiente |

## 4. Objetivos

### COBERTURA_MINIMA

Se calculará solo después de confirmar:
- costos fijos actuales;
- días operativos planificados;
- método de costo variable.

### OBJETIVO_DUENO

Hipótesis previa de volumen saludable:
- `30–50 pizzas/día sostenido` — `UNVERIFIED_PRIOR` para Baseline V1.

Debe confirmarse si este sigue siendo el objetivo y si se expresa mejor como:
- pizzas/día;
- ventas/semana;
- margen de contribución/semana;
- utilidad/meta mensual;
- combinación de métricas.

## 5. Costo variable

Antes del piloto debe elegirse un método inicial verificable.

Opciones:
1. costo por pizza/producto;
2. costo variable % de venta por categoría;
3. costo promedio ponderado;
4. costo por receta parcial;
5. importación desde costos actuales;
6. otro método documentado.

### Datos pendientes

| Categoría | Precio venta | Costo variable estimado | Fuente | Estado |
|---|---:|---:|---|---|
| Pizza pequeña | pendiente | pendiente | pendiente | UNKNOWN |
| Pizza mediana | pendiente | pendiente | pendiente | UNKNOWN |
| Pizza grande | pendiente | pendiente | pendiente | UNKNOWN |
| Café | pendiente | pendiente | pendiente | UNKNOWN |
| Chocolate | pendiente | pendiente | pendiente | UNKNOWN |
| Frappé | pendiente | pendiente | pendiente | UNKNOWN |

## 6. Frescura de costos

Registrar para insumos críticos:
- último precio;
- fecha;
- proveedor;
- unidad de compra;
- evidencia disponible;
- frecuencia de cambio.

Prioridad inicial:
- queso;
- harina;
- salsa/tomate;
- embutidos/carnes;
- cajas/empaque;
- gas;
- café/chocolate/leche cuando correspondan.

Canal de actualización todavía NO decidido:
- captura rápida;
- foto/OCR;
- CSV;
- proveedor;
- factura electrónica;
- otro.

## 7. Capacidad y continuidad

| Campo | Estado | Valor |
|---|---|---|
| Horno actual | CONFIRMED_CONTEXT / revalidar capacidad | artesanal |
| Capacidad pizzas simultáneas | UNKNOWN | pendiente |
| Tiempo real preparación | UNKNOWN | pendiente |
| Tiempo real horno | UNKNOWN | pendiente |
| Tiempo total pedido | UNKNOWN | pendiente |
| Cuello de botella dominante | UNVERIFIED_PRIOR | horno + atención/personal |
| Horas perdidas/cierres últimos 30 días | UNKNOWN | pendiente |

## 8. Clientes / recuperación

| Campo | Estado | Valor |
|---|---|---|
| Clientes identificados con nombre/teléfono | UNKNOWN | pendiente |
| Clientes con >=2 compras | UNKNOWN | pendiente |
| Clientes inactivos >21 días | UNKNOWN | pendiente |
| Consentimiento/uso permitido para contacto | UNKNOWN | pendiente |

No activar recomendaciones de recuperación hasta verificar datos y tratamiento permitido.

## 9. Ventana móvil candidata

Claude sugirió 7 días para VANSAM debido al bajo volumen diario.

Estado: `HYPOTHESIS_TO_VALIDATE`.

Comparar durante Baseline V1:
- 1 día;
- 7 días;
- 14 días;
- mismo día de semana previo cuando exista historia suficiente.

Elegir la ventana que reduzca ruido sin ocultar cambios operativos reales.

## 10. Inventario inicial de fuentes de acción

Evaluar disponibilidad real de evidencia para:
- clientes inactivos;
- mix/producto;
- faltantes;
- continuidad/cierres;
- capacidad/tiempos;
- acción comercial local;
- datos/costos desactualizados.

No fijar un mínimo artificial de acciones distintas antes de observar los datos.

## 11. Gate de Baseline V1

`BASELINE_READY` solo si:

- calendario actual confirmado;
- costos fijos actuales confirmados;
- ventas recientes disponibles y suficientemente confiables;
- método de costo variable documentado;
- al menos una ventana temporal seleccionada/provisional;
- `COBERTURA_MINIMA` calculable;
- `OBJETIVO_DUENO` confirmado;
- frescura/calidad declarada;
- principales confusores registrados.

Si falta algo:

`BASELINE_NOT_READY` + lista exacta de datos faltantes.

## 12. Primer resultado esperado

Una vez confirmado el baseline, IQ GROWTH deberá poder producir, sin afirmar utilidad contable:

- tendencia;
- cobertura mínima;
- posición frente al objetivo;
- calidad/frescura;
- una acción ejecutable o `NO_RECOMMENDATION_WITH_REASON`.

**CEO_ACTION_REQUIRED:** sí — confirmar datos actuales y objetivo durante Baseline V1.
