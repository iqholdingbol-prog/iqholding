# BACKLOG.md
## IQ GROWTH — Lista de Tareas y Hoja de Ruta
### Versión: 1.2 · Fecha: 2026-09-15 · Prioridad: Por orden descendente

---

## CONVENCIONES
- **IQG-001** = Fundación del Núcleo Universal
- **IQG-002** = Laboratorio VANSAM
- **IQG-003** = Laboratorio Café Zacarías
- **IQG-004** = Laboratorio Chocolates (marca pendiente)
- **IQG-005** = Laboratorio IPCENTER / sourcing y procurement inteligente
- **IQG-100+** = Funciones de crecimiento y valor agregado
- **IQG-110+** = relaciones empresariales, cumplimiento jurisdiccional e integridad jurídica

> Responsables: C = Codex (construye), G = Gemini (evidencia externa/mercado), Ds = DeepSeek (seguridad/integridad), Cl = Claude (producto/sistemas), Ch = ChatGPT (arquitectura/coordinación), Iván = CEO / decisión final

---

## PRINCIPIO OPERATIVO DE LOS LABORATORIOS
- Los laboratorios son **empresas reales**, no demos.
- Deben seguir vendiendo, operando y mejorando mientras IQ GROWTH aprende de ellas.
- La secuencia de implementación de software no debe confundirse con la secuencia comercial.
- El mismo Core debe soportar los cuatro laboratorios sin hardcodear pizza, café, chocolate, laptops, celulares, drones o repuestos.

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
### Negocio real
- [ ] llevar VANSAM hacia 50–100 pizzas/día sostenibles, sujeto a capacidad/demanda/margen.
- [ ] validar cuándo una unidad es suficientemente estable/replicable para evaluar sucursales.

### IQ GROWTH
- [ ] Adaptar flujos operativos al Core sin contaminarlo con lógica `pizza`.
- [ ] Mantener V11 funcionando mientras se prueba nuevo.
- [ ] migración en producción sin interrupción.
- [ ] validar hechos de ventas/operación con datos diarios.
- [ ] medir clientes nuevos/recurrentes cuando exista dato válido.
- [ ] preparar captura prospectiva de tiempos/capacidad si V11 no tiene evidencia suficiente.
- [ ] cerrar catálogo real, precios, costos y estado de productos.
- [ ] completar ciclo real de ventas miércoles→lunes por SKU/tamaño.

---

## 🟠 IQG-003 — CAFÉ ZACARÍAS
### Negocio real
- [ ] medir venta actual en El Alto desde ahora, sin esperar la planta Senkata.
- [ ] estructurar canales actuales: carritos/vehículos, puestos fijos/ambulantes, tiendas, kioscos y vendedores.
- [ ] desarrollar canal B2B: restaurantes, cafeterías, hoteles y mayoristas.
- [ ] validar 4 líneas comerciales: 2 torrados + 2 especiales, con precio/costo/margen reales.
- [ ] planificar expansión progresiva por ciudades bolivianas basada en evidencia.
- [ ] continuar finca + secado + traslado/proyecto de planta industrial Senkata.
- [ ] preparar capacidad futura de exportación de café verde con trazabilidad/calidad verificable.

### IQ GROWTH
- [ ] modelar lotes, transformación, rutas, vendedores/puntos y rendición sin contaminar Core.
- [ ] capturar datos actuales aunque la interfaz vertical completa todavía no exista.
- [ ] validar portabilidad del Core en agricultura + transformación + distribución.

---

## 🟠 IQG-004 — CHOCOLATES / MARCA PENDIENTE
### Negocio real
- [ ] mantener `BRAND_NAME_PENDING` hasta decisión CEO.
- [ ] validar abastecimiento real de cacao de Alto Beni, proveedor, costos y calidad.
- [ ] estructurar catálogo/formulaciones/presentaciones y costos reales.
- [ ] desarrollar comercialización fija/móvil/mayorista/minorista.
- [ ] diseñar integración física en Senkata compartiendo infraestructura con Café Zacarías sin mezclar datos/economía.

