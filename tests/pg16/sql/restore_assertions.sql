\set ON_ERROR_STOP on

-- pg_dump/pg_restore no lleva roles globales. Esta sonda confirma que el
-- restore no alteró la topology ya presente del clúster efímero y que la base
-- restaurada conserva ownership y FORCE RLS.
SELECT qa_harness.assert_true(
    NOT EXISTS (
        SELECT 1
          FROM pg_auth_members
         WHERE roleid = 'iqg_owner'::regrole
    )
    AND NOT EXISTS (
        SELECT 1
          FROM pg_auth_members
         WHERE member IN (
                'iqg_owner'::regrole,
                'iqg_app'::regrole,
                'iqg_gateway'::regrole,
                'iqg_bootstrap_invoker'::regrole
            )
    ),
    'W/BOOT-10: restore no amplía membresías IQG'
);

-- Las tres memberships QA son la única excepción permitida para roles de
-- runtime. pg_dump/pg_restore no recrea roles globales; esta equality exacta
-- detecta tanto una membresía adicional como una opción ADMIN/INHERIT/SET que
-- se haya ampliado en el clúster durante el restore.
SELECT qa_harness.assert_true(
    NOT EXISTS (
        (
            SELECT roleid, member, admin_option, inherit_option, set_option
              FROM pg_auth_members
             WHERE roleid IN (
                 'iqg_app'::regrole,
                 'iqg_gateway'::regrole,
                 'iqg_bootstrap_invoker'::regrole
             )
            EXCEPT ALL
            SELECT *
              FROM (VALUES
                  (
                      ('iqg_app'::regrole)::oid,
                      ('qa_app_probe'::regrole)::oid,
                      false,
                      true,
                      true
                  ),
                  (
                      ('iqg_gateway'::regrole)::oid,
                      ('qa_gateway_probe'::regrole)::oid,
                      false,
                      true,
                      true
                  ),
                  (
                      ('iqg_bootstrap_invoker'::regrole)::oid,
                      ('qa_bootstrap'::regrole)::oid,
                      false,
                      true,
                      false
                  )
              ) AS expected_membership(
                  roleid,
                  member,
                  admin_option,
                  inherit_option,
                  set_option
              )
        )
        UNION ALL
        (
            SELECT *
              FROM (VALUES
                  (
                      ('iqg_app'::regrole)::oid,
                      ('qa_app_probe'::regrole)::oid,
                      false,
                      true,
                      true
                  ),
                  (
                      ('iqg_gateway'::regrole)::oid,
                      ('qa_gateway_probe'::regrole)::oid,
                      false,
                      true,
                      true
                  ),
                  (
                      ('iqg_bootstrap_invoker'::regrole)::oid,
                      ('qa_bootstrap'::regrole)::oid,
                      false,
                      true,
                      false
                  )
              ) AS expected_membership(
                  roleid,
                  member,
                  admin_option,
                  inherit_option,
                  set_option
            EXCEPT ALL
            SELECT roleid, member, admin_option, inherit_option, set_option
              FROM pg_auth_members
             WHERE roleid IN (
                 'iqg_app'::regrole,
                 'iqg_gateway'::regrole,
                 'iqg_bootstrap_invoker'::regrole
             )
        )
    ),
    'W/BOOT-10: restore conserva exactamente las memberships QA permitidas'
);

SELECT qa_harness.assert_true(
    EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'iqg_core' AND nspowner = 'iqg_owner'::regrole)
    AND EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'iqg_fiscal' AND nspowner = 'iqg_owner'::regrole)
    AND NOT EXISTS (
        SELECT 1
          FROM pg_class AS c
          JOIN pg_namespace AS n ON n.oid = c.relnamespace
         WHERE n.nspname IN ('iqg_core', 'iqg_fiscal')
            AND c.relkind IN ('r', 'p', 'v', 'm', 'S', 'f')
           AND c.relowner <> 'iqg_owner'::regrole
    )
    AND NOT EXISTS (
        SELECT 1
          FROM pg_class AS c
          JOIN pg_namespace AS n ON n.oid = c.relnamespace
         WHERE n.nspname IN ('iqg_core', 'iqg_fiscal')
           AND c.relkind IN ('r', 'p')
           AND (NOT c.relrowsecurity OR NOT c.relforcerowsecurity)
    )
    AND NOT EXISTS (
        SELECT 1
          FROM pg_type AS type_iqg
          JOIN pg_namespace AS schema_iqg ON schema_iqg.oid = type_iqg.typnamespace
         WHERE schema_iqg.nspname IN ('iqg_core', 'iqg_fiscal')
           AND type_iqg.typowner <> 'iqg_owner'::regrole
    ),
    'W/BOOT-10: restore conserva ownership y FORCE RLS de todo IQG'
);

SELECT qa_harness.assert_true(
    NOT has_schema_privilege('iqg_app', 'iqg_core', 'USAGE,CREATE')
    AND NOT has_schema_privilege('iqg_app', 'iqg_fiscal', 'USAGE,CREATE')
    AND NOT has_schema_privilege('iqg_gateway', 'iqg_core', 'USAGE,CREATE')
    AND NOT has_schema_privilege('iqg_gateway', 'iqg_fiscal', 'USAGE,CREATE'),
    'W/BOOT-10: restore no amplía ACL de schema para app ni gateway'
);

SELECT qa_harness.assert_true(
    NOT EXISTS (
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
    )
    AND (SELECT count(*)
           FROM pg_catalog.pg_default_acl AS default_acl
          WHERE default_acl.defaclrole = 'iqg_owner'::regrole
            AND default_acl.defaclnamespace = 0) = 2
    AND NOT EXISTS (
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
    AND NOT EXISTS (
        SELECT 1
          FROM pg_catalog.pg_default_acl AS default_acl
         WHERE default_acl.defaclnamespace IN (
             'iqg_core'::regnamespace,
             'iqg_fiscal'::regnamespace
         )
    ),
    'W/BOOT-10: restore conserva allowlist de schema y default ACL IQG'
);

SELECT qa_harness.assert_true(
    NOT EXISTS (
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
    ),
    'W/BOOT-10: restore no amplía USAGE de tipos IQG'
);

SET ROLE iqg_owner;

SELECT qa_harness.assert_true(
    EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'iqg_core')
    AND EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'iqg_fiscal'),
    'W: restore conserva ambos esquemas IQG'
);

SELECT qa_harness.assert_true(
    (SELECT relrowsecurity AND relforcerowsecurity
       FROM pg_class
      WHERE oid = 'iqg_core.operacion'::regclass),
    'W: restore conserva FORCE RLS'
);

SELECT qa_harness.set_context_for('A1');
SELECT qa_harness.assert_true(
    (SELECT count(*) = 1 FROM iqg_core.canal WHERE codigo = 'QA_CANAL_A'),
    'W: restore conserva datos aislados de A1'
);

RESET ROLE;
