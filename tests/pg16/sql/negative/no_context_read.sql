\set ON_ERROR_STOP on

-- Una conexión sin GUC de contexto no recibe filas aunque adopte el rol técnico
-- dentro del clúster efímero de pruebas.
SET ROLE iqg_owner;
SELECT qa_harness.assert_true(
    (SELECT count(*) = 0 FROM iqg_core.canal),
    'H: contexto ausente no expone filas operativas'
);
RESET ROLE;
