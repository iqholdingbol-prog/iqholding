\set ON_ERROR_STOP on
SET ROLE iqg_owner;
SELECT qa_harness.set_context_for('A1');
INSERT INTO iqg_core.operacion_linea (
    operacion_linea_id, company_id, branch_id, creado_por_usuario_id, operacion_id,
    elemento_id, numero_linea, nombre_elemento_snapshot, unidad_medida_codigo,
    cantidad, moneda_codigo, precio_unitario_menor, importe_bruto_menor,
    descuento_menor, impuesto_menor, importe_total_menor
) VALUES (
    'a1500000-0000-4000-8000-0000000000ff',
    iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(),
    'a1400000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001',
    99, 'Unidad inválida QA', 'UNIDAD_QUIETA', 1, 'BOB', 100, 100, 0, 0, 100
);
