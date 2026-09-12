# DeepSeek — Bolivia Labor Dispute Defense Red Team

Actúa como red team de fraude interno, evidencia y abuso de procesos laborales para IQ GROWTH/VANSAM en Bolivia.

NO propongas evasión de derechos laborales.
NO propongas contratos simulados, renuncias de beneficios, consultorías ficticias ni destrucción de evidencia.
NO interpretes leyes como abogado definitivo.

CONTEXTO VERIFICADO

- IQ GROWTH debe proteger tanto al trabajador como al empleador mediante evidencia y cumplimiento.
- Derechos laborales son irrenunciables.
- Una relación con subordinación/dependencia, trabajo por cuenta ajena y remuneración puede constituir relación laboral independientemente del nombre contractual.
- Para VANSAM existen roles permanentes previstos: hornero/armador, mesera/cajera y futuro administrador.
- El mito “contrato de 3 meses renovable evita beneficios” NO se acepta. La normativa/jurisprudencia boliviana limita contratos a plazo fijo y no los admite como mecanismo para tareas propias y permanentes.
- Beneficios sociales/indemnización se consolidan a partir del umbral legal aplicable (>90 días según material oficial MTEPS); vacaciones nacen tras un año continuo; seguridad social y registros tienen obligaciones desde la relación laboral.
- IQ GROWTH tendrá asistencia, pagos, incidencias, respuestas y correcciones append-only.

MISIÓN

Intenta romper la defensa probatoria del empleador y del trabajador.

Escenarios mínimos:
1. trabajador afirma que ingresó meses antes;
2. afirma haber trabajado horas extras no registradas;
3. dice que recibía salario mayor al declarado;
4. empleador paga efectivo sin recibo;
5. trabajador niega firma/recibo;
6. cajera marca asistencia por compañero;
7. administrador modifica horario después;
8. trabajador acusa sanción por incidencia que solo era reporte operativo;
9. supervisor fabrica incidencias contra trabajador;
10. trabajador abandona puesto y luego alega despido;
11. empleador dice abandono pero no tiene evidencia;
12. WhatsApp personal contiene instrucciones laborales no ingresadas al sistema;
13. pagos parciales/adelantos se confunden con salario;
14. comida/cena se intenta descontar indebidamente;
15. trabajador afirma trabajo en domingo/feriado/nocturno;
16. trabajador fue contratado “por servicios” pero tenía horario, jefe y puesto fijo;
17. contrato firmado después de iniciado el trabajo;
18. contrato dice un horario y sistema registra otro;
19. cierre de relación sin finiquito completo;
20. empleado denuncia meses después.

Para cada ataque entrega:
ID / SEVERITY / CLAIM / WHAT EVIDENCE WOULD MATTER / EMPLOYER ABUSE RISK / WORKER ABUSE RISK / CONTROL / WHAT IQ GROWTH MUST NEVER DO / PROFESSIONAL REVIEW.

Diseña luego:
A. expediente laboral mínimo probatoriamente fuerte;
B. controles de asistencia antifraude sin biometría invasiva por defecto;
C. pagos y recibos difíciles de negar;
D. incidentes append-only con derecho de respuesta;
E. protocolo de corrección de horarios;
F. protocolo de terminación y cierre documental;
G. top 10 huecos por los que VANSAM podría perder una controversia aunque crea tener razón;
H. top 10 controles que más reducen reclamos falsos o exagerados sin vulnerar derechos.

VEREDICTO:
DEFENSE_MODEL_STRONG
DEFENSE_MODEL_NEEDS_REFINEMENT
DEFENSE_MODEL_UNSAFE

CEO_ACTION_REQUIRED=false salvo decisión material.