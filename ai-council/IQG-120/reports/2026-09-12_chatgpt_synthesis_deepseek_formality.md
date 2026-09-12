# ChatGPT synthesis — DeepSeek formality/labor-cost red team

**Fecha:** 2026-09-12  
**Estado:** `ACCEPTED_WITH_CORRECTIONS`

## 1. Decisión principal

Se mantiene el modelo:

`REALIDAD OPERATIVA → OBLIGACION APLICABLE → FUENTE/VERIFICACION → BRECHA → MATERIALIDAD → PLAN DE TRANSICION`

No existe `modo informal` como autorización jurídica. Existe `MODO_REGISTRO_REALIDAD`.

## 2. Corrección de tasas Bolivia 2026

Verificación oficial posterior al challenge:

- Gestora: trabajador dependiente SIP = 12,71% del Total Ganado.
- Gestora: aporte patronal SIP = 5,21% (3,50% solidario + 1,71% riesgo profesional).
- APS: aporte patronal para vivienda = 2%, pagado con recursos del empleador y recaudado conjuntamente por Gestora.
- CNS: aporte patronal de salud = 10% de la planilla/Total Ganado según fuente aplicable.

Por tanto, para simulación preliminar:

`5,21% + 2,00% + 10,00% = 17,21%` de carga patronal identificada adicional al salario bruto, antes de otros conceptos.

## 3. Ejemplo Bs 3.300

- Total Ganado: Bs 3.300.
- Retención trabajador 12,71%: Bs 419,43.
- Líquido preliminar: Bs 2.880,57.
- SIP patronal 5,21%: Bs 171,93.
- Vivienda 2%: Bs 66,00.
- Salud 10%: Bs 330,00.
- Costo inmediato identificado para empresa: Bs 3.867,93.

No incluir como costo definitivo todavía:
- aguinaldo;
- vacaciones;
- indemnización;
- extras/nocturno/domingos/feriados;
- otros conceptos aplicables.

## 4. Provisiones

Se rechaza canonizar `costo total = 139,6% del salario` como regla universal.

Los porcentajes de provisión pueden servir para escenarios internos, pero requieren:
- base normativa aplicable;
- antigüedad;
- total ganado/base de cálculo;
- validación contador/abogado;
- regla BO versionada.

`PROVISION_CONTABLE != APORTE_MENSUAL_EXIGIBLE`.

## 5. Hallazgos aceptados de DeepSeek

- añadir fuente, verificación y materialidad;
- hechos laborales append-only donde corresponda;
- separar pago observado vs declarado;
- pagos en efectivo con evidencia débil si no hay confirmación;
- solicitud `dame el seguro a mí` como `NO_VINCULANTE`;
- doble control para correcciones materiales;
- administrador no autoaprueba su propio vínculo;
- contraste contrato vs asistencia;
- pasivos como estimaciones referenciales;
- acceso/provenance suficientes para reconstruir hechos;
- soporte futuro de disputa y legal hold.

## 6. Hallazgos modificados/rechazados

- `7,21% SIP patronal`: corregido a `5,21% SIP + 2% vivienda`.
- materialidad basada en múltiplos de SMN: no canónica; requiere diseño específico.
- tercer contrato como efecto automático: solo dispara revisión; el sistema no adjudica efecto jurídico.
- tablas laborales ausentes en IQG-001.2: no es P0 del Core; módulo deliberadamente posterior.
- hash-chain como prueba fuerte suficiente: rechazado; una misma autoridad técnica puede reescribir y recalcular. Para alta integridad, usar anclaje externo/WORM/raíz firmada en fase futura.

## 7. Secuencia

No ampliar IQG-001.2.

1. cerrar Core/PG16;
2. estabilizar migración;
3. contrato técnico de módulo laboral;
4. validación profesional Compliance Pack BO;
5. implementación posterior.

## 8. Estado

`FORMALITY_MODEL_HARDENED / IMPLEMENTATION_DEFERRED_BY_SEQUENCE`

`CEO_ACTION_REQUIRED=false`
