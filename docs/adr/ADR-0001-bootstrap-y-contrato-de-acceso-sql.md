# ADR-0001 — Bootstrap y contrato mínimo de acceso SQL

**Estado:** Aceptado para IQG-001.2
**Fecha:** 2026-09-11
**Decisores:** IQ GROWTH Architecture / Codex
**Alcance:** PostgreSQL 16 de referencia; no decide el motor productivo.

## Contexto

Los valores `iqg.company_id`, `iqg.branch_id`, `iqg.usuario_id` y los demás
`iqg.*` son parámetros de sesión que PostgreSQL permite establecer. Por sí
solos no prueban autenticación, autorización ni pertenencia a un tenant.

La versión previa de `contexto_bootstrap_activo()` comprobaba
`current_user = 'iqg_owner'` dentro de una función `SECURITY DEFINER`. Esa
comprobación es inválida como autenticación: dentro de una función de ese tipo
`current_user` representa al propietario efectivo de la función. El dato que
permanece ligado a quien abrió la conexión es `session_user`.

También se debe evitar el atajo de conceder `USAGE`, `SELECT`, DML o `EXECUTE`
amplios a `iqg_app` para que una policy RLS pueda operar. El núcleo mantiene
RLS `FORCE` incluso para `iqg_owner`; los endpoints de dominio estrechos son
el límite de confianza futuro.

## Decisión

1. Se crea `iqg_bootstrap_invoker` como rol de capacidad sin inicio de sesión,
   sin superusuario, sin `BYPASSRLS`, sin `CREATEROLE`, sin `CREATEDB` y sin
   herencia propia.
2. La única ACL de ese rol es `USAGE` sobre `iqg_core` y `EXECUTE` sobre la
   firma completa de `iqg_core.provisionar_empresa(...)`. No recibe tablas,
   secuencias, helpers, acceso a `iqg_fiscal` ni `CREATE`.
3. `contexto_bootstrap_activo()` exige simultáneamente:
   - una fila **directa** de `pg_auth_members` para `session_user` hacia
     `iqg_bootstrap_invoker`;
   - `inherit_option = true` y `set_option = false` en esa membresía;
   - que el invocador no sea superusuario, no tenga `BYPASSRLS`, pueda iniciar
     sesión y no sea miembro de `iqg_owner`;
   - contexto y clave de idempotencia completos.
4. La membresía de una identidad de provisioning se concede de forma explícita
   con `INHERIT TRUE, SET FALSE, ADMIN FALSE`. Así la identidad puede usar el
   único endpoint autorizado pero no puede `SET ROLE iqg_bootstrap_invoker` ni
   asumir `iqg_owner`.
5. `iqg_app` e `iqg_gateway` no son miembros de `iqg_bootstrap_invoker` y no
   reciben acceso SQL directo. El DDL verifica estas prohibiciones al instalar.
6. Las tablas de evidencia de identidad usan únicamente policies internas para
   que una función `SECURITY DEFINER` pueda comprobar una membresía bajo
   `FORCE ROW LEVEL SECURITY`; estas policies no se conceden como acceso de
   tabla a roles de cliente.

## Contrato del gateway futuro

No se construye un gateway en este ticket. Cuando exista, cada conexión de
gateway debe autenticarse fuera de PostgreSQL y cumplir este contrato:

1. No usar `iqg_app`, `iqg_gateway` ni `iqg_owner` como login de cliente.
2. Recibir únicamente `USAGE` de un schema de API revisado y `EXECUTE` de
   endpoints concretos. Nunca recibir acceso directo a `iqg_core` o
   `iqg_fiscal`.
3. Cada endpoint debe ser `SECURITY DEFINER`, con `search_path` fijo y con una
   operación de negocio definida. No habrá un endpoint genérico que reciba
   tenant, sucursal y usuario como autoridad arbitraria.
4. El endpoint debe obtener identidad ya autenticada, establecer el contexto
   de forma local a la transacción, exigir membresía activa y comprobar el
   permiso de negocio antes de escribir.
5. Helpers de policy, tablas de evidencia y funciones de auditoría siguen sin
   `EXECUTE` para el rol de conexión. El endpoint corre como `iqg_owner`, que
   sigue sujeto a RLS por `FORCE ROW LEVEL SECURITY`.

## Consecuencias

- Una sesión que falsifique solo GUCs falla cerrada: no obtiene la capacidad de
  bootstrap ni acceso a tablas.
- Un superusuario sigue siendo una frontera administrativa del clúster y no
  forma parte de la garantía de aislamiento SQL.
- Provisioning queda disponible únicamente para una identidad explícitamente
  enrolada, sin conceder el propietario técnico ni DML general.
- El arnés PostgreSQL 16 debe demostrar ambos sentidos: alta legítima por un
  miembro directo y rechazo de un no miembro con todos los GUCs falsificados.

## Referencias técnicas

- [PostgreSQL 16: CREATE FUNCTION — SECURITY DEFINER](https://www.postgresql.org/docs/16/sql-createfunction.html)
- [PostgreSQL 16: CREATE POLICY](https://www.postgresql.org/docs/16/sql-createpolicy.html)
- [PostgreSQL 16: session_user y current_user](https://www.postgresql.org/docs/16/functions-info.html)
