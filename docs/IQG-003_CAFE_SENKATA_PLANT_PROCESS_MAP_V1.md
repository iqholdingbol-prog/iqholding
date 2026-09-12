# IQG-003 — Café Don Zacarías Senkata Plant Process Map V1

**Fecha:** 2026-09-12
**Estado:** mapa funcional inicial, previo a levantamiento físico de máquinas
**Autoridad de negocio:** Iván Quea — CEO / Product Owner

## 1. Propósito

Desglosar la planta de El Alto/Senkata desde la recepción del café proveniente de finca hasta empaque, almacenamiento y despacho, separando procesos, equipos, operadores, capacidades, lotes, costos y responsabilidades.

La planta es compartida con Chocolates La Florita, pero los datos de Café y Chocolate permanecen segregados.

## 2. Flujo café en planta

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

## 3. Recepción

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

## 4. Secado / estabilización

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

## 5. Almacenamiento de pergamino

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

## 6. Trilla

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
`TRILLADORA`: `PENDING_CONFIRMATION/ACQUISITION`.

No fijar modelo/capacidad hasta reconfirmar decisión de compra.

## 7. Selección / clasificación

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

## 8. Destinos post-clasificación

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

## 9. Tostado

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

### Equipos históricos a reconfirmar
No encontrados en repositorio; se conservan como `UNVERIFIED_PRIOR` hasta validación física del CEO:
- tostador tipo bola para café torrado;
- tostador artesanal para café especial.

No usar capacidad ni depreciación hasta reconfirmación.

## 10. Molienda

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

### Equipos históricos a reconfirmar
`UNVERIFIED_PRIOR`:
- molino para torrado;
- molinos para café especial.

## 11. Empaque

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

### Equipo histórico a reconfirmar
- selladoras (`UNVERIFIED_PRIOR`).

## 12. Catálogo inicial propuesto

No fijar como vigente todavía:
- Torrado Base;
- Torrado Premium;
- Especial Base;
- Especial Premium.

Cada línea puede tener múltiples presentaciones y precios por canal/fecha.

## 13. Producto terminado

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

## 14. Despacho multicanal

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

## 15. Operadores y responsabilidad

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

## 16. Máquinas/equipos — datos mínimos

Para cada equipo:
- nombre/tipo;
- propietario;
- marca/modelo si existe;
- capacidad nominal;
- capacidad observada;
- unidad/hora;
- energía/combustible;
- ubicación;
- operador autorizado;
- mantenimiento;
- costo adquisición;
- estado;
- vida/fecha compra si se conoce;
- incidencias;
- productos/procesos compatibles.

## 17. Costeo por transformación

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

## 18. Planta compartida con Chocolate

La planta de Senkata tendrá recursos compartidos y procesos específicos.

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

## 19. Próximo levantamiento requerido

Para convertir este mapa en `PLANT_BASELINE_V1`, levantar físicamente:
1. lista exacta de máquinas existentes;
2. fotos/placas/modelos cuando existan;
3. capacidad real aproximada;
4. estado de cada equipo;
5. qué procesos hoy se hacen y cuáles no;
6. operadores actuales;
7. espacio físico por proceso;
8. servicios/energía;
9. equipo faltante prioritario;
10. flujo real de un lote de principio a fin.

**Estado:** `SENKATA_PLANT_PROCESS_MAP_OPEN_FOR_PHYSICAL_VALIDATION`
**CEO_ACTION_REQUIRED:** false hasta decisiones de compra/capex.
