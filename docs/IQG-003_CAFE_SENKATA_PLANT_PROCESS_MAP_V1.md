# IQG-003 — Café Don Zacarías Senkata Plant Process Map V2

**Fecha:** 2026-09-12
**Estado:** mapa funcional de planta futura, previo a levantamiento físico/layout
**Autoridad de negocio:** Iván Quea — CEO / Product Owner

## 1. Propósito y estado real

Desglosar la futura planta de El Alto/Senkata desde la recepción del café proveniente de finca hasta empaque, almacenamiento y despacho, separando procesos, equipos, operadores, capacidades, lotes, costos y responsabilidades.

**Corrección CEO:** la producción actual NO se realiza todavía en Senkata. Hoy se realiza en la casa del padre de Iván, zona Huayna Potosí, El Alto. Senkata es el sitio de traslado y expansión planificada.

La futura planta/terreno será compartida con Chocolates La Florita, pero los datos de Café y Chocolate permanecen segregados.

## 2. Sitio Senkata confirmado

- Terreno total: **9 lotes × ~200 m² = ~1.800 m²**.
- Galpón existente: **~15 m × 25 m = ~375 m²**.
- Acceso tipo garaje apto para ingreso de camión.
- Orientación/recorrido descrito por el CEO: **sur → noroeste**, pendiente de verificar con plano/fotos antes de fijar layout.
- Uso/adaptación actual del galpón: **trilla y selección/escogido de café**.
- Estrategia: comenzar usando el galpón existente y crecer por fases hasta utilizar más del terreno de 1.800 m² para Café + Chocolate.

## 3. Flujo café objetivo en Senkata

```text
RECEPCIÓN LOTE
  ↓
PESAJE / IDENTIFICACIÓN
  ↓
CONTROL HUMEDAD / CALIDAD EN RECEPCIÓN
  ↓
SECADO / ESTABILIZACIÓN FINAL SI HACE FALTA
  ↓
ALMACENAMIENTO PERGAMINO
  ↓
TRILLA
  ↓
SELECCIÓN / CLASIFICACIÓN
  ├─ CAFÉ VERDE EXPORTABLE / MAYORISTA
  ├─ CAFÉ ESPECIAL PARA TOSTADO
  ├─ CAFÉ PARA TORRADO/CARAMELADO
  └─ DESCARTES CLASIFICADOS / OTROS DESTINOS
  ↓
TOSTADO SEGÚN LÍNEA
  ↓
ENFRIADO / REPOSO SEGÚN PROCESO
  ↓
MOLIENDA SI APLICA
  ↓
PESAJE / DOSIFICACIÓN
  ↓
EMPAQUE / SELLADO
  ↓
ETIQUETADO / LOTE / PRESENTACIÓN
  ↓
ALMACENAMIENTO PRODUCTO TERMINADO
  ↓
TRANSFERENCIA A PUNTO / VENDEDOR / VEHÍCULO / CLIENTE
```

## 4. Recepción

Registrar:
- lote origen finca;
- fecha/hora;
- sacos/unidad original;
- peso recibido cuando exista;
- humedad;
- responsable recepción;
- transportista;
- costo transporte;
- estado envases/sacos;
- incidencia;
- ubicación asignada.

La diferencia origen→recepción debe poder medirse sin asumir robo/merma automáticamente.

## 5. Secado / estabilización

Objetivo: llevar/mantener el lote dentro del rango operativo definido por la empresa/calidad antes de trilla/almacenamiento.

Registrar:
- humedad entrada/salida;
- método/equipo;
- cantidad;
- inicio/fin;
- responsable;
- energía/combustible;
- condiciones/incidencias;
- merma de peso;
- costo;
- evidencia.

No fijar humedad objetivo en Core; es regla/configuración de producto/proceso.

## 6. Almacenamiento de pergamino

Stock por:
- lote;
- calidad;
- humedad;
- cantidad/unidad;
- ubicación/bin;
- fecha ingreso;
- movimientos;
- propietario/business unit;
- reserva/destino previsto.

## 7. Trilla

