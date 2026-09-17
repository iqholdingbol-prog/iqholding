\set ON_ERROR_STOP on

-- Sonda aislada de PostgreSQL 16. Toda la preparación ocurre dentro de una
-- única transacción que se aborta deliberadamente al final; no deja roles,
-- schemas, ACL ni datos fuera del arnés efímero.
BEGIN;

CREATE ROLE qa_type_semantics_owner
    NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS NOINHERIT;
CREATE ROLE qa_type_semantics_no_schema
    NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS NOINHERIT;
CREATE ROLE qa_type_semantics_schema
    NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS NOINHERIT;
CREATE ROLE qa_type_semantics_rls
    NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS NOINHERIT;

CREATE SCHEMA qa_type_semantics AUTHORIZATION qa_type_semantics_owner;

SET LOCAL ROLE qa_type_semantics_owner;

-- Este es exactamente el contrato que se examina en IQG: se intenta retirar
-- USAGE público de tipos creados después por este owner.
ALTER DEFAULT PRIVILEGES
    REVOKE USAGE ON TYPES FROM PUBLIC;

CREATE DOMAIN qa_type_semantics.domain_probe AS integer;
CREATE TYPE qa_type_semantics.enum_probe AS ENUM ('one', 'two');
CREATE TYPE qa_type_semantics.composite_probe AS (id integer);
CREATE TABLE qa_type_semantics.table_probe (id integer PRIMARY KEY);
INSERT INTO qa_type_semantics.table_probe (id) VALUES (1);
ALTER TABLE qa_type_semantics.table_probe ENABLE ROW LEVEL SECURITY;
ALTER TABLE qa_type_semantics.table_probe FORCE ROW LEVEL SECURITY;

CREATE FUNCTION qa_type_semantics.indirect_table_read()
RETURNS integer
LANGUAGE sql
SECURITY INVOKER
AS $$
    SELECT count(*)::integer
      FROM qa_type_semantics.table_probe;
$$;
REVOKE ALL ON FUNCTION qa_type_semantics.indirect_table_read() FROM PUBLIC;

RESET ROLE;

-- Un consumidor puede recibir USAGE de schema sin recibir SELECT de tabla ni
-- EXECUTE de función. Un segundo consumidor recibe SELECT sólo para demostrar
-- que FORCE RLS sigue aplicándose aun cuando la ACL de relación exista.
GRANT USAGE ON SCHEMA qa_type_semantics TO qa_type_semantics_schema, qa_type_semantics_rls;
GRANT SELECT ON qa_type_semantics.table_probe TO qa_type_semantics_rls;

DO $type_privilege_semantics$
DECLARE
    v_catalog jsonb;
    v_no_schema_cast text := 'not_run';
    v_no_schema_table_read text := 'not_run';
    v_no_schema_function text := 'not_run';
    v_schema_cast text := 'not_run';
    v_schema_table_read text := 'not_run';
    v_schema_function text := 'not_run';
    v_rls_visible_rows integer := NULL;
BEGIN
    SELECT jsonb_agg(
               jsonb_build_object(
                   'role', role_probe.role_name,
                   'typname', type_probe.typname,
                   'typtype', type_probe.typtype,
                   'typrelid', type_probe.typrelid,
                   'typcategory', type_probe.typcategory,
                   'typelem', type_probe.typelem,
                   'typacl', COALESCE(type_probe.typacl::text, '<null>'),
                   'effective_typacl', array_to_string(
                       COALESCE(
                           type_probe.typacl,
                           pg_catalog.acldefault('T', type_probe.typowner)
                       ),
                       ','
                   ),
                   'classification', CASE
                       WHEN type_probe.typtype = 'c' AND type_probe.typrelid <> 0 THEN 'table_row_type'
                       WHEN type_probe.typcategory = 'A' AND type_probe.typelem <> 0 THEN 'array_type'
                       WHEN type_probe.typtype = 'd' THEN 'domain'
                       WHEN type_probe.typtype = 'e' THEN 'enum'
                       WHEN type_probe.typtype = 'c' THEN 'independent_composite'
                       WHEN type_probe.typtype = 'b' THEN 'base_type'
                       ELSE 'other'
                   END,
                   'has_usage', has_type_privilege(role_probe.role_name, type_probe.oid, 'USAGE')
               )
               ORDER BY role_probe.role_name, type_probe.typname
           )
      INTO v_catalog
      FROM pg_catalog.pg_type AS type_probe
      JOIN pg_catalog.pg_namespace AS schema_probe
        ON schema_probe.oid = type_probe.typnamespace
      CROSS JOIN (VALUES
          ('qa_type_semantics_no_schema'::name),
          ('qa_type_semantics_schema'::name),
          ('qa_type_semantics_rls'::name)
      ) AS role_probe(role_name)
     WHERE schema_probe.nspname = 'qa_type_semantics'
       AND type_probe.typname IN (
           'domain_probe',
           '_domain_probe',
           'enum_probe',
           '_enum_probe',
           'composite_probe',
           '_composite_probe',
           'table_probe',
           '_table_probe'
       );

    EXECUTE 'SET LOCAL ROLE qa_type_semantics_no_schema';
    BEGIN
        EXECUTE 'SELECT NULL::qa_type_semantics._table_probe';
        v_no_schema_cast := 'succeeded';
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_no_schema_cast = RETURNED_SQLSTATE;
    END;
    BEGIN
        EXECUTE 'SELECT count(*) FROM qa_type_semantics.table_probe';
        v_no_schema_table_read := 'succeeded';
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_no_schema_table_read = RETURNED_SQLSTATE;
    END;
    BEGIN
        EXECUTE 'SELECT qa_type_semantics.indirect_table_read()';
        v_no_schema_function := 'succeeded';
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_no_schema_function = RETURNED_SQLSTATE;
    END;
    EXECUTE 'RESET ROLE';

    EXECUTE 'SET LOCAL ROLE qa_type_semantics_schema';
    BEGIN
        EXECUTE 'SELECT NULL::qa_type_semantics._table_probe';
        v_schema_cast := 'succeeded';
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_schema_cast = RETURNED_SQLSTATE;
    END;
    BEGIN
        EXECUTE 'SELECT count(*) FROM qa_type_semantics.table_probe';
        v_schema_table_read := 'succeeded';
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_schema_table_read = RETURNED_SQLSTATE;
    END;
    BEGIN
        EXECUTE 'SELECT qa_type_semantics.indirect_table_read()';
        v_schema_function := 'succeeded';
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_schema_function = RETURNED_SQLSTATE;
    END;
    EXECUTE 'RESET ROLE';

    EXECUTE 'SET LOCAL ROLE qa_type_semantics_rls';
    EXECUTE 'SELECT count(*) FROM qa_type_semantics.table_probe' INTO v_rls_visible_rows;
    EXECUTE 'RESET ROLE';

    RAISE NOTICE 'TYPE_PRIVILEGE_SEMANTICS_CATALOG %', v_catalog;
    RAISE NOTICE 'TYPE_PRIVILEGE_SEMANTICS_CAPABILITIES no_schema_array_cast=% no_schema_table_read=% no_schema_function=% schema_array_cast=% schema_table_read=% schema_function=% rls_visible_rows=%',
        v_no_schema_cast,
        v_no_schema_table_read,
        v_no_schema_function,
        v_schema_cast,
        v_schema_table_read,
        v_schema_function,
        v_rls_visible_rows;

    RAISE EXCEPTION USING
        ERRCODE = 'P0001',
        MESSAGE = 'TYPE_PRIVILEGE_SEMANTICS_DIAGNOSTIC_COMPLETE';
END;
$type_privilege_semantics$;