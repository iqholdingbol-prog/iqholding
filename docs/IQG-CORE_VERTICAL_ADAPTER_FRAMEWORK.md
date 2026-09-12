# IQ GROWTH — Core Universal & Vertical Adapter Framework

**Fecha:** 2026-09-12
**Estado:** arquitectura canónica de producto, previa a implementación de nuevos verticales
**Objetivo:** permitir que IQ GROWTH se adapte a negocios de cualquier rubro sin convertir el Core en un sistema específico de restaurantes, café, chocolate o cualquier industria concreta.

---

## 1. Principio arquitectónico

IQ GROWTH se diseña en cuatro capas:

```text
CORE UNIVERSAL
    ↓
CAPACIDADES REUTILIZABLES
    ↓
ADAPTADOR VERTICAL
    ↓
CONFIGURACION DE EMPRESA/SUCURSAL
```

### CORE UNIVERSAL

Nunca conoce conceptos como `pizza`, `cafetal`, `barra de chocolate`, `hotel` o `taller`.

Conoce hechos universales:
- empresa;
- sucursal/ubicación;
- persona;
- relación/rol;
- calendario operativo;
- producto/servicio/recurso (`ITEM`);
- operación/transacción;
- línea de operación;
- pago;
- movimiento;
- stock/recurso;
- costo;
- precio vigente;
- proceso;
- tarea;
- responsabilidad;
- incidencia;
- evidencia;
- documento;
- evento temporal;
- métrica;
- objetivo;
- intervención;
- resultado;
- regla/compliance;
- auditoría.

### CAPACIDADES REUTILIZABLES

Bloques que pueden servir en varios rubros:
- ventas/POS;
- CRM/clientes;
- inventario;
- compras;
- recetas/BOM/formulaciones;
- producción/transformación;
- lotes y trazabilidad;
- agenda/reservas;
- proyectos/servicios;
- fuerza laboral/asistencia;
- incidencias;
- caja/pagos;
- costos/margen;
- logística/entrega;
- marketing/adquisición;
- fidelización/recompra;
- growth engine;
- compliance;
- IA/copiloto.

### ADAPTADOR VERTICAL

Selecciona y configura capacidades según el rubro.

No crea un Core nuevo.

### CONFIGURACION EMPRESA

Cada empresa decide:
- calendario;
- horarios;
- roles;
- productos;
- procesos;
- KPIs;
- permisos;
- obligaciones;
- flujo operativo;
- unidades;
- moneda;
- reglas comerciales;
- fuentes de datos.

---

## 2. Calendario y ciclo operativo universal

Eliminar la idea de que todo negocio trabaja `7 dias` o que el periodo natural siempre es una semana calendario.

Modelo universal:

- `OPERATING_CALENDAR`
- `PLANNED_OPEN_WINDOW`
- `PLANNED_CLOSED_WINDOW`
- `ACTUAL_OPEN`
- `ACTUAL_CLOSE`
- `UNPLANNED_CLOSURE`
- `OPERATING_CYCLE`
- `OPERATING_AVAILABILITY`

Cada negocio define su ciclo.

Ejemplos:

### VANSAM
- miércoles → lunes: operativo;
- martes: descanso planificado;
- ciclo operativo: 6 días.

### Fábrica
- lunes → viernes;
- sábado mantenimiento;
- domingo cerrado.

### Hotel
- 24/7;
- ciclo de ocupación por noche.

### Servicio profesional
- lunes → viernes;
- ciclo por proyecto/cita, no necesariamente por día.

### Agricultura
- ciclos por campaña/lote/cosecha además del calendario laboral.

`PLANNED_CLOSED` nunca se trata automáticamente como falla.

---

## 3. Adaptador inicial: VANSAM

Tipo conceptual:
`FOOD_SERVICE + RETAIL + LIGHT_PRODUCTION`

