\set ON_ERROR_STOP on
BEGIN;
SELECT set_config('iqg.company_id', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', true);
SELECT set_config('iqg.branch_id', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaab', true);
SELECT set_config('iqg.usuario_id', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaac', true);
SELECT set_config('iqg.provisionamiento_origen', 'QA_FORGED', true);
SELECT set_config('iqg.provisionamiento_clave', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaad', true);
SELECT NOT iqg_core.contexto_bootstrap_activo() AS rechazo_confirmado \gset
\if :rechazo_confirmado
\else
  \quit 3
\endif
ROLLBACK;
