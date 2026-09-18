\set ON_ERROR_STOP on

-- Todas las aserciones se ejecutan como el superusuario efímero que adopta el
-- rol técnico iqg_owner. Esto prueba las políticas FORCED del owner sin crear
-- una membresía persistente de iqg_owner para ningún rol de aplicación.
SET ROLE iqg_owner;

SELECT qa_harness.assert_true(
    (SELECT count(*) = 4 FROM qa_harness.fixture),
    'G: fixture contiene dos empresas por dos sucursales'
);

SELECT qa_harness.assert_true(
    (SELECT count(*) = 2 FROM iqg_core.empresa),
    'A/G: provisioning produjo exactamente dos empresas base'
);

SELECT qa_harness.assert_true(
    (SELECT count(*) = 4 FROM iqg_core.sucursal),
    'G: fixture produjo exactamente cuatro sucursales'
);

SELECT qa_harness.assert_true(
    NOT EXISTS (
        SELECT 1
          FROM pg_class AS c
          JOIN pg_namespace AS n ON n.oid = c.relnamespace
         WHERE n.nspname IN ('iqg_core', 'iqg_fiscal')
           AND c.relkind IN ('r', 'p')
           AND (NOT c.relrowsecurity OR NOT c.relforcerowsecurity)
    ),
    'F: cada tabla IQG tiene ENABLE y FORCE ROW LEVEL SECURITY'
);

SELECT qa_harness.assert_true(
    NOT EXISTS (
        SELECT 1
          FROM pg_roles
         WHERE rolname IN ('iqg_owner', 'iqg_app', 'iqg_gateway', 'iqg_bootstrap_invoker')
           AND (rolsuper OR rolbypassrls OR rolcanlogin OR rolcreatedb OR rolcreaterole)
    ),
    'C: roles IQG son NOLOGIN, no superusuarios y sin privilegios de cluster'
);

SELECT qa_harness.assert_true(
    NOT EXISTS (
        SELECT 1
          FROM pg_auth_members AS m
         WHERE m.roleid = 'iqg_owner'::regrole
    ),
    'C: iqg_owner no conserva miembros tras la instalación'
);

SELECT qa_harness.assert_true(
    NOT has_schema_privilege('iqg_app', 'iqg_core', 'USAGE')
    AND NOT has_schema_privilege('iqg_app', 'iqg_fiscal', 'USAGE')
    AND NOT has_schema_privilege('iqg_gateway', 'iqg_core', 'USAGE')
    AND NOT has_schema_privilege('iqg_gateway', 'iqg_fiscal', 'USAGE'),
    'C: app y gateway no tienen USAGE de esquemas IQG'
);

SELECT qa_harness.assert_true(
    NOT EXISTS (
        SELECT 1
          FROM pg_class AS c
          JOIN pg_namespace AS n ON n.oid = c.relnamespace
          CROSS JOIN (VALUES ('iqg_app'::name), ('iqg_gateway'::name)) AS r(rol)
         WHERE n.nspname IN ('iqg_core', 'iqg_fiscal')
           AND c.relkind IN ('r', 'p', 'v', 'm')
           AND has_table_privilege(r.rol, c.oid, 'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER')
    ),
    'C: app y gateway no tienen privilegios directos de relaciones'
);

SELECT qa_harness.assert_true(
    NOT EXISTS (
        SELECT 1
          FROM pg_class AS c
          JOIN pg_namespace AS n ON n.oid = c.relnamespace
          CROSS JOIN (VALUES ('iqg_app'::name), ('iqg_gateway'::name)) AS r(rol)
         WHERE n.nspname IN ('iqg_core', 'iqg_fiscal')
           -- No depender del orden de predicados WHERE para restringir un OID
           -- al dominio de has_sequence_privilege.
           AND CASE
                   WHEN c.relkind = 'S' THEN
                       has_sequence_privilege(r.rol, c.oid, 'USAGE,SELECT,UPDATE')
                   ELSE false
               END
    ),
    'C: app y gateway no tienen privilegios directos de secuencias'
);

SELECT qa_harness.assert_true(
    NOT EXISTS (
        SELECT 1
          FROM pg_proc AS p
          JOIN pg_namespace AS n ON n.oid = p.pronamespace
          CROSS JOIN (VALUES ('iqg_app'::name), ('iqg_gateway'::name)) AS r(rol)
         WHERE n.nspname IN ('iqg_core', 'iqg_fiscal')
           AND has_function_privilege(r.rol, p.oid, 'EXECUTE')
    ),
    'C: app y gateway no pueden ejecutar funciones IQG'
);

