\set ON_ERROR_STOP on

DO $phase1_catalog_assertions$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_namespace
         WHERE nspname = 'iqg_core' AND nspowner = 'iqg_owner'::regrole
    ) OR NOT EXISTS (
        SELECT 1 FROM pg_namespace
         WHERE nspname = 'iqg_fiscal' AND nspowner = 'iqg_owner'::regrole
    ) THEN
        RAISE EXCEPTION 'BOOT: PHASE 1 no conserva ownership de schemas IQG';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM pg_catalog.pg_namespace AS schema_iqg
         CROSS JOIN LATERAL pg_catalog.aclexplode(
             COALESCE(
                 schema_iqg.nspacl,
                 pg_catalog.acldefault('n', schema_iqg.nspowner)
             )
         ) AS acl
         WHERE schema_iqg.nspname IN ('iqg_core', 'iqg_fiscal')
           AND NOT (
               acl.grantee = schema_iqg.nspowner
               AND acl.grantor = schema_iqg.nspowner
               AND acl.privilege_type IN ('USAGE', 'CREATE')
               AND NOT acl.is_grantable
           )
           AND NOT (
               schema_iqg.nspname = 'iqg_core'
               AND acl.grantee = 'iqg_bootstrap_invoker'::regrole
               AND acl.grantor = 'iqg_owner'::regrole
               AND acl.privilege_type = 'USAGE'
               AND NOT acl.is_grantable
           )
    ) THEN
        RAISE EXCEPTION 'BOOT: PHASE 1 conserva una ACL de schema fuera de allowlist';
    END IF;

    IF (SELECT count(*)
          FROM pg_catalog.pg_default_acl AS default_acl
         WHERE default_acl.defaclrole = 'iqg_owner'::regrole
           AND default_acl.defaclnamespace = 0) <> 2
       OR EXISTS (
            SELECT 1
              FROM pg_catalog.pg_default_acl AS default_acl
             WHERE default_acl.defaclrole = 'iqg_owner'::regrole
               AND default_acl.defaclnamespace = 0
               AND NOT (
                   (default_acl.defaclobjtype = 'f'
                    AND default_acl.defaclacl IS NOT DISTINCT FROM ARRAY[
                        pg_catalog.makeaclitem(
                            'iqg_owner'::regrole,
                            'iqg_owner'::regrole,
                            'EXECUTE',
                            false
                        )
                    ]::aclitem[])
                   OR
                   (default_acl.defaclobjtype = 'T'
                    AND default_acl.defaclacl IS NOT DISTINCT FROM ARRAY[
                        pg_catalog.makeaclitem(
                            'iqg_owner'::regrole,
                            'iqg_owner'::regrole,
                            'USAGE',
                            false
                        )
                    ]::aclitem[])
               )
       )
       OR EXISTS (
            SELECT 1
              FROM pg_catalog.pg_default_acl AS default_acl
             WHERE default_acl.defaclnamespace IN (
                 'iqg_core'::regnamespace,
                 'iqg_fiscal'::regnamespace
             )
       ) THEN
        RAISE EXCEPTION 'BOOT: PHASE 1 conserva default ACL IQG fuera de allowlist';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM pg_class AS c
          JOIN pg_namespace AS n ON n.oid = c.relnamespace
         WHERE n.nspname IN ('iqg_core', 'iqg_fiscal')
            AND c.relkind IN ('r', 'p', 'v', 'm', 'S', 'f')
           AND c.relowner <> 'iqg_owner'::regrole
    ) OR EXISTS (
        SELECT 1
          FROM pg_proc AS p
          JOIN pg_namespace AS n ON n.oid = p.pronamespace
         WHERE n.nspname IN ('iqg_core', 'iqg_fiscal')
            AND p.proowner <> 'iqg_owner'::regrole
    ) OR EXISTS (
        SELECT 1
          FROM pg_type AS type_iqg
          JOIN pg_namespace AS schema_iqg ON schema_iqg.oid = type_iqg.typnamespace
         WHERE schema_iqg.nspname IN ('iqg_core', 'iqg_fiscal')
           AND type_iqg.typowner <> 'iqg_owner'::regrole
    ) THEN
        RAISE EXCEPTION 'BOOT: PHASE 1 no conserva ownership técnico IQG';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM pg_class AS c
          JOIN pg_namespace AS n ON n.oid = c.relnamespace
         WHERE n.nspname IN ('iqg_core', 'iqg_fiscal')
           AND c.relkind IN ('r', 'p')
           AND (NOT c.relrowsecurity OR NOT c.relforcerowsecurity)
    ) THEN
        RAISE EXCEPTION 'BOOT: PHASE 1 perdió ENABLE o FORCE ROW LEVEL SECURITY';
    END IF;

    IF has_schema_privilege('iqg_app', 'iqg_core', 'USAGE,CREATE')
       OR has_schema_privilege('iqg_app', 'iqg_fiscal', 'USAGE,CREATE')
       OR has_schema_privilege('iqg_gateway', 'iqg_core', 'USAGE,CREATE')
       OR has_schema_privilege('iqg_gateway', 'iqg_fiscal', 'USAGE,CREATE') THEN
        RAISE EXCEPTION 'BOOT: app o gateway conservan privilegios de schema IQG';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM pg_class AS c
          JOIN pg_namespace AS n ON n.oid = c.relnamespace
          CROSS JOIN (VALUES ('iqg_app'::name), ('iqg_gateway'::name)) AS r(rol)
         WHERE n.nspname IN ('iqg_core', 'iqg_fiscal')
            AND c.relkind IN ('r', 'p', 'v', 'm', 'f')
           AND has_table_privilege(r.rol, c.oid, 'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER')
    ) OR EXISTS (
        SELECT 1
          FROM pg_class AS c
          JOIN pg_namespace AS n ON n.oid = c.relnamespace
          CROSS JOIN (VALUES ('iqg_app'::name), ('iqg_gateway'::name)) AS r(rol)
         WHERE n.nspname IN ('iqg_core', 'iqg_fiscal')
           AND c.relkind = 'S'
           AND has_sequence_privilege(r.rol, c.oid, 'USAGE,SELECT,UPDATE')
    ) OR EXISTS (
        SELECT 1
          FROM pg_proc AS p
          JOIN pg_namespace AS n ON n.oid = p.pronamespace
          CROSS JOIN (VALUES ('iqg_app'::name), ('iqg_gateway'::name)) AS r(rol)
         WHERE n.nspname IN ('iqg_core', 'iqg_fiscal')
           AND has_function_privilege(r.rol, p.oid, 'EXECUTE')
    ) THEN
        RAISE EXCEPTION 'BOOT: app o gateway conservan ACL directa IQG';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM pg_type AS type_iqg
          JOIN pg_namespace AS schema_iqg ON schema_iqg.oid = type_iqg.typnamespace
          CROSS JOIN (VALUES
              ('iqg_app'::name),
              ('iqg_gateway'::name),
              ('iqg_bootstrap_invoker'::name)
          ) AS role_iqg(role_name)
         WHERE schema_iqg.nspname IN ('iqg_core', 'iqg_fiscal')
           AND has_type_privilege(role_iqg.role_name, type_iqg.oid, 'USAGE')
    ) THEN
        RAISE EXCEPTION 'BOOT: un rol IQG de runtime conserva USAGE sobre tipos IQG';
    END IF;

    -- Este selector replica la frontera productiva por catálogo para verificar
    -- row types de tablas IQG y sus arrays automáticos sin depender de nombres.
    IF EXISTS (
        SELECT 1
          FROM pg_catalog.pg_type AS row_type
          JOIN pg_catalog.pg_class AS relation_iqg
            ON relation_iqg.oid = row_type.typrelid
           AND relation_iqg.reltype = row_type.oid
           AND relation_iqg.relnamespace = row_type.typnamespace
          JOIN pg_catalog.pg_namespace AS schema_iqg
            ON schema_iqg.oid = row_type.typnamespace
          LEFT JOIN pg_catalog.pg_type AS array_type
            ON array_type.typelem = row_type.oid
           AND array_type.typcategory = 'A'
         WHERE schema_iqg.nspname IN ('iqg_core', 'iqg_fiscal')
           AND row_type.typtype = 'c'
           AND row_type.typrelid <> 0
           AND row_type.typowner = 'iqg_owner'::regrole
           AND relation_iqg.relowner = 'iqg_owner'::regrole
           AND relation_iqg.relkind IN ('r', 'p')
           AND (
               array_type.oid IS NULL
               OR array_type.typowner <> 'iqg_owner'::regrole
               OR NOT has_type_privilege('iqg_owner', row_type.oid, 'USAGE')
               OR NOT has_type_privilege('iqg_owner', array_type.oid, 'USAGE')
               OR EXISTS (
                   SELECT 1
                     FROM (VALUES
                         ('iqg_app'::name),
                         ('iqg_gateway'::name),
                         ('iqg_bootstrap_invoker'::name)
                     ) AS runtime_role(role_name)
                    WHERE has_type_privilege(runtime_role.role_name, row_type.oid, 'USAGE')
                       OR has_type_privilege(runtime_role.role_name, array_type.oid, 'USAGE')
               )
           )
    ) THEN
        RAISE EXCEPTION 'BOOT: row types IQG o arrays automáticos conservan una postura TYPE USAGE incorrecta';
    END IF;

    IF NOT has_schema_privilege('iqg_bootstrap_invoker', 'iqg_core', 'USAGE')
       OR has_schema_privilege('iqg_bootstrap_invoker', 'iqg_core', 'CREATE')
       OR has_schema_privilege('iqg_bootstrap_invoker', 'iqg_fiscal', 'USAGE')
       OR EXISTS (
            SELECT 1
              FROM pg_class AS c
              JOIN pg_namespace AS n ON n.oid = c.relnamespace
             WHERE n.nspname IN ('iqg_core', 'iqg_fiscal')
                AND c.relkind IN ('r', 'p', 'v', 'm', 'f')
               AND has_table_privilege('iqg_bootstrap_invoker', c.oid, 'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER')
       ) OR EXISTS (
            SELECT 1
              FROM pg_class AS c
              JOIN pg_namespace AS n ON n.oid = c.relnamespace
             WHERE n.nspname IN ('iqg_core', 'iqg_fiscal')
               AND c.relkind = 'S'
               AND has_sequence_privilege('iqg_bootstrap_invoker', c.oid, 'USAGE,SELECT,UPDATE')
       ) OR EXISTS (
            SELECT 1
              FROM pg_proc AS p
              JOIN pg_namespace AS n ON n.oid = p.pronamespace
             WHERE n.nspname IN ('iqg_core', 'iqg_fiscal')
               AND p.proname <> 'provisionar_empresa'
               AND has_function_privilege('iqg_bootstrap_invoker', p.oid, 'EXECUTE')
       ) OR (SELECT count(*)
               FROM pg_proc AS p
               JOIN pg_namespace AS n ON n.oid = p.pronamespace
              WHERE n.nspname = 'iqg_core'
                AND p.proname = 'provisionar_empresa'
                AND has_function_privilege('iqg_bootstrap_invoker', p.oid, 'EXECUTE')) <> 1 THEN
        RAISE EXCEPTION 'BOOT: invocador de provisioning conserva ACL fuera de contrato';
    END IF;
END;
$phase1_catalog_assertions$;
