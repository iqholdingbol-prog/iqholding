\set ON_ERROR_STOP on
BEGIN;
SELECT * FROM iqg_core.provisionar_empresa(
    'QA_CONCURRENTE',
    '33333333-3333-4333-8333-333333333333',
    decode('01' || repeat('00', 29), 'hex'),
    decode('01' || repeat('00', 29), 'hex'),
    NULL::bytea,
    '33333333-3333-4333-8333-333333333334',
    'BO', NULL, false, false, NULL,
    'BOB', 'QA_C_1', 'QA empresa concurrente', 'America/La_Paz',
    decode('01' || repeat('00', 29), 'hex'),
    decode('01' || repeat('00', 29), 'hex'),
    '33333333-3333-4333-8333-333333333335',
    '30000000-0000-4000-8000-000000000003',
    NULL::bytea
);
SELECT pg_sleep(1.5);
COMMIT;
