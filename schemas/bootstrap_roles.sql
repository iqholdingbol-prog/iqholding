-- =============================================================================
-- IQ GROWTH — PHASE 0: PRIVILEGED INFRASTRUCTURE BOOTSTRAP (PostgreSQL 16)
-- Ticket: IQG-001.2
-- =============================================================================
--
-- Este artefacto establece únicamente la topología técnica de roles IQG. No
-- crea schemas, tablas, funciones, ACL de dominio ni datos operativos.
--
-- PRIVILEGED_BOOTSTRAP_PRINCIPAL es un concepto de capacidad, no el nombre de
-- un usuario ni un rol de aplicación. En PostgreSQL 16 de referencia debe poder
-- crear, asumir y eliminar un rol técnico NOLOGIN sin dejar una membresía
-- persistente; el arnés efímero demuestra esa capacidad usando `postgres`.
-- Si un proveedor administrado no puede demostrarla, debe fallar con
-- DEPLOYMENT_CAPABILITY_INCOMPATIBLE sin degradar la postura de seguridad.
--
-- Este principal no se convierte en miembro de iqg_owner, no es un rol IQG y
-- nunca participa del runtime normal de IQ GROWTH.
-- =============================================================================

BEGIN;

DO $phase0_privileged_bootstrap$
DECLARE
    v_probe_role name := format('iqg_phase0_probe_%s', txid_current())::name;
