# Arnés reproducible de PostgreSQL 16

Este directorio prueba el DDL de referencia de `schemas/core_schema.sql` en una instancia efímera de PostgreSQL 16. No se conecta a Firebase, GitHub, ningún entorno compartido ni datos de una empresa. Todos los UUID, sobres cifrados de forma sintáctica y nombres de prueba son sintéticos.

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

El DDL se instala como `iqg_test_admin` dentro de una base efímera. Las únicas identidades adicionales son `qa_bootstrap` y `qa_untrusted`. Son roles de prueba efímeros, no reciben membresía de `iqg_owner`, y se eliminan junto con el clúster. `iqg_app` e `iqg_gateway` nunca reciben `USAGE`, privilegios de tabla, secuencia ni `EXECUTE` en estas pruebas.

La única excepción controlada es la membresía directa de `qa_bootstrap` en `iqg_bootstrap_invoker`, con `INHERIT TRUE`, `SET FALSE` y `ADMIN FALSE`. El `EXECUTE` de `provisionar_empresa()` se hereda exclusivamente del grant final del DDL; no se agrega ningún grant QA de endpoint. Ambos roles QA reciben solamente la lectura de sonda de `contexto_bootstrap_activo()`. Esto permite demostrar, en una sesión de conexión real, que los GUC `iqg.*` son falsificables pero no bastan sin la capacidad de bootstrap. No se concede nada a los roles de aplicación o pasarela del esquema.

Para construir la segunda sucursal sintética de cada tenant, el fixture usa una ventana acotada con `session_replication_role = replica` bajo el superusuario efímero de la base. Es una preparación de datos para cubrir la matriz 2 empresas por 2 sucursales: no valida ni simula una ruta de creación de sucursales, porque este ticket prohíbe construir una pasarela o endpoint de dominio nuevo. Todos los hechos que se validan después se insertan con RLS, `FORCE ROW LEVEL SECURITY`, triggers y auditoría activos.

## Matriz A–W

| ID | Prueba reproducible |
| --- | --- |
| A | instalación limpia del DDL PostgreSQL 16 |
| B | fallo inyectado antes de `COMMIT` y rollback sin esquemas residuales |
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
