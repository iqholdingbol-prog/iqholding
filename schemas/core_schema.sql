-- =============================================================================
-- IQ GROWTH — Núcleo Universal: esquema relacional de referencia
-- Ticket: IQG-001.2
-- Estado: diseño ejecutable para auditoría; no ejecutar contra datos productivos.
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
--   6. registro_cambios registra DML exitoso y no puede actualizarse ni borrarse,
--      salvo la redacción criptográfica única, legal y trazable de PII operativa.
--   7. RLS falla cerrada cuando no existe un contexto empresa/sucursal válido.
--
-- Bootstrap: empresa y sucursal forman un ciclo deliberado para que también
-- tengan company_id + branch_id. El alta inicial debe ejecutarse en una única
-- transacción privilegiada con las FKs diferibles, nunca desde un cliente.
-- =============================================================================

BEGIN;

-- PHASE 1 — instalación del Core por base de datos. La topología global de
-- roles se establece antes, y exclusivamente, por schemas/bootstrap_roles.sql
-- (PHASE 0). PRIVILEGED_BOOTSTRAP_PRINCIPAL es una capacidad de despliegue,
-- no un nombre de usuario, un rol IQG ni una identidad de runtime. PostgreSQL
-- acepta SET para cualquier placeholder personalizado de dos partes (por
-- ejemplo, iqg.company_id); por tanto, iqg.* nunca es identidad ni autorización
-- por sí misma. iqg_app no recibe acceso directo a relaciones o funciones de
-- dominio mientras no exista un gateway revisado.
DO $phase1_preflight$
BEGIN
    IF current_user <> session_user THEN
        RAISE EXCEPTION
            'PHASE 1 debe comenzar como session_user, sin SET ROLE activo';
    END IF;

    IF current_user IN ('iqg_owner', 'iqg_app', 'iqg_gateway', 'iqg_bootstrap_invoker') THEN
        RAISE EXCEPTION
            'PRIVILEGED_BOOTSTRAP_PRINCIPAL debe ser independiente de los roles IQG';
    END IF;

    IF (SELECT count(*)
          FROM pg_roles
         WHERE rolname IN ('iqg_owner', 'iqg_app', 'iqg_gateway', 'iqg_bootstrap_invoker')) <> 4
       OR EXISTS (
            SELECT 1
              FROM pg_roles
             WHERE rolname IN ('iqg_owner', 'iqg_app', 'iqg_gateway', 'iqg_bootstrap_invoker')
               AND (rolsuper OR rolbypassrls OR rolcanlogin OR rolcreatedb
                    OR rolcreaterole OR rolreplication OR rolinherit)
       ) THEN
        RAISE EXCEPTION
            'PHASE 1 requiere una topología PHASE 0 de roles IQG endurecida';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM pg_auth_members AS membership
         WHERE membership.roleid = 'iqg_owner'::regrole
    ) THEN
        RAISE EXCEPTION 'PHASE 1 requiere iqg_owner con ZERO MEMBERS';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM pg_auth_members AS membership
         WHERE membership.member IN (
                'iqg_owner'::regrole,
                'iqg_app'::regrole,
                'iqg_gateway'::regrole,
                'iqg_bootstrap_invoker'::regrole
            )
    ) THEN
        RAISE EXCEPTION
            'PHASE 1 detectó que un rol IQG hereda o puede asumir otro rol';
    END IF;
END;
$phase1_preflight$;

-- PHASE 1 no es una migración genérica sobre schemas IQG ya poblados. Puede
-- corregir el owner de un schema vacío sin ACL explícita, pero se niega a
-- absorber privilegios u objetos heredados: ALTER SCHEMA OWNER no elimina una
-- ACL explícita del dueño anterior y un default ACL de iqg_owner podría abrir
-- objetos SECURITY DEFINER creados más abajo.
DO $phase1_existing_schema_preflight$
BEGIN
    IF EXISTS (
        SELECT 1
          FROM pg_catalog.pg_namespace AS schema_iqg
         WHERE schema_iqg.nspname IN ('iqg_core', 'iqg_fiscal')
           AND (
               schema_iqg.nspacl IS NOT NULL
               OR EXISTS (
                   SELECT 1
                     FROM pg_catalog.pg_depend AS dependency
                    WHERE dependency.refclassid = 'pg_catalog.pg_namespace'::regclass
                      AND dependency.refobjid = schema_iqg.oid
               )
               OR EXISTS (
                   SELECT 1
                     FROM pg_catalog.pg_extension AS extension_iqg
                    WHERE extension_iqg.extnamespace = schema_iqg.oid
               )
               OR EXISTS (
                   SELECT 1
                     FROM pg_catalog.pg_publication_namespace AS publication_namespace
                    WHERE publication_namespace.pnnspid = schema_iqg.oid
               )
               OR EXISTS (
                   SELECT 1
                     FROM pg_catalog.pg_default_acl AS default_acl
                    WHERE default_acl.defaclnamespace = schema_iqg.oid
               )
           )
    ) THEN
        RAISE EXCEPTION USING
            ERRCODE = 'P0001',
            MESSAGE = 'PHASE1_UNSAFE_EXISTING_SCHEMA_STATE: iqg_core o iqg_fiscal existente contiene ACL, default ACL u objetos; se requiere una migración revisada';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM pg_catalog.pg_default_acl AS default_acl
         WHERE (
                   default_acl.defaclrole = 'iqg_owner'::regrole
                   AND default_acl.defaclnamespace = 0
               )
            OR default_acl.defaclnamespace IN (
                SELECT oid
                  FROM pg_catalog.pg_namespace
                 WHERE nspname IN ('iqg_core', 'iqg_fiscal')
            )
    ) THEN
        RAISE EXCEPTION USING
            ERRCODE = 'P0001',
            MESSAGE = 'PHASE1_UNSAFE_EXISTING_SCHEMA_STATE: iqg_owner conserva default ACL previo; se requiere una migración revisada';
    END IF;
END;
$phase1_existing_schema_preflight$;

-- iqg_core es la capa operativa privada; iqg_fiscal es la capa jurídica
-- separada. Solo el principal de despliegue crea y entrega ownership de estos
-- schemas. Si no puede hacerlo, la transacción falla cerrada antes de crear
-- objetos de negocio.
DO $phase1_schema_ownership$
BEGIN
    BEGIN
        EXECUTE 'CREATE SCHEMA IF NOT EXISTS iqg_core AUTHORIZATION iqg_owner';
        EXECUTE 'ALTER SCHEMA iqg_core OWNER TO iqg_owner';
        EXECUTE 'CREATE SCHEMA IF NOT EXISTS iqg_fiscal AUTHORIZATION iqg_owner';
        EXECUTE 'ALTER SCHEMA iqg_fiscal OWNER TO iqg_owner';
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE EXCEPTION USING
                ERRCODE = '42501',
                MESSAGE = 'DEPLOYMENT_CAPABILITY_INCOMPATIBLE: PRIVILEGED_BOOTSTRAP_PRINCIPAL no puede crear y asignar ownership de los schemas IQG';
    END;
END;
$phase1_schema_ownership$;

-- La prueba de capacidad queda dentro de la transacción. No se otorga una
-- membresía a iqg_owner: un principal insuficiente revierte los schemas recién
-- creados y no deja objetos del Core.
DO $phase1_owner_capability$
BEGIN
    BEGIN
        EXECUTE 'SET LOCAL ROLE iqg_owner';
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE EXCEPTION USING
                ERRCODE = '42501',
                MESSAGE = 'DEPLOYMENT_CAPABILITY_INCOMPATIBLE: PRIVILEGED_BOOTSTRAP_PRINCIPAL no puede asumir iqg_owner durante PHASE 1';
    END;

    IF current_user <> 'iqg_owner' THEN
        RAISE EXCEPTION
            'DEPLOYMENT_CAPABILITY_INCOMPATIBLE: SET LOCAL ROLE no asumió iqg_owner durante PHASE 1';
    END IF;

    RESET ROLE;
END;
$phase1_owner_capability$;

-- PHASE 1_OBJECT_DDL_START: a partir de aquí todo objeto del Core se crea
-- como iqg_owner. Las migraciones estructurales futuras requieren una decisión
-- separada de capacidad mínima; este instalador no es un framework de DDL
-- arbitrario sobre una base ya poblada.
SET LOCAL ROLE iqg_owner;

REVOKE ALL ON SCHEMA iqg_core FROM PUBLIC, iqg_app, iqg_gateway, iqg_bootstrap_invoker;
REVOKE CREATE ON SCHEMA iqg_core FROM PUBLIC, iqg_app, iqg_gateway, iqg_bootstrap_invoker;
REVOKE ALL ON SCHEMA iqg_fiscal FROM PUBLIC, iqg_app, iqg_gateway, iqg_bootstrap_invoker;
REVOKE CREATE ON SCHEMA iqg_fiscal FROM PUBLIC, iqg_app, iqg_gateway, iqg_bootstrap_invoker;
-- El EXECUTE público predeterminado de funciones es global por owner; una
-- revocación limitada al schema no lo elimina en PostgreSQL.
ALTER DEFAULT PRIVILEGES
    REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
ALTER DEFAULT PRIVILEGES
    REVOKE USAGE ON TYPES FROM PUBLIC;

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

CREATE OR REPLACE FUNCTION iqg_core.contexto_motivo_codigo()
RETURNS varchar
LANGUAGE sql
STABLE
AS $$
    SELECT NULLIF(upper(current_setting('iqg.motivo_codigo', true)), '');
$$;

CREATE OR REPLACE FUNCTION iqg_core.contexto_correlation_id()
RETURNS uuid
LANGUAGE sql
STABLE
AS $$
    SELECT NULLIF(current_setting('iqg.correlation_id', true), '')::uuid;
$$;

CREATE OR REPLACE FUNCTION iqg_core.contexto_direccion_ip_cifrada()
RETURNS bytea
LANGUAGE sql
STABLE
AS $$
    SELECT CASE
        WHEN NULLIF(current_setting('iqg.direccion_ip_cifrada', true), '') IS NULL THEN NULL
        ELSE decode(current_setting('iqg.direccion_ip_cifrada', true), 'hex')
    END;
$$;

CREATE OR REPLACE FUNCTION iqg_core.contexto_direccion_ip_clave_referencia()
RETURNS uuid
LANGUAGE sql
STABLE
AS $$
    SELECT NULLIF(current_setting('iqg.direccion_ip_clave_referencia', true), '')::uuid;
$$;

CREATE OR REPLACE FUNCTION iqg_core.contexto_direccion_ip_version_sobre()
RETURNS smallint
LANGUAGE sql
STABLE
AS $$
    SELECT NULLIF(current_setting('iqg.direccion_ip_version_sobre', true), '')::smallint;
$$;

-- Formato canónico de sobre: versión(1 byte)=1 || nonce GCM(12) || tag GCM(16)
-- || ciphertext(no vacío). Esta validación solo comprueba la forma mínima; el
-- agente criptográfico del titular cifra AES-256-GCM y verifica la AAD fuera de
-- PostgreSQL. La base nunca recibe ni almacena material de clave.
CREATE OR REPLACE FUNCTION iqg_core.es_sobre_cifrado_aes_256_gcm(p_sobre bytea)
RETURNS boolean
LANGUAGE sql
IMMUTABLE
PARALLEL SAFE
AS $$
    SELECT p_sobre IS NOT NULL
       AND octet_length(p_sobre) >= 30
       AND get_byte(p_sobre, 0) = 1;
$$;

-- Estas dos marcas se usan únicamente por provisionar_empresa para resolver
-- reintentos antes de conocer el company_id. No se conceden a iqg_app.
CREATE OR REPLACE FUNCTION iqg_core.contexto_provisionamiento_origen()
RETURNS varchar
LANGUAGE sql
STABLE
AS $$
    SELECT NULLIF(current_setting('iqg.provisionamiento_origen', true), '');
$$;

CREATE OR REPLACE FUNCTION iqg_core.contexto_provisionamiento_clave()
RETURNS uuid
LANGUAGE sql
STABLE
AS $$
    SELECT NULLIF(current_setting('iqg.provisionamiento_clave', true), '')::uuid;
$$;

-- Excepción estrecha para el único bootstrap transaccional. Antes de existir
-- usuario_sucursal aún no puede verificarse una membresía. `iqg.*` es
-- falsificable por cualquier sesión SQL, así que la condición exige además una
-- capacidad de cluster no derivable de GUC: la identidad ORIGINAL de conexión
-- debe ser miembro de iqg_bootstrap_invoker. session_user no cambia al entrar
-- en SECURITY DEFINER; current_user sí cambia a iqg_owner y por eso nunca se
-- usa como autenticación del invocador. La capacidad no recibe tablas,
-- secuencias, helpers ni acceso fiscal; al final del DDL obtiene solamente
-- USAGE operativo y EXECUTE de la firma de alta revisada.
CREATE OR REPLACE FUNCTION iqg_core.contexto_bootstrap_activo()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = iqg_core, pg_temp
AS $$
    SELECT EXISTS (
            SELECT 1
              FROM pg_auth_members AS m
             WHERE m.roleid = 'iqg_bootstrap_invoker'::regrole
               AND m.member = session_user::regrole
               AND NOT m.admin_option
               AND m.inherit_option
               AND NOT m.set_option
       )
       AND NOT EXISTS (
            SELECT 1
              FROM pg_auth_members AS m
             WHERE m.roleid = 'iqg_owner'::regrole
               AND m.member = session_user::regrole
       )
       AND NOT EXISTS (
            SELECT 1
              FROM pg_roles AS r
             WHERE r.rolname = session_user
               AND (r.rolsuper OR r.rolbypassrls OR NOT r.rolcanlogin)
       )
       AND iqg_core.contexto_company_id() IS NOT NULL
       AND iqg_core.contexto_branch_id() IS NOT NULL
       AND iqg_core.contexto_usuario_id() IS NOT NULL
       AND iqg_core.contexto_provisionamiento_origen() IS NOT NULL
       AND iqg_core.contexto_provisionamiento_clave() IS NOT NULL;
$$;

-- -----------------------------------------------------------------------------
-- Identidad, empresa y sucursal
-- -----------------------------------------------------------------------------