SELECT qa_harness.assert_true(
    has_schema_privilege('iqg_bootstrap_invoker', 'iqg_core', 'USAGE')
    AND NOT has_schema_privilege('iqg_bootstrap_invoker', 'iqg_fiscal', 'USAGE')
    AND (SELECT count(*)
           FROM pg_proc AS p
           JOIN pg_namespace AS n ON n.oid = p.pronamespace
          WHERE n.nspname = 'iqg_core'
            AND p.proname = 'provisionar_empresa'
            AND has_function_privilege('iqg_bootstrap_invoker', p.oid, 'EXECUTE')) = 1
    AND NOT EXISTS (
        SELECT 1
          FROM pg_proc AS p
          JOIN pg_namespace AS n ON n.oid = p.pronamespace
         WHERE n.nspname IN ('iqg_core', 'iqg_fiscal')
           AND p.proname <> 'provisionar_empresa'
           AND has_function_privilege('iqg_bootstrap_invoker', p.oid, 'EXECUTE')
    ),
    'C/E: bootstrap tiene exclusivamente el endpoint de provisión revisado'
);

SELECT qa_harness.assert_true(
    current_user = 'iqg_owner' AND session_user = 'postgres',
    'D: SECURITY DEFINER puede distinguir rol efectivo de identidad de sesión'
);

SELECT qa_harness.set_context_for('A1');
SELECT qa_harness.assert_true(
    iqg_core.contexto_membresia_activa(),
    'H/J/K: contexto A1 activo se reconoce bajo FORCE RLS'
);

SELECT qa_harness.assert_true(
    (SELECT count(*) = 1 FROM iqg_core.canal WHERE codigo = 'QA_CANAL_A'),
    'H: A1 lee su propio canal'
);

SELECT qa_harness.assert_true(
    (SELECT count(*) = 0 FROM iqg_core.canal WHERE codigo IN ('QA_CANAL_A2', 'QA_CANAL_B2')),
    'H: A1 no lee canales de otra sucursal ni otra empresa'
);

SELECT qa_harness.assert_true(
    (SELECT count(*) = 3 FROM iqg_core.rol)
    AND (SELECT count(*) = 5 FROM iqg_core.permiso)
    AND (SELECT count(*) = 5 FROM iqg_core.rol_permiso)
    AND (SELECT count(*) = 1 FROM iqg_core.usuario_rol),
    'L: los roles y permisos base iniciales son completos'
);

SELECT iqg_core.asegurar_roles_base(
    iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id()
);
SELECT qa_harness.assert_true(
    (SELECT count(*) = 3 FROM iqg_core.rol)
    AND (SELECT count(*) = 5 FROM iqg_core.permiso)
    AND (SELECT count(*) = 5 FROM iqg_core.rol_permiso)
    AND (SELECT count(*) = 1 FROM iqg_core.usuario_rol),
    'L: asegurar_roles_base es idempotente'
);

-- N-02: la unidad histórica se inactiva. Una actualización no semántica del
-- elemento debe pasar porque el código no cambia; cambiarlo a un valor inválido
-- se prueba como negativo independiente.
UPDATE iqg_core.dominio_valor
   SET activo = false
 WHERE company_id = iqg_core.contexto_company_id()
   AND dominio_codigo = 'UNIDAD_MEDIDA'
   AND codigo = 'UNIDAD_QUIETA';
UPDATE iqg_core.elemento
   SET descripcion = 'Actualización QA sin cambio de código de dominio'
 WHERE company_id = iqg_core.contexto_company_id()
   AND elemento_id = 'a1000000-0000-4000-8000-000000000002';
SELECT qa_harness.assert_true(
    (SELECT descripcion = 'Actualización QA sin cambio de código de dominio'
       FROM iqg_core.elemento
      WHERE elemento_id = 'a1000000-0000-4000-8000-000000000002'),
    'M: UPDATE sin cambio de código no revalida dominio histórico inactivo'
);

SELECT qa_harness.assert_true(
    (SELECT fecha_creacion <= clock_timestamp()
       FROM iqg_core.canal
      WHERE codigo = 'QA_CANAL_A'),
    'R: fecha_creacion se sella con tiempo de servidor'
);
SELECT qa_harness.assert_true(
    (SELECT count(*) > 0
       FROM iqg_core.registro_cambios
      WHERE tabla_origen = 'iqg_core.canal'),
    'R: DML operativo genera auditoría'
);

SELECT qa_harness.assert_true(
    (SELECT count(*) = 1
       FROM iqg_core.movimiento_caja AS mc
       JOIN iqg_core.pago AS p
         ON p.company_id = mc.company_id
        AND p.branch_id = mc.branch_id
        AND p.pago_id = mc.pago_id
      WHERE mc.caja_id = 'a1700000-0000-4000-8000-000000000001'
        AND mc.operacion_id = p.operacion_id
        AND mc.moneda_codigo = p.moneda_codigo
        AND mc.signo_impacto = p.signo_impacto
        AND mc.importe_menor = p.importe_menor),
    'Q: movimiento de caja conserva operación, moneda, signo e importe del pago'
);

