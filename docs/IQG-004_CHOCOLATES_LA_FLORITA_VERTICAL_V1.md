# IQG-004 — Chocolates La Florita Vertical V1

**Fecha:** 2026-09-12
**Estado:** diseño de vertical, no implementación
**Objetivo:** usar Chocolates La Florita como tercer laboratorio para demostrar que IQ GROWTH soporta manufactura, formulaciones, lotes, merma, empaque, retail y mayorista sin modificar el Core universal.

## 1. Tipo de negocio

`MANUFACTURING + RETAIL + WHOLESALE`

El vertical activa capacidades universales y añade semántica de producción de alimentos manufacturados.

## 2. Preguntas que debe responder

- ¿Qué insumos entraron a cada lote de producción?
- ¿Qué formulación/receta se usó y qué versión estaba vigente?
- ¿Cuánto rindió el lote?
- ¿Qué merma ocurrió y por qué?
- ¿Cuánto costó realmente producir cada presentación?
- ¿Qué stock terminado existe por lote/presentación?
- ¿Qué canal vende mejor y con qué margen?
- ¿Qué productos rotan y cuáles inmovilizan capital?
- ¿Qué materia prima o proceso limita producción?
- ¿Qué acción prioritaria mejora margen, rotación, calidad o venta?

## 3. Capacidades reutilizadas

- ITEM;
- FORMULATION/BOM;
- PRODUCTION_BATCH;
- TRANSFORMATION;
- INVENTORY_MOVEMENT;
- PURCHASE;
- COST;
- PRICE_VERSION;
- QUALITY_EVENT;
- SALE;
- PAYMENT;
- CUSTOMER;
- DOCUMENT;
- INCIDENT;
- WORKFORCE;
- AUDIT;
- GROWTH_INTERVENTION.

No crear un Core separado para chocolate.

## 4. Productos

Debe poder configurar sin alterar el modelo:
- barras;
- chocolatitos;
- chocolate/polvo;
- cascarilla;
- presentaciones futuras;
- productos de temporada;
- marcas futuras/rebranding.

Cada producto puede tener:
- presentación;
- peso/unidad;
- empaque;
- canal;
- precio vigente por fecha;
- formulación asociada;
- costo estimado/observado.

## 5. Formulación y propiedad de receta

La formulación debe ser temporal/versionada:
- FORMULA_V1 válida desde fecha X;
- FORMULA_V2 válida desde fecha Y;
- producción histórica conserva la versión usada.

Campos conceptuales:
- ingredientes;
- cantidades;
- unidad;
- tolerancia;
- proceso/instrucción;
- rendimiento esperado;
- acceso restringido cuando sea información confidencial.

Cambiar formulación hoy nunca recalcula lotes anteriores.

## 6. Producción por lote

Cada `PRODUCTION_BATCH` registra:
- fecha;
- formulación/version;
- insumos/lotes consumidos;
- cantidades;
- responsables;
- equipo/recurso;
- tiempo;
- producción obtenida;
- merma;
- unidades terminadas;
- incidencias;
- evidencia;
- costo.

Salida:
- lote terminado trazable;
- stock por lote;
- costo unitario estimado/observado.

## 7. Inventario y compras

Separar:
- materia prima;
- material de empaque;
- producto en proceso;
- producto terminado;
- merma/descarte.

Cada nueva compra registra precio por fecha/lote y no reescribe costos pasados.

Alertas futuras:
- stock crítico;
- variación anómala de precio;
- insumo próximo a agotarse;
- producto terminado con baja rotación;
- diferencias inventario físico/sistema.

## 8. Calidad

Eventos configurables:
- lote aprobado/rechazado;
- textura;
- peso;
- presentación;
- empaque;
- defecto;
- contaminación/incidencia;
- evaluación sensorial;
- otro control definido por empresa/compliance.

IQ GROWTH no debe asumir automáticamente requisitos regulatorios específicos: estos vienen del Compliance Pack aplicable.

## 9. Ventas y canales

Posibles canales:
- retail directo;
- punto de venta;
- mayorista;
- distribuidores;
- pedidos corporativos;
- e-commerce futuro.

Debe conservar:
- producto/lote;
- cantidad;
- precio;
- descuento;
- canal;
- cliente;
- costo atribuible;
- margen/contribución;
- pago separado;
- devolución/incidencia.

## 10. Growth Engine Chocolate

Palancas:
- margen por producto;
- mix;
- precio;
- rendimiento por lote;
- merma;
- rotación;
- frecuencia de compra;
- canal;
- clientes mayoristas;
- recompra;
- disponibilidad;
- capacidad productiva;
- empaque/presentación;
- acciones comerciales.

Ejemplo:

```text
HECHO
Producto A vende más unidades pero Producto B deja mayor contribución por hora de producción.

BRECHA
Mix actual utiliza capacidad en producto de menor contribución.

ACCION
Probar promoción/canal específico para aumentar participación de Producto B.

MEDICION
Comparar mix y contribución en periodo comparable.
```

## 11. Datos iniciales a mapear

Antes de implementación:
- catálogo actual;
- formulaciones/recetas;
- gramajes;
- insumos;
- proveedores;
- precios actuales;
- flujo de producción;
- equipos;
- capacidad;
- empaques;
- lotes actuales si existen;
- merma;
- canales/clientes;
- costos fijos/variables;
- controles de calidad existentes.

## 12. Qué prueba este vertical

Si Chocolates La Florita funciona sin cambiar el Core, validamos:
- formulaciones versionadas;
- manufactura por lotes;
- transformación;
- costos de producción;
- merma;
- empaque;
- retail;
- mayorista;
- nuevos productos sin nuevas tablas del Core.

**Gate:** `CHOCOLATE_VERTICAL_DESIGN_READY_FOR_DATA_MAPPING`
**CEO_ACTION_REQUIRED:** false
