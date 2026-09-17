# Arnés reproducible de PostgreSQL 16

Este directorio prueba los dos artefactos PostgreSQL 16 de referencia en una instancia efímera: `schemas/bootstrap_roles.sql` (Phase 0, topology global de roles) y `schemas/core_schema.sql` (Phase 1, instalación inicial del Core por base de datos). Phase 2 es el runtime normal y no reutiliza el principal de infraestructura. No se conecta a Firebase, GitHub, ningún entorno compartido ni datos de una empresa. Todos los UUID, sobres cifrados de forma sintáctica y nombres de prueba son sintéticos.

Ejecute desde la raíz del repositorio:

```powershell
pwsh -File tests/pg16/run.ps1
```

El corredor usa la imagen oficial fijada `docker.io/library/postgres:16.6-bookworm@sha256:557fea37a744d5f4c8faab304b0a90858b53ab119735a88c131fd19dab802f36`, crea un contenedor con nombre aleatorio y lo elimina aun cuando una aserción falla. Se puede usar `-KeepContainer` para inspección local. Si Docker o Podman no está disponible, el script falla antes de modificar el equipo o el repositorio.

Para elegir el runtime explícitamente:

```powershell
pwsh -NoProfile -File tests/pg16/run.ps1 -Engine docker
pwsh -NoProfile -File tests/pg16/run.ps1 -Engine podman
```

El mismo comando se ejecuta en `.github/workflows/pg16-harness.yml`. El runner no instala paquetes, no usa bases persistentes, no expone puertos del host, no conecta con Firebase/GitHub/datos compartidos y deja los logs temporales fuera del repositorio.

## Aislamiento del arnés

El `postgres` efímero del contenedor es una implementación de CI del concepto `PRIVILEGED_BOOTSTRAP_PRINCIPAL`; no es un requisito de nombre, proveedor o identidad de producción. Primero ejecuta Phase 0 y demuestra que `iqg_test_admin` (`CREATEROLE`, no superusuario) falla cerrado. Luego ejecuta Phase 1 únicamente con la capacidad de infraestructura efímera.

Esto no concede `SUPERUSER` a un rol IQG. `iqg_owner` termina `NOLOGIN`, `NOSUPERUSER`, `NOBYPASSRLS`, `NOINHERIT` y con cero miembros. `iqg_app`, `iqg_gateway` e `iqg_bootstrap_invoker` no reciben acceso directo de schema, tabla, secuencia o función fuera del contrato estrecho de provisioning.

Las identidades QA efímeras son `qa_bootstrap`, `qa_untrusted`, `qa_app_probe` y `qa_gateway_probe`. `qa_bootstrap` recibe una membership directa hacia `iqg_bootstrap_invoker` con `INHERIT TRUE`, `SET FALSE` y `ADMIN FALSE`. `qa_app_probe` y `qa_gateway_probe` reciben sus roles de grupo sólo para probar sesiones reales que no pueden asumir el owner ni leer tablas. `qa_untrusted` puede consultar exclusivamente la sonda de contexto. Ninguna de estas identidades recibe membership de `iqg_owner`.

Las pruebas negativas que tienen un contrato de error estable exigen dos señales: salida no cero y el par `SQLSTATE` más mensaje esperado. El helper no acepta una categoría amplia como `42501` o `P0001` por sí sola. Los mensajes nativos de PostgreSQL se usan sólo cuando son la causa contractual de la prueba; los invariantes propios usan el texto definido por el DDL.

Para construir la segunda sucursal sintética de cada tenant, el fixture usa una ventana acotada con `session_replication_role = replica` bajo el superusuario efímero de la base. Es una preparación de datos para cubrir la matriz 2 empresas por 2 sucursales: no valida ni simula una ruta de creación de sucursales, porque este ticket prohíbe construir una pasarela o endpoint de dominio nuevo. Todos los hechos que se validan después se insertan con RLS, `FORCE ROW LEVEL SECURITY`, triggers y auditoría activos.

## Matriz A–W

