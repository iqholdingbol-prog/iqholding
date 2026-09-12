# IQG-100 — VANSAM BASELINE V1

**Fecha de corte:** 2026-09-12  
**Estado:** `BASELINE_PARTIAL_READY`  
**Fuente principal:** datos actuales declarados por Iván Quea para VANSAM  
**Uso:** diseño y calibración del piloto IQ GROWTH; NO contabilidad fiscal ni utilidad distribuible.

---

## 1. Regla de evidencia

Estados usados:

- `OWNER_CONFIRMED_CURRENT`: dato actual declarado por propietario/operador.
- `OWNER_PROVIDED_SNAPSHOT`: snapshot de precios/costos suministrado por propietario; debe conservar fecha.
- `SYSTEM_CALCULATED`: derivación aritmética a partir de datos confirmados.
- `ESTIMATED`: aproximación sujeta a supuestos explícitos.
- `PENDING_CLASSIFICATION`: hecho real cuya naturaleza económica/contable aún no debe inferirse.
- `UNKNOWN`: no disponible todavía.

Ningún cálculo en este documento debe llamarse utilidad neta contable mientras falten costos, clasificación de retiros/gastos, impuestos y demás componentes materiales.

---

## 2. Calendario operativo actual

- Día de descanso programado: **martes** — `OWNER_CONFIRMED_CURRENT`.
- Días planificados de operación: **6 días/semana** — `SYSTEM_CALCULATED`.
- Días operativos promedio por mes: **26** (= 6 × 52 / 12) — `SYSTEM_CALCULATED`.
- Inicio de atención: **16:00** — `OWNER_CONFIRMED_CURRENT`.
- Servicio en mesa: hasta **23:00** — `OWNER_CONFIRMED_CURRENT`.
- Para llevar: hasta **23:30** — `OWNER_CONFIRMED_CURRENT`.
- Después de 23:30: personal limpia únicamente su lugar/sector de trabajo; este tiempo es **cierre operativo**, no ventana de venta — `OWNER_CONFIRMED_CURRENT`.
- Hamburguesas: oferta prevista **viernes, sábado y domingo** — `OWNER_CONFIRMED_CURRENT`.

### Regla de modelado de horario

Separar:

`SALES_OPEN_AT = 16:00`

`DINE_IN_LAST_ORDER / SERVICE_END = 23:00`

`TAKEAWAY_LAST_ORDER = 23:30`

`CLOSING_CLEANUP_START >= 23:30`

La hora final de salida del personal queda `UNKNOWN` hasta medirla.

---

## 3. Personal actual y estructura de costo

### 3.1 Personas activas actualmente

1. **Samira**
   - rol operativo principal / encargada;
   - remuneración asignada: **Bs 2.500/mes** — `OWNER_CONFIRMED_CURRENT`;
   - también asumirá hamburguesas fines de semana;
   - compras de insumos se realizan fuera de viernes/sábado/domingo según operación actual.

2. **Iván**
   - trabaja actualmente en VANSAM;
   - sueldo empresarial actual: **Bs 0** — `OWNER_CONFIRMED_CURRENT`;
   - desayuno, almuerzo, cena y otros gastos personales cubiertos durante su presencia NO se clasifican automáticamente como costo salarial ni gasto operativo: `PENDING_CLASSIFICATION` hasta cuantificar y definir naturaleza.

3. **Apoyo eventual — amiga de Samira**
   - costo por turno: **Bs 88**, cena incluida — `OWNER_CONFIRMED_CURRENT`;
   - días habituales: lunes, miércoles, viernes y sábado = 4 turnos/semana.
   - costo mensual normalizado: **Bs 1.525,33** (= 88 × 4 × 52 / 12) — `SYSTEM_CALCULATED`.

### 3.2 Vacantes / estructura futura

Actualmente NO hay:
- hornero/armador fijo;
- mesera/cajera fija.

Ambos están en búsqueda. Sus salarios NO forman parte del costo actual hasta contratación.

El sistema debe mantener dos escenarios separados:

- `CURRENT_ACTUAL_STRUCTURE`: estructura vigente real.
- `TARGET_STABLE_STRUCTURE`: estructura con personal necesario para operar sin dependencia directa de Iván/Samira; pendiente de salarios definitivos.

No usar el escenario actual reducido para afirmar que el modelo escalable ya es rentable.

---

## 4. Costos conocidos actuales

| Concepto | Bs/mes | Estado |
|---|---:|---|
| Alquiler | 2.000,00 | OWNER_CONFIRMED_CURRENT |
| Luz | 450,00 | OWNER_CONFIRMED_CURRENT |
| Agua | 150,00 | OWNER_CONFIRMED_CURRENT |
| Internet | 50,00 | OWNER_CONFIRMED_CURRENT |
| Remuneración Samira | 2.500,00 | OWNER_CONFIRMED_CURRENT |
| Apoyo eventual normalizado | 1.525,33 | SYSTEM_CALCULATED |
| **Total estructura actual conocida** | **6.675,33** | SYSTEM_CALCULATED |

