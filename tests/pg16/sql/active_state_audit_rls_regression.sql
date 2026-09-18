\set ON_ERROR_STOP on

-- Prueba el camino BEFORE UPDATE que preserva auditoría durante una revocación
-- inmediata. Cada caso revierte su propia transición y no contamina J/K.
-- El baseline vive fuera de las cuatro transacciones para que la comprobación
-- posterior demuestre rollback real, aun si otro fixture agregara una UPDATE
-- auditada antes de esta regresión.
CREATE TEMP TABLE qa_active_state_audit_baseline (
    tabla text PRIMARY KEY,
    registro_id uuid NOT NULL,
    conteo_update integer NOT NULL
) ON COMMIT PRESERVE ROWS;

WITH objetivos(tabla, registro_id) AS (
    SELECT 'usuario_sucursal', usuario_sucursal_id
      FROM iqg_core.usuario_sucursal
     WHERE company_id = (SELECT company_id FROM qa_harness.fixture WHERE codigo = 'A2')
       AND branch_id = (SELECT branch_id FROM qa_harness.fixture WHERE codigo = 'A2')
       AND usuario_id = (SELECT usuario_id FROM qa_harness.fixture WHERE codigo = 'A2')
    UNION ALL
    SELECT 'sucursal', branch_id
      FROM qa_harness.fixture
     WHERE codigo = 'B2'
    UNION ALL
    SELECT 'usuario', usuario_id
      FROM qa_harness.fixture
     WHERE codigo = 'A1'
    UNION ALL
    SELECT 'empresa', company_id
      FROM qa_harness.fixture
     WHERE codigo = 'B1'
)
INSERT INTO qa_active_state_audit_baseline (tabla, registro_id, conteo_update)
SELECT o.tabla, o.registro_id, count(rc.registro_cambio_id)::integer
  FROM objetivos AS o
  LEFT JOIN iqg_core.registro_cambios AS rc
    ON rc.tabla_origen = 'iqg_core.' || o.tabla
   AND rc.operacion_dml = 'UPDATE'
   AND rc.registro_id = o.registro_id
 GROUP BY o.tabla, o.registro_id;

CREATE OR REPLACE FUNCTION qa_harness.probar_revocacion_auditada(
    p_fixture text,
    p_tabla text,
    p_sql text,
    p_registro_sql text
) RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_registro_id uuid;
    v_registro_actual uuid;
    v_before integer;
    v_before_actual integer;
    v_after integer;
    v_transiciones_antes integer;
    v_transiciones_despues integer;
    v_visibles_despues integer;
