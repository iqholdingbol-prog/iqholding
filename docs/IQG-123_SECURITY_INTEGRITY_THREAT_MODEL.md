# IQG-123 — Security, Integrity & Legal-Evidence Threat Model

**Proyecto:** IQ GROWTH  
**Estado:** arquitectura canónica previa a implementación  
**Fecha:** 2026-09-12  
**Autoridad:** Iván Quea — CEO / Product Owner  
**Síntesis:** ChatGPT — Chief Architect  
**Red team base:** DeepSeek  

## 1. Propósito

IQG-123 define amenazas e invariantes de seguridad para los futuros dominios IQG-110/120/121/122.

No añade alcance a IQG-001.2. Su función es impedir que los módulos de relaciones empresariales, cumplimiento jurisdiccional, disputas, evidencia y revisión humana se implementen en el futuro sin controles contra fraude, manipulación histórica y abuso interno.

## 2. Frontera conceptual

IQ GROWTH puede demostrar:

- que un evento fue registrado;
- quién/qué lo originó;
- cuándo lo recibió el sistema;
- qué fuente/documento estaba asociado;
- qué regla/version se evaluó;
- quién aprobó/rechazó;
- qué cambió y por qué.

IQ GROWTH no declara por sí mismo:

- propietario jurídico definitivo;
- deuda jurídicamente exigible cuando existe controversia;
- validez final de contrato/documento;
- validez de transferencia societaria;
- derechos sucesorios;
- legalidad definitiva de despido/sanción;
- obligación tributaria final no verificada;
- resolución de conflicto.

Principio:

> **EVIDENCE OF SYSTEM EVENT ≠ PROOF OF LEGAL TRUTH**

## 3. Clases principales de amenaza

### T1 — Reclasificación oportunista

Un actor intenta transformar retrospectivamente préstamo/aporte/retiro/gasto/distribución para mejorar su posición.

Controles:
- hecho original inmutable;
- calificación versionada;
- actor/autoridad/motivo/evidencia;
- separación de funciones cuando exista beneficio material;
- alerta por reclasificaciones repetidas;
- fechas de recepción servidor separadas de fechas declaradas.

### T2 — Autoaprobación / colusión

RBAC no basta si quien tiene permiso también obtiene beneficio.

Controles:
- conflicto de interés explícito;
- separation of duties por acto;
- aprobación múltiple cuando materialidad lo requiera;
- aprobador independiente cuando corresponda;
- auditoría de administradores privilegiados.

### T3 — Abuso de DISPUTE

Una disputa puede utilizarse para paralizar la empresa o perjudicar a otra parte.

Controles:
- objeto y alcance mínimos;
- motivo y materialidad registrados;
- apertura/cierre segregados;
- notificación;
- revisión/escalado;
- congelar únicamente decisiones dependientes del hecho controvertido;
- operación corriente continúa salvo bloqueo legal real.

### T4 — Abuso o evasión de LEGAL HOLD

Riesgos:
- hold falso para retener de más;
- borrado previo al hold;
- modificación de evidencia;
- restore que elimina el hold;
- export incompleto.

Controles:
- alcance explícito;
- autoridad y base registradas;
- revisión periódica;
- separación de funciones;
- objetos bajo hold versionados/inmutables dentro del sistema;
- manifests/hashes de export;
- reconciliación en restore;
- anclaje de eventos críticos fuera del mismo dominio de administración.

## 4. Provenance y epistemología

Todo dato/material sensible debe distinguir al menos:

- `FACT_VERIFIED`
- `USER_DECLARED`
- `DOCUMENT_SUPPORTED`
- `THIRD_PARTY_ATTESTED`
- `SYSTEM_INFERRED`
- `PENDING_CLASSIFICATION`
- `PENDING_HUMAN_REVIEW`
- `PENDING_LEGAL_REVIEW`
- `CONTRADICTED`
- `DISPUTED`
- `VERIFICATION_EXPIRED`
- `UNVERIFIABLE`
- `WITHDRAWN`
- `SUPERSEDED`
- `INVALIDATED`

Existencia de documento, contenido declarado del documento y efecto jurídico del documento son capas distintas.

## 5. IA

La IA puede:
- detectar contradicciones;
- resumir;
- calcular;
- señalar verificaciones vencidas;
- proponer clasificaciones;
- preparar acciones.

La IA no puede por sí sola:
- convertir inferencia en hecho verificado;
- cerrar disputa;
- modificar equity;
- crear deuda exigible;
- despedir/sancionar;
- ejecutar distribución;
- declarar propiedad;
- eliminar evidencia protegida;
- aplicar regla no verificada como permitida.

Toda salida material conserva origen/modelo/versión/confianza y estado de revisión.

## 6. Compliance Pack como superficie de ataque

Una regla jurisdiccional debe ser tratada como configuración crítica.

Mínimos:
- jurisdicción;
- dominio;
- forma jurídica/sector/contexto aplicable;
- fuente oficial;
- autoridad;
- referencia;
- hash/identidad de fuente cuando sea viable;
- versión;
- effective_from/effective_to;
- operación-fecha a la que aplica;
- verification_status;
- verified_by;
- fecha de revisión;
- next_review_date;
- supersedes/superseded_by;
- limitaciones;
- evidencia/aprobación requerida;
- action_if_uncertain.

Reglas materiales se versionan append-only: cambiar una regla produce nueva versión.

`VERIFICATION_EXPIRED` / `PENDING_VERIFY` nunca producen `ALLOWED` automáticamente.

## 7. Evidencia resistente a administrador privilegiado

Append-only y hash interno protegen contra errores/aplicación común, pero no son suficientes frente a un DBA que controla la misma base.

Para eventos materiales futuros debe existir anclaje independiente, seleccionando una solución proporcional:
- almacenamiento WORM externo;
- export firmado periódico;
- Merkle/root firmado con clave fuera de PostgreSQL;
- timestamp externo;
- SIEM/log independiente con retención propia.

No se requiere blockchain.

## 8. Mantenimiento y soporte

No existirán `modo dios` ni BYPASSRLS como solución operativa ordinaria.

Acceso administrativo futuro:
- just-in-time;
- tenant explícito;
- ticket/motivo;
- ventana temporal;
- permisos mínimos;
- funciones estrechas;
- auditoría reforzada;
- separación de funciones en actos materiales;
- anclaje externo cuando aplique.

Migración y corrección histórica usan provenance `MIGRATION`/`MAINTENANCE`; nunca se presentan como hechos nativos sin marcar.

## 9. Privacidad, supresión y backups

No existe política universal de “guardar siempre” ni “borrar siempre”.

La decisión depende de Compliance Pack + estado del dato + legal hold + necesidad legítima.

Requisitos:
- solicitud registrada;
- revisión cuando corresponda;
- legal hold bloquea supresión solo en su alcance;
- no retención indefinida por incertidumbre;
- propagación de supresión a réplicas/backups según arquitectura y jurisdicción;
- restore debe reconciliar solicitudes/holds/eventos posteriores al backup;
- logs deben minimizar PII.

## 10. Invariantes canónicos

1. Hecho y calificación son entidades conceptualmente distintas.
2. Una reclasificación nunca elimina su predecesora.
3. Sistema-time y business-time no se fusionan.
4. Un documento recibido posteriormente nunca parece haber sido recibido retroactivamente.
5. Beneficiario material no puede ser único aprobador.
6. RBAC no sustituye conflicto de interés ni separación de funciones.
7. Dispute y legal hold tienen alcance mínimo explícito.
8. Ninguna disputa congela toda la empresa por defecto.
9. Inferencia IA no se convierte silenciosamente en verdad.
10. Regla jurisdiccional aplicada queda sellada por versión.
11. Nueva regla no reescribe evaluación histórica.
12. Toda nueva tabla tenant-aware debe heredar aislamiento equivalente a Core.
13. Soporte/mantenimiento privilegiado nunca es silencioso.
14. Evidencia crítica contra DBA requiere frontera de confianza externa.
15. Borrado/retención dependen de jurisdicción; ambos son auditables.
16. Restore/migration conserva provenance.
17. La arquitectura registra conflictos; no los adjudica.

## 11. Gate de implementación de IQG-110+

Antes de que Codex implemente físicamente IQG-110/120/121/122 debe existir:

1. ER/modelo físico revisado;
2. matriz de transiciones de estado;
3. matriz de permisos + SoD + conflicto de interés;
4. RLS/tenant isolation plan;
5. estrategia de provenance;
6. estrategia de evidence anchoring proporcional;
7. diseño de dispute/legal hold mínimo;
8. política de retención/supresión por pack;
9. pruebas negativas derivadas del red team;
10. revisión DeepSeek del diseño físico;
11. validación profesional de reglas jurídicas materiales por jurisdicción.

## 12. Relación con IQG-001.2

IQG-123 **NO reabre IQG-001.2**.

El cierre inmediato del Core sigue siendo:

`Codex PG16 → DeepSeek reauditoría runtime → ChatGPT synthesis`

Los controles de IQG-123 entran únicamente cuando el ticket futuro correspondiente los necesite, salvo que un hallazgo ya forme parte explícita de la remediación vigente de IQG-001.2.

**CEO_ACTION_REQUIRED:** false.