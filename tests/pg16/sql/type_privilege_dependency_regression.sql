\set ON_ERROR_STOP on

-- Regresión aislada de PostgreSQL 16.15. Distingue privilegio de catálogo,
-- lookup de schema, uso de valores en queries, creación de dependencias, ACL
-- de tabla/función y RLS. No toca iqg_core ni iqg_fiscal y revierte todo.
BEGIN;

CREATE ROLE qa_type_privilege_owner
    NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS NOINHERIT;
CREATE ROLE qa_type_privilege_consumer
    NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS NOINHERIT;
CREATE ROLE qa_type_privilege_rls_reader
    NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS NOINHERIT;

CREATE SCHEMA qa_type_privilege_source AUTHORIZATION qa_type_privilege_owner;
CREATE SCHEMA qa_type_privilege_consumer AUTHORIZATION postgres;

SET LOCAL ROLE qa_type_privilege_owner;
ALTER DEFAULT PRIVILEGES
    REVOKE USAGE ON TYPES FROM PUBLIC;

CREATE DOMAIN qa_type_privilege_source.domain_probe AS integer;
CREATE TYPE qa_type_privilege_source.enum_probe AS ENUM ('one', 'two');
CREATE TYPE qa_type_privilege_source.composite_probe AS (id integer);
CREATE TABLE qa_type_privilege_source.table_probe (id integer PRIMARY KEY);
INSERT INTO qa_type_privilege_source.table_probe (id) VALUES (1);
ALTER TABLE qa_type_privilege_source.table_probe ENABLE ROW LEVEL SECURITY;
ALTER TABLE qa_type_privilege_source.table_probe FORCE ROW LEVEL SECURITY;

CREATE FUNCTION qa_type_privilege_source.indirect_table_read()
RETURNS integer
LANGUAGE sql
SECURITY INVOKER
AS $$
    SELECT count(*)::integer
      FROM qa_type_privilege_source.table_probe;
$$;
REVOKE ALL ON FUNCTION qa_type_privilege_source.indirect_table_read() FROM PUBLIC;

RESET ROLE;
GRANT USAGE ON SCHEMA qa_type_privilege_source
    TO qa_type_privilege_consumer, qa_type_privilege_rls_reader;
GRANT USAGE, CREATE ON SCHEMA qa_type_privilege_consumer
    TO qa_type_privilege_consumer;
GRANT SELECT ON qa_type_privilege_source.table_probe TO qa_type_privilege_rls_reader;

-- CREATE TABLE asigna un row type con semántica de privilegios distinta de los
-- tipos explícitos. La revocación explícita del row type es intencional; el
-- array automático se comprueba, pero no se revoca por nombre.
REVOKE USAGE ON TYPE qa_type_privilege_source.table_probe FROM PUBLIC;

DO $type_privilege_regression$
DECLARE
    v_query_value_usage text := 'not_run';
    v_table_dependency text := 'not_run';
    v_function_dependency text := 'not_run';
    v_stored_expression_dependency text := 'not_run';
    v_table_read text := 'not_run';
    v_function_execution text := 'not_run';
    v_rls_visible_rows integer := NULL;
