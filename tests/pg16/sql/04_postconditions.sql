\set ON_ERROR_STOP on

-- Propiedad física global: la reserva de una carrera de provisioning pertenece
-- a su tenant ganador, no al fixture A1. Se verifica como superusuario QA.
SELECT qa_harness.assert_true(
    (SELECT count(*) = 1
       FROM iqg_core.provisionamiento_empresa
      WHERE origen_idempotencia = 'QA_CONCURRENTE'
        AND clave_idempotencia = '33333333-3333-4333-8333-333333333333'),
    'O/P: provisioning concurrente conserva una única reserva idempotente'
);

-- Estado global del fixture QA; iqg_owner no recibe SELECT sobre esta tabla.
SELECT qa_harness.assert_true(
    (SELECT bool_and(valor = 1) FROM qa_harness.lock_probe),
    'V: deadlock controlado revierte una transacción y conserva la otra'
);

SET ROLE iqg_owner;
SELECT qa_harness.set_context_for('A1');

SELECT qa_harness.assert_true(
    (SELECT count(*) = 1
       FROM iqg_core.precio_vigente
      WHERE reemplaza_precio_vigente_id = 'a1100000-0000-4000-8000-000000000001'),
    'O: carrera de sucesores deja una única continuación de precio'
);

SELECT qa_harness.assert_true(
    (SELECT COALESCE(sum(importe_menor), 0) = 60
       FROM iqg_core.pago
      WHERE pago_referencia_id = 'a1600000-0000-4000-8000-000000000001'
        AND signo_impacto = -1),
    'P: reversos concurrentes no exceden el pago original'
);

SELECT qa_harness.assert_true(
    (SELECT count(*) = 1
       FROM iqg_core.pago
      WHERE pago_referencia_id = 'a1600000-0000-4000-8000-000000000001'
        AND signo_impacto = -1),
    'P: carrera de reverso conserva un único evento válido'
);

SELECT qa_harness.assert_true(
    (SELECT count(*) = 1 FROM iqg_fiscal.factura)
    AND (SELECT count(*) = 1 FROM iqg_fiscal.factura_linea)
    AND (SELECT count(*) = 1 FROM iqg_fiscal.evento_emision_factura),
    'T: concurrencia ajena no alteró snapshots fiscales'
);

RESET ROLE;
