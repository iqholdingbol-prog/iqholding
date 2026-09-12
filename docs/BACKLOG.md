# BACKLOG.md
## IQ GROWTH — Lista de Tareas y Hoja de Ruta
### Versión: 1.1 · Fecha: 2026-09-12 · Prioridad: Por orden descendente

---

## CONVENCIONES
- **IQG-001** = Fundación del Núcleo Universal
- **IQG-002** = Laboratorio VANSAM
- **IQG-003** = Laboratorio Café Zacarías
- **IQG-004** = Laboratorio Chocolates La Florita
- **IQG-100+** = Funciones de crecimiento y valor agregado
- **IQG-110+** = relaciones empresariales, cumplimiento jurisdiccional e integridad jurídica

> Responsables: C = Codex (construye), G = Gemini (evidencia externa/mercado), Ds = DeepSeek (seguridad/integridad), Cl = Claude (producto/sistemas), Ch = ChatGPT (arquitectura/coordinación), Iván = CEO / decisión final

---

## 🔴 IQG-001 — FUNDACIÓN DEL NÚCLEO (PRIORIDAD MÁXIMA)

### IQG-001.1 — Modelo de Datos
- [x] Definir esquema relacional de referencia PostgreSQL 16.
- [x] Separar ORDER / SALE / PAYMENT / CASH / INVENTORY MOVEMENT.
- [x] company_id + branch_id como aislamiento base.
- [x] eventos/operaciones críticas append-only o versionadas.
- [x] separar capa operativa y fiscal.
- [x] auditoría estática inicial por DeepSeek.
- [ ] cerrar validación runtime junto con IQG-001.2.

### IQG-001.2 — Motor de Seguridad y Aislamiento
**Estado actual:** `CHECKPOINT_SAFE`; Codex congelado temporalmente por cuota.

- [x] diseño RLS + FORCE RLS.
- [x] roles sin LOGIN/SUPERUSER/BYPASSRLS.
- [x] postura de acceso privado app/gateway por defecto.
- [x] remediación estática parcial de hallazgos DeepSeek.
- [ ] completar bootstrap seguro N-03/C1.
- [ ] validar usuario/empresa activos N-04/C5.
- [ ] cerrar alcance de anonimización N-01/C4.
- [ ] cerrar unicidad/PII N-05/C3 mediante ADR/decisión técnica.
- [ ] completar harness PostgreSQL 16.
- [ ] ejecutar matriz runtime de RLS/roles/ACL/concurrencia/rollback/restore.
- [ ] reauditoría DeepSeek.
- [ ] síntesis ChatGPT y gate final.

### IQG-001.3 — Migración de Datos V11 → IQ GROWTH
**Estado:** plan y addendum listos; producción bloqueada hasta cerrar IQG-001.2 y Fase -1.

- [x] auditoría forense de V11.
- [x] plan de migración con Historia Sagrada, snapshots, lineage, quarantine y reconciliación.
- [x] challenge Claude y addendum.
- [ ] Fase -1: freeze verificable, backups/export, localStorage por terminal, hashes y evidence manifest.
- [ ] importer de prueba.
- [ ] shadow import.
- [ ] reconciliación.
- [ ] rollback probado.
- [ ] migración productiva solo después de gates.

### IQG-001.4 — Auditoría Final del Núcleo
- [ ] Claude revisa coherencia con producto y crecimiento.
- [ ] DeepSeek intenta romper seguridad, integridad y aislamiento.
- [ ] ChatGPT verifica arquitectura completa y deuda aceptada.
- [ ] Iván aprueba puesta en marcha del núcleo.

---

## 🟡 IQG-002 — VANSAM COMO PRIMER LABORATORIO
- [ ] Adaptar flujos operativos al Core sin contaminarlo con lógica `pizza`.
- [ ] Mantener V11 funcionando mientras se prueba nuevo.
- [ ] migración en producción sin interrupción.
- [ ] validar hechos de ventas/operación con datos diarios.
- [ ] medir clientes nuevos/recurrentes cuando exista dato válido.
- [ ] preparar captura prospectiva de tiempos/capacidad si V11 no tiene evidencia suficiente.

---

## 🟠 IQG-003 / IQG-004 — CAFÉ Y CHOCOLATE
- [ ] diferir implementación hasta validar VANSAM y primer cliente externo.
- [ ] luego probar portabilidad del Core en agroindustria/manufactura.
- [ ] trazabilidad de lotes, producción y transformación como extensiones verticales.
- [ ] NO modificar el núcleo con supuestos específicos de esos rubros.