CREATE TABLE iqg_core.empresa (
    company_id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_id                   uuid NOT NULL DEFAULT gen_random_uuid(),
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    -- Sobres de PII emitidos por el agente criptográfico del titular. Ninguna
    -- clave, passphrase, KMS URI autenticada ni texto claro existe en SQL.
    nombre_legal_cifrado        bytea NOT NULL,
    nombre_mostrar_cifrado      bytea NULL,
    identificador_fiscal_cifrado bytea NULL,
    referencia_clave_operativa_externa uuid NOT NULL,
    version_sobre_cifrado       smallint NOT NULL DEFAULT 1,
    algoritmo_cifrado           varchar(32) NOT NULL DEFAULT 'AES_256_GCM',
    pais_codigo                 char(2) NOT NULL,
    regimen_fiscal_codigo       varchar(64) NULL,
    esta_obligado_a_facturar    boolean NOT NULL DEFAULT false,
    facturacion_fiscal_voluntaria boolean NOT NULL DEFAULT false,
    facturacion_fiscal_activa   boolean GENERATED ALWAYS AS (
        esta_obligado_a_facturar OR facturacion_fiscal_voluntaria
    ) STORED,
    perfil_privacidad_codigo    varchar(64) NOT NULL DEFAULT 'GENERAL_MINIMIZADO',
    perfil_aad_cifrado_codigo   varchar(64) NOT NULL DEFAULT 'GENERAL_AAD_TENANT_ESTRICTO',
    minimiza_recoleccion_pii    boolean NOT NULL DEFAULT true,
    version_politica_privacidad varchar(64) NOT NULL DEFAULT 'IQG_PRIVACIDAD_V1',
    retencion_fiscal_anios      smallint NOT NULL DEFAULT 0,
    version_regla_fiscal        varchar(64) NULL,
    determinado_fiscalmente_en  timestamptz NULL,
    moneda_predeterminada       varchar(3) NOT NULL,
    activo                      boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_empresa_company_branch UNIQUE (company_id, branch_id),
    CONSTRAINT ck_empresa_moneda CHECK (moneda_predeterminada ~ '^[A-Z]{3}$'),
    CONSTRAINT ck_empresa_sobres_operativos CHECK (
        iqg_core.es_sobre_cifrado_aes_256_gcm(nombre_legal_cifrado)
        AND (nombre_mostrar_cifrado IS NULL
             OR iqg_core.es_sobre_cifrado_aes_256_gcm(nombre_mostrar_cifrado))
        AND (identificador_fiscal_cifrado IS NULL
             OR iqg_core.es_sobre_cifrado_aes_256_gcm(identificador_fiscal_cifrado))
        AND version_sobre_cifrado > 0
        AND algoritmo_cifrado = 'AES_256_GCM'
    ),
    CONSTRAINT ck_empresa_pais CHECK (pais_codigo ~ '^[A-Z]{2}$'),
    CONSTRAINT ck_empresa_perfil_privacidad CHECK (
        (pais_codigo = 'BO'
         AND perfil_privacidad_codigo = 'BOLIVIA_REFORZADA_MINIMA'
         AND perfil_aad_cifrado_codigo = 'BO_AAD_TENANT_COLUMNA_ESTRICTO'
         AND minimiza_recoleccion_pii)
        OR (pais_codigo = 'PE'
            AND perfil_privacidad_codigo = 'PERU_RESERVA_TRIBUTARIA'
            AND perfil_aad_cifrado_codigo = 'PE_AAD_TENANT_COLUMNA_ESTRICTO'
            AND minimiza_recoleccion_pii)
        OR (pais_codigo = 'BR'
            AND perfil_privacidad_codigo = 'BRASIL_SIGILO_FISCAL'
            AND perfil_aad_cifrado_codigo = 'BR_AAD_TENANT_COLUMNA_ESTRICTO'
            AND minimiza_recoleccion_pii)
        OR (pais_codigo = 'AR'
            AND perfil_privacidad_codigo = 'ARGENTINA_SECRETO_FISCAL'
            AND perfil_aad_cifrado_codigo = 'AR_AAD_TENANT_COLUMNA_ESTRICTO'
            AND minimiza_recoleccion_pii)
        OR (pais_codigo NOT IN ('BO', 'PE', 'BR', 'AR')
            AND perfil_privacidad_codigo = 'GENERAL_MINIMIZADO'
            AND perfil_aad_cifrado_codigo = 'GENERAL_AAD_TENANT_ESTRICTO'
            AND minimiza_recoleccion_pii)
    ),
    CONSTRAINT ck_empresa_version_politica_privacidad CHECK (
        version_politica_privacidad ~ '^[A-Z][A-Z0-9_]{0,63}$'
    ),
    CONSTRAINT ck_empresa_regimen_fiscal CHECK (
        NOT facturacion_fiscal_activa
        OR (
            regimen_fiscal_codigo ~ '^[A-Z][A-Z0-9_]{0,63}$'
            AND identificador_fiscal_cifrado IS NOT NULL
            AND version_regla_fiscal IS NOT NULL
            AND determinado_fiscalmente_en IS NOT NULL
        )
    ),
    CONSTRAINT ck_empresa_retencion_fiscal CHECK (
        (facturacion_fiscal_activa AND retencion_fiscal_anios IN (5, 10))
        OR (NOT facturacion_fiscal_activa AND retencion_fiscal_anios = 0)
    )
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

-- usuario no almacena credenciales ni PII en claro. La identidad autenticada
-- vive fuera del núcleo y sus sobres se cifran por columna en el agente del
-- titular. No se configura un índice ciego por defecto: una búsqueda de PII
-- requiere un ADR criptográfico y un token opaco externo específico.
CREATE TABLE iqg_core.usuario (
    usuario_id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                  uuid NOT NULL,
    branch_id                   uuid NOT NULL,
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    identificador_identidad_cifrado bytea NOT NULL,
    nombre_mostrar_cifrado      bytea NOT NULL,
    correo_electronico_cifrado  bytea NULL,
    referencia_clave_operativa_externa uuid NOT NULL,
    version_sobre_cifrado       smallint NOT NULL DEFAULT 1,
    algoritmo_cifrado           varchar(32) NOT NULL DEFAULT 'AES_256_GCM',
    activo                      boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_usuario_scope UNIQUE (company_id, branch_id, usuario_id),
    CONSTRAINT uq_usuario_company_id UNIQUE (company_id, usuario_id),
    CONSTRAINT ck_usuario_sobres_operativos CHECK (
        iqg_core.es_sobre_cifrado_aes_256_gcm(identificador_identidad_cifrado)
        AND iqg_core.es_sobre_cifrado_aes_256_gcm(nombre_mostrar_cifrado)
        AND (correo_electronico_cifrado IS NULL
             OR iqg_core.es_sobre_cifrado_aes_256_gcm(correo_electronico_cifrado))
        AND version_sobre_cifrado > 0
        AND algoritmo_cifrado = 'AES_256_GCM'
    ),
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

-- Reserva global de idempotencia para el alta de un tenant. Se inserta antes
-- de crear la empresa y sus FKs diferibles se verifican al final de la misma
-- transacción; así un reintento concurrente no puede generar otro tenant.
CREATE TABLE iqg_core.provisionamiento_empresa (
    provisionamiento_empresa_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                  uuid NOT NULL,
    branch_id                   uuid NOT NULL,
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    origen_idempotencia         varchar(64) NOT NULL,
    clave_idempotencia          uuid NOT NULL,
    CONSTRAINT uq_provisionamiento_empresa_scope
        UNIQUE (company_id, branch_id, provisionamiento_empresa_id),
    CONSTRAINT uq_provisionamiento_empresa_idempotencia
        UNIQUE (origen_idempotencia, clave_idempotencia),
    CONSTRAINT ck_provisionamiento_empresa_origen
        CHECK (origen_idempotencia ~ '^[A-Z][A-Z0-9_]{0,63}$'),
    CONSTRAINT fk_provisionamiento_empresa_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        DEFERRABLE INITIALLY DEFERRED
);

-- Los roles y permisos son corporativos. branch_id se conserva por el
-- invariante universal y registra la sucursal de origen, pero no fragmenta la
-- definición ni la matriz de permisos de una empresa.
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
    CONSTRAINT uq_rol_company UNIQUE (company_id, rol_id),
    CONSTRAINT uq_rol_codigo UNIQUE (company_id, codigo),
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
    CONSTRAINT uq_permiso_company UNIQUE (company_id, permiso_id),
    CONSTRAINT uq_permiso_recurso_accion UNIQUE (company_id, recurso_codigo, accion_codigo),
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
    CONSTRAINT uq_rol_permiso_company UNIQUE (company_id, rol_permiso_id),
    CONSTRAINT uq_rol_permiso_asignacion UNIQUE (company_id, rol_id, permiso_id),
    CONSTRAINT fk_rol_permiso_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_rol_permiso_rol
        FOREIGN KEY (company_id, rol_id)
        REFERENCES iqg_core.rol (company_id, rol_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_rol_permiso_permiso
        FOREIGN KEY (company_id, permiso_id)
        REFERENCES iqg_core.permiso (company_id, permiso_id)
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
        FOREIGN KEY (company_id, rol_id)
        REFERENCES iqg_core.rol (company_id, rol_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

-- -----------------------------------------------------------------------------
-- Catálogos corporativos de dominio. Los consumidores se validan mediante
-- triggers contra dominio_valor activo de la misma empresa; no se repite una
-- columna de dominio artificial en cada tabla de negocio.
CREATE TABLE iqg_core.dominio (
    dominio_id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                  uuid NOT NULL,
    branch_id                   uuid NOT NULL,
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    codigo                      varchar(64) NOT NULL,
    nombre                      text NOT NULL,
    descripcion                 text NULL,
    activo                      boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_dominio_scope UNIQUE (company_id, branch_id, dominio_id),
    CONSTRAINT uq_dominio_company UNIQUE (company_id, dominio_id),
    CONSTRAINT uq_dominio_codigo UNIQUE (company_id, codigo),
    CONSTRAINT ck_dominio_codigo CHECK (codigo ~ '^[A-Z][A-Z0-9_]{0,63}$'),
    CONSTRAINT fk_dominio_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

CREATE TABLE iqg_core.dominio_valor (
    dominio_valor_id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                  uuid NOT NULL,
    branch_id                   uuid NOT NULL,
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    dominio_codigo              varchar(64) NOT NULL,
    codigo                      varchar(64) NOT NULL,
    nombre                      text NOT NULL,
    descripcion                 text NULL,
    activo                      boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_dominio_valor_scope UNIQUE (company_id, branch_id, dominio_valor_id),
    CONSTRAINT uq_dominio_valor_company UNIQUE (company_id, dominio_valor_id),
    CONSTRAINT uq_dominio_valor_codigo UNIQUE (company_id, dominio_codigo, codigo),
    CONSTRAINT ck_dominio_valor_codigo CHECK (codigo ~ '^[A-Z][A-Z0-9_]{0,63}$'),
    CONSTRAINT fk_dominio_valor_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_dominio_valor_dominio
        FOREIGN KEY (company_id, dominio_codigo)
        REFERENCES iqg_core.dominio (company_id, codigo)
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
    motivo_codigo               varchar(64) NULL,
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

-- Los identificadores y datos de contacto son sobres AES-256-GCM por columna
-- producidos fuera de PostgreSQL. El UUID interno preserva relaciones y
-- trazabilidad sin almacenar identidad humana en claro. Los campos de negocio
-- que no terminan en _cifrado no admiten PII por contrato de entrada.
CREATE TABLE iqg_core.cliente (
    cliente_id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                  uuid NOT NULL,
    branch_id                   uuid NOT NULL,
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    canal_id                    uuid NULL,
    identificador_externo_cifrado bytea NULL,
    nombre_mostrar_cifrado      bytea NULL,
    correo_electronico_cifrado  bytea NULL,
    telefono_cifrado            bytea NULL,
    referencia_clave_operativa_externa uuid NULL,
    version_sobre_cifrado       smallint NOT NULL DEFAULT 1,
    algoritmo_cifrado           varchar(32) NOT NULL DEFAULT 'AES_256_GCM',
    consentimiento_comercial_cifrado bytea NULL,
    activo                      boolean NOT NULL DEFAULT true,
    anonimizado_en              timestamptz NULL,
    anonimizacion_solicitud_id  uuid NULL,
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
        consentimiento_comercial_cifrado IS NULL
        OR iqg_core.es_sobre_cifrado_aes_256_gcm(consentimiento_comercial_cifrado)
    ),
    CONSTRAINT ck_cliente_anonimizado CHECK (
        (anonimizado_en IS NULL AND anonimizacion_solicitud_id IS NULL)
        OR (
            anonimizado_en IS NOT NULL
            AND anonimizacion_solicitud_id IS NOT NULL
            AND nombre_mostrar_cifrado IS NULL
            AND identificador_externo_cifrado IS NULL
            AND correo_electronico_cifrado IS NULL
            AND telefono_cifrado IS NULL
            AND referencia_clave_operativa_externa IS NULL
            AND consentimiento_comercial_cifrado IS NULL
            AND activo = false
        )
    ),
    CONSTRAINT ck_cliente_sobres_operativos CHECK (
        (identificador_externo_cifrado IS NULL
         OR iqg_core.es_sobre_cifrado_aes_256_gcm(identificador_externo_cifrado))
        AND (nombre_mostrar_cifrado IS NULL
             OR iqg_core.es_sobre_cifrado_aes_256_gcm(nombre_mostrar_cifrado))
        AND (correo_electronico_cifrado IS NULL
             OR iqg_core.es_sobre_cifrado_aes_256_gcm(correo_electronico_cifrado))
        AND (telefono_cifrado IS NULL
             OR iqg_core.es_sobre_cifrado_aes_256_gcm(telefono_cifrado))
        AND (consentimiento_comercial_cifrado IS NULL
             OR iqg_core.es_sobre_cifrado_aes_256_gcm(consentimiento_comercial_cifrado))
        AND version_sobre_cifrado > 0
        AND algoritmo_cifrado = 'AES_256_GCM'
        AND (
            anonimizado_en IS NOT NULL
            OR (
                nombre_mostrar_cifrado IS NOT NULL
                AND referencia_clave_operativa_externa IS NOT NULL
            )
        )
    )
);

-- No se indexa PII cifrada de forma determinista. Si una futura necesidad de
-- negocio exige búsqueda o unicidad de PII, se aprobará un blind-index/HMAC
-- externo por ADR; no se agrega por defecto para evitar correlación innecesaria.

-- La solicitud es un hecho append-only: prueba que se aplicó la excepción de
-- privacidad sin conservar hashes, correo, teléfono ni identificadores previos.
-- La confirmación externa es una referencia de evidencia emitida por el
-- custodio del titular; PostgreSQL no puede verificar una destrucción de clave
-- que ocurre fuera de su límite de confianza.
CREATE TABLE iqg_core.anonimizacion_solicitud (
    anonimizacion_solicitud_id  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                  uuid NOT NULL,
    branch_id                   uuid NOT NULL,
    creado_por_usuario_id       uuid NOT NULL,
    fecha_creacion              timestamptz NOT NULL DEFAULT clock_timestamp(),
    cliente_id                  uuid NOT NULL,
    motivo_codigo               varchar(64) NOT NULL,
    confirmacion_destruccion_externa uuid NOT NULL,
    destruccion_confirmada_en   timestamptz NOT NULL DEFAULT clock_timestamp(),
    CONSTRAINT uq_anonimizacion_solicitud_scope
        UNIQUE (company_id, branch_id, anonimizacion_solicitud_id),
    CONSTRAINT uq_anonimizacion_solicitud_cliente
        UNIQUE (company_id, branch_id, cliente_id),
    CONSTRAINT ck_anonimizacion_solicitud_motivo
        CHECK (motivo_codigo ~ '^[A-Z][A-Z0-9_]{0,63}$'),
    CONSTRAINT ck_anonimizacion_solicitud_confirmacion
        CHECK (confirmacion_destruccion_externa IS NOT NULL),
    CONSTRAINT fk_anonimizacion_solicitud_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_anonimizacion_solicitud_cliente
        FOREIGN KEY (company_id, branch_id, cliente_id)
        REFERENCES iqg_core.cliente (company_id, branch_id, cliente_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

-- cliente y anonimizacion_solicitud se enlazan mutuamente: la solicitud prueba
-- la transición y el cliente apunta al hecho exacto que la produjo.
ALTER TABLE iqg_core.cliente
    ADD CONSTRAINT fk_cliente_anonimizacion_solicitud
        FOREIGN KEY (company_id, branch_id, anonimizacion_solicitud_id)
        REFERENCES iqg_core.anonimizacion_solicitud (
            company_id, branch_id, anonimizacion_solicitud_id
        )
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
        DEFERRABLE INITIALLY DEFERRED;

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
    -- Solo una transición de OPERACION configurada y aprobada puede disparar
    -- la materialización automática de una factura fiscal.
    dispara_emision_fiscal      boolean NOT NULL DEFAULT false,
    tipo_documento_fiscal_codigo varchar(64) NULL,
    activo                      boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_estado_scope UNIQUE (company_id, branch_id, estado_id),
    CONSTRAINT uq_estado_entidad_codigo UNIQUE (company_id, branch_id, entidad_codigo, codigo),
    CONSTRAINT ck_estado_emision_fiscal CHECK (
        NOT dispara_emision_fiscal
        OR (
            entidad_codigo = 'OPERACION'
            AND es_terminal
            AND tipo_documento_fiscal_codigo ~ '^[A-Z][A-Z0-9_]{0,63}$'
        )
    ),
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
    referencia_externa_cifrada  bytea NULL,
    referencia_clave_externa    uuid NULL,
    referencia_version_sobre    smallint NULL,
    origen_idempotencia         varchar(64) NOT NULL,
    clave_idempotencia          uuid NOT NULL,
    operacion_referencia_id     uuid NULL,
    motivo_codigo               varchar(64) NULL,
    CONSTRAINT uq_operacion_scope UNIQUE (company_id, branch_id, operacion_id),
    CONSTRAINT uq_operacion_idempotencia UNIQUE (company_id, branch_id, origen_idempotencia, clave_idempotencia),
    CONSTRAINT ck_operacion_signo CHECK (signo_impacto IN (-1, 1)),
    CONSTRAINT ck_operacion_moneda CHECK (moneda_codigo ~ '^[A-Z]{3}$'),
    CONSTRAINT ck_operacion_referencia_cifrada CHECK (
        (referencia_externa_cifrada IS NULL
         AND referencia_clave_externa IS NULL
         AND referencia_version_sobre IS NULL)
        OR (
            iqg_core.es_sobre_cifrado_aes_256_gcm(referencia_externa_cifrada)
            AND referencia_clave_externa IS NOT NULL
            AND referencia_version_sobre > 0
        )
    ),
    CONSTRAINT ck_operacion_motivo_codigo CHECK (
        motivo_codigo IS NULL OR motivo_codigo ~ '^[A-Z][A-Z0-9_]{0,63}$'
    ),
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
    motivo_codigo               varchar(64) NULL,
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
    referencia_externa_cifrada  bytea NULL,
    referencia_clave_externa    uuid NULL,
    referencia_version_sobre    smallint NULL,
    origen_idempotencia         varchar(64) NOT NULL,
    clave_idempotencia          uuid NOT NULL,
    motivo_codigo               varchar(64) NULL,
    CONSTRAINT uq_pago_scope UNIQUE (company_id, branch_id, pago_id),
    CONSTRAINT uq_pago_idempotencia UNIQUE (company_id, branch_id, origen_idempotencia, clave_idempotencia),
    CONSTRAINT ck_pago_signo CHECK (signo_impacto IN (-1, 1)),
    CONSTRAINT ck_pago_moneda CHECK (moneda_codigo ~ '^[A-Z]{3}$'),
    CONSTRAINT ck_pago_importe CHECK (importe_menor > 0),
    CONSTRAINT ck_pago_referencia_cifrada CHECK (
        (referencia_externa_cifrada IS NULL
         AND referencia_clave_externa IS NULL
         AND referencia_version_sobre IS NULL)
        OR (
            iqg_core.es_sobre_cifrado_aes_256_gcm(referencia_externa_cifrada)
            AND referencia_clave_externa IS NOT NULL
            AND referencia_version_sobre > 0
        )
    ),
    CONSTRAINT ck_pago_motivo_codigo CHECK (
        motivo_codigo IS NULL OR motivo_codigo ~ '^[A-Z][A-Z0-9_]{0,63}$'
    ),
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
    motivo_codigo               varchar(64) NULL,
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
    motivo_codigo               varchar(64) NULL,
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
    referencia_externa_cifrada  bytea NULL,
    referencia_clave_externa    uuid NULL,
    referencia_version_sobre    smallint NULL,
    origen_idempotencia         varchar(64) NOT NULL,
    clave_idempotencia          uuid NOT NULL,
    CONSTRAINT uq_movimiento_scope UNIQUE (company_id, branch_id, movimiento_id),
    CONSTRAINT uq_movimiento_linea_grupo UNIQUE (company_id, branch_id, grupo_movimiento_id, numero_linea_grupo),
    CONSTRAINT uq_movimiento_idempotencia UNIQUE (company_id, branch_id, origen_idempotencia, clave_idempotencia),
    CONSTRAINT ck_movimiento_numero_linea_grupo CHECK (numero_linea_grupo > 0),
    CONSTRAINT ck_movimiento_signo CHECK (signo_cantidad IN (-1, 1)),
    CONSTRAINT ck_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT ck_movimiento_moneda CHECK (moneda_codigo IS NULL OR moneda_codigo ~ '^[A-Z]{3}$'),
    CONSTRAINT ck_movimiento_referencia_cifrada CHECK (
        (referencia_externa_cifrada IS NULL
         AND referencia_clave_externa IS NULL
         AND referencia_version_sobre IS NULL)
        OR (
            iqg_core.es_sobre_cifrado_aes_256_gcm(referencia_externa_cifrada)
            AND referencia_clave_externa IS NOT NULL
            AND referencia_version_sobre > 0
        )
    ),
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
    direccion_ip_cifrada        bytea NULL,
    direccion_ip_clave_referencia uuid NULL,
    direccion_ip_version_sobre  smallint NULL,
    actor_tipo_codigo           varchar(32) NOT NULL DEFAULT 'SISTEMA',
    tabla_origen                text NOT NULL,
    operacion_dml               varchar(6) NOT NULL,
    registro_id                 uuid NOT NULL,
    motivo_codigo               varchar(64) NULL,
    datos_antes                 jsonb NULL,
    datos_despues               jsonb NULL,
    redactado_en                timestamptz NULL,
    redactado_por_usuario_id    uuid NULL,
    redaccion_solicitud_id      uuid NULL,
    CONSTRAINT uq_registro_cambios_scope UNIQUE (company_id, branch_id, registro_cambio_id),
    CONSTRAINT ck_registro_cambios_operacion CHECK (operacion_dml IN ('INSERT', 'UPDATE', 'DELETE')),
    CONSTRAINT ck_registro_cambios_tabla CHECK (tabla_origen <> 'registro_cambios'),
    CONSTRAINT ck_registro_cambios_ip_cifrada CHECK (
        (direccion_ip_cifrada IS NULL
         AND direccion_ip_clave_referencia IS NULL
         AND direccion_ip_version_sobre IS NULL)
        OR (
            iqg_core.es_sobre_cifrado_aes_256_gcm(direccion_ip_cifrada)
            AND direccion_ip_clave_referencia IS NOT NULL
            AND direccion_ip_version_sobre > 0
        )
    ),
    CONSTRAINT ck_registro_cambios_motivo_codigo CHECK (
        motivo_codigo IS NULL OR motivo_codigo ~ '^[A-Z][A-Z0-9_]{0,63}$'
    ),
    CONSTRAINT ck_registro_cambios_valores CHECK (
        (operacion_dml = 'INSERT' AND datos_antes IS NULL AND datos_despues IS NOT NULL)
        OR (operacion_dml = 'UPDATE' AND datos_antes IS NOT NULL AND datos_despues IS NOT NULL)
        OR (operacion_dml = 'DELETE' AND datos_antes IS NOT NULL AND datos_despues IS NULL)
    ),
    CONSTRAINT ck_registro_cambios_redaccion CHECK (
        (redactado_en IS NULL
         AND redactado_por_usuario_id IS NULL
         AND redaccion_solicitud_id IS NULL)
        OR (
            redactado_en IS NOT NULL
            AND redactado_por_usuario_id IS NOT NULL
            AND redaccion_solicitud_id IS NOT NULL
        )
    ),
    CONSTRAINT fk_registro_cambios_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        DEFERRABLE INITIALLY DEFERRED
);

-- -----------------------------------------------------------------------------
-- Capa fiscal separada. Estas relaciones no almacenan CRM, inventario, costos
-- internos ni PII operativa en claro. Una FK a operacion conserva procedencia;
-- no convierte la fila operativa en una fila fiscal. Si facturacion_fiscal_activa
-- es false, el trigger no inserta ninguna fila en este esquema.
-- -----------------------------------------------------------------------------

CREATE TABLE iqg_fiscal.factura (
    factura_id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                   uuid NOT NULL,
    branch_id                    uuid NOT NULL,
    creado_por_usuario_id        uuid NOT NULL,
    fecha_creacion               timestamptz NOT NULL DEFAULT clock_timestamp(),
    operacion_id                 uuid NOT NULL,
    factura_referencia_id        uuid NULL,
    tipo_documento_fiscal_codigo varchar(64) NOT NULL,
    estado_emision_codigo        varchar(32) NOT NULL DEFAULT 'PENDIENTE_EMISOR',
    pais_codigo_emision          char(2) NOT NULL,
    regimen_fiscal_codigo_emision varchar(64) NOT NULL,
    version_regla_fiscal         varchar(64) NOT NULL,
    identificador_fiscal_cifrado_snapshot bytea NOT NULL,
    referencia_clave_fiscal_externa uuid NOT NULL,
    version_sobre_fiscal         smallint NOT NULL,
    algoritmo_cifrado_fiscal     varchar(32) NOT NULL DEFAULT 'AES_256_GCM',
    es_emision_obligatoria       boolean NOT NULL,
    moneda_codigo                varchar(3) NOT NULL,
    importe_bruto_menor          bigint NOT NULL,
    descuento_menor              bigint NOT NULL,
    impuesto_menor               bigint NOT NULL,
    importe_total_menor          bigint NOT NULL,
    fecha_solicitud_emision      timestamptz NOT NULL DEFAULT clock_timestamp(),
    fecha_emision_confirmada     timestamptz NULL,
    retencion_fiscal_anios       smallint NOT NULL,
    retener_hasta                date NULL,
    CONSTRAINT uq_factura_scope UNIQUE (company_id, branch_id, factura_id),
    CONSTRAINT uq_factura_operacion UNIQUE (company_id, branch_id, operacion_id),
    CONSTRAINT ck_factura_estado_emision CHECK (
        estado_emision_codigo IN ('PENDIENTE_EMISOR', 'EMITIDA', 'RECHAZADA')
    ),
    CONSTRAINT ck_factura_pais CHECK (pais_codigo_emision IN ('BO', 'PE', 'BR', 'AR')),
    CONSTRAINT ck_factura_regimen CHECK (
        regimen_fiscal_codigo_emision ~ '^[A-Z][A-Z0-9_]{0,63}$'
    ),
    CONSTRAINT ck_factura_identidad_fiscal_snapshot CHECK (
        iqg_core.es_sobre_cifrado_aes_256_gcm(identificador_fiscal_cifrado_snapshot)
        AND referencia_clave_fiscal_externa IS NOT NULL
        AND version_sobre_fiscal > 0
        AND algoritmo_cifrado_fiscal = 'AES_256_GCM'
    ),
    CONSTRAINT ck_factura_montos CHECK (
        importe_bruto_menor >= 0
        AND descuento_menor >= 0
        AND impuesto_menor >= 0
        AND importe_total_menor = importe_bruto_menor - descuento_menor + impuesto_menor
        AND importe_total_menor >= 0
    ),
    CONSTRAINT ck_factura_retencion CHECK (
        (pais_codigo_emision = 'BR' AND retencion_fiscal_anios = 5)
        OR (pais_codigo_emision IN ('BO', 'PE', 'AR')
            AND retencion_fiscal_anios = 10)
    ),
    CONSTRAINT ck_factura_fecha_emision CHECK (
        (estado_emision_codigo = 'PENDIENTE_EMISOR'
            AND fecha_emision_confirmada IS NULL
            AND retener_hasta IS NULL)
        OR (estado_emision_codigo IN ('EMITIDA', 'RECHAZADA')
            AND fecha_emision_confirmada IS NOT NULL
            AND retener_hasta = (
                fecha_emision_confirmada
                + make_interval(years => retencion_fiscal_anios)
            )::date)
    ),
    CONSTRAINT fk_factura_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_factura_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_factura_operacion
        FOREIGN KEY (company_id, branch_id, operacion_id)
        REFERENCES iqg_core.operacion (company_id, branch_id, operacion_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_factura_referencia
        FOREIGN KEY (company_id, branch_id, factura_referencia_id)
        REFERENCES iqg_fiscal.factura (company_id, branch_id, factura_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT
);

CREATE TABLE iqg_fiscal.factura_linea (
    factura_linea_id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                   uuid NOT NULL,
    branch_id                    uuid NOT NULL,
    creado_por_usuario_id        uuid NOT NULL,
    fecha_creacion               timestamptz NOT NULL DEFAULT clock_timestamp(),
    factura_id                   uuid NOT NULL,
    operacion_linea_id           uuid NOT NULL,
    numero_linea                 integer NOT NULL,
    descripcion_elemento_snapshot text NOT NULL,
    unidad_medida_codigo         varchar(32) NOT NULL,
    cantidad                     numeric(20, 6) NOT NULL,
    moneda_codigo                varchar(3) NOT NULL,
    precio_unitario_menor        bigint NOT NULL,
    importe_bruto_menor          bigint NOT NULL,
    descuento_menor              bigint NOT NULL,
    impuesto_menor               bigint NOT NULL,
    importe_total_menor          bigint NOT NULL,
    CONSTRAINT uq_factura_linea_scope UNIQUE (company_id, branch_id, factura_linea_id),
    CONSTRAINT uq_factura_linea_ordinal UNIQUE (company_id, branch_id, factura_id, numero_linea),
    CONSTRAINT uq_factura_linea_operacion_linea UNIQUE (company_id, branch_id, operacion_linea_id),
    CONSTRAINT ck_factura_linea_montos CHECK (
        numero_linea > 0
        AND cantidad > 0
        AND moneda_codigo ~ '^[A-Z]{3}$'
        AND precio_unitario_menor >= 0
        AND importe_bruto_menor = round(cantidad * precio_unitario_menor)::bigint
        AND descuento_menor BETWEEN 0 AND importe_bruto_menor
        AND impuesto_menor >= 0
        AND importe_total_menor = importe_bruto_menor - descuento_menor + impuesto_menor
        AND importe_total_menor >= 0
    ),
    CONSTRAINT fk_factura_linea_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_factura_linea_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_factura_linea_factura
        FOREIGN KEY (company_id, branch_id, factura_id)
        REFERENCES iqg_fiscal.factura (company_id, branch_id, factura_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_factura_linea_operacion_linea
        FOREIGN KEY (company_id, branch_id, operacion_linea_id)
        REFERENCES iqg_core.operacion_linea (company_id, branch_id, operacion_linea_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT
);

-- El XML puede contener identificadores fiscales y PII. Solo se guarda como
-- sobre AES-256-GCM y el hash para verificar integridad; no existe XML claro
-- ni material de firma/clave dentro de PostgreSQL.
CREATE TABLE iqg_fiscal.factura_xml (
    factura_xml_id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                   uuid NOT NULL,
    branch_id                    uuid NOT NULL,
    creado_por_usuario_id        uuid NOT NULL,
    fecha_creacion               timestamptz NOT NULL DEFAULT clock_timestamp(),
    factura_id                   uuid NOT NULL,
    tipo_xml_codigo              varchar(64) NOT NULL,
    version_xml                  integer NOT NULL DEFAULT 1,
    xml_cifrado                  bytea NOT NULL,
    hash_sobre_cifrado_sha256    bytea NOT NULL,
    referencia_clave_fiscal_externa uuid NOT NULL,
    version_sobre_cifrado        smallint NOT NULL DEFAULT 1,
    algoritmo_cifrado            varchar(32) NOT NULL DEFAULT 'AES_256_GCM',
    estado_envio_codigo          varchar(32) NOT NULL DEFAULT 'GENERADO',
    enviado_en                   timestamptz NULL,
    aceptado_por_fisco_en        timestamptz NULL,
    referencia_autoridad_cifrada bytea NULL,
    CONSTRAINT uq_factura_xml_scope UNIQUE (company_id, branch_id, factura_xml_id),
    CONSTRAINT uq_factura_xml_version UNIQUE (company_id, branch_id, factura_id, version_xml),
    CONSTRAINT ck_factura_xml_version CHECK (version_xml > 0),
    CONSTRAINT ck_factura_xml_sobre CHECK (
        iqg_core.es_sobre_cifrado_aes_256_gcm(xml_cifrado)
        AND octet_length(hash_sobre_cifrado_sha256) = 32
        AND version_sobre_cifrado > 0
        AND algoritmo_cifrado = 'AES_256_GCM'
        AND (referencia_autoridad_cifrada IS NULL
             OR iqg_core.es_sobre_cifrado_aes_256_gcm(referencia_autoridad_cifrada))
    ),
    CONSTRAINT ck_factura_xml_estado CHECK (
        estado_envio_codigo IN ('GENERADO', 'ENVIADO', 'ACEPTADO', 'RECHAZADO')
    ),
    CONSTRAINT ck_factura_xml_fechas CHECK (
        (estado_envio_codigo = 'GENERADO'
            AND enviado_en IS NULL
            AND aceptado_por_fisco_en IS NULL)
        OR (estado_envio_codigo = 'ENVIADO'
            AND enviado_en IS NOT NULL
            AND aceptado_por_fisco_en IS NULL)
        OR (estado_envio_codigo = 'ACEPTADO'
            AND enviado_en IS NOT NULL
            AND aceptado_por_fisco_en IS NOT NULL
            AND referencia_autoridad_cifrada IS NOT NULL)
        OR (estado_envio_codigo = 'RECHAZADO'
            AND enviado_en IS NOT NULL
            AND aceptado_por_fisco_en IS NOT NULL
            AND referencia_autoridad_cifrada IS NOT NULL)
    ),
    CONSTRAINT fk_factura_xml_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_factura_xml_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_factura_xml_factura
        FOREIGN KEY (company_id, branch_id, factura_id)
        REFERENCES iqg_fiscal.factura (company_id, branch_id, factura_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT
);

-- Outbox transaccional: el trigger solo solicita emisión. Un agente fiscal
-- operado por el titular descifra, firma y transmite fuera de PostgreSQL.
CREATE TABLE iqg_fiscal.evento_emision_factura (
    evento_emision_factura_id    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                   uuid NOT NULL,
    branch_id                    uuid NOT NULL,
    creado_por_usuario_id        uuid NOT NULL,
    fecha_creacion               timestamptz NOT NULL DEFAULT clock_timestamp(),
    factura_id                   uuid NOT NULL,
    tipo_evento_codigo           varchar(64) NOT NULL DEFAULT 'EMITIR_FACTURA',
    clave_idempotencia           uuid NOT NULL,
    entregado_en                 timestamptz NULL,
    procesado_en                 timestamptz NULL,
    resultado_codigo             varchar(64) NULL,
    CONSTRAINT uq_evento_emision_factura_scope
        UNIQUE (company_id, branch_id, evento_emision_factura_id),
    CONSTRAINT uq_evento_emision_factura_idempotencia
        UNIQUE (company_id, branch_id, factura_id, tipo_evento_codigo),
    CONSTRAINT ck_evento_emision_factura_tipo CHECK (
        tipo_evento_codigo = 'EMITIR_FACTURA'
    ),
    CONSTRAINT ck_evento_emision_factura_resultado CHECK (
        resultado_codigo IS NULL OR resultado_codigo ~ '^[A-Z][A-Z0-9_]{0,63}$'
    ),
    CONSTRAINT fk_evento_emision_factura_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_evento_emision_factura_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_evento_emision_factura_factura
        FOREIGN KEY (company_id, branch_id, factura_id)
        REFERENCES iqg_fiscal.factura (company_id, branch_id, factura_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT
);

-- Auditoría separada: nunca se invoca desde tablas operativas ni comparte
-- snapshots con iqg_core.registro_cambios.
CREATE TABLE iqg_fiscal.registro_cambios (
    registro_cambio_id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                   uuid NOT NULL,
    branch_id                    uuid NOT NULL,
    creado_por_usuario_id        uuid NOT NULL,
    fecha_creacion               timestamptz NOT NULL DEFAULT clock_timestamp(),
    transaccion_id               bigint NOT NULL DEFAULT txid_current(),
    correlation_id               uuid NULL,
    direccion_ip_cifrada         bytea NULL,
    direccion_ip_clave_referencia uuid NULL,
    direccion_ip_version_sobre   smallint NULL,
    actor_tipo_codigo            varchar(32) NOT NULL DEFAULT 'SISTEMA',
    tabla_origen                 text NOT NULL,
    operacion_dml                varchar(6) NOT NULL,
    registro_id                  uuid NOT NULL,
    motivo_codigo                varchar(64) NULL,
    datos_antes                  jsonb NULL,
    datos_despues                jsonb NULL,
    CONSTRAINT uq_registro_cambios_fiscal_scope
        UNIQUE (company_id, branch_id, registro_cambio_id),
    CONSTRAINT ck_registro_cambios_fiscal_operacion
        CHECK (operacion_dml IN ('INSERT', 'UPDATE', 'DELETE')),
    CONSTRAINT ck_registro_cambios_fiscal_tabla
        CHECK (tabla_origen LIKE 'iqg_fiscal.%'),
    CONSTRAINT ck_registro_cambios_fiscal_ip_cifrada CHECK (
        (direccion_ip_cifrada IS NULL
         AND direccion_ip_clave_referencia IS NULL
         AND direccion_ip_version_sobre IS NULL)
        OR (
            iqg_core.es_sobre_cifrado_aes_256_gcm(direccion_ip_cifrada)
            AND direccion_ip_clave_referencia IS NOT NULL
            AND direccion_ip_version_sobre > 0
        )
    ),
    CONSTRAINT ck_registro_cambios_fiscal_motivo_codigo CHECK (
        motivo_codigo IS NULL OR motivo_codigo ~ '^[A-Z][A-Z0-9_]{0,63}$'
    ),
    CONSTRAINT ck_registro_cambios_fiscal_valores CHECK (
        (operacion_dml = 'INSERT' AND datos_antes IS NULL AND datos_despues IS NOT NULL)
        OR (operacion_dml = 'UPDATE' AND datos_antes IS NOT NULL AND datos_despues IS NOT NULL)
        OR (operacion_dml = 'DELETE' AND datos_antes IS NOT NULL AND datos_despues IS NULL)
    ),
    CONSTRAINT fk_registro_cambios_fiscal_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_registro_cambios_fiscal_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT
);

-- Hecho corporativo mínimo, no fiscal ni PII: materializa que ya existe una
-- factura en alguna sucursal. Permite congelar la configuración fiscal de la
-- empresa sin abrir lectura de documentos fiscales entre sucursales.
CREATE TABLE iqg_core.fiscal_configuracion_bloqueada (
    fiscal_configuracion_bloqueada_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id                        uuid NOT NULL,
    branch_id                         uuid NOT NULL,
    creado_por_usuario_id             uuid NOT NULL,
    fecha_creacion                    timestamptz NOT NULL DEFAULT clock_timestamp(),
    factura_id                        uuid NOT NULL,
    CONSTRAINT uq_fiscal_configuracion_bloqueada_scope
        UNIQUE (company_id, branch_id, fiscal_configuracion_bloqueada_id),
    CONSTRAINT uq_fiscal_configuracion_bloqueada_company
        UNIQUE (company_id),
    CONSTRAINT fk_fiscal_configuracion_bloqueada_sucursal
        FOREIGN KEY (company_id, branch_id)
        REFERENCES iqg_core.sucursal (company_id, branch_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_fiscal_configuracion_bloqueada_factura
        FOREIGN KEY (company_id, branch_id, factura_id)
        REFERENCES iqg_fiscal.factura (company_id, branch_id, factura_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT
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
ALTER TABLE iqg_core.provisionamiento_empresa
    ADD CONSTRAINT fk_provisionamiento_empresa_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE iqg_core.fiscal_configuracion_bloqueada
    ADD CONSTRAINT fk_fiscal_configuracion_bloqueada_creador
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
ALTER TABLE iqg_core.dominio
    ADD CONSTRAINT fk_dominio_creador
        FOREIGN KEY (company_id, branch_id, creado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE iqg_core.dominio_valor
    ADD CONSTRAINT fk_dominio_valor_creador
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
ALTER TABLE iqg_core.anonimizacion_solicitud
    ADD CONSTRAINT fk_anonimizacion_solicitud_creador
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
ALTER TABLE iqg_core.registro_cambios
    ADD CONSTRAINT fk_registro_cambios_redactor
        FOREIGN KEY (company_id, branch_id, redactado_por_usuario_id)
        REFERENCES iqg_core.usuario_sucursal (company_id, branch_id, usuario_id)
        ON UPDATE NO ACTION ON DELETE NO ACTION
        DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE iqg_core.registro_cambios
    ADD CONSTRAINT fk_registro_cambios_solicitud_redaccion
        FOREIGN KEY (company_id, branch_id, redaccion_solicitud_id)
        REFERENCES iqg_core.anonimizacion_solicitud (
            company_id, branch_id, anonimizacion_solicitud_id
        )
        ON UPDATE NO ACTION ON DELETE NO ACTION
        DEFERRABLE INITIALLY DEFERRED;

-- Las cuatro funciones de evidencia son el único estrato de lectura usado por
-- las políticas internas de empresa/usuario/sucursal/membresía. Cada una lee
-- solo la fila nombrada por el contexto y sus políticas SELECT no invocan la
-- membresía completa; de ese modo contexto_membresia_activa puede verificar
-- los cuatro estados sin recursión bajo FORCE ROW LEVEL SECURITY. No se
-- conceden tablas ni estas funciones a iqg_app/iqg_gateway.
CREATE OR REPLACE FUNCTION iqg_core.contexto_empresa_activa()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = iqg_core, pg_temp
AS $$
    SELECT EXISTS (
        SELECT 1
          FROM iqg_core.empresa AS e
         WHERE e.company_id = iqg_core.contexto_company_id()
           AND e.activo = true
    );
$$;

CREATE OR REPLACE FUNCTION iqg_core.contexto_usuario_activo()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = iqg_core, pg_temp
AS $$
    SELECT EXISTS (
        SELECT 1
          FROM iqg_core.usuario AS u
         WHERE u.company_id = iqg_core.contexto_company_id()
           AND u.usuario_id = iqg_core.contexto_usuario_id()
           AND u.activo = true
    );
$$;

CREATE OR REPLACE FUNCTION iqg_core.contexto_sucursal_activa()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = iqg_core, pg_temp
AS $$
    SELECT EXISTS (
        SELECT 1
          FROM iqg_core.sucursal AS s
         WHERE s.company_id = iqg_core.contexto_company_id()
           AND s.branch_id = iqg_core.contexto_branch_id()
           AND s.activo = true
    );
$$;

CREATE OR REPLACE FUNCTION iqg_core.contexto_usuario_sucursal_activa()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = iqg_core, pg_temp
AS $$
    SELECT EXISTS (
        SELECT 1
          FROM iqg_core.usuario_sucursal AS us
         WHERE us.company_id = iqg_core.contexto_company_id()
           AND us.branch_id = iqg_core.contexto_branch_id()
           AND us.usuario_id = iqg_core.contexto_usuario_id()
           AND us.activo = true
    );
$$;

-- Verifica la pertenencia de alcance y los cuatro estados de acceso. La
-- combinación prueba que el usuario pertenece a la empresa y a la sucursal
-- del contexto, y que ni el usuario, ni la empresa, ni la sucursal, ni la
-- membresía se encuentran desactivados.
CREATE OR REPLACE FUNCTION iqg_core.contexto_membresia_activa()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = iqg_core, pg_temp
AS $$
    SELECT iqg_core.contexto_company_id() IS NOT NULL
       AND iqg_core.contexto_branch_id() IS NOT NULL
       AND iqg_core.contexto_usuario_id() IS NOT NULL
       AND iqg_core.contexto_empresa_activa()
       AND iqg_core.contexto_usuario_activo()
       AND iqg_core.contexto_sucursal_activa()
       AND iqg_core.contexto_usuario_sucursal_activa();
$$;

CREATE OR REPLACE FUNCTION iqg_core.exigir_contexto_membresia_activa()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = iqg_core, pg_temp
AS $$
BEGIN
    IF NOT iqg_core.contexto_membresia_activa() THEN
        RAISE EXCEPTION
            'El contexto requiere una membresía activa y una sucursal de la misma empresa';
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION iqg_core.contexto_tiene_permiso(
    p_recurso_codigo varchar,
    p_accion_codigo varchar
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = iqg_core, pg_temp
AS $$
    SELECT iqg_core.contexto_membresia_activa()
       AND EXISTS (
        SELECT 1
          FROM iqg_core.usuario_sucursal AS us
          JOIN iqg_core.usuario_rol AS ur
            ON ur.company_id = us.company_id
           AND ur.branch_id = us.branch_id
           AND ur.usuario_sucursal_id = us.usuario_sucursal_id
           AND ur.activo = true
          JOIN iqg_core.rol AS r
            ON r.company_id = ur.company_id
           AND r.rol_id = ur.rol_id
           AND r.activo = true
          JOIN iqg_core.rol_permiso AS rp
            ON rp.company_id = r.company_id
           AND rp.rol_id = r.rol_id
           AND rp.activo = true
          JOIN iqg_core.permiso AS p
            ON p.company_id = rp.company_id
           AND p.permiso_id = rp.permiso_id
           AND p.activo = true
         WHERE us.company_id = iqg_core.contexto_company_id()
           AND us.branch_id = iqg_core.contexto_branch_id()
           AND us.usuario_id = iqg_core.contexto_usuario_id()
           AND us.activo = true
           AND p.recurso_codigo = upper(p_recurso_codigo)
           AND p.accion_codigo = upper(p_accion_codigo)
    );
$$;

-- -----------------------------------------------------------------------------
-- Índices de aislamiento, recorrido histórico y claves foráneas de alto uso.
-- Los índices comienzan por company_id + branch_id para que no se mezclen
-- recorridos de tenants y sucursales.
-- -----------------------------------------------------------------------------

CREATE INDEX idx_empresa_scope_fecha ON iqg_core.empresa (company_id, branch_id, fecha_creacion DESC);
CREATE INDEX idx_sucursal_scope_fecha ON iqg_core.sucursal (company_id, branch_id, fecha_creacion DESC);
CREATE INDEX idx_usuario_scope_fecha ON iqg_core.usuario (company_id, branch_id, fecha_creacion DESC);
CREATE INDEX idx_usuario_sucursal_scope_usuario ON iqg_core.usuario_sucursal (company_id, branch_id, usuario_id);
CREATE INDEX idx_provisionamiento_empresa_scope_fecha ON iqg_core.provisionamiento_empresa (company_id, branch_id, fecha_creacion DESC);
CREATE INDEX idx_rol_company_fecha ON iqg_core.rol (company_id, fecha_creacion DESC);
CREATE INDEX idx_permiso_company_fecha ON iqg_core.permiso (company_id, fecha_creacion DESC);
CREATE INDEX idx_rol_permiso_company_rol ON iqg_core.rol_permiso (company_id, rol_id);
CREATE INDEX idx_usuario_rol_scope_usuario ON iqg_core.usuario_rol (company_id, branch_id, usuario_sucursal_id);
CREATE INDEX idx_dominio_company_fecha ON iqg_core.dominio (company_id, fecha_creacion DESC);
CREATE INDEX idx_dominio_valor_company_dominio ON iqg_core.dominio_valor (company_id, dominio_codigo, codigo);
CREATE INDEX idx_elemento_scope_fecha ON iqg_core.elemento (company_id, branch_id, fecha_creacion DESC);
CREATE INDEX idx_precio_scope_elemento_fecha ON iqg_core.precio_vigente (company_id, branch_id, elemento_id, fecha_creacion DESC);
CREATE INDEX idx_canal_scope_fecha ON iqg_core.canal (company_id, branch_id, fecha_creacion DESC);
CREATE INDEX idx_campania_scope_fecha ON iqg_core.campania (company_id, branch_id, fecha_creacion DESC);
CREATE INDEX idx_cliente_scope_fecha ON iqg_core.cliente (company_id, branch_id, fecha_creacion DESC);
CREATE INDEX idx_anonimizacion_solicitud_scope_fecha ON iqg_core.anonimizacion_solicitud (company_id, branch_id, fecha_creacion DESC);
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
CREATE INDEX idx_fiscal_configuracion_bloqueada_scope_fecha ON iqg_core.fiscal_configuracion_bloqueada (company_id, branch_id, fecha_creacion DESC);
CREATE INDEX idx_factura_scope_fecha ON iqg_fiscal.factura (company_id, branch_id, fecha_creacion DESC);
CREATE INDEX idx_factura_scope_estado_fecha ON iqg_fiscal.factura (company_id, branch_id, estado_emision_codigo, fecha_creacion DESC);
CREATE INDEX idx_factura_linea_scope_factura ON iqg_fiscal.factura_linea (company_id, branch_id, factura_id, numero_linea);
CREATE INDEX idx_factura_xml_scope_factura ON iqg_fiscal.factura_xml (company_id, branch_id, factura_id, version_xml DESC);
CREATE INDEX idx_evento_emision_factura_pendiente ON iqg_fiscal.evento_emision_factura (company_id, branch_id, fecha_creacion)
    WHERE procesado_en IS NULL;
CREATE INDEX idx_registro_cambios_fiscal_scope_destino_fecha
    ON iqg_fiscal.registro_cambios (company_id, branch_id, tabla_origen, registro_id, fecha_creacion DESC);

-- -----------------------------------------------------------------------------
-- Integridad temporal, contexto inmutable y auditoría.
-- -----------------------------------------------------------------------------

-- Política solicitada de privacidad y retención. No infiere obligación legal
-- solo a partir del país: automatiza la consecuencia de una determinación
-- versionada ya registrada en empresa. País no soportado puede operar en la
-- capa privada, pero falla cerrado si se intenta activar facturación fiscal.
CREATE OR REPLACE FUNCTION iqg_core.tg_aplicar_politica_fiscal_empresa()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = iqg_core, iqg_fiscal, pg_temp
AS $$
DECLARE
    v_facturacion_activa boolean :=
        NEW.esta_obligado_a_facturar OR NEW.facturacion_fiscal_voluntaria;
BEGIN
    NEW.pais_codigo := upper(NEW.pais_codigo);

    CASE NEW.pais_codigo
        WHEN 'BO' THEN
            NEW.perfil_privacidad_codigo := 'BOLIVIA_REFORZADA_MINIMA';
            NEW.perfil_aad_cifrado_codigo := 'BO_AAD_TENANT_COLUMNA_ESTRICTO';
        WHEN 'PE' THEN
            NEW.perfil_privacidad_codigo := 'PERU_RESERVA_TRIBUTARIA';
            NEW.perfil_aad_cifrado_codigo := 'PE_AAD_TENANT_COLUMNA_ESTRICTO';
        WHEN 'BR' THEN
            NEW.perfil_privacidad_codigo := 'BRASIL_SIGILO_FISCAL';
            NEW.perfil_aad_cifrado_codigo := 'BR_AAD_TENANT_COLUMNA_ESTRICTO';
        WHEN 'AR' THEN
            NEW.perfil_privacidad_codigo := 'ARGENTINA_SECRETO_FISCAL';
            NEW.perfil_aad_cifrado_codigo := 'AR_AAD_TENANT_COLUMNA_ESTRICTO';
        ELSE
            NEW.perfil_privacidad_codigo := 'GENERAL_MINIMIZADO';
            NEW.perfil_aad_cifrado_codigo := 'GENERAL_AAD_TENANT_ESTRICTO';
    END CASE;
    NEW.minimiza_recoleccion_pii := true;

    IF v_facturacion_activa THEN
        IF NEW.regimen_fiscal_codigo IS NULL
           OR NEW.version_regla_fiscal IS NULL
           OR NEW.identificador_fiscal_cifrado IS NULL THEN
            RAISE EXCEPTION
                'La facturación fiscal activa exige régimen, versión de regla e identificador fiscal cifrado';
        END IF;

        NEW.retencion_fiscal_anios := CASE NEW.pais_codigo
            WHEN 'BR' THEN 5
            WHEN 'BO' THEN 10
            WHEN 'PE' THEN 10
            WHEN 'AR' THEN 10
            ELSE NULL
        END;

        IF NEW.retencion_fiscal_anios IS NULL THEN
            RAISE EXCEPTION
                'No existe una política fiscal aprobada para %; la emisión fiscal queda cerrada',
                NEW.pais_codigo;
        END IF;

        IF TG_OP = 'INSERT' THEN
            NEW.determinado_fiscalmente_en := clock_timestamp();
        ELSIF NEW.esta_obligado_a_facturar IS DISTINCT FROM OLD.esta_obligado_a_facturar
           OR NEW.facturacion_fiscal_voluntaria IS DISTINCT FROM OLD.facturacion_fiscal_voluntaria
           OR NEW.regimen_fiscal_codigo IS DISTINCT FROM OLD.regimen_fiscal_codigo
           OR NEW.version_regla_fiscal IS DISTINCT FROM OLD.version_regla_fiscal THEN
            NEW.determinado_fiscalmente_en := clock_timestamp();
        END IF;
    ELSE
        NEW.retencion_fiscal_anios := 0;
        NEW.version_regla_fiscal := NULL;
        NEW.determinado_fiscalmente_en := NULL;
    END IF;

    -- Una factura ya creada congela la jurisdicción, régimen y política que la
    -- originó. Rectificar exige una nueva empresa/configuración, no reescribir
    -- una determinación histórica.
    IF TG_OP = 'UPDATE' THEN
        -- Comparte este candado con el trigger de emisión para evitar que una
        -- primera factura y un cambio de régimen se crucen entre sucursales.
        PERFORM pg_advisory_xact_lock(
            hashtextextended(NEW.company_id::text, 918273645)
        );

        IF (
                NEW.pais_codigo IS DISTINCT FROM OLD.pais_codigo
                OR NEW.regimen_fiscal_codigo IS DISTINCT FROM OLD.regimen_fiscal_codigo
                OR NEW.esta_obligado_a_facturar IS DISTINCT FROM OLD.esta_obligado_a_facturar
                OR NEW.facturacion_fiscal_voluntaria IS DISTINCT FROM OLD.facturacion_fiscal_voluntaria
                OR NEW.version_regla_fiscal IS DISTINCT FROM OLD.version_regla_fiscal
            )
           AND EXISTS (
                SELECT 1
                  FROM iqg_core.fiscal_configuracion_bloqueada AS b
                 WHERE b.company_id = OLD.company_id
           ) THEN
            RAISE EXCEPTION
                'No se puede cambiar país, régimen o activación fiscal después de crear una factura';
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION iqg_core.tg_sellar_registro()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = iqg_core, pg_temp
AS $$
DECLARE
    v_actor uuid := iqg_core.contexto_usuario_id();
    v_company_id uuid := iqg_core.contexto_company_id();
    v_branch_id uuid := iqg_core.contexto_branch_id();
    v_id_anterior text;
    v_id_nuevo text;
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- El servidor siempre decide la fecha oficial de creación.
        NEW.fecha_creacion := clock_timestamp();

        IF v_company_id IS NULL
           OR v_branch_id IS NULL
           OR NEW.company_id IS DISTINCT FROM v_company_id
           OR NEW.branch_id IS DISTINCT FROM v_branch_id THEN
            RAISE EXCEPTION
                'La empresa y sucursal de una inserción deben coincidir con el contexto controlado';
        END IF;

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

-- Valida los códigos libres de las tablas de negocio contra el maestro
-- corporativo activo. TG_ARGV[0] es la columna y TG_ARGV[1] el dominio lógico.
CREATE OR REPLACE FUNCTION iqg_core.tg_validar_codigo_dominio()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = iqg_core, pg_temp
AS $$
DECLARE
    v_codigo text := to_jsonb(NEW) ->> TG_ARGV[0];
BEGIN
    -- Una actualización de otra columna no debe volver a depender de un valor
    -- de dominio histórico que no cambió ni adquirir sus locks. La inserción y
    -- cualquier modificación real del código sí pasan por la validación.
    IF TG_OP = 'UPDATE'
       AND v_codigo IS NOT DISTINCT FROM (to_jsonb(OLD) ->> TG_ARGV[0]) THEN
        RETURN NEW;
    END IF;

    IF v_codigo IS NULL THEN
        RETURN NEW;
    END IF;

    PERFORM 1
      FROM iqg_core.dominio_valor AS dv
      JOIN iqg_core.dominio AS d
        ON d.company_id = dv.company_id
       AND d.codigo = dv.dominio_codigo
     WHERE dv.company_id = NEW.company_id
       AND dv.dominio_codigo = TG_ARGV[1]
       AND dv.codigo = v_codigo
       AND dv.activo = true
       AND d.activo = true
     FOR KEY SHARE OF dv, d;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'El código % no es un valor activo de % para la empresa',
            v_codigo, TG_ARGV[1];
    END IF;

    RETURN NEW;
END;
$$;

-- El único INSERT de empresa es el bootstrap, que crea el catálogo de su
-- tenant más adelante en la misma transacción. Cualquier cambio posterior del
-- régimen exige un valor activo del maestro REGIMEN_FISCAL.
CREATE OR REPLACE FUNCTION iqg_core.tg_validar_regimen_fiscal_empresa()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = iqg_core, pg_temp
AS $$
BEGIN
    IF TG_OP = 'UPDATE'
       AND NEW.regimen_fiscal_codigo IS NOT DISTINCT FROM OLD.regimen_fiscal_codigo THEN
        RETURN NEW;
    END IF;

    IF NEW.regimen_fiscal_codigo IS NULL THEN
        RETURN NEW;
    END IF;

    IF TG_OP = 'INSERT' AND iqg_core.contexto_bootstrap_activo() THEN
        RETURN NEW;
    END IF;

    PERFORM 1
      FROM iqg_core.dominio_valor AS dv
      JOIN iqg_core.dominio AS d
        ON d.company_id = dv.company_id
       AND d.codigo = dv.dominio_codigo
     WHERE dv.company_id = NEW.company_id
       AND dv.dominio_codigo = 'REGIMEN_FISCAL'
       AND dv.codigo = NEW.regimen_fiscal_codigo
       AND dv.activo = true
       AND d.activo = true
     FOR KEY SHARE OF dv, d;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'El régimen fiscal % no es un valor activo para la empresa',
            NEW.regimen_fiscal_codigo;
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION iqg_core.tg_bloquear_cambio_unidad_elemento()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = iqg_core, pg_temp
AS $$
DECLARE
    v_tiene_referencias boolean;
BEGIN
    IF NEW.unidad_medida_codigo IS NOT DISTINCT FROM OLD.unidad_medida_codigo THEN
        RETURN NEW;
    END IF;

    SELECT EXISTS (
        SELECT 1
          FROM iqg_core.operacion_linea AS ol
         WHERE ol.company_id = OLD.company_id
           AND ol.branch_id = OLD.branch_id
           AND ol.elemento_id = OLD.elemento_id
    ) OR EXISTS (
        SELECT 1
          FROM iqg_core.movimiento AS m
         WHERE m.company_id = OLD.company_id
           AND m.branch_id = OLD.branch_id
           AND m.elemento_id = OLD.elemento_id
    )
      INTO v_tiene_referencias;

    IF v_tiene_referencias THEN
        RAISE EXCEPTION
            'La unidad base de un elemento con líneas o movimientos históricos es inmutable';
    END IF;

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
    v_unidad_elemento varchar(32);
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

    -- Una vez materializado el snapshot fiscal, las líneas operativas no pueden
    -- divergir. Una corrección posterior debe usar una nueva operación/documento.
    IF EXISTS (
        SELECT 1
          FROM iqg_fiscal.factura AS f
         WHERE f.company_id = NEW.company_id
           AND f.branch_id = NEW.branch_id
           AND f.operacion_id = NEW.operacion_id
    ) THEN
        RAISE EXCEPTION
            'No se pueden agregar líneas a una operación que ya tiene factura fiscal';
    END IF;

    SELECT unidad_medida_codigo
      INTO v_unidad_elemento
      FROM iqg_core.elemento
     WHERE company_id = NEW.company_id
       AND branch_id = NEW.branch_id
       AND elemento_id = NEW.elemento_id
     FOR KEY SHARE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El elemento de la línea no existe en el alcance indicado';
    END IF;

    IF NEW.unidad_medida_codigo IS DISTINCT FROM v_unidad_elemento THEN
        RAISE EXCEPTION
            'La unidad de medida de una línea debe coincidir con la unidad base del elemento';
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION iqg_core.tg_validar_movimiento()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = iqg_core, pg_temp
AS $$
DECLARE
    v_unidad_elemento varchar(32);
BEGIN
    SELECT unidad_medida_codigo
      INTO v_unidad_elemento
      FROM iqg_core.elemento
     WHERE company_id = NEW.company_id
       AND branch_id = NEW.branch_id
       AND elemento_id = NEW.elemento_id
     FOR KEY SHARE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El elemento del movimiento no existe en el alcance indicado';
    END IF;

    IF NEW.unidad_medida_codigo IS DISTINCT FROM v_unidad_elemento THEN
        RAISE EXCEPTION
            'La unidad de medida de un movimiento debe coincidir con la unidad base del elemento';
    END IF;

    RETURN NEW;
END;
$$;

-- La anonimización admite una sola transición, conserva el hecho que la
-- autorizó y evita que una actualización ordinaria reidentifique al cliente.
CREATE OR REPLACE FUNCTION iqg_core.tg_validar_anonimizacion_cliente()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = iqg_core, pg_temp
AS $$
BEGIN
    IF TG_OP <> 'UPDATE' THEN
        RETURN NEW;
    END IF;

    IF OLD.anonimizado_en IS NOT NULL
       OR OLD.anonimizacion_solicitud_id IS NOT NULL THEN
        RAISE EXCEPTION 'Un cliente anonimizado no puede volver a modificarse';
    END IF;

    IF NEW.anonimizacion_solicitud_id IS NULL THEN
        IF NEW.anonimizado_en IS NOT NULL THEN
            RAISE EXCEPTION
                'anonimizado_en requiere una solicitud de anonimización';
        END IF;
        RETURN NEW;
    END IF;

    IF current_user <> 'iqg_owner' THEN
        RAISE EXCEPTION
            'Solo la ruta controlada de anonimización puede sustituir datos personales';
    END IF;

    IF (to_jsonb(NEW) - ARRAY[
            'nombre_mostrar_cifrado',
            'identificador_externo_cifrado',
            'correo_electronico_cifrado',
            'telefono_cifrado',
            'referencia_clave_operativa_externa',
            'consentimiento_comercial_cifrado',
            'activo',
            'anonimizado_en',
            'anonimizacion_solicitud_id'
        ]::text[])
       IS DISTINCT FROM
       (to_jsonb(OLD) - ARRAY[
            'nombre_mostrar_cifrado',
            'identificador_externo_cifrado',
            'correo_electronico_cifrado',
            'telefono_cifrado',
            'referencia_clave_operativa_externa',
            'consentimiento_comercial_cifrado',
            'activo',
            'anonimizado_en',
            'anonimizacion_solicitud_id'
        ]::text[]) THEN
        RAISE EXCEPTION
            'La anonimización solo puede cambiar datos personales y sus metadatos legales';
    END IF;

    PERFORM 1
      FROM iqg_core.anonimizacion_solicitud AS a
     WHERE a.company_id = NEW.company_id
       AND a.branch_id = NEW.branch_id
       AND a.anonimizacion_solicitud_id = NEW.anonimizacion_solicitud_id
       AND a.cliente_id = NEW.cliente_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'La solicitud de anonimización no corresponde al cliente y alcance indicados';
    END IF;

    -- La fecha de anonimización la fija el servidor, nunca el invocador.
    NEW.anonimizado_en := clock_timestamp();
    RETURN NEW;
END;
$$;

-- registro_cambios permanece append-only salvo una excepción legal única y
-- verificable: retirar PII de snapshots de cliente ya vinculados a una
-- solicitud de anonimización. No se permite DELETE bajo ninguna circunstancia.
CREATE OR REPLACE FUNCTION iqg_core.tg_proteger_registro_cambios()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = iqg_core, pg_temp
AS $$
DECLARE
    v_claves_pii text[] := ARRAY[
        'nombre_mostrar_cifrado',
        'identificador_externo_cifrado',
        'correo_electronico_cifrado',
        'telefono_cifrado',
        'referencia_clave_operativa_externa',
        'consentimiento_comercial_cifrado'
    ]::text[];
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'registro_cambios no permite DELETE';
    END IF;

    IF current_user <> 'iqg_owner'
       OR OLD.redaccion_solicitud_id IS NOT NULL
       OR NEW.redaccion_solicitud_id IS NULL
       OR NEW.redactado_por_usuario_id IS DISTINCT FROM iqg_core.contexto_usuario_id()
       OR NEW.redactado_en IS NOT NULL
       OR NEW.tabla_origen <> 'iqg_core.cliente'
       OR NEW.registro_id IS NULL THEN
        RAISE EXCEPTION
            'registro_cambios solo permite una redacción legal controlada de datos de cliente';
    END IF;

    IF (to_jsonb(NEW) - ARRAY[
            'datos_antes',
            'datos_despues',
            'motivo_codigo',
            'redactado_en',
            'redactado_por_usuario_id',
            'redaccion_solicitud_id'
        ]::text[])
       IS DISTINCT FROM
       (to_jsonb(OLD) - ARRAY[
            'datos_antes',
            'datos_despues',
            'motivo_codigo',
            'redactado_en',
            'redactado_por_usuario_id',
            'redaccion_solicitud_id'
        ]::text[]) THEN
        RAISE EXCEPTION
            'La redacción no puede modificar alcance, identidad, operación ni procedencia de auditoría';
    END IF;

    IF NEW.datos_antes IS DISTINCT FROM (OLD.datos_antes - v_claves_pii)
       OR NEW.datos_despues IS DISTINCT FROM (OLD.datos_despues - v_claves_pii)
       OR NEW.motivo_codigo IS DISTINCT FROM 'REDACTADO_PRIVACIDAD' THEN
        RAISE EXCEPTION
            'La redacción debe retirar exclusivamente los campos personales definidos';
    END IF;

    PERFORM 1
      FROM iqg_core.anonimizacion_solicitud AS a
     WHERE a.company_id = OLD.company_id
       AND a.branch_id = OLD.branch_id
       AND a.anonimizacion_solicitud_id = NEW.redaccion_solicitud_id
       AND a.cliente_id = OLD.registro_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'La solicitud de redacción no corresponde al registro de cliente auditado';
    END IF;

    NEW.redactado_en := clock_timestamp();
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
        direccion_ip_cifrada,
        direccion_ip_clave_referencia,
        direccion_ip_version_sobre,
        actor_tipo_codigo,
        tabla_origen,
        operacion_dml,
        registro_id,
        motivo_codigo,
        datos_antes,
        datos_despues
    ) VALUES (
        v_company,
        v_branch,
        iqg_core.contexto_usuario_id(),
        iqg_core.contexto_correlation_id(),
        iqg_core.contexto_direccion_ip_cifrada(),
        iqg_core.contexto_direccion_ip_clave_referencia(),
        iqg_core.contexto_direccion_ip_version_sobre(),
        iqg_core.contexto_actor_tipo(),
        TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME,
        TG_OP,
        v_registro,
        iqg_core.contexto_motivo_codigo(),
        v_antes,
        v_despues
    );

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION iqg_fiscal.tg_registrar_cambio()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = iqg_core, iqg_fiscal, pg_temp
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

    INSERT INTO iqg_fiscal.registro_cambios (
        company_id,
        branch_id,
        creado_por_usuario_id,
        correlation_id,
        direccion_ip_cifrada,
        direccion_ip_clave_referencia,
        direccion_ip_version_sobre,
        actor_tipo_codigo,
        tabla_origen,
        operacion_dml,
        registro_id,
        motivo_codigo,
        datos_antes,
        datos_despues
    ) VALUES (
        v_company,
        v_branch,
        iqg_core.contexto_usuario_id(),
        iqg_core.contexto_correlation_id(),
        iqg_core.contexto_direccion_ip_cifrada(),
        iqg_core.contexto_direccion_ip_clave_referencia(),
        iqg_core.contexto_direccion_ip_version_sobre(),
        iqg_core.contexto_actor_tipo(),
        TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME,
        TG_OP,
        v_registro,
        iqg_core.contexto_motivo_codigo(),
        v_antes,
        v_despues
    );

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;
    RETURN NEW;
END;
$$;

-- Crea únicamente categorías universales de códigos. Los valores operativos
-- siguen siendo configurables por empresa; la moneda elegida al alta y un
-- motivo legal seguro se registran para que las rutas base sean utilizables.
CREATE OR REPLACE FUNCTION iqg_core.asegurar_dominios_base(
    p_company_id uuid,
    p_branch_id uuid,
    p_usuario_id uuid,
    p_moneda_codigo varchar,
    p_regimen_fiscal_codigo varchar
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = iqg_core, pg_temp
AS $$
BEGIN
    IF p_company_id IS DISTINCT FROM iqg_core.contexto_company_id()
       OR p_branch_id IS DISTINCT FROM iqg_core.contexto_branch_id()
       OR p_usuario_id IS DISTINCT FROM iqg_core.contexto_usuario_id() THEN
        RAISE EXCEPTION
            'Los catálogos base solo pueden crearse dentro del contexto autenticado de su empresa y sucursal';
    END IF;

    PERFORM iqg_core.exigir_contexto_membresia_activa();

    INSERT INTO iqg_core.dominio (
        company_id, branch_id, creado_por_usuario_id, codigo, nombre
    )
    VALUES
        (p_company_id, p_branch_id, p_usuario_id, 'TIPO_ELEMENTO', 'Tipo de elemento'),
        (p_company_id, p_branch_id, p_usuario_id, 'UNIDAD_MEDIDA', 'Unidad de medida'),
        (p_company_id, p_branch_id, p_usuario_id, 'MONEDA', 'Moneda'),
        (p_company_id, p_branch_id, p_usuario_id, 'ENTIDAD_ESTADO', 'Entidad de estado'),
        (p_company_id, p_branch_id, p_usuario_id, 'TIPO_OPERACION', 'Tipo de operación'),
        (p_company_id, p_branch_id, p_usuario_id, 'MEDIO_PAGO', 'Medio de pago'),
        (p_company_id, p_branch_id, p_usuario_id, 'TIPO_MOVIMIENTO_CAJA', 'Tipo de movimiento de caja'),
        (p_company_id, p_branch_id, p_usuario_id, 'TIPO_MOVIMIENTO_INVENTARIO', 'Tipo de movimiento de inventario'),
        (p_company_id, p_branch_id, p_usuario_id, 'UBICACION', 'Ubicación'),
        (p_company_id, p_branch_id, p_usuario_id, 'MOTIVO_ANONIMIZACION', 'Motivo de anonimización'),
        (p_company_id, p_branch_id, p_usuario_id, 'MOTIVO_CAMBIO', 'Motivo codificado de cambio'),
        (p_company_id, p_branch_id, p_usuario_id, 'REGIMEN_FISCAL', 'Régimen fiscal'),
        (p_company_id, p_branch_id, p_usuario_id, 'TIPO_DOCUMENTO_FISCAL', 'Tipo de documento fiscal'),
        (p_company_id, p_branch_id, p_usuario_id, 'ESTADO_FACTURA_FISCAL', 'Estado de factura fiscal'),
        (p_company_id, p_branch_id, p_usuario_id, 'TIPO_XML_FISCAL', 'Tipo de XML fiscal')
    ON CONFLICT (company_id, codigo) DO NOTHING;

    INSERT INTO iqg_core.dominio_valor (
        company_id, branch_id, creado_por_usuario_id,
        dominio_codigo, codigo, nombre
    )
    VALUES
        (p_company_id, p_branch_id, p_usuario_id,
         'MONEDA', upper(p_moneda_codigo), upper(p_moneda_codigo)),
        (p_company_id, p_branch_id, p_usuario_id,
         'MOTIVO_ANONIMIZACION', 'DERECHO_SUPRESION', 'Derecho de supresión'),
        (p_company_id, p_branch_id, p_usuario_id,
         'MOTIVO_CAMBIO', 'PROVISION_INICIAL', 'Provisión inicial'),
        (p_company_id, p_branch_id, p_usuario_id,
         'MOTIVO_CAMBIO', 'REDACTADO_PRIVACIDAD', 'Redactado por privacidad'),
        (p_company_id, p_branch_id, p_usuario_id,
         'ESTADO_FACTURA_FISCAL', 'PENDIENTE_EMISOR', 'Pendiente de emisor externo'),
        (p_company_id, p_branch_id, p_usuario_id,
         'ESTADO_FACTURA_FISCAL', 'EMITIDA', 'Documento fiscal emitido'),
        (p_company_id, p_branch_id, p_usuario_id,
         'ESTADO_FACTURA_FISCAL', 'RECHAZADA', 'Documento fiscal rechazado')
    ON CONFLICT (company_id, dominio_codigo, codigo) DO NOTHING;

    -- El régimen inicial llega en la provisión antes de que exista el catálogo
    -- del tenant. Se registra dentro de la misma transacción; después de este
    -- punto, todo uso fiscal debe pasar por el validador de dominio activo.
    IF p_regimen_fiscal_codigo IS NOT NULL THEN
        INSERT INTO iqg_core.dominio_valor (
            company_id, branch_id, creado_por_usuario_id,
            dominio_codigo, codigo, nombre
        ) VALUES (
            p_company_id, p_branch_id, p_usuario_id,
            'REGIMEN_FISCAL', upper(p_regimen_fiscal_codigo),
            upper(p_regimen_fiscal_codigo)
        )
        ON CONFLICT (company_id, dominio_codigo, codigo) DO NOTHING;
    END IF;
END;
$$;

-- Roles/permisos base universales. La asignación continúa siendo por sucursal
-- para conservar mínimo privilegio operativo, mientras la definición se
-- comparte en toda la empresa. Todos los INSERT usan ON CONFLICT DO NOTHING.
CREATE OR REPLACE FUNCTION iqg_core.asegurar_roles_base(
    p_company_id uuid,
    p_branch_id uuid,
    p_usuario_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = iqg_core, pg_temp
AS $$
DECLARE
    v_rol_administrador_id uuid;
    v_usuario_sucursal_id uuid;
BEGIN
    IF p_company_id IS DISTINCT FROM iqg_core.contexto_company_id()
       OR p_branch_id IS DISTINCT FROM iqg_core.contexto_branch_id()
       OR p_usuario_id IS DISTINCT FROM iqg_core.contexto_usuario_id() THEN
        RAISE EXCEPTION
            'Los roles base solo pueden crearse dentro del contexto autenticado de su empresa y sucursal';
    END IF;

    PERFORM iqg_core.exigir_contexto_membresia_activa();

    INSERT INTO iqg_core.rol (
        company_id, branch_id, creado_por_usuario_id, codigo, nombre, descripcion
    )
    VALUES
        (p_company_id, p_branch_id, p_usuario_id,
         'ADMINISTRADOR_EMPRESA', 'Administrador de empresa',
         'Rol corporativo inicial con permisos administrativos explícitos.'),
        (p_company_id, p_branch_id, p_usuario_id,
         'OPERADOR', 'Operador',
         'Rol operativo universal; los permisos se asignan explícitamente.'),
        (p_company_id, p_branch_id, p_usuario_id,
         'LECTURA', 'Lectura',
         'Rol de consulta universal; los permisos se asignan explícitamente.')
    ON CONFLICT (company_id, codigo) DO NOTHING;

    INSERT INTO iqg_core.permiso (
        company_id, branch_id, creado_por_usuario_id,
        recurso_codigo, accion_codigo, descripcion
    )
    VALUES
        (p_company_id, p_branch_id, p_usuario_id,
         'SISTEMA', 'ADMINISTRAR',
         'Administración corporativa mediante rutas de dominio autorizadas.'),
        (p_company_id, p_branch_id, p_usuario_id,
         'CLIENTE', 'ANONIMIZAR',
         'Sustituir datos personales mediante la ruta legal controlada.'),
        (p_company_id, p_branch_id, p_usuario_id,
         'FISCAL', 'CONFIGURAR',
         'Configurar una determinación fiscal versionada mediante ruta autorizada.'),
        (p_company_id, p_branch_id, p_usuario_id,
         'FISCAL', 'EMITIR',
         'Solicitar o completar emisión fiscal solo mediante un emisor externo autorizado.'),
        (p_company_id, p_branch_id, p_usuario_id,
         'FISCAL', 'CONSULTAR',
         'Consultar evidencia fiscal mediante una ruta de dominio autorizada.')
    ON CONFLICT (company_id, recurso_codigo, accion_codigo) DO NOTHING;

    SELECT r.rol_id
      INTO v_rol_administrador_id
      FROM iqg_core.rol AS r
     WHERE r.company_id = p_company_id
       AND r.codigo = 'ADMINISTRADOR_EMPRESA'
       AND r.activo = true
     FOR KEY SHARE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se pudo asegurar el rol ADMINISTRADOR_EMPRESA';
    END IF;

    INSERT INTO iqg_core.rol_permiso (
        company_id, branch_id, creado_por_usuario_id, rol_id, permiso_id
    )
    SELECT
        p_company_id,
        p_branch_id,
        p_usuario_id,
        v_rol_administrador_id,
        p.permiso_id
      FROM iqg_core.permiso AS p
     WHERE p.company_id = p_company_id
       AND (p.recurso_codigo, p.accion_codigo) IN (
            ('SISTEMA', 'ADMINISTRAR'),
            ('CLIENTE', 'ANONIMIZAR'),
            ('FISCAL', 'CONFIGURAR'),
            ('FISCAL', 'EMITIR'),
            ('FISCAL', 'CONSULTAR')
       )
       AND p.activo = true
    ON CONFLICT (company_id, rol_id, permiso_id) DO NOTHING;

    SELECT us.usuario_sucursal_id
      INTO v_usuario_sucursal_id
      FROM iqg_core.usuario_sucursal AS us
     WHERE us.company_id = p_company_id
       AND us.branch_id = p_branch_id
       AND us.usuario_id = p_usuario_id
       AND us.activo = true
     FOR KEY SHARE;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'El fundador debe tener una membresía activa antes de recibir el rol base';
    END IF;

    INSERT INTO iqg_core.usuario_rol (
        company_id, branch_id, creado_por_usuario_id,
        usuario_sucursal_id, rol_id
    )
    VALUES (
        p_company_id,
        p_branch_id,
        p_usuario_id,
        v_usuario_sucursal_id,
        v_rol_administrador_id
    )
    ON CONFLICT (company_id, branch_id, usuario_sucursal_id, rol_id) DO NOTHING;
END;
$$;

-- Punto de entrada legal interno. No recibe company/branch/usuario como
-- parámetros: conserva y vuelve a fijar el contexto ya ligado por middleware
-- confiable, valida la membresía y el permiso antes de tocar datos. No se
-- concede a iqg_app hasta que el middleware autenticado esté integrado.
CREATE OR REPLACE FUNCTION iqg_core.anonimizar_cliente(
    p_cliente_id uuid,
    p_confirmacion_destruccion_externa uuid,
    p_motivo_codigo varchar DEFAULT 'DERECHO_SUPRESION'
)
RETURNS TABLE (
    anonimizacion_solicitud_id uuid,
    cliente_id uuid,
    anonimizado_en timestamptz,
    ya_anonimizado boolean
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = iqg_core, pg_temp
AS $$
DECLARE
    v_company_id uuid := iqg_core.contexto_company_id();
    v_branch_id uuid := iqg_core.contexto_branch_id();
    v_usuario_id uuid := iqg_core.contexto_usuario_id();
    v_actor_tipo varchar := iqg_core.contexto_actor_tipo();
    v_correlation_id uuid := iqg_core.contexto_correlation_id();
    v_direccion_ip_cifrada bytea := iqg_core.contexto_direccion_ip_cifrada();
    v_direccion_ip_clave_referencia uuid :=
        iqg_core.contexto_direccion_ip_clave_referencia();
    v_direccion_ip_version_sobre smallint :=
        iqg_core.contexto_direccion_ip_version_sobre();
    v_solicitud_id uuid;
    v_anonimizado_en timestamptz;
BEGIN
    IF p_cliente_id IS NULL
       OR v_company_id IS NULL
       OR v_branch_id IS NULL
       OR v_usuario_id IS NULL
       OR p_confirmacion_destruccion_externa IS NULL
       OR p_motivo_codigo IS NULL
       OR upper(p_motivo_codigo) !~ '^[A-Z][A-Z0-9_]{0,63}$' THEN
        RAISE EXCEPTION
            'La anonimización requiere cliente, motivo codificado y contexto autenticado válido';
    END IF;

    -- El contexto solo es una variable de trabajo: el puente autenticado debe
    -- haberlo ligado a la identidad antes de permitir esta función. Ninguna
    -- aplicación recibe EXECUTE mientras ese puente no esté revisado.
    PERFORM set_config('iqg.company_id', v_company_id::text, true);
    PERFORM set_config('iqg.branch_id', v_branch_id::text, true);
    PERFORM set_config('iqg.usuario_id', v_usuario_id::text, true);
    PERFORM set_config('iqg.actor_tipo', v_actor_tipo, true);
    PERFORM set_config('iqg.correlation_id', COALESCE(v_correlation_id::text, ''), true);
    PERFORM set_config(
        'iqg.direccion_ip_cifrada',
        CASE WHEN v_direccion_ip_cifrada IS NULL THEN '' ELSE encode(v_direccion_ip_cifrada, 'hex') END,
        true
    );
    PERFORM set_config(
        'iqg.direccion_ip_clave_referencia',
        COALESCE(v_direccion_ip_clave_referencia::text, ''),
        true
    );
    PERFORM set_config(
        'iqg.direccion_ip_version_sobre',
        COALESCE(v_direccion_ip_version_sobre::text, ''),
        true
    );
    PERFORM set_config('iqg.motivo_codigo', 'ANONIMIZACION_PRIVACIDAD', true);

    PERFORM iqg_core.exigir_contexto_membresia_activa();

    IF NOT iqg_core.contexto_tiene_permiso('CLIENTE', 'ANONIMIZAR')
       AND NOT iqg_core.contexto_tiene_permiso('SISTEMA', 'ADMINISTRAR') THEN
        RAISE EXCEPTION
            'El actor no tiene el permiso CLIENTE/ANONIMIZAR';
    END IF;

    PERFORM 1
      FROM iqg_core.dominio_valor AS dv
      JOIN iqg_core.dominio AS d
        ON d.company_id = dv.company_id
       AND d.codigo = dv.dominio_codigo
     WHERE dv.company_id = v_company_id
       AND dv.dominio_codigo = 'MOTIVO_ANONIMIZACION'
       AND dv.codigo = upper(p_motivo_codigo)
       AND dv.activo = true
       AND d.activo = true
     FOR KEY SHARE OF dv, d;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'El motivo de anonimización no está activo en el catálogo de la empresa';
    END IF;

    SELECT c.anonimizacion_solicitud_id, c.anonimizado_en
      INTO v_solicitud_id, v_anonimizado_en
      FROM iqg_core.cliente AS c
     WHERE c.company_id = v_company_id
       AND c.branch_id = v_branch_id
       AND c.cliente_id = p_cliente_id
     FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El cliente no existe en el alcance del contexto';
    END IF;

    IF v_solicitud_id IS NOT NULL THEN
        RETURN QUERY
        SELECT v_solicitud_id, p_cliente_id, v_anonimizado_en, true;
        RETURN;
    END IF;

    -- No se destruye la evidencia operativa mientras exista un documento
    -- fiscal pendiente que todavía deba materializarse por el emisor externo.
    -- Una vez emitido, el XML fiscal cifrado queda retenido en su capa propia.
    PERFORM 1
      FROM iqg_fiscal.factura AS f
      JOIN iqg_core.operacion AS o
        ON o.company_id = f.company_id
       AND o.branch_id = f.branch_id
       AND o.operacion_id = f.operacion_id
     WHERE f.company_id = v_company_id
       AND f.branch_id = v_branch_id
       AND o.cliente_id = p_cliente_id
       AND f.estado_emision_codigo = 'PENDIENTE_EMISOR'
     FOR KEY SHARE OF f;

    IF FOUND THEN
        RAISE EXCEPTION
            'No se puede anonimizar un cliente con una factura fiscal pendiente de materialización';
    END IF;

    INSERT INTO iqg_core.anonimizacion_solicitud (
        company_id, branch_id, creado_por_usuario_id, cliente_id, motivo_codigo,
        confirmacion_destruccion_externa
    )
    VALUES (
        v_company_id, v_branch_id, v_usuario_id, p_cliente_id, upper(p_motivo_codigo),
        p_confirmacion_destruccion_externa
    )
    RETURNING anonimizacion_solicitud_id INTO v_solicitud_id;

    UPDATE iqg_core.cliente
       SET nombre_mostrar_cifrado = NULL,
           identificador_externo_cifrado = NULL,
           correo_electronico_cifrado = NULL,
           telefono_cifrado = NULL,
           referencia_clave_operativa_externa = NULL,
           consentimiento_comercial_cifrado = NULL,
           activo = false,
           anonimizado_en = NULL,
           anonimizacion_solicitud_id = v_solicitud_id
     WHERE company_id = v_company_id
       AND branch_id = v_branch_id
       AND cliente_id = p_cliente_id
     RETURNING anonimizado_en INTO v_anonimizado_en;

    -- Incluye la fila de auditoría generada por el UPDATE anterior. La
    -- transacción no se confirma hasta que todos los snapshots hayan quedado
    -- redactados; otra sesión nunca observa PII intermedio confirmado.
    UPDATE iqg_core.registro_cambios
       SET datos_antes = datos_antes - ARRAY[
               'nombre_mostrar_cifrado',
               'identificador_externo_cifrado',
               'correo_electronico_cifrado',
               'telefono_cifrado',
               'referencia_clave_operativa_externa',
               'consentimiento_comercial_cifrado'
           ]::text[],
           datos_despues = datos_despues - ARRAY[
               'nombre_mostrar_cifrado',
               'identificador_externo_cifrado',
               'correo_electronico_cifrado',
               'telefono_cifrado',
               'referencia_clave_operativa_externa',
               'consentimiento_comercial_cifrado'
           ]::text[],
            motivo_codigo = 'REDACTADO_PRIVACIDAD',
           redactado_en = NULL,
           redactado_por_usuario_id = v_usuario_id,
           redaccion_solicitud_id = v_solicitud_id
     WHERE company_id = v_company_id
       AND branch_id = v_branch_id
       AND tabla_origen = 'iqg_core.cliente'
       AND registro_id = p_cliente_id
       AND redaccion_solicitud_id IS NULL;

    RETURN QUERY
    SELECT v_solicitud_id, p_cliente_id, v_anonimizado_en, false;
END;
$$;

-- Una empresa con facturación activa solo puede cerrar una operación mediante
-- un estado terminal que materialice su documento fiscal. La aplicación nunca
-- pregunta por operación: la determinación versionada decide en esta frontera.
CREATE OR REPLACE FUNCTION iqg_core.tg_validar_transicion_fiscal_operacion()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = iqg_core, pg_temp
AS $$
DECLARE
    v_es_terminal boolean;
    v_dispara boolean;
    v_entidad_codigo varchar(64);
    v_facturacion_activa boolean;
BEGIN
    SELECT e.es_terminal, e.dispara_emision_fiscal, e.entidad_codigo
      INTO v_es_terminal, v_dispara, v_entidad_codigo
      FROM iqg_core.estado AS e
     WHERE e.company_id = NEW.company_id
       AND e.branch_id = NEW.branch_id
       AND e.estado_id = NEW.estado_id
     FOR KEY SHARE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El estado de operación no existe en el alcance indicado';
    END IF;

    IF v_entidad_codigo IS DISTINCT FROM 'OPERACION' THEN
        RAISE EXCEPTION
            'El estado asignado a una operación debe pertenecer a la entidad OPERACION';
    END IF;

    -- Este candado corporativo se comparte con la política de empresa y el
    -- trigger de emisión; evita carreras entre sucursales sin abrir RLS.
    PERFORM pg_advisory_xact_lock(
        hashtextextended(NEW.company_id::text, 918273645)
    );

    SELECT e.facturacion_fiscal_activa
      INTO v_facturacion_activa
      FROM iqg_core.empresa AS e
     WHERE e.company_id = NEW.company_id
     ;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La empresa de la operación no existe';
    END IF;

    IF v_facturacion_activa AND v_es_terminal AND NOT v_dispara THEN
        RAISE EXCEPTION
            'Una operación terminal de una empresa con facturación fiscal activa requiere un estado que dispare emisión fiscal';
    END IF;

    RETURN NEW;
END;
$$;

-- Una línea fiscal es un snapshot exacto de una única línea de la misma
-- operación. Las FKs compuestas garantizan el tenant; esta regla cierra la
-- relación factura-operación que una FK aislada no puede expresar.
CREATE OR REPLACE FUNCTION iqg_fiscal.tg_validar_factura_linea_origen()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = iqg_core, iqg_fiscal, pg_temp
AS $$
DECLARE
    v_operacion_factura uuid;
    v_moneda_factura varchar(3);
    v_operacion_linea uuid;
    v_numero_linea integer;
    v_nombre text;
    v_unidad varchar(32);
    v_cantidad numeric(20, 6);
    v_moneda varchar(3);
    v_precio bigint;
    v_bruto bigint;
    v_descuento bigint;
    v_impuesto bigint;
    v_total bigint;
BEGIN
    SELECT f.operacion_id, f.moneda_codigo
      INTO v_operacion_factura, v_moneda_factura
      FROM iqg_fiscal.factura AS f
     WHERE f.company_id = NEW.company_id
       AND f.branch_id = NEW.branch_id
       AND f.factura_id = NEW.factura_id
     FOR KEY SHARE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La factura de la línea no existe en el alcance indicado';
    END IF;

    SELECT ol.operacion_id,
           ol.numero_linea,
           ol.nombre_elemento_snapshot,
           ol.unidad_medida_codigo,
           ol.cantidad,
           ol.moneda_codigo,
           ol.precio_unitario_menor,
           ol.importe_bruto_menor,
           ol.descuento_menor,
           ol.impuesto_menor,
           ol.importe_total_menor
      INTO v_operacion_linea,
           v_numero_linea,
           v_nombre,
           v_unidad,
           v_cantidad,
           v_moneda,
           v_precio,
           v_bruto,
           v_descuento,
           v_impuesto,
           v_total
      FROM iqg_core.operacion_linea AS ol
     WHERE ol.company_id = NEW.company_id
       AND ol.branch_id = NEW.branch_id
       AND ol.operacion_linea_id = NEW.operacion_linea_id
     FOR KEY SHARE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La línea operativa fiscalizada no existe en el alcance indicado';
    END IF;

    IF v_operacion_linea IS DISTINCT FROM v_operacion_factura
       OR NEW.numero_linea IS DISTINCT FROM v_numero_linea
       OR NEW.moneda_codigo IS DISTINCT FROM v_moneda_factura
       OR NEW.descripcion_elemento_snapshot IS DISTINCT FROM v_nombre
       OR NEW.unidad_medida_codigo IS DISTINCT FROM v_unidad
       OR NEW.cantidad IS DISTINCT FROM v_cantidad
       OR NEW.moneda_codigo IS DISTINCT FROM v_moneda
       OR NEW.precio_unitario_menor IS DISTINCT FROM v_precio
       OR NEW.importe_bruto_menor IS DISTINCT FROM v_bruto
       OR NEW.descuento_menor IS DISTINCT FROM v_descuento
       OR NEW.impuesto_menor IS DISTINCT FROM v_impuesto
       OR NEW.importe_total_menor IS DISTINCT FROM v_total THEN
        RAISE EXCEPTION
            'La línea fiscal debe ser el snapshot exacto de una línea de la operación de su factura';
    END IF;

    RETURN NEW;
END;
$$;

-- Constraint trigger diferido: al COMMIT comprueba que el documento tiene al
-- menos una línea y que sus totales son exactamente la suma de snapshots.
CREATE OR REPLACE FUNCTION iqg_fiscal.tg_verificar_totales_factura()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = iqg_core, iqg_fiscal, pg_temp
AS $$
DECLARE
    v_factura_id uuid;
    v_company_id uuid;
    v_branch_id uuid;
    v_bruto_factura bigint;
    v_descuento_factura bigint;
    v_impuesto_factura bigint;
    v_total_factura bigint;
    v_cantidad_lineas bigint;
    v_bruto_lineas bigint;
    v_descuento_lineas bigint;
    v_impuesto_lineas bigint;
    v_total_lineas bigint;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_factura_id := OLD.factura_id;
        v_company_id := OLD.company_id;
        v_branch_id := OLD.branch_id;
    ELSE
        v_factura_id := NEW.factura_id;
        v_company_id := NEW.company_id;
        v_branch_id := NEW.branch_id;
    END IF;

    SELECT f.importe_bruto_menor,
           f.descuento_menor,
           f.impuesto_menor,
           f.importe_total_menor
      INTO v_bruto_factura,
           v_descuento_factura,
           v_impuesto_factura,
           v_total_factura
      FROM iqg_fiscal.factura AS f
     WHERE f.company_id = v_company_id
       AND f.branch_id = v_branch_id
       AND f.factura_id = v_factura_id
     FOR KEY SHARE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No existe factura para verificar sus líneas';
    END IF;

    SELECT count(*),
           COALESCE(sum(fl.importe_bruto_menor), 0),
           COALESCE(sum(fl.descuento_menor), 0),
           COALESCE(sum(fl.impuesto_menor), 0),
           COALESCE(sum(fl.importe_total_menor), 0)
      INTO v_cantidad_lineas,
           v_bruto_lineas,
           v_descuento_lineas,
           v_impuesto_lineas,
           v_total_lineas
      FROM iqg_fiscal.factura_linea AS fl
     WHERE fl.company_id = v_company_id
       AND fl.branch_id = v_branch_id
       AND fl.factura_id = v_factura_id;

    IF v_cantidad_lineas = 0
       OR v_bruto_lineas IS DISTINCT FROM v_bruto_factura
       OR v_descuento_lineas IS DISTINCT FROM v_descuento_factura
       OR v_impuesto_lineas IS DISTINCT FROM v_impuesto_factura
       OR v_total_lineas IS DISTINCT FROM v_total_factura THEN
        RAISE EXCEPTION
            'Las líneas de la factura deben existir y cuadrar exactamente con sus importes de cabecera';
    END IF;

    RETURN NULL;
END;
$$;

-- Materializa automáticamente la intención y el snapshot fiscal cuando una
-- transición de OPERACION configurada lo exige. No descifra, firma ni transmite:
-- esas acciones ocurren en el emisor externo operado por el titular. El candado
-- FOR UPDATE sobre operacion serializa el cierre contra inserciones de líneas.
CREATE OR REPLACE FUNCTION iqg_fiscal.tg_programar_factura_desde_estado()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = iqg_core, iqg_fiscal, pg_temp
AS $$
DECLARE
    v_dispara boolean;
    v_tipo_documento varchar(64);
    v_facturacion_activa boolean;
    v_obligatoria boolean;
    v_pais char(2);
    v_regimen varchar(64);
    v_version_regla varchar(64);
    v_retencion_anios smallint;
    v_identificador_fiscal_cifrado bytea;
    v_referencia_clave_fiscal uuid;
    v_version_sobre_fiscal smallint;
    v_moneda varchar(3);
    v_cantidad_lineas bigint;
    v_importe_bruto bigint;
    v_descuento bigint;
    v_impuesto bigint;
    v_importe_total bigint;
    v_factura_id uuid;
    v_fecha_solicitud timestamptz := clock_timestamp();
BEGIN
    SELECT e.dispara_emision_fiscal, e.tipo_documento_fiscal_codigo
      INTO v_dispara, v_tipo_documento
      FROM iqg_core.estado AS e
     WHERE e.company_id = NEW.company_id
       AND e.branch_id = NEW.branch_id
       AND e.estado_id = NEW.estado_id
     FOR KEY SHARE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El estado de operación no existe en el alcance indicado';
    END IF;

    IF NOT v_dispara THEN
        RETURN NEW;
    END IF;

    -- El bloqueo es la frontera de concurrencia con tg_validar_operacion_linea.
    SELECT o.moneda_codigo
      INTO v_moneda
      FROM iqg_core.operacion AS o
     WHERE o.company_id = NEW.company_id
       AND o.branch_id = NEW.branch_id
       AND o.operacion_id = NEW.operacion_id
     FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La operación fiscalizable no existe en el alcance indicado';
    END IF;

    -- Comparte un candado corporativo con tg_aplicar_politica_fiscal_empresa:
    -- ninguna emisión puede capturar una configuración a medio cambiar.
    PERFORM pg_advisory_xact_lock(
        hashtextextended(NEW.company_id::text, 918273645)
    );

    SELECT e.facturacion_fiscal_activa,
           e.esta_obligado_a_facturar,
           e.pais_codigo,
           e.regimen_fiscal_codigo,
           e.version_regla_fiscal,
           e.retencion_fiscal_anios,
           e.identificador_fiscal_cifrado,
           e.referencia_clave_operativa_externa,
           e.version_sobre_cifrado
      INTO v_facturacion_activa,
           v_obligatoria,
           v_pais,
           v_regimen,
           v_version_regla,
           v_retencion_anios,
           v_identificador_fiscal_cifrado,
           v_referencia_clave_fiscal,
           v_version_sobre_fiscal
      FROM iqg_core.empresa AS e
     WHERE e.company_id = NEW.company_id
     ;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La empresa de la operación fiscalizable no existe';
    END IF;

    -- Privacidad por defecto: no hay factura, XML ni evento fiscal para un
    -- tenant sin obligación ni elección voluntaria.
    IF NOT v_facturacion_activa THEN
        RETURN NEW;
    END IF;

    IF v_pais NOT IN ('BO', 'PE', 'BR', 'AR')
       OR v_regimen IS NULL
       OR v_version_regla IS NULL
       OR v_retencion_anios NOT IN (5, 10)
       OR v_identificador_fiscal_cifrado IS NULL
       OR v_referencia_clave_fiscal IS NULL
       OR v_version_sobre_fiscal IS NULL THEN
        RAISE EXCEPTION
            'La emisión fiscal requiere una política de país y régimen aprobada';
    END IF;

    SELECT count(*),
           COALESCE(sum(ol.importe_bruto_menor), 0),
           COALESCE(sum(ol.descuento_menor), 0),
           COALESCE(sum(ol.impuesto_menor), 0),
           COALESCE(sum(ol.importe_total_menor), 0)
      INTO v_cantidad_lineas,
           v_importe_bruto,
           v_descuento,
           v_impuesto,
           v_importe_total
      FROM iqg_core.operacion_linea AS ol
     WHERE ol.company_id = NEW.company_id
       AND ol.branch_id = NEW.branch_id
       AND ol.operacion_id = NEW.operacion_id;

    IF v_cantidad_lineas = 0 THEN
        RAISE EXCEPTION
            'Una operación fiscalizable requiere al menos una línea antes de emitir';
    END IF;

    INSERT INTO iqg_fiscal.factura (
        company_id,
        branch_id,
        creado_por_usuario_id,
        operacion_id,
        tipo_documento_fiscal_codigo,
        pais_codigo_emision,
        regimen_fiscal_codigo_emision,
        version_regla_fiscal,
        identificador_fiscal_cifrado_snapshot,
        referencia_clave_fiscal_externa,
        version_sobre_fiscal,
        es_emision_obligatoria,
        moneda_codigo,
        importe_bruto_menor,
        descuento_menor,
        impuesto_menor,
        importe_total_menor,
        fecha_solicitud_emision,
        retencion_fiscal_anios
    ) VALUES (
        NEW.company_id,
        NEW.branch_id,
        NEW.creado_por_usuario_id,
        NEW.operacion_id,
        v_tipo_documento,
        v_pais,
        v_regimen,
        v_version_regla,
        v_identificador_fiscal_cifrado,
        v_referencia_clave_fiscal,
        v_version_sobre_fiscal,
        v_obligatoria,
        v_moneda,
        v_importe_bruto,
        v_descuento,
        v_impuesto,
        v_importe_total,
        v_fecha_solicitud,
        v_retencion_anios
    )
    ON CONFLICT (company_id, branch_id, operacion_id) DO NOTHING
    RETURNING factura_id INTO v_factura_id;

    IF v_factura_id IS NULL THEN
        RETURN NEW;
    END IF;

    INSERT INTO iqg_fiscal.factura_linea (
        company_id,
        branch_id,
        creado_por_usuario_id,
        factura_id,
        operacion_linea_id,
        numero_linea,
        descripcion_elemento_snapshot,
        unidad_medida_codigo,
        cantidad,
        moneda_codigo,
        precio_unitario_menor,
        importe_bruto_menor,
        descuento_menor,
        impuesto_menor,
        importe_total_menor
    )
    SELECT
        ol.company_id,
        ol.branch_id,
        NEW.creado_por_usuario_id,
        v_factura_id,
        ol.operacion_linea_id,
        ol.numero_linea,
        ol.nombre_elemento_snapshot,
        ol.unidad_medida_codigo,
        ol.cantidad,
        ol.moneda_codigo,
        ol.precio_unitario_menor,
        ol.importe_bruto_menor,
        ol.descuento_menor,
        ol.impuesto_menor,
        ol.importe_total_menor
      FROM iqg_core.operacion_linea AS ol
     WHERE ol.company_id = NEW.company_id
       AND ol.branch_id = NEW.branch_id
       AND ol.operacion_id = NEW.operacion_id
     ORDER BY ol.numero_linea;

    INSERT INTO iqg_fiscal.evento_emision_factura (
        company_id,
        branch_id,
        creado_por_usuario_id,
        factura_id,
        clave_idempotencia
    ) VALUES (
        NEW.company_id,
        NEW.branch_id,
        NEW.creado_por_usuario_id,
        v_factura_id,
        v_factura_id
    );

    INSERT INTO iqg_core.fiscal_configuracion_bloqueada (
        company_id,
        branch_id,
        creado_por_usuario_id,
        factura_id
    ) VALUES (
        NEW.company_id,
        NEW.branch_id,
        NEW.creado_por_usuario_id,
        v_factura_id
    )
    ON CONFLICT (company_id) DO NOTHING;

    RETURN NEW;
END;
$$;

-- Una factura conserva su snapshot y retención. Solo existe una transición de
-- estado, controlada por una futura ruta SECURITY DEFINER del emisor fiscal; el
-- XML, firmas y acuses se agregan como filas nuevas y nunca se sobrescriben.
CREATE OR REPLACE FUNCTION iqg_fiscal.tg_proteger_factura()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = iqg_core, iqg_fiscal, pg_temp
AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'factura no permite DELETE; use un documento fiscal relacionado de corrección';
    END IF;

    IF current_user <> 'iqg_owner'
       OR OLD.estado_emision_codigo <> 'PENDIENTE_EMISOR'
       OR NEW.estado_emision_codigo NOT IN ('EMITIDA', 'RECHAZADA')
       OR NEW.fecha_emision_confirmada IS NOT NULL
       OR NEW.retener_hasta IS NOT NULL THEN
        RAISE EXCEPTION
            'factura solo permite una transición fiscal controlada desde PENDIENTE_EMISOR';
    END IF;

    IF (to_jsonb(NEW) - ARRAY[
            'estado_emision_codigo',
            'fecha_emision_confirmada',
            'retener_hasta'
        ]::text[])
       IS DISTINCT FROM
       (to_jsonb(OLD) - ARRAY[
            'estado_emision_codigo',
            'fecha_emision_confirmada',
            'retener_hasta'
        ]::text[]) THEN
        RAISE EXCEPTION
            'La transición fiscal no puede alterar el snapshot, importes, país, régimen ni retención';
    END IF;

    NEW.fecha_emision_confirmada := clock_timestamp();
    NEW.retener_hasta := (
        NEW.fecha_emision_confirmada
        + make_interval(years => NEW.retencion_fiscal_anios)
    )::date;
    RETURN NEW;
END;
$$;

-- El outbox conserva el evento original; solo su resultado técnico puede
-- completarse una vez, sin alterar destino, tenant ni idempotencia.
CREATE OR REPLACE FUNCTION iqg_fiscal.tg_proteger_evento_emision_factura()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = iqg_core, iqg_fiscal, pg_temp
AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'evento_emision_factura no permite DELETE';
    END IF;

    IF current_user <> 'iqg_owner'
       OR OLD.procesado_en IS NOT NULL
       OR NEW.entregado_en IS NOT NULL
       OR NEW.procesado_en IS NOT NULL
       OR NEW.resultado_codigo IS NULL
       OR (
            NEW.resultado_codigo <> 'DOCUMENTO_GENERADO'
            AND NEW.resultado_codigo !~ '^EMISION_RECHAZADA(_[A-Z0-9_]{1,40})?$'
       ) THEN
        RAISE EXCEPTION
            'El resultado del evento fiscal solo puede completarse una vez por una ruta controlada';
    END IF;

    IF (to_jsonb(NEW) - ARRAY[
            'entregado_en',
            'procesado_en',
            'resultado_codigo'
        ]::text[])
       IS DISTINCT FROM
       (to_jsonb(OLD) - ARRAY[
            'entregado_en',
            'procesado_en',
            'resultado_codigo'
        ]::text[]) THEN
        RAISE EXCEPTION 'No se puede alterar la identidad ni el destino de un evento fiscal';
    END IF;

    NEW.entregado_en := clock_timestamp();
    NEW.procesado_en := NEW.entregado_en;
    RETURN NEW;
END;
$$;

-- Ruta de dominio reservada para un emisor fiscal externo del titular. Registra
-- un documento generado, no una aceptación del fisco: la aceptación exige un
-- acuse verificable separado. Acepta exclusivamente ciphertext y metadatos no
-- secretos; no recibe claves ni PII.
-- No se concede a iqg_app ni iqg_gateway hasta que el puente autenticado tenga
-- una identidad técnica revisada y un permiso FISCAL/EMITIR verificable.
CREATE OR REPLACE FUNCTION iqg_fiscal.completar_emision_factura(
    p_factura_id uuid,
    p_tipo_xml_codigo varchar,
    p_version_xml integer,
    p_xml_cifrado bytea,
    p_hash_sobre_cifrado_sha256 bytea,
    p_referencia_clave_fiscal_externa uuid,
    p_referencia_autoridad_cifrada bytea DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = iqg_core, iqg_fiscal, pg_temp
AS $$
DECLARE
    v_company_id uuid := iqg_core.contexto_company_id();
    v_branch_id uuid := iqg_core.contexto_branch_id();
    v_usuario_id uuid := iqg_core.contexto_usuario_id();
    v_factura_id uuid;
    v_eventos_actualizados integer;
BEGIN
    IF p_factura_id IS NULL
       OR p_tipo_xml_codigo IS NULL
       OR p_version_xml IS NULL
       OR p_xml_cifrado IS NULL
       OR p_hash_sobre_cifrado_sha256 IS NULL
       OR p_referencia_clave_fiscal_externa IS NULL
       OR v_company_id IS NULL
       OR v_branch_id IS NULL
       OR v_usuario_id IS NULL THEN
        RAISE EXCEPTION 'La emisión fiscal requiere contexto, factura y sobre XML cifrado completos';
    END IF;

    PERFORM iqg_core.exigir_contexto_membresia_activa();
    IF NOT iqg_core.contexto_tiene_permiso('FISCAL', 'EMITIR') THEN
        RAISE EXCEPTION 'El actor no tiene el permiso FISCAL/EMITIR';
    END IF;

    PERFORM 1
      FROM iqg_core.dominio_valor AS dv
      JOIN iqg_core.dominio AS d
        ON d.company_id = dv.company_id
       AND d.codigo = dv.dominio_codigo
     WHERE dv.company_id = v_company_id
       AND dv.dominio_codigo = 'TIPO_XML_FISCAL'
       AND dv.codigo = upper(p_tipo_xml_codigo)
       AND dv.activo = true
       AND d.activo = true
     FOR KEY SHARE OF dv, d;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El tipo de XML fiscal no está activo para la empresa';
    END IF;

    SELECT f.factura_id
      INTO v_factura_id
      FROM iqg_fiscal.factura AS f
     WHERE f.company_id = v_company_id
       AND f.branch_id = v_branch_id
       AND f.factura_id = p_factura_id
       AND f.estado_emision_codigo = 'PENDIENTE_EMISOR'
     FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La factura no existe o ya fue finalizada en este alcance';
    END IF;

    INSERT INTO iqg_fiscal.factura_xml (
        company_id,
        branch_id,
        creado_por_usuario_id,
        factura_id,
        tipo_xml_codigo,
        version_xml,
        xml_cifrado,
        hash_sobre_cifrado_sha256,
        referencia_clave_fiscal_externa,
        referencia_autoridad_cifrada,
        estado_envio_codigo,
        enviado_en,
        aceptado_por_fisco_en
    ) VALUES (
        v_company_id,
        v_branch_id,
        v_usuario_id,
        v_factura_id,
        upper(p_tipo_xml_codigo),
        p_version_xml,
        p_xml_cifrado,
        p_hash_sobre_cifrado_sha256,
        p_referencia_clave_fiscal_externa,
        p_referencia_autoridad_cifrada,
        'GENERADO',
        NULL,
        NULL
    );

    UPDATE iqg_fiscal.factura
       SET estado_emision_codigo = 'EMITIDA',
           fecha_emision_confirmada = NULL
     WHERE company_id = v_company_id
       AND branch_id = v_branch_id
       AND factura_id = v_factura_id;

    UPDATE iqg_fiscal.evento_emision_factura
       SET entregado_en = NULL,
           procesado_en = NULL,
           resultado_codigo = 'DOCUMENTO_GENERADO'
     WHERE company_id = v_company_id
       AND branch_id = v_branch_id
       AND factura_id = v_factura_id
       AND tipo_evento_codigo = 'EMITIR_FACTURA';

    GET DIAGNOSTICS v_eventos_actualizados = ROW_COUNT;
    IF v_eventos_actualizados <> 1 THEN
        RAISE EXCEPTION
            'La factura no tiene exactamente un evento pendiente de emisión';
    END IF;

    RETURN v_factura_id;
END;
$$;

-- Registra una falla codificada del emisor sin introducir mensajes libres ni
-- reescribir hechos. La evidencia técnica detallada corresponde al emisor
-- externo del titular y nunca debe entrar como PII en este esquema.
CREATE OR REPLACE FUNCTION iqg_fiscal.rechazar_emision_factura(
    p_factura_id uuid,
    p_codigo_rechazo varchar
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = iqg_core, iqg_fiscal, pg_temp
AS $$
DECLARE
    v_company_id uuid := iqg_core.contexto_company_id();
    v_branch_id uuid := iqg_core.contexto_branch_id();
    v_usuario_id uuid := iqg_core.contexto_usuario_id();
    v_factura_id uuid;
    v_eventos_actualizados integer;
BEGIN
    IF p_factura_id IS NULL
       OR p_codigo_rechazo IS NULL
       OR upper(p_codigo_rechazo) !~ '^EMISION_RECHAZADA(_[A-Z0-9_]{1,40})?$'
       OR v_company_id IS NULL
       OR v_branch_id IS NULL
       OR v_usuario_id IS NULL THEN
        RAISE EXCEPTION
            'El rechazo fiscal requiere factura, código codificado y contexto completo';
    END IF;

    PERFORM iqg_core.exigir_contexto_membresia_activa();
    IF NOT iqg_core.contexto_tiene_permiso('FISCAL', 'EMITIR') THEN
        RAISE EXCEPTION 'El actor no tiene el permiso FISCAL/EMITIR';
    END IF;

    SELECT f.factura_id
      INTO v_factura_id
      FROM iqg_fiscal.factura AS f
     WHERE f.company_id = v_company_id
       AND f.branch_id = v_branch_id
       AND f.factura_id = p_factura_id
       AND f.estado_emision_codigo = 'PENDIENTE_EMISOR'
     FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La factura no existe o ya fue finalizada en este alcance';
    END IF;

    UPDATE iqg_fiscal.factura
       SET estado_emision_codigo = 'RECHAZADA',
           fecha_emision_confirmada = NULL
     WHERE company_id = v_company_id
       AND branch_id = v_branch_id
       AND factura_id = v_factura_id;

    UPDATE iqg_fiscal.evento_emision_factura
       SET entregado_en = NULL,
           procesado_en = NULL,
           resultado_codigo = upper(p_codigo_rechazo)
     WHERE company_id = v_company_id
       AND branch_id = v_branch_id
       AND factura_id = v_factura_id
       AND tipo_evento_codigo = 'EMITIR_FACTURA';

    GET DIAGNOSTICS v_eventos_actualizados = ROW_COUNT;
    IF v_eventos_actualizados <> 1 THEN
        RAISE EXCEPTION
            'La factura no tiene exactamente un evento pendiente de emisión';
    END IF;

    RETURN v_factura_id;
END;
$$;

-- Todas las filas reciben el sellado de identidad, contexto y fecha. Los
-- nombres de trigger ordenan el sellado antes de las reglas específicas.
CREATE TRIGGER trg_00_sellar_empresa BEFORE INSERT OR UPDATE ON iqg_core.empresa FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('company_id');
CREATE TRIGGER trg_00_sellar_sucursal BEFORE INSERT OR UPDATE ON iqg_core.sucursal FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('branch_id');
CREATE TRIGGER trg_00_sellar_usuario BEFORE INSERT OR UPDATE ON iqg_core.usuario FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('usuario_id');
CREATE TRIGGER trg_00_sellar_usuario_sucursal BEFORE INSERT OR UPDATE ON iqg_core.usuario_sucursal FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('usuario_sucursal_id');
CREATE TRIGGER trg_00_sellar_provisionamiento_empresa BEFORE INSERT OR UPDATE ON iqg_core.provisionamiento_empresa FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('provisionamiento_empresa_id');
CREATE TRIGGER trg_00_sellar_rol BEFORE INSERT OR UPDATE ON iqg_core.rol FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('rol_id');
CREATE TRIGGER trg_00_sellar_permiso BEFORE INSERT OR UPDATE ON iqg_core.permiso FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('permiso_id');
CREATE TRIGGER trg_00_sellar_rol_permiso BEFORE INSERT OR UPDATE ON iqg_core.rol_permiso FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('rol_permiso_id');
CREATE TRIGGER trg_00_sellar_usuario_rol BEFORE INSERT OR UPDATE ON iqg_core.usuario_rol FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('usuario_rol_id');
CREATE TRIGGER trg_00_sellar_dominio BEFORE INSERT OR UPDATE ON iqg_core.dominio FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('dominio_id');
CREATE TRIGGER trg_00_sellar_dominio_valor BEFORE INSERT OR UPDATE ON iqg_core.dominio_valor FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('dominio_valor_id');
CREATE TRIGGER trg_00_sellar_elemento BEFORE INSERT OR UPDATE ON iqg_core.elemento FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('elemento_id');
CREATE TRIGGER trg_00_sellar_precio BEFORE INSERT OR UPDATE ON iqg_core.precio_vigente FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('precio_vigente_id');
CREATE TRIGGER trg_00_sellar_canal BEFORE INSERT OR UPDATE ON iqg_core.canal FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('canal_id');
CREATE TRIGGER trg_00_sellar_campania BEFORE INSERT OR UPDATE ON iqg_core.campania FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('campania_id');
CREATE TRIGGER trg_00_sellar_cliente BEFORE INSERT OR UPDATE ON iqg_core.cliente FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('cliente_id');
CREATE TRIGGER trg_00_sellar_anonimizacion_solicitud BEFORE INSERT OR UPDATE ON iqg_core.anonimizacion_solicitud FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('anonimizacion_solicitud_id');
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
CREATE TRIGGER trg_00_sellar_fiscal_configuracion_bloqueada BEFORE INSERT OR UPDATE ON iqg_core.fiscal_configuracion_bloqueada FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('fiscal_configuracion_bloqueada_id');
CREATE TRIGGER trg_00_sellar_factura BEFORE INSERT OR UPDATE ON iqg_fiscal.factura FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('factura_id');
CREATE TRIGGER trg_00_sellar_factura_linea BEFORE INSERT OR UPDATE ON iqg_fiscal.factura_linea FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('factura_linea_id');
CREATE TRIGGER trg_00_sellar_factura_xml BEFORE INSERT OR UPDATE ON iqg_fiscal.factura_xml FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('factura_xml_id');
CREATE TRIGGER trg_00_sellar_evento_emision_factura BEFORE INSERT OR UPDATE ON iqg_fiscal.evento_emision_factura FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('evento_emision_factura_id');
CREATE TRIGGER trg_00_sellar_registro_cambios_fiscal BEFORE INSERT OR UPDATE ON iqg_fiscal.registro_cambios FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_registro('registro_cambio_id');

CREATE TRIGGER trg_01_aplicar_politica_fiscal_empresa BEFORE INSERT OR UPDATE ON iqg_core.empresa FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_aplicar_politica_fiscal_empresa();
CREATE TRIGGER trg_01_sellar_fecha_operacion BEFORE INSERT OR UPDATE ON iqg_core.operacion FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_sellar_fecha_operacion();
CREATE TRIGGER trg_01_validar_precio BEFORE INSERT ON iqg_core.precio_vigente FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_precio_vigente();
CREATE TRIGGER trg_01_validar_operacion_linea BEFORE INSERT ON iqg_core.operacion_linea FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_operacion_linea();
CREATE TRIGGER trg_01_validar_transicion_fiscal_operacion BEFORE INSERT ON iqg_core.operacion_estado FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_transicion_fiscal_operacion();
CREATE TRIGGER trg_01_validar_movimiento BEFORE INSERT ON iqg_core.movimiento FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_movimiento();
CREATE TRIGGER trg_01_validar_pago BEFORE INSERT ON iqg_core.pago FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_pago();
CREATE TRIGGER trg_01_validar_movimiento_caja BEFORE INSERT ON iqg_core.movimiento_caja FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_movimiento_caja();
CREATE TRIGGER trg_01_bloquear_moneda_caja BEFORE UPDATE ON iqg_core.caja FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_cambio_moneda_caja();
CREATE TRIGGER trg_01_bloquear_cambio_unidad_elemento BEFORE UPDATE ON iqg_core.elemento FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_cambio_unidad_elemento();
CREATE TRIGGER trg_01_validar_anonimizacion_cliente BEFORE UPDATE ON iqg_core.cliente FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_anonimizacion_cliente();
CREATE TRIGGER trg_01_validar_factura_linea_origen BEFORE INSERT ON iqg_fiscal.factura_linea FOR EACH ROW EXECUTE FUNCTION iqg_fiscal.tg_validar_factura_linea_origen();

CREATE TRIGGER trg_02_validar_dominio_elemento_tipo BEFORE INSERT OR UPDATE ON iqg_core.elemento FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('tipo_codigo', 'TIPO_ELEMENTO');
CREATE TRIGGER trg_02_validar_dominio_elemento_unidad BEFORE INSERT OR UPDATE ON iqg_core.elemento FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('unidad_medida_codigo', 'UNIDAD_MEDIDA');
CREATE TRIGGER trg_02_validar_regimen_fiscal_empresa BEFORE INSERT OR UPDATE ON iqg_core.empresa FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_regimen_fiscal_empresa();
CREATE TRIGGER trg_02_validar_dominio_precio_moneda BEFORE INSERT OR UPDATE ON iqg_core.precio_vigente FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('moneda_codigo', 'MONEDA');
CREATE TRIGGER trg_02_validar_dominio_precio_motivo BEFORE INSERT OR UPDATE ON iqg_core.precio_vigente FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('motivo_codigo', 'MOTIVO_CAMBIO');
CREATE TRIGGER trg_02_validar_dominio_estado_entidad BEFORE INSERT OR UPDATE ON iqg_core.estado FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('entidad_codigo', 'ENTIDAD_ESTADO');
CREATE TRIGGER trg_02_validar_dominio_estado_tipo_documento_fiscal BEFORE INSERT OR UPDATE ON iqg_core.estado FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('tipo_documento_fiscal_codigo', 'TIPO_DOCUMENTO_FISCAL');
CREATE TRIGGER trg_02_validar_dominio_factura_tipo_documento BEFORE INSERT OR UPDATE ON iqg_fiscal.factura FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('tipo_documento_fiscal_codigo', 'TIPO_DOCUMENTO_FISCAL');
CREATE TRIGGER trg_02_validar_dominio_factura_regimen BEFORE INSERT OR UPDATE ON iqg_fiscal.factura FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('regimen_fiscal_codigo_emision', 'REGIMEN_FISCAL');
CREATE TRIGGER trg_02_validar_dominio_factura_estado BEFORE INSERT OR UPDATE ON iqg_fiscal.factura FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('estado_emision_codigo', 'ESTADO_FACTURA_FISCAL');
CREATE TRIGGER trg_02_validar_dominio_factura_moneda BEFORE INSERT OR UPDATE ON iqg_fiscal.factura FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('moneda_codigo', 'MONEDA');
CREATE TRIGGER trg_02_validar_dominio_factura_linea_unidad BEFORE INSERT OR UPDATE ON iqg_fiscal.factura_linea FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('unidad_medida_codigo', 'UNIDAD_MEDIDA');
CREATE TRIGGER trg_02_validar_dominio_factura_linea_moneda BEFORE INSERT OR UPDATE ON iqg_fiscal.factura_linea FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('moneda_codigo', 'MONEDA');
CREATE TRIGGER trg_02_validar_dominio_factura_xml_tipo BEFORE INSERT OR UPDATE ON iqg_fiscal.factura_xml FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('tipo_xml_codigo', 'TIPO_XML_FISCAL');
CREATE TRIGGER trg_02_validar_dominio_operacion_tipo BEFORE INSERT OR UPDATE ON iqg_core.operacion FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('tipo_operacion_codigo', 'TIPO_OPERACION');
CREATE TRIGGER trg_02_validar_dominio_operacion_moneda BEFORE INSERT OR UPDATE ON iqg_core.operacion FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('moneda_codigo', 'MONEDA');
CREATE TRIGGER trg_02_validar_dominio_operacion_motivo BEFORE INSERT OR UPDATE ON iqg_core.operacion FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('motivo_codigo', 'MOTIVO_CAMBIO');
CREATE TRIGGER trg_02_validar_dominio_operacion_estado_motivo BEFORE INSERT OR UPDATE ON iqg_core.operacion_estado FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('motivo_codigo', 'MOTIVO_CAMBIO');
CREATE TRIGGER trg_02_validar_dominio_operacion_linea_unidad BEFORE INSERT OR UPDATE ON iqg_core.operacion_linea FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('unidad_medida_codigo', 'UNIDAD_MEDIDA');
CREATE TRIGGER trg_02_validar_dominio_operacion_linea_moneda BEFORE INSERT OR UPDATE ON iqg_core.operacion_linea FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('moneda_codigo', 'MONEDA');
CREATE TRIGGER trg_02_validar_dominio_pago_medio BEFORE INSERT OR UPDATE ON iqg_core.pago FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('medio_pago_codigo', 'MEDIO_PAGO');
CREATE TRIGGER trg_02_validar_dominio_pago_moneda BEFORE INSERT OR UPDATE ON iqg_core.pago FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('moneda_codigo', 'MONEDA');
CREATE TRIGGER trg_02_validar_dominio_pago_motivo BEFORE INSERT OR UPDATE ON iqg_core.pago FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('motivo_codigo', 'MOTIVO_CAMBIO');
CREATE TRIGGER trg_02_validar_dominio_caja_moneda BEFORE INSERT OR UPDATE ON iqg_core.caja FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('moneda_codigo', 'MONEDA');
CREATE TRIGGER trg_02_validar_dominio_movimiento_caja_tipo BEFORE INSERT OR UPDATE ON iqg_core.movimiento_caja FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('tipo_movimiento_codigo', 'TIPO_MOVIMIENTO_CAJA');
CREATE TRIGGER trg_02_validar_dominio_movimiento_caja_moneda BEFORE INSERT OR UPDATE ON iqg_core.movimiento_caja FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('moneda_codigo', 'MONEDA');
CREATE TRIGGER trg_02_validar_dominio_movimiento_caja_motivo BEFORE INSERT OR UPDATE ON iqg_core.movimiento_caja FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('motivo_codigo', 'MOTIVO_CAMBIO');
CREATE TRIGGER trg_02_validar_dominio_grupo_movimiento_tipo BEFORE INSERT OR UPDATE ON iqg_core.grupo_movimiento FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('tipo_movimiento_codigo', 'TIPO_MOVIMIENTO_INVENTARIO');
CREATE TRIGGER trg_02_validar_dominio_grupo_movimiento_motivo BEFORE INSERT OR UPDATE ON iqg_core.grupo_movimiento FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('motivo_codigo', 'MOTIVO_CAMBIO');
CREATE TRIGGER trg_02_validar_dominio_movimiento_ubicacion BEFORE INSERT OR UPDATE ON iqg_core.movimiento FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('ubicacion_codigo', 'UBICACION');
CREATE TRIGGER trg_02_validar_dominio_movimiento_unidad BEFORE INSERT OR UPDATE ON iqg_core.movimiento FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('unidad_medida_codigo', 'UNIDAD_MEDIDA');
CREATE TRIGGER trg_02_validar_dominio_movimiento_moneda BEFORE INSERT OR UPDATE ON iqg_core.movimiento FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_validar_codigo_dominio('moneda_codigo', 'MONEDA');

-- Configuraciones se pueden ajustar con auditoría, pero no se eliminan.
CREATE TRIGGER trg_10_bloquear_delete_empresa BEFORE DELETE ON iqg_core.empresa FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();
CREATE TRIGGER trg_10_bloquear_delete_sucursal BEFORE DELETE ON iqg_core.sucursal FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();
CREATE TRIGGER trg_10_bloquear_delete_usuario BEFORE DELETE ON iqg_core.usuario FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();
CREATE TRIGGER trg_10_bloquear_delete_usuario_sucursal BEFORE DELETE ON iqg_core.usuario_sucursal FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();
CREATE TRIGGER trg_10_bloquear_delete_rol BEFORE DELETE ON iqg_core.rol FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();
CREATE TRIGGER trg_10_bloquear_delete_permiso BEFORE DELETE ON iqg_core.permiso FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();
CREATE TRIGGER trg_10_bloquear_delete_rol_permiso BEFORE DELETE ON iqg_core.rol_permiso FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();
CREATE TRIGGER trg_10_bloquear_delete_usuario_rol BEFORE DELETE ON iqg_core.usuario_rol FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();
CREATE TRIGGER trg_10_bloquear_delete_dominio BEFORE DELETE ON iqg_core.dominio FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();
CREATE TRIGGER trg_10_bloquear_delete_dominio_valor BEFORE DELETE ON iqg_core.dominio_valor FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();
CREATE TRIGGER trg_10_bloquear_delete_elemento BEFORE DELETE ON iqg_core.elemento FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();
CREATE TRIGGER trg_10_bloquear_delete_canal BEFORE DELETE ON iqg_core.canal FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();
CREATE TRIGGER trg_10_bloquear_delete_campania BEFORE DELETE ON iqg_core.campania FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();
CREATE TRIGGER trg_10_bloquear_delete_cliente BEFORE DELETE ON iqg_core.cliente FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();
CREATE TRIGGER trg_10_bloquear_delete_estado BEFORE DELETE ON iqg_core.estado FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();
CREATE TRIGGER trg_10_bloquear_delete_caja BEFORE DELETE ON iqg_core.caja FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_delete();

-- Los hechos y el registro de auditoría no se reescriben bajo ninguna vía DML.
CREATE TRIGGER trg_10_append_only_provisionamiento_empresa BEFORE UPDATE OR DELETE ON iqg_core.provisionamiento_empresa FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_mutacion_append_only();
CREATE TRIGGER trg_10_append_only_precio BEFORE UPDATE OR DELETE ON iqg_core.precio_vigente FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_mutacion_append_only();
CREATE TRIGGER trg_10_append_only_operacion BEFORE UPDATE OR DELETE ON iqg_core.operacion FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_mutacion_append_only();
CREATE TRIGGER trg_10_append_only_operacion_estado BEFORE UPDATE OR DELETE ON iqg_core.operacion_estado FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_mutacion_append_only();
CREATE TRIGGER trg_10_append_only_operacion_linea BEFORE UPDATE OR DELETE ON iqg_core.operacion_linea FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_mutacion_append_only();
CREATE TRIGGER trg_10_append_only_pago BEFORE UPDATE OR DELETE ON iqg_core.pago FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_mutacion_append_only();
CREATE TRIGGER trg_10_append_only_movimiento_caja BEFORE UPDATE OR DELETE ON iqg_core.movimiento_caja FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_mutacion_append_only();
CREATE TRIGGER trg_10_append_only_grupo_movimiento BEFORE UPDATE OR DELETE ON iqg_core.grupo_movimiento FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_mutacion_append_only();
CREATE TRIGGER trg_10_append_only_movimiento BEFORE UPDATE OR DELETE ON iqg_core.movimiento FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_mutacion_append_only();
CREATE TRIGGER trg_10_append_only_anonimizacion_solicitud BEFORE UPDATE OR DELETE ON iqg_core.anonimizacion_solicitud FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_mutacion_append_only();
CREATE TRIGGER trg_10_append_only_fiscal_configuracion_bloqueada BEFORE UPDATE OR DELETE ON iqg_core.fiscal_configuracion_bloqueada FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_mutacion_append_only();
CREATE TRIGGER trg_10_proteger_registro_cambios BEFORE UPDATE OR DELETE ON iqg_core.registro_cambios FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_proteger_registro_cambios();
CREATE TRIGGER trg_10_proteger_factura BEFORE UPDATE OR DELETE ON iqg_fiscal.factura FOR EACH ROW EXECUTE FUNCTION iqg_fiscal.tg_proteger_factura();
CREATE TRIGGER trg_10_append_only_factura_linea BEFORE UPDATE OR DELETE ON iqg_fiscal.factura_linea FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_mutacion_append_only();
CREATE TRIGGER trg_10_append_only_factura_xml BEFORE UPDATE OR DELETE ON iqg_fiscal.factura_xml FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_mutacion_append_only();
CREATE TRIGGER trg_10_proteger_evento_emision_factura BEFORE UPDATE OR DELETE ON iqg_fiscal.evento_emision_factura FOR EACH ROW EXECUTE FUNCTION iqg_fiscal.tg_proteger_evento_emision_factura();
CREATE TRIGGER trg_10_append_only_registro_cambios_fiscal BEFORE UPDATE OR DELETE ON iqg_fiscal.registro_cambios FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_bloquear_mutacion_append_only();

-- TRUNCATE no ejecuta triggers por fila; se bloquea de forma explícita en cada
-- tabla para que no se convierta en una vía de evasión de historia y auditoría.
DO $$
DECLARE
    v_tabla text;
BEGIN
    FOREACH v_tabla IN ARRAY ARRAY[
        'empresa', 'sucursal', 'usuario', 'usuario_sucursal',
        'provisionamiento_empresa', 'rol', 'permiso', 'rol_permiso',
        'usuario_rol', 'dominio', 'dominio_valor', 'elemento',
        'precio_vigente', 'canal', 'campania', 'cliente',
        'anonimizacion_solicitud', 'estado', 'operacion',
        'operacion_estado', 'operacion_linea', 'pago', 'caja',
        'movimiento_caja', 'grupo_movimiento', 'movimiento',
        'registro_cambios', 'fiscal_configuracion_bloqueada'
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

DO $$
DECLARE
    v_tabla text;
BEGIN
    FOREACH v_tabla IN ARRAY ARRAY[
        'factura', 'factura_linea', 'factura_xml',
        'evento_emision_factura', 'registro_cambios'
    ] LOOP
        EXECUTE format(
            'CREATE TRIGGER %I BEFORE TRUNCATE ON iqg_fiscal.%I FOR EACH STATEMENT '
            || 'EXECUTE FUNCTION iqg_core.tg_bloquear_truncate()',
            'trg_11_bloquear_truncate_fiscal_' || v_tabla,
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
CREATE TRIGGER trg_90_auditar_provisionamiento_empresa AFTER INSERT OR UPDATE OR DELETE ON iqg_core.provisionamiento_empresa FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('provisionamiento_empresa_id');
CREATE TRIGGER trg_90_auditar_rol AFTER INSERT OR UPDATE OR DELETE ON iqg_core.rol FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('rol_id');
CREATE TRIGGER trg_90_auditar_permiso AFTER INSERT OR UPDATE OR DELETE ON iqg_core.permiso FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('permiso_id');
CREATE TRIGGER trg_90_auditar_rol_permiso AFTER INSERT OR UPDATE OR DELETE ON iqg_core.rol_permiso FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('rol_permiso_id');
CREATE TRIGGER trg_90_auditar_usuario_rol AFTER INSERT OR UPDATE OR DELETE ON iqg_core.usuario_rol FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('usuario_rol_id');
CREATE TRIGGER trg_90_auditar_dominio AFTER INSERT OR UPDATE OR DELETE ON iqg_core.dominio FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('dominio_id');
CREATE TRIGGER trg_90_auditar_dominio_valor AFTER INSERT OR UPDATE OR DELETE ON iqg_core.dominio_valor FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('dominio_valor_id');
CREATE TRIGGER trg_90_auditar_elemento AFTER INSERT OR UPDATE OR DELETE ON iqg_core.elemento FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('elemento_id');
CREATE TRIGGER trg_90_auditar_precio AFTER INSERT OR UPDATE OR DELETE ON iqg_core.precio_vigente FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('precio_vigente_id');
CREATE TRIGGER trg_90_auditar_canal AFTER INSERT OR UPDATE OR DELETE ON iqg_core.canal FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('canal_id');
CREATE TRIGGER trg_90_auditar_campania AFTER INSERT OR UPDATE OR DELETE ON iqg_core.campania FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('campania_id');
CREATE TRIGGER trg_90_auditar_cliente AFTER INSERT OR UPDATE OR DELETE ON iqg_core.cliente FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('cliente_id');
CREATE TRIGGER trg_90_auditar_anonimizacion_solicitud AFTER INSERT OR UPDATE OR DELETE ON iqg_core.anonimizacion_solicitud FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('anonimizacion_solicitud_id');
CREATE TRIGGER trg_90_auditar_estado AFTER INSERT OR UPDATE OR DELETE ON iqg_core.estado FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('estado_id');
CREATE TRIGGER trg_90_auditar_operacion AFTER INSERT OR UPDATE OR DELETE ON iqg_core.operacion FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('operacion_id');
CREATE TRIGGER trg_90_auditar_operacion_estado AFTER INSERT OR UPDATE OR DELETE ON iqg_core.operacion_estado FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('operacion_estado_id');
CREATE TRIGGER trg_90_auditar_operacion_linea AFTER INSERT OR UPDATE OR DELETE ON iqg_core.operacion_linea FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('operacion_linea_id');
CREATE TRIGGER trg_90_auditar_pago AFTER INSERT OR UPDATE OR DELETE ON iqg_core.pago FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('pago_id');
CREATE TRIGGER trg_90_auditar_caja AFTER INSERT OR UPDATE OR DELETE ON iqg_core.caja FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('caja_id');
CREATE TRIGGER trg_90_auditar_movimiento_caja AFTER INSERT OR UPDATE OR DELETE ON iqg_core.movimiento_caja FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('movimiento_caja_id');
CREATE TRIGGER trg_90_auditar_grupo_movimiento AFTER INSERT OR UPDATE OR DELETE ON iqg_core.grupo_movimiento FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('grupo_movimiento_id');
CREATE TRIGGER trg_90_auditar_movimiento AFTER INSERT OR UPDATE OR DELETE ON iqg_core.movimiento FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('movimiento_id');
CREATE TRIGGER trg_90_auditar_fiscal_configuracion_bloqueada AFTER INSERT OR UPDATE OR DELETE ON iqg_core.fiscal_configuracion_bloqueada FOR EACH ROW EXECUTE FUNCTION iqg_core.tg_registrar_cambio('fiscal_configuracion_bloqueada_id');
CREATE TRIGGER trg_20_programar_factura_fiscal AFTER INSERT ON iqg_core.operacion_estado FOR EACH ROW EXECUTE FUNCTION iqg_fiscal.tg_programar_factura_desde_estado();
CREATE TRIGGER trg_90_auditar_factura AFTER INSERT OR UPDATE OR DELETE ON iqg_fiscal.factura FOR EACH ROW EXECUTE FUNCTION iqg_fiscal.tg_registrar_cambio('factura_id');
CREATE TRIGGER trg_90_auditar_factura_linea AFTER INSERT OR UPDATE OR DELETE ON iqg_fiscal.factura_linea FOR EACH ROW EXECUTE FUNCTION iqg_fiscal.tg_registrar_cambio('factura_linea_id');
CREATE TRIGGER trg_90_auditar_factura_xml AFTER INSERT OR UPDATE OR DELETE ON iqg_fiscal.factura_xml FOR EACH ROW EXECUTE FUNCTION iqg_fiscal.tg_registrar_cambio('factura_xml_id');
CREATE TRIGGER trg_90_auditar_evento_emision_factura AFTER INSERT OR UPDATE OR DELETE ON iqg_fiscal.evento_emision_factura FOR EACH ROW EXECUTE FUNCTION iqg_fiscal.tg_registrar_cambio('evento_emision_factura_id');

CREATE CONSTRAINT TRIGGER trg_95_verificar_totales_factura
    AFTER INSERT OR UPDATE ON iqg_fiscal.factura
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE FUNCTION iqg_fiscal.tg_verificar_totales_factura();
CREATE CONSTRAINT TRIGGER trg_95_verificar_totales_factura_linea
    AFTER INSERT ON iqg_fiscal.factura_linea
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE FUNCTION iqg_fiscal.tg_verificar_totales_factura();

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

-- RLS aplica company_id + branch_id y una membresía real a toda relación de
-- negocio. iqg_app no recibe una política, tablas ni funciones. Los GUC iqg.*
-- son variables no autenticadas: solamente un endpoint SECURITY DEFINER
-- revisado puede abrir una transacción y el bootstrap exige además la capacidad
-- de cluster iqg_bootstrap_invoker antes de que exista la primera membresía.
DO $$
DECLARE
    v_tabla text;
BEGIN
    FOREACH v_tabla IN ARRAY ARRAY[
        'provisionamiento_empresa', 'rol', 'permiso', 'rol_permiso',
        'usuario_rol', 'dominio', 'dominio_valor', 'elemento',
        'precio_vigente', 'canal', 'campania', 'cliente',
        'anonimizacion_solicitud', 'estado', 'operacion',
        'operacion_estado', 'operacion_linea', 'pago', 'caja',
        'movimiento_caja', 'grupo_movimiento', 'movimiento',
        'registro_cambios', 'fiscal_configuracion_bloqueada'
    ] LOOP
        EXECUTE format('ALTER TABLE iqg_core.%I ENABLE ROW LEVEL SECURITY', v_tabla);
        EXECUTE format('ALTER TABLE iqg_core.%I FORCE ROW LEVEL SECURITY', v_tabla);
        EXECUTE format(
            'CREATE POLICY %I ON iqg_core.%I FOR ALL TO iqg_owner '
            || 'USING (company_id = iqg_core.contexto_company_id() '
            || 'AND branch_id = iqg_core.contexto_branch_id() '
            || 'AND (iqg_core.contexto_membresia_activa() '
            || 'OR iqg_core.contexto_bootstrap_activo())) '
            || 'WITH CHECK (company_id = iqg_core.contexto_company_id() '
            || 'AND branch_id = iqg_core.contexto_branch_id() '
            || 'AND (iqg_core.contexto_membresia_activa() '
            || 'OR iqg_core.contexto_bootstrap_activo()))',
            'p_aislamiento_' || v_tabla,
            v_tabla
        );
    END LOOP;
END;
$$;

-- Las cuatro relaciones de identidad son evidencia interna de la membresía.
-- Sus políticas SELECT son deliberadamente mínimas y no llaman a
-- contexto_membresia_activa, porque esa función las lee bajo FORCE RLS. No hay
-- grants de tabla para iqg_app, iqg_gateway ni iqg_bootstrap_invoker: la
-- excepción no crea un canal de lectura SQL para clientes. Las mutaciones
-- continúan exigiendo membresía completa o el bootstrap acotado.
ALTER TABLE iqg_core.empresa ENABLE ROW LEVEL SECURITY;
ALTER TABLE iqg_core.empresa FORCE ROW LEVEL SECURITY;
CREATE POLICY p_contexto_interno_empresa_lectura ON iqg_core.empresa
    FOR SELECT TO iqg_owner
    USING (company_id = iqg_core.contexto_company_id());
CREATE POLICY p_aislamiento_empresa_insert ON iqg_core.empresa
    FOR INSERT TO iqg_owner
    WITH CHECK (
        company_id = iqg_core.contexto_company_id()
        AND branch_id = iqg_core.contexto_branch_id()
        AND iqg_core.contexto_bootstrap_activo()
    );
CREATE POLICY p_aislamiento_empresa_update ON iqg_core.empresa
    FOR UPDATE TO iqg_owner
    USING (
        company_id = iqg_core.contexto_company_id()
        AND branch_id = iqg_core.contexto_branch_id()
        AND iqg_core.contexto_membresia_activa()
    )
    WITH CHECK (
        company_id = iqg_core.contexto_company_id()
        AND branch_id = iqg_core.contexto_branch_id()
        -- Permite que un actor actualmente válido desactive la empresa; en el
        -- siguiente comando ya no pasará la cláusula USING anterior.
        AND iqg_core.contexto_usuario_activo()
        AND iqg_core.contexto_sucursal_activa()
        AND iqg_core.contexto_usuario_sucursal_activa()
    );
CREATE POLICY p_aislamiento_empresa_delete ON iqg_core.empresa
    FOR DELETE TO iqg_owner
    USING (
        company_id = iqg_core.contexto_company_id()
        AND branch_id = iqg_core.contexto_branch_id()
        AND iqg_core.contexto_membresia_activa()
    );

ALTER TABLE iqg_core.usuario ENABLE ROW LEVEL SECURITY;
ALTER TABLE iqg_core.usuario FORCE ROW LEVEL SECURITY;
CREATE POLICY p_contexto_interno_usuario_lectura ON iqg_core.usuario
    FOR SELECT TO iqg_owner
    USING (
        company_id = iqg_core.contexto_company_id()
        AND usuario_id = iqg_core.contexto_usuario_id()
    );
CREATE POLICY p_aislamiento_usuario_insert ON iqg_core.usuario
    FOR INSERT TO iqg_owner
    WITH CHECK (
        company_id = iqg_core.contexto_company_id()
        AND branch_id = iqg_core.contexto_branch_id()
        AND (
            iqg_core.contexto_membresia_activa()
            OR iqg_core.contexto_bootstrap_activo()
        )
    );
CREATE POLICY p_aislamiento_usuario_update ON iqg_core.usuario
    FOR UPDATE TO iqg_owner
    USING (
        company_id = iqg_core.contexto_company_id()
        AND branch_id = iqg_core.contexto_branch_id()
        AND iqg_core.contexto_membresia_activa()
    )
    WITH CHECK (
        company_id = iqg_core.contexto_company_id()
        AND branch_id = iqg_core.contexto_branch_id()
        -- Permite desactivar al usuario objetivo sin permitir que un actor ya
        -- desactivado inicie una nueva mutación.
        AND iqg_core.contexto_empresa_activa()
        AND iqg_core.contexto_sucursal_activa()
        AND iqg_core.contexto_usuario_sucursal_activa()
    );
CREATE POLICY p_aislamiento_usuario_delete ON iqg_core.usuario
    FOR DELETE TO iqg_owner
    USING (
        company_id = iqg_core.contexto_company_id()
        AND branch_id = iqg_core.contexto_branch_id()
        AND iqg_core.contexto_membresia_activa()
    );

ALTER TABLE iqg_core.sucursal ENABLE ROW LEVEL SECURITY;
ALTER TABLE iqg_core.sucursal FORCE ROW LEVEL SECURITY;
CREATE POLICY p_contexto_interno_sucursal_lectura ON iqg_core.sucursal
    FOR SELECT TO iqg_owner
    USING (
        company_id = iqg_core.contexto_company_id()
        AND branch_id = iqg_core.contexto_branch_id()
    );
CREATE POLICY p_aislamiento_sucursal_insert ON iqg_core.sucursal
    FOR INSERT TO iqg_owner
    WITH CHECK (
        company_id = iqg_core.contexto_company_id()
        AND branch_id = iqg_core.contexto_branch_id()
        AND (
            iqg_core.contexto_membresia_activa()
            OR iqg_core.contexto_bootstrap_activo()
        )
    );
CREATE POLICY p_aislamiento_sucursal_update ON iqg_core.sucursal
    FOR UPDATE TO iqg_owner
    USING (
        company_id = iqg_core.contexto_company_id()
        AND branch_id = iqg_core.contexto_branch_id()
        AND iqg_core.contexto_membresia_activa()
    )
    WITH CHECK (
        company_id = iqg_core.contexto_company_id()
        AND branch_id = iqg_core.contexto_branch_id()
        -- Permite desactivar la sucursal del contexto desde una membresía que
        -- era válida al comenzar UPDATE; la próxima operación queda bloqueada.
        AND iqg_core.contexto_empresa_activa()
        AND iqg_core.contexto_usuario_activo()
        AND iqg_core.contexto_usuario_sucursal_activa()
    );
CREATE POLICY p_aislamiento_sucursal_delete ON iqg_core.sucursal
    FOR DELETE TO iqg_owner
    USING (
        company_id = iqg_core.contexto_company_id()
        AND branch_id = iqg_core.contexto_branch_id()
        AND iqg_core.contexto_membresia_activa()
    );

ALTER TABLE iqg_core.usuario_sucursal ENABLE ROW LEVEL SECURITY;
ALTER TABLE iqg_core.usuario_sucursal FORCE ROW LEVEL SECURITY;
CREATE POLICY p_contexto_interno_usuario_sucursal_lectura ON iqg_core.usuario_sucursal
    FOR SELECT TO iqg_owner
    USING (
        company_id = iqg_core.contexto_company_id()
        AND branch_id = iqg_core.contexto_branch_id()
        AND usuario_id = iqg_core.contexto_usuario_id()
    );
CREATE POLICY p_aislamiento_usuario_sucursal_insert ON iqg_core.usuario_sucursal
    FOR INSERT TO iqg_owner
    WITH CHECK (
        company_id = iqg_core.contexto_company_id()
        AND branch_id = iqg_core.contexto_branch_id()
        AND (
            iqg_core.contexto_membresia_activa()
            OR iqg_core.contexto_bootstrap_activo()
        )
    );
CREATE POLICY p_aislamiento_usuario_sucursal_update ON iqg_core.usuario_sucursal
    FOR UPDATE TO iqg_owner
    USING (
        company_id = iqg_core.contexto_company_id()
        AND branch_id = iqg_core.contexto_branch_id()
        AND iqg_core.contexto_membresia_activa()
    )
    WITH CHECK (
        company_id = iqg_core.contexto_company_id()
        AND branch_id = iqg_core.contexto_branch_id()
        -- Permite desactivar la membresía actual una sola vez sin abrir DML a
        -- un actor cuya membresía ya está inactiva.
        AND iqg_core.contexto_empresa_activa()
        AND iqg_core.contexto_usuario_activo()
        AND iqg_core.contexto_sucursal_activa()
    );
CREATE POLICY p_aislamiento_usuario_sucursal_delete ON iqg_core.usuario_sucursal
    FOR DELETE TO iqg_owner
    USING (
        company_id = iqg_core.contexto_company_id()
        AND branch_id = iqg_core.contexto_branch_id()
        AND iqg_core.contexto_membresia_activa()
    );

-- La capa fiscal tiene sus propias políticas; no hereda ni reutiliza la
-- auditoría operativa. Aun el owner técnico queda sujeto al tenant, sucursal y
-- membresía activa por FORCE ROW LEVEL SECURITY.
DO $$
DECLARE
    v_tabla text;
BEGIN
    FOREACH v_tabla IN ARRAY ARRAY[
        'factura', 'factura_linea', 'factura_xml',
        'evento_emision_factura', 'registro_cambios'
    ] LOOP
        EXECUTE format('ALTER TABLE iqg_fiscal.%I ENABLE ROW LEVEL SECURITY', v_tabla);
        EXECUTE format('ALTER TABLE iqg_fiscal.%I FORCE ROW LEVEL SECURITY', v_tabla);
        EXECUTE format(
            'CREATE POLICY %I ON iqg_fiscal.%I FOR ALL TO iqg_owner '
            || 'USING (company_id = iqg_core.contexto_company_id() '
            || 'AND branch_id = iqg_core.contexto_branch_id() '
            || 'AND iqg_core.contexto_membresia_activa()) '
            || 'WITH CHECK (company_id = iqg_core.contexto_company_id() '
            || 'AND branch_id = iqg_core.contexto_branch_id() '
            || 'AND iqg_core.contexto_membresia_activa())',
            'p_aislamiento_fiscal_' || v_tabla,
            v_tabla
        );
    END LOOP;
END;
$$;

-- Entidades corporativas se leen desde cualquier sucursal en la que el actor
-- tenga membresía activa. Las escrituras siguen ocurriendo en su sucursal de
-- origen mediante la política estricta anterior, para que actor, auditoría y
-- branch_id permanezcan coherentes; la definición resultante es reutilizable
-- por todas las demás sucursales de la misma empresa.
DO $$
DECLARE
    v_tabla text;
BEGIN
    FOREACH v_tabla IN ARRAY ARRAY[
        'rol', 'permiso', 'rol_permiso', 'dominio', 'dominio_valor',
        'fiscal_configuracion_bloqueada'
    ] LOOP
        EXECUTE format(
            'CREATE POLICY %I ON iqg_core.%I FOR SELECT TO iqg_owner '
            || 'USING (company_id = iqg_core.contexto_company_id() '
            || 'AND iqg_core.contexto_membresia_activa())',
            'p_corporativo_' || v_tabla,
            v_tabla
        );
    END LOOP;
END;
$$;

-- El reintento de provisioning necesita encontrar su propia reserva antes de
-- tener company_id. Esta excepción es exclusiva de iqg_owner y exige ambos
-- componentes de la llave global definidos dentro de provisionar_empresa.
CREATE POLICY p_provisionamiento_empresa_reintento
    ON iqg_core.provisionamiento_empresa
    FOR SELECT TO iqg_owner
    USING (
        origen_idempotencia = iqg_core.contexto_provisionamiento_origen()
        AND clave_idempotencia = iqg_core.contexto_provisionamiento_clave()
    );

-- Única ruta de bootstrap de este esquema. Genera el actor inicial antes de
-- insertar, reserva primero una llave de idempotencia global y conserva
-- company_id + branch_id + usuario en todas las filas. La función no se
-- concede a PUBLIC, iqg_app ni iqg_gateway; solo iqg_bootstrap_invoker recibe
-- EXECUTE, sin tablas ni helpers, y exige una membresía directa de session_user.
CREATE OR REPLACE FUNCTION iqg_core.provisionar_empresa(
    p_origen_idempotencia varchar,
    p_clave_idempotencia uuid,
    p_nombre_legal_cifrado bytea,
    p_nombre_mostrar_cifrado bytea,
    p_identificador_fiscal_cifrado bytea,
    p_referencia_clave_operativa_externa uuid,
    p_pais_codigo char(2),
    p_regimen_fiscal_codigo varchar,
    p_esta_obligado_a_facturar boolean,
    p_facturacion_fiscal_voluntaria boolean,
    p_version_regla_fiscal varchar,
    p_moneda_predeterminada varchar(3),
    p_codigo_sucursal varchar(64),
    p_nombre_sucursal text,
    p_zona_horaria text,
    p_identificador_identidad_cifrado bytea,
    p_nombre_usuario_cifrado bytea,
    p_referencia_clave_usuario_externa uuid,
    p_usuario_id uuid,
    p_correo_electronico_cifrado bytea DEFAULT NULL
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
    v_result_company_id uuid;
    v_result_branch_id uuid;
    v_result_usuario_id uuid;
BEGIN
    IF p_origen_idempotencia IS NULL
       OR p_clave_idempotencia IS NULL
       OR upper(p_origen_idempotencia) !~ '^[A-Z][A-Z0-9_]{0,63}$'
       OR p_nombre_legal_cifrado IS NULL
       OR NOT iqg_core.es_sobre_cifrado_aes_256_gcm(p_nombre_legal_cifrado)
       OR (p_nombre_mostrar_cifrado IS NOT NULL
           AND NOT iqg_core.es_sobre_cifrado_aes_256_gcm(p_nombre_mostrar_cifrado))
       OR (p_identificador_fiscal_cifrado IS NOT NULL
           AND NOT iqg_core.es_sobre_cifrado_aes_256_gcm(p_identificador_fiscal_cifrado))
       OR p_referencia_clave_operativa_externa IS NULL
       OR p_pais_codigo IS NULL
       OR upper(p_pais_codigo) !~ '^[A-Z]{2}$'
       OR p_esta_obligado_a_facturar IS NULL
       OR p_facturacion_fiscal_voluntaria IS NULL
       OR p_moneda_predeterminada IS NULL
       OR p_moneda_predeterminada !~ '^[A-Z]{3}$'
       OR p_codigo_sucursal IS NULL
       OR p_nombre_sucursal IS NULL
       OR p_zona_horaria IS NULL
       OR p_identificador_identidad_cifrado IS NULL
       OR NOT iqg_core.es_sobre_cifrado_aes_256_gcm(p_identificador_identidad_cifrado)
       OR p_nombre_usuario_cifrado IS NULL
       OR NOT iqg_core.es_sobre_cifrado_aes_256_gcm(p_nombre_usuario_cifrado)
       OR (p_correo_electronico_cifrado IS NOT NULL
           AND NOT iqg_core.es_sobre_cifrado_aes_256_gcm(p_correo_electronico_cifrado))
       OR p_referencia_clave_usuario_externa IS NULL
       OR v_usuario_id IS NULL THEN
        RAISE EXCEPTION
            'La provisión requiere sobres cifrados válidos, contexto fiscal y datos de sucursal e identidad inicial';
    END IF;

    -- El contexto vive solo en la transacción actual y coincide con los UUID
    -- nuevos antes de que las políticas RLS permitan escribir las filas.
    PERFORM set_config('iqg.company_id', v_company_id::text, true);
    PERFORM set_config('iqg.branch_id', v_branch_id::text, true);
    PERFORM set_config('iqg.usuario_id', v_usuario_id::text, true);
    PERFORM set_config('iqg.actor_tipo', 'SISTEMA', true);
    PERFORM set_config('iqg.motivo_codigo', 'PROVISION_INICIAL', true);
    PERFORM set_config('iqg.correlation_id', '', true);
    PERFORM set_config('iqg.direccion_ip_cifrada', '', true);
    PERFORM set_config('iqg.direccion_ip_clave_referencia', '', true);
    PERFORM set_config('iqg.direccion_ip_version_sobre', '', true);
    PERFORM set_config('iqg.provisionamiento_origen', upper(p_origen_idempotencia), true);
    PERFORM set_config('iqg.provisionamiento_clave', p_clave_idempotencia::text, true);

    -- INSERT ... ON CONFLICT serializa reintentos concurrentes de la misma
    -- clave antes de crear objetos tenant. Si otro intento ganó, se recupera
    -- solo su reserva mediante la política de reintento inmediatamente anterior.
    INSERT INTO iqg_core.provisionamiento_empresa (
        company_id,
        branch_id,
        creado_por_usuario_id,
        origen_idempotencia,
        clave_idempotencia
    ) VALUES (
        v_company_id,
        v_branch_id,
        v_usuario_id,
        upper(p_origen_idempotencia),
        p_clave_idempotencia
    )
    ON CONFLICT (origen_idempotencia, clave_idempotencia) DO NOTHING
    RETURNING company_id, branch_id, creado_por_usuario_id
         INTO v_result_company_id, v_result_branch_id, v_result_usuario_id;

    IF NOT FOUND THEN
        SELECT pe.company_id, pe.branch_id, pe.creado_por_usuario_id
          INTO v_result_company_id, v_result_branch_id, v_result_usuario_id
          FROM iqg_core.provisionamiento_empresa AS pe
         WHERE pe.origen_idempotencia = upper(p_origen_idempotencia)
           AND pe.clave_idempotencia = p_clave_idempotencia
         FOR KEY SHARE;

        IF NOT FOUND THEN
            RAISE EXCEPTION
                'No se pudo recuperar la reserva de idempotencia de provisioning';
        END IF;

        IF v_result_usuario_id IS DISTINCT FROM v_usuario_id THEN
            RAISE EXCEPTION
                'La clave de idempotencia ya pertenece a otro fundador';
        END IF;

        RETURN QUERY
        SELECT v_result_company_id, v_result_branch_id, v_result_usuario_id;
        RETURN;
    END IF;

    INSERT INTO iqg_core.empresa (
        company_id, branch_id, creado_por_usuario_id,
        nombre_legal_cifrado, nombre_mostrar_cifrado,
        identificador_fiscal_cifrado, referencia_clave_operativa_externa,
        pais_codigo, regimen_fiscal_codigo,
        esta_obligado_a_facturar, facturacion_fiscal_voluntaria,
        version_regla_fiscal, moneda_predeterminada
    ) VALUES (
        v_company_id, v_branch_id, v_usuario_id,
        p_nombre_legal_cifrado, p_nombre_mostrar_cifrado,
        p_identificador_fiscal_cifrado, p_referencia_clave_operativa_externa,
        upper(p_pais_codigo), p_regimen_fiscal_codigo,
        p_esta_obligado_a_facturar, p_facturacion_fiscal_voluntaria,
        p_version_regla_fiscal, p_moneda_predeterminada
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
        identificador_identidad_cifrado, nombre_mostrar_cifrado,
        correo_electronico_cifrado, referencia_clave_operativa_externa
    ) VALUES (
        v_usuario_id, v_company_id, v_branch_id, v_usuario_id,
        p_identificador_identidad_cifrado, p_nombre_usuario_cifrado,
        p_correo_electronico_cifrado, p_referencia_clave_usuario_externa
    );

    INSERT INTO iqg_core.usuario_sucursal (
        company_id, branch_id, creado_por_usuario_id, usuario_id
    ) VALUES (
        v_company_id, v_branch_id, v_usuario_id, v_usuario_id
    );

    PERFORM iqg_core.asegurar_dominios_base(
        v_company_id,
        v_branch_id,
        v_usuario_id,
        p_moneda_predeterminada,
        p_regimen_fiscal_codigo
    );
    PERFORM iqg_core.asegurar_roles_base(
        v_company_id,
        v_branch_id,
        v_usuario_id
    );

    RETURN QUERY SELECT v_company_id, v_branch_id, v_usuario_id;
END;
$$;

-- Los comentarios son metadatos de objetos propiedad de iqg_owner. Deben
-- fijarse antes de devolver la identidad de instalación y cerrar PHASE 1.
COMMENT ON SCHEMA iqg_core IS
    'Capa operativa privada IQ GROWTH: alcance company/branch, PII en sobres externos AES-256-GCM, historia temporal y auditoría.';
COMMENT ON SCHEMA iqg_fiscal IS
    'Capa fiscal separada y opcional: solo recibe snapshots/documentos fiscales cuando la determinación de empresa activa facturación.';
COMMENT ON TABLE iqg_core.empresa IS
    'Configuración corporativa privada. El perfil país fija minimización y contrato AAD; las claves permanecen fuera de PostgreSQL.';
COMMENT ON TABLE iqg_core.fiscal_configuracion_bloqueada IS
    'Hecho corporativo no sensible que impide reescribir país/régimen/activación después de la primera factura en cualquier sucursal.';
COMMENT ON TABLE iqg_core.precio_vigente IS
    'Libro append-only de precios. Cambiar precio inserta un sucesor, no actualiza la fila anterior.';
COMMENT ON TABLE iqg_core.registro_cambios IS
    'Bitácora DML inmutable salvo redacción legal única y trazable de PII de cliente; sin DELETE.';
COMMENT ON TABLE iqg_core.anonimizacion_solicitud IS
    'Hecho inmutable que respalda una anonimización de cliente sin retener PII original.';
COMMENT ON TABLE iqg_core.provisionamiento_empresa IS
    'Reserva global append-only para alta idempotente y concurrentemente segura de una empresa.';
COMMENT ON TABLE iqg_core.movimiento IS
    'Libro inmutable de cantidades y costos; los saldos se derivan y no son fuente de verdad mutable.';
COMMENT ON TABLE iqg_fiscal.factura IS
    'Snapshot fiscal inmutable de una operación: separa emisor, país/régimen, años de retención e importes de la capa operativa.';
COMMENT ON TABLE iqg_fiscal.factura_linea IS
    'Snapshot fiscal exacto de una línea operativa de la misma operación; un constraint trigger diferido verifica las sumas de la factura.';
COMMENT ON TABLE iqg_fiscal.factura_xml IS
    'Documento fiscal cifrado. hash_sobre_cifrado_sha256 es hash del sobre cifrado, no un hash correlacionable del XML en claro.';
COMMENT ON TABLE iqg_fiscal.evento_emision_factura IS
    'Outbox transaccional de generación fiscal. DOCUMENTO_GENERADO no afirma aceptación por una autoridad fiscal.';

-- H-01/C2: iqg_app e iqg_gateway no tienen USAGE de schema, tablas, secuencias
-- ni funciones. Un placeholder iqg.* nunca es una identidad. La única
-- excepción declarada es la capacidad NOLOGIN iqg_bootstrap_invoker: recibe
-- solo USAGE del schema operativo y EXECUTE de provisionar_empresa. Una
-- identidad de conexión debe ser miembro directo con INHERIT y sin SET ROLE;
-- no obtiene ninguna relación, helper ni acceso fiscal.
REVOKE ALL ON SCHEMA iqg_core FROM PUBLIC, iqg_app, iqg_gateway, iqg_bootstrap_invoker;
REVOKE ALL ON SCHEMA iqg_fiscal FROM PUBLIC, iqg_app, iqg_gateway, iqg_bootstrap_invoker;
REVOKE ALL ON ALL TABLES IN SCHEMA iqg_core FROM PUBLIC, iqg_app, iqg_gateway, iqg_bootstrap_invoker;
REVOKE ALL ON ALL TABLES IN SCHEMA iqg_fiscal FROM PUBLIC, iqg_app, iqg_gateway, iqg_bootstrap_invoker;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA iqg_core FROM PUBLIC, iqg_app, iqg_gateway, iqg_bootstrap_invoker;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA iqg_fiscal FROM PUBLIC, iqg_app, iqg_gateway, iqg_bootstrap_invoker;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA iqg_core FROM PUBLIC, iqg_app, iqg_gateway, iqg_bootstrap_invoker;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA iqg_fiscal FROM PUBLIC, iqg_app, iqg_gateway, iqg_bootstrap_invoker;
ALTER DEFAULT PRIVILEGES FOR ROLE iqg_owner IN SCHEMA iqg_core
    REVOKE ALL ON TABLES FROM PUBLIC, iqg_app, iqg_gateway, iqg_bootstrap_invoker;
ALTER DEFAULT PRIVILEGES FOR ROLE iqg_owner IN SCHEMA iqg_fiscal
    REVOKE ALL ON TABLES FROM PUBLIC, iqg_app, iqg_gateway, iqg_bootstrap_invoker;
ALTER DEFAULT PRIVILEGES FOR ROLE iqg_owner IN SCHEMA iqg_core
    REVOKE ALL ON SEQUENCES FROM PUBLIC, iqg_app, iqg_gateway, iqg_bootstrap_invoker;
ALTER DEFAULT PRIVILEGES FOR ROLE iqg_owner IN SCHEMA iqg_fiscal
    REVOKE ALL ON SEQUENCES FROM PUBLIC, iqg_app, iqg_gateway, iqg_bootstrap_invoker;
ALTER DEFAULT PRIVILEGES FOR ROLE iqg_owner IN SCHEMA iqg_core
    REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC, iqg_app, iqg_gateway, iqg_bootstrap_invoker;
ALTER DEFAULT PRIVILEGES FOR ROLE iqg_owner IN SCHEMA iqg_fiscal
    REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC, iqg_app, iqg_gateway, iqg_bootstrap_invoker;

GRANT USAGE ON SCHEMA iqg_core TO iqg_bootstrap_invoker;
GRANT EXECUTE ON FUNCTION iqg_core.provisionar_empresa(
    varchar, uuid, bytea, bytea, bytea, uuid, char, varchar, boolean, boolean,
    varchar, varchar, varchar, text, text, bytea, bytea, uuid, uuid, bytea
) TO iqg_bootstrap_invoker;

-- PostgreSQL 16 aplica el default ACL de TYPE a tipos explícitos, pero los
-- tipos compuestos respaldados por relaciones (tablas, vistas y relaciones
-- futuras) requieren endurecimiento explícito. Este selector catalog-driven
-- se ejecuta tras crear todos los objetos relación del Core; no infiere arrays
-- por nombre ni toca tipos externos. Revocar el row type cierra el USAGE
-- efectivo de su array automático, cubierto por regresiones runtime.
DO $endurecer_row_types_iqg$
DECLARE
    v_row_type record;
BEGIN
    FOR v_row_type IN
        SELECT schema_iqg.nspname AS schema_name,
               type_iqg.typname AS type_name
          FROM pg_catalog.pg_type AS type_iqg
          JOIN pg_catalog.pg_class AS relation_iqg
            ON relation_iqg.oid = type_iqg.typrelid
           AND relation_iqg.reltype = type_iqg.oid
           AND relation_iqg.relnamespace = type_iqg.typnamespace
          JOIN pg_catalog.pg_namespace AS schema_iqg
            ON schema_iqg.oid = type_iqg.typnamespace
         WHERE schema_iqg.nspname IN ('iqg_core', 'iqg_fiscal')
           AND type_iqg.typtype = 'c'
           AND type_iqg.typrelid <> 0
           AND type_iqg.typowner = 'iqg_owner'::regrole
           AND relation_iqg.relowner = 'iqg_owner'::regrole
         ORDER BY schema_iqg.nspname, type_iqg.oid
    LOOP
        EXECUTE format(
            'REVOKE USAGE ON TYPE %I.%I FROM PUBLIC',
            v_row_type.schema_name,
            v_row_type.type_name
        );
    END LOOP;
END;
$endurecer_row_types_iqg$;

-- PRIVILEGED_BOOTSTRAP_PRINCIPAL solo asumió iqg_owner localmente para construir
-- objetos. RESET ROLE devuelve session_user y la verificación final exige que
-- iqg_owner no conserve ninguna membresía.
RESET ROLE;
DO $liberar_owner_instalacion$
BEGIN
    IF current_user <> session_user THEN
        RAISE EXCEPTION 'RESET ROLE no devolvió la identidad de instalación';
    END IF;
END;
$liberar_owner_instalacion$;

-- Fallar la migración si la postura de owner/ACL deja a una función SECURITY
-- DEFINER con una membership externa o deja SQL directo disponible para el rol
-- de aplicación.
DO $verificar_postura_seguridad$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM pg_roles
         WHERE rolname = 'iqg_owner'
           AND NOT rolsuper
           AND NOT rolbypassrls
           AND NOT rolcanlogin
           AND NOT rolcreaterole
           AND NOT rolcreatedb
           AND NOT rolreplication
           AND NOT rolinherit
    ) THEN
        RAISE EXCEPTION
            'iqg_owner debe ser NOLOGIN, NOSUPERUSER, NOBYPASSRLS, NOINHERIT, NOCREATEDB, NOCREATEROLE y NOREPLICATION';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM pg_roles
         WHERE rolname = 'iqg_app'
           AND NOT rolsuper
           AND NOT rolbypassrls
           AND NOT rolcanlogin
           AND NOT rolcreaterole
           AND NOT rolcreatedb
           AND NOT rolreplication
           AND NOT rolinherit
    ) THEN
        RAISE EXCEPTION
            'iqg_app debe ser un rol NOLOGIN, NOSUPERUSER, NOBYPASSRLS y NOINHERIT';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM pg_roles
         WHERE rolname = 'iqg_gateway'
           AND NOT rolsuper
           AND NOT rolbypassrls
           AND NOT rolcanlogin
           AND NOT rolcreaterole
           AND NOT rolcreatedb
           AND NOT rolreplication
           AND NOT rolinherit
    ) THEN
        RAISE EXCEPTION
            'iqg_gateway debe ser NOLOGIN, NOSUPERUSER, NOBYPASSRLS, NOINHERIT, NOCREATEDB, NOCREATEROLE y NOREPLICATION';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM pg_roles
         WHERE rolname = 'iqg_bootstrap_invoker'
           AND NOT rolsuper
           AND NOT rolbypassrls
           AND NOT rolcanlogin
           AND NOT rolcreaterole
           AND NOT rolcreatedb
           AND NOT rolreplication
           AND NOT rolinherit
    ) THEN
        RAISE EXCEPTION
            'iqg_bootstrap_invoker debe ser NOLOGIN, NOSUPERUSER, NOBYPASSRLS, NOINHERIT, NOCREATEDB, NOCREATEROLE y NOREPLICATION';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM pg_auth_members AS m
         WHERE m.roleid = 'iqg_owner'::regrole
    ) THEN
        RAISE EXCEPTION
            'iqg_owner debe terminar PHASE 1 con ZERO MEMBERS';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM pg_auth_members AS m
         WHERE m.member IN (
                'iqg_owner'::regrole,
                'iqg_app'::regrole,
                'iqg_gateway'::regrole,
                'iqg_bootstrap_invoker'::regrole
            )
    ) THEN
        RAISE EXCEPTION
            'Los roles IQG no pueden heredar ni asumir otros roles';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM pg_namespace AS n
         WHERE n.nspname = 'iqg_core'
           AND n.nspowner = 'iqg_owner'::regrole
    ) THEN
        RAISE EXCEPTION 'El esquema iqg_core debe pertenecer a iqg_owner';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM pg_namespace AS n
         WHERE n.nspname = 'iqg_fiscal'
           AND n.nspowner = 'iqg_owner'::regrole
    ) THEN
        RAISE EXCEPTION 'El esquema iqg_fiscal debe pertenecer a iqg_owner';
    END IF;

    -- La única ACL no implícita de schema permitida es USAGE no delegable del
    -- invocador operativo sobre iqg_core. Así una ACL del owner anterior, de
    -- PUBLIC o de un rol externo no puede sobrevivir el cambio de ownership.
    IF EXISTS (
        SELECT 1
          FROM pg_catalog.pg_namespace AS schema_iqg
         CROSS JOIN LATERAL pg_catalog.aclexplode(
             COALESCE(
                 schema_iqg.nspacl,
                 pg_catalog.acldefault('n', schema_iqg.nspowner)
             )
         ) AS acl
         WHERE schema_iqg.nspname IN ('iqg_core', 'iqg_fiscal')
           AND NOT (
               acl.grantee = schema_iqg.nspowner
               AND acl.grantor = schema_iqg.nspowner
               AND acl.privilege_type IN ('USAGE', 'CREATE')
               AND NOT acl.is_grantable
           )
           AND NOT (
               schema_iqg.nspname = 'iqg_core'
               AND acl.grantee = 'iqg_bootstrap_invoker'::regrole
               AND acl.grantor = 'iqg_owner'::regrole
               AND acl.privilege_type = 'USAGE'
               AND NOT acl.is_grantable
           )
    ) THEN
        RAISE EXCEPTION
            'Las ACL de schemas IQG sólo pueden conceder USAGE no delegable a iqg_bootstrap_invoker sobre iqg_core';
    END IF;

    -- Los default ACL relevantes se cierran a una allowlist exacta: sólo las
    -- dos revocaciones globales que sustituyen los defaults públicos de
    -- funciones y tipos. No se aceptan ACL por schema ni grants de terceros.
    IF (SELECT count(*)
          FROM pg_catalog.pg_default_acl AS default_acl
         WHERE default_acl.defaclrole = 'iqg_owner'::regrole
           AND default_acl.defaclnamespace = 0) <> 2
       OR EXISTS (
            SELECT 1
              FROM pg_catalog.pg_default_acl AS default_acl
             WHERE default_acl.defaclrole = 'iqg_owner'::regrole
               AND default_acl.defaclnamespace = 0
               AND NOT (
                   (default_acl.defaclobjtype = 'f'
                    AND default_acl.defaclacl IS NOT DISTINCT FROM ARRAY[
                        pg_catalog.makeaclitem(
                            'iqg_owner'::regrole,
                            'iqg_owner'::regrole,
                            'EXECUTE',
                            false
                        )
                    ]::aclitem[])
                   OR
                   (default_acl.defaclobjtype = 'T'
                    AND default_acl.defaclacl IS NOT DISTINCT FROM ARRAY[
                        pg_catalog.makeaclitem(
                            'iqg_owner'::regrole,
                            'iqg_owner'::regrole,
                            'USAGE',
                            false
                        )
                    ]::aclitem[])
               )
       )
       OR EXISTS (
            SELECT 1
              FROM pg_catalog.pg_default_acl AS default_acl
             WHERE default_acl.defaclnamespace IN (
                 'iqg_core'::regnamespace,
                 'iqg_fiscal'::regnamespace
             )
       ) THEN
        RAISE EXCEPTION
            'Los default ACL relevantes de IQG deben ser exactamente las revocaciones globales de PUBLIC para funciones y tipos';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM pg_class AS c
          JOIN pg_namespace AS n ON n.oid = c.relnamespace
         WHERE n.nspname = 'iqg_core'
           AND c.relkind IN ('r', 'p', 'v', 'm', 'S', 'f')
           AND c.relowner <> 'iqg_owner'::regrole
    ) THEN
        RAISE EXCEPTION
            'Todas las relaciones de iqg_core deben pertenecer a iqg_owner';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM pg_class AS c
          JOIN pg_namespace AS n ON n.oid = c.relnamespace
         WHERE n.nspname = 'iqg_fiscal'
           AND c.relkind IN ('r', 'p', 'v', 'm', 'S', 'f')
           AND c.relowner <> 'iqg_owner'::regrole
    ) THEN
        RAISE EXCEPTION
            'Todas las relaciones de iqg_fiscal deben pertenecer a iqg_owner';
    END IF;

    IF EXISTS (
        SELECT 1
         FROM pg_proc AS p
          JOIN pg_namespace AS n ON n.oid = p.pronamespace
          WHERE n.nspname = 'iqg_core'
            AND p.proowner <> 'iqg_owner'::regrole
    ) THEN
        RAISE EXCEPTION
            'Toda función de iqg_core debe pertenecer a iqg_owner';
    END IF;

    IF EXISTS (
        SELECT 1
         FROM pg_proc AS p
          JOIN pg_namespace AS n ON n.oid = p.pronamespace
          WHERE n.nspname = 'iqg_fiscal'
            AND p.proowner <> 'iqg_owner'::regrole
    ) THEN
        RAISE EXCEPTION
            'Toda función de iqg_fiscal debe pertenecer a iqg_owner';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM pg_type AS type_iqg
          JOIN pg_namespace AS schema_iqg ON schema_iqg.oid = type_iqg.typnamespace
         WHERE schema_iqg.nspname IN ('iqg_core', 'iqg_fiscal')
           AND type_iqg.typowner <> 'iqg_owner'::regrole
    ) THEN
        RAISE EXCEPTION
            'Todos los tipos, dominios y row types IQG deben pertenecer a iqg_owner';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM pg_class AS c
          JOIN pg_namespace AS n ON n.oid = c.relnamespace
         WHERE n.nspname = 'iqg_core'
           AND c.relkind IN ('r', 'p', 'v', 'm', 'S', 'f')
           AND (
               has_table_privilege('iqg_app', c.oid, 'SELECT')
               OR has_table_privilege('iqg_app', c.oid, 'INSERT')
               OR has_table_privilege('iqg_app', c.oid, 'UPDATE')
               OR has_table_privilege('iqg_app', c.oid, 'DELETE')
               OR has_table_privilege('iqg_app', c.oid, 'TRUNCATE')
               OR has_table_privilege('iqg_app', c.oid, 'REFERENCES')
               OR has_table_privilege('iqg_app', c.oid, 'TRIGGER')
           )
    ) THEN
        RAISE EXCEPTION
            'iqg_app no puede conservar privilegios directos sobre relaciones de iqg_core';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM pg_proc AS p
          JOIN pg_namespace AS n ON n.oid = p.pronamespace
         WHERE n.nspname = 'iqg_core'
           AND has_function_privilege('iqg_app', p.oid, 'EXECUTE')
    ) THEN
        RAISE EXCEPTION
            'iqg_app no puede ejecutar helpers ni funciones antes de una concesión de dominio revisada';
    END IF;

    IF NOT has_schema_privilege('iqg_bootstrap_invoker', 'iqg_core', 'USAGE')
       OR has_schema_privilege('iqg_bootstrap_invoker', 'iqg_core', 'CREATE')
       OR has_schema_privilege('iqg_bootstrap_invoker', 'iqg_fiscal', 'USAGE')
       OR has_schema_privilege('iqg_bootstrap_invoker', 'iqg_fiscal', 'CREATE') THEN
        RAISE EXCEPTION
            'iqg_bootstrap_invoker solo puede tener USAGE sobre iqg_core y nunca CREATE ni acceso fiscal';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM pg_class AS c
          JOIN pg_namespace AS n ON n.oid = c.relnamespace
         WHERE n.nspname IN ('iqg_core', 'iqg_fiscal')
           AND c.relkind IN ('r', 'p', 'v', 'm', 'f')
           AND (
                has_table_privilege('iqg_bootstrap_invoker', c.oid, 'SELECT')
                OR has_table_privilege('iqg_bootstrap_invoker', c.oid, 'INSERT')
                OR has_table_privilege('iqg_bootstrap_invoker', c.oid, 'UPDATE')
                OR has_table_privilege('iqg_bootstrap_invoker', c.oid, 'DELETE')
                OR has_table_privilege('iqg_bootstrap_invoker', c.oid, 'TRUNCATE')
                OR has_table_privilege('iqg_bootstrap_invoker', c.oid, 'REFERENCES')
                OR has_table_privilege('iqg_bootstrap_invoker', c.oid, 'TRIGGER')
           )
    ) THEN
        RAISE EXCEPTION
            'iqg_bootstrap_invoker no puede conservar privilegios directos sobre relaciones IQG';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM pg_class AS c
          JOIN pg_namespace AS n ON n.oid = c.relnamespace
         WHERE n.nspname IN ('iqg_core', 'iqg_fiscal')
           AND c.relkind = 'S'
           AND (
                has_sequence_privilege('iqg_bootstrap_invoker', c.oid, 'USAGE')
                OR has_sequence_privilege('iqg_bootstrap_invoker', c.oid, 'SELECT')
                OR has_sequence_privilege('iqg_bootstrap_invoker', c.oid, 'UPDATE')
           )
    ) THEN
        RAISE EXCEPTION
            'iqg_bootstrap_invoker no puede conservar privilegios directos sobre secuencias IQG';
    END IF;

    IF (SELECT count(*)
          FROM pg_proc AS p
          JOIN pg_namespace AS n ON n.oid = p.pronamespace
         WHERE n.nspname = 'iqg_core'
           AND p.proname = 'provisionar_empresa'
           AND has_function_privilege('iqg_bootstrap_invoker', p.oid, 'EXECUTE')) <> 1
       OR EXISTS (
            SELECT 1
              FROM pg_proc AS p
              JOIN pg_namespace AS n ON n.oid = p.pronamespace
             WHERE n.nspname IN ('iqg_core', 'iqg_fiscal')
               AND has_function_privilege('iqg_bootstrap_invoker', p.oid, 'EXECUTE')
               AND p.proname <> 'provisionar_empresa'
       ) THEN
        RAISE EXCEPTION
            'iqg_bootstrap_invoker solo puede ejecutar la firma única de provisionar_empresa';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM pg_namespace AS n
          CROSS JOIN (VALUES ('iqg_app'::name), ('iqg_gateway'::name)) AS ar(rol)
         WHERE n.nspname IN ('iqg_core', 'iqg_fiscal')
           AND (
               has_schema_privilege(ar.rol, n.oid, 'USAGE')
               OR has_schema_privilege(ar.rol, n.oid, 'CREATE')
           )
    ) THEN
        RAISE EXCEPTION
            'iqg_app e iqg_gateway no pueden conservar USAGE ni CREATE sobre los schemas IQG';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM pg_class AS c
          JOIN pg_namespace AS n ON n.oid = c.relnamespace
          CROSS JOIN (VALUES ('iqg_app'::name), ('iqg_gateway'::name)) AS ar(rol)
         WHERE n.nspname IN ('iqg_core', 'iqg_fiscal')
           AND c.relkind IN ('r', 'p', 'v', 'm', 'f')
           AND (
               has_table_privilege(ar.rol, c.oid, 'SELECT')
               OR has_table_privilege(ar.rol, c.oid, 'INSERT')
               OR has_table_privilege(ar.rol, c.oid, 'UPDATE')
               OR has_table_privilege(ar.rol, c.oid, 'DELETE')
               OR has_table_privilege(ar.rol, c.oid, 'TRUNCATE')
               OR has_table_privilege(ar.rol, c.oid, 'REFERENCES')
               OR has_table_privilege(ar.rol, c.oid, 'TRIGGER')
           )
    ) THEN
        RAISE EXCEPTION
            'iqg_app e iqg_gateway no pueden conservar privilegios directos sobre relaciones IQG';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM pg_class AS c
          JOIN pg_namespace AS n ON n.oid = c.relnamespace
          CROSS JOIN (VALUES ('iqg_app'::name), ('iqg_gateway'::name)) AS ar(rol)
         WHERE n.nspname IN ('iqg_core', 'iqg_fiscal')
           AND c.relkind = 'S'
           AND (
               has_sequence_privilege(ar.rol, c.oid, 'USAGE')
               OR has_sequence_privilege(ar.rol, c.oid, 'SELECT')
               OR has_sequence_privilege(ar.rol, c.oid, 'UPDATE')
           )
    ) THEN
        RAISE EXCEPTION
            'iqg_app e iqg_gateway no pueden conservar privilegios directos sobre secuencias IQG';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM pg_proc AS p
          JOIN pg_namespace AS n ON n.oid = p.pronamespace
          CROSS JOIN (VALUES ('iqg_app'::name), ('iqg_gateway'::name)) AS ar(rol)
         WHERE n.nspname IN ('iqg_core', 'iqg_fiscal')
           AND has_function_privilege(ar.rol, p.oid, 'EXECUTE')
    ) THEN
        RAISE EXCEPTION
            'iqg_app e iqg_gateway no pueden ejecutar funciones IQG antes de una concesión de endpoint revisada';
    END IF;

    -- Esta comprobación es exclusivamente de privilegio de catálogo. No afirma
    -- que PostgreSQL prohíba todo valor tipado dentro de una query; la regresión
    -- QA separa esa semántica de creación de dependencias, ACL y RLS.
    IF EXISTS (
        SELECT 1
          FROM pg_type AS type_iqg
          JOIN pg_namespace AS schema_iqg ON schema_iqg.oid = type_iqg.typnamespace
          CROSS JOIN (VALUES
              ('iqg_app'::name),
              ('iqg_gateway'::name),
              ('iqg_bootstrap_invoker'::name)
          ) AS role_iqg(role_name)
         WHERE schema_iqg.nspname IN ('iqg_core', 'iqg_fiscal')
           AND has_type_privilege(role_iqg.role_name, type_iqg.oid, 'USAGE')
    ) THEN
        RAISE EXCEPTION
            'Ningún rol IQG de runtime puede conservar USAGE sobre tipos, dominios o row types IQG';
    END IF;
END;
$verificar_postura_seguridad$;

-- PHASE 1_FINAL_SECURITY_POSTURE_VERIFIED: marcador para la prueba efímera
-- de rollback después de DDL, ACL, default ACL y verificaciones finales.
COMMIT;
