\set ON_ERROR_STOP on
BEGIN;
SELECT set_config('iqg.company_id', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', true);
SELECT set_config('iqg.branch_id', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaab', true);
SELECT set_config('iqg.usuario_id', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaac', true);
SELECT set_config('iqg.provisionamiento_origen', 'QA_BOOTSTRAP', true);
SELECT set_config('iqg.provisionamiento_clave', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaad', true);
INSERT INTO iqg_core.empresa (company_id, branch_id, creado_por_usuario_id, nombre_legal_cifrado, referencia_clave_operativa_externa, pais_codigo, moneda_predeterminada)
VALUES ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaab', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaac', decode('01' || repeat('00', 29), 'hex'), 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaae', 'BO', 'BOB');
COMMIT;
