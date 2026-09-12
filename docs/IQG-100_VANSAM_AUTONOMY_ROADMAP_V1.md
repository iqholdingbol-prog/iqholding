# IQG-100 — VANSAM Autonomy Roadmap V1

**Fecha:** 2026-09-12
**Objetivo:** llevar VANSAM desde una operación dependiente de Iván/Samira hacia una operación estable, medible y replicable.

## Principio

VANSAM no está lista para escalar mientras una ausencia de Iván o Samira pueda cerrar el local o detener una función crítica.

La autonomía se mide por procesos, no por intención.

## Fase 0 — Datos limpios y continuidad por ciclo operativo

Objetivo inmediato:
- completar al menos 1 ciclo operativo configurado de VANSAM: miércoles → lunes = 6 días operativos;
- martes es `PLANNED_CLOSED` y no cuenta como falla;
- registrar venta diaria, pizzas por tamaño, otros productos, horarios reales, cierres, faltantes e incidencias;
- registrar costos nuevos de insumos por compra sin reescribir historia;
- medir disponibilidad operativa solo contra días/horas planificados como abiertos.

Primer gate:
`OPERATING_CYCLE_BASELINE_INITIAL`

Baseline más robusto:
- comparar al menos 2 ciclos operativos completos = 12 días operativos dentro de 14 días calendario.

## Fase 1 — Equipo mínimo estable

Roles:
- hornero/armador;
- mesera/cajera;
- Samira como administradora transitoria y responsable de masa/compras;
- apoyo puntual solo cuando la carga lo justifique.

Cada rol debe tener:
- jornada;
- salario/pago real;
- costo formal estimado;
- funciones;
- sector propio;
- check-in/check-out;
- incidencias;
- responsable de respaldo.

Gate:
`STAFFING_MINIMUM_STABLE`

## Fase 2 — Responsabilidades por sector

### Cocina pizza
Responsable principal: hornero/armador.

Incluye:
- toppings;
- mise en place;
- armado;
- horno;
- tiempos;
- orden y limpieza de cocina;
- faltantes de su sector.

Masa permanece temporalmente con Samira.

### Sala/caja
Responsable principal: mesera/cajera.

Incluye:
- caja;
- atención;
- bebidas;
- aderezos;
- reposición visible de sala;
- orden y limpieza;
- incidencias de falta de producto en sala.

### Compras/abastecimiento
Responsable transitorio: Samira.

Incluye:
- compras de insumos;
- recepción/carga de precios;
- stock crítico;
- Coca-Cola/bebidas y abastecimiento general;
- evidencia de factura/nota/foto.

### Hamburguesas
Responsable transitorio: Samira viernes/sábado/domingo.

Debe existir plan para transferir esta función cuando el volumen lo justifique.

Gate:
`RESPONSIBILITY_MATRIX_OPERATING`

## Fase 3 — Sacar a Iván de la operación

Estado esperado:
- Iván no cocina;
- no atiende caja;
- no compra insumos rutinarios;
- no resuelve cada incidencia;
- supervisa remotamente.

Vista CEO:
- apertura/cierre;
- ventas;
- contribución estimada;
- disponibilidad;
- faltantes;
- incidencias críticas;
- responsables;
- acción prioritaria;
- tendencia por ciclo operativo.

Gate:
`CEO_REMOTE_ONLY`

## Fase 4 — Sacar a Samira de las funciones críticas

Objetivo:
Samira pasa de administradora operativa a socia/supervisora.

Funciones a transferir:
1. administración diaria → administrador/a;
2. compras → administrador/compras;
3. stock → responsable + sistema;
4. hamburguesas → cocina;
5. masa → procedimiento protegido.

### Problema especial: receta de masa

Samira quiere proteger su receta.

Opciones a diseñar:
- premezcla secreta preparada por ella por lotes;
- componente secreto dosificado;
- receta cifrada con acceso restringido y auditado;
- producción centralizada de premezcla para futuras sucursales.

La solución debe proteger IP sin convertir a Samira en cuello de botella diario.

Gate:
`SAMIRA_NOT_OPERATION_CRITICAL`

## Fase 5 — Operación autónoma demostrada

Requisito sugerido antes de expansión:
- local opera varios ciclos operativos sin cierre por ausencia de socios;
- horarios cumplidos;
- incidencias registradas/resueltas;
- costos frescos;
- caja/ventas confiables;
- equipo puede abrir, operar y cerrar sin socios;
- rendimiento no cae materialmente cuando Iván/Samira no están.

Gate:
`VANSAM_AUTONOMOUS`

## Fase 6 — Growth

Solo después:
- estabilizar 30 pizzas/día;
- buscar 50 pizzas/día;
- validar capacidad horno/cocina/sala;
- adquisición/CRM/recompra;
- TV 42 como cross-sell inteligente;
- marketing medido;
- margen por producto;
- segundo local/piloto replicable.

Nunca escalar volumen por encima de capacidad o destruyendo margen.

## Indicador estratégico de autonomía

`OWNER_DEPENDENCY_RATE`

Medir cuánto de la operación crítica todavía depende personalmente de Iván o Samira.

Ejemplos de procesos críticos:
- apertura;
- masa;
- compras;
- caja;
- cocina;
- cierre;
- solución de faltantes;
- decisiones urgentes.

Objetivo:
`OWNER_DEPENDENCY_RATE → 0%` para operación diaria normal.

Los socios pueden seguir tomando decisiones estratégicas sin ser necesarios para mantener el local abierto.

**Estado:** `AUTONOMY_ROADMAP_DEFINED`
**CEO_ACTION_REQUIRED:** false.