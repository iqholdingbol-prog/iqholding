\set ON_ERROR_STOP on

-- Todo lo que existe en este archivo es exclusivo del clúster efímero QA.
-- No modifica los roles de aplicación ni pasarela definidos por el DDL.
DO $qa_precondicion$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'iqg_test_admin') THEN
        RAISE EXCEPTION 'El runner PG16 debe crear iqg_test_admin antes del soporte QA';
    END IF;
END;
$qa_precondicion$;

-- Las identidades de conexión deben ser nuevas en el clúster efímero. El
-- arnés no elimina memberships existentes para fabricar un negativo verde.
DO $qa_roles$
BEGIN
    IF EXISTS (
        SELECT 1
          FROM pg_roles
         WHERE rolname IN ('qa_bootstrap', 'qa_untrusted', 'qa_app_probe', 'qa_gateway_probe')
    ) THEN
        RAISE EXCEPTION 'El arnés PG16 requiere probes QA nuevos; no corrige roles QA preexistentes';
    END IF;

    CREATE ROLE qa_bootstrap LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE
        NOREPLICATION NOBYPASSRLS NOINHERIT;
    CREATE ROLE qa_untrusted LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE
        NOREPLICATION NOBYPASSRLS NOINHERIT;
    CREATE ROLE qa_app_probe LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE
        NOREPLICATION NOBYPASSRLS NOINHERIT;
    CREATE ROLE qa_gateway_probe LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE
        NOREPLICATION NOBYPASSRLS NOINHERIT;
END;
$qa_roles$;

DO $qa_membership_precondition$
BEGIN
    IF EXISTS (
        SELECT 1
          FROM pg_auth_members AS membership
         WHERE membership.member IN (
                   'qa_bootstrap'::regrole,
                   'qa_untrusted'::regrole,
                   'qa_app_probe'::regrole,
                   'qa_gateway_probe'::regrole
               )
           AND membership.roleid IN (
                   'iqg_owner'::regrole,
                   'iqg_app'::regrole,
                   'iqg_gateway'::regrole,
                   'iqg_bootstrap_invoker'::regrole
               )
    ) THEN
        RAISE EXCEPTION 'El arnés PG16 no puede observar probes QA con memberships IQG preexistentes';
    END IF;
END;
$qa_membership_precondition$;

GRANT iqg_bootstrap_invoker TO qa_bootstrap
    WITH ADMIN FALSE, INHERIT TRUE, SET FALSE;
GRANT iqg_app TO qa_app_probe
    WITH ADMIN FALSE, INHERIT TRUE, SET TRUE;
GRANT iqg_gateway TO qa_gateway_probe
    WITH ADMIN FALSE, INHERIT TRUE, SET TRUE;

CREATE SCHEMA qa_harness AUTHORIZATION iqg_test_admin;
REVOKE ALL ON SCHEMA qa_harness FROM PUBLIC;

-- qa_untrusted sólo puede resolver la sonda de contexto; no recibe endpoint ni
-- tablas. qa_bootstrap hereda provisioning desde iqg_bootstrap_invoker.
GRANT USAGE ON SCHEMA iqg_core TO qa_untrusted;
GRANT EXECUTE ON FUNCTION iqg_core.contexto_bootstrap_activo()
    TO qa_bootstrap, qa_untrusted;

-- El soporte QA no pertenece al superusuario: se crea con una identidad de
-- prueba no privilegiada y queda aislado de los roles de aplicación.
SET ROLE iqg_test_admin;

CREATE TABLE qa_harness.fixture (
    codigo text PRIMARY KEY,
    company_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    usuario_id uuid NOT NULL
);

CREATE TABLE qa_harness.lock_probe (
    id integer PRIMARY KEY,
    valor integer NOT NULL DEFAULT 0
);
INSERT INTO qa_harness.lock_probe (id) VALUES (1), (2);

CREATE OR REPLACE FUNCTION qa_harness.assert_true(
    p_condicion boolean,
    p_codigo text
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_condicion IS DISTINCT FROM true THEN
        RAISE EXCEPTION 'Fallo de arnés PG16: %', p_codigo;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION qa_harness.set_context_for(p_codigo text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = qa_harness, pg_catalog, pg_temp
AS $$
DECLARE
    v_fixture qa_harness.fixture%ROWTYPE;
BEGIN
    SELECT * INTO STRICT v_fixture
      FROM qa_harness.fixture
     WHERE codigo = p_codigo;

    PERFORM set_config('iqg.company_id', v_fixture.company_id::text, false);
    PERFORM set_config('iqg.branch_id', v_fixture.branch_id::text, false);
    PERFORM set_config('iqg.usuario_id', v_fixture.usuario_id::text, false);
    PERFORM set_config('iqg.actor_tipo', 'SISTEMA', false);
    PERFORM set_config('iqg.motivo_codigo', 'QA_HARNESS', false);
    PERFORM set_config('iqg.correlation_id', '', false);
    PERFORM set_config('iqg.direccion_ip_cifrada', '', false);
    PERFORM set_config('iqg.direccion_ip_clave_referencia', '', false);
    PERFORM set_config('iqg.direccion_ip_version_sobre', '', false);
    PERFORM set_config('iqg.provisionamiento_origen', '', false);
    PERFORM set_config('iqg.provisionamiento_clave', '', false);
END;
$$;

GRANT USAGE ON SCHEMA qa_harness TO iqg_owner;
GRANT SELECT ON qa_harness.fixture TO iqg_owner;
GRANT EXECUTE ON FUNCTION qa_harness.assert_true(boolean, text) TO iqg_owner;
GRANT EXECUTE ON FUNCTION qa_harness.set_context_for(text) TO iqg_owner;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA qa_harness FROM PUBLIC;
GRANT EXECUTE ON FUNCTION qa_harness.assert_true(boolean, text) TO iqg_owner;
GRANT EXECUTE ON FUNCTION qa_harness.set_context_for(text) TO iqg_owner;
RESET ROLE;