Capacidades específicas activadas:
- pedido;
- salón / para llevar / delivery;
- caja;
- KDS cocina;
- pizza/hamburguesa;
- recetas/gramajes;
- preparación;
- tiempos;
- mesa;
- bebidas;
- cross-sell cliente;
- faltantes;
- incidencias;
- inventario de insumos;
- costo por receta/lote de compra;
- CRM/recompra;
- asistencia/personal.

Vertical-only concepts:
- `TABLE`;
- `KITCHEN_TICKET`;
- `PREPARATION_STATION`;
- `DINE_IN / TAKEAWAY / DELIVERY`;
- semáforo de preparación.

Estos NO entran al Core universal.

---

## 4. Adaptador inicial: Café Don Zacarías

Tipo conceptual:
`AGRICULTURE + PROCESSING + MANUFACTURING + WHOLESALE + RETAIL`

Debe poder representar como mínimo:

### Producción agrícola
- finca;
- parcela/lote agrícola;
- variedad;
- campaña;
- cosecha;
- volumen;
- fecha;
- calidad;
- humedad;
- productor/origen.

### Transformación
- cereza → pergamino;
- pergamino → verde;
- verde → tostado;
- tostado → molido;
- empaque.

Cada transformación:
- consume lote(s);
- produce lote(s);
- conserva trazabilidad;
- registra merma/rendimiento;
- costo;
- responsable;
- equipo;
- fecha.

### Calidad
- humedad;
- defectos;
- clasificación;
- puntuación/catación;
- evidencia;
- estado de calidad.

### Comercial
- café verde;
- tostado;
- molido;
- mayorista;
- retail;
- exportación futura;
- cliente;
- lote vendido;
- margen por lote/canal.

Capacidades universales reutilizadas:
- inventario;
- lotes;
- producción;
- costos;
- personas;
- proveedores;
- clientes;
- ventas;
- pagos;
- compras;
- documentos;
- compliance;
- Growth Engine.

---

## 5. Adaptador inicial: Chocolates La Florita

Tipo conceptual:
`MANUFACTURING + RETAIL + WHOLESALE`

Debe soportar:
- insumos;
- formulación/receta;
- lote de producción;
- transformación;
- rendimiento/merma;
- fecha elaboración;
- lote terminado;
- presentación/empaque;
- barras;
- chocolatitos;
- polvo;
- cascarilla;
- futuras líneas/productos;
- costo por lote/unidad;
- precio por canal;
- retail/mayorista;
- clientes;
- stock;
- trazabilidad;
- calidad;
- incidencias.

No crear tablas `barra_chocolate_*` en el Core.

Usar:
- ITEM;
- FORMULATION/BOM;
- PRODUCTION_BATCH;
- TRANSFORMATION;
- INVENTORY_MOVEMENT;
- QUALITY_EVENT;
- SALE.

---

## 6. Cómo se agrega cualquier negocio futuro

Antes de crear un vertical nuevo se responde:

1. ¿Qué vende o entrega al cliente?
2. ¿Qué recursos consume?
3. ¿Transforma algo?
4. ¿Trabaja por stock, cita, proyecto, lote, suscripción, habitación, viaje u otra unidad?
5. ¿Qué evento crea ingreso?
6. ¿Qué evento crea costo?
7. ¿Qué proceso limita capacidad?
8. ¿Qué significa cliente recurrente?
9. ¿Qué significa calidad?
10. ¿Qué obligaciones/reglas afectan el negocio?

Luego se intenta cubrir el nuevo rubro usando capacidades existentes.

Solo si existe una necesidad genuinamente nueva se añade una capacidad reutilizable.

Nunca modificar el Core solo porque un rubro usa un nombre diferente.

---

## 7. Ejemplos de verticales futuros

Sin implementarlos todavía, la arquitectura debe poder soportar:

- restaurante;
- cafetería;
- retail/minimarket;
- importadora;
- e-commerce;
- agricultura;
- fábrica;
- servicios profesionales;
- taller;
- clínica/consultorio con compliance especializado;
- hotel;
- transporte/logística;
- construcción;
- distribuidora;
- educación;
- mantenimiento;
- SaaS;
- suscripciones;
- franquicias;
- negocios mixtos.

