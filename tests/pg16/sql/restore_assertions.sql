\set ON_ERROR_STOP on

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