-- N-05/C3: la unicidad no se impone sobre ciphertext ni referencias de clave,
-- cuyo valor puede cambiar al rotar sobres. Las claves de negocio ya explícitas
-- se prueban mediante provisioning/precios/pagos en la fase de concurrencia.
SELECT qa_harness.assert_true(
    NOT EXISTS (
        SELECT 1
          FROM pg_index AS i
          JOIN pg_class AS c ON c.oid = i.indrelid
          JOIN pg_namespace AS n ON n.oid = c.relnamespace
          JOIN pg_attribute AS a ON a.attrelid = c.oid AND a.attnum = ANY(i.indkey)
         WHERE n.nspname = 'iqg_core'
           AND c.relname IN ('empresa', 'usuario', 'cliente')
           AND i.indisunique
           AND (a.attname LIKE '%_cifrado' OR a.attname LIKE 'referencia_clave_%')
    ),
    'N-05/C3: no hay índice único sobre PII cifrada ni referencia de clave'
);

-- Separación fiscal: A no activa fiscal y B sí. La transición B materializa
-- una factura, su snapshot de línea y un único evento transaccional.
SELECT qa_harness.assert_true(
    (SELECT count(*) = 0
       FROM iqg_fiscal.factura AS f
       JOIN qa_harness.fixture AS q ON q.company_id = f.company_id
      WHERE q.codigo = 'A1'),
    'T: empresa privada no crea filas fiscales'
);

SELECT qa_harness.set_context_for('B1');
SELECT qa_harness.assert_true(
    (SELECT count(*) = 1 FROM iqg_fiscal.factura)
    AND (SELECT count(*) = 1 FROM iqg_fiscal.factura_linea)
    AND (SELECT count(*) = 1 FROM iqg_fiscal.evento_emision_factura),
    'T: transición fiscal crea snapshot, línea y outbox separados'
);
SELECT qa_harness.assert_true(
    (SELECT f.importe_total_menor = COALESCE(sum(fl.importe_total_menor), 0)
       FROM iqg_fiscal.factura AS f
       LEFT JOIN iqg_fiscal.factura_linea AS fl
         ON fl.company_id = f.company_id
        AND fl.branch_id = f.branch_id
        AND fl.factura_id = f.factura_id
      GROUP BY f.factura_id, f.importe_total_menor),
    'T: total fiscal coincide con sus snapshots de líneas'
);

-- N-01/C4: solo el cliente es alcance implementado. Los sobres y referencias
-- se sustituyen, la solicitud persiste y la auditoría se redacta sin borrar
-- hechos. Usuario y empresa permanecen diferidos según ADR-0003.
SELECT qa_harness.set_context_for('A1');
SELECT qa_harness.assert_true(
    (SELECT NOT ya_anonimizado
       FROM iqg_core.anonimizar_cliente(
            'a1300000-0000-4000-8000-000000000001',
            'a1300000-0000-4000-8000-000000000003'
       )),
    'S: anonimización inicial de cliente se ejecuta'
);
SELECT qa_harness.assert_true(
    (SELECT nombre_mostrar_cifrado IS NULL
            AND identificador_externo_cifrado IS NULL
            AND correo_electronico_cifrado IS NULL
            AND telefono_cifrado IS NULL
            AND referencia_clave_operativa_externa IS NULL
            AND consentimiento_comercial_cifrado IS NULL
            AND activo = false
       FROM iqg_core.cliente
      WHERE cliente_id = 'a1300000-0000-4000-8000-000000000001'),
    'S: PII de cliente se reemplaza por valores irreconocibles'
);
SELECT qa_harness.assert_true(
    (SELECT count(*) = 1
       FROM iqg_core.anonimizacion_solicitud
      WHERE cliente_id = 'a1300000-0000-4000-8000-000000000001'),
    'S: solicitud de anonimización es inmutable y única'
);
SELECT qa_harness.assert_true(
    (SELECT count(*) > 0
       FROM iqg_core.registro_cambios
      WHERE tabla_origen = 'iqg_core.cliente'
        AND registro_id = 'a1300000-0000-4000-8000-000000000001'
        AND redaccion_solicitud_id IS NOT NULL
        AND NOT (COALESCE(datos_antes, '{}'::jsonb) ?| ARRAY[
            'nombre_mostrar_cifrado', 'identificador_externo_cifrado',
            'correo_electronico_cifrado', 'telefono_cifrado',
            'referencia_clave_operativa_externa', 'consentimiento_comercial_cifrado'
        ])
        AND NOT (COALESCE(datos_despues, '{}'::jsonb) ?| ARRAY[
            'nombre_mostrar_cifrado', 'identificador_externo_cifrado',
            'correo_electronico_cifrado', 'telefono_cifrado',
            'referencia_clave_operativa_externa', 'consentimiento_comercial_cifrado'
        ])),
    'S: auditoría del cliente queda redactada de PII'
);
SELECT qa_harness.assert_true(
    (SELECT ya_anonimizado
       FROM iqg_core.anonimizar_cliente(
            'a1300000-0000-4000-8000-000000000001',
            'a1300000-0000-4000-8000-000000000003'
       )),
    'S: anonimización de cliente es idempotente'
);

RESET ROLE;
