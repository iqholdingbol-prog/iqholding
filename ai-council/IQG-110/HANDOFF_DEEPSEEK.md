# IQG-110 / IQG-120 / IQG-121 / IQG-122 — Handoff a DeepSeek

**Estado:** READY FOR DEEPSEEK RED TEAM  
**Fecha:** 2026-09-11  
**Owner actual:** DeepSeek — integridad/seguridad/red team  
**Coordinación:** ChatGPT  
**CEO_ACTION_REQUIRED:** false

## Documentos obligatorios

- `docs/MASTER_CONTEXT.md`
- `docs/IQG-110_UNIVERSAL_BUSINESS_RELATIONSHIPS_SPEC.md`
- `docs/IQG-120_JURISDICTIONAL_COMPLIANCE_ARCHITECTURE.md`
- `docs/IQG-121_LEGAL_RISK_GOVERNANCE.md`
- `docs/IQG-122_LEGAL_DEFENSIBILITY_ADDENDUM.md`
- `ai-council/IQG-110/reports/2026-09-11_2355_claude_legal_risk_challenge.md`

## Objetivo

Intentar romper la integridad y defensibilidad del modelo sin interpretar ni inventar legislación.

Prioridades:

1. fraude interno;
2. manipulación histórica;
3. bypass de RBAC/segregación de funciones;
4. abuso de `DISPUTE` para paralizar la empresa;
5. cierre fraudulento de controversias;
6. bypass de `LEGAL HOLD`;
7. reclasificación maliciosa de `PENDING_CLASSIFICATION`;
8. persistencia de inferencias IA como hechos;
9. uso de reglas expiradas/no verificadas;
10. aplicación retroactiva incorrecta de Compliance Packs;
11. filtración cross-company/cross-branch de evidencia jurídica;
12. abuso de borrado/rectificación frente a retención;
13. documentos falsos, revocados o contradictorios;
14. colusión entre usuarios autorizados;
15. recuperación/rollback que destruya trazabilidad.

## Regla

DeepSeek no debe proponer legislación ni declarar legalidad. Debe identificar vulnerabilidades de sistema, invariantes, estados y controles técnicos/probatorios.

El resultado debe terminar en uno:

- `RED_TEAM_PASS_WITH_CONDITIONS`
- `CHANGES_REQUIRED`
- `ARCHITECTURE_UNSAFE`
