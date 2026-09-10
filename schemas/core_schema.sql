-- =============================================================================
-- IQ GROWTH — Núcleo Universal: esquema relacional de referencia
-- Ticket: IQG-001.1
-- Estado: diseño ejecutable para revisión; no ejecutar contra datos productivos.
-- =============================================================================
--
-- Este archivo usa el dialecto PostgreSQL 16 únicamente para poder expresar en
-- DDL garantías que SQL portable no ofrece por sí solo: RLS, timestamps del
-- servidor, triggers de inmutabilidad y auditoría JSONB. NO es un ADR ni una
-- decisión sobre el motor productivo. Antes de aplicarlo se debe aprobar el
-- motor y convertirlo en una migración controlada para ese entorno.
--
-- Invariantes que este esquema expresa:
--   1. Toda tabla tiene company_id, branch_id, creado_por_usuario_id y
--      fecha_creacion.
--   2. company_id, branch_id, el identificador y fecha_creacion no cambian.
--   3. El servidor fija fecha_creacion; valores enviados por clientes se ignoran.
--   4. Las relaciones tenant-aware usan FKs compuestas con company_id y
--      branch_id; no se relacionan datos solo por un UUID aislado.
--   5. Operaciones, líneas, pagos, movimientos, estados, precios y auditoría
--      son append-only. Una corrección es un nuevo evento relacionado.
--   6. registro_cambios registra DML exitoso y no puede actualizarse ni borrarse.
--   7. RLS falla cerrada cuando no existe un contexto empresa/sucursal válido.
--
-- Bootstrap: empresa y sucursal forman un ciclo deliberado para que también
-- tengan company_id + branch_id. El alta inicial debe ejecutarse en una única
-- transacción privilegiada con las FKs diferibles, nunca desde un cliente.
-- =============================================================================

BEGIN;

CREATE SCHEMA IF NOT EXISTS iqg_core;
REVOKE CREATE ON SCHEMA iqg_core FROM PUBLIC;

-- -----------------------------------------------------------------------------
-- Contexto de solicitud. IQG-001.2 debe fijar estos valores exclusivamente
-- desde middleware de confianza después de autenticar y autorizar al actor.
-- Con contexto ausente, las políticas RLS no exponen ni permiten filas.
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION iqg_core.contexto_company_id()
RETURNS uuid
LANGUAGE sql
STABLE
AS $$
    SELECT NULLIF(current_setting('iqg.company_id', true), '')::uuid;
$$;

CREATE OR REPLACE FUNCTION iqg_core.contexto_branch_id()
RETURNS uuid
LANGUAGE sql
STABLE
AS $$
    SELECT NULLIF(current_setting('iqg.branch_id', true), '')::uuid;
$$;

CREATE OR REPLACE FUNCTION iqg_core.contexto_usuario_id()
RETURNS uuid
LANGUAGE sql
STABLE
AS $$
    SELECT NULLIF(current_setting('iqg.usuario_id', true), '')::uuid;
$$;

CREATE OR REPLACE FUNCTION iqg_core.contexto_actor_tipo()
RETURNS varchar
LANGUAGE sql
STABLE
AS $$
    SELECT COALESCE(NULLIF(upper(current_setting('iqg.actor_tipo', true)), ''), 'SISTEMA');
$$;

CREATE OR REPLACE FUNCTION iqg_core.contexto_motivo()
RETURNS text
LANGUAGE sql
STABLE
AS $$
    SELECT NULLIF(current_setting('iqg.motivo_cambio', true), '');
$$;

CREATE OR REPLACE FUNCTION iqg_core.contexto_correlation_id()
RETURNS uuid
LANGUAGE sql
STABLE
AS $$
    SELECT NULLIF(current_setting('iqg.correlation_id', true), '')::uuid;
$$;

CREATE OR REPLACE FUNCTION iqg_core.contexto_direccion_ip()
RETURNS inet
LANGUAGE sql
STABLE
AS $$
    SELECT NULLIF(current_setting('iqg.direccion_ip', true), '')::inet;
$$;

-- -----------------------------------------------------------------------------
-- Identidad, empresa y sucursal
-- -----------------------------------------------------------------------------

CREATE TABLE iqg_core.empresa (
    company_id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_id                   uuid NOT NULL DEFAULT gen_random_uuid(),
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    nombre_legal                text NOT NULL,
    nombre_mostrar              text NULL,
    identificador_fiscal        text NULL,
    moneda_predeterminada       varchar(3) NOT NULL,
    activo                      boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_empresa_company_branch UNIQUE (company_id, branch_id),
    CONSTRAINT ck_empresa_moneda CHECK (moneda_predeterminada ~ '^[A-Z]{3}$')
);

