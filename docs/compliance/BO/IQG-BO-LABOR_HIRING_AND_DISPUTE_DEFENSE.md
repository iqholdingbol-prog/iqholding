# IQG-BO — Labor Hiring & Dispute Defense Guardrails

**Proyecto:** IQ GROWTH / VANSAM
**Jurisdicción inicial:** Bolivia
**Estado:** guía de diseño y control interno; requiere validación profesional antes de contratación/terminación real
**Fecha:** 2026-09-12

## 1. Objetivo

Proteger simultáneamente los derechos de las personas trabajadoras y a VANSAM/IQHOLDING frente a reclamos falsos, reconstrucciones inexactas de hechos, pagos no acreditados, horarios discutidos, incidencias manipuladas o documentación incompleta.

La protección no se basa en renuncias de derechos ni en contratos aparentes destinados a evitar obligaciones laborales. Se basa en cumplimiento, evidencia, trazabilidad, segregación de funciones y cierre documental correcto.

## 2. Regla de no evasión

No utilizar como estrategia:
- contratos de 3 meses renovados para eludir beneficios;
- consultorías simuladas cuando existe subordinación/dependencia;
- pagos fuera de planilla para ocultar remuneración;
- renuncias anticipadas de beneficios irrenunciables;
- borrado o edición retroactiva de asistencia, incidencias o pagos.

Para tareas propias y permanentes de la operación —por ejemplo hornero/armador, cajera/mesera estable, administrador operativo— el uso de contratos a plazo fijo requiere revisión legal previa y no debe asumirse como vía de exclusión de derechos.

## 3. Fuentes oficiales verificadas — punto de partida

- Salario Mínimo Nacional 2026: Bs 3.300 para jornada completa; en jornadas parciales la adecuación es proporcional al tiempo pactado, conforme RM 088/26.
- Registro Obligatorio de Empleadores y planillas mensuales: la RM 088/26 recuerda la obligación bajo normativa vigente.
- Jornada: regla general máxima 8 horas/día y 48 horas/semana; para mujeres y menores de 18 años la jornada diurna no excede 40 horas semanales; trabajo nocturno se entiende entre 20:00 y 06:00 y tiene régimen propio.
- Beneficios sociales: el MTEPS señala que se consolidan a partir de más de 90 días / tercer mes cumplido; la indemnización por tiempo de servicios corresponde superado ese umbral y se prorratea cuando no se alcanza el año.
- Vacación: después de un año ininterrumpido, 15 días hábiles de 1 a 5 años, 20 de 5 a 10 y 30 desde 10 años, según guía oficial MTEPS.
- Aguinaldo: derecho de trabajadores bajo subordinación/dependencia sujeto a los requisitos temporales y reglas de cálculo vigentes; debe verificarse la clasificación aplicable del trabajador.
- SIP/Gestora: el empleador registra trabajadores dependientes, actúa como agente de retención y paga aportes patronales; la Gestora indica obligación de registro del dependiente dentro del plazo legal si el trabajador no se registra voluntariamente.
- Salud de corto plazo: la CNS publica aporte patronal del 10% de planilla para el seguro de salud.
- Contratos a plazo fijo: la jurisprudencia oficial boliviana aplica el DL 16187; no se permiten más de dos contratos sucesivos y tampoco contratos a plazo fijo para tareas propias y permanentes de la empresa.

Toda tasa, plazo o tratamiento debe conservar `source_id`, fecha de verificación y versión; no hardcodear porcentajes jurídicos sin Compliance Pack.

## 4. Expediente laboral mínimo por persona

Cada trabajador debe tener un expediente trazable con:
- identidad;
- fecha real de ingreso;
- cargo y responsabilidades;
- jornada pactada y calendario;
- salario/remuneración y vigencia;
- contrato/documento aplicable;
- registro/alta en sistemas que correspondan;
- asistencia;
- papeletas/planillas;
- transferencias o recibos de pago;
- vacaciones/licencias;
- aguinaldo/beneficios cuando correspondan;
- incidencias y respuestas;
- cambios de cargo/salario/jornada con fecha efectiva;
- documentos de terminación;
- finiquito y constancia de pago cuando corresponda.

