# ADR-0004 — Bootstrap privilegiado de infraestructura para PostgreSQL 16

**Estado:** Aceptado para IQG-001.2
**Fecha:** 2026-09-16
**Decisores:** CEO / IQ GROWTH Architecture / Codex
**Alcance:** PostgreSQL 16 como dialecto y arnés de referencia. No selecciona el
motor productivo ni autoriza privilegios de runtime.
**Relacionada con:** ADR-0001, ADR-0002 y ADR-0003.

## Contexto y problema observado

El Core requiere que `iqg_owner` sea un owner técnico dedicado: `NOLOGIN`,
`NOSUPERUSER`, `NOCREATEDB`, `NOCREATEROLE`, `NOREPLICATION`, `NOBYPASSRLS`,
`NOINHERIT` y con cero filas en `pg_auth_members` donde sea `roleid`. Este
invariante evita una vía normal para asumir el owner técnico y hace verificable
la protección `FORCE ROW LEVEL SECURITY`.

La matriz PostgreSQL 16 mostró que el mecanismo anterior de préstamo temporal
de owner mediante un instalador `CREATEROLE` no superusuario no puede cumplir
ese invariante. Los runs de CI que llevaron a esta decisión fueron:

| Commit | Run | Resultado relevante |
| --- | --- | --- |
| `9081c2f` | `35055711594` | `SQLSTATE 0LP01`: PostgreSQL rechazó devolver `ADMIN` al propio grantor. |
| `33aa490` | `35055957381` | El instalador no podía `SET ROLE iqg_owner`. |
| `b2ae168` | `35144375460` | La aserción final detectó una membresía residual de `iqg_owner`. |

`ai-council/IQG-001/reports/2026-09-16_1617_codex.md` conserva evidencia
detallada del run `35144375460`; los dos runs anteriores se registran aquí como
contexto de la decisión y requieren recuperar sus artefactos si se necesitan
como prueba independiente. PostgreSQL 16 puede dar al creador no superusuario
una membership automática con un grantor que el mismo creador no puede retirar
de forma segura. Por ello, el conjunto
`CREATEROLE` no superusuario + creación inicial de `iqg_owner` + `ZERO MEMBERS`
no es compatible con ese flujo.

Esto no justifica elevar roles IQG ni relajar el invariante. La aserción fue la
que reveló el defecto y se conserva.

## Decisión

Se separan físicamente tres fases y se define el concepto de capacidad
`PRIVILEGED_BOOTSTRAP_PRINCIPAL`.

### Phase 0 — Bootstrap privilegiado de infraestructura

`schemas/bootstrap_roles.sql` establece exclusivamente la topología global de
roles. Debe ejecutarse mediante una identidad de despliegue que pueda:

1. crear, alterar, inspeccionar y retirar roles/memberships de infraestructura;
2. crear, asumir y eliminar un rol técnico `NOLOGIN` sin dejar una membership
   persistente;
3. establecer los cuatro roles IQG sin convertir a ningún rol IQG en
   superusuario, login o `BYPASSRLS`;
4. fallar cerrado y de manera transaccional si no puede demostrar esas
   capacidades.
5. tomar durante Phase 0 los locks de relación necesarios sobre los catálogos
   compartidos de autorización del clúster.

El script no crea schemas, tablas, funciones, ACL de dominio, datos de
empresa, contraseñas ni secretos. Normaliza las relaciones conocidas entre
roles IQG. Si encuentra que un rol IQG hereda de un rol externo desconocido,
falla cerrado en vez de revocar una relación ajena sin revisión explícita.

La implementación candidata de Phase 0 no usa advisory locks: PostgreSQL los
limita a la base de datos de cada sesión, mientras que roles y memberships son
globales al clúster. Intenta adquirir un lock transaccional `SHARE ROW
EXCLUSIVE` sobre los catálogos compartidos `pg_authid` y `pg_auth_members`
antes de consultar o alterar la topología. La prueba concurrente BOOT-02 debe
demostrar en PostgreSQL 16 real que ese lock excluye transacciones desde otras
bases; esta decisión no declara esa garantía como PASS hasta que exista el run
de CI del candidato. El lock no entrega un privilegio nuevo ni se conserva tras
el `COMMIT`; si el proveedor no permite tomarlo, Phase 0 falla cerrado.