### Exclusiones actuales

No están incluidos todavía:
- remuneración futura de hornero/armador;
- remuneración futura de mesera/cajera;
- gastos personales de Iván pendientes de clasificación;
- impuestos;
- mantenimiento/depreciación;
- transporte de compras actual si existe;
- mermas no medidas;
- otros costos administrativos;
- costos variables de bebidas/café/chocolate/hamburguesas cuando no estén suficientemente documentados.

---

## 5. Ventas y volumen actuales cuando VANSAM abre

- POS actualmente fuera de operación; control manual diario en papel — `OWNER_CONFIRMED_CURRENT`.
- Venta bruta promedio por día abierto: **~Bs 800** — `OWNER_CONFIRMED_CURRENT`, confianza `MEDIUM` por registro manual.
- Pizzas promedio por día abierto: **~12** — `OWNER_CONFIRMED_CURRENT`.
- Rango habitual actual: **8–16 pizzas/día** — `OWNER_CONFIRMED_CURRENT`.
- Histórico previo a cierres: **15–20 pizzas/día** — referencia histórica, no baseline actual.

### Importante

`Bs 800 / 12 pizzas = ~Bs 66,67 por pizza-equivalente` es solo una relación aritmética agregada. NO es ticket promedio si las ventas incluyen bebidas, café u otros productos.

---

## 6. Continuidad — confusor crítico

En los últimos 30 días VANSAM estuvo cerrado aproximadamente **3 semanas o más**, principalmente por viajes/desplazamientos de los responsables — `OWNER_CONFIRMED_CURRENT`.

Por tanto:

- NO usar los últimos 30 días como un mes operativo normal;
- distinguir `OPEN_DAY_PERFORMANCE` de `CALENDAR_MONTH_PERFORMANCE`;
- toda comparación debe registrar días y horas realmente abiertas;
- el compromiso operativo actual es no volver a cerrar por viajes personales hasta que el negocio pueda operar solo.

`CONTINUITY` es una variable causal/operativa de primer nivel para el piloto.

---

## 7. Snapshot actual de pizza — costos y precios

El propietario suministró un snapshot detallado de costos por producto/tamaño, incluyendo masa, salsa, queso, ingredientes, caja y salsas de acompañamiento.

Indicadores del snapshot:

- margen promedio general listado: **39,6%** — `OWNER_PROVIDED_SNAPSHOT`.
- ejemplos:
  - Napoboom P: costo 23,08 / venta 40 / margen 42,3%;
  - Napoboom M: costo 27,70 / venta 49 / margen 43,5%;
  - Napoboom G: costo 33,16 / venta 69 / margen 51,9%;
  - 4 Estaciones M: costo 41,19 / venta 53 / margen 22,3%;
  - Cereza del Pecado M: costo 42,71 / venta 53 / margen 19,4%;
  - Charque G: costo 41,01 / venta 82 / margen 50,0%;
  - Piqué G: costo 41,95 / venta 82 / margen 48,8%.

El 39,6% NO es todavía el margen ponderado real de VANSAM porque falta conocer el mix efectivo vendido por SKU/tamaño.

---

## 8. Costos base y frescura

El snapshot suministrado contiene costos actuales de insumos y gramajes. Entre los insumos críticos:

- harina;
- manteca/mantequilla;
- mozzarella y otros quesos;
- tomate/salsa;
- jamón, salchicha, chorizo, pepperoni, tocino, carne, charque;
- vegetales y toppings;
- cajas;
- gas.

Los precios de Cochabamba pueden variar bruscamente por disponibilidad, bloqueos y mercado.

### Invariante aprobado

**Un cambio de precio de compra nunca reescribe el costo histórico.**

Ejemplo:

`Harina lote A — Bs 290 — recibido fecha X`

`Harina lote B — Bs 400 — recibido fecha Y`

El lote B afecta costos futuros según el método de inventario/consumo aprobado; nunca modifica ventas o producción pasada.

---

## 9. Captura de compras/costos — requisito de producto

El flujo debe permitir a una encargada autorizada cargar compras de forma simple:

### Entrada manual asistida

Ejemplo libre:

`azúcar quintal 275`

`harina quintal 300`

`cebolla 5`

El sistema propone la estructuración y el usuario confirma.

### Entrada por foto

Foto de factura/nota → IA/OCR propone:
- proveedor;
- fecha;
- insumo;
- presentación/unidad;
- cantidad;
- monto;
- costo unitario;
- correspondencia con catálogo.

Ninguna extracción IA se vuelve dato definitivo sin validación cuando existe ambigüedad o impacto material.

### Detección de anomalías

Si un insumo cambia bruscamente, por ejemplo Bs 290 → Bs 400:

