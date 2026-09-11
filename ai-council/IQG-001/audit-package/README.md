# IQG-001 — AUDIT PACKAGE

Este directorio define el paquete mínimo que debe entregarse a una IA auditora cuando no tenga acceso directo y confiable al repositorio privado.

## Objetivo
Evitar que Iván actúe como mensajero, evitar copiar miles de líneas manualmente y evitar ampliar la visibilidad del repositorio innecesariamente.

## Contenido requerido
- artefacto exacto a auditar;
- commit SHA objetivo;
- informe del implementador;
- auditoría anterior relevante;
- documentos canónicos necesarios;
- alcance de auditoría;
- hash/manifest cuando se exporte fuera de GitHub.

## Para IQG-001.2
Commit objetivo:
`d564812dd3583e837b838654f14d6159c8a53d87`

Artefactos de referencia:
- `schemas/core_schema.sql`
- `ai-council/IQG-001/reports/2026-09-11_0212_codex.md`
- `ai-council/IQG-001/reports/2026-09-10_auditoria_deepseek.md`
- `docs/MASTER_CONTEXT.md`
- `ai-council/IQG-001/HANDOFF.md`

## Reglas
1. No sustituir el artefacto completo por fragmentos si la auditoría depende del archivo íntegro.
2. No hacer público todo el repositorio si basta un adjunto, ZIP o acceso puntual.
3. La IA auditora debe conocer el commit SHA exacto.
4. El informe producido debe guardarse como archivo nuevo e inmutable.
5. Nunca afirmar auditoría completa si la herramienta recibió contenido truncado.
6. Si se genera un bundle externo, incluir un `MANIFEST.md` con SHA-256 de cada archivo exportado.

## CEO Action Count
La preparación y entrega del paquete debe requerir `0` acciones del CEO cuando Dola tenga herramientas suficientes. Si una plataforma externa exige una carga manual, consolidar todo en una única acción.