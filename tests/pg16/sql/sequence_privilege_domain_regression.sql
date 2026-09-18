\set ON_ERROR_STOP on

-- Regresión aislada PostgreSQL 16.15 para la frontera de dominio de
-- has_sequence_privilege. Un scan de pg_class contiene secuencias y relaciones
-- no-secuencia; CASE protege la llamada sin depender del orden de evaluación
-- de predicados WHERE. Todo se revierte al terminar.
BEGIN;

CREATE ROLE qa_sequence_privilege_consumer
    NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS NOINHERIT;
CREATE SCHEMA qa_sequence_privilege_domain AUTHORIZATION postgres;
CREATE TABLE qa_sequence_privilege_domain.probe_relation (id integer PRIMARY KEY);
CREATE SEQUENCE qa_sequence_privilege_domain.probe_sequence;
GRANT USAGE ON SEQUENCE qa_sequence_privilege_domain.probe_sequence
    TO qa_sequence_privilege_consumer;

DO $sequence_privilege_domain_regression$
DECLARE
    v_sequence_count integer;
    v_non_sequence_count integer;
    v_usage_granted boolean;
    v_usage_revoked boolean;
BEGIN
    SELECT count(*) FILTER (WHERE c.relkind = 'S'),
           count(*) FILTER (WHERE c.relkind <> 'S')
      INTO v_sequence_count,
           v_non_sequence_count
      FROM pg_catalog.pg_class AS c
      JOIN pg_catalog.pg_namespace AS n
        ON n.oid = c.relnamespace
     WHERE n.nspname = 'qa_sequence_privilege_domain'
       AND c.relname IN ('probe_relation', 'probe_sequence');

    IF v_sequence_count <> 1 OR v_non_sequence_count <> 1 THEN
        RAISE EXCEPTION 'SEQUENCE_PRIVILEGE_DOMAIN_REGRESSION: el fixture no contiene una secuencia y una relación no-secuencia';
    END IF;

    -- Esta consulta cruza ambos relkind. La función especializada vive solo
    -- dentro de THEN, por lo que nunca recibe el OID de probe_relation.
    SELECT COALESCE(bool_or(
               CASE
                   WHEN c.relkind = 'S' THEN
                       has_sequence_privilege(
                           'qa_sequence_privilege_consumer',
                           c.oid,
                           'USAGE'
                       )
                   ELSE false
               END
           ), false)
      INTO v_usage_granted
      FROM pg_catalog.pg_class AS c
      JOIN pg_catalog.pg_namespace AS n
        ON n.oid = c.relnamespace
     WHERE n.nspname = 'qa_sequence_privilege_domain'
       AND c.relname IN ('probe_relation', 'probe_sequence');

    IF v_usage_granted IS DISTINCT FROM true THEN
        RAISE EXCEPTION 'SEQUENCE_PRIVILEGE_DOMAIN_REGRESSION: la secuencia no fue comprobada normalmente con USAGE concedido';
    END IF;

    REVOKE USAGE ON SEQUENCE qa_sequence_privilege_domain.probe_sequence
        FROM qa_sequence_privilege_consumer;

    SELECT COALESCE(bool_or(
               CASE
                   WHEN c.relkind = 'S' THEN
                       has_sequence_privilege(
                           'qa_sequence_privilege_consumer',
                           c.oid,
                           'USAGE'
                       )
                   ELSE false
               END
           ), false)
      INTO v_usage_revoked
      FROM pg_catalog.pg_class AS c
      JOIN pg_catalog.pg_namespace AS n
        ON n.oid = c.relnamespace
     WHERE n.nspname = 'qa_sequence_privilege_domain'
       AND c.relname IN ('probe_relation', 'probe_sequence');

    IF v_usage_revoked IS DISTINCT FROM false THEN
        RAISE EXCEPTION 'SEQUENCE_PRIVILEGE_DOMAIN_REGRESSION: la secuencia no fue comprobada normalmente después de revocar USAGE';
    END IF;
END;
$sequence_privilege_domain_regression$;

ROLLBACK;