En la referencia PostgreSQL 16, tomar locks sobre catálogos compartidos,
transferir ownership de schemas y asumir temporalmente `iqg_owner` requiere una
capacidad de infraestructura elevada, que puede ser superuser-equivalente según
el proveedor. `PRIVILEGED_BOOTSTRAP_PRINCIPAL` no fija un nombre ni convierte
esa capacidad en rol de runtime: el despliegue debe demostrarla o fallar
cerrado con `DEPLOYMENT_CAPABILITY_INCOMPATIBLE`.

En el arnés efímero PostgreSQL 16, `postgres` es la implementación de CI que
se pretende verificar como `PRIVILEGED_BOOTSTRAP_PRINCIPAL`. No es un nombre de
usuario obligatorio, un proveedor exigido ni una identidad de producción.

### Postcondición de Phase 0

Se crean o endurecen `iqg_owner`, `iqg_app`, `iqg_gateway` e
`iqg_bootstrap_invoker` con esta postura:

```text
iqg_owner
- NOLOGIN
- NOSUPERUSER
- NOCREATEDB
- NOCREATEROLE
- NOREPLICATION
- NOBYPASSRLS
- NOINHERIT
- ZERO MEMBERS
```

Los cuatro roles IQG no pueden heredar ni asumir otro rol. Las identidades de
conexión externas pueden recibir una capacidad IQG acotada en sentido inverso,
por ejemplo una membership directa hacia `iqg_bootstrap_invoker` bajo el
contrato de ADR-0001. Eso no convierte al rol IQG en miembro de otro rol.

`iqg_app`, `iqg_gateway` e `iqg_bootstrap_invoker` nunca reciben
`iqg_owner`, `SUPERUSER` ni `BYPASSRLS`. No se abren schemas a `PUBLIC` ni se
agregan grants directos amplios.

### Phase 1 — Instalación del Core por base de datos

`schemas/core_schema.sql` exige la postcondición segura de Phase 0. El
principal de despliegue crea los schemas `iqg_core` e `iqg_fiscal`, asigna su
ownership a `iqg_owner` y recién entonces asume localmente ese owner para crear
objetos del Core. Nunca recibe una membership persistente hacia `iqg_owner`.

Si el proveedor puede crear el rol de prueba de Phase 0 pero no puede crear un
schema, asignar ownership o asumir `iqg_owner` en Phase 1, la instalación falla
con `DEPLOYMENT_CAPABILITY_INCOMPATIBLE`. La transacción de Phase 1 revierte los
schemas y objetos de esa base. La topología segura ya comprometida por Phase 0
puede permanecer y se verifica antes de reintentar Phase 1.

El archivo representa instalación inicial en una base limpia. No afirma ser un
framework de migraciones estructurales arbitrarias sobre una base poblada. Una
migración futura debe declarar y auditar su capacidad mínima de despliegue; no
puede reutilizar roles de runtime ni agregar members persistentes a
`iqg_owner`.

### Phase 2 — Runtime normal

El runtime no reutiliza `PRIVILEGED_BOOTSTRAP_PRINCIPAL`. Opera con ACL mínimas,
RLS `FORCE` e interfaces `SECURITY DEFINER` revisadas. ADR-0001 sigue vigente:
`iqg_bootstrap_invoker` es una capacidad operacional limitada para
`provisionar_empresa(...)`; no es un administrador de infraestructura y nunca
puede asumir `iqg_owner`.

## Frontera de confianza

