\set ON_ERROR_STOP on
BEGIN;
SET LOCAL ROLE iqg_owner;
SELECT qa_harness.set_context_for('B1');
SELECT pg_advisory_xact_lock(hashtextextended(iqg_core.contexto_company_id()::text, 918273645));
SELECT pg_sleep(3);
COMMIT;
