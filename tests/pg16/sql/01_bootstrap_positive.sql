\set ON_ERROR_STOP on

-- E: el miembro permitido puede hacer que el chequeo sea verdadero, pero solo
-- porque su session_user posee la capacidad de cluster y recibe un endpoint
-- explícito. Los valores iqg.* por sí solos nunca son la credencial.
BEGIN;
SELECT set_config('iqg.company_id', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', true);
SELECT set_config('iqg.branch_id', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaab', true);
SELECT set_config('iqg.usuario_id', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaac', true);
SELECT set_config('iqg.provisionamiento_origen', 'QA_BOOTSTRAP', true);
SELECT set_config('iqg.provisionamiento_clave', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaad', true);
SELECT iqg_core.contexto_bootstrap_activo() AS bootstrap_activo \gset
\if :bootstrap_activo
\else
  \quit 3
\endif
ROLLBACK;

-- Tenant A: capa operativa privada, sin obligación de facturación.
BEGIN;
SELECT * FROM iqg_core.provisionar_empresa(
    'QA_TENANT_A',
    '11111111-1111-4111-8111-111111111111',
    decode('01' || repeat('00', 29), 'hex'),
    decode('01' || repeat('00', 29), 'hex'),
    NULL::bytea,
    '11111111-1111-4111-8111-111111111112',
    'BO', NULL, false, false, NULL,
    'BOB', 'QA_A_1', 'QA empresa A / sucursal 1', 'America/La_Paz',
    decode('01' || repeat('00', 29), 'hex'),
    decode('01' || repeat('00', 29), 'hex'),
    '11111111-1111-4111-8111-111111111113',
    '10000000-0000-4000-8000-000000000001',
    NULL::bytea
);
COMMIT;

-- Tenant B: obligación fiscal Bolivia, para probar capa fiscal separada.
BEGIN;
SELECT * FROM iqg_core.provisionar_empresa(
    'QA_TENANT_B',
    '22222222-2222-4222-8222-222222222222',
    decode('01' || repeat('00', 29), 'hex'),
    decode('01' || repeat('00', 29), 'hex'),
    decode('01' || repeat('00', 29), 'hex'),
    '22222222-2222-4222-8222-222222222223',
    'BO', 'QA_REGIMEN', true, false, 'QA_REGLA_V1',
    'BOB', 'QA_B_1', 'QA empresa B / sucursal 1', 'America/La_Paz',
    decode('01' || repeat('00', 29), 'hex'),
    decode('01' || repeat('00', 29), 'hex'),
    '22222222-2222-4222-8222-222222222224',
    '20000000-0000-4000-8000-000000000002',
    NULL::bytea
);
COMMIT;