---

## 🟢 IQG-100 — MOTOR DE CRECIMIENTO / PRIMER PRODUCTO

### IQG-100.0 — Descubrimiento y wedge
- [x] especificación Growth Engine.
- [x] validación de mercado Gemini + contraste competitivo.
- [x] challenge de producto Claude.
- [x] reducir tres pilares a un wedge único.

### IQG-100.1 — Control Diario de Crecimiento
**Pregunta del producto:**
> ¿Cómo está mi negocio frente a su objetivo económico y cuál es la acción concreta más útil que debo ejecutar ahora?

- [x] `IQG-100_MVP_WEDGE_SPEC.md`.
- [x] `IQG-100_DAILY_DECISION_ENGINE_SPEC.md`.
- [x] terminología económica: contribución/cobertura/brecha, no falsa utilidad neta.
- [x] `NEXT_BEST_ACTION` única, no lista de dashboards/recomendaciones.
- [x] human-in-the-loop para acciones externas/materiales.
- [ ] challenge final de UX/producto sobre el motor diario.
- [ ] contratos técnicos después de cerrar Core/migración.

### IQG-100.2 — Día 0 VANSAM
- [x] `IQG-100_VANSAM_DAY0_DATA_CONTRACT.md`.
- [x] separar `OBSERVED_CURRENT / DOCUMENT_SUPPORTED / OWNER_CONFIRMED / SYSTEM_CALCULATED / ESTIMATED / STALE / UNKNOWN`.
- [ ] revalidar calendario operativo actual.
- [ ] revalidar costos fijos actuales.
- [ ] elegir método inicial de costo variable.
- [ ] validar calidad de ventas recientes.
- [ ] producir `VANSAM BASELINE V1`.

### IQG-100.3 — Piloto VANSAM 30 días
- [x] diseño de piloto.
- [x] separar Product Value Gate de Business Outcome Gate.
- [x] definir absence test.
- [x] definir señal comercial externa mínima.
- [ ] ejecutar cuando exista soporte técnico suficiente.
- [ ] obtener primera señal de dueño externo.

### IQG-100.4 — Evolución posterior
- [ ] captura de costos con menor carga manual.
- [ ] recuperación/retención cuando exista base de clientes suficiente.
- [ ] atribución con confianza, no causalidad inventada.
- [ ] expansión a Café Zacarías y Chocolates solo después de prueba VANSAM/externa.

---

## ⚖️ IQG-110+ — RELACIONES, CUMPLIMIENTO Y DEFENSIBILIDAD

### IQG-110 — Relaciones empresariales universales
- [x] separar persona/socio/empleado/administrador/acreedor/aportante/beneficiario.
- [x] challenge Claude y corrección de recomendaciones de alto riesgo.
- [x] no adjudicar `propietario_economico`.
- [x] aceptar `PENDING_CLASSIFICATION` para hechos económicos no caracterizados.

### IQG-120 — Compliance por jurisdicción
- [x] arquitectura `CORE UNIVERSAL + COMPLIANCE PACK`.
- [x] mapa inicial Bolivia por Gemini.
- [x] registro de fuentes BO con estados de verificación.
- [ ] revisión profesional boliviana antes de activar reglas materiales.
- [ ] revisión contable/tributaria profesional para reglas fiscales.

### IQG-121/122/123 — Riesgo legal, defensibilidad y threat model
- [x] principio de doble protección: personas + IQHOLDING/IQ GROWTH.
- [x] no automatización jurídica de alto impacto.
- [x] provenance/contradicción/disputa/legal hold como diseño futuro.
- [x] red team DeepSeek con 62 escenarios.
- [x] separar evidencia de evento del sistema de verdad jurídica.
- [ ] diseño físico futuro, separado de IQG-001.2.

---

## ESTADO OPERATIVO ACTUAL

### Codex
`CHECKPOINT_SAFE` en IQG-001.2. No gastar cuota restante salvo riesgo de pérdida de trabajo.

### Trabajo paralelo autorizado
- IQG-100 producto/UX/datos.
- IQG-110+ diseño y evidencia sin implementación.
- preparación de inputs reales para Día 0 VANSAM.

### Próximo gate técnico
Cuando vuelva cuota Codex:

`REANUDAR IQG-001.2 → COMPLETAR HARNESS PG16 → EJECUTAR MATRIZ → DEEPSEEK REAUDIT → CHATGPT SYNTHESIS`

No iniciar IQG-001.3 productivo ni IQG-100 en código antes de ese gate.
