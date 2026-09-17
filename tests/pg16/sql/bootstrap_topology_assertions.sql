\set ON_ERROR_STOP on

DO $phase0_topology_assertions$
BEGIN
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
        RAISE EXCEPTION 'BOOT: PHASE 0 no dejó los cuatro roles IQG endurecidos';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM pg_auth_members
         WHERE roleid = 'iqg_owner'::regrole
    ) THEN
        RAISE EXCEPTION 'BOOT: iqg_owner conserva miembros';
    END IF;

    -- Un rol IQG no debe recibir membresía de ningún rol externo. El sentido
    -- inverso sí permite una cuenta de conexión externa con capacidad acotada.
    IF EXISTS (
        SELECT 1
          FROM pg_auth_members
         WHERE member IN (
                'iqg_owner'::regrole,
                'iqg_app'::regrole,
                'iqg_gateway'::regrole,
                'iqg_bootstrap_invoker'::regrole
            )
    ) THEN
        RAISE EXCEPTION 'BOOT: un rol IQG puede heredar o asumir otro rol';
    END IF;

    -- La identidad que ejecutó esta aserción representa el principal
    -- privilegiado del arnés. Debe quedar fuera de toda membership IQG; las
    -- memberships de probes QA se prueban más tarde con sesiones separadas.
    IF EXISTS (
        SELECT 1
          FROM pg_auth_members
         WHERE member = session_user::regrole
           AND roleid IN (
               'iqg_owner'::regrole,
               'iqg_app'::regrole,
               'iqg_gateway'::regrole,
               'iqg_bootstrap_invoker'::regrole
           )
    ) THEN
        RAISE EXCEPTION 'BOOT: el principal privilegiado conserva una membership IQG';
    END IF;
END;
$phase0_topology_assertions$;
