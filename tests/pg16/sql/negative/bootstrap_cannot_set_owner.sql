\set ON_ERROR_STOP on

DO $bootstrap_probe_identity$
BEGIN
    IF session_user <> 'qa_bootstrap' THEN
        RAISE EXCEPTION 'BOOT-06 requiere una sesión qa_bootstrap real';
    END IF;
END;
$bootstrap_probe_identity$;

SET ROLE iqg_owner;
