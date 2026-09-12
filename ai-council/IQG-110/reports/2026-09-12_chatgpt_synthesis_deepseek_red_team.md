# ChatGPT Synthesis — DeepSeek Red Team IQG-110/120/121/122

**Fecha:** 2026-09-12  
**Autoridad de síntesis:** ChatGPT — Chief Architect / Coordinador central  
**Input:** `ai-council/IQG-110/reports/2026-09-12_deepseek_red_team.md`

## 1. Veredicto de síntesis

**ACCEPTED WITH SCOPE CORRECTION**

El red team aporta amenazas e invariantes valiosos, pero su `CHANGES_REQUIRED` no se traslada literalmente a IQG-001.2 porque DeepSeek no recibió las especificaciones IQG-110/120/121/122 y auditó principalmente el esquema físico actual IQG-001.2.

La ausencia de tablas futuras como `DISPUTE`, `LEGAL_HOLD`, `rule_version`, `PENDING_CLASSIFICATION` o provenance en IQG-001.2 es esperada: esos dominios todavía no fueron autorizados para implementación.

## 2. Regla de alcance

### NO ampliar IQG-001.2 con IQG-110+

Codex debe cerrar IQG-001.2 según el alcance ya checkpointed y ejecutar PG16. No se incorporan ahora módulos jurídicos/corporativos nuevos.

DeepSeek no crea un nuevo blocker del checkpoint por ausencia de módulos que pertenecen a tickets posteriores.

### Sí permanecen en IQG-001.2

Los hallazgos ya existentes y previamente aceptados dentro de la remediación actual, incluyendo:
- bootstrap/identidad;
- usuario y empresa activos;
- anonimización y PII dentro del alcance acordado;
- ACL/roles/ownership;
- FORCE RLS;
- pruebas 2x2 de aislamiento;
- concurrencia;
- fiscalidad ya incluida en el esquema;
- restauración/re-ejecución del DDL.

## 3. Reclasificación de los P0 de DeepSeek

### DS-P0-01 — módulos IQG-110+ no existen en DDL

**RECLASSIFIED: FUTURE IMPLEMENTATION GATE**

Correcto como observación de completitud, incorrecto como P0 de IQG-001.2.

Antes de implementar IQG-110/120/121/122 sí debe existir diseño físico explícito para provenance, hechos/calificaciones, disputas, holds, versiones normativas y revisión humana.

### DS-P0-02 — ruta privilegiada de mantenimiento

**ACCEPTED WITH RESTRICTION**

Existe una necesidad real de migración/corrección controlada, especialmente para IQG-001.3. No se acepta un `modo dios`, `BYPASSRLS` ni acceso irrestricto.

Diseño futuro permitido:
- endpoint/función administrativa estrecha;
- SECURITY DEFINER revisada;
- actor `MANTENIMIENTO`;
- ticket/motivo obligatorio;
- alcance tenant explícito;
- separación de funciones para operaciones materiales;
- auditoría reforzada;
- ventana temporal.

Debe diseñarse antes de migración productiva, no necesariamente dentro del cierre PG16 actual.

### DS-P0-03 — anclaje criptográfico externo

**ACCEPTED IN PRINCIPLE, REJECT INTERNAL-HASH-CHAIN-AS-SUFFICIENT**

Un hash chain almacenado únicamente dentro de la misma PostgreSQL no resiste a un DBA con capacidad de reescribir filas y recalcular la cadena completa.

Para evidencia fuerte frente a administración privilegiada futura se requiere un dominio de confianza separado, por ejemplo:
- export periódico firmado a almacenamiento WORM;
- Merkle/root periódico firmado con clave fuera de la base;
- servicio de timestamp externo verificable;
- log/SIEM independiente con retención propia.

No construir blockchain.

Este requisito pertenece al endurecimiento probatorio antes de comercializar funciones legales/materiales, no bloquea el actual PG16 de IQG-001.2.

### DS-P0-04 — identidad de actor IA

**ACCEPTED AS FUTURE CROSS-CUTTING CONTROL**

El Core ya contempla contexto de actor genérico, pero la futura persistencia de recomendaciones/inferencias IA debe distinguir explícitamente HUMANO / IA / SISTEMA / MANTENIMIENTO / EXTERNO y exigir revisión humana en acciones materiales.

No bloquea IQG-001.2 mientras no exista una ruta de IA autorizada para realizar esos actos.

## 4. Hallazgos P1 aceptados

### Ya pertenecen a IQG-001.2

- validar `usuario.activo` + `empresa.activo` además de membresía;
- resolver bootstrap SECURITY DEFINER correctamente;
- remediaciones de anonimización incluidas en el ticket vigente;
- restricciones/grants/ACLs del gateway futuro;
- unicidad PII según ADR y evidencia de runtime.

