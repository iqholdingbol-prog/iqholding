\set ON_ERROR_STOP on

SET ROLE iqg_owner;
SELECT qa_harness.set_context_for('A1');
UPDATE iqg_core.registro_cambios
   SET motivo_codigo = 'QA_NO_PERMITIDO'
 WHERE registro_cambio_id = (
    SELECT registro_cambio_id
      FROM iqg_core.registro_cambios
     ORDER BY fecha_creacion
     LIMIT 1
 );
