\set ON_ERROR_STOP on

DO $gateway_probe_identity$
BEGIN
    IF session_user <> 'qa_gateway_probe' THEN
        RAISE EXCEPTION 'BOOT-05 requiere una sesión qa_gateway_probe real';
    END IF;
END;
$gateway_probe_identity$;

SET ROLE iqg_owner;