| ID | Prueba reproducible |
| --- | --- |
| A | instalación Phase 0/1 limpia y recuperación demostrada de Phase 1 |
| B | fallos inyectados de Phase 0 y Phase 1 dentro de sus límites transaccionales |
| C | roles, dueño no superusuario y ACL sin acceso directo para app/pasarela |
| D | `current_user`/`session_user` bajo `SECURITY DEFINER` |
| E | GUC de bootstrap legítimo, GUC malicioso y acceso SQL directo negado |
| F | `ENABLE` + `FORCE ROW LEVEL SECURITY` para todas las relaciones IQG |
| G | 2 empresas x 2 sucursales con datos sintéticos |
| H | aislamiento de lectura por empresa y sucursal |
| I | escrituras con alcance cruzado rechazadas |
| J | usuario inactivo bloquea membresía y acceso |
| K | empresa inactiva bloquea membresía y acceso |
| L | roles y permisos base idempotentes tras provisioning |
| M | validadores de códigos de dominio no bloquean un `UPDATE` sin cambio de código |
| N | validador de unidad de medida de líneas de operación |
| O | precio append-only, cadena de sucesor y carrera de sucesores |
| P | pago/reverso, bloqueo del padre y carrera contra sobre-reverso |
| Q | caja, movimiento y coherencia de moneda/unidad |
| R | auditoría operativa, sellado de fechas e inmutabilidad |
| S | anonimización de cliente, redacción de auditoría e idempotencia |
| T | snapshot fiscal, totales diferidos y outbox transaccional |
| U | bloqueo asesor corporativo durante emisión/configuración fiscal |
| V | detección de deadlock en objetos QA aislados |
| W | dump/restore y reejecución del DDL en una base nueva |

Los scripts de `sql/concurrency/` se ejecutan desde procesos `psql` distintos para que los bloqueos y las carreras no queden simulados dentro de una sola sesión.

## BOOT-01 a BOOT-10

| ID | Evidencia runtime |
| --- | --- |
| BOOT-01 | Un instalador `CREATEROLE` no superusuario debe fallar en Phase 0 sin roles/schemas IQG residuales; un fallo de Phase 1 tras Phase 0 válida debe revertir schemas/objetos de esa base y conservar la topología segura. |
| BOOT-02 | Dos Phase 0 desde bases distintas deben serializarse mediante locks de catálogos compartidos; el principal privilegiado no puede conservar ninguna membership IQG. |
| BOOT-03 | `iqg_owner` debe terminar con cero miembros y los cuatro roles IQG deben quedar endurecidos, incluso ante drift preexistente. |
| BOOT-04 | Una sesión login miembro de `iqg_app` no puede `SET ROLE iqg_owner` ni leer tablas directas. |
| BOOT-05 | Una sesión login miembro de `iqg_gateway` no puede `SET ROLE iqg_owner` ni leer tablas directas. |
| BOOT-06 | Una sesión de provisioning no puede `SET ROLE iqg_owner`. |
| BOOT-07 | GUC `iqg.*` falsificados no activan provisioning ni conceden `EXECUTE`. |
| BOOT-08 | Errores inyectados después de roles, memberships, ownership, DDL, ACL y verificaciones finales deben revertir el estado transaccional de Phase 0/1. |
| BOOT-09 | La reejecución de Phase 0 corrige atributos inseguros conocidos y rechaza memberships externas no revisadas; Phase 1 se instala sólo en una base nueva o con schemas verdaderamente vacíos. |
| BOOT-10 | Dump/restore conserva la topology global existente y la allowlist exacta de memberships QA, ACL, ownership, tipos y RLS de la base restaurada. |

`pg_dump`/`pg_restore` son operaciones por base de datos y no restauran roles globales. El arnés prueba por separado la topology de cluster mediante catálogo y la seguridad de los objetos restaurados. La salida `PG16_MATRIX=PASS` requiere que todas las letras A–W y estas pruebas de bootstrap hayan completado sus aserciones; no se declara por inspección estática ni antes de observar un run de PostgreSQL 16 real.
