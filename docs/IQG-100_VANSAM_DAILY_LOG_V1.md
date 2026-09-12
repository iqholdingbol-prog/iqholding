# IQG-100 — VANSAM Daily Log V1

**Fecha:** 2026-09-12
**Propósito:** capturar 7 días limpios de operación con el mínimo esfuerzo posible mientras el POS definitivo no está disponible.

## Principio

El registro diario debe ser suficientemente corto para completarse todos los días y suficientemente preciso para alimentar IQ GROWTH.

No pedir datos que el sistema pueda derivar automáticamente en el futuro.

## 1. Apertura y continuidad

- fecha;
- día de semana;
- apertura planificada: 16:00;
- apertura real;
- motivo si apertura tardía;
- cierre salón planificado: 23:00;
- último pedido salón;
- cierre para llevar planificado: 23:30;
- último pedido para llevar;
- hora final de limpieza/cierre;
- minutos/horas de interrupción durante el turno;
- motivo de interrupción;
- cierre total del día: sí/no + motivo.

## 2. Personal

Por persona:
- rol;
- hora entrada;
- hora salida;
- ausencia/retraso;
- corrección de marcación si existe;
- evidencia/actor que aprobó corrección.

Roles iniciales:
- Samira;
- hornero/armador;
- mesera/cajera;
- apoyo eventual;
- administrador futuro.

## 3. Ventas

Registrar al cierre:
- ventas totales Bs;
- pedidos totales;
- pizzas pequeñas;
- pizzas medianas;
- pizzas grandes;
- hamburguesas;
- bebidas;
- café/chocolate/frappé u otras categorías relevantes;
- cancelaciones/devoluciones si existen.

Forma de pago puede añadirse cuando la operación la controle con suficiente confiabilidad.

## 4. Compras y costos

Por cada compra del día:
- insumo/producto;
- cantidad;
- unidad/presentación;
- monto total;
- proveedor cuando se conozca;
- foto/nota/factura opcional como evidencia;
- responsable de compra;
- responsable de ingreso al stock.

Un precio nuevo nunca modifica compras históricas.

## 5. Faltantes

Registrar todo producto solicitado que no pudo venderse/producirse por falta de stock.

Campos:
- producto/insumo faltante;
- hora;
- pedido afectado si existe;
- quien reporta;
- proceso/sector;
- responsable funcional configurado;
- causa declarada;
- respuesta del responsable;
- estado.

No equivale automáticamente a culpa.

## 6. Incidencias operativas

Categorías mínimas:
- stock;
- preparación;
- masa;
- horno/equipo;
- atención;
- caja;
- personal;
- retraso;
- limpieza/orden;
- proveedor;
- sistema/tecnología;
- otro.

Campos:
- hora;
- reportante;
- descripción;
- responsable funcional;
- impacto;
- evidencia opcional;
- respuesta;
- resuelto/pending.

Nunca borrar una incidencia; una corrección crea un nuevo evento.

## 7. Confusores del día

Solo si ocurrieron:
- lluvia/clima severo;
- bloqueo/transporte;
- feriado/evento;
- promoción;
- cambio de precio;
- enfermedad;
- falla de equipo;
- cierre parcial;
- falta de personal;
- otro evento material.

## 8. Cierre diario mínimo

La pantalla final debe poder resumirse así:

```text
VANSAM · FECHA

ABIERTO:       sí / parcial / no
VENTAS:        Bs X
PEDIDOS:       X
PIZZAS:        P X · M X · G X
OTROS:         X
FALTANTES:     X
INCIDENCIAS:   X
APERTURA REAL: HH:MM
CIERRE REAL:   HH:MM

[CONFIRMAR CIERRE]
```

## 9. Datos que IQ GROWTH deriva después

No pedir manualmente:
- venta promedio;
- pizzas promedio;
- mix porcentual;
- tendencia 7 días;
- disponibilidad operativa;
- venta por hora;
- contribución estimada;
- brecha contra cobertura;
- frecuencia de faltantes;
- puntualidad;
- recurrencia de incidencias por sector/responsable.

El sistema los calcula.

## 10. Gate de 7 días

Después de 7 días planificados:

`7_DAY_CLEAN_WINDOW_READY` si:
- cada día planificado tiene registro;
- ventas y volumen están presentes;
- cierres/interrupciones están explicados;
- costos nuevos relevantes están registrados;
- faltantes/incidencias tienen trazabilidad básica.

Si un día se cierra, NO se elimina de la muestra: se registra como cierre y se mide su impacto.

## 11. Evolución futura

Cuando exista POS IQ GROWTH:
- ventas y pedidos se capturan automáticamente;
- asistencia desde terminal autorizada;
- compras por captura rápida/foto/IA;
- incidencias por POS/KDS/WhatsApp autenticado;
- cierre diario propone datos y el responsable solo confirma/explícita excepciones.

**Estado:** `READY_FOR_7_DAY_FIELD_USE`
