\set ON_ERROR_STOP on

-- PostgreSQL 16.15: una policy SELECT de reintento puede exponer una reserva
-- por clave, mientras SELECT FOR KEY SHARE incorpora la política modificadora
-- tenant-scoped. El fixture es transaccional y no toca objetos IQG.
BEGIN;

CREATE ROLE qa_retry_rls_owner
    NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS NOINHERIT;
CREATE SCHEMA qa_retry_rls AUTHORIZATION qa_retry_rls_owner;

SET LOCAL ROLE qa_retry_rls_owner;
CREATE TABLE qa_retry_rls.reserva (
    reserva_id uuid PRIMARY KEY,
    tenant_id uuid NOT NULL,
    retry_key uuid NOT NULL UNIQUE
);
ALTER TABLE qa_retry_rls.reserva ENABLE ROW LEVEL SECURITY;
ALTER TABLE qa_retry_rls.reserva FORCE ROW LEVEL SECURITY;

CREATE POLICY tenant_all ON qa_retry_rls.reserva
    FOR ALL TO qa_retry_rls_owner
    USING (tenant_id = current_setting('qa_retry.tenant_id', true)::uuid)
    WITH CHECK (tenant_id = current_setting('qa_retry.tenant_id', true)::uuid);
CREATE POLICY retry_select ON qa_retry_rls.reserva
    FOR SELECT TO qa_retry_rls_owner
    USING (retry_key = current_setting('qa_retry.retry_key', true)::uuid);

SELECT set_config('qa_retry.tenant_id', '11111111-1111-1111-1111-111111111111', true);
INSERT INTO qa_retry_rls.reserva (reserva_id, tenant_id, retry_key)
VALUES (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    '11111111-1111-1111-1111-111111111111',
    'cccccccc-cccc-cccc-cccc-cccccccccccc'
);

SELECT set_config('qa_retry.tenant_id', '22222222-2222-2222-2222-222222222222', true);
SELECT set_config('qa_retry.retry_key', 'cccccccc-cccc-cccc-cccc-cccccccccccc', true);

DO $provision_retry_rls_locking_regression$
DECLARE
    v_plain uuid;
    v_locked uuid;
BEGIN
    SELECT r.reserva_id
      INTO v_plain
      FROM qa_retry_rls.reserva AS r
     WHERE r.retry_key = current_setting('qa_retry.retry_key', true)::uuid;

    IF v_plain <> 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid THEN
        RAISE EXCEPTION 'PROVISION_RETRY_RLS_LOCKING_REGRESSION: plain SELECT no expuso la reserva por retry key';
    END IF;

    SELECT r.reserva_id
      INTO v_locked
      FROM qa_retry_rls.reserva AS r
     WHERE r.retry_key = current_setting('qa_retry.retry_key', true)::uuid
     FOR KEY SHARE;

    IF v_locked IS NOT NULL THEN
        RAISE EXCEPTION 'PROVISION_RETRY_RLS_LOCKING_REGRESSION: FOR KEY SHARE no aplicó la frontera tenant modificadora';
    END IF;
END;
$provision_retry_rls_locking_regression$;

ROLLBACK;
