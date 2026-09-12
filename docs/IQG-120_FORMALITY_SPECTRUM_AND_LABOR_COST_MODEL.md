# IQG-120 — Formality Spectrum & Labor Cost Model

**Estado:** diseño canónico previo a implementación  
**Fecha:** 2026-09-12  
**Autoridad:** Iván Quea — CEO / Product Owner  
**Síntesis:** ChatGPT  
**Evidencia:** fuentes oficiales Bolivia + DeepSeek red-team de informalidad/costo laboral

## Principio central

IQ GROWTH debe servir a negocios formales, parcialmente formales, informales y en transición sin confundir realidad económica con validez jurídica.

Nunca modelar `FORMAL` e `INFORMAL` como dos regímenes jurídicamente equivalentes.

La arquitectura separa siempre:

1. `REALIDAD_OPERATIVA_OBSERVADA` — qué paga y hace realmente el negocio.
2. `OBLIGACION_APLICABLE` — obligación candidata según jurisdicción, fecha, relación y contexto.
3. `FUENTE_DE_LA_OBLIGACION` — norma/fuente oficial versionada que sustenta la regla.
4. `VERIFICACION_DE_LA_OBLIGACION` — quién la verificó, cuándo y con qué versión.
5. `BRECHA_CUMPLIMIENTO` — diferencia entre realidad y obligación, con evidencia y supuestos.
6. `EFECTO_MATERIAL` — magnitud, duración, número de personas afectadas y nivel de riesgo.
7. `PLAN_TRANSICION` — acciones lícitas para reducir la brecha.

Ninguna IA puede convertir automáticamente una brecha en una deuda jurídica definitiva ni certificar cumplimiento.

## Estados empresariales de presentación

Estados descriptivos, no certificaciones jurídicas:

- `FORMAL_VERIFICADO`
- `FORMAL_CON_OBSERVACIONES`
- `PARCIALMENTE_FORMAL`
- `REALIDAD_INFORMAL_REGISTRADA`
- `EN_TRANSICION`
- `TRANSICION_BLOQUEADA`

La IA puede proponer el estado. Un humano autorizado lo confirma con evidencia. Nunca existe un `modo_informal` que autorice incumplimiento.

El modo correcto es `MODO_REGISTRO_REALIDAD`: registra hechos, calcula brechas contra reglas verificadas y muestra opciones de transición sin certificar legalidad.

## Modelo salarial mínimo

Para cada vínculo laboral distinguir:

- salario básico/nominal;
- total ganado;
- descuentos del trabajador;
- líquido pagado;
- aportes patronales;
- otros aportes empresariales obligatorios;
- provisiones/beneficios cuando corresponda;
- costo laboral empresarial estimado;
- jornada y modalidad;
- fecha real de inicio;
- evidencia de pago;
- evidencia de aportes;
- estado y calidad de la evidencia.

Nunca presentar el líquido recibido como costo total empresarial ni el salario nominal como líquido del trabajador.

## Bolivia 2026 — hechos oficiales de referencia

### Remuneración

- SMN 2026: Bs 3.300 para jornada completa, con efecto desde 2026-01-01.
- Jornadas parciales: adecuación proporcional al tiempo pactado conforme RM 088/26 y normativa aplicable.

### Aportes del trabajador dependiente

- SIP trabajador: `12,71%` del Total Ganado, retenido por el empleador y remitido a la Gestora.

### Costos patronales identificados

Separar explícitamente:

1. `SIP_PATRONAL = 5,21%`
   - 3,50% Aporte Patronal Solidario;
   - 1,71% Prima por Riesgo Profesional.
2. `APORTE_PATRONAL_VIVIENDA = 2,00%`
   - obligación distinta del SIP, actualmente recaudada por la Gestora y regulada por APS.
3. `SEGURO_SOCIAL_CORTO_PLAZO = 10,00%`
   - aporte patronal de salud sobre la planilla/Total Ganado según fuente CNS aplicable.

Por tanto, para una simulación preliminar y únicamente respecto a estos conceptos:

`CARGA_PATRONAL_IDENTIFICADA = 5,21% + 2,00% + 10,00% = 17,21%`

Estas tasas deben vivir en Compliance Pack versionado, no hardcodeadas en el Core.

## Ejemplo didáctico con Total Ganado Bs 3.300

Suponiendo `total_ganado = 3.300` y sin otras deducciones:

- descuento SIP trabajador 12,71% = Bs 419,43;
- líquido aproximado antes de otros descuentos = Bs 2.880,57;
- SIP patronal 5,21% = Bs 171,93;
- vivienda patronal 2,00% = Bs 66,00;
- salud patronal 10,00% = Bs 330,00;
- costo inmediato empresa por salario + estos aportes = Bs 3.867,93.

Este valor NO es el costo laboral total definitivo.

No incluye, según corresponda:
- aguinaldo;
- vacaciones;
- indemnización/beneficios sociales;
- horas extra;
- recargo nocturno;
- domingos/feriados;
- primas u otros conceptos;
- obligaciones sectoriales o futuras modificaciones normativas.

## Provisiones: regla de cautela

