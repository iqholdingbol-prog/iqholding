\set ON_ERROR_STOP on
BEGIN;
SET LOCAL deadlock_timeout = '200ms';
UPDATE qa_harness.lock_probe SET valor = valor + 1 WHERE id = 1;
SELECT pg_sleep(1);
UPDATE qa_harness.lock_probe SET valor = valor + 1 WHERE id = 2;
COMMIT;
