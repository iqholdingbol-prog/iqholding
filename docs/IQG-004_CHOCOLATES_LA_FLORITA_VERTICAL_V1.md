# IQG-004 — Chocolates La Florita Vertical V3

**Fecha:** 2026-09-12
**Estado:** diseño de vertical, no implementación
**Autoridad de negocio:** Iván Quea — CEO / Product Owner
**Objetivo:** usar Chocolates La Florita como laboratorio de abastecimiento externo y, opcionalmente en el futuro, agricultura propia de cacao + manufactura + formulaciones + lotes + empaque + distribución móvil/fija + mayorista/minorista, sin modificar el Core universal.

## 1. Tipo de negocio

Actual:
`PROCUREMENT + MANUFACTURING + FORMULATION + BATCH_PRODUCTION + PACKAGING + WHOLESALE + RETAIL + MOBILE_COMMERCE`

Futuro posible:
`AGRICULTURE + PROCUREMENT + MANUFACTURING + FORMULATION + BATCH_PRODUCTION + PACKAGING + WHOLESALE + RETAIL + MOBILE_COMMERCE`

Diferencia fundamental con Café Don Zacarías hoy:
- Café comienza desde tierra/cultivo propio.
- Chocolates La Florita **no cultiva cacao actualmente**; compra materia prima, referida por el CEO principalmente desde El Ceibo.
- Se evalúa cultivo propio futuro de cacao en **Mayaya**, no en la finca cafetalera actual.

El Core debe soportar ambos orígenes simultáneamente:
- `PRODUCIDO_POR_LA_EMPRESA`;
- `COMPRADO_A_PROVEEDOR`;
- `MIXTO`.

Nunca reescribir historia cuando cambie el origen de abastecimiento.

## 2. Cadena actual end-to-end

```text
PROVEEDOR / COMPRA DE CACAO E INSUMOS
  ↓
RECEPCIÓN + COSTO + LOTE
  ↓
ALMACENAMIENTO DE MATERIA PRIMA
  ↓
FORMULACIÓN / RECETA VERSIONADA
  ↓
PRODUCCIÓN POR LOTE
  ↓
MOLDE / FORMA / TAMAÑO / PRESENTACIÓN
  ↓
CONTROL DE RENDIMIENTO / MERMA
  ↓
EMPAQUE
  ↓
PRODUCTO TERMINADO
  ├─ chocolatitos
  ├─ barras / futuras variantes
  ├─ cocoa/polvo
  ├─ cascarilla de cacao
  └─ otros productos configurables
  ↓
DISTRIBUCIÓN
  ├─ punto fijo
  ├─ puesto callejero
  ├─ feria
  ├─ carrito/venta ambulante
  ├─ vehículo de venta
  ├─ mayorista
  └─ distribuidor
  ↓
VENTA / COBRO / RECOMPRA
```

## 3. Cadena futura opcional con cacao propio

Si se activa cultivo propio en Mayaya:

```text
TERRENO / PARCELA CACAO
  ↓
IMPLANTACIÓN
  ↓
LABORES AGRÍCOLAS
  ↓
COSECHA
  ↓
BENEFICIO / PROCESO PRIMARIO CACAO
  ↓
LOTE DE CACAO PROPIO
  ───────────────┐
                 ├→ ALMACENAMIENTO / PRODUCCIÓN
CACAO COMPRADO ──┘
```

Regla universal:
`SUPPLY_SOURCE` se registra por lote.

El mismo producto terminado puede usar lotes de origen propio o comprado, pero cada lote conserva trazabilidad, costo y calidad reales.

## 4. Agricultura de cacao futura

Cuando se active, debe reutilizar capacidades agrícolas universales ya probadas con café:
- terreno/location;
- parcela/production unit;
- superficie;
- proyecto de implantación;
- plantines/material vegetal;
- labores;
- personal/jornal/contrato;
- herramientas/equipos;
- insumos;
- cosecha;
- lote;
- calidad;
- transporte;
- costos;
- incidencias;
- evidencia.

La semántica específica de cacao vive en el adaptador vertical, no en el Core.

No asumir todavía variedades, rendimientos, distancias, costos o procesos agrícolas concretos de Mayaya: `TO_VERIFY`.

## 5. Compras y proveedores

Cada compra debe conservar:
- proveedor;
- materia prima/insumo;
- lote del proveedor cuando exista;
- fecha;
- cantidad;
- unidad;
- costo unitario/total;
- transporte;
- calidad/condición recibida;
- evidencia;
- estado de pago;
- responsable;
- ubicación de recepción.

Proveedor referido actual: **El Ceibo** (`CEO_CONFIRMED_CONTEXT`).

Un precio nuevo nunca recalcula lotes históricos.

## 6. Formulaciones versionadas

La receta/formulación es un activo del negocio y debe poder protegerse.

Cada formulación:
- producto base;
- versión;
- vigencia;
- ingredientes;
- cantidades;
- unidades;
- tolerancias;
- rendimiento esperado;
- proceso;
- controles;
- acceso restringido;
- autor/aprobador;
- evidencia.

`FORMULA_V2` no modifica lotes elaborados con `FORMULA_V1`.

## 7. Variedad de chocolatitos, formas y tamaños

El catálogo no puede asumir un solo SKU por producto.

Debe soportar:
- familia de producto;
- modelo/forma;
- tamaño;
- peso;
- sabor/formulación;
- empaque;
- color/diseño;
- unidades por paquete;
- canal;
- precio vigente;
- costo vigente/histórico;
- lote.

