\set ON_ERROR_STOP on

-- Captura los dos tenants creados por la ruta real de bootstrap.
INSERT INTO qa_harness.fixture (codigo, company_id, branch_id, usuario_id)
SELECT 'A1', company_id, branch_id, creado_por_usuario_id
  FROM iqg_core.provisionamiento_empresa
 WHERE origen_idempotencia = 'QA_TENANT_A'
   AND clave_idempotencia = '11111111-1111-4111-8111-111111111111';

INSERT INTO qa_harness.fixture (codigo, company_id, branch_id, usuario_id)
SELECT 'B1', company_id, branch_id, creado_por_usuario_id
  FROM iqg_core.provisionamiento_empresa
 WHERE origen_idempotencia = 'QA_TENANT_B'
   AND clave_idempotencia = '22222222-2222-4222-8222-222222222222';

INSERT INTO qa_harness.fixture (codigo, company_id, branch_id, usuario_id)
SELECT 'A2', company_id, 'a2000000-0000-4000-8000-000000000002'::uuid, usuario_id
  FROM qa_harness.fixture WHERE codigo = 'A1';
INSERT INTO qa_harness.fixture (codigo, company_id, branch_id, usuario_id)
SELECT 'B2', company_id, 'b2000000-0000-4000-8000-000000000002'::uuid, usuario_id
  FROM qa_harness.fixture WHERE codigo = 'B1';

-- Fixture controlado para 2x2. Los triggers/RLS permanecen activos para todos
-- los hechos posteriores; este bloque solo evita inventar un endpoint de alta
-- de sucursal que el ticket prohíbe construir.
SET session_replication_role = replica;
INSERT INTO iqg_core.sucursal (
    branch_id, company_id, creado_por_usuario_id, codigo, nombre,
    zona_horaria, moneda_predeterminada
)
SELECT branch_id, company_id, usuario_id, 'QA_A_2', 'QA empresa A / sucursal 2',
       'America/La_Paz', 'BOB'
  FROM qa_harness.fixture WHERE codigo = 'A2';
INSERT INTO iqg_core.usuario_sucursal (
    company_id, branch_id, creado_por_usuario_id, usuario_id
)
SELECT company_id, branch_id, usuario_id, usuario_id
  FROM qa_harness.fixture WHERE codigo = 'A2';
INSERT INTO iqg_core.sucursal (
    branch_id, company_id, creado_por_usuario_id, codigo, nombre,
    zona_horaria, moneda_predeterminada
)
SELECT branch_id, company_id, usuario_id, 'QA_B_2', 'QA empresa B / sucursal 2',
       'America/La_Paz', 'BOB'
  FROM qa_harness.fixture WHERE codigo = 'B2';
INSERT INTO iqg_core.usuario_sucursal (
    company_id, branch_id, creado_por_usuario_id, usuario_id
)
SELECT company_id, branch_id, usuario_id, usuario_id
  FROM qa_harness.fixture WHERE codigo = 'B2';
SET session_replication_role = origin;

SET ROLE iqg_owner;

BEGIN;
SELECT qa_harness.set_context_for('A1');
INSERT INTO iqg_core.dominio_valor (
    company_id, branch_id, creado_por_usuario_id, dominio_codigo, codigo, nombre
) VALUES
    (iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(), 'TIPO_ELEMENTO', 'PRODUCTO', 'Producto QA'),
    (iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(), 'UNIDAD_MEDIDA', 'UNIDAD', 'Unidad QA'),
    (iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(), 'UNIDAD_MEDIDA', 'UNIDAD_QUIETA', 'Unidad sin cambio QA'),
    (iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(), 'TIPO_OPERACION', 'VENTA', 'Venta QA'),
    (iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(), 'MEDIO_PAGO', 'EFECTIVO', 'Efectivo QA'),
    (iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(), 'TIPO_MOVIMIENTO_CAJA', 'COBRO', 'Cobro QA'),
    (iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(), 'TIPO_MOVIMIENTO_INVENTARIO', 'INGRESO', 'Ingreso QA'),
    (iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(), 'UBICACION', 'ALMACEN', 'Almacén QA'),
    (iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(), 'ENTIDAD_ESTADO', 'OPERACION', 'Operación QA'),
    (iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(), 'TIPO_DOCUMENTO_FISCAL', 'FACTURA_QA', 'Factura QA'),
    (iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(), 'TIPO_XML_FISCAL', 'XML_QA', 'XML QA'),
    (iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(), 'MOTIVO_CAMBIO', 'QA_PRUEBA', 'Prueba QA')