Cada uno activa combinaciones diferentes de capacidades.

---

## 8. Growth Engine universal

El motor de crecimiento no pregunta primero `¿cuantas pizzas vendiste?`.

Pregunta universalmente:

```text
¿Cual es tu objetivo economico?
¿Que resultado observaste?
¿Que brecha existe?
¿Que proceso o palanca explica mejor esa brecha?
¿Que accion ejecutable tiene mayor valor ahora?
¿Que ocurrió después?
```

Palancas universales:
- adquisición;
- conversión;
- ticket/mix;
- margen;
- recompra/retención;
- disponibilidad;
- capacidad;
- productividad;
- merma;
- costos;
- calidad;
- continuidad.

La traducción cambia por vertical:

### VANSAM
- pizzas/tickets/clientes/tiempos.

### Café
- kg/qq/lotes/rendimiento/calidad/canal.

### Chocolate
- lotes/unidades/rendimiento/mix/canal.

El motor económico sigue siendo el mismo.

---

## 9. KPI architecture

Separar:

### KPI UNIVERSAL
- ventas;
- contribución;
- costos;
- margen;
- disponibilidad;
- productividad;
- clientes nuevos/recurrentes;
- recurrencia;
- incidencias;
- cumplimiento de objetivo;
- cash/cobertura según datos disponibles.

### KPI VERTICAL
Ejemplos:
- tiempo de cocina;
- ocupación hotelera;
- rendimiento de tostado;
- humedad de café;
- merma de chocolate;
- utilización de técnico;
- entregas a tiempo.

### KPI CONFIGURABLE
Cada empresa puede añadir objetivos/indicadores propios sin cambiar el Core.

---

## 10. Regla contra sobreingeniería

Universal no significa construir todos los módulos antes de tener usuarios.

Secuencia:

1. Core universal sólido.
2. VANSAM valida operación/ventas/growth.
3. Café Zacarías valida agricultura + lotes + transformación.
4. Chocolates La Florita valida manufactura + formulación + lotes.
5. Negocio externo valida portabilidad fuera de IQHOLDING.
6. Nuevos verticales se incorporan por evidencia real.

La universalidad se demuestra por portabilidad, no por cantidad de tablas anticipadas.

---

## 11. Prueba de universalidad del Core

Antes de declarar IQ GROWTH verdaderamente multisectorial debe demostrarse que:

- VANSAM funciona sin lógica restaurante en el Core;
- Café puede usar el mismo Core sin deformarlo;
- Chocolate puede usar el mismo Core sin deformarlo;
- un negocio externo de otro rubro puede activarse sin reescribir la arquitectura;
- datos, seguridad y Growth Engine permanecen aislados por empresa/sucursal;
- cada vertical puede evolucionar sin romper a los demás.

Gate:
`MULTI_VERTICAL_CORE_VALIDATED`

---

## 12. Primeros tres laboratorios

Orden de validación funcional:

### Lab 1 — VANSAM
Valida:
- operación diaria;
- ventas;
- pedidos;
- personal;
- costos variables;
- incidencias;
- CRM;
- decisión diaria/growth.

### Lab 2 — Café Don Zacarías
Valida:
- agricultura;
- lotes;
- transformación;
- calidad;
- trazabilidad;
- producción;
- mayorista/exportación futura.

### Lab 3 — Chocolates La Florita
Valida:
- manufactura;
- formulaciones;
- lotes;
- merma/rendimiento;
- empaque;
- retail/mayorista.

Estos tres laboratorios son complementarios: juntos prueban comercio, servicio, producción, agricultura y manufactura sin convertir el Core en uno de ellos.

---

**Estado:** `UNIVERSAL_VERTICAL_FRAMEWORK_DEFINED`
**CEO_ACTION_REQUIRED:** false