### IQ GROWTH
- [ ] modelar formulaciones, lotes, manufactura, merma y presentaciones como extensión vertical.
- [ ] capturar datos reales antes de construir software vertical amplio.

---

## 🟠 IQG-005 — IPCENTER / SOURCING & PROCUREMENT LAB
**Estado:** `DESIGN + AS_IS BASELINE`; no programación vertical hasta que el Core lo permita.

### Negocio real / reactivación
- [ ] auditar activos digitales históricos: Facebook, WhatsApp Business, web/catalogs, contactos y clientes.
- [ ] verificar tamaño/calidad/actividad actual de la audiencia; ~44k Facebook queda `CEO_REPORTED` hasta verificación.
- [ ] mapear base WhatsApp por ciudad/interés/actividad cuando sea legal y operativamente posible.
- [ ] definir oferta inicial: laptops + celulares y expansión controlada a drones/repuestos/productos especializados.
- [ ] definir política comercial: commerce / sourcing / B2B procurement según operación.
- [ ] definir garantía, responsabilidad, cotización y economía mínima viable por orden.
- [ ] reactivar ventas con datos medibles, no solo contenido/seguidores.

### Modelo operativo
- [ ] definir `CUSTOMER_REQUEST → REQUIREMENTS → PRODUCT_CANDIDATE → SUPPLIER_OFFER → QUOTATION → APPROVAL → PROCUREMENT → FULFILLMENT → DELIVERY/WARRANTY`.
- [ ] separar solicitud, cotización, order, procurement, sale, payment y cash movement.
- [ ] Product Fit inicial para laptops/celulares.
- [ ] Supplier verification con evidencia real.
- [ ] pricing interno separado de vista cliente.
- [ ] serial/IMEI/part-number cuando corresponda.
- [ ] trazabilidad/evidencia de recepción, control, entrega y garantía.
- [ ] compliance/importability como capacidad versionada con revisión humana cuando haya incertidumbre.

### IQ GROWTH
- [ ] crear `IQG-005_IPCENTER_VERTICAL_V1.md`.
- [ ] crear `IQG-005_IPCENTER_AS_IS_BASELINE_V1.md`.
- [ ] crear `IQG-005_IPCENTER_DAY0_DATA_CONTRACT.md`.
- [ ] crear `IQG-005_IPCENTER_GROWTH_BASELINE_V1.md`.
- [ ] usar IPCENTER para probar cotizaciones, sourcing, procurement, serialización, logística, garantías e inteligencia de demanda sin modificar el Core con conceptos de marca/categoría.

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
- [ ] aplicar Growth Engine progresivamente a Café Zacarías, Chocolates e IPCENTER con sus datos reales, sin construir cuatro motores distintos.
- [ ] prueba posterior con empresas externas para validar que el modelo no funciona solo dentro de IQHOLDING.

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
- [ ] extender evidencia aplicable a sourcing/importación IPCENTER sin inventar reglas automáticas.

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
- VANSAM: catálogo + ventas + datos reales.
- Café Zacarías: ventas actuales + canales + datos reales + planta/finca como track empresarial.
- Chocolates: identidad de marca pendiente + catálogo/costos/canales + datos reales.
- IPCENTER: AS-IS, activos digitales, modelo operativo, data contract y reactivación comercial; **sin código vertical todavía**.
- IQG-100 producto/UX/datos.
- IQG-110+ diseño y evidencia sin implementación material prematura.

### Próximo gate técnico
Cuando vuelva cuota Codex:

`REANUDAR IQG-001.2 → COMPLETAR HARNESS PG16 → EJECUTAR MATRIZ → DEEPSEEK REAUDIT → CHATGPT SYNTHESIS`

No iniciar IQG-001.3 productivo ni código de IQG-100/IQG-005 antes de ese gate.