ON CONFLICT (company_id, dominio_codigo, codigo) DO NOTHING;

INSERT INTO iqg_core.canal (
    canal_id, company_id, branch_id, creado_por_usuario_id, codigo, nombre
) VALUES (
    'a1200000-0000-4000-8000-000000000001',
    iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(),
    'QA_CANAL_A', 'Canal QA A'
);

INSERT INTO iqg_core.cliente (
    cliente_id, company_id, branch_id, creado_por_usuario_id, canal_id,
    identificador_externo_cifrado, nombre_mostrar_cifrado,
    correo_electronico_cifrado, telefono_cifrado,
    referencia_clave_operativa_externa, consentimiento_comercial_cifrado
) VALUES (
    'a1300000-0000-4000-8000-000000000001',
    iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(),
    'a1200000-0000-4000-8000-000000000001',
    decode('01' || repeat('00', 29), 'hex'), decode('01' || repeat('00', 29), 'hex'),
    decode('01' || repeat('00', 29), 'hex'), decode('01' || repeat('00', 29), 'hex'),
    'a1300000-0000-4000-8000-000000000002', decode('01' || repeat('00', 29), 'hex')
);

INSERT INTO iqg_core.elemento (
    elemento_id, company_id, branch_id, creado_por_usuario_id, codigo, nombre,
    tipo_codigo, unidad_medida_codigo, es_vendible, es_inventariable
) VALUES
    ('a1000000-0000-4000-8000-000000000001', iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(), 'QA_ITEM_A', 'Elemento QA A', 'PRODUCTO', 'UNIDAD', true, true),
    ('a1000000-0000-4000-8000-000000000002', iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(), 'QA_ITEM_A_QUIETO', 'Elemento QA A quieto', 'PRODUCTO', 'UNIDAD_QUIETA', true, false);

INSERT INTO iqg_core.precio_vigente (
    precio_vigente_id, company_id, branch_id, creado_por_usuario_id, elemento_id,
    moneda_codigo, importe_menor, valid_from, origen_idempotencia, clave_idempotencia,
    motivo_codigo
) VALUES (
    'a1100000-0000-4000-8000-000000000001',
    iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(),
    'a1000000-0000-4000-8000-000000000001', 'BOB', 100,
    '2026-01-01 00:00:00+00', 'QA_PRECIO_RAIZ', 'a1100000-0000-4000-8000-000000000002', 'QA_PRUEBA'
);

INSERT INTO iqg_core.operacion (
    operacion_id, company_id, branch_id, creado_por_usuario_id, cliente_id,
    tipo_operacion_codigo, moneda_codigo, origen_idempotencia, clave_idempotencia
) VALUES (
    'a1400000-0000-4000-8000-000000000001',
    iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(),
    'a1300000-0000-4000-8000-000000000001', 'VENTA', 'BOB',
    'QA_OPERACION_A', 'a1400000-0000-4000-8000-000000000002'
);

INSERT INTO iqg_core.operacion_linea (
    operacion_linea_id, company_id, branch_id, creado_por_usuario_id, operacion_id,
    elemento_id, numero_linea, nombre_elemento_snapshot, unidad_medida_codigo,
    cantidad, moneda_codigo, precio_unitario_menor, importe_bruto_menor,
    descuento_menor, impuesto_menor, importe_total_menor
) VALUES (
    'a1500000-0000-4000-8000-000000000001',
    iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(),
    'a1400000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001',
    1, 'Elemento QA A', 'UNIDAD', 1, 'BOB', 100, 100, 0, 0, 100
);