```text
PRIVILEGED_BOOTSTRAP_PRINCIPAL (solo Phase 0/1 de despliegue)
        |
        v
Topología IQG cerrada
        |
        +--> iqg_owner (NOLOGIN, ZERO MEMBERS, NOBYPASSRLS)
        |        |
        |        v
        |    SECURITY DEFINER / interfaces de dominio controladas
        |
        +--> iqg_app / iqg_gateway / iqg_bootstrap_invoker
                 |
                 v
             RLS + FORCE RLS + ACL mínima
```

El administrador de infraestructura no forma parte de la garantía de
aislamiento del runtime y no queda enrolado en `iqg_owner`. No aparece como
secreto ni configuración sensible en el repositorio.

## Alternativas consideradas

| Alternativa | Decisión | Razón |
| --- | --- | --- |
| Mantener self-`GRANT`/self-`REVOKE` temporal bajo `CREATEROLE` | Rechazada | La evidencia PostgreSQL 16 muestra que no puede eliminar el grant emitido por otro grantor. |
| Relajar `iqg_owner ZERO MEMBERS` | Rechazada | Eliminaría el invariante que detectó el defecto. |
| Conceder `SUPERUSER` o `BYPASSRLS` a un rol IQG | Rechazada | Rompe mínimo privilegio y la frontera RLS. |
| Abrir `PUBLIC` o ACLs directas para app/gateway | Rechazada | No resuelve la topology y debilita aislamiento. |
| Usar privilegio máximo en runtime o en toda migración futura | Rechazada | La capacidad privilegiada pertenece únicamente al despliegue puntual. |
| Separación física Phase 0/1/2 | Aceptada | Hace la frontera verificable, reduce alcance y permite probar rollback real. |

## Amenazas y mitigaciones

| Amenaza | Mitigación |
| --- | --- |
| Membership residual de owner | Postcondiciones directas de `pg_auth_members`; BOOT-02 y BOOT-03. |
| Un rol IQG recibe privilegios de un rol externo | Phase 0 y Phase 1 fallan cerrado; no revocan relaciones externas desconocidas. |
| App, gateway o invocador asumen owner | BOOT-04, BOOT-05 y BOOT-06 con logins QA reales. |
| GUC `iqg.*` falsificados | ADR-0001 y BOOT-07: GUC no es identidad ni habilita provisioning. |
| Fallo a mitad de instalación | BOOT-01 y BOOT-08 verifican rollback dentro de los límites transaccionales reales. |
| Carrera o drift entre bases durante Phase 0 | Locks de relación sobre `pg_authid`/`pg_auth_members`, prueba concurrente BOOT-02 y aserciones de catálogo; pendiente de evidencia runtime. |
| ACL/default ACL heredado en schema IQG | Phase 1 acepta sólo schemas vacíos sin ACL explícita y falla cerrado ante objetos, extensiones, publicaciones o default ACL aplicables. |
| Restore amplía ACL o memberships | BOOT-10 revisa topology global y objetos restaurados por separado. |
| Proveedor gestionado insuficiente | `DEPLOYMENT_CAPABILITY_INCOMPATIBLE`; no se reducen las postcondiciones. |

## Atomicidad, rollback y recuperación

Phase 0 y Phase 1 son transacciones independientes. PostgreSQL no ofrece una
transacción que abarque dos ejecuciones físicas de scripts. Por tanto no se
afirma una atomicidad falsa:

| Camino | Resultado esperado |
| --- | --- |
| Identidad insuficiente en Phase 0 | Falla cerrado sin roles IQG, schemas IQG ni membership insegura. |
| Identidad insuficiente en Phase 1 tras Phase 0 válida | Falla cerrado y revierte los schemas de esa base; la topología global segura permanece. |
| Error inyectado en Phase 0 | Rollback total de roles y topology creada en esa ejecución. |
| Error inyectado en Phase 1 | Rollback de schemas y objetos de esa base; Phase 0 puede permanecer como topology segura. |
| Recuperación Phase 1 | Se verifica Phase 0 y se reejecuta sólo Phase 1. |
| Éxito | Roles seguros, Core propiedad de `iqg_owner`, `ZERO MEMBERS` y runtime sin principal privilegiado. |

