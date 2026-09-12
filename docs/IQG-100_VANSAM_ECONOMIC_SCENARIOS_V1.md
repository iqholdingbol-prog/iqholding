# IQG-100 — VANSAM Economic Scenarios V1

**Estado:** diseño económico preliminar, no contable ni jurídico
**Fecha:** 2026-09-12
**Objetivo:** comparar la economía de VANSAM bajo distintas estructuras reales de personal y cumplimiento, sin confundir caja observada con costo formal.

## 1. Principio

IQ GROWTH debe mostrar simultáneamente:

1. `COSTO_CAJA_OBSERVADO`
2. `COSTO_LABORAL_FORMAL_ESTIMADO`
3. `BRECHA_CUMPLIMIENTO`
4. `COSTO_OPERACION_AUTONOMA`

Nunca usar una sola cifra como si representara todos los escenarios.

## 2. Datos actuales de referencia

- Días planificados abiertos: lunes, miércoles, jueves, viernes, sábado y domingo.
- Martes: descanso.
- Servicio salón: 16:00–23:00.
- Para llevar: hasta 23:30.
- Después: limpieza y cierre por sector.
- Venta actual observada cuando abre: ~Bs 800/día.
- Volumen actual observado: ~12 pizzas/día, rango 8–16.
- Margen promedio listado en pizzas: ~39,6% — provisional hasta revalidar precios/costos frescos.
- Venta promedio implícita por pizza con datos actuales: ~Bs 66,67 — solo equivalencia operativa, no ticket canónico.
- Costos no laborales conocidos: alquiler 2.000 + luz 450 + agua 150 + internet 50 = Bs 2.650/mes.

## 3. Escenario A — OPERACION_ACTUAL_OBSERVADA

Estructura conocida:
- Samira: Bs 2.500/mes.
- apoyo eventual: Bs 88 por turno, 4 días/semana aprox.
- Iván: fuera del costo laboral objetivo; actualmente no debe considerarse trabajador operativo estructural.

Costo mensual conocido normalizado aproximado:
- no laboral: Bs 2.650
- Samira: Bs 2.500
- apoyo eventual: ~Bs 1.525
- total conocido: ~Bs 6.675/mes

Con margen provisional 39,6% y 26 días abiertos/mes:
- ventas mensuales de cobertura aproximada: ~Bs 16.856
- ventas diarias de cobertura aproximada: ~Bs 648
- equivalente aproximado: ~9,7 pizzas/día al mix actual

**Interpretación:** este escenario NO representa una VANSAM autónoma ni plenamente formal; solo describe la caja conocida de la operación actual.

## 4. Escenario B — OPERACION_EQUIPADA_CAJA

Hipótesis de caja propuesta por CEO:
- Samira: Bs 2.500
- hornero/armador: Bs 3.300
- mesera/cajera: Bs 2.000 propuestos
- no laboral: Bs 2.650

Total observado/propuesto de caja: ~Bs 10.450/mes.

Con margen provisional 39,6%:
- ventas mensuales de cobertura aproximada: ~Bs 26.389
- ventas diarias de cobertura aproximada: ~Bs 1.015
- equivalente aproximado: ~15,2 pizzas/día al mix actual

**Regla:** este escenario representa `COSTO_CAJA_PROPUESTO`; NO certifica cumplimiento laboral. El salario de mesera/cajera debe validarse contra jornada/modalidad aplicable.

## 5. Escenario C — OPERACION_FORMAL_INMEDIATA_ESTIMADA

Solo como referencia económica inicial, usando tres puestos nominales de Bs 3.300 y los aportes patronales inmediatos identificados en Compliance Pack BO:

- salario nominal por puesto: Bs 3.300
- SIP patronal: 5,21%
- vivienda patronal: 2,00%
- salud patronal: 10,00%
- costo inmediato referencial por puesto: ~Bs 3.867,93

Para tres puestos equivalentes:
- costo laboral inmediato referencial: ~Bs 11.603,79
- no laboral: Bs 2.650
- total piso inmediato: ~Bs 14.253,79/mes

Con margen provisional 39,6%:
- ventas mensuales de cobertura aproximada: ~Bs 35.994
- ventas diarias de cobertura aproximada: ~Bs 1.384
- equivalente aproximado: ~20,8 pizzas/día al mix actual

**NO incluye** provisiones y contingencias por aguinaldo, vacaciones, indemnización, nocturnidad, extras, domingos/feriados u otros conceptos aplicables. Por tanto, es un **piso**, no el costo formal completo.

## 6. Escenario D — OPERACION_AUTONOMA_FUTURA

Objetivo: VANSAM funciona sin Iván y sin dependencia diaria de Samira.

Roles esperados:
- administrador/a operativo/a;
- hornero/armador;
- mesera/cajera;
- apoyo hamburguesas u otro rol si el volumen lo exige;
- Samira queda como socia/supervisora, no cuello de botella operativo.

El costo de este escenario queda `PENDING_MODEL` hasta definir:
- salario/jornada del administrador;
- cobertura real de hamburguesas;
- reemplazo de la función de masa actualmente retenida por Samira;
- cargas laborales aplicables;
- necesidad de apoyo adicional según volumen.

## 7. Escenarios de volumen

Usando únicamente como equivalencia provisional `Bs 66,67 de venta por pizza` y `39,6% de margen de contribución`:

| Pizzas/día | Ventas/día aprox. | Contribución/día aprox. | Contribución/mes (26 días) | Excedente sobre Escenario C* |
|---:|---:|---:|---:|---:|
| 12 | Bs 800 | Bs 317 | Bs 8.237 | -Bs 6.017 |
| 20 | Bs 1.333 | Bs 528 | Bs 13.728 | -Bs 526 |
| 30 | Bs 2.000 | Bs 792 | Bs 20.592 | +Bs 6.338 |
| 50 | Bs 3.333 | Bs 1.320 | Bs 34.320 | +Bs 20.066 |
| 100 | Bs 6.667 | Bs 2.640 | Bs 68.640 | +Bs 54.386 |

\*Antes de provisiones laborales completas, impuestos, marketing, mantenimiento, merma, depreciación y otros costos no modelados.

Estas cifras son **sensibilidad**, no forecast ni utilidad neta.

## 8. Qué debe mostrar IQ GROWTH por puesto

Para cada persona/rol:
- salario nominal/declarado;
- pago real de caja;
- descuentos del trabajador;
- líquido pagado;
- aportes patronales verificados;
- provisiones aplicables;
- costo empresa estimado;
- evidencia disponible;
- brecha de cumplimiento;
- estado `REGISTRO_REALIDAD / EN_TRANSICION / FORMAL_VERIFICADO` según evidencia y revisión humana.

## 9. Siguiente gate

Antes de convertir este documento en baseline económico definitivo:

1. reunir 7 días continuos de operación sin cierre;
2. revalidar mix real de pizzas y ventas diarias;
3. actualizar precios de insumos críticos;
4. definir jornada y salario real de mesera/cajera;
5. definir salario y funciones del futuro administrador;
6. decidir cómo eliminar la dependencia de Samira para la masa;
7. incorporar impuestos/otros gastos periódicos relevantes;
8. elegir escenario objetivo para el piloto.

**Estado:** `ECONOMIC_SCENARIO_MODEL_READY_FOR_DATA_VALIDATION`
**CEO_ACTION_REQUIRED:** false por ahora.