DeepSeek propuso porcentajes mensuales de provisión para aguinaldo, vacaciones e indemnización. IQ GROWTH NO canoniza por ahora un porcentaje universal total como `139,6% del salario`.

Razones:
- el derecho y la base pueden depender de antigüedad, categoría, total ganado y hecho generador;
- `provisión contable` no es lo mismo que `aporte mensual exigible`;
- vacaciones cambian con antigüedad;
- el cálculo final debe ser validado por contador/abogado laboral y regla BO versionada.

Se permite una `SIMULACION_REFERENCIAL` con supuestos visibles, nunca una deuda definitiva.

## Caso “dame el seguro/aporte en efectivo”

Si una obligación legal exige retención o aporte a una entidad de seguridad social, entregar ese monto al trabajador no debe marcarse como cumplimiento.

El sistema puede registrar:
- solicitud del trabajador;
- pago adicional observado;
- evidencia del mensaje;
- contexto.

Pero la solicitud debe quedar como:

`SOLICITUD_TRABAJADOR_NO_VINCULANTE`

La obligación permanece abierta hasta existir evidencia válida de cumplimiento o decisión profesional documentada.

## Hechos laborales y evidencia

Modelo conceptual futuro:

- `vinculo_laboral`
- `hecho_pago`
- `hecho_asistencia`
- `obligacion_laboral_aplicable`
- `brecha_laboral`
- `plan_transicion`
- `disputa_laboral`
- `legal_hold_laboral`
- `provenance_laboral`

Todos deben ser tenant-aware y compatibles con RLS.

### Invariantes

1. Un pago observado nunca se borra; una corrección crea un nuevo evento.
2. Fecha de ingreso declarada y fecha verificada se conservan separadas.
3. Una regla laboral aplicada conserva `rule_version`, fuente y vigencia.
4. Una brecha nunca se cierra automáticamente.
5. Una estimación de pasivo se etiqueta `REFERENCIAL_NO_VINCULANTE`.
6. Una inferencia IA nunca se guarda como `FACT_VERIFIED` automáticamente.
7. Quien registra una corrección material no debe ser su único aprobador.
8. Un administrador no puede aprobar cambios sobre su propio vínculo como único aprobador.
9. Pagos en efectivo requieren evidencia; sin confirmación se marcan `EVIDENCIA_DEBIL`.
10. Un contrato temporal repetido o aplicado a funciones permanentes puede disparar `REQUIERE_REVISION_LABORAL`; el sistema no decide por sí solo el efecto jurídico.

## Integridad de evidencia

Para asistencia, pagos y correcciones:

- append-only cuando corresponda;
- timestamps de servidor;
- `fecha_declarada` separada de `fecha_recepcion`;
- correcciones como eventos nuevos;
- separación de funciones;
- historial visible para la persona afectada cuando corresponda;
- hash/provenance.

Un hash-chain dentro de la misma base NO basta contra un administrador de base malicioso. Para evidencia fuerte futura considerar anclaje independiente, WORM o raíz firmada fuera del mismo dominio administrativo.

## Vistas de producto

### Vista dueño

- costo de caja observado;
- salario nominal;
- líquido estimado/observado;
- costo patronal identificado;
- costo laboral total referencial;
- brecha mensual;
- brecha acumulada referencial;
- evidencia disponible;
- opciones de transición lícita.

### Vista operador/RRHH

- contrato/jornada;
- marcaciones;
- pagos;
- aportes;
- permisos/ausencias;
- incidencias;
- documentación faltante;
- correcciones pendientes de aprobación.

## No permitido

IQ GROWTH no debe:

- sugerir contratos simulados para eludir derechos;
- recomendar pagar aportes obligatorios directamente al trabajador como sustitución;
- ocultar empleados o jornadas;
- falsear fecha de ingreso;
- convertir trabajador dependiente en consultor por etiqueta;
- borrar evidencia histórica;
- calcular deuda jurídica definitiva;
- certificar cumplimiento laboral;
- automatizar despido, sanción o terminación;
- presentar una solicitud de renuncia del trabajador como exención automática.

## Alternativas lícitas que puede simular

Sujetos a validación profesional:

- jornada parcial real;
- menos días/turnos;
- turnos de demanda pico;
- automatización;
- redistribución de funciones;
- contratación temporal solo cuando la naturaleza sea verdaderamente temporal;
- otras estructuras válidas por jurisdicción.

El sistema debe alertar cuando la forma declarada contradice la realidad observada.

## Secuencia de implementación

Este diseño NO amplía IQG-001.2.

Secuencia:

1. cerrar IQG-001.2 seguridad/runtime;
2. estabilizar IQG-001.3 migración;
3. definir contrato técnico laboral como módulo posterior;
4. validar Compliance Pack BO laboral con profesional;
5. recién entonces implementar hechos laborales, brechas, disputas y evidencia.

## Objetivo de producto

Dar al dueño una respuesta honesta:

`¿Cuánto me cuesta realmente esta persona hoy?`

`¿Cuánto me costaría con cumplimiento verificado?`

`¿Qué brecha estoy acumulando?`

`¿Qué tan fuerte es mi evidencia?`

`¿Qué alternativa lícita reduce esa brecha?`

**CEO_ACTION_REQUIRED:** false
