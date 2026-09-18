\set ON_ERROR_STOP on

-- Regresión aislada PostgreSQL 16.15 para los tipos compuestos que CREATE VIEW
-- genera implícitamente. La relación view -> row type -> typarray se resuelve
-- por catálogo; no depende del prefijo técnico de los arrays. Todo revierte.
BEGIN;

CREATE ROLE qa_view_type_owner
    NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS NOINHERIT;
CREATE ROLE qa_view_type_consumer
    NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS NOINHERIT;

CREATE SCHEMA qa_view_type_source AUTHORIZATION qa_view_type_owner;

SET LOCAL ROLE qa_view_type_owner;
ALTER DEFAULT PRIVILEGES
    REVOKE USAGE ON TYPES FROM PUBLIC;

CREATE TABLE qa_view_type_source.source_relation (id integer PRIMARY KEY);
INSERT INTO qa_view_type_source.source_relation (id) VALUES (1);
CREATE VIEW qa_view_type_source.current_projection AS
SELECT id
  FROM qa_view_type_source.source_relation;

RESET ROLE;
GRANT USAGE ON SCHEMA qa_view_type_source TO qa_view_type_consumer;

DO $view_row_type_array_regression$
DECLARE
    v_view_row_type oid;
    v_view_array_type oid;
BEGIN
    SELECT row_type.oid,
           row_type.typarray
      INTO v_view_row_type,
           v_view_array_type
      FROM pg_catalog.pg_type AS row_type
      JOIN pg_catalog.pg_class AS view_relation
        ON view_relation.oid = row_type.typrelid
       AND view_relation.reltype = row_type.oid
       AND view_relation.relnamespace = row_type.typnamespace
      JOIN pg_catalog.pg_namespace AS view_schema
        ON view_schema.oid = row_type.typnamespace
     WHERE view_schema.nspname = 'qa_view_type_source'
       AND row_type.typtype = 'c'
       AND row_type.typrelid <> 0
       AND view_relation.relkind = 'v'
     ORDER BY row_type.oid
     LIMIT 1;

    IF v_view_row_type IS NULL OR v_view_array_type = 0 THEN
        RAISE EXCEPTION 'VIEW_ROW_TYPE_ARRAY_REGRESSION: la vista no produjo row type y array automáticos por catálogo';
    END IF;

    IF NOT has_type_privilege('qa_view_type_consumer', v_view_row_type, 'USAGE')
       OR NOT has_type_privilege('qa_view_type_consumer', v_view_array_type, 'USAGE') THEN
        RAISE EXCEPTION 'VIEW_ROW_TYPE_ARRAY_REGRESSION: la vista no expuso el USAGE inicial esperado para row type y array';
    END IF;

    EXECUTE format(
        'REVOKE USAGE ON TYPE %s FROM PUBLIC',
        v_view_row_type::regtype
    );

    IF has_type_privilege('qa_view_type_consumer', v_view_row_type, 'USAGE')
       OR has_type_privilege('qa_view_type_consumer', v_view_array_type, 'USAGE') THEN
        RAISE EXCEPTION 'VIEW_ROW_TYPE_ARRAY_REGRESSION: REVOKE del row type no cerró el USAGE efectivo de su array automático';
    END IF;

    IF NOT has_type_privilege('qa_view_type_owner', v_view_row_type, 'USAGE')
       OR NOT has_type_privilege('qa_view_type_owner', v_view_array_type, 'USAGE') THEN
        RAISE EXCEPTION 'VIEW_ROW_TYPE_ARRAY_REGRESSION: el dueño perdió USAGE sobre el row type o array de la vista';
    END IF;
END;
$view_row_type_array_regression$;

ROLLBACK;