- NO asumir error automáticamente;
- comparar con historia propia;
- detectar posible cero extra/menos, unidad distinta o presentación distinta;
- pedir confirmación/justificación;
- conservar el precio confirmado como nuevo evento.

La búsqueda web/precios externos puede aportar contexto, pero nunca reemplaza el comprobante o confirmación del negocio.

---

## 10. Escenario económico provisional — estructura ACTUAL

Solo para calibración y NO como utilidad neta.

### Supuestos

- 26 días planificados/mes;
- ventas promedio en día abierto: Bs 800;
- margen de contribución provisional: 39,6% del snapshot de pizzas;
- costos mensuales actuales conocidos: Bs 6.675,33;
- se ignoran temporalmente los costos aún no clasificados/listados.

### Derivaciones

- ventas planificadas si abre 26 días: **Bs 20.800/mes**;
- pizzas equivalentes al ritmo actual: **~312/mes**;
- contribución estimada/día: **Bs 316,80**;
- carga mensual actual conocida por día operativo: **Bs 256,74**;
- remanente operativo estimado/día antes de costos omitidos: **~Bs 60,06**;
- contribución estimada mensual: **Bs 8.236,80**;
- remanente mensual antes de costos omitidos: **~Bs 1.561,47**.

### Cobertura provisional

Con el supuesto de 39,6% de contribución:

- ventas necesarias para cubrir la estructura actual conocida: **~Bs 16.857/mes**;
- equivalente por día abierto: **~Bs 648/día**.

### Advertencia crítica

Estos valores NO significan “ganancia neta”. Pueden cambiar materialmente por:

- mix real de productos;
- costos de bebidas/café/hamburguesas;
- mermas;
- impuestos;
- gastos pendientes;
- nuevas contrataciones;
- cierres;
- variación de insumos.

Además, la estructura actual no es todavía la estructura estable necesaria para operar sin los propietarios.

---

## 11. Objetivo del dueño

El objetivo ya no se modelará como un techo fijo.

### Guardia económica

Primero:
- proteger contribución;
- cubrir estructura estable real;
- evitar crecimiento destructivo por descuento/margen insuficiente.

### Escalera de crecimiento inicial

- `STAGE_1`: sostener **30 pizzas/día** con margen y continuidad sanos.
- `STAGE_2`: sostener **50 pizzas/día**.
- `STAGE_3`: explorar **100+ pizzas/día** si capacidad, equipo, personal y demanda lo permiten.

El propósito declarado es vender cada vez más, abrir sucursales y posteriormente evaluar franquicia/expansión nacional, pero el motor nunca debe premiar volumen que destruya margen o servicio.

---

## 12. Vista del operador vs vista del dueño remoto

### Operador (Samira / responsable en local)

Debe priorizar:
- qué ejecutar ahora;
- faltantes;
- capacidad;
- pedidos/servicio;
- compra necesaria;
- anomalías de costo;
- acción comercial dentro de ventana útil.

### Dueño remoto (Iván)

Debe ver:
- ventas Bs y unidades;
- horas/días realmente abiertos;
- tendencia móvil;
- cobertura actual vs estructura estable;
- margen/contribución con calidad declarada;
- acciones propuestas/aprobadas/rechazadas;
- cierres y causas;
- evolución hacia 30/50/100+ pizzas/día.

---

## 13. Datos todavía necesarios para cerrar BASELINE V1

1. Hora habitual de finalización de limpieza/salida del personal.
2. Número exacto de días abiertos/cerrados de una ventana reciente utilizable o iniciar nueva ventana observacional.
3. Venta diaria anotada por fecha durante al menos 7 días continuos de operación.
4. Mix real por tamaño/SKU durante esa ventana.
5. Costos actuales de bebidas, café, chocolate y hamburguesas si entran al mismo análisis.
6. Mermas y consumos relevantes si se quiere pasar de contribución estimada a resultado operativo más preciso.
7. Cuantificación/clasificación de gastos personales de Iván pagados por VANSAM, si corresponden.
8. Salarios definitivos del escenario `TARGET_STABLE_STRUCTURE` cuando se contrate personal.

Hasta entonces:

`BASELINE_PARTIAL_READY`

No `BASELINE_READY`.

---

## 14. Próximo dato operativo mínimo

Desde el próximo día abierto, registrar manualmente aunque el POS siga caído:

- fecha;
- hora apertura real;
- hora último servicio mesa;
- hora último pedido para llevar;
- hora fin limpieza;
- ventas Bs;
- pizzas P/M/G por SKU o al menos por tamaño;
- bebidas/otros Bs;
- cierres/horas perdidas;
- incidencias relevantes.

Con 7 días continuos obtenemos la primera ventana operativa limpia del nuevo compromiso de continuidad.

**CEO_ACTION_REQUIRED:** false — continuar captura real; no hace falta una decisión estratégica adicional para iniciar esta ventana.
