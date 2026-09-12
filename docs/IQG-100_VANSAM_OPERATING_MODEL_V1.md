# IQG-100 — VANSAM Operating Model V1

**Estado:** diseño operativo previo a piloto / no implementación automática  
**Fecha:** 2026-09-12  
**Autoridad:** Iván Quea — CEO / Product Owner  
**Objetivo:** definir cómo debe operar VANSAM de forma estable sin depender de la presencia permanente de Iván o Samira y separar claramente la operación actual de la operación objetivo.

---

## 1. Principio central

VANSAM necesita dos modelos paralelos para no falsear su economía:

### ESCENARIO A — OPERACIÓN ACTUAL REAL
Representa cómo funciona hoy, con estructura incompleta y trabajo directo de los dueños.

### ESCENARIO B — OPERACIÓN OBJETIVO ESTABLE
Representa cómo debe funcionar cuando pueda abrir de forma continua con personal suficiente aunque Iván o Samira no estén sosteniendo físicamente cada puesto.

El punto de equilibrio estratégico debe evaluarse principalmente contra el Escenario B. El Escenario A sirve para medir transición y caja real actual, pero puede subestimar el costo de una operación escalable.

---

## 2. Calendario confirmado actual

Días planificados de apertura:
- lunes;
- miércoles;
- jueves;
- viernes;
- sábado;
- domingo.

Día de descanso:
- martes.

Horario comercial:
- apertura al público: 16:00;
- fin de servicio en mesa: 23:00;
- fin de pedidos para llevar: 23:30;
- después de 23:30: limpieza y cierre por sector.

La hora de cierre comercial NO es equivalente a la hora de salida del personal.

El sistema debe registrar separadamente:
- `OPEN_TO_PUBLIC_AT`;
- `TABLE_SERVICE_CLOSE_AT`;
- `TAKEAWAY_CLOSE_AT`;
- `CLEANING_STARTED_AT`;
- `SECTOR_CLEANING_COMPLETED_AT`;
- `STAFF_CLOCK_OUT_AT` cuando exista control de asistencia.

No usar ventas después de 23:30 como comportamiento normal sin una excepción registrada.

---

## 3. Oferta operacional actual

### Pizza
Oferta principal todos los días de apertura.

### Hamburguesas
Plan operacional actual:
- viernes;
- sábado;
- domingo.

Samira participa directamente en la preparación/operación de hamburguesas durante estos días.

### Compras / abastecimiento
Samira realiza compras de insumos en días distintos de viernes, sábado y domingo según necesidad operativa.

El sistema futuro debe separar:
- compra;
- recepción;
- ingreso de stock;
- validación de precio;
- uso/consumo;
- merma;
- responsable.

---

## 4. Escenario A — operación actual real

### Personas activas

#### Samira
Funciones actuales aproximadas:
- administración cotidiana;
- operación del local;
- producción según necesidad;
- hamburguesas fines de semana;
- compras de insumos;
- coordinación del apoyo eventual;
- resolución de incidencias.

Remuneración actual declarada:
- Bs 2.500/mes.

Estado: `CONFIRMED_CURRENT`.

#### Iván
Funciones actuales aproximadas cuando está presente:
- dirección/decisión;
- apoyo operativo;
- control económico;
- compras/gestión según necesidad;
- desarrollo de IQ GROWTH/VANSAM.

No tiene salario fijo actualmente.

Sus gastos personales o de presencia (alimentación y otros) NO se clasifican automáticamente como salario ni costo operativo definitivo. Deben registrarse como `PENDING_CLASSIFICATION` hasta documentar su naturaleza.

#### Apoyo eventual
Amiga de Samira:
- lunes;
- miércoles;
- viernes;
- sábado.

Costo declarado:
- Bs 88 por jornada incluyendo cena.

Para análisis mensual inicial puede normalizarse, pero el sistema real debe calcular por turnos efectivamente trabajados, no por promedio fijo.

---

## 5. Problema estructural del Escenario A

La operación actual no es suficiente como modelo de escala porque:
- depende directamente de los dueños;
- existe déficit de personal;
- la continuidad histórica se ha visto afectada por viajes/cierres;
- no hay hornero/armador fijo;
- no hay mesera/cajera estable;
- la ausencia de personal fijo reduce artificialmente algunos costos actuales;
- la capacidad real de crecimiento no puede evaluarse usando solo esta estructura.

Por tanto:

> **El costo actual observado NO es equivalente al costo sostenible de VANSAM.**

---

## 6. Escenario B — operación objetivo estable

Objetivo operacional:

> VANSAM debe poder cumplir su calendario y horario comercial sin cerrar por ausencia de Iván o Samira.