## Evidencia runtime obligatoria

| ID | Garantía mínima |
| --- | --- |
| BOOT-01 | Un `CREATEROLE` no superusuario debe fallar en Phase 0 sin roles/schemas IQG residuales; si Phase 1 falla después de Phase 0 válida, debe revertir sólo schemas/objetos de esa base y conservar la topología segura. |
| BOOT-02 | Dos Phase 0 concurrentes desde bases distintas deben serializarse y el principal privilegiado no debe conservar ninguna membership IQG. |
| BOOT-03 | `iqg_owner` debe terminar con cero miembros, incluso ante membresías accidentales preexistentes. |
| BOOT-04 | App no puede `SET ROLE iqg_owner`. |
| BOOT-05 | Gateway no puede `SET ROLE iqg_owner`. |
| BOOT-06 | Invocador de provisioning no puede `SET ROLE iqg_owner`. |
| BOOT-07 | GUC falsificado no eleva privilegio ni llama provisioning. |
| BOOT-08 | Fallos inyectados tras roles, memberships, DDL, ACL y verificaciones finales deben dejar solamente el estado seguro documentado. |
| BOOT-09 | Reejecución debe corregir atributos inseguros conocidos y rechazar memberships externas no revisadas, sin derivar roles, ACL, owner ni `FORCE RLS`. |
| BOOT-10 | Dump/restore no debe ampliar memberships, ACL, ownership, tipos ni RLS. |

`READY_FOR_DEEPSEEK_REAUDIT` sólo puede declararse con evidencia runtime de la
matriz A–W y BOOT-01 a BOOT-10.

## Proveedores gestionados

Un proveedor no necesita exponer un usuario llamado `postgres`, pero debe
permitir demostrar las capacidades requeridas por Phase 0/1 y sus
postcondiciones, incluidas las operaciones de catálogo y ownership que
PostgreSQL 16 reserva en muchos proveedores a una capacidad
superuser-equivalente. Si no permite crear la topología y preservar
`iqg_owner ZERO MEMBERS`, el resultado obligatorio es
`DEPLOYMENT_CAPABILITY_INCOMPATIBLE`.

No se permite rebajar seguridad para acomodar un proveedor: no se admite un
miembro residual de owner, cambiar una aserción por warning, ampliar permisos
de aplicación ni almacenar una credencial privilegiada en el repositorio.

## Lo que esta decisión no significa

- No vuelve superusuario a ningún rol IQG.
- No habilita `BYPASSRLS`, schemas abiertos a `PUBLIC`, grants amplios ni
  secretos en el repositorio.
- No autoriza uso del principal privilegiado en runtime, onboarding ni gateway.
- No reemplaza ADR-0001 ni convierte `iqg_bootstrap_invoker` en administrador
  de infraestructura.
- No declara IQG-001.2 listo para producción ni fija PostgreSQL como motor
  final.

## Referencias

- PostgreSQL 16: [Role Attributes](https://www.postgresql.org/docs/16/role-attributes.html)
- PostgreSQL 16: [GRANT](https://www.postgresql.org/docs/16/sql-grant.html)
- PostgreSQL 16: [Role Membership](https://www.postgresql.org/docs/16/role-membership.html)
- PostgreSQL 16: [Explicit Locking](https://www.postgresql.org/docs/16/explicit-locking.html)
- PostgreSQL 16: [`pg_locks`](https://www.postgresql.org/docs/16/view-pg-locks.html)
- PostgreSQL 16: [`pg_authid`](https://www.postgresql.org/docs/16/catalog-pg-authid.html)
- PostgreSQL 16: [`pg_auth_members`](https://www.postgresql.org/docs/16/catalog-pg-auth-members.html)
- ADR-0001 — Bootstrap y contrato mínimo de acceso SQL.
