\set ON_ERROR_STOP on

-- Los grants directos QA sobre IQG sirven solo a probes ya completados. Se
-- retiran antes del dump para que el restore pruebe ACL productivas reales.
REVOKE USAGE ON SCHEMA iqg_core FROM qa_untrusted;
REVOKE EXECUTE ON FUNCTION iqg_core.contexto_bootstrap_activo()
    FROM qa_bootstrap, qa_untrusted;

DO $pre_dump_qa_acl_cleanup$
DECLARE
    v_qa_roles oid[] := ARRAY[
        'qa_bootstrap'::regrole,
        'qa_untrusted'::regrole,
        'qa_app_probe'::regrole,
        'qa_gateway_probe'::regrole
    ];
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_catalog.pg_namespace AS n
        CROSS JOIN LATERAL pg_catalog.aclexplode(COALESCE(n.nspacl, pg_catalog.acldefault('n', n.nspowner))) AS acl
        WHERE n.nspname IN ('iqg_core', 'iqg_fiscal') AND acl.grantee = ANY (v_qa_roles)
    ) OR EXISTS (
        SELECT 1 FROM pg_catalog.pg_class AS c
        CROSS JOIN LATERAL pg_catalog.aclexplode(COALESCE(c.relacl, pg_catalog.acldefault('r', c.relowner))) AS acl
        WHERE c.relnamespace IN ('iqg_core'::regnamespace, 'iqg_fiscal'::regnamespace)
          AND c.relkind <> 'S' AND acl.grantee = ANY (v_qa_roles)
    ) OR EXISTS (
        SELECT 1 FROM pg_catalog.pg_class AS c
        CROSS JOIN LATERAL pg_catalog.aclexplode(COALESCE(c.relacl, pg_catalog.acldefault('S', c.relowner))) AS acl
        WHERE c.relnamespace IN ('iqg_core'::regnamespace, 'iqg_fiscal'::regnamespace)
          AND c.relkind = 'S' AND acl.grantee = ANY (v_qa_roles)
    ) OR EXISTS (
        SELECT 1 FROM pg_catalog.pg_proc AS p
        CROSS JOIN LATERAL pg_catalog.aclexplode(COALESCE(p.proacl, pg_catalog.acldefault('f', p.proowner))) AS acl
        WHERE p.pronamespace IN ('iqg_core'::regnamespace, 'iqg_fiscal'::regnamespace)
          AND acl.grantee = ANY (v_qa_roles)
    ) OR EXISTS (
        SELECT 1 FROM pg_catalog.pg_type AS t
        CROSS JOIN LATERAL pg_catalog.aclexplode(COALESCE(t.typacl, pg_catalog.acldefault('T', t.typowner))) AS acl
        WHERE t.typnamespace IN ('iqg_core'::regnamespace, 'iqg_fiscal'::regnamespace)
          AND acl.grantee = ANY (v_qa_roles)
    ) THEN
        RAISE EXCEPTION 'PRE_DUMP_QA_ACL_CLEANUP: persiste una ACL directa QA sobre IQG';
    END IF;

    IF EXISTS (
        SELECT 1 FROM pg_catalog.pg_namespace AS n
        CROSS JOIN LATERAL pg_catalog.aclexplode(COALESCE(n.nspacl, pg_catalog.acldefault('n', n.nspowner))) AS acl
        WHERE n.nspname IN ('iqg_core', 'iqg_fiscal')
          AND NOT (acl.grantee = n.nspowner AND acl.privilege_type IN ('USAGE', 'CREATE') AND NOT acl.is_grantable)
          AND NOT (n.nspname = 'iqg_core' AND acl.grantee = 'iqg_bootstrap_invoker'::regrole AND acl.privilege_type = 'USAGE' AND NOT acl.is_grantable)
    ) THEN
        RAISE EXCEPTION 'PRE_DUMP_QA_ACL_CLEANUP: ACL productiva de schema fuera de contrato';
    END IF;
END;
$pre_dump_qa_acl_cleanup$;
