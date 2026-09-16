\set ON_ERROR_STOP on
BEGIN;
SET LOCAL ROLE iqg_owner;
SELECT qa_harness.set_context_for('B1');
INSERT INTO iqg_core.operacion (
    operacion_id, company_id, branch_id, creado_por_usuario_id,
    tipo_operacion_codigo, moneda_codigo, origen_idempotencia, clave_idempotencia
) VALUES (
    'b1700000-0000-4000-8000-000000000001',
    iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(),
    'VENTA', 'BOB', 'QA_FACTURA_SIN_LINEAS', 'b1700000-0000-4000-8000-000000000002'
);
INSERT INTO iqg_fiscal.factura (
    factura_id, company_id, branch_id, creado_por_usuario_id, operacion_id,
    tipo_documento_fiscal_codigo, pais_codigo_emision, regimen_fiscal_codigo_emision,
    version_regla_fiscal, identificador_fiscal_cifrado_snapshot,
    referencia_clave_fiscal_externa, version_sobre_fiscal, es_emision_obligatoria,
    moneda_codigo, importe_bruto_menor, descuento_menor, impuesto_menor,
    importe_total_menor, retencion_fiscal_anios
) VALUES (
    'b1800000-0000-4000-8000-000000000001',
    iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(),
    'b1700000-0000-4000-8000-000000000001', 'FACTURA_QA', 'BO', 'QA_REGIMEN',
    'QA_REGLA_V1', decode('01' || repeat('00', 29), 'hex'),
    'b1800000-0000-4000-8000-000000000002', 1, true, 'BOB', 0, 0, 0, 0, 10
);
COMMIT;