Ejemplo:

```text
FAMILIA: CHOCOLATITO
  ├─ forma A · 8 g
  ├─ forma B · 12 g
  ├─ forma C · 20 g
  └─ nuevas variantes sin cambiar el Core
```

## 8. Productos complementarios y coproductos

Debe poder comercializar independientemente:
- cocoa/polvo de cacao;
- cascarilla de cacao;
- otros productos derivados;
- productos futuros.

Cada uno tiene stock, unidad, costo, precio y canal propios.

## 9. Producción por lote

Cada lote registra:
- formulación/version;
- insumos consumidos y sus lotes;
- origen de cada materia prima (comprada/propia);
- cantidad entrada;
- responsables;
- equipo/molde;
- inicio/fin;
- producción obtenida;
- peso total;
- unidades por variante;
- merma;
- reproceso;
- producto fuera de especificación;
- evidencia;
- costo.

La salida es inventario trazable de producto terminado.

## 10. Planta compartida Senkata

Café Don Zacarías y Chocolates La Florita comparten/compartirán infraestructura física en la planta de El Alto/Senkata.

Regla:
`SHARED_FACILITY != SHARED_DATA_OWNERSHIP`.

Se debe separar por operación:
- empresa/unidad;
- marca;
- proceso;
- lote;
- inventario;
- formulación;
- persona/responsable;
- tiempo de equipo;
- consumo;
- costo asignado;
- documento;
- ingreso/venta.

Un equipo compartido puede asignar costo/tiempo a más de una línea sin duplicarse como activo.

## 11. Unidades y venta flexible

Soportar:
- unidades individuales;
- paquetes;
- cajas;
- gramos;
- kilogramos;
- combinaciones comerciales;
- ventas mayoristas por volumen.

Las conversiones deben ser configurables y auditables.

## 12. Distribución fija y móvil multimarcas

La misma capacidad universal de canales usada por Café se aplica aquí.

Tipos posibles:
- tienda/punto fijo;
- puesto fijo callejero;
- feria temporal;
- carrito ambulante;
- vendedor ambulante;
- vehículo de venta;
- distribuidor;
- mayorista;
- minorista;
- pedidos corporativos;
- e-commerce futuro.

Un mismo vendedor, carrito o vehículo puede llevar **Café Don Zacarías + Chocolates La Florita** en la misma salida.

La rendición se separa por producto/marca/lote:
- stock recibido;
- ventas;
- devoluciones;
- faltantes/sobrantes;
- cobros;
- gastos;
- efectivo/otros medios;
- incidencias.

## 13. Vehículos y vendedores

La Toyota Hiace 1982 y la Ford Ranger 2008 pueden ser utilizadas por la red comercial si la empresa decide asignarlas, manteniendo separado:
- propietario legal;
- relación de uso con la empresa;
- responsable/vendedor;
- inventario transportado;
- ruta;
- ventas;
- gastos;
- mantenimiento;
- caja.

La propiedad familiar de un vehículo nunca se infiere como activo de la empresa.

## 14. Venta mayorista y minorista

El mismo producto puede tener:
- precio minorista;
- precio mayorista;
- escala por cantidad;
- precio por canal;
- promoción temporal;
- precio por cliente/acuerdo cuando corresponda.

Todos con vigencia temporal. Cambiar precio hoy no modifica ventas anteriores.

## 15. Growth Engine Chocolate

Palancas potenciales:
- margen por familia/modelo/tamaño;
- margen por lote;
- costo cacao comprado vs propio cuando exista evidencia;
- merma;
- rendimiento de formulación;
- utilización de moldes/equipos;
- costo de materia prima;
- rotación;
- canal;
- vendedor/ruta;
- mayorista vs minorista;
- recompra;
- empaque/presentación;
- surtido por punto;
- stock inmovilizado;
- disponibilidad;
- promociones medibles.

## 16. Preguntas que IQ GROWTH debe responder

- ¿Qué proveedor/lote u origen agrícola alimentó cada producto terminado?
- ¿Qué formulación se usó?
- ¿Qué modelo/forma/tamaño deja más contribución?
- ¿Qué lote tuvo merma anormal?
- ¿Qué punto/vendedor mueve mejor cada producto?
- ¿Qué stock lleva cada carrito/vehículo?
- ¿Qué precio mayorista/minorista está vigente?
- ¿Cuánto capital está inmovilizado en producto lento?
- ¿Conviene comprar cacao, producirlo o combinar ambas fuentes cuando exista información suficiente?
- ¿Qué acción prioritaria mejora margen, rotación o venta?

## 17. Qué prueba este vertical para el Core

Chocolates La Florita obliga al Core a soportar:
- procurement externo como origen actual;
- agricultura propia opcional futura;
- origen híbrido por lote;
- múltiples proveedores;
- formulaciones secretas/versionadas;
- producción por lotes;
- gran cantidad de variantes;
- formas/tamaños/pesos;
- coproductos/derivados;
- planta compartida multinegocio;
- empaque;
- precios multicanal;
- mayorista/minorista;
- stock por vendedor/punto/vehículo;
- comercio móvil/fijo multimarcas;
- propiedad separada de activos usados por el negocio.

**Gate:** `CHOCOLATE_VERTICAL_V3_HYBRID_SUPPLY_DEFINED`
**CEO_ACTION_REQUIRED:** false
