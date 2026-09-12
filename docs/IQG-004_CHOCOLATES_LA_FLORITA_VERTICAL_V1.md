# IQG-004 — Chocolates La Florita Vertical V2

**Fecha:** 2026-09-12
**Estado:** diseño de vertical, no implementación
**Autoridad de negocio:** Iván Quea — CEO / Product Owner
**Objetivo:** usar Chocolates La Florita como laboratorio de compra de materia prima + manufactura + formulaciones + lotes + empaque + distribución móvil/fija + mayorista/minorista, sin modificar el Core universal.

## 1. Tipo de negocio

`PROCUREMENT + MANUFACTURING + FORMULATION + BATCH_PRODUCTION + PACKAGING + WHOLESALE + RETAIL + MOBILE_COMMERCE`

Diferencia fundamental con Café Don Zacarías:
- Café puede comenzar desde tierra/cultivo propio.
- Chocolates La Florita **no cultiva cacao actualmente**; compra materia prima, referida por el CEO principalmente desde El Ceibo, y desde ahí transforma/comercializa.

El Core debe soportar ambos modelos sin confundir `PRODUCIDO_POR_LA_EMPRESA` con `COMPRADO_A_PROVEEDOR`.

## 2. Cadena end-to-end

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

## 3. Compras y proveedores

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
- evidencia (factura, nota, foto, declaración);
- estado de pago;
- responsable;
- ubicación de recepción.

Un precio nuevo nunca recalcula lotes históricos.

## 4. Formulaciones versionadas

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

## 5. Variedad de chocolatitos, formas y tamaños

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

Ejemplo conceptual:

```text
FAMILIA: CHOCOLATITO
  ├─ forma A · 8 g
  ├─ forma B · 12 g
  ├─ forma C · 20 g
  └─ nuevas variantes sin cambiar el Core
```

## 6. Productos complementarios y coproductos

Debe poder comercializar de forma independiente:
- cocoa/polvo de cacao;
- cascarilla de cacao;
- otros productos derivados;
- productos futuros.

Cada uno tiene stock, unidad, costo, precio y canal propios.

## 7. Producción por lote

Cada lote registra:
- formulación/version;
- insumos consumidos y sus lotes;
- cantidad entrada;
- responsables;
- equipo/molde;
- inicio/fin;
- producción obtenida;
- peso total;
- unidades por variante;
- merma;
- reproceso si existe;
- producto fuera de especificación;
- evidencia;
- costo.

La salida es inventario trazable de producto terminado.

## 8. Unidades y venta flexible

El sistema debe soportar:
- unidades individuales;
- paquetes;
- cajas;
- gramos;
- kilogramos;
- combinaciones comerciales;
- ventas mayoristas por volumen.

Las conversiones deben ser configurables y auditables.

## 9. Distribución fija y móvil

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

Cada vendedor/punto/vehículo puede recibir stock en consignación o transferencia interna y debe rendir:
- stock recibido;
- ventas;
- devoluciones;
- faltantes/sobrantes;
- cobros;
- gastos;
- efectivo/otros medios;
- incidencias.

## 10. Vehículos y vendedores

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

## 11. Venta mayorista y minorista

El mismo producto puede tener:
- precio minorista;
- precio mayorista;
- escala por cantidad;
- precio por canal;
- promoción temporal;
- precio por cliente/acuerdo cuando corresponda.

Todos con vigencia temporal. Cambiar precio hoy no modifica ventas anteriores.

## 12. Growth Engine Chocolate

Palancas potenciales:
- margen por familia/modelo/tamaño;
- margen por lote;
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

## 13. Preguntas que IQ GROWTH debe responder

- ¿Qué proveedor/lote alimentó cada producto terminado?
- ¿Qué formulación se usó?
- ¿Qué modelo/forma/tamaño deja más contribución?
- ¿Qué lote tuvo merma anormal?
- ¿Qué punto/vendedor mueve mejor cada producto?
- ¿Qué stock lleva cada carrito/vehículo?
- ¿Qué precio mayorista/minorista es vigente?
- ¿Cuánto capital está inmovilizado en producto lento?
- ¿Conviene producir más de un modelo o reducir variedad?
- ¿Qué acción prioritaria mejora margen, rotación o venta?

## 14. Qué prueba este vertical para el Core

Chocolates La Florita obliga al Core a soportar:
- procurement externo como origen;
- múltiples proveedores;
- formulaciones secretas/versionadas;
- producción por lotes;
- gran cantidad de variantes;
- formas/tamaños/pesos;
- coproductos/derivados;
- empaque;
- precios multicanal;
- mayorista/minorista;
- stock por vendedor/punto/vehículo;
- comercio móvil/fijo;
- propiedad separada de activos usados por el negocio.

**Gate:** `CHOCOLATE_VERTICAL_V2_MULTICHANNEL_DEFINED`
**CEO_ACTION_REQUIRED:** false