### Roles mínimos objetivo

#### R1 — Administrador/a de local
Responsable de:
- apertura operativa;
- cierre;
- caja/control;
- coordinación de personal;
- incidencias;
- compras o autorización de compras;
- continuidad del servicio;
- revisión de indicadores básicos.

Samira puede ocupar inicialmente este rol, pero el sistema debe modelarlo como rol empresarial y no como dependencia personal irreemplazable.

#### R2 — Hornero / armador de pizzas
Responsable de:
- mise en place de pizza;
- armado;
- horneado;
- tiempos;
- calidad;
- orden y limpieza de su sector;
- reporte de faltantes/mermas.

Objetivo: evitar que una sola persona tenga que alternar continuamente entre armado, horno y otras funciones incompatibles.

Salario definitivo: `PENDING_CONFIRMATION`.

La referencia histórica de Bs 3.300 no debe entrar al baseline como costo confirmado hasta cerrar contratación real.

#### R3 — Mesera / cajera
Responsable de:
- atención en salón;
- toma/confirmación de pedido;
- caja dentro de los permisos definidos;
- entrega de pedidos;
- coordinación salón/llevar;
- limpieza/orden de su sector;
- captura correcta de tipo de pedido y cliente cuando corresponda.

Costo/forma contractual: `PENDING_CONFIRMATION`.

#### R4 — Apoyo operativo flexible
Puede cubrir:
- picos de demanda;
- fines de semana;
- limpieza;
- preparación auxiliar;
- apoyo de salón;
- contingencias.

No sustituye estructuralmente a R2 o R3 si esos puestos son necesarios para capacidad y continuidad.

---

## 7. Turno conceptual

La jornada debe distinguir fases:

### PRE-APERTURA
Antes de 16:00:
- mise en place;
- stock crítico;
- caja;
- limpieza inicial;
- equipos;
- insumos;
- preparación de estación.

Hora exacta de ingreso requerida por rol: `TO_MEASURE`.

### SERVICIO 1
16:00–23:00:
- salón + para llevar.

### SERVICIO 2
23:00–23:30:
- no se abren nuevas mesas salvo excepción;
- continúa para llevar;
- pueden iniciarse tareas de cierre que no afecten pedidos activos.

### CIERRE
Desde 23:30:
- limpieza por sector;
- stock/incidencias;
- cierre de caja;
- residuos/merma;
- preparación mínima para el próximo día;
- salida del personal cuando su sector esté limpio y entregado.

La política debe evitar que “fin de venta” se convierta en “fin instantáneo de jornada”.

---

## 8. Propiedad por sector

Cada rol debe cerrar y entregar su sector.

Ejemplos conceptuales:

- cocina/pizza → estación, horno, superficies, insumos críticos;
- salón/caja → mesas, caja, POS, área de atención;
- hamburguesas/fritura → estación específica cuando opere;
- administración → cierre operativo final.

La limpieza no debe quedar como tarea difusa de “todos” porque eso dificulta atribuir incumplimientos y tiempo real de cierre.

---

## 9. Continuidad operacional como KPI principal

IQ GROWTH debe medir:

`PLANNED_OPEN_DAYS`

`ACTUAL_OPEN_DAYS`

`OPERATIONAL_AVAILABILITY = ACTUAL_OPEN_DAYS / PLANNED_OPEN_DAYS`

Además:
- horas planificadas;
- horas realmente operadas;
- cierres completos;
- cierres parciales;
- apertura tardía;
- cierre temprano;
- motivo;
- responsable de resolución;
- venta/contribución estimada no realizada por indisponibilidad, marcada siempre como estimación.

Categorías iniciales de causa:
- falta de personal;
- viaje/ausencia de responsable;
- enfermedad;
- equipo/horno;
- stock/faltante;
- fuerza mayor;
- decisión comercial planificada;
- otro documentado.

No usar continuidad como mecanismo disciplinario automático contra personas.

---

## 10. Capacidad

Antes de perseguir 30–50 pizzas/día debe medirse capacidad real.

Campos mínimos:
- pedidos/hora;
- pizzas/hora;
- tiempo pedido→inicio preparación;
- tiempo preparación;
- tiempo horno;
- tiempo total;
- cola máxima;
- pedidos retrasados;
- cancelaciones por demora;
- capacidad simultánea del horno;
- saturación por franja horaria.

El semáforo de cocina 4–6–8 minutos continúa como objetivo de producto/UX, pero debe validarse contra tiempos reales y equipamiento real antes de considerarlo SLA definitivo.

---

## 11. Indicadores por rol

