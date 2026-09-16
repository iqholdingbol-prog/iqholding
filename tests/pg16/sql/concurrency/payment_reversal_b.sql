\set ON_ERROR_STOP on
BEGIN;
SET LOCAL ROLE iqg_owner;
SELECT qa_harness.set_context_for('A1');
INSERT INTO iqg_core.pago (
    pago_id, company_id, branch_id, creado_por_usuario_id, operacion_id,
    pago_referencia_id, medio_pago_codigo, signo_impacto, moneda_codigo,
    importe_menor, origen_idempotencia, clave_idempotencia
) VALUES (
    'a1600000-0000-4000-8000-000000000021',
    iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(),
    'a1400000-0000-4000-8000-000000000001', 'a1600000-0000-4000-8000-000000000001',
    'EFECTIVO', -1, 'BOB', 60, 'QA_REVERSO_B', 'a1600000-0000-4000-8000-000000000022'
);
COMMIT;