### Pertenecen a IQG-110+ futuro

- separación de funciones;
- conflicto de interés;
- doble aprobación/quórum;
- `rule_version` y Compliance Pack;
- temporalidad de participación/salario/autoridad;
- provenance jurídico/epistemológico;
- DISPUTE/LEGAL HOLD;
- soporte break-glass.

## 5. Invariantes aceptados para IQG-110+

1. El hecho económico se preserva aunque su calificación esté pendiente.
2. Reclasificar crea un nuevo evento; nunca elimina la clasificación histórica.
3. Fecha declarada por una parte y fecha de recepción servidor son hechos distintos.
4. Quien se beneficia materialmente no puede ser único aprobador de la decisión que le beneficia.
5. La separación de funciones debe evaluarse por acto y conflicto de interés, no solo por rol.
6. Una disputa afecta únicamente objetos/decisiones materialmente dependientes de ella.
7. Abrir y cerrar una disputa requieren segregación adecuada.
8. Legal hold no puede convertirse en mecanismo indefinido de retención; tiene revisión y base registrada.
9. Un objeto bajo legal hold no puede modificarse/borrarse silenciosamente.
10. Inferencia IA != hecho verificado.
11. La transición a una categoría verificada requiere actor autorizado y evidencia.
12. Toda regla jurisdiccional aplicada conserva versión, fuente, vigencia y fecha de evaluación.
13. Reevaluar no reescribe la evaluación histórica.
14. Toda nueva tabla tenant-aware hereda aislamiento/RLS equivalente.
15. Acceso de soporte del proveedor es just-in-time, trazado y limitado.
16. Evidencia probatoria fuerte contra insiders privilegiados necesita anclaje fuera del mismo dominio de administración.
17. Supresión, retención y backups se gobiernan por jurisdicción; no hay borrado ni conservación absolutos.
18. Restauración/migración nunca debe convertir datos migrados en hechos nativos sin provenance.
19. Ningún Compliance Pack no verificado/caducado produce automáticamente `ALLOWED`.
20. IQ GROWTH demuestra eventos del sistema; no adjudica verdad jurídica.

## 6. Recomendaciones DeepSeek modificadas/rechazadas

### Hash chain interno como solución suficiente

**REJECTED.** Puede ayudar a detectar cambios accidentales/aplicativos, pero no es una frontera de confianza frente a DBA comprometido.

### `hard_delete` siempre con doble aprobación

**MODIFIED.** La supresión debe obedecer el Compliance Pack. Puede requerir aprobación/revisión material según riesgo, pero no se canoniza un mecanismo universal que contradiga derechos jurisdiccionales. Siempre queda evidencia mínima no-PII del evento de supresión cuando legalmente sea permitido conservarla.

### prohibición temporal universal para borrar registros jóvenes

**NOT CANONICAL.** Plazos y ventanas son jurisdiccionales/política de producto verificada, no constantes universales.

### cierre automático/caducidad de disputas

**MODIFIED.** Una disputa puede requerir revisión, escalado o cierre administrativo según reglas aplicables; nunca debe extinguir automáticamente un derecho o reclamo jurídico por simple temporizador del software.

### conflicto de interés detectado invalida automáticamente el acto

**REJECTED AS LEGAL CONCLUSION.** El sistema puede marcar `CONFLICT_OF_INTEREST_DETECTED` y bloquear/requerir revisión según política; no declara nulidad jurídica universal.

## 7. Orden de implementación

1. Cerrar IQG-001.2 con PG16 sin scope creep.
2. Reauditoría DeepSeek de IQG-001.2 basada en evidencia runtime.
3. IQG-001.3 Phase -1 y diseño de migración controlada.
4. Mantener IQG-110/120/121/122/123 como arquitectura previa a implementación.
5. Antes de implementar relaciones empresariales/legal-risk, producir modelo físico específico y pruebas de abuso derivadas de este red team.
6. Validar Compliance Pack BO con fuentes oficiales + profesionales humanos en dominios materiales.

## 8. Decisión constitucional explícita

IQ GROWTH persigue:

**EVIDENCIA DE HECHO + PROCEDENCIA + ESTADO + DECISIÓN TRAZABLE**

No persigue:

**VERDAD JURÍDICA AUTÓNOMA**

La IA nunca es autoridad final para determinar propiedad, derechos laborales, validez societaria, deuda exigible, sucesión, obligaciones tributarias ni resolución de controversias.

Esta decisión queda consistente con IQG-120/121/122.

**CEO_ACTION_REQUIRED:** false — ya está alineado con la directriz del CEO de proteger personas y reducir riesgo de litigio sin quitar derechos.