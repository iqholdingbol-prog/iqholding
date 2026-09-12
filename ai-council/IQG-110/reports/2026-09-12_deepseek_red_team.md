# IQG-110 / IQG-120 / IQG-121 / IQG-122 — Red Team Independiente

**Rol:** DeepSeek — Red Team de seguridad, integridad, fraude interno y trazabilidad  
**Fecha:** 2026-09-12  
**Ticket:** IQG-110 + extensiones legales

> Informe recibido del auditor externo. DeepSeek declaró expresamente que no tuvo acceso directo a IQG-110/120/121/122 ni al handoff; auditó los 15 principios contenidos en el prompt, MASTER_CONTEXT y el esquema IQG-001.2 previamente revisado. Por ello sus severidades deben ser sintetizadas contra el alcance real por ChatGPT antes de convertirse en backlog.

## Veredicto original

**CHANGES_REQUIRED**

## P0 reportados por DeepSeek

1. El esquema IQG-001.2 todavía no materializa `PENDING_CLASSIFICATION`, `SYSTEM_INFERRED`, `CONTRADICTED`, `DISPUTE`, `LEGAL_HOLD` ni provenance.
2. No existe una ruta privilegiada estrecha de mantenimiento para migración/corrección.
3. No existe evidencia anclada fuera de la propia base para detectar manipulación por un DBA.
4. La política de que IA no tome decisiones jurídicas de alto impacto todavía no tiene un modelo físico completo.

## P1 reportados

- anonimización centrada en cliente;
- validación incompleta de usuario/empresa activos;
- ausencia de `rule_version` completa;
- RBAC sin separación de funciones/quórum/conflicto de interés;
- configuración corporativa sensible sin modelo temporal completo.

## Principales ataques identificados

DeepSeek generó 62 escenarios de ataque sobre:

- clasificación y reclasificación retroactiva;
- colusión y fraude interno;
- abuso de disputas;
- abuso de legal hold;
- manipulación histórica;
- Compliance Packs falsos/desactualizados;
- IA fabricando hechos;
- privacidad vs conservación de evidencia;
- fugas multi-tenant;
- restauración de backups y cadena de custodia.

## Invariantes propuestos por DeepSeek

- una clasificación histórica nunca desaparece;
- nadie puede aprobar en solitario un acto del que se beneficia materialmente;
- fecha declarada de documento y fecha de recepción servidor son distintas;
- la versión normativa aplicada se conserva con fuente/hash/verificador;
- no hay retroactividad silenciosa;
- una disputa congela solo el objeto/material afectado;
- apertura y cierre de disputa se segregan;
- legal hold requiere control reforzado;
- evidencia bajo hold no se modifica silenciosamente;
- inferencias IA se distinguen de hechos verificados;
- toda tabla tenant-aware debe aplicar aislamiento;
- cambios sensibles deben ser temporalmente trazables.

## Modelos mínimos sugeridos

DeepSeek propuso modelos conceptuales para:

- `DISPUTE`;
- `LEGAL_HOLD`;
- provenance;
- revisión humana;
- conflicto de interés;
- separación de funciones y doble aprobación;
- soporte `break-glass` auditado.

## Sobreingeniería que recomendó evitar

- blockchain;
- DMS legal completo;
- firma notarial propia;
- tribunal interno;
- DSL jurídico completo;
- detección compleja de colusión por grafos.

## Riesgos residuales declarados

DeepSeek reconoce que ningún software puede eliminar fraude humano externo al sistema, documentos falsos aceptados por personas, disputas hereditarias/familiares, órdenes de autoridad, negligencia humana al aceptar IA o robo de infraestructura fuera del control del producto.

## Nota de autoridad

Este archivo preserva la posición del red team. La clasificación canónica aceptada/rechazada se documenta por separado en la síntesis de ChatGPT.