# DeepSeek — Red Team de informalidad, costo laboral y fraude

**Fecha:** 2026-09-12  
**Origen:** respuesta aportada por Iván Quea  
**Veredicto original:** `FORMALITY_MODEL_NEEDS_REFINEMENT`

## Alcance declarado por DeepSeek

DeepSeek indicó que no tuvo acceso directo a todos los documentos canónicos y trabajó con el contexto incluido en el prompt, `MASTER_CONTEXT.md` y el esquema IQG-001.2. Por tanto, sus conclusiones se tratan como challenge, no como autoridad canónica.

## Hallazgos principales

1. El modelo `REALIDAD_OPERATIVA_OBSERVADA + OBLIGACION_VERIFICADA + BRECHA_CUMPLIMIENTO + PLAN_TRANSICION` es correcto en dirección, pero debe añadir:
   - `FUENTE_DE_LA_OBLIGACION`;
   - `VERIFICACION_DE_LA_OBLIGACION`;
   - `EFECTO_MATERIAL`.
2. Debe existir separación explícita entre:
   - hecho económico observado;
   - obligación aplicable versionada;
   - brecha;
   - plan de transición.
3. DeepSeek propuso como estructura de costo Bolivia 2026:
   - trabajador SIP 12,71%;
   - SIP patronal 5,21%;
   - vivienda patronal 2%;
   - salud patronal 10%;
   - provisiones separadas para aguinaldo, vacaciones e indemnización.
4. El caso `dame el seguro a mí` debe registrarse como solicitud del trabajador, pero nunca como cierre automático de obligación.
5. No debe existir un `modo informal` que parezca autorizar incumplimiento. Debe existir `MODO_REGISTRO_REALIDAD`.
6. Pagos en efectivo sin recibo/confirmación deben quedar como evidencia débil.
7. Contrato declarado y realidad de asistencia deben contrastarse automáticamente.
8. Correcciones retroactivas no deben sobrescribir hechos; generan nuevo evento, con doble control cuando sean materiales.
9. El sistema debe proteger simultáneamente a empresa y trabajador.
10. Brechas y pasivos deben expresarse como estimaciones referenciales, no deudas jurídicas definitivas.

## Ataques destacados

DeepSeek generó más de 30 escenarios, entre ellos:

- pago efectivo luego negado;
- empleador registra un monto distinto del realmente pagado;
- solicitud del trabajador de no aportar;
- contrato de medio tiempo con asistencia de jornada completa;
- correcciones retroactivas de horas;
- abandono alegado vs despido;
- contratos temporales repetidos en función permanente;
- retención previsional no enterada;
- finiquito sin firma;
- clasificación falsa como eventual/socio/familiar/pasante;
- manipulación de incidencias para justificar despido;
- formalización posterior con pasivos históricos inciertos.

## Invariantes propuestos

- hechos económicos no se borran;
- obligaciones se aplican por regla versionada;
- brechas no se cierran automáticamente;
- solicitudes del trabajador de no aportar son `NO_VINCULANTE`;
- pagos en efectivo sin evidencia son `EVIDENCIA_DEBIL`;
- correcciones retroactivas requieren trazabilidad;
- administrador no autoaprueba su vínculo;
- IA no persiste inferencias como hechos verificados;
- estimaciones de pasivo son `REFERENCIAL_NO_VINCULANTE`.

## Observaciones que requieren corrección/validación

- La cifra `7,21%` patronal debe descomponerse correctamente: `5,21% SIP patronal + 2% aporte patronal vivienda`.
- Los porcentajes de provisión mensual no deben canonizarse como obligación universal sin regla BO validada y revisión profesional.
- Los umbrales de materialidad propuestos por DeepSeek son heurísticos, no norma; no se adoptan automáticamente.
- La ausencia actual de tablas laborales en IQG-001.2 no se considera defecto del ticket de Core: el módulo laboral está deliberadamente diferido.
- Un hash-chain interno no protege por sí solo frente a un DBA con capacidad de reescritura; evidencia fuerte requiere frontera independiente.

## Estado

`CHALLENGE_ACCEPTED_WITH_CORRECTIONS`

`CEO_ACTION_REQUIRED=false`
