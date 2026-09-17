\set ON_ERROR_STOP on

DO $phase0_absence_assertions$
BEGIN
    IF EXISTS (
        SELECT 1
          FROM pg_roles
         WHERE rolname IN ('iqg_owner', 'iqg_app', 'iqg_gateway', 'iqg_bootstrap_invoker')
    ) THEN
        RAISE EXCEPTION 'BOOT: rollback de PHASE 0 dejó roles IQG residuales';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM pg_namespace
         WHERE nspname IN ('iqg_core', 'iqg_fiscal')
    ) THEN
        RAISE EXCEPTION 'BOOT: rollback de PHASE 0 dejó schemas IQG residuales';
    END IF;
END;
$phase0_absence_assertions$;
