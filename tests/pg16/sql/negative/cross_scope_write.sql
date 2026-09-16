\set ON_ERROR_STOP on
SET ROLE iqg_owner;
SELECT qa_harness.set_context_for('A1');
INSERT INTO iqg_core.canal (company_id, branch_id, creado_por_usuario_id, codigo, nombre)
SELECT company_id, branch_id, usuario_id, 'QA_CRUCE_PROHIBIDO', 'Cruce prohibido QA'
  FROM qa_harness.fixture
 WHERE codigo = 'B1';