Entrada: café pergamino.
Salida: café verde + subproductos/descartes.

Registrar:
- lote entrada;
- kg/qq/sacos;
- máquina;
- operador;
- hora inicio/fin;
- rendimiento;
- verde obtenido;
- descarte/subproducto;
- consumo;
- incidencia;
- costo.

### Equipo
El galpón está adaptado para trilla, pero la trilladora exacta/capacidad/modelo debe levantarse físicamente antes de fijarla como `CONFIRMED_EQUIPMENT`.

## 8. Selección / clasificación

Debe permitir clasificación manual, mecánica o combinada.

Registrar:
- lote;
- criterio;
- cantidad por clase;
- defectos;
- responsable;
- tiempo;
- merma/descarte;
- destino de cada fracción.

Una fracción descartada para especial puede seguir siendo materia prima válida para otra línea; no se marca automáticamente como basura.

## 9. Destinos post-clasificación

### A. Café verde
- exportación;
- mayorista;
- almacenamiento;
- muestra/catación.

### B. Café especial tostado
- tostado especial;
- grano o molido;
- presentaciones configurables.

### C. Café torrado/caramelado
- materia prima clasificada para esa línea;
- puede provenir de cafés de primera o descartes aptos, manteniendo origen y calidad.

## 10. Tostado — equipos confirmados por CEO

Por lote de tostado registrar:
- lote verde origen;
- línea/calidad;
- peso entrada;
- perfil/receta de tostado versionada cuando exista;
- tostador;
- operador;
- inicio/fin;
- combustible/energía;
- peso salida;
- merma;
- control calidad;
- costo.

### Equipos actuales confirmados
- **Tostador/horno para café torrado: ~40 kg por carga.**
- **Tostador artesanal/hechizo para café especial: ~10 kg por carga; no industrial.**

Pendiente levantar:
- marca/modelo si existe;
- energía/combustible;
- tiempo real de ciclo;
- capacidad real por hora;
- estado técnico;
- fecha/costo de adquisición;
- mantenimiento.

## 11. Molienda — equipos confirmados por CEO

Registrar:
- lote tostado origen;
- cantidad;
- grado/configuración;
- molino;
- operador;
- entrada/salida;
- merma;
- incidencia;
- costo.

Equipos:
- **2 molinos para café especial.**
- **1 molino para café torrado.**

Pendiente confirmar capacidades reales, motor/energía, estado y mantenimiento.

## 12. Empaque

Debe soportar venta desde aproximadamente 60 g hasta 1 kg o más, además de presentaciones futuras.

Por corrida/empaque:
- producto/línea;
- lote origen;
- presentación;
- cantidad por envase;
- número unidades;
- envase;
- etiqueta;
- responsable;
- equipo/selladora;
- pérdida/reproceso;
- costo material empaque;
- costo mano de obra;
- fecha.

### Estado actual
- **Selladoras disponibles — CEO_CONFIRMED.**
- **Empaques con diseño/identidad/marca propia — PENDIENTE.**

El desarrollo de empaque no debe mezclarse con el diseño físico de planta, pero afecta catálogo, costos, stock y estrategia comercial.

## 13. Catálogo inicial propuesto

No fijar como vigente todavía:
- Torrado Base;
- Torrado Premium;
- Especial Base;
- Especial Premium.

Cada línea puede tener múltiples presentaciones y precios por canal/fecha.

## 14. Producto terminado

Stock separado por:
- familia/línea;
- variante;
- presentación;
- lote;
- fecha producción;
- ubicación;
- cantidad;
- costo histórico;
- estado/reserva.

## 15. Despacho multicanal

Destinos:
- puesto fijo;
- feria;
- carrito ambulante;
- vendedor;
- Hiace/Ranger u otro vehículo autorizado;
- mayorista;
- cliente B2B;
- exportación cuando aplique.

Toda salida genera `INVENTORY_MOVEMENT`; una transferencia interna no es una venta.

## 16. Operadores y responsabilidad