CREATE TABLE iqg_core.sucursal (
    branch_id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                  uuid NOT NULL,
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    codigo                      varchar(64) NOT NULL,
    nombre                      text NOT NULL,
    zona_horaria                text NOT NULL,
    moneda_predeterminada       varchar(3) NOT NULL,
    activo                      boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_sucursal_scope UNIQUE (company_id, branch_id),
    CONSTRAINT uq_sucursal_codigo UNIQUE (company_id, codigo),
    CONSTRAINT ck_sucursal_moneda CHECK (moneda_predeterminada ~ '^[A-Z]{3}$'),
    CONSTRAINT fk_sucursal_empresa
        FOREIGN KEY (company_id)
        REFERENCES iqg_core.empresa (company_id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        DEFERRABLE INITIALLY DEFERRED
);

ALTER TABLE iqg_core.empresa
    ADD CONSTRAINT fk_empresa_sucursal_contexto
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        DEFERRABLE INITIALLY DEFERRED;

-- usuario no almacena credenciales: la identidad autenticada vive fuera del
-- núcleo. identificador_identidad enlaza con el proveedor de identidad elegido.
CREATE TABLE iqg_core.usuario (
    usuario_id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                  uuid NOT NULL,
    branch_id                   uuid NOT NULL,
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    identificador_identidad     text NOT NULL,
    nombre_mostrar              text NOT NULL,
    correo_electronico          text NULL,
    activo                      boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_usuario_scope UNIQUE (company_id, branch_id, usuario_id),
    CONSTRAINT uq_usuario_company_id UNIQUE (company_id, usuario_id),
    CONSTRAINT uq_usuario_identidad UNIQUE (company_id, identificador_identidad),
    CONSTRAINT fk_usuario_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

-- La membresía separa una identidad de sus accesos explícitos a sucursales.
CREATE TABLE iqg_core.usuario_sucursal (
    usuario_sucursal_id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                  uuid NOT NULL,
    branch_id                   uuid NOT NULL,
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    usuario_id                  uuid NOT NULL,
    activo                      boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_usuario_sucursal_scope UNIQUE (company_id, branch_id, usuario_sucursal_id),
    CONSTRAINT uq_usuario_sucursal_usuario UNIQUE (company_id, branch_id, usuario_id),
    CONSTRAINT fk_usuario_sucursal_scope
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_usuario_sucursal_usuario
        FOREIGN KEY (company_id, usuario_id)
        REFERENCES iqg_core.usuario (company_id, usuario_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

CREATE TABLE iqg_core.rol (
    rol_id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                  uuid NOT NULL,
    branch_id                   uuid NOT NULL,
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    codigo                      varchar(64) NOT NULL,
    nombre                      text NOT NULL,
    descripcion                 text NULL,
    activo                      boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_rol_scope UNIQUE (company_id, branch_id, rol_id),
    CONSTRAINT uq_rol_codigo UNIQUE (company_id, branch_id, codigo),
    CONSTRAINT fk_rol_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

CREATE TABLE iqg_core.permiso (
    permiso_id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                  uuid NOT NULL,
    branch_id                   uuid NOT NULL,
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    recurso_codigo              varchar(96) NOT NULL,
    accion_codigo               varchar(64) NOT NULL,
    descripcion                 text NULL,
    activo                      boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_permiso_scope UNIQUE (company_id, branch_id, permiso_id),
    CONSTRAINT uq_permiso_recurso_accion UNIQUE (company_id, branch_id, recurso_codigo, accion_codigo),
    CONSTRAINT fk_permiso_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

CREATE TABLE iqg_core.rol_permiso (
    rol_permiso_id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                  uuid NOT NULL,
    branch_id                   uuid NOT NULL,
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    rol_id                      uuid NOT NULL,
    permiso_id                  uuid NOT NULL,
    activo                      boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_rol_permiso_scope UNIQUE (company_id, branch_id, rol_permiso_id),
    CONSTRAINT uq_rol_permiso_asignacion UNIQUE (company_id, branch_id, rol_id, permiso_id),
    CONSTRAINT fk_rol_permiso_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_rol_permiso_rol
        FOREIGN KEY (company_id, branch_id, rol_id)
        REFERENCES iqg_core.rol (company_id, branch_id, rol_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_rol_permiso_permiso
        FOREIGN KEY (company_id, branch_id, permiso_id)
        REFERENCES iqg_core.permiso (company_id, branch_id, permiso_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

CREATE TABLE iqg_core.usuario_rol (
    usuario_rol_id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                  uuid NOT NULL,
    branch_id                   uuid NOT NULL,
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    usuario_sucursal_id         uuid NOT NULL,
    rol_id                      uuid NOT NULL,
    activo                      boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_usuario_rol_scope UNIQUE (company_id, branch_id, usuario_rol_id),
    CONSTRAINT uq_usuario_rol_asignacion UNIQUE (company_id, branch_id, usuario_sucursal_id, rol_id),
    CONSTRAINT fk_usuario_rol_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_usuario_rol_usuario_sucursal
        FOREIGN KEY (company_id, branch_id, usuario_sucursal_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_sucursal_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_usuario_rol_rol
        FOREIGN KEY (company_id, branch_id, rol_id)
        REFERENCES iqg_core.rol (company_id, branch_id, rol_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

-- -----------------------------------------------------------------------------
-- Catálogo, precios, CRM y atribución
-- -----------------------------------------------------------------------------

CREATE TABLE iqg_core.elemento (
    elemento_id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                  uuid NOT NULL,
    branch_id                   uuid NOT NULL,
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    codigo                      varchar(96) NOT NULL,
    nombre                      text NOT NULL,
    descripcion                 text NULL,
    tipo_codigo                 varchar(64) NOT NULL,
    unidad_medida_codigo        varchar(32) NOT NULL,
    es_vendible                 boolean NOT NULL DEFAULT false,
    es_inventariable            boolean NOT NULL DEFAULT false,
    activo                      boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_elemento_scope UNIQUE (company_id, branch_id, elemento_id),
    CONSTRAINT uq_elemento_codigo UNIQUE (company_id, branch_id, codigo),
    CONSTRAINT fk_elemento_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

-- precio_vigente es un libro de versiones: reemplazar un precio inserta una
-- fila nueva que apunta a la anterior. Nunca se cierra ni edita la fila previa.
CREATE TABLE iqg_core.precio_vigente (
    precio_vigente_id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                  uuid NOT NULL,
    branch_id                   uuid NOT NULL,
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    elemento_id                 uuid NOT NULL,
    moneda_codigo               varchar(3) NOT NULL,
    importe_menor               bigint NOT NULL,
    valid_from                  timestamptz NOT NULL,
    valid_to                    timestamptz NULL,
    reemplaza_precio_vigente_id uuid NULL,
    origen_idempotencia         varchar(64) NOT NULL,
    clave_idempotencia          uuid NOT NULL,
    motivo                      text NULL,
    CONSTRAINT uq_precio_vigente_scope UNIQUE (company_id, branch_id, precio_vigente_id),
    CONSTRAINT uq_precio_unico_sucesor UNIQUE (company_id, branch_id, reemplaza_precio_vigente_id),
    CONSTRAINT uq_precio_idempotencia UNIQUE (company_id, branch_id, origen_idempotencia, clave_idempotencia),
    CONSTRAINT ck_precio_moneda CHECK (moneda_codigo ~ '^[A-Z]{3}$'),
    CONSTRAINT ck_precio_importe CHECK (importe_menor >= 0),
    CONSTRAINT ck_precio_vigencia CHECK (valid_to IS NULL OR valid_to > valid_from),
    CONSTRAINT fk_precio_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_precio_elemento
        FOREIGN KEY (company_id, branch_id, elemento_id)
        REFERENCES iqg_core.elemento (company_id, branch_id, elemento_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_precio_reemplazado
        FOREIGN KEY (company_id, branch_id, reemplaza_precio_vigente_id)
        REFERENCES iqg_core.precio_vigente (company_id, branch_id, precio_vigente_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

-- Solo puede existir una raíz por elemento y moneda. Los precios posteriores
-- deben enlazarse con reemplaza_precio_vigente_id para formar una única cadena.
CREATE UNIQUE INDEX uq_precio_raiz_elemento_moneda
    ON iqg_core.precio_vigente (company_id, branch_id, elemento_id, moneda_codigo)
    WHERE reemplaza_precio_vigente_id IS NULL;

CREATE TABLE iqg_core.canal (
    canal_id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                  uuid NOT NULL,
    branch_id                   uuid NOT NULL,
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    codigo                      varchar(64) NOT NULL,
    nombre                      text NOT NULL,
    descripcion                 text NULL,
    activo                      boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_canal_scope UNIQUE (company_id, branch_id, canal_id),
    CONSTRAINT uq_canal_codigo UNIQUE (company_id, branch_id, codigo),
    CONSTRAINT fk_canal_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

CREATE TABLE iqg_core.campania (
    campania_id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                  uuid NOT NULL,
    branch_id                   uuid NOT NULL,
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    canal_id                    uuid NULL,
    codigo                      varchar(96) NOT NULL,
    nombre                      text NOT NULL,
    fecha_inicio                timestamptz NULL,
    fecha_fin                   timestamptz NULL,
    activo                      boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_campania_scope UNIQUE (company_id, branch_id, campania_id),
    CONSTRAINT uq_campania_codigo UNIQUE (company_id, branch_id, codigo),
    CONSTRAINT ck_campania_fechas CHECK (fecha_fin IS NULL OR fecha_inicio IS NULL OR fecha_fin >= fecha_inicio),
    CONSTRAINT fk_campania_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_campania_canal
        FOREIGN KEY (company_id, branch_id, canal_id)
        REFERENCES iqg_core.canal (company_id, branch_id, canal_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

-- Se mantienen únicamente datos de contacto necesarios para operar y medir.
-- No hay secretos, credenciales ni categorías sensibles de datos personales.
CREATE TABLE iqg_core.cliente (
    cliente_id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                  uuid NOT NULL,
    branch_id                   uuid NOT NULL,
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    canal_id                    uuid NULL,
    identificador_externo       text NULL,
    nombre_mostrar              text NOT NULL,
    correo_electronico          text NULL,
    telefono                    text NULL,
    permite_contacto_comercial  boolean NOT NULL DEFAULT false,
    fecha_consentimiento        timestamptz NULL,
    activo                      boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_cliente_scope UNIQUE (company_id, branch_id, cliente_id),
    CONSTRAINT fk_cliente_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_cliente_canal
        FOREIGN KEY (company_id, branch_id, canal_id)
        REFERENCES iqg_core.canal (company_id, branch_id, canal_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT ck_cliente_consentimiento CHECK (
        (permite_contacto_comercial = false AND fecha_consentimiento IS NULL)
        OR (permite_contacto_comercial = true AND fecha_consentimiento IS NOT NULL)
    )
);

-- La ausencia de identificador externo es válida para muchos clientes; solo
-- los identificadores efectivamente suministrados deben ser únicos por alcance.
CREATE UNIQUE INDEX uq_cliente_identificador_externo
    ON iqg_core.cliente (company_id, branch_id, identificador_externo)
    WHERE identificador_externo IS NOT NULL;

-- -----------------------------------------------------------------------------
-- Estados, operaciones, pagos y caja
-- -----------------------------------------------------------------------------

CREATE TABLE iqg_core.estado (
    estado_id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                  uuid NOT NULL,
    branch_id                   uuid NOT NULL,
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    entidad_codigo              varchar(64) NOT NULL,
    codigo                      varchar(64) NOT NULL,
    nombre                      text NOT NULL,
    es_terminal                 boolean NOT NULL DEFAULT false,
    activo                      boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_estado_scope UNIQUE (company_id, branch_id, estado_id),
    CONSTRAINT uq_estado_entidad_codigo UNIQUE (company_id, branch_id, entidad_codigo, codigo),
    CONSTRAINT fk_estado_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

-- operacion es una cabecera de hecho inmutable. fecha_operacion se sella con la
-- fecha del servidor. fecha_origen conserva una fecha fuente verificable para
-- una futura migración sin falsificar la fecha oficial de creación.
CREATE TABLE iqg_core.operacion (
    operacion_id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                  uuid NOT NULL,
    branch_id                   uuid NOT NULL,
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    fecha_operacion             timestamptz NOT NULL DEFAULT clock_timestamp(),
    fecha_origen                timestamptz NULL,
    cliente_id                  uuid NULL,
    canal_id                    uuid NULL,
    campania_id                 uuid NULL,
    tipo_operacion_codigo       varchar(64) NOT NULL,
    signo_impacto               smallint NOT NULL DEFAULT 1,
    moneda_codigo               varchar(3) NOT NULL,
    referencia_externa          text NULL,
    origen_idempotencia         varchar(64) NOT NULL,
    clave_idempotencia          uuid NOT NULL,
    operacion_referencia_id     uuid NULL,
    motivo                      text NULL,
    CONSTRAINT uq_operacion_scope UNIQUE (company_id, branch_id, operacion_id),
    CONSTRAINT uq_operacion_idempotencia UNIQUE (company_id, branch_id, origen_idempotencia, clave_idempotencia),
    CONSTRAINT ck_operacion_signo CHECK (signo_impacto IN (-1, 1)),
    CONSTRAINT ck_operacion_moneda CHECK (moneda_codigo ~ '^[A-Z]{3}$'),
    CONSTRAINT fk_operacion_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_operacion_cliente
        FOREIGN KEY (company_id, branch_id, cliente_id)
        REFERENCES iqg_core.cliente (company_id, branch_id, cliente_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_operacion_canal
        FOREIGN KEY (company_id, branch_id, canal_id)
        REFERENCES iqg_core.canal (company_id, branch_id, canal_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_operacion_campania
        FOREIGN KEY (company_id, branch_id, campania_id)
        REFERENCES iqg_core.campania (company_id, branch_id, campania_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_operacion_referencia
        FOREIGN KEY (company_id, branch_id, operacion_referencia_id)
        REFERENCES iqg_core.operacion (company_id, branch_id, operacion_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

-- El estado actual se deriva de la última transición; no se sobrescribe una
-- columna de estado en operacion.
CREATE TABLE iqg_core.operacion_estado (
    operacion_estado_id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                  uuid NOT NULL,
    branch_id                   uuid NOT NULL,
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    operacion_id                uuid NOT NULL,
    estado_id                   uuid NOT NULL,
    origen_idempotencia         varchar(64) NOT NULL,
    clave_idempotencia          uuid NOT NULL,
    motivo                      text NULL,
    CONSTRAINT uq_operacion_estado_scope UNIQUE (company_id, branch_id, operacion_estado_id),
    CONSTRAINT uq_operacion_estado_idempotencia UNIQUE (company_id, branch_id, origen_idempotencia, clave_idempotencia),
    CONSTRAINT fk_operacion_estado_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_operacion_estado_operacion
        FOREIGN KEY (company_id, branch_id, operacion_id)
        REFERENCES iqg_core.operacion (company_id, branch_id, operacion_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_operacion_estado_estado
        FOREIGN KEY (company_id, branch_id, estado_id)
        REFERENCES iqg_core.estado (company_id, branch_id, estado_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

-- Los importes se expresan en la unidad menor de la moneda. Cuando una
-- cantidad admite fracciones, el importe derivado se calcula una sola vez con
-- round(numeric) de PostgreSQL al menor unitario más cercano; no hay una
-- segunda fuente de verdad para el bruto.
CREATE TABLE iqg_core.operacion_linea (
    operacion_linea_id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                  uuid NOT NULL,
    branch_id                   uuid NOT NULL,
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    operacion_id                uuid NOT NULL,
    elemento_id                 uuid NOT NULL,
    numero_linea                integer NOT NULL,
    nombre_elemento_snapshot    text NOT NULL,
    unidad_medida_codigo        varchar(32) NOT NULL,
    cantidad                    numeric(20, 6) NOT NULL,
    moneda_codigo               varchar(3) NOT NULL,
    precio_unitario_menor       bigint NOT NULL,
    importe_bruto_menor         bigint NOT NULL,
    descuento_menor             bigint NOT NULL DEFAULT 0,
    impuesto_menor              bigint NOT NULL DEFAULT 0,
    importe_total_menor         bigint NOT NULL,
    -- Snapshot de margen; el libro movimiento sigue siendo la fuente de
    -- existencias y valoración. Si se conserva, su total es verificable.
    costo_unitario_menor        bigint NULL,
    costo_total_menor           bigint NULL,
    CONSTRAINT uq_operacion_linea_scope UNIQUE (company_id, branch_id, operacion_linea_id),
    CONSTRAINT uq_operacion_linea_ordinal UNIQUE (company_id, branch_id, operacion_id, numero_linea),
    CONSTRAINT ck_operacion_linea_numero CHECK (numero_linea > 0),
    CONSTRAINT ck_operacion_linea_cantidad CHECK (cantidad > 0),
    CONSTRAINT ck_operacion_linea_moneda CHECK (moneda_codigo ~ '^[A-Z]{3}$'),
    CONSTRAINT ck_operacion_linea_montos CHECK (
        precio_unitario_menor >= 0
        AND importe_bruto_menor >= 0
        AND descuento_menor >= 0
        AND impuesto_menor >= 0
        AND importe_bruto_menor = round(cantidad * precio_unitario_menor)::bigint
        AND descuento_menor <= importe_bruto_menor
        AND importe_total_menor = importe_bruto_menor - descuento_menor + impuesto_menor
        AND importe_total_menor >= 0
        AND (
            (costo_unitario_menor IS NULL AND costo_total_menor IS NULL)
            OR (
                costo_unitario_menor IS NOT NULL
                AND costo_total_menor IS NOT NULL
                AND costo_unitario_menor >= 0
                AND costo_total_menor >= 0
                AND costo_total_menor = round(cantidad * costo_unitario_menor)::bigint
            )
        )
    ),
    CONSTRAINT fk_operacion_linea_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_operacion_linea_operacion
        FOREIGN KEY (company_id, branch_id, operacion_id)
        REFERENCES iqg_core.operacion (company_id, branch_id, operacion_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_operacion_linea_elemento
        FOREIGN KEY (company_id, branch_id, elemento_id)
        REFERENCES iqg_core.elemento (company_id, branch_id, elemento_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

-- Los reversos o devoluciones de pago son nuevos eventos con signo negativo y
-- pago_referencia_id. No se cambia ni se elimina el cobro original.
CREATE TABLE iqg_core.pago (
    pago_id                     uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                  uuid NOT NULL,
    branch_id                   uuid NOT NULL,
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    operacion_id                uuid NOT NULL,
    pago_referencia_id          uuid NULL,
    medio_pago_codigo           varchar(64) NOT NULL,
    signo_impacto               smallint NOT NULL DEFAULT 1,
    moneda_codigo               varchar(3) NOT NULL,
    importe_menor               bigint NOT NULL,
    referencia_externa          text NULL,
    origen_idempotencia         varchar(64) NOT NULL,
    clave_idempotencia          uuid NOT NULL,
    motivo                      text NULL,
    CONSTRAINT uq_pago_scope UNIQUE (company_id, branch_id, pago_id),
    CONSTRAINT uq_pago_idempotencia UNIQUE (company_id, branch_id, origen_idempotencia, clave_idempotencia),
    CONSTRAINT ck_pago_signo CHECK (signo_impacto IN (-1, 1)),
    CONSTRAINT ck_pago_moneda CHECK (moneda_codigo ~ '^[A-Z]{3}$'),
    CONSTRAINT ck_pago_importe CHECK (importe_menor > 0),
    CONSTRAINT fk_pago_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_pago_operacion
        FOREIGN KEY (company_id, branch_id, operacion_id)
        REFERENCES iqg_core.operacion (company_id, branch_id, operacion_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_pago_referencia
        FOREIGN KEY (company_id, branch_id, pago_referencia_id)
        REFERENCES iqg_core.pago (company_id, branch_id, pago_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

CREATE TABLE iqg_core.caja (
    caja_id                     uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                  uuid NOT NULL,
    branch_id                   uuid NOT NULL,
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    codigo                      varchar(64) NOT NULL,
    nombre                      text NOT NULL,
    moneda_codigo               varchar(3) NOT NULL,
    activo                      boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_caja_scope UNIQUE (company_id, branch_id, caja_id),
    CONSTRAINT uq_caja_codigo UNIQUE (company_id, branch_id, codigo),
    CONSTRAINT ck_caja_moneda CHECK (moneda_codigo ~ '^[A-Z]{3}$'),
    CONSTRAINT fk_caja_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

CREATE TABLE iqg_core.movimiento_caja (
    movimiento_caja_id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                  uuid NOT NULL,
    branch_id                   uuid NOT NULL,
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    caja_id                     uuid NOT NULL,
    operacion_id                uuid NULL,
    pago_id                     uuid NULL,
    tipo_movimiento_codigo      varchar(64) NOT NULL,
    signo_impacto               smallint NOT NULL,
    moneda_codigo               varchar(3) NOT NULL,
    importe_menor               bigint NOT NULL,
    origen_idempotencia         varchar(64) NOT NULL,
    clave_idempotencia          uuid NOT NULL,
    motivo                      text NULL,
    CONSTRAINT uq_movimiento_caja_scope UNIQUE (company_id, branch_id, movimiento_caja_id),
    CONSTRAINT uq_movimiento_caja_idempotencia UNIQUE (company_id, branch_id, origen_idempotencia, clave_idempotencia),
    CONSTRAINT ck_movimiento_caja_signo CHECK (signo_impacto IN (-1, 1)),
    CONSTRAINT ck_movimiento_caja_moneda CHECK (moneda_codigo ~ '^[A-Z]{3}$'),
    CONSTRAINT ck_movimiento_caja_importe CHECK (importe_menor > 0),
    CONSTRAINT fk_movimiento_caja_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_movimiento_caja_caja
        FOREIGN KEY (company_id, branch_id, caja_id)
        REFERENCES iqg_core.caja (company_id, branch_id, caja_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_movimiento_caja_operacion
        FOREIGN KEY (company_id, branch_id, operacion_id)
        REFERENCES iqg_core.operacion (company_id, branch_id, operacion_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_movimiento_caja_pago
        FOREIGN KEY (company_id, branch_id, pago_id)
        REFERENCES iqg_core.pago (company_id, branch_id, pago_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

-- -----------------------------------------------------------------------------
-- Libro de movimientos. La existencia y el costo se derivan de movimientos;
-- no existe un saldo mutable como fuente única de verdad.
-- Los costos siguen la misma regla de redondeo de operación_linea: round(numeric)
-- al entero de unidad monetaria menor más cercano.
-- -----------------------------------------------------------------------------

CREATE TABLE iqg_core.grupo_movimiento (
    grupo_movimiento_id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                  uuid NOT NULL,
    branch_id                   uuid NOT NULL,
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    tipo_movimiento_codigo      varchar(64) NOT NULL,
    grupo_referencia_id         uuid NULL,
    origen_idempotencia         varchar(64) NOT NULL,
    clave_idempotencia          uuid NOT NULL,
    motivo                      text NULL,
    CONSTRAINT uq_grupo_movimiento_scope UNIQUE (company_id, branch_id, grupo_movimiento_id),
    CONSTRAINT uq_grupo_movimiento_idempotencia UNIQUE (company_id, branch_id, origen_idempotencia, clave_idempotencia),
    CONSTRAINT fk_grupo_movimiento_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_grupo_movimiento_referencia
        FOREIGN KEY (company_id, branch_id, grupo_referencia_id)
        REFERENCES iqg_core.grupo_movimiento (company_id, branch_id, grupo_movimiento_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

CREATE TABLE iqg_core.movimiento (
    movimiento_id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                  uuid NOT NULL,
    branch_id                   uuid NOT NULL,
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    grupo_movimiento_id         uuid NOT NULL,
    numero_linea_grupo          integer NOT NULL,
    operacion_id                uuid NULL,
    elemento_id                 uuid NOT NULL,
    ubicacion_codigo            varchar(64) NULL,
    signo_cantidad              smallint NOT NULL,
    cantidad                    numeric(20, 6) NOT NULL,
    unidad_medida_codigo        varchar(32) NOT NULL,
    moneda_codigo               varchar(3) NULL,
    costo_unitario_menor        bigint NULL,
    costo_total_menor           bigint NULL,
    referencia_externa          text NULL,
    origen_idempotencia         varchar(64) NOT NULL,
    clave_idempotencia          uuid NOT NULL,
    CONSTRAINT uq_movimiento_scope UNIQUE (company_id, branch_id, movimiento_id),
    CONSTRAINT uq_movimiento_linea_grupo UNIQUE (company_id, branch_id, grupo_movimiento_id, numero_linea_grupo),
    CONSTRAINT uq_movimiento_idempotencia UNIQUE (company_id, branch_id, origen_idempotencia, clave_idempotencia),
    CONSTRAINT ck_movimiento_numero_linea_grupo CHECK (numero_linea_grupo > 0),
    CONSTRAINT ck_movimiento_signo CHECK (signo_cantidad IN (-1, 1)),
    CONSTRAINT ck_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT ck_movimiento_moneda CHECK (moneda_codigo IS NULL OR moneda_codigo ~ '^[A-Z]{3}$'),
    CONSTRAINT ck_movimiento_costos CHECK (
        (moneda_codigo IS NULL
         AND costo_unitario_menor IS NULL
         AND costo_total_menor IS NULL)
        OR (
            moneda_codigo IS NOT NULL
            AND costo_unitario_menor IS NOT NULL
            AND costo_total_menor IS NOT NULL
            AND costo_unitario_menor >= 0
            AND costo_total_menor >= 0
            AND costo_total_menor = round(cantidad * costo_unitario_menor)::bigint
        )
    ),
    CONSTRAINT fk_movimiento_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_movimiento_grupo
        FOREIGN KEY (company_id, branch_id, grupo_movimiento_id)
        REFERENCES iqg_core.grupo_movimiento (company_id, branch_id, grupo_movimiento_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_movimiento_operacion
        FOREIGN KEY (company_id, branch_id, operacion_id)
        REFERENCES iqg_core.operacion (company_id, branch_id, operacion_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_movimiento_elemento
        FOREIGN KEY (company_id, branch_id, elemento_id)
        REFERENCES iqg_core.elemento (company_id, branch_id, elemento_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

-- -----------------------------------------------------------------------------
-- Auditoría forense. No existe FK a registro_id porque un DELETE histórico
-- podría ya no tener fila destino; tabla_origen + registro_id conservan vínculo.
-- -----------------------------------------------------------------------------

CREATE TABLE iqg_core.registro_cambios (
    registro_cambio_id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                  uuid NOT NULL,
    branch_id                   uuid NOT NULL,
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    transaccion_id              bigint NOT NULL DEFAULT txid_current(),
    correlation_id              uuid NULL,
    direccion_ip                inet NULL,
    actor_tipo_codigo           varchar(32) NOT NULL DEFAULT 'SISTEMA',
    tabla_origen                text NOT NULL,
    operacion_dml               varchar(6) NOT NULL,
    registro_id                 uuid NOT NULL,
    motivo                      text NULL,
    datos_antes                 jsonb NULL,
    datos_despues               jsonb NULL,
    CONSTRAINT uq_registro_cambios_scope UNIQUE (company_id, branch_id, registro_cambio_id),
    CONSTRAINT ck_registro_cambios_operacion CHECK (operacion_dml IN ('INSERT', 'UPDATE', 'DELETE')),
    CONSTRAINT ck_registro_cambios_tabla CHECK (tabla_origen <> 'registro_cambios'),
    CONSTRAINT ck_registro_cambios_valores CHECK (
        (operacion_dml = 'INSERT' AND datos_antes IS NULL AND datos_despues IS NOT NULL)
        OR (operacion_dml = 'UPDATE' AND datos_antes IS NOT NULL AND datos_despues IS NOT NULL)
        OR (operacion_dml = 'DELETE' AND datos_antes IS NOT NULL AND datos_despues IS NULL)
    ),
    CONSTRAINT fk_registro_cambios_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        DEFERRABLE INITIALLY DEFERRED
);

-- Cada actor creador debe pertenecer al mismo alcance de la fila. Se agregan
-- después de usuario_sucursal para permitir el bootstrap transaccional.
ALTER TABLE iqg_core.empresa
    ADD CONSTRAINT fk_empresa_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE iqg_core.sucursal
    ADD CONSTRAINT fk_sucursal_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE iqg_core.usuario
    ADD CONSTRAINT fk_usuario_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE iqg_core.usuario_sucursal
    ADD CONSTRAINT fk_usuario_sucursal_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE iqg_core.rol
    ADD CONSTRAINT fk_rol_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE iqg_core.permiso
    ADD CONSTRAINT fk_permiso_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE iqg_core.rol_permiso
    ADD CONSTRAINT fk_rol_permiso_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE iqg_core.usuario_rol
    ADD CONSTRAINT fk_usuario_rol_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE iqg_core.elemento
    ADD CONSTRAINT fk_elemento_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE iqg_core.precio_vigente
    ADD CONSTRAINT fk_precio_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE iqg_core.canal
    ADD CONSTRAINT fk_canal_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE iqg_core.campania
    ADD CONSTRAINT fk_campania_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE iqg_core.cliente
    ADD CONSTRAINT fk_cliente_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE iqg_core.estado
    ADD CONSTRAINT fk_estado_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE iqg_core.operacion
    ADD CONSTRAINT fk_operacion_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE iqg_core.operacion_estado
    ADD CONSTRAINT fk_operacion_estado_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE iqg_core.operacion_linea
    ADD CONSTRAINT fk_operacion_linea_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE iqg_core.pago
    ADD CONSTRAINT fk_pago_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE iqg_core.caja
    ADD CONSTRAINT fk_caja_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE iqg_core.movimiento_caja
    ADD CONSTRAINT fk_movimiento_caja_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE iqg_core.grupo_movimiento
    ADD CONSTRAINT fk_grupo_movimiento_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE iqg_core.movimiento
    ADD CONSTRAINT fk_movimiento_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE iqg_core.registro_cambios
    ADD CONSTRAINT fk_registro_cambios_actor
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;

-- -----------------------------------------------------------------------------
-- Índices de aislamiento, recorrido histórico y claves foráneas de alto uso.
-- Los índices comienzan por company_id + branch_id para que no se mezclen
-- recorridos de tenants y sucursales.
-- -----------------------------------------------------------------------------

CREATE INDEX idx_empresa_scope_fecha ON iqg_core.empresa (company_id, branch_id, fecha_creacion DESC);
CREATE INDEX idx_sucursal_scope_fecha ON iqg_core.sucursal (company_id, branch_id, fecha_creacion DESC);
CREATE INDEX idx_usuario_scope_fecha ON iqg_core.usuario (company_id, branch_id, fecha_creacion DESC);
CREATE INDEX idx_usuario_sucursal_scope_usuario ON iqg_core.usuario_sucursal (company_id, branch_id, usuario_id);
CREATE INDEX idx_rol_scope_fecha ON iqg_core.rol (company_id, branch_id, fecha_creacion DESC);
CREATE INDEX idx_permiso_scope_fecha ON iqg_core.permiso (company_id, branch_id, fecha_creacion DESC);
CREATE INDEX idx_rol_permiso_scope_rol ON iqg_core.rol_permiso (company_id, branch_id, rol_id);
CREATE INDEX idx_usuario_rol_scope_usuario ON iqg_core.usuario_rol (company_id, branch_id, usuario_sucursal_id);
CREATE INDEX idx_elemento_scope_fecha ON iqg_core.elemento (company_id, branch_id, fecha_creacion DESC);
CREATE INDEX idx_precio_scope_elemento_fecha ON iqg_core.precio_vigente (company_id, branch_id, elemento_id, fecha_creacion DESC);
CREATE INDEX idx_canal_scope_fecha ON iqg_core.canal (company_id, branch_id, fecha_creacion DESC);
CREATE INDEX idx_campania_scope_fecha ON iqg_core.campania (company_id, branch_id, fecha_creacion DESC);
CREATE INDEX idx_cliente_scope_fecha ON iqg_core.cliente (company_id, branch_id, fecha_creacion DESC);
CREATE INDEX idx_estado_scope_entidad ON iqg_core.estado (company_id, branch_id, entidad_codigo, codigo);
CREATE INDEX idx_operacion_scope_fecha_operacion ON iqg_core.operacion (company_id, branch_id, fecha_operacion DESC);
CREATE INDEX idx_operacion_scope_cliente_fecha ON iqg_core.operacion (company_id, branch_id, cliente_id, fecha_operacion DESC);
CREATE INDEX idx_operacion_estado_scope_operacion_fecha ON iqg_core.operacion_estado (company_id, branch_id, operacion_id, fecha_creacion DESC);
CREATE INDEX idx_operacion_linea_scope_operacion ON iqg_core.operacion_linea (company_id, branch_id, operacion_id, numero_linea);
CREATE INDEX idx_operacion_linea_scope_elemento ON iqg_core.operacion_linea (company_id, branch_id, elemento_id, fecha_creacion DESC);
CREATE INDEX idx_pago_scope_operacion_fecha ON iqg_core.pago (company_id, branch_id, operacion_id, fecha_creacion DESC);
CREATE INDEX idx_caja_scope_fecha ON iqg_core.caja (company_id, branch_id, fecha_creacion DESC);
CREATE INDEX idx_movimiento_caja_scope_caja_fecha ON iqg_core.movimiento_caja (company_id, branch_id, caja_id, fecha_creacion DESC);
CREATE UNIQUE INDEX uq_movimiento_caja_pago_unico
    ON iqg_core.movimiento_caja (company_id, branch_id, pago_id)
    WHERE pago_id IS NOT NULL;
CREATE INDEX idx_grupo_movimiento_scope_fecha ON iqg_core.grupo_movimiento (company_id, branch_id, fecha_creacion DESC);
CREATE INDEX idx_movimiento_scope_elemento_fecha ON iqg_core.movimiento (company_id, branch_id, elemento_id, fecha_creacion DESC);
CREATE INDEX idx_movimiento_scope_grupo ON iqg_core.movimiento (company_id, branch_id, grupo_movimiento_id);
CREATE INDEX idx_registro_cambios_scope_destino_fecha ON iqg_core.registro_cambios (company_id, branch_id, tabla_origen, registro_id, fecha_creacion DESC);

-- -----------------------------------------------------------------------------
-- Integridad temporal, contexto inmutable y auditoría.
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION iqg_core.tg_sellar_registro()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = iqg_core, pg_temp
AS $$
DECLARE
    v_actor uuid := iqg_core.contexto_usuario_id();
    v_id_anterior text;
    v_id_nuevo text;
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- El servidor siempre decide la fecha oficial de creación.
        NEW.fecha_creacion := clock_timestamp();

        -- No existe una fila sin actor. El bootstrap usa provisionar_empresa,
        -- que genera un actor inicial y lo propaga dentro de su transacción.
        IF v_actor IS NULL THEN
            RAISE EXCEPTION 'Todo registro requiere iqg.usuario_id; use la ruta privilegiada de provisión para el alta inicial';
        END IF;

        IF NEW.creado_por_usuario_id IS NOT NULL
           AND NEW.creado_por_usuario_id IS DISTINCT FROM v_actor THEN
            RAISE EXCEPTION 'El actor del contexto no coincide con creado_por_usuario_id';
        END IF;
        NEW.creado_por_usuario_id := v_actor;

        RETURN NEW;
    END IF;

    IF NEW.company_id IS DISTINCT FROM OLD.company_id
       OR NEW.branch_id IS DISTINCT FROM OLD.branch_id THEN
        RAISE EXCEPTION 'company_id y branch_id son inmutables';
    END IF;

    IF NEW.fecha_creacion IS DISTINCT FROM OLD.fecha_creacion THEN
        RAISE EXCEPTION 'fecha_creacion es inmutable y solo la define el servidor';
    END IF;

    IF NEW.creado_por_usuario_id IS DISTINCT FROM OLD.creado_por_usuario_id THEN
        RAISE EXCEPTION 'creado_por_usuario_id es inmutable';
    END IF;

    v_id_anterior := to_jsonb(OLD) ->> TG_ARGV[0];
    v_id_nuevo := to_jsonb(NEW) ->> TG_ARGV[0];
    IF v_id_nuevo IS DISTINCT FROM v_id_anterior THEN
        RAISE EXCEPTION 'El identificador % es inmutable en %', TG_ARGV[0], TG_TABLE_NAME;
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION iqg_core.tg_sellar_fecha_operacion()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = iqg_core, pg_temp
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- Se ejecuta después de tg_sellar_registro y toma exactamente la misma
        -- marca de tiempo autoritativa del servidor.
        NEW.fecha_operacion := NEW.fecha_creacion;
        RETURN NEW;
    END IF;

    IF NEW.fecha_operacion IS DISTINCT FROM OLD.fecha_operacion THEN
        RAISE EXCEPTION 'fecha_operacion es inmutable';
    END IF;

    IF NEW.fecha_origen IS DISTINCT FROM OLD.fecha_origen THEN
        RAISE EXCEPTION 'fecha_origen es inmutable';
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION iqg_core.tg_bloquear_delete()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = iqg_core, pg_temp
AS $$
BEGIN
    RAISE EXCEPTION 'No se permiten DELETE en %. Desactive o corrija mediante un nuevo registro auditable.', TG_TABLE_NAME;
    RETURN OLD;
END;
$$;

CREATE OR REPLACE FUNCTION iqg_core.tg_bloquear_cambio_moneda_caja()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = iqg_core, pg_temp
AS $$
BEGIN
    IF NEW.moneda_codigo IS DISTINCT FROM OLD.moneda_codigo THEN
        RAISE EXCEPTION 'La moneda de una caja es inmutable; cree una nueva caja para otra moneda';
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION iqg_core.tg_bloquear_truncate()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = iqg_core, pg_temp
AS $$
BEGIN
    RAISE EXCEPTION 'No se permite TRUNCATE en %. La historia se conserva mediante eventos y migraciones controladas.', TG_TABLE_NAME;
    RETURN NULL;
END;
$$;

CREATE OR REPLACE FUNCTION iqg_core.tg_bloquear_mutacion_append_only()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = iqg_core, pg_temp
AS $$
BEGIN
    RAISE EXCEPTION '% es append-only. Inserte un evento de corrección; no actualice ni borre historia.', TG_TABLE_NAME;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION iqg_core.tg_validar_precio_vigente()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = iqg_core, pg_temp
AS $$
DECLARE
    v_elemento_anterior uuid;
    v_moneda_anterior varchar(3);
    v_inicio_anterior timestamptz;
BEGIN
    IF NEW.reemplaza_precio_vigente_id IS NULL THEN
        RETURN NEW;
    END IF;

    -- El candado y las unicidades de raíz/sucesor hacen que dos reintentos no
    -- puedan construir ramas distintas de la misma cadena de precios.
    SELECT elemento_id, moneda_codigo, valid_from
      INTO v_elemento_anterior, v_moneda_anterior, v_inicio_anterior
      FROM iqg_core.precio_vigente
     WHERE company_id = NEW.company_id
       AND branch_id = NEW.branch_id
       AND precio_vigente_id = NEW.reemplaza_precio_vigente_id
     FOR KEY SHARE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El precio reemplazado no existe en el alcance indicado';
    END IF;

    IF NEW.elemento_id IS DISTINCT FROM v_elemento_anterior
       OR NEW.moneda_codigo IS DISTINCT FROM v_moneda_anterior THEN
        RAISE EXCEPTION 'Un precio solo puede reemplazar otro precio del mismo elemento y moneda';
    END IF;

    IF NEW.valid_from <= v_inicio_anterior THEN
        RAISE EXCEPTION 'valid_from debe ser posterior al inicio del precio reemplazado';
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION iqg_core.tg_validar_operacion_linea()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = iqg_core, pg_temp
AS $$
DECLARE
    v_moneda_operacion varchar(3);
BEGIN
    SELECT moneda_codigo
      INTO v_moneda_operacion
      FROM iqg_core.operacion
     WHERE company_id = NEW.company_id
       AND branch_id = NEW.branch_id
       AND operacion_id = NEW.operacion_id
     FOR KEY SHARE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La operación de la línea no existe en el alcance indicado';
    END IF;

    IF NEW.moneda_codigo IS DISTINCT FROM v_moneda_operacion THEN
        RAISE EXCEPTION 'La moneda de una línea debe coincidir con la moneda de su operación';
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION iqg_core.tg_validar_pago()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = iqg_core, pg_temp
AS $$
DECLARE
    v_moneda_operacion varchar(3);
    v_operacion_padre uuid;
    v_moneda_padre varchar(3);
    v_signo_padre smallint;
    v_importe_padre bigint;
    v_importe_revertido bigint;
BEGIN
    SELECT moneda_codigo
      INTO v_moneda_operacion
      FROM iqg_core.operacion
     WHERE company_id = NEW.company_id
       AND branch_id = NEW.branch_id
       AND operacion_id = NEW.operacion_id
     FOR KEY SHARE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La operación del pago no existe en el alcance indicado';
    END IF;

    IF NEW.moneda_codigo IS DISTINCT FROM v_moneda_operacion THEN
        RAISE EXCEPTION 'La moneda de un pago debe coincidir con la moneda de su operación';
    END IF;

    IF NEW.pago_referencia_id IS NULL THEN
        IF NEW.signo_impacto <> 1 THEN
            RAISE EXCEPTION 'Un pago con signo negativo debe referenciar el pago positivo que revierte';
        END IF;
        RETURN NEW;
    END IF;

    IF NEW.pago_referencia_id = NEW.pago_id THEN
        RAISE EXCEPTION 'Un pago no puede referenciarse a sí mismo';
    END IF;

    -- El bloqueo del pago padre serializa devoluciones parciales concurrentes.
    SELECT operacion_id, moneda_codigo, signo_impacto, importe_menor
      INTO v_operacion_padre, v_moneda_padre, v_signo_padre, v_importe_padre
      FROM iqg_core.pago
     WHERE company_id = NEW.company_id
       AND branch_id = NEW.branch_id
       AND pago_id = NEW.pago_referencia_id
     FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El pago de referencia no existe en el alcance indicado';
    END IF;

    IF NEW.signo_impacto <> -1
       OR v_signo_padre <> 1
       OR NEW.operacion_id IS DISTINCT FROM v_operacion_padre
       OR NEW.moneda_codigo IS DISTINCT FROM v_moneda_padre THEN
        RAISE EXCEPTION 'Un reverso debe tener signo opuesto y conservar operación y moneda del pago original';
    END IF;

    SELECT COALESCE(sum(importe_menor), 0)
      INTO v_importe_revertido
      FROM iqg_core.pago
     WHERE company_id = NEW.company_id
       AND branch_id = NEW.branch_id
       AND pago_referencia_id = NEW.pago_referencia_id
       AND signo_impacto = -1;

    IF v_importe_revertido + NEW.importe_menor > v_importe_padre THEN
        RAISE EXCEPTION 'El total de reversos supera el importe del pago original';
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION iqg_core.tg_validar_movimiento_caja()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = iqg_core, pg_temp
AS $$
DECLARE
    v_moneda_caja varchar(3);
    v_moneda_operacion varchar(3);
    v_operacion_pago uuid;
    v_moneda_pago varchar(3);
    v_signo_pago smallint;
    v_importe_pago bigint;
BEGIN
    SELECT moneda_codigo
      INTO v_moneda_caja
      FROM iqg_core.caja
     WHERE company_id = NEW.company_id
       AND branch_id = NEW.branch_id
       AND caja_id = NEW.caja_id
     FOR KEY SHARE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La caja no existe en el alcance indicado';
    END IF;

    IF NEW.moneda_codigo IS DISTINCT FROM v_moneda_caja THEN
        RAISE EXCEPTION 'La moneda del movimiento debe coincidir con la moneda de la caja';
    END IF;

    IF NEW.operacion_id IS NOT NULL THEN
        SELECT moneda_codigo
          INTO v_moneda_operacion
          FROM iqg_core.operacion
         WHERE company_id = NEW.company_id
           AND branch_id = NEW.branch_id
           AND operacion_id = NEW.operacion_id
         FOR KEY SHARE;

        IF NOT FOUND OR NEW.moneda_codigo IS DISTINCT FROM v_moneda_operacion THEN
            RAISE EXCEPTION 'La operación vinculada no existe o usa otra moneda';
        END IF;
    END IF;

    IF NEW.pago_id IS NOT NULL THEN
        SELECT operacion_id, moneda_codigo, signo_impacto, importe_menor
          INTO v_operacion_pago, v_moneda_pago, v_signo_pago, v_importe_pago
          FROM iqg_core.pago
         WHERE company_id = NEW.company_id
           AND branch_id = NEW.branch_id
           AND pago_id = NEW.pago_id
         FOR KEY SHARE;

        IF NOT FOUND
           OR NEW.moneda_codigo IS DISTINCT FROM v_moneda_pago
           OR NEW.operacion_id IS DISTINCT FROM v_operacion_pago
           OR NEW.signo_impacto IS DISTINCT FROM v_signo_pago
           OR NEW.importe_menor IS DISTINCT FROM v_importe_pago THEN
            RAISE EXCEPTION 'El movimiento de caja vinculado debe conservar operación, moneda, signo e importe del pago';
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION iqg_core.tg_registrar_cambio()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = iqg_core, pg_temp
AS $$
DECLARE
    v_antes jsonb;
    v_despues jsonb;
    v_fila jsonb;
    v_company uuid;
    v_branch uuid;
    v_registro uuid;
BEGIN
    IF TG_OP = 'INSERT' THEN
        v_despues := to_jsonb(NEW);
        v_fila := v_despues;
    ELSIF TG_OP = 'UPDATE' THEN
        v_antes := to_jsonb(OLD);
        v_despues := to_jsonb(NEW);
        v_fila := v_despues;
    ELSE
        v_antes := to_jsonb(OLD);
        v_fila := v_antes;
    END IF;

    v_company := (v_fila ->> 'company_id')::uuid;
    v_branch := (v_fila ->> 'branch_id')::uuid;
    v_registro := (v_fila ->> TG_ARGV[0])::uuid;

    INSERT INTO iqg_core.registro_cambios (
        company_id,
        branch_id,
        creado_por_usuario_id,
        correlation_id,
        direccion_ip,
        actor_tipo_codigo,
        tabla_origen,
        operacion_dml,
        registro_id,
        motivo,
        datos_antes,
        datos_despues
    ) VALUES (
        v_company,
        v_branch,
        iqg_core.contexto_usuario_id(),
        iqg_core.contexto_correlation_id(),
        iqg_core.contexto_direccion_ip(),
        iqg_core.contexto_actor_tipo(),
        TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME,
        TG_OP,
        v_registro,
        iqg_core.contexto_motivo(),
        v_antes,
        v_despues
    );

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;
    RETURN NEW;
END;
$$;

-- Todas las filas reciben el sellado de identidad, contexto y fecha. Los
-- nombres de trigger ordenan el sellado antes de las reglas específicas.
CREATE TRIGGER trg_00_sellar_empresa BEFORE INSERT OR UPDATE ON iqg_core.empresa FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('company_id');
CREATE TRIGGER trg_00_sellar_sucursal BEFORE INSERT OR UPDATE ON iqg_core.sucursal FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('branch_id');
CREATE TRIGGER trg_00_sellar_usuario BEFORE INSERT OR UPDATE ON iqg_core.usuario FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('usuario_id');
CREATE TRIGGER trg_00_sellar_usuario_sucursal BEFORE INSERT OR UPDATE ON iqg_core.usuario_sucursal FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('usuario_sucursal_id');
CREATE TRIGGER trg_00_sellar_rol BEFORE INSERT OR UPDATE ON iqg_core.rol FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('rol_id');
CREATE TRIGGER trg_00_sellar_permiso BEFORE INSERT OR UPDATE ON iqg_core.permiso FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('permiso_id');
CREATE TRIGGER trg_00_sellar_rol_permiso BEFORE INSERT OR UPDATE ON iqg_core.rol_permiso FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('rol_permiso_id');
CREATE TRIGGER trg_00_sellar_usuario_rol BEFORE INSERT OR UPDATE ON iqg_core.usuario_rol FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('usuario_rol_id');
CREATE TRIGGER trg_00_sellar_elemento BEFORE INSERT OR UPDATE ON iqg_core.elemento FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('elemento_id');
CREATE TRIGGER trg_00_sellar_precio BEFORE INSERT OR UPDATE ON iqg_core.precio_vigente FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('precio_vigente_id');
CREATE TRIGGER trg_00_sellar_canal BEFORE INSERT OR UPDATE ON iqg_core.canal FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('canal_id');
CREATE TRIGGER trg_00_sellar_campania BEFORE INSERT OR UPDATE ON iqg_core.campania FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('campania_id');
CREATE TRIGGER trg_00_sellar_cliente BEFORE INSERT OR UPDATE ON iqg_core.cliente FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('cliente_id');
CREATE TRIGGER trg_00_sellar_estado BEFORE INSERT OR UPDATE ON iqg_core.estado FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('estado_id');
CREATE TRIGGER trg_00_sellar_operacion BEFORE INSERT OR UPDATE ON iqg_core.operacion FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('operacion_id');
CREATE TRIGGER trg_00_sellar_operacion_estado BEFORE INSERT OR UPDATE ON iqg_core.operacion_estado FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('operacion_estado_id');
CREATE TRIGGER trg_00_sellar_operacion_linea BEFORE INSERT OR UPDATE ON iqg_core.operacion_linea FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('operacion_linea_id');
CREATE TRIGGER trg_00_sellar_pago BEFORE INSERT OR UPDATE ON iqg_core.pago FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('pago_id');
CREATE TRIGGER trg_00_sellar_caja BEFORE INSERT OR UPDATE ON iqg_core.caja FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('caja_id');
CREATE TRIGGER trg_00_sellar_movimiento_caja BEFORE INSERT OR UPDATE ON iqg_core.movimiento_caja FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('movimiento_caja_id');
CREATE TRIGGER trg_00_sellar_grupo_movimiento BEFORE INSERT OR UPDATE ON iqg_core.grupo_movimiento FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('grupo_movimiento_id');
CREATE TRIGGER trg_00_sellar_movimiento BEFORE INSERT OR UPDATE ON iqg_core.movimiento FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('movimiento_id');
CREATE TRIGGER trg_00_sellar_registro_cambios BEFORE INSERT OR UPDATE ON iqg_core.registro_cambios FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('registro_cambio_id');

CREATE TRIGGER trg_01_sellar_fecha_operacion BEFORE INSERT OR UPDATE ON iqg_core.operacion FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_fecha_operacion();
CREATE TRIGGER trg_01_validar_precio BEFORE INSERT ON iqg_core.precio_vigente FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_precio_vigente();
CREATE TRIGGER trg_01_validar_operacion_linea BEFORE INSERT ON iqg_core.operacion_linea FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_operacion_linea();
CREATE TRIGGER trg_01_validar_pago BEFORE INSERT ON iqg_core.pago FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_pago();
CREATE TRIGGER trg_01_validar_movimiento_caja BEFORE INSERT ON iqg_core.movimiento_caja FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_movimiento_caja();
CREATE TRIGGER trg_01_bloquear_moneda_caja BEFORE UPDATE ON iqg_core.caja FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_cambio_moneda_caja();

-- Configuraciones se pueden ajustar con auditoría, pero no se eliminan.
CREATE TRIGGER trg_10_bloquear_delete_empresa BEFORE DELETE ON iqg_core.empresa FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();
CREATE TRIGGER trg_10_bloquear_delete_sucursal BEFORE DELETE ON iqg_core.sucursal FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();
CREATE TRIGGER trg_10_bloquear_delete_usuario BEFORE DELETE ON iqg_core.usuario FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();
CREATE TRIGGER trg_10_bloquear_delete_usuario_sucursal BEFORE DELETE ON iqg_core.usuario_sucursal FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();
CREATE TRIGGER trg_10_bloquear_delete_rol BEFORE DELETE ON iqg_core.rol FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();
CREATE TRIGGER trg_10_bloquear_delete_permiso BEFORE DELETE ON iqg_core.permiso FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();
CREATE TRIGGER trg_10_bloquear_delete_rol_permiso BEFORE DELETE ON iqg_core.rol_permiso FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();
CREATE TRIGGER trg_10_bloquear_delete_usuario_rol BEFORE DELETE ON iqg_core.usuario_rol FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();
CREATE TRIGGER trg_10_bloquear_delete_elemento BEFORE DELETE ON iqg_core.elemento FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();
CREATE TRIGGER trg_10_bloquear_delete_canal BEFORE DELETE ON iqg_core.canal FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();
CREATE TRIGGER trg_10_bloquear_delete_campania BEFORE DELETE ON iqg_core.campania FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();
CREATE TRIGGER trg_10_bloquear_delete_cliente BEFORE DELETE ON iqg_core.cliente FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();
CREATE TRIGGER trg_10_bloquear_delete_estado BEFORE DELETE ON iqg_core.estado FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();
CREATE TRIGGER trg_10_bloquear_delete_caja BEFORE DELETE ON iqg_core.caja FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();

-- Los hechos y el registro de auditoría no se reescriben bajo ninguna vía DML.
CREATE TRIGGER trg_10_append_only_precio BEFORE UPDATE OR DELETE ON iqg_core.precio_vigente FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_mutacion_append_only();
CREATE TRIGGER trg_10_append_only_operacion BEFORE UPDATE OR DELETE ON iqg_core.operacion FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_mutacion_append_only();
CREATE TRIGGER trg_10_append_only_operacion_estado BEFORE UPDATE OR DELETE ON iqg_core.operacion_estado FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_mutacion_append_only();
CREATE TRIGGER trg_10_append_only_operacion_linea BEFORE UPDATE OR DELETE ON iqg_core.operacion_linea FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_mutacion_append_only();
CREATE TRIGGER trg_10_append_only_pago BEFORE UPDATE OR DELETE ON iqg_core.pago FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_mutacion_append_only();
CREATE TRIGGER trg_10_append_only_movimiento_caja BEFORE UPDATE OR DELETE ON iqg_core.movimiento_caja FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_mutacion_append_only();
CREATE TRIGGER trg_10_append_only_grupo_movimiento BEFORE UPDATE OR DELETE ON iqg_core.grupo_movimiento FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_mutacion_append_only();
CREATE TRIGGER trg_10_append_only_movimiento BEFORE UPDATE OR DELETE ON iqg_core.movimiento FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_mutacion_append_only();
CREATE TRIGGER trg_10_append_only_registro_cambios BEFORE UPDATE OR DELETE ON iqg_core.registro_cambios FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_mutacion_append_only();

-- TRUNCATE no ejecuta triggers por fila; se bloquea de forma explícita en cada
-- tabla para que no se convierta en una vía de evasión de historia y auditoría.
DO $$
DECLARE
    v_tabla text;
BEGIN
    FOREACH v_tabla IN ARRAY ARRAY[
        'empresa', 'sucursal', 'usuario', 'usuario_sucursal', 'rol', 'permiso',
        'rol_permiso', 'usuario_rol', 'elemento', 'precio_vigente', 'canal',
        'campania', 'cliente', 'estado', 'operacion', 'operacion_estado',
        'operacion_linea', 'pago', 'caja', 'movimiento_caja',
        'grupo_movimiento', 'movimiento', 'registro_cambios'
    ] LOOP
        EXECUTE format(
            'CREATE TRIGGER %I BEFORE TRUNCATE ON iqg_core.%I FOR EACH STATEMENT '
            || 'EXECUTE FUNCTION iqg_core.tg_bloquear_truncate()',
            'trg_11_bloquear_truncate_' || v_tabla,
            v_tabla
        );
    END LOOP;
END;
$$;

-- Auditar cada DML exitoso de tablas de núcleo, sin recursión sobre la propia
-- bitácora. Intentos bloqueados revierten la transacción y requieren logging de
-- seguridad de la capa de acceso, que pertenece a IQG-001.2.
CREATE TRIGGER trg_90_auditar_empresa AFTER INSERT OR UPDATE OR DELETE ON iqg_core.empresa FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('company_id');
CREATE TRIGGER trg_90_auditar_sucursal AFTER INSERT OR UPDATE OR DELETE ON iqg_core.sucursal FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('branch_id');
CREATE TRIGGER trg_90_auditar_usuario AFTER INSERT OR UPDATE OR DELETE ON iqg_core.usuario FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('usuario_id');
CREATE TRIGGER trg_90_auditar_usuario_sucursal AFTER INSERT OR UPDATE OR DELETE ON iqg_core.usuario_sucursal FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('usuario_sucursal_id');
CREATE TRIGGER trg_90_auditar_rol AFTER INSERT OR UPDATE OR DELETE ON iqg_core.rol FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('rol_id');
CREATE TRIGGER trg_90_auditar_permiso AFTER INSERT OR UPDATE OR DELETE ON iqg_core.permiso FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('permiso_id');
CREATE TRIGGER trg_90_auditar_rol_permiso AFTER INSERT OR UPDATE OR DELETE ON iqg_core.rol_permiso FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('rol_permiso_id');
CREATE TRIGGER trg_90_auditar_usuario_rol AFTER INSERT OR UPDATE OR DELETE ON iqg_core.usuario_rol FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('usuario_rol_id');
CREATE TRIGGER trg_90_auditar_elemento AFTER INSERT OR UPDATE OR DELETE ON iqg_core.elemento FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('elemento_id');
CREATE TRIGGER trg_90_auditar_precio AFTER INSERT OR UPDATE OR DELETE ON iqg_core.precio_vigente FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('precio_vigente_id');
CREATE TRIGGER trg_90_auditar_canal AFTER INSERT OR UPDATE OR DELETE ON iqg_core.canal FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('canal_id');
CREATE TRIGGER trg_90_auditar_campania AFTER INSERT OR UPDATE OR DELETE ON iqg_core.campania FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('campania_id');
CREATE TRIGGER trg_90_auditar_cliente AFTER INSERT OR UPDATE OR DELETE ON iqg_core.cliente FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('cliente_id');
CREATE TRIGGER trg_90_auditar_estado AFTER INSERT OR UPDATE OR DELETE ON iqg_core.estado FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('estado_id');
CREATE TRIGGER trg_90_auditar_operacion AFTER INSERT OR UPDATE OR DELETE ON iqg_core.operacion FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('operacion_id');
CREATE TRIGGER trg_90_auditar_operacion_estado AFTER INSERT OR UPDATE OR DELETE ON iqg_core.operacion_estado FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('operacion_estado_id');
CREATE TRIGGER trg_90_auditar_operacion_linea AFTER INSERT OR UPDATE OR DELETE ON iqg_core.operacion_linea FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('operacion_linea_id');
CREATE TRIGGER trg_90_auditar_pago AFTER INSERT OR UPDATE OR DELETE ON iqg_core.pago FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('pago_id');
CREATE TRIGGER trg_90_auditar_caja AFTER INSERT OR UPDATE OR DELETE ON iqg_core.caja FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('caja_id');
CREATE TRIGGER trg_90_auditar_movimiento_caja AFTER INSERT OR UPDATE OR DELETE ON iqg_core.movimiento_caja FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('movimiento_caja_id');
CREATE TRIGGER trg_90_auditar_grupo_movimiento AFTER INSERT OR UPDATE OR DELETE ON iqg_core.grupo_movimiento FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('grupo_movimiento_id');
CREATE TRIGGER trg_90_auditar_movimiento AFTER INSERT OR UPDATE OR DELETE ON iqg_core.movimiento FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('movimiento_id');

-- Precio efectivo: valid_to puede haber sido declarado al crear la fila. Si un
-- sucesor existe, su valid_from cierra lógicamente al anterior sin modificarlo.
-- security_invoker conserva las políticas RLS del lector de la vista.
CREATE VIEW iqg_core.v_precio_vigencia
WITH (security_invoker = true)
AS
SELECT
    p.precio_vigente_id,
    p.company_id,
    p.branch_id,
    p.elemento_id,
    p.moneda_codigo,
    p.importe_menor,
    p.valid_from,
    CASE
        WHEN p.valid_to IS NULL THEN sucesor.valid_from
        WHEN sucesor.valid_from IS NULL THEN p.valid_to
        WHEN p.valid_to <= sucesor.valid_from THEN p.valid_to
        ELSE sucesor.valid_from
    END AS valid_to_efectivo,
    p.reemplaza_precio_vigente_id,
    p.fecha_creacion
FROM iqg_core.precio_vigente AS p
LEFT JOIN iqg_core.precio_vigente AS sucesor
    ON sucesor.company_id = p.company_id
   AND sucesor.branch_id = p.branch_id
   AND sucesor.reemplaza_precio_vigente_id = p.precio_vigente_id;

CREATE VIEW iqg_core.v_precio_actual
WITH (security_invoker = true)
AS
SELECT *
FROM iqg_core.v_precio_vigencia
WHERE valid_from <= statement_timestamp()
  AND (valid_to_efectivo IS NULL OR valid_to_efectivo > statement_timestamp());

-- RLS aplica company_id + branch_id a TODAS las tablas. La política es una
-- defensa adicional; IQG-001.2 debe validar que el contexto proviene de una
-- identidad autenticada y que su membresía/rol permite la acción solicitada.
DO $$
DECLARE
    v_tabla text;
BEGIN
    FOREACH v_tabla IN ARRAY ARRAY[
        'sucursal', 'usuario_sucursal', 'rol', 'permiso', 'rol_permiso',
        'usuario_rol', 'elemento', 'precio_vigente', 'canal',
        'campania', 'cliente', 'estado', 'operacion', 'operacion_estado',
        'operacion_linea', 'pago', 'caja', 'movimiento_caja',
        'grupo_movimiento', 'movimiento', 'registro_cambios'
    ] LOOP
        EXECUTE format('ALTER TABLE iqg_core.%I ENABLE ROW LEVEL SECURITY', v_tabla);
        EXECUTE format('ALTER TABLE iqg_core.%I FORCE ROW LEVEL SECURITY', v_tabla);
        EXECUTE format(
            'CREATE POLICY %I ON iqg_core.%I FOR ALL TO PUBLIC '
            || 'USING (company_id = iqg_core.contexto_company_id() '
            || 'AND branch_id = iqg_core.contexto_branch_id()) '
            || 'WITH CHECK (company_id = iqg_core.contexto_company_id() '
            || 'AND branch_id = iqg_core.contexto_branch_id())',
            'p_aislamiento_' || v_tabla,
            v_tabla
        );
    END LOOP;
END;
$$;

-- empresa y usuario son identidades corporativas ancladas físicamente a una
-- sucursal de origen para cumplir el contrato de alcance. Se leen dentro de
-- cualquier sucursal activa del mismo company; escribirlos exige la sucursal
-- de origen. IQG-001.2 debe verificar que el contexto pertenezca de verdad a
-- una membresía activa antes de conceder acceso a un rol de aplicación.
ALTER TABLE iqg_core.empresa ENABLE ROW LEVEL SECURITY;
ALTER TABLE iqg_core.empresa FORCE ROW LEVEL SECURITY;
CREATE POLICY p_aislamiento_empresa ON iqg_core.empresa FOR ALL TO PUBLIC
    USING (
        company_id = iqg_core.contexto_company_id()
        AND iqg_core.contexto_branch_id() IS NOT NULL
    )
    WITH CHECK (
        company_id = iqg_core.contexto_company_id()
        AND branch_id = iqg_core.contexto_branch_id()
    );

ALTER TABLE iqg_core.usuario ENABLE ROW LEVEL SECURITY;
ALTER TABLE iqg_core.usuario FORCE ROW LEVEL SECURITY;
CREATE POLICY p_aislamiento_usuario ON iqg_core.usuario FOR ALL TO PUBLIC
    USING (
        company_id = iqg_core.contexto_company_id()
        AND iqg_core.contexto_branch_id() IS NOT NULL
    )
    WITH CHECK (
        company_id = iqg_core.contexto_company_id()
        AND branch_id = iqg_core.contexto_branch_id()
    );

-- Única ruta de bootstrap de este esquema. Genera el actor inicial antes de
-- insertar y conserva company_id + branch_id + usuario en todas las filas. La
-- función no se concede a PUBLIC ni al futuro rol de aplicación.
CREATE OR REPLACE FUNCTION iqg_core.provisionar_empresa(
    p_nombre_legal text,
    p_moneda_predeterminada varchar(3),
    p_codigo_sucursal varchar(64),
    p_nombre_sucursal text,
    p_zona_horaria text,
    p_identificador_identidad text,
    p_nombre_usuario text,
    p_usuario_id uuid DEFAULT gen_random_uuid(),
    p_correo_electronico text DEFAULT NULL
)
RETURNS TABLE (company_id uuid, branch_id uuid, usuario_id uuid)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = iqg_core, pg_temp
AS $$
DECLARE
    v_company_id uuid := gen_random_uuid();
    v_branch_id uuid := gen_random_uuid();
    v_usuario_id uuid := p_usuario_id;
BEGIN
    IF p_nombre_legal IS NULL
       OR p_moneda_predeterminada IS NULL
       OR p_codigo_sucursal IS NULL
       OR p_nombre_sucursal IS NULL
       OR p_zona_horaria IS NULL
       OR p_identificador_identidad IS NULL
       OR p_nombre_usuario IS NULL
       OR v_usuario_id IS NULL THEN
        RAISE EXCEPTION 'La provisión requiere datos de empresa, sucursal e identidad inicial';
    END IF;

    -- El contexto vive solo en la transacción actual y coincide con los UUID
    -- nuevos antes de que las políticas RLS permitan escribir las filas.
    PERFORM set_config('iqg.company_id', v_company_id::text, true);
    PERFORM set_config('iqg.branch_id', v_branch_id::text, true);
    PERFORM set_config('iqg.usuario_id', v_usuario_id::text, true);
    PERFORM set_config('iqg.actor_tipo', 'SISTEMA', true);
    PERFORM set_config('iqg.motivo_cambio', 'PROVISION_INICIAL', true);
    INSERT INTO iqg_core.empresa (
        company_id, branch_id, creado_por_usuario_id,
        nombre_legal, moneda_predeterminada
    ) VALUES (
        v_company_id, v_branch_id, v_usuario_id,
        p_nombre_legal, p_moneda_predeterminada
    );

    INSERT INTO iqg_core.sucursal (
        company_id, branch_id, creado_por_usuario_id,
        codigo, nombre, zona_horaria, moneda_predeterminada
    ) VALUES (
        v_company_id, v_branch_id, v_usuario_id,
        p_codigo_sucursal, p_nombre_sucursal, p_zona_horaria, p_moneda_predeterminada
    );

    INSERT INTO iqg_core.usuario (
        usuario_id, company_id, branch_id, creado_por_usuario_id,
        identificador_identidad, nombre_mostrar, correo_electronico
    ) VALUES (
        v_usuario_id, v_company_id, v_branch_id, v_usuario_id,
        p_identificador_identidad, p_nombre_usuario, p_correo_electronico
    );

    INSERT INTO iqg_core.usuario_sucursal (
        company_id, branch_id, creado_por_usuario_id, usuario_id
    ) VALUES (
        v_company_id, v_branch_id, v_usuario_id, v_usuario_id
    );

    RETURN QUERY SELECT v_company_id, v_branch_id, v_usuario_id;
END;
$$;

-- El rol de aplicación futuro debe recibir únicamente privilegios mínimos a
-- través de una capa de dominio. IQG-001.2 debe otorgar EXECUTE solo a los
-- helpers contexto_* al rol de aplicación nombrado; PUBLIC no puede mutar,
-- truncar ni invocar sellado, auditoría ni provisión directamente.
REVOKE ALL ON ALL TABLES IN SCHEMA iqg_core FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA iqg_core FROM PUBLIC;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA iqg_core FROM PUBLIC;

COMMENT ON SCHEMA iqg_core IS
    'Núcleo universal IQ GROWTH: alcance company/branch, historia temporal y auditoría.';
COMMENT ON TABLE iqg_core.precio_vigente IS
    'Libro append-only de precios. Cambiar precio inserta un sucesor, no actualiza la fila anterior.';
COMMENT ON TABLE iqg_core.registro_cambios IS
    'Bitácora DML append-only. No guarda credenciales; su acceso queda protegido por RLS y privilegios mínimos.';
COMMENT ON TABLE iqg_core.movimiento IS
    'Libro inmutable de cantidades y costos; los saldos se derivan y no son fuente de verdad mutable.';

COMMIT;