BEGIN
    SELECT registro_id, conteo_update
      INTO STRICT v_registro_id, v_before
      FROM pg_temp.qa_active_state_audit_baseline
     WHERE tabla = p_tabla;

    EXECUTE p_registro_sql INTO v_registro_actual;
    IF v_registro_id IS DISTINCT FROM v_registro_actual THEN
        RAISE EXCEPTION 'ACTIVE_STATE_AUDIT_RLS_REGRESSION: AUDIT_TARGET_DRIFT';
    END IF;

    EXECUTE format(
        'SELECT count(*) FROM iqg_core.registro_cambios WHERE tabla_origen = %L AND operacion_dml = %L AND registro_id = (%s)',
        'iqg_core.' || p_tabla, 'UPDATE', p_registro_sql
    ) INTO v_before_actual;

    IF v_before_actual <> v_before THEN
        RAISE EXCEPTION 'ACTIVE_STATE_AUDIT_RLS_REGRESSION: AUDIT_BASELINE_DRIFT';
    END IF;

    EXECUTE format(
        'SELECT count(*) FROM iqg_core.registro_cambios '
        || 'WHERE tabla_origen = %L AND operacion_dml = %L AND registro_id = (%s) '
        || 'AND datos_antes ->> ''activo'' = ''true'' '
        || 'AND datos_despues ->> ''activo'' = ''false''',
        'iqg_core.' || p_tabla, 'UPDATE', p_registro_sql
    ) INTO v_transiciones_antes;

    EXECUTE 'SET LOCAL ROLE iqg_owner';
    PERFORM qa_harness.set_context_for(p_fixture);

    -- PRECONDITION_ACTIVE: la fila debe ser actualizable desde un contexto
    -- legítimo antes de que la mutación lo revoque.
    IF NOT iqg_core.contexto_membresia_activa() THEN
        RAISE EXCEPTION 'ACTIVE_STATE_AUDIT_RLS_REGRESSION: PRECONDITION_ACTIVE';
    END IF;

    EXECUTE p_sql;

    -- DEACTIVATION, CONTEXT_REVOKED_AFTER y POST_DEACTIVATION_ACCESS_DENIED.
    IF iqg_core.contexto_membresia_activa() THEN
        RAISE EXCEPTION 'ACTIVE_STATE_AUDIT_RLS_REGRESSION: CONTEXT_REVOKED_AFTER';
    END IF;
    SELECT count(*)
      INTO v_visibles_despues
      FROM iqg_core.canal;
    IF v_visibles_despues <> 0 THEN
        RAISE EXCEPTION 'ACTIVE_STATE_AUDIT_RLS_REGRESSION: POST_DEACTIVATION_ACCESS_DENIED';
    END IF;
    EXECUTE 'RESET ROLE';

    EXECUTE format(
        'SELECT count(*) FROM iqg_core.registro_cambios WHERE tabla_origen = %L AND operacion_dml = %L AND registro_id = (%s)',
        'iqg_core.' || p_tabla, 'UPDATE', p_registro_sql
    ) INTO v_after;

    EXECUTE format(
        'SELECT count(*) FROM iqg_core.registro_cambios '
        || 'WHERE tabla_origen = %L AND operacion_dml = %L AND registro_id = (%s) '
        || 'AND datos_antes ->> ''activo'' = ''true'' '
        || 'AND datos_despues ->> ''activo'' = ''false''',
        'iqg_core.' || p_tabla, 'UPDATE', p_registro_sql
    ) INTO v_transiciones_despues;

    IF v_after <> v_before + 1 THEN
        RAISE EXCEPTION 'ACTIVE_STATE_AUDIT_RLS_REGRESSION: AUDIT_EXACTLY_ONCE';
    END IF;
    IF v_transiciones_despues <> v_transiciones_antes + 1 THEN
        RAISE EXCEPTION 'ACTIVE_STATE_AUDIT_RLS_REGRESSION: AUDIT_OLD_NEW_TRANSITION';
    END IF;
END;
$$;

BEGIN;
SELECT qa_harness.probar_revocacion_auditada(
    'A2', 'usuario_sucursal',
    'UPDATE iqg_core.usuario_sucursal SET activo = false WHERE company_id = iqg_core.contexto_company_id() AND branch_id = iqg_core.contexto_branch_id() AND usuario_id = iqg_core.contexto_usuario_id()',
    'SELECT usuario_sucursal_id FROM iqg_core.usuario_sucursal WHERE company_id = (SELECT company_id FROM qa_harness.fixture WHERE codigo = ''A2'') AND branch_id = (SELECT branch_id FROM qa_harness.fixture WHERE codigo = ''A2'') AND usuario_id = (SELECT usuario_id FROM qa_harness.fixture WHERE codigo = ''A2'')'
);
ROLLBACK;
SELECT qa_harness.assert_true(
    (SELECT activo FROM iqg_core.usuario_sucursal
      WHERE company_id = (SELECT company_id FROM qa_harness.fixture WHERE codigo = 'A2')
        AND branch_id = (SELECT branch_id FROM qa_harness.fixture WHERE codigo = 'A2')
        AND usuario_id = (SELECT usuario_id FROM qa_harness.fixture WHERE codigo = 'A2'))
    AND (SELECT count(*) FROM iqg_core.registro_cambios
          WHERE tabla_origen = 'iqg_core.usuario_sucursal'
            AND operacion_dml = 'UPDATE'
            AND registro_id = (SELECT usuario_sucursal_id FROM iqg_core.usuario_sucursal
                                WHERE company_id = (SELECT company_id FROM qa_harness.fixture WHERE codigo = 'A2')
                                  AND branch_id = (SELECT branch_id FROM qa_harness.fixture WHERE codigo = 'A2')
                                  AND usuario_id = (SELECT usuario_id FROM qa_harness.fixture WHERE codigo = 'A2')))
        = (SELECT conteo_update FROM qa_active_state_audit_baseline WHERE tabla = 'usuario_sucursal'),
    'ACTIVE_STATE_AUDIT_RLS_USUARIO_SUCURSAL: FAILED_OR_ROLLED_BACK_TRANSITION_NO_COMMITTED_AUDIT'
);

