\set ON_ERROR_STOP on

-- N-04/C5: cada evidencia de estado debe bloquear inmediatamente el contexto
-- correspondiente. Se prueba al final porque estas transiciones no deben
-- impedir las demás pruebas de negocio ni se ocultan mediante replica.
SET ROLE iqg_owner;

BEGIN;
SELECT qa_harness.set_context_for('A2');
UPDATE iqg_core.usuario_sucursal
   SET activo = false
 WHERE company_id = iqg_core.contexto_company_id()
   AND branch_id = iqg_core.contexto_branch_id()
   AND usuario_id = iqg_core.contexto_usuario_id();
SELECT qa_harness.assert_true(
    NOT iqg_core.contexto_membresia_activa()
    AND (SELECT count(*) = 0 FROM iqg_core.canal),
    'J: membresía de sucursal inactiva bloquea acceso a A2'
);
COMMIT;

BEGIN;
SELECT qa_harness.set_context_for('B2');
UPDATE iqg_core.sucursal
   SET activo = false
 WHERE company_id = iqg_core.contexto_company_id()
   AND branch_id = iqg_core.contexto_branch_id();
SELECT qa_harness.assert_true(
    NOT iqg_core.contexto_membresia_activa()
    AND (SELECT count(*) = 0 FROM iqg_core.canal),
    'K: sucursal inactiva bloquea acceso a B2'
);
COMMIT;

BEGIN;
SELECT qa_harness.set_context_for('A1');
UPDATE iqg_core.usuario
   SET activo = false
 WHERE company_id = iqg_core.contexto_company_id()
   AND usuario_id = iqg_core.contexto_usuario_id();
SELECT qa_harness.assert_true(
    NOT iqg_core.contexto_membresia_activa()
    AND (SELECT count(*) = 0 FROM iqg_core.canal),
    'J: usuario inactivo bloquea acceso a A1'
);
COMMIT;

BEGIN;
SELECT qa_harness.set_context_for('B1');
UPDATE iqg_core.empresa
   SET activo = false
 WHERE company_id = iqg_core.contexto_company_id();
SELECT qa_harness.assert_true(
    NOT iqg_core.contexto_membresia_activa()
    AND (SELECT count(*) = 0 FROM iqg_core.elemento),
    'K: empresa inactiva bloquea acceso a B1'
);
COMMIT;

RESET ROLE;