No borrar versiones anteriores.

## 5. Defensa probatoria

IQ GROWTH debe conservar como `SYSTEM_EVENT`, no como “verdad jurídica”:
- hora de entrada/salida registrada por terminal autorizado;
- actor que creó una incidencia;
- persona/proceso responsable vigente en ese momento;
- respuesta del trabajador;
- evidencia adjunta;
- pago realizado, medio y referencia;
- horario planificado vs horario real;
- cambios de contrato/salario;
- aprobación de correcciones;
- motivo de terminación declarado y evidencia asociada.

El sistema no debe permitir que un administrador edite o elimine silenciosamente estos registros. Las correcciones se hacen con eventos nuevos.

## 6. Incidencias y reclamos internos

`RESPONSABLE_FUNCIONAL != CULPABLE`

Flujo:

`REPORTE → CLASIFICACIÓN → RESPONSABLE DEL PROCESO → RESPUESTA → EVIDENCIA → RESOLUCIÓN → HISTORIAL`

Una incidencia puede quedar como:
- error de proceso;
- proveedor externo;
- falta de stock;
- falta de preparación;
- equipo;
- dato incorrecto;
- causa no determinada.

La IA no sanciona ni descuenta salario.

## 7. Asistencia

Para VANSAM, terminal primaria candidata: PC táctil 23" de caja.

Cada trabajador marca con identidad propia. No existe PIN compartido.

Registrar:
- hora programada;
- entrada real;
- salida real;
- pausa cuando corresponda;
- corrección solicitada;
- aprobador de corrección;
- motivo.

El sistema de control de asistencia deberá alinearse con la normativa MTEPS aplicable antes de utilizarse como mecanismo laboral oficial.

## 8. Horarios y costo laboral real

No calcular rentabilidad solo con salario nominal.

El motor debe distinguir:

`SALARIO_BASE`
`APORTES_PATRONALES`
`AGUINALDO_RESERVA`
`INDEMNIZACION_RESERVA`
`VACACION_RESERVA`
`RECARGOS/EXTRAS/DOMINGOS/FERIADOS`
`OTROS_COSTOS_LABORALES_APLICABLES`

El costo total depende de jornada, sexo cuando la norma establezca límites diferenciados, horario nocturno, domingos/feriados, antigüedad y normativa vigente.

## 9. Opciones lícitas si una PYME no puede sostener jornada completa

Evaluar con profesional laboral:
- jornada parcial real con remuneración proporcional cuando la norma lo permita;
- menos días/horas y turnos separados;
- contratación temporal solo para necesidades realmente temporales/extraordinarias;
- tercerización real de un servicio autónomo cuando no exista subordinación/dependencia;
- rediseño operativo para automatizar o reducir horas necesarias.

No disfrazar un trabajador dependiente como consultor independiente.

## 10. Terminación

Antes de cualquier terminación:
- identificar causal;
- preservar asistencia/incidencias/pagos;
- revisar si existe protección especial o inamovilidad;
- calcular obligaciones;
- revisión humana/legal cuando corresponda;
- emitir documentos y pagos dentro de plazos vigentes;
- conservar evidencia del cierre.

La IA nunca ejecuta despido ni determina por sí sola que una causal está legalmente probada.

## 11. Regla de VANSAM

Para los roles permanentes previstos actualmente:
- hornero/armador;
- cajera/mesera;
- administrador futuro;

la hipótesis por defecto del sistema será `RELACION_PERMANENTE / LEGAL_STRUCTURE_TO_VERIFY`, no `CONTRATO_3_MESES_PARA_EVITAR_BENEFICIOS`.

## 12. Gate antes de contratar

Antes de la primera contratación formal estable de VANSAM:
1. abogado laboral boliviano revisa modelo de contrato y terminación;
2. contador/planillero calcula costo laboral completo;
3. se define horario legalmente compatible;
4. se verifica ROE/planillas;
5. se verifica CNS/seguridad social y Gestora;
6. se configura asistencia y expedientes;
7. se reserva mensualmente el costo de beneficios.

**CEO_ACTION_REQUIRED:** false; requiere validación profesional antes de ejecución real.