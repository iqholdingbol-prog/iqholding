# IQG-120 — Formality Spectrum & Labor Cost Model

**Estado:** diseño canónico previo a implementación
**Fecha:** 2026-09-12

## Principio central

IQ GROWTH debe servir a negocios formales, informales y en transición sin confundir realidad económica con validez jurídica.

Nunca modelar `FORMAL` e `INFORMAL` como dos regímenes jurídicamente equivalentes.

La arquitectura debe separar siempre:

1. `REALIDAD_OPERATIVA_OBSERVADA` — qué paga y hace realmente el negocio.
2. `OBLIGACION_VERIFICADA` — qué obligación normativa fue validada para la jurisdicción/fecha/relación.
3. `BRECHA_CUMPLIMIENTO` — diferencia entre realidad y obligación, con evidencia, monto/riesgo estimado y estado.
4. `PLAN_TRANSICION` — acciones lícitas para reducir la brecha cuando el negocio decide formalizar o corregir.

## Modelo salarial mínimo

Para cada relación laboral distinguir:
- salario básico/nominal;
- total ganado;
- descuentos del trabajador;
- líquido pagado;
- aportes patronales adicionales;
- provisiones de beneficios cuando corresponda;
- costo laboral empresarial estimado;
- jornada y modalidad;
- evidencia de pago;
- estado de cumplimiento.

Nunca presentar el líquido recibido como costo total empresarial ni el salario nominal como líquido del trabajador.

## Bolivia 2026 — hechos oficiales de referencia

- SMN 2026: Bs 3.300 para jornada completa; jornadas parciales pueden adecuarse proporcionalmente al tiempo pactado, conforme RM 088/26.
- SIP trabajador dependiente: 12,71% sobre total ganado, retenido por el empleador y remitido a la Gestora.
- SIP patronal dependiente: 5,21% adicional sobre total ganado (3,50% aporte patronal solidario + 1,71% riesgo profesional), según Gestora.
- Seguro social de corto plazo: CNS publica aporte patronal de 10% sobre planilla salarial.

Estas tasas deben vivir en Compliance Pack versionado, no hardcodeadas en el Core.

## Ejemplo didáctico con salario Bs 3.300

Suponiendo `total_ganado = 3.300` y sin otras deducciones:
- descuento SIP trabajador 12,71% = Bs 419,43;
- líquido aproximado antes de otros descuentos = Bs 2.880,57;
- SIP patronal 5,21% = Bs 171,93;
- salud patronal 10% = Bs 330;
- costo mínimo inmediato empresa por salario + esos aportes = Bs 3.801,93;

No incluye provisiones/obligaciones adicionales como aguinaldo, vacaciones, indemnización, horas extra/nocturnas/feriados u otras que correspondan.

## Regla 'dame el seguro en efectivo'

Si una obligación legal exige aporte a entidad de seguridad social, pagar ese monto directamente al trabajador no debe marcarse como cumplimiento. El sistema puede registrar que ocurrió un pago en efectivo, pero la obligación queda abierta hasta contar con evidencia válida de cumplimiento.

## Modos de presentación

### Vista dueño
- costo de caja observado;
- costo laboral normativo estimado;
- brecha mensual;
- obligaciones vencidas/pendientes;
- riesgo cualitativo;
- opciones de transición lícita.

### Vista operador/RRHH
- contrato/jornada;
- marcaciones;
- planillas;
- aportes;
- pagos;
- incidencias;
- documentación faltante.

## No permitido

IQ GROWTH no debe:
- sugerir contratos simulados para eludir derechos;
- recomendar pagar aportes obligatorios directamente al trabajador como sustitución;
- ocultar empleados o jornadas;
- falsear fecha de ingreso;
- convertir trabajador dependiente en consultor por etiqueta;
- borrar evidencia histórica.

## Objetivo de producto

Dar al dueño una respuesta honesta:

`¿Cuánto me cuesta realmente esta persona hoy?`

`¿Cuánto me costaría en cumplimiento verificado?`

`¿Qué brecha estoy acumulando?`

`¿Qué alternativa lícita reduce esa brecha: jornada parcial real, redistribución de turnos, automatización, cambio de horario o estructura de personal?`

**CEO_ACTION_REQUIRED:** false
