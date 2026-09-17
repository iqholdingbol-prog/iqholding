\set ON_ERROR_STOP on

DO $app_probe_identity$
BEGIN
    IF session_user <> 'qa_app_probe' THEN
        RAISE EXCEPTION 'BOOT-04 requiere una sesión qa_app_probe real';
    END IF;
END;
$app_probe_identity$;

SET ROLE iqg_owner;