INSERT INTO iqg_core.pago (
    pago_id, company_id, branch_id, creado_por_usuario_id, operacion_id,
    medio_pago_codigo, signo_impacto, moneda_codigo, importe_menor,
    origen_idempotencia, clave_idempotencia
) VALUES (
    'a1600000-0000-4000-8000-000000000001',
    iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(),
    'a1400000-0000-4000-8000-000000000001', 'EFECTIVO', 1, 'BOB', 100,
    'QA_PAGO_ORIGINAL', 'a1600000-0000-4000-8000-000000000002'
);

INSERT INTO iqg_core.caja (
    caja_id, company_id, branch_id, creado_por_usuario_id, codigo, nombre, moneda_codigo
) VALUES (
    'a1700000-0000-4000-8000-000000000001',
    iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(),
    'QA_CAJA_A', 'Caja QA A', 'BOB'
);

INSERT INTO iqg_core.movimiento_caja (
    movimiento_caja_id, company_id, branch_id, creado_por_usuario_id, caja_id,
    operacion_id, pago_id, tipo_movimiento_codigo, signo_impacto, moneda_codigo,
    importe_menor, origen_idempotencia, clave_idempotencia
) VALUES (
    'a1800000-0000-4000-8000-000000000001',
    iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(),
    'a1700000-0000-4000-8000-000000000001', 'a1400000-0000-4000-8000-000000000001',
    'a1600000-0000-4000-8000-000000000001', 'COBRO', 1, 'BOB', 100,
    'QA_MOV_CAJA', 'a1800000-0000-4000-8000-000000000002'
);

INSERT INTO iqg_core.grupo_movimiento (
    grupo_movimiento_id, company_id, branch_id, creado_por_usuario_id,
    tipo_movimiento_codigo, origen_idempotencia, clave_idempotencia
) VALUES (
    'a1900000-0000-4000-8000-000000000001',
    iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(),
    'INGRESO', 'QA_GRUPO_MOV', 'a1900000-0000-4000-8000-000000000002'
);

INSERT INTO iqg_core.movimiento (
    movimiento_id, company_id, branch_id, creado_por_usuario_id, grupo_movimiento_id,
    numero_linea_grupo, elemento_id, ubicacion_codigo, signo_cantidad, cantidad,
    unidad_medida_codigo, moneda_codigo, costo_unitario_menor, costo_total_menor,
    origen_idempotencia, clave_idempotencia
) VALUES (
    'a1a00000-0000-4000-8000-000000000001',
    iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(),
    'a1900000-0000-4000-8000-000000000001', 1, 'a1000000-0000-4000-8000-000000000001',
    'ALMACEN', 1, 1, 'UNIDAD', 'BOB', 60, 60,
    'QA_MOVIMIENTO', 'a1a00000-0000-4000-8000-000000000002'
);
COMMIT;

BEGIN;
SELECT qa_harness.set_context_for('B1');
INSERT INTO iqg_core.dominio_valor (
    company_id, branch_id, creado_por_usuario_id, dominio_codigo, codigo, nombre
) VALUES
    (iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(), 'TIPO_ELEMENTO', 'PRODUCTO', 'Producto QA'),
    (iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(), 'UNIDAD_MEDIDA', 'UNIDAD', 'Unidad QA'),
    (iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(), 'TIPO_OPERACION', 'VENTA', 'Venta QA'),
    (iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(), 'ENTIDAD_ESTADO', 'OPERACION', 'Operación QA'),
    (iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(), 'TIPO_DOCUMENTO_FISCAL', 'FACTURA_QA', 'Factura QA'),
    (iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(), 'TIPO_XML_FISCAL', 'XML_QA', 'XML QA')
