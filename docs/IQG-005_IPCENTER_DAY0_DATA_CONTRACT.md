# IQG-005 — IPCENTER Day 0 Data Contract

**Fecha:** 2026-09-15
**Estado:** `DESIGN_V1`
**Objetivo:** definir el mínimo dato útil para reactivar IPCENTER y permitir que IQ GROWTH mida conversión, economía, riesgo y aprendizaje sin construir todavía un sistema completo.

## 1. Principio
Cada solicitud debe poder reconstruirse desde la necesidad del cliente hasta su resultado final, sin inventar campos ausentes y sin mezclar solicitud, cotización, compra, venta, pago o entrega.

## 2. Entidades mínimas
### CUSTOMER_REQUEST
- request_id
- company_id
- branch_id / operating_unit_id
- created_at_server
- created_by
- customer_id cuando exista
- customer_contact_channel
- acquisition_channel
- campaign_id opcional
- request_text_original
- attachment_refs opcionales
- request_category
- city / location cuando el cliente la proporcione
- urgency
- budget_min / budget_max / currency cuando exista
- status

### REQUIREMENTS
- request_id
- requirement_version
- use_case
- must_have[]
- nice_to_have[]
- compatibility_constraints[]
- budget
- timing_requirement
- notes
- source: customer / advisor / inferred_with_confirmation

### PRODUCT_CANDIDATE
- candidate_id
- request_id
- manufacturer
- model
- variant/configuration
- part_number/SKU cuando exista
- key_specs
- fit_reason
- fit_risks
- confidence
- source_refs[]
- observed_at

### SUPPLIER_OFFER
- offer_id
- candidate_id
- supplier_id
- source_url/evidence_ref
- price
- currency
- observed_at
- availability_observed
- condition
- warranty
- return_policy
- seller_reputation_evidence
- shipping_origin
- expiry/valid_until cuando exista
- uncertainty_notes

### QUOTATION
- quote_id
- request_id
- quote_version
- candidate_id
- route_option_id cuando exista
- final_customer_price
- currency
- validity_until
- estimated_lead_time_range
- customer_visible_terms
- internal_cost_estimate
- target_margin
- risk_buffer cuando corresponda
- approval_status
- approved_by
- created_at_server

### CUSTOMER_DECISION
- quote_id
- decision: accepted / rejected / expired / pending
- decision_at
- rejection_reason cuando se conozca
- selected_option

### PROCUREMENT
- procurement_id
- accepted_quote_id
- supplier_id
- supplier_order_ref
- purchase_price
- currency
- payment_status
- purchase_at
- evidence_refs[]
- physical_unit_expected_count

### PHYSICAL_ITEM
- physical_item_id
- procurement_id
- product_model_ref
- serial
- IMEI
- part_number
- condition_received
- packaging_condition
- evidence_refs[]
- custody_status

### FULFILLMENT / LOGISTICS EVENT
- event_id
- procurement/order ref
- event_type
- occurred_at
- location/node
- actor/operator
- evidence_refs[]
- notes

### SALE / PAYMENT
Debe reutilizar contratos universales de IQ GROWTH; nunca crear una “venta IPCENTER” incompatible con Core.

### WARRANTY / INCIDENT
- incident_id
- physical_item_id/order_id
- type
- reported_at
- customer_claim
- evidence
- responsible_process
- resolution
- cost_impact
- status

## 3. Campos mínimos para operar manualmente desde Día 0
Aunque el software todavía no exista, toda solicitud real debe intentar conservar:
1. fecha/hora;
2. cliente/contacto;
3. canal de llegada;
4. ciudad;
5. qué busca;
6. presupuesto si lo indica;
7. producto recomendado/cotizado;
8. proveedor/fuente usados;
9. precio cliente;
10. costo estimado interno;
11. decisión del cliente;
12. motivo de pérdida cuando se conozca;
13. fecha de compra si se concreta;
14. fecha/estado de entrega;
15. margen/contribución estimada/real;
16. incidencia/garantía si ocurre.

## 4. Calidad/provenance
Cada dato debe poder etiquetarse como:
- `SYSTEM_OBSERVED`
- `OWNER_CONFIRMED`
- `CUSTOMER_PROVIDED`
- `DOCUMENT_SUPPORTED`
- `SUPPLIER_OBSERVED`
- `SYSTEM_CALCULATED`
- `ESTIMATED`
- `STALE`
- `UNKNOWN`

Un dato externo observado en web debe guardar URL/fuente y timestamp; no se conserva como “precio vigente” indefinidamente.

## 5. Conversión y economía derivables
Con este contrato mínimo IQ GROWTH debe poder calcular después:
- requests → quotes;
- quotes → accepted;
- accepted → delivered;
- tiempo request→quote;
- tiempo quote→decision;
- lead time total;
- ticket promedio;
- contribución/margen por operación;
- pérdida por canal/motivo;
- categorías demandadas;
- clientes nuevos/recurrentes;
- recurrencia/referidos;
- costo de garantía/incidencias;
- proveedor/ruta con mejor desempeño histórico.

## 6. Privacidad y acceso
- Datos de clientes se aíslan por empresa/unidad y permisos.
- Contactos WhatsApp/Facebook no se importan indiscriminadamente al Core sin definir fuente, base legal/consentimiento aplicable y propósito.
- Vista cliente nunca expone automáticamente costo interno, margen, notas de riesgo internas ni negociaciones con proveedores.

## 7. No construir todavía
Este contrato no autoriza:
- scraping masivo indiscriminado;
- compras autónomas;
- decisiones legales automáticas;
- 20 agentes independientes;
- catálogo de miles de productos;
- integración total de Meta/WhatsApp antes de validar el flujo manual.

**Gate:** `DATA_CONTRACT_READY_FOR_MANUAL_PILOT`; implementación técnica queda subordinada a IQG-001.2/001.3.
