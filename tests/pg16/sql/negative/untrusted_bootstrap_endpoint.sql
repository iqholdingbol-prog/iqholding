\set ON_ERROR_STOP on

DO $untrusted_probe_identity$
BEGIN
    IF session_user <> 'qa_untrusted' THEN
        RAISE EXCEPTION 'BOOT-07 requiere una sesión qa_untrusted real';
    END IF;
END;
$untrusted_probe_identity$;

BEGIN;
SELECT set_config('iqg.company_id', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', true);
SELECT set_config('iqg.branch_id', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaab', true);
SELECT set_config('iqg.usuario_id', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaac', true);
SELECT set_config('iqg.provisionamiento_origen', 'QA_FORGED', true);
SELECT set_config('iqg.provisionamiento_clave', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaad', true);

SELECT * FROM iqg_core.provisionar_empresa(
    'QA_FORGED',
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaad',
    decode('01' || repeat('00', 29), 'hex'),
    decode('01' || repeat('00', 29), 'hex'),
    NULL::bytea,
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaab',
    'BO', NULL, false, false, NULL,
    'BOB', 'QA_FORGED_BRANCH', 'QA forged', 'America/La_Paz',
    decode('01' || repeat('00', 29), 'hex'),
    decode('01' || repeat('00', 29), 'hex'),
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaac',
    '30000000-0000-4000-8000-000000000003',
    NULL::bytea
);
ROLLBACK;
