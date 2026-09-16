\set ON_ERROR_STOP on
BEGIN;
SET LOCAL ROLE iqg_owner;
SELECT qa_harness.set_context_for('A1');
INSERT INTO iqg_core.precio_vigente (
    precio_vigente_id, company_id, branch_id, creado_por_usuario_id, elemento_id,
    moneda_codigo, importe_menor, valid_from, reemplaza_precio_vigente_id,
    origen_idempotencia, clave_idempotencia, motivo_codigo
) VALUES (
    'a1100000-0000-4000-8000-000000000011',
    iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(),
    'a1000000-0000-4000-8000-000000000001', 'BOB', 110, '2027-01-01 00:00:00+00',
    'a1100000-0000-4000-8000-000000000001', 'QA_PRECIO_SUCESOR_A',
    'a1100000-0000-4000-8000-000000000012', 'QA_PRUEBA'
);
SELECT pg_sleep(2);
COMMIT;
