\set ON_ERROR_STOP on

DO $phase1_absence_assertions$
BEGIN
    IF EXISTS (
        SELECT 1
          FROM pg_namespace
         WHERE nspname IN ('iqg_core', 'iqg_fiscal')
    ) THEN
        RAISE EXCEPTION 'BOOT: rollback de PHASE 1 dejó schemas IQG residuales';
    END IF;
END;
$phase1_absence_assertions$;