BEGIN
    IF (SELECT count(*)
          FROM pg_catalog.pg_type AS type_probe
          JOIN pg_catalog.pg_namespace AS schema_probe
            ON schema_probe.oid = type_probe.typnamespace
         WHERE schema_probe.nspname = 'qa_type_privilege_source'
           AND type_probe.typname IN (
               'domain_probe', '_domain_probe',
               'enum_probe', '_enum_probe',
               'composite_probe', '_composite_probe',
               'table_probe', '_table_probe'
           )) <> 8 THEN
        RAISE EXCEPTION 'TYPE_PRIVILEGE_REGRESSION: no se crearon los ocho tipos de prueba esperados';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM pg_catalog.pg_type AS type_probe
          JOIN pg_catalog.pg_namespace AS schema_probe
            ON schema_probe.oid = type_probe.typnamespace
          CROSS JOIN (VALUES
              ('qa_type_privilege_consumer'::name),
              ('qa_type_privilege_rls_reader'::name)
          ) AS role_probe(role_name)
         WHERE schema_probe.nspname = 'qa_type_privilege_source'
           AND type_probe.typname IN (
               'domain_probe', '_domain_probe',
               'enum_probe', '_enum_probe',
               'composite_probe', '_composite_probe',
               'table_probe', '_table_probe'
           )
           AND has_type_privilege(role_probe.role_name, type_probe.oid, 'USAGE')
    ) THEN
        RAISE EXCEPTION 'TYPE_PRIVILEGE_REGRESSION: un consumidor no dueño conserva USAGE de catálogo';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM pg_catalog.pg_type AS type_probe
          JOIN pg_catalog.pg_namespace AS schema_probe
            ON schema_probe.oid = type_probe.typnamespace
         WHERE schema_probe.nspname = 'qa_type_privilege_source'
           AND type_probe.typname IN (
               'domain_probe', '_domain_probe',
               'enum_probe', '_enum_probe',
               'composite_probe', '_composite_probe',
               'table_probe', '_table_probe'
           )
           AND NOT has_type_privilege('qa_type_privilege_owner', type_probe.oid, 'USAGE')
    ) THEN
        RAISE EXCEPTION 'TYPE_PRIVILEGE_REGRESSION: el dueño perdió USAGE de catálogo';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM pg_catalog.pg_type AS row_type
          JOIN pg_catalog.pg_class AS relation_probe
            ON relation_probe.oid = row_type.typrelid
           AND relation_probe.reltype = row_type.oid
          JOIN pg_catalog.pg_namespace AS schema_probe
            ON schema_probe.oid = row_type.typnamespace
          LEFT JOIN pg_catalog.pg_type AS array_type
            ON array_type.typelem = row_type.oid
           AND array_type.typcategory = 'A'
         WHERE schema_probe.nspname = 'qa_type_privilege_source'
           AND row_type.typname = 'table_probe'
           AND row_type.typtype = 'c'
           AND row_type.typrelid <> 0
           AND relation_probe.relkind IN ('r', 'p')
           AND (
               array_type.oid IS NULL
               OR has_type_privilege('qa_type_privilege_consumer', row_type.oid, 'USAGE')
               OR has_type_privilege('qa_type_privilege_consumer', array_type.oid, 'USAGE')
               OR NOT has_type_privilege('qa_type_privilege_owner', row_type.oid, 'USAGE')
               OR NOT has_type_privilege('qa_type_privilege_owner', array_type.oid, 'USAGE')
           )
    ) THEN
        RAISE EXCEPTION 'TYPE_PRIVILEGE_REGRESSION: row type o array automático no conserva la postura esperada';
    END IF;

    EXECUTE 'SET LOCAL ROLE qa_type_privilege_consumer';
    BEGIN
        -- PostgreSQL documenta que TYPE USAGE no controla todo uso de valores
        -- en queries. Este éxito no autoriza crear una dependencia.
        EXECUTE 'SELECT NULL::qa_type_privilege_source._table_probe';
        v_query_value_usage := 'succeeded';
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_query_value_usage = RETURNED_SQLSTATE;
    END;
    BEGIN
        EXECUTE 'CREATE TABLE qa_type_privilege_consumer.object_probe (payload qa_type_privilege_source.table_probe)';
        v_table_dependency := 'succeeded';
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_table_dependency = RETURNED_SQLSTATE;
    END;
    BEGIN
        EXECUTE 'CREATE FUNCTION qa_type_privilege_consumer.function_dependency_probe(p qa_type_privilege_source.table_probe) RETURNS integer LANGUAGE sql AS $$ SELECT 1 $$';
        v_function_dependency := 'succeeded';
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_function_dependency = RETURNED_SQLSTATE;
    END;
    BEGIN
        EXECUTE 'CREATE TABLE qa_type_privilege_consumer.stored_expression_probe (id integer NOT NULL, CONSTRAINT stored_expression_uses_restricted_type CHECK ((ROW(id)::qa_type_privilege_source.table_probe) IS NOT NULL))';
        v_stored_expression_dependency := 'succeeded';
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_stored_expression_dependency = RETURNED_SQLSTATE;
    END;
    BEGIN
        EXECUTE 'SELECT count(*) FROM qa_type_privilege_source.table_probe';
        v_table_read := 'succeeded';
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_table_read = RETURNED_SQLSTATE;
    END;
    BEGIN
        EXECUTE 'SELECT qa_type_privilege_source.indirect_table_read()';
        v_function_execution := 'succeeded';
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_function_execution = RETURNED_SQLSTATE;
    END;
    EXECUTE 'RESET ROLE';

    EXECUTE 'SET LOCAL ROLE qa_type_privilege_rls_reader';
    EXECUTE 'SELECT count(*) FROM qa_type_privilege_source.table_probe' INTO v_rls_visible_rows;
    EXECUTE 'RESET ROLE';

    IF v_query_value_usage <> 'succeeded'
       OR v_table_dependency <> '42501'
       OR v_function_dependency <> '42501'
       OR v_stored_expression_dependency <> '42501'
       OR v_table_read <> '42501'
       OR v_function_execution <> '42501'
       OR v_rls_visible_rows <> 0 THEN
        RAISE EXCEPTION USING
            MESSAGE = format(
                'TYPE_PRIVILEGE_REGRESSION: query_value_usage=%s table_dependency=%s function_dependency=%s stored_expression_dependency=%s table_read=%s function_execution=%s rls_visible_rows=%s',
                v_query_value_usage,
                v_table_dependency,
                v_function_dependency,
                v_stored_expression_dependency,
                v_table_read,
                v_function_execution,
                v_rls_visible_rows
            );
    END IF;
END;
$type_privilege_regression$;

ROLLBACK;
