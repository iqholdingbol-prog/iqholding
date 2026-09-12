# IQG-003 — Senkata Masterplan Phased V1

**Fecha:** 2026-09-12
**Estado:** diseño funcional preliminar; sin layout métrico definitivo
**Autoridad:** Iván Quea — CEO / Product Owner

## 1. Base confirmada

- Sitio Senkata: 9 lotes × ~200 m² = ~1.800 m².
- Galpón existente: ~15 × 25 m = ~375 m².
- Acceso tipo garaje apto para camión; geometría exacta de ingreso pendiente de plano/fotos.
- Galpón adaptado para trilla y selección/escogido de café.
- Producción actual todavía en Huayna Potosí, casa del padre del CEO.
- Objetivo: trasladar progresivamente la operación a Senkata y luego expandir Café + Chocolate.

## 2. Equipos confirmados

Café:
- tostador/horno de torrado ~40 kg/carga;
- tostador artesanal/hechizo especial ~10 kg/carga;
- 2 molinos de café especial;
- 1 molino de café torrado;
- selladoras.

Pendiente:
- empaques con diseño/marca propia;
- levantamiento técnico de trilla/selección;
- capacidades reales por hora;
- consumos y servicios;
- mantenimiento/estado.

## 3. Principio de masterplan

No ocupar ni construir los 1.800 m² de una sola vez.

Diseñar desde el inicio para crecer sin destruir ni rehacer el flujo anterior.

`FASE 0 → FASE 1 → FASE 2 → FASE 3`

La infraestructura debe ser modular y cada expansión conservar trazabilidad de costos, activos y procesos.

## 4. Fase 0 — Huayna Potosí actual

Objetivo: mantener operación mientras se prepara Senkata.

Registrar:
- qué equipo está en Huayna Potosí;
- producción realizada;
- lotes procesados;
- stock;
- costos;
- incidencias;
- fecha de traslado de cada equipo cuando ocurra.

Gate: `CURRENT_OPERATION_MAPPED`.

## 5. Fase 1 — Galpón Senkata mínimo viable

Objetivo: trasladar Café Don Zacarías al galpón existente sin exigir construcción total del sitio.

### Zona funcional A — recepción / materia prima / trilla / selección

Procesos:
- descarga;
- identificación lote;
- pesaje;
- humedad;
- almacenamiento temporal pergamino;
- trilla;
- selección/clasificación.

Características de diseño:
- cercana al acceso de camión;
- preparada para sacos/carga;
- flujo de materia prima separado del empaque/producto terminado;
- control de polvo/residuos como problema operativo a resolver en layout técnico.

### Zona funcional B — café verde / lotes clasificados

- verde exportable;
- especial;
- materia prima para torrado;
- descartes clasificados con destino definido.

Stock separado por lote/calidad/destino.

### Zona funcional C — tostado

Equipos iniciales:
- tostador torrado ~40 kg;
- tostador especial artesanal ~10 kg.

Debe considerar:
- alimentación de energía/combustible;
- ventilación/extracción según equipo;
- enfriado;
- circulación del operador;
- almacenamiento inmediato pre/post tostado;
- mantenimiento.

La definición técnica final requiere inspección de equipos/instalaciones.

### Zona funcional D — molienda

- 2 molinos especial;
- 1 molino torrado.

Separar flujos/líneas cuando sea necesario para evitar confusión de producto y lotes.

### Zona funcional E — empaque limpio

Procesos:
- pesaje/dosificación;
- envase;
- sellado;
- etiquetado;
- lote/presentación;
- control final.

Regla de diseño: no ubicar el empaque terminado dentro del flujo de polvo/residuos de trilla.

### Zona funcional F — producto terminado / despacho

Stock por:
- línea;
- lote;
- presentación;
- canal/destino.

Salidas a:
- vendedor;
- carrito;
- vehículo;
- punto fijo;
- feria;
- mayorista;
- B2B/exportación.

## 6. Chocolate en Fase 1/2

No mezclar Chocolate dentro de las zonas de Café solo porque comparten galpón.

Reservar una zona funcional propia o una futura ampliación para:
- recepción cacao/insumos;
- formulación;
- producción;
- moldeado;
- empaque;
- producto terminado.

Los servicios generales pueden compartirse con asignación de costos explícita.

## 7. Administración y apoyo

El sitio completo deberá contemplar progresivamente:
- administración/registro;
- documentación/archivo;
- higiene/vestuario según necesidad;
- mantenimiento/herramientas;
- residuos;
- servicios;
- seguridad;
- carga/descarga;
- circulación de personas y vehículos.

## 8. Residencia temporal del CEO

El CEO contempla instalarse temporalmente en/el entorno del galpón durante la transición.

Principio de diseño:
- `RESIDENTIAL_USE != PRODUCTION_AREA`.
- si existe uso residencial temporal, debe ser físicamente separado del flujo de materia prima, producción, empaque e inventario;
- no convertir el área de producto terminado/empaque en espacio habitacional;
- el masterplan futuro debe prever una solución independiente si el CEO necesita permanecer en el sitio.

Requisitos normativos/sanitarios específicos se verificarán antes de ejecución física.

## 9. Fase 2 — planta compartida Café + Chocolate

Objetivo:
- ambos negocios operan en Senkata;
- infraestructura común sin mezclar inventario, lotes, costos ni procesos;
- almacenes y despachos consolidados donde sea eficiente;
- operadores y responsabilidades formalizados.

Gate: `SHARED_PLANT_OPERATIONAL`.

## 10. Fase 3 — utilización progresiva de 1.800 m²

Posibles módulos futuros, no aprobados aún:
- ampliación productiva Café;
- ampliación productiva Chocolate;
- secado/estabilización dedicado;
- almacén materia prima;
- almacén terminado;
- muelle/carga y logística;
- mantenimiento;
- administración;
- showroom/punto mayorista;
- preparación de rutas/carritos/vehículos;
- otros negocios/capacidades compatibles si el masterplan lo permite.

No construir por anticipación sin demanda/capacidad justificadas.

## 11. Regla de expansión

Cada nueva obra/máquina debe responder:
1. qué cuello de botella elimina;
2. qué capacidad añade;
3. cuánto cuesta;
4. qué ingreso/margen protege o habilita;
5. qué proceso depende de ella;
6. si puede instalarse sin rehacer fases anteriores.

## 12. Próximo dato físico requerido

Para pasar a layout V2:
- croquis/plano de los 9 lotes;
- posición exacta del galpón dentro del terreno;
- norte/sur confirmado;
- puertas y dimensiones;
- columnas/obstáculos;
- altura del galpón;
- luz/agua/gas disponibles;
- baños/servicios existentes;
- ubicación actual de máquinas;
- fotografías interiores desde las cuatro esquinas;
- fotografías exteriores y acceso del camión.

Con esto se podrá proponer un layout físico sin inventar geometría.

**Estado:** `SENKATA_MASTERPLAN_PHASED_READY_FOR_SITE_SURVEY`
**CEO_ACTION_REQUIRED:** false hasta seleccionar obra/capex/layout final.
