# IQG-003 — Café Don Zacarías Vertical V1

**Fecha:** 2026-09-12
**Estado:** diseño de vertical, no implementación
**Objetivo:** usar Café Don Zacarías como segundo laboratorio para demostrar que IQ GROWTH soporta agricultura, transformación, lotes, calidad y comercialización sin modificar el Core universal.

## 1. Tipo de negocio

`AGRICULTURE + PROCESSING + MANUFACTURING + WHOLESALE + RETAIL`

El vertical no crea un ERP separado. Activa capacidades universales y añade semántica específica del café.

## 2. Preguntas que debe responder

- ¿Qué lote/parcela produjo qué cantidad?
- ¿Cuánto costó producir/cosechar/procesar ese lote?
- ¿Qué rendimiento tuvo cada transformación?
- ¿Qué humedad/calidad/puntuación tiene?
- ¿Dónde está físicamente el lote?
- ¿Cuánto stock existe por estado: pergamino, verde, tostado, molido?
- ¿Qué lote se vendió a qué cliente y a qué precio?
- ¿Cuál fue margen/contribución por lote, presentación y canal?
- ¿Dónde se pierde rendimiento o calidad?
- ¿Qué acción prioritaria mejora rentabilidad/calidad/rotación?

## 3. Entidades verticales

Semántica del café sobre capacidades universales:
- FINCA/LOCATION;
- PARCELA/PRODUCTION_UNIT;
- CAMPAÑA/PRODUCTION_CYCLE;
- LOTE/TRACEABLE_BATCH;
- VARIEDAD/ITEM_ATTRIBUTE;
- COSECHA/PRODUCTION_EVENT;
- CALIDAD/QUALITY_EVENT;
- TRANSFORMACION/TRANSFORMATION;
- CATACION/QUALITY_ASSESSMENT.

No duplicar personas, inventario, pagos, clientes, ventas, documentos ni auditoría.

## 4. Cadena de transformación

Debe poder modelar:

```text
CEREZA
  ↓ beneficio/proceso
PERGAMINO
  ↓ trillado
VERDE
  ↓ tostado
TOSTADO
  ↓ molienda
MOLIDO
  ↓ empaque
PRODUCTO TERMINADO
```

Cada transformación registra:
- lotes de entrada;
- cantidades;
- unidad;
- humedad/calidad antes/después;
- merma;
- rendimiento;
- equipo;
- responsable;
- fecha;
- costo;
- lote(s) de salida;
- evidencia.

Historia sagrada: una transformación futura no modifica el rendimiento histórico de un lote anterior.

## 5. Calidad

Eventos posibles:
- humedad;
- defectos;
- clasificación;
- tamaño/malla cuando aplique;
- catación;
- puntuación;
- notas sensoriales;
- aceptación/rechazo;
- responsable/evaluador;
- evidencia/documento.

La calidad debe versionarse por fecha/lote.

## 6. Inventario

Ubicaciones:
- finca;
- secado/almacenamiento;
- planta El Alto;
- punto de venta;
- terceros si corresponde.

Estados de producto:
- cereza;
- pergamino;
- verde;
- tostado;
- molido;
- empacado.

Debe existir trazabilidad lote origen → transformaciones → producto vendido.

## 7. Equipos/capacidad

El vertical debe poder registrar recursos productivos:
- secado;
- trillado;
- tostado;
- molienda;
- empaque.

Por equipo:
- capacidad nominal;
- capacidad observada;
- disponibilidad;
- mantenimiento;
- tiempo de proceso;
- incidencias;
- cuello de botella.

El equipo se modela como recurso universal, no como tabla específica por marca/modelo.

## 8. Comercialización

Canales:
- café verde mayorista;
- tostado/molid retail;
- ventas B2B;
- punto de venta;
- exportación futura.

Cada venta conserva:
- cliente;
- canal;
- lote;
- cantidad;
- precio;
- moneda;
- costo atribuible;
- margen/contribución estimada;
- documento/evidencia;
- estado de pago separado de la venta.

## 9. Growth Engine Café

Palancas iniciales:
- rendimiento por lote;
- pérdida/merma;
- calidad/puntuación;
- precio por canal;
- rotación de inventario;
- utilización de capacidad;
- costo de procesamiento;
- cartera de clientes B2B;
- recompra retail;
- mezcla entre verde vs tostado/molid;
- disponibilidad de materia prima.

Ejemplo de salida:

```text
HECHO
Lote X tiene rendimiento inferior al promedio comparable.

BRECHA
-8% de producto útil vs baseline.

ACCION
Revisar etapa de secado/proceso antes del siguiente lote.

EVIDENCIA
3 lotes comparables + humedad + tiempos.
```

No atribuir causalidad sin evidencia suficiente.

## 10. Datos iniciales a mapear antes de implementación

- estructura de finca/parcela;
- campañas/lotes históricos disponibles;
- unidades reales usadas (kg, qq, sacos, lb);
- estados de inventario actuales;
- flujo de beneficio/secado;
- flujo de planta;
- costos variables/fijos;
- equipos;
- clientes/canales;
- formatos de calidad/catación;
- documentos existentes.

## 11. Qué prueba este vertical

Si Café Don Zacarías funciona sin modificar el Core, habremos validado:
- ciclos productivos no diarios;
- lotes;
- transformaciones múltiples;
- calidad;
- agricultura;
- manufactura ligera;
- mayorista;
- retail;
- trazabilidad profunda.

**Gate:** `CAFE_VERTICAL_DESIGN_READY_FOR_DATA_MAPPING`
**CEO_ACTION_REQUIRED:** false