ON CONFLICT (company_id, dominio_codigo, codigo) DO NOTHING;

INSERT INTO iqg_core.elemento (
    elemento_id, company_id, branch_id, creado_por_usuario_id, codigo, nombre,
    tipo_codigo, unidad_medida_codigo, es_vendible, es_inventariable
) VALUES (
    'b1000000-0000-4000-8000-000000000001',
    iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(),
    'QA_ITEM_B', 'Elemento QA B', 'PRODUCTO', 'UNIDAD', true, false
);

INSERT INTO iqg_core.estado (
    estado_id, company_id, branch_id, creado_por_usuario_id, entidad_codigo, codigo,
    nombre, es_terminal, dispara_emision_fiscal, tipo_documento_fiscal_codigo
) VALUES (
    'b1300000-0000-4000-8000-000000000001',
    iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(),
    'OPERACION', 'CERRADA_FISCAL', 'Cerrada fiscal QA', true, true, 'FACTURA_QA'
);

INSERT INTO iqg_core.operacion (
    operacion_id, company_id, branch_id, creado_por_usuario_id,
    tipo_operacion_codigo, moneda_codigo, origen_idempotencia, clave_idempotencia
) VALUES (
    'b1400000-0000-4000-8000-000000000001',
    iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(),
    'VENTA', 'BOB', 'QA_OPERACION_B', 'b1400000-0000-4000-8000-000000000002'
);

INSERT INTO iqg_core.operacion_linea (
    operacion_linea_id, company_id, branch_id, creado_por_usuario_id, operacion_id,
    elemento_id, numero_linea, nombre_elemento_snapshot, unidad_medida_codigo,
    cantidad, moneda_codigo, precio_unitario_menor, importe_bruto_menor,
    descuento_menor, impuesto_menor, importe_total_menor
) VALUES (
    'b1500000-0000-4000-8000-000000000001',
    iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(),
    'b1400000-0000-4000-8000-000000000001', 'b1000000-0000-4000-8000-000000000001',
    1, 'Elemento QA B', 'UNIDAD', 1, 'BOB', 125, 125, 0, 0, 125
);

-- Esta transición debe crear exactamente una factura, una línea snapshot y un
-- evento outbox; los constraint triggers diferidos se evalúan al COMMIT.
INSERT INTO iqg_core.operacion_estado (
    operacion_estado_id, company_id, branch_id, creado_por_usuario_id,
    operacion_id, estado_id, origen_idempotencia, clave_idempotencia
) VALUES (
    'b1600000-0000-4000-8000-000000000001',
    iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(), iqg_core.contexto_usuario_id(),
    'b1400000-0000-4000-8000-000000000001', 'b1300000-0000-4000-8000-000000000001',
    'QA_ESTADO_FISCAL', 'b1600000-0000-4000-8000-000000000002'
);
COMMIT;

-- A2/B2 fueron creadas como fixture bajo replica para evitar inventar una ruta
-- de alta de sucursal. Estos hechos sí pasan por RLS, sellos, auditoría y
-- validadores normales, y demuestran que ambas unidades quedan operables.
BEGIN;
SELECT qa_harness.set_context_for('A2');
INSERT INTO iqg_core.canal (
    company_id, branch_id, creado_por_usuario_id, codigo, nombre
) VALUES (
    iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(),
    iqg_core.contexto_usuario_id(), 'QA_CANAL_A2', 'Canal QA A2'
);
COMMIT;

BEGIN;
SELECT qa_harness.set_context_for('B2');
INSERT INTO iqg_core.canal (
    company_id, branch_id, creado_por_usuario_id, codigo, nombre
) VALUES (
    iqg_core.contexto_company_id(), iqg_core.contexto_branch_id(),
    iqg_core.contexto_usuario_id(), 'QA_CANAL_B2', 'Canal QA B2'
);
COMMIT;

RESET ROLE;