BEGIN;
SELECT qa_harness.probar_revocacion_auditada(
    'B2', 'sucursal',
    'UPDATE iqg_core.sucursal SET activo = false WHERE company_id = iqg_core.contexto_company_id() AND branch_id = iqg_core.contexto_branch_id()',
    'SELECT branch_id FROM qa_harness.fixture WHERE codigo = ''B2'''
);
ROLLBACK;
SELECT qa_harness.assert_true(
    (SELECT activo FROM iqg_core.sucursal
      WHERE company_id = (SELECT company_id FROM qa_harness.fixture WHERE codigo = 'B2')
        AND branch_id = (SELECT branch_id FROM qa_harness.fixture WHERE codigo = 'B2'))
    AND (SELECT count(*) FROM iqg_core.registro_cambios
          WHERE tabla_origen = 'iqg_core.sucursal'
            AND operacion_dml = 'UPDATE'
            AND registro_id = (SELECT branch_id FROM qa_harness.fixture WHERE codigo = 'B2'))
        = (SELECT conteo_update FROM qa_active_state_audit_baseline WHERE tabla = 'sucursal'),
    'ACTIVE_STATE_AUDIT_RLS_SUCURSAL: FAILED_OR_ROLLED_BACK_TRANSITION_NO_COMMITTED_AUDIT'
);

BEGIN;
SELECT qa_harness.probar_revocacion_auditada(
    'A1', 'usuario',
    'UPDATE iqg_core.usuario SET activo = false WHERE company_id = iqg_core.contexto_company_id() AND usuario_id = iqg_core.contexto_usuario_id()',
    'SELECT usuario_id FROM qa_harness.fixture WHERE codigo = ''A1'''
);
ROLLBACK;
SELECT qa_harness.assert_true(
    (SELECT activo FROM iqg_core.usuario
      WHERE company_id = (SELECT company_id FROM qa_harness.fixture WHERE codigo = 'A1')
        AND usuario_id = (SELECT usuario_id FROM qa_harness.fixture WHERE codigo = 'A1'))
    AND (SELECT count(*) FROM iqg_core.registro_cambios
          WHERE tabla_origen = 'iqg_core.usuario'
            AND operacion_dml = 'UPDATE'
            AND registro_id = (SELECT usuario_id FROM qa_harness.fixture WHERE codigo = 'A1'))
        = (SELECT conteo_update FROM qa_active_state_audit_baseline WHERE tabla = 'usuario'),
    'ACTIVE_STATE_AUDIT_RLS_USUARIO: FAILED_OR_ROLLED_BACK_TRANSITION_NO_COMMITTED_AUDIT'
);

BEGIN;
SELECT qa_harness.probar_revocacion_auditada(
    'B1', 'empresa',
    'UPDATE iqg_core.empresa SET activo = false WHERE company_id = iqg_core.contexto_company_id()',
    'SELECT company_id FROM qa_harness.fixture WHERE codigo = ''B1'''
);
ROLLBACK;
SELECT qa_harness.assert_true(
    (SELECT activo FROM iqg_core.empresa
      WHERE company_id = (SELECT company_id FROM qa_harness.fixture WHERE codigo = 'B1'))
    AND (SELECT count(*) FROM iqg_core.registro_cambios
          WHERE tabla_origen = 'iqg_core.empresa'
            AND operacion_dml = 'UPDATE'
            AND registro_id = (SELECT company_id FROM qa_harness.fixture WHERE codigo = 'B1'))
        = (SELECT conteo_update FROM qa_active_state_audit_baseline WHERE tabla = 'empresa'),
    'ACTIVE_STATE_AUDIT_RLS_EMPRESA: FAILED_OR_ROLLED_BACK_TRANSITION_NO_COMMITTED_AUDIT'
);

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM (VALUES ('iqg_app'::name), ('iqg_gateway'::name), ('iqg_bootstrap_invoker'::name)) r(rol)
        WHERE has_table_privilege(r.rol, 'iqg_core.registro_cambios', 'INSERT')
           OR has_function_privilege(
                r.rol,
                'iqg_core.tg_registrar_cambio()'::regprocedure,
                'EXECUTE'
              )
    ) THEN
        RAISE EXCEPTION 'ACTIVE_STATE_AUDIT_RLS_REGRESSION: RUNTIME_DIRECT_AUDIT_CAPABILITY';
    END IF;
END;
$$;

DROP FUNCTION qa_harness.probar_revocacion_auditada(text, text, text, text);
