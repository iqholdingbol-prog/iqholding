\set ON_ERROR_STOP on

SET ROLE iqg_owner;
SELECT qa_harness.set_context_for('A1');
UPDATE iqg_core.precio_vigente
   SET importe_menor = 999
 WHERE precio_vigente_id = 'a1100000-0000-4000-8000-000000000001';