BEGIN
    IF current_user <> session_user THEN
        RAISE EXCEPTION
            'PHASE 0 debe comenzar como session_user, sin SET ROLE activo';
    END IF;

    IF current_user IN ('iqg_owner', 'iqg_app', 'iqg_gateway', 'iqg_bootstrap_invoker') THEN
        RAISE EXCEPTION
            'PRIVILEGED_BOOTSTRAP_PRINCIPAL debe ser independiente de los roles IQG';
    END IF;

    BEGIN
        -- Los advisory locks son locales a una base de datos y no pueden
        -- serializar roles, que viven en catálogos compartidos del clúster.
        -- Estos locks de relación usan los catálogos compartidos pg_authid y
        -- pg_auth_members, por lo que también se excluyen entre bases. El modo
        -- SHARE ROW EXCLUSIVE bloquea CREATE/ALTER/DROP ROLE y GRANT/REVOKE de
        -- memberships durante toda PHASE 0 sin conceder privilegios nuevos.
        LOCK TABLE pg_catalog.pg_authid, pg_catalog.pg_auth_members
            IN SHARE ROW EXCLUSIVE MODE;
        -- PHASE 0_CLUSTER_ROLE_LOCK_ACQUIRED: marcador para la prueba efímera
        -- de serialización entre dos bases del mismo clúster.

        -- Prueba concreta de la capacidad necesaria. Un creador CREATEROLE que
        -- deja una membership automática del bootstrap user falla aquí antes de
        -- crear cualquier rol IQG permanente. La transacción completa revierte.
        EXECUTE format(
            'CREATE ROLE %I NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS NOINHERIT',
            v_probe_role
        );

        IF EXISTS (
            SELECT 1
              FROM pg_auth_members AS membership
             WHERE membership.roleid = to_regrole(v_probe_role::text)
        ) THEN
            RAISE EXCEPTION
                'DEPLOYMENT_CAPABILITY_INCOMPATIBLE: PRIVILEGED_BOOTSTRAP_PRINCIPAL no puede crear un rol técnico sin membresías persistentes';
        END IF;

        EXECUTE format('SET LOCAL ROLE %I', v_probe_role);

        IF current_user <> v_probe_role THEN
            RAISE EXCEPTION
                'DEPLOYMENT_CAPABILITY_INCOMPATIBLE: SET LOCAL ROLE no asumió el rol técnico de prueba';
        END IF;

        RESET ROLE;
        EXECUTE format('DROP ROLE %I', v_probe_role);

        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'iqg_owner') THEN
            CREATE ROLE iqg_owner
                NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION
                NOBYPASSRLS NOINHERIT;
        ELSE
            ALTER ROLE iqg_owner
                NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION
                NOBYPASSRLS NOINHERIT;
        END IF;
        -- PHASE 0_OWNER_ROLE_READY: marcador para rollback después del primer
        -- rol técnico creado o endurecido.

        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'iqg_app') THEN
            CREATE ROLE iqg_app
                NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION
                NOBYPASSRLS NOINHERIT;
        ELSE
            ALTER ROLE iqg_app
                NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION
                NOBYPASSRLS NOINHERIT;
        END IF;

        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'iqg_gateway') THEN
            CREATE ROLE iqg_gateway
                NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION
                NOBYPASSRLS NOINHERIT;
        ELSE
            ALTER ROLE iqg_gateway
                NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION
                NOBYPASSRLS NOINHERIT;
        END IF;

        -- Este rol no es el principal privilegiado de infraestructura. Es una
        -- capacidad estrecha de provisioning operativo definida por ADR-0001.
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'iqg_bootstrap_invoker') THEN
            CREATE ROLE iqg_bootstrap_invoker
                NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION
                NOBYPASSRLS NOINHERIT;
        ELSE
            ALTER ROLE iqg_bootstrap_invoker
                NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION
                NOBYPASSRLS NOINHERIT;
        END IF;

        -- No hay relaciones permitidas entre los cuatro roles IQG. Las
        -- membresías de identidades de conexión hacia el invocador operativo
        -- son externas a esta topología y se validan por ADR-0001.
        REVOKE iqg_owner FROM iqg_app, iqg_gateway, iqg_bootstrap_invoker;
        REVOKE iqg_app FROM iqg_owner, iqg_gateway, iqg_bootstrap_invoker;
        REVOKE iqg_gateway FROM iqg_owner, iqg_app, iqg_bootstrap_invoker;
        REVOKE iqg_bootstrap_invoker FROM iqg_owner, iqg_app, iqg_gateway;
        -- PHASE 0_KNOWN_MEMBERSHIPS_NORMALIZED: marcador para rollback después
        -- de normalizar las memberships conocidas de la topología IQG.

        -- El bootstrap no modifica memberships externas desconocidas. Si un
        -- rol IQG ya recibe privilegios de un rol externo, falla cerrado para
        -- que la topología se revise explícitamente sin romper otro servicio.
        IF EXISTS (
            SELECT 1
              FROM pg_auth_members AS membership
             WHERE membership.member IN (
                    'iqg_owner'::regrole,
                    'iqg_app'::regrole,
                    'iqg_gateway'::regrole,
                    'iqg_bootstrap_invoker'::regrole
                )
        ) THEN
            RAISE EXCEPTION
                'DEPLOYMENT_CAPABILITY_INCOMPATIBLE: un rol IQG ya pertenece a otro rol; se requiere remediación explícita fuera de PHASE 0';
        END IF;

        -- El principal privilegiado es una capacidad temporal de despliegue,
        -- nunca una identidad de runtime. Si ya recibió una membership IQG,
        -- PHASE 0 no la revoca silenciosamente: falla cerrado para que la
        -- remediación quede trazable y no convierta al instalador en app,
        -- gateway u operador de provisioning.
        IF EXISTS (
            SELECT 1
              FROM pg_auth_members AS membership
             WHERE membership.member = session_user::regrole
               AND membership.roleid IN (
                   'iqg_owner'::regrole,
                   'iqg_app'::regrole,
                   'iqg_gateway'::regrole,
                   'iqg_bootstrap_invoker'::regrole
               )
        ) THEN
            RAISE EXCEPTION
                'DEPLOYMENT_CAPABILITY_INCOMPATIBLE: PRIVILEGED_BOOTSTRAP_PRINCIPAL conserva una membership IQG; se requiere remediación explícita fuera de PHASE 0';
        END IF;

        IF (SELECT count(*)
              FROM pg_roles
             WHERE rolname IN ('iqg_owner', 'iqg_app', 'iqg_gateway', 'iqg_bootstrap_invoker')) <> 4
           OR EXISTS (
                SELECT 1
                  FROM pg_roles
                 WHERE rolname IN ('iqg_owner', 'iqg_app', 'iqg_gateway', 'iqg_bootstrap_invoker')
                   AND (rolsuper OR rolbypassrls OR rolcanlogin OR rolcreatedb
                        OR rolcreaterole OR rolreplication OR rolinherit)
           ) THEN
            RAISE EXCEPTION
                'PHASE 0 no pudo establecer roles IQG NOLOGIN, NOSUPERUSER, NOBYPASSRLS, NOINHERIT y sin privilegios de cluster';
        END IF;

        IF EXISTS (
            SELECT 1
              FROM pg_auth_members AS membership
             WHERE membership.roleid = 'iqg_owner'::regrole
        ) THEN
            RAISE EXCEPTION
                'iqg_owner debe terminar PHASE 0 con ZERO MEMBERS';
        END IF;

        IF EXISTS (
            SELECT 1
              FROM pg_auth_members AS membership
             WHERE membership.member IN (
                    'iqg_owner'::regrole,
                    'iqg_app'::regrole,
                    'iqg_gateway'::regrole,
                    'iqg_bootstrap_invoker'::regrole
                )
        ) THEN
            RAISE EXCEPTION
                'PHASE 0 detectó una membresía prohibida entre roles IQG';
        END IF;
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE EXCEPTION USING
                ERRCODE = '42501',
                MESSAGE = 'DEPLOYMENT_CAPABILITY_INCOMPATIBLE: PRIVILEGED_BOOTSTRAP_PRINCIPAL carece de privilegios PostgreSQL 16 para establecer la topología segura';
    END;
END;
$phase0_privileged_bootstrap$;

COMMIT;