Cada etapa debe tener:
- `PRIMARY_RESPONSIBLE`;
- `BACKUP_RESPONSIBLE` cuando corresponda;
- check-in/out o periodo de trabajo cuando aplique;
- producción procesada;
- incidencias;
- calidad;
- mantenimiento reportado.

Roles a levantar físicamente:
- recepción/almacén;
- secado;
- trillado;
- selección;
- tostado;
- molienda;
- empaque;
- despacho;
- mantenimiento;
- supervisor/planta.

Una persona puede asumir varios roles en una microempresa, pero el sistema conserva las responsabilidades separadas.

## 17. Máquinas/equipos — datos mínimos

Para cada equipo:
- nombre/tipo;
- propietario;
- marca/modelo si existe;
- capacidad nominal;
- capacidad observada;
- unidad/hora;
- energía/combustible;
- ubicación actual;
- ubicación futura;
- operador autorizado;
- mantenimiento;
- costo adquisición;
- estado;
- vida/fecha compra si se conoce;
- incidencias;
- productos/procesos compatibles.

El sistema debe poder representar traslado de equipo `HUAYNA_POTOSI → SENKATA` sin perder su historial.

## 18. Costeo por transformación

Cada proceso debe acumular:
- materia prima consumida;
- mano de obra;
- alimentación/hospedaje cuando corresponda;
- energía/combustible;
- transporte;
- empaque;
- mantenimiento atribuible;
- servicios externos;
- merma/rendimiento;
- costo compartido con método explícito.

Objetivo futuro:
`COSTO_DESDE_FINCA_HASTA_PRODUCTO_TERMINADO` por lote/presentación.

## 19. Planta compartida con Chocolate

El sitio de Senkata tendrá recursos compartidos y procesos específicos.

No duplicar:
- facility;
- vehículos;
- servicios generales;
- ciertos espacios/equipos comunes.

Sí separar:
- inventario;
- lotes;
- formulaciones;
- procesos;
- costos directos;
- ingresos;
- calidad;
- responsables cuando difieran.

## 20. Principio de layout por fases

No diseñar los 1.800 m² como si todo debiera construirse ahora.

### Fase 0 — operación actual
`HUAYNA_POTOSI_ACTIVE`
- producción/tostado/molienda/sellado actual en casa del padre.

### Fase 1 — traslado compacto al galpón
`SENKATA_GALPON_MINIMUM_OPERATION`
- recepción/almacén;
- trilla/selección;
- tostado;
- molienda;
- empaque;
- almacenamiento terminado;
- despacho.

Diseñar el galpón para evitar cruces innecesarios entre materia prima/polvo de trilla y producto terminado/empaque.

### Fase 2 — consolidación Café + Chocolate
`SENKATA_SHARED_PLANT`
- zonas segregadas por proceso;
- servicios comunes planificados;
- Chocolate incorporado sin contaminar trazabilidad ni flujos de Café.

### Fase 3 — expansión del terreno
`SENKATA_1800M2_MASTERPLAN`
- crecimiento productivo;
- almacenes;
- despacho/logística;
- puntos de carga;
- administración;
- mantenimiento;
- posibles áreas comerciales u otras según estrategia.

No fijar ubicación exacta de cada zona antes de levantar plano físico.

## 21. Próximo levantamiento requerido

Para convertir este mapa en `PLANT_BASELINE_V1`, levantar físicamente:
1. croquis de los 9 lotes y ubicación exacta del galpón;
2. puerta(s), columnas, ventanas, servicios y altura útil del galpón;
3. ruta exacta de ingreso/manobra del camión;
4. lista/fotos/placas de máquinas existentes;
5. capacidad real aproximada por equipo;
6. estado de cada equipo;
7. qué equipos están hoy en Huayna Potosí y cuáles ya están en Senkata;
8. operadores actuales;
9. energía/gas/agua disponibles;
10. necesidades de almacenamiento;
11. equipo faltante prioritario;
12. flujo real de un lote de principio a fin.

**Estado:** `SENKATA_PLANT_V2_READY_FOR_SITE_LAYOUT`
**CEO_ACTION_REQUIRED:** false hasta decisiones de obra/capex.
