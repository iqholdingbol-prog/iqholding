# IQG-100 — VANSAM Daily Log V1

**Fecha:** 2026-09-12
**Propósito:** capturar ciclos operativos reales con el mínimo esfuerzo posible mientras el POS definitivo no está disponible.

## Principio

El registro diario debe ser suficientemente corto para completarse todos los días operativos y suficientemente preciso para alimentar IQ GROWTH.

No pedir datos que el sistema pueda derivar automáticamente en el futuro.

El calendario de operación es configurable. Un día planificado como descanso NO cuenta como cierre, falla ni pérdida de disponibilidad.

## 1. Calendario operativo VANSAM

Configuración vigente:
- miércoles: operativo;
- jueves: operativo;
- viernes: operativo;
- sábado: operativo;
- domingo: operativo;
- lunes: operativo;
- martes: descanso planificado.

Un `OPERATING_CYCLE` completo de VANSAM contiene **6 días operativos**: miércoles → lunes.

Martes se registra como `PLANNED_CLOSED` y no reduce `OPERATING_AVAILABILITY`.

## 2. Apertura y continuidad

Por cada día operativo:
- fecha;
- día de semana;
- estado planificado: `OPEN / PLANNED_CLOSED`;
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
- cierre total no planificado del día: sí/no + motivo.

## 3. Personal

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

## 4. Ventas

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

## 5. Compras y costos

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

## 6. Faltantes

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

## 7. Incidencias operativas

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

## 8. Confusores del día

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

## 9. Cierre diario mínimo

La pantalla final debe poder resumirse así:

```text
VANSAM · FECHA

PLAN:          OPEN
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

Para martes:

```text
VANSAM · MARTES
PLAN: PLANNED_CLOSED
Motivo: descanso semanal
```

No debe pedir cierre ni ventas como si fuera un día fallido.

## 10. Datos que IQ GROWTH deriva después

No pedir manualmente:
- venta promedio por día operativo;
- volumen promedio;
- mix porcentual;
- tendencia por ciclo;
- disponibilidad operativa;
- venta por hora;
- contribución estimada;
- brecha contra cobertura;
- frecuencia de faltantes;
- puntualidad;
- recurrencia de incidencias por sector/responsable.

El sistema los calcula.

## 11. Gate por ciclo operativo

Después de **1 ciclo operativo completo (miércoles → lunes, 6 días operativos)**:

`OPERATING_CYCLE_BASELINE_INITIAL` si:
- cada día operativo planificado tiene registro;
- ventas y volumen están presentes;
- cierres/interrupciones están explicados;
- costos nuevos relevantes están registrados;
- faltantes/incidencias tienen trazabilidad básica.

Para una línea base más robusta, comparar al menos **2 ciclos operativos completos (12 días operativos dentro de 14 días calendario)**.

Si un día operativo se cierra inesperadamente, NO se elimina de la muestra: se registra como cierre no planificado y se mide su impacto.

Un martes planificado cerrado NO es una interrupción.

## 12. Evolución futura

Cuando exista POS IQ GROWTH:
- ventas y pedidos se capturan automáticamente;
- asistencia desde terminal autorizada;
- compras por captura rápida/foto/IA;
- incidencias por POS/KDS/WhatsApp autenticado;
- cierre diario propone datos y el responsable solo confirma/explica excepciones.

**Estado:** `READY_FOR_OPERATING_CYCLE_FIELD_USE`