Los KPIs deben medir proceso, no solo resultados económicos.

### Administrador/a
- apertura a tiempo;
- disponibilidad operacional;
- cierre completo;
- incidencias resueltas;
- caja conciliada cuando el sistema lo permita;
- datos de compras/costos actualizados.

### Hornero/armador
- tiempo de preparación/horno;
- pedidos fuera de objetivo;
- reprocesos;
- merma atribuible verificable;
- calidad/incidencias;
- limpieza del sector.

### Mesera/cajera
- exactitud de pedido;
- tipo de pedido correctamente registrado;
- tiempos de atención;
- quejas verificables;
- entrega correcta;
- limpieza del sector.

No convertir automáticamente KPIs en sanciones o descuentos laborales. Cualquier consecuencia laboral debe pasar por política y cumplimiento aplicable.

---

## 12. Costos del escenario objetivo

El baseline debe conservar dos resultados:

### CURRENT_STRUCTURE_COST
Costos reales actuales.

### STABLE_OPERATING_STRUCTURE_COST
Costos necesarios para operar sin dependencia permanente de los dueños.

Todavía faltan confirmar:
- salario real hornero/armador;
- costo real mesera/cajera;
- jornadas/turnos;
- cargas/beneficios aplicables;
- costo de comidas del personal cuando corresponda;
- costo de reemplazos/descansos;
- transporte/compras;
- otros costos recurrentes.

No calcular punto de equilibrio definitivo del modelo escalable hasta completar esos datos.

---

## 13. Handoffs obligatorios

Para que el negocio no dependa de conocimiento informal, cada turno debe poder dejar:
- faltantes;
- insumos críticos;
- compras pendientes;
- equipo con problema;
- pedidos/incidencias;
- reclamos;
- caja/operación pendiente;
- limpieza incompleta;
- acción recomendada de IQ GROWTH pendiente.

Un viaje de Iván o Samira no debe implicar pérdida del estado operativo.

---

## 14. Independencia de los dueños

Indicador estratégico futuro:

`OWNER_DEPENDENCY_INDEX`

Debe medir de forma simple qué porcentaje de funciones críticas requiere presencialmente a Iván o Samira.

Objetivo:
- reducirlo progresivamente;
- sin perder control;
- sin crear permisos excesivos;
- con evidencia y reportes remotos.

No necesita implementarse como score complejo en el MVP. Puede comenzar como conteo de funciones críticas con/sin sustituto autorizado.

---

## 15. Vista operador vs vista dueño remoto

### OPERADOR
Necesita:
- qué está pasando ahora;
- qué falta;
- qué acción ejecutar;
- tiempos/capacidad;
- incidencias;
- próximos handoffs.

### DUEÑO REMOTO
Necesita:
- abrió/cerró según plan;
- ventas/volumen;
- margen/contribución estimada;
- tendencia;
- acción aprobada/rechazada;
- incidencias;
- continuidad;
- cambios anómalos en costos;
- dependencia de personas clave.

Ambas vistas consumen los mismos hechos; cambia la prioridad de información.

---

## 16. Gate para considerar VANSAM operativamente estable

No basta con vender más.

Un primer gate conceptual requiere:
- calendario sostenido sin cierres evitables;
- roles críticos cubiertos;
- operación posible sin presencia permanente de ambos dueños;
- compras/costos registrados con frescura suficiente;
- tiempos de cocina observables;
- caja/ventas registradas confiablemente;
- cierre y limpieza por sector;
- handoff diario;
- capacidad suficiente para la meta comercial siguiente.

---

## 17. Próximos datos necesarios

Para cerrar `STABLE_OPERATING_STRUCTURE_COST` se necesita confirmar posteriormente:
- salario/oferta final del hornero-armador;
- modalidad y costo final de mesera-cajera;
- hora real de ingreso de cada rol;
- hora promedio de salida después de limpieza;
- descansos/reemplazos;
- comidas/beneficios asociados;
- si Samira mantiene salario de Bs 2.500 en el escenario estable y qué funciones conserva;
- qué funciones seguirá haciendo Iván y cuáles deben delegarse.

---

## 18. Decisión de arquitectura de producto

IQ GROWTH no optimizará solo:

`VENTAS`

Optimizará el sistema completo:

`CONTINUIDAD → CAPACIDAD → VENTA → CONTRIBUCIÓN → OPERACIÓN SIN DEPENDENCIA EXCESIVA DE LOS DUEÑOS`

Una empresa que vende bien únicamente cuando el dueño está presente todavía no es una operación escalable.

**CEO_ACTION_REQUIRED:** false para este diseño; será true únicamente al aprobar estructura final de personal/costos.