Informe de auditoría — IQG-001.1
Rol: DeepSeek — Red Team & Independent Auditor
Fecha: 2026-09-10
Artefacto auditado: schemas/core_schema.sql (PostgreSQL 16)
Documentos canónicos leídos: MASTER_CONTEXT.md, ARCHITECTURE.md, informe Codex 2026-09-10_1312_codex.md
Alcance: revisión estática de seguridad, aislamiento, inmutabilidad, vigencia, integridad
Tipo de evidencia: análisis estático de DDL. No se ejecutó contra PostgreSQL 16.

1. Resumen ejecutivo
El esquema es notablemente maduro para un primer diseño. Implementa los 5 principios inviolables con mecanismos concretos, no con buenas intenciones:

Aislamiento: RLS ENABLE + FORCE en 23 tablas, FKs compuestas (company_id, branch_id, X_id), índices que empiezan por company_id, branch_id, políticas que fallan cerradas sin contexto.

Inmutabilidad: triggers BEFORE INSERT/UPDATE que sellan fecha_creacion desde clock_timestamp(), bloquean cambio de PK/company/branch/creador, append-only real en hechos y auditoría, TRUNCATE bloqueado por trigger de statement.

Vigencia: precio_vigente es un libro append-only con valid_from, valid_to, reemplaza_precio_vigente_id, unicidad de raíz/sucesor y validación de cadena.

Seguridad: REVOKE ALL FROM PUBLIC, SECURITY DEFINER con search_path fijo, validadores que consultan hechos sin conceder SELECT amplio, sin CASCADE.

Integridad: FKs compuestas en todas las relaciones de negocio, CHECK de dominio, idempotencia por (origen_idempotencia, clave_idempotencia), auditoría DML con datos_antes/datos_despues en JSONB.

Pero no está listo para producción. Hay riesgos P0 que dependen de IQG-001.2 (fijación confiable de contexto, rol de aplicación sin privilegios SQL directos) y contradicciones con obligaciones legales (GDPR, derecho al olvido) que el esquema actual hace imposibles de cumplir porque bloquea DELETE en todo, incluida cliente y registro_cambios.

Veredicto: APROBADO CON CONDICIONES. El esquema puede convertirse en migración controlada cuando se cierren los P0 y P1 de este informe. No antes.

2. Cumplimiento de los 5 principios
Principio	Estado	Evidencia
Aislamiento (company_id + branch_id en toda tabla)	✅ Cumple, con reservas	23/23 tablas con ambos campos. RLS forzado. FKs compuestas. Reserva: políticas especiales de empresa y usuario permiten lectura cross-branch con contexto_branch_id() IS NOT NULL, no con pertenencia real a la company. Ver H-04.
Inmutabilidad (fechas de servidor, no borrar ni sobrescribir)	✅ Cumple	tg_sellar_registro sella fecha, bloquea PK/company/branch/creador. tg_bloquear_delete en 13 tablas, tg_bloquear_mutacion_append_only en 10. tg_bloquear_truncate en 23. Sin ON DELETE CASCADE.
Vigencia (precios nunca se editan)	✅ Cumple	precio_vigente append-only. uq_precio_raiz_elemento_moneda parcial, uq_precio_unico_sucesor, trigger tg_validar_precio_vigente con FOR KEY SHARE. Vistas security_invoker.
Seguridad (sin fugas, sin comandos peligrosos)	⚠️ Cumple con reservas	REVOKE ALL FROM PUBLIC, search_path fijo, SECURITY DEFINER acotado. Riesgo: GUCs iqg.* son spoofables por cualquier rol con SQL (P0 condicional). Sin DROP, TRUNCATE, ALTER SYSTEM, COPY PROGRAM, dblink, lo_import.
Integridad (FKs, restricciones, auditoría)	✅ Cumple, con huecos	FKs compuestas en todas las relaciones. CHECK de dominio y consistencia aritmética. Auditoría DML completa. Huecos: sin tablas maestras para códigos (tipo_movimiento, medio_pago, unidad_medida, tipo_elemento), sin unicidad de identificador_fiscal, sin consistencia activo entre jerarquías.
3. Hallazgos clasificados por gravedad
🔴 P0 — Crítico
H-01. Contexto RLS spoofable por cualquier rol con SQL directo.
contexto_company_id(), contexto_branch_id(), contexto_usuario_id() leen GUCs iqg.*. PostgreSQL permite SET sobre cualquier GUC con prefijo (cualquier nombre con punto) sin privilegio especial. Cualquier rol al que IQG-001.2 conceda INSERT/SELECT sobre iqg_core.* y que pueda ejecutar SET iqg.company_id = '...' suplanta el aislamiento completo. El esquema no restringe pg_parameter_acl ni impone que la aplicación no tenga SQL directo. Es el riesgo más grave del diseño. Mitigación obligatoria: IQG-001.2 debe conceder DML solo a un rol intermedio (funciones de dominio SECURITY DEFINER) y nunca SET/INSERT/UPDATE directo al cliente. Sin esto, el aislamiento es decorativo.

H-02. Imposibilidad de cumplir derecho al olvido / GDPR.
DELETE está bloqueado en las 23 tablas (tg_bloquear_delete o tg_bloquear_mutacion_append_only). cliente contiene nombre_mostrar, correo_electronico, telefono. registro_cambios conserva esos valores en datos_antes/datos_despues JSONB de forma inmutable y para siempre. Si un titular ejerce derecho de supresión, el sistema no puede cumplir. Tampoco hay ruta de anonimización. Esto no es opinable: es un incumplimiento legal en cualquier jurisdicción con GDPR o leyes equivalentes.

H-03. Funciones SECURITY DEFINER sin garantía de owner no-superusuario.
tg_sellar_registro, tg_validar_*, tg_registrar_cambio, provisionar_empresa son SECURITY DEFINER. Si el DDL se ejecuta como superusuario (lo habitual en migraciones), el owner es superusuario y FORCE ROW LEVEL SECURITY no lo detiene: los superusuarios bypassean RLS incluso con FORCE. El esquema no crea un rol owner separado ni verifica que no sea superusuario. Mitigación: documentar y forzar que el owner sea un rol dedicado iqg_owner sin SUPERUSER ni BYPASSRLS.

H-04. Políticas RLS débiles en empresa y usuario.
Ambas usan USING (company_id = contexto_company_id() AND contexto_branch_id() IS NOT NULL). No verifican que el branch_id del contexto pertenezca a la company del contexto. Con iqg.company_id = X e iqg.branch_id = <branch de Y>, se leen filas de empresa/usuario de X. En un diseño donde el contexto lo fija middleware confiable el riesgo se atenúa, pero es exactamente el tipo de suposición que un atacante con acceso a SQL puede romper. Defensa en profundidad: la política debe validar membresía real (EXISTS sobre usuario_sucursal con activo = true).

🟠 P1 — Alto
H-05. Roles y permisos fragmentados por sucursal.
rol.codigo es único por (company_id, branch_id, codigo). permiso.recurso_codigo + accion_codigo es único por (company_id, branch_id, ...). Una empresa con N sucursales debe duplicar N veces cada rol y cada permiso. En IQ GROWTH, con VANSAM + Café Zacarías + La Florita y potenciales clientes multi-sucursal, esto es una bomba administrativa y una fuente de inconsistencia (un rol cambia en sucursal A pero no en B). El modelo correcto es rol/permiso a nivel company con asignación a branch.

H-06. Sin tablas maestras para códigos de dominio.
tipo_movimiento_codigo, medio_pago_codigo, tipo_codigo (elemento), unidad_medida_codigo, entidad_codigo (estado), tipo_operacion_codigo son varchar libres. No hay FK, no hay CHECK de valores válidos, no hay auditoría de cambios en el catálogo de códigos. Un cliente puede insertar tipo_movimiento_codigo = 'lo_que_sea' y el esquema lo acepta. Esto rompe la promesa de "datos confiables para decidir" del MASTER_CONTEXT.md.

H-07. unidad_medida_codigo en línea/movimiento no valida contra la unidad base del elemento.
elemento.unidad_medida_codigo existe, pero operacion_linea.unidad_medida_codigo y movimiento.unidad_medida_codigo son libres y no se comparan con la del elemento. Se puede vender 1 kg de un elemento cuya unidad base son piezas. Esto rompe la integridad de inventario y valoración.

H-08. Sin particionamiento ni archivado para tablas de crecimiento ilimitado.
registro_cambios, movimiento, movimiento_caja, operacion_linea, operacion, pago crecen monotónicamente. No hay particionamiento por rango temporal, no hay política de retención, no hay archivado. Para un SaaS multiempresa con clientes externos, esto es un P1 de escalabilidad y costo.

H-09. provisionar_empresa no crea roles ni permisos iniciales.
Crea empresa, sucursal, usuario y membresía, pero ningún rol ni permiso. El usuario inicial no puede hacer nada. El onboarding debe crear roles base por vertical/plantilla. Sin esto, cada alta de tenant requiere intervención manual privilegiada.

H-10. provisionar_empresa no es idempotente.
Cada reintento crea una empresa nueva. usuario.usuario_id es PK, así que un reintento con el mismo p_usuario_id falla y deja la transacción abortada, pero si el caller genera nuevo usuario_id, se crea un tenant duplicado. Sin clave de idempotencia global. Codex ya lo marcó; lo confirmo como P1.

H-11. Sin consistencia de estado activo en jerarquías.
empresa.activo = false no desactiva sucursal, usuario, usuario_sucursal, rol, usuario_rol. usuario.activo = false no desactiva sus membresías ni sus roles. No hay triggers ni CHECK que impongan coherencia. Un usuario "inactivo" puede seguir autenticándose si el middleware solo mira usuario_sucursal.activo.

H-12. identificador_fiscal sin unicidad.
Dos empresas pueden declarar el mismo NIF/RUC. Riesgo de duplicación de tenants y de reportes fiscales cruzados.

H-13. referencia_externa sin unicidad en operacion y pago.
Si el origen externo (V11, pasarela de pago) envía la misma referencia, se puede duplicar. La idempotencia por (origen_idempotencia, clave_idempotencia) solo protege si el cliente respeta el contrato. Una UNIQUE (company_id, branch_id, referencia_externa) parcial sería más robusta.

🟡 P2 — Medio
H-14. usuario.correo_electronico sin unicidad por company.
Dos usuarios pueden compartir correo. Para login y notificaciones, esto es un problema. Debería ser UNIQUE (company_id, correo_electronico) WHERE correo_electronico IS NOT NULL.

H-15. cliente.correo_electronico y telefono sin normalización ni validación.
Solo text. Sin CHECK de formato. Para CRM y campañas, la calidad de datos se degrada.

H-16. zona_horaria es text libre.
No valida contra pg_timezone_names. Una zona inválida rompe cálculos de fecha/hora aguas abajo.

H-17. moneda_codigo con regex ^[A-Z]{3}$ sin catálogo.
Acepta XXX, ZZZ, cualquier ISO inexistente. Debería haber moneda como tabla maestra con FK.

H-18. Sin tabla de migración ni versionado de esquema.
No hay schema_version ni historial de migraciones. Para un producto SaaS con clientes externos, esto es indispensable antes de la primera migración.

H-19. fecha_creacion con clock_timestamp() no es monotónica intra-transacción.
Dos inserciones en la misma transacción pueden tener timestamps en orden invertido si el reloj retrocede. Para ordenar eventos, usar txid_current() + numero_linea o un bigserial adicional. Afecta la auditabilidad fina.

H-20. v_precio_actual no considera la sucursal de origen del elemento.
El precio se define por (company_id, branch_id, elemento_id). Pero un elemento puede existir en varias sucursales. v_precio_actual devuelve todos los precios vigentes del alcance RLS. No hay resolución de "precio efectivo para este elemento en esta sucursal". Diseño incompleto para multi-sucursal.

H-21. Snapshot de costo en operacion_linea sin garantía de que coincida con movimiento.
costo_total_menor es un snapshot. El libro de movimiento es la fuente de verdad. Si un re-cálculo posterior cambia el costo, el snapshot queda desactualizado y verificable solo manualmente. El comentario lo reconoce, pero no hay trigger que valide la coherencia al insertar la línea vs. los movimientos generados.

H-22. movimiento permite costos nulos pero no hay estado "pendiente de costeo".
ck_movimiento_costos permite (moneda_codigo IS NULL, costo_unitario NULL, costo_total NULL) o los tres juntos. No hay un flag costeo_pendiente. Un movimiento sin costo puede quedar así para siempre sin que nada lo señale.

H-23. Sin ON DELETE SET NULL ni ON DELETE RESTRICT explícito en todas las FKs.
La mayoría usa ON DELETE RESTRICT implícito (default). Correcto, pero inconsistente en legibilidad. Menor.

H-24. Sin control de concurrencia optimista en tablas actualizables.
empresa, sucursal, usuario, rol, permiso, elemento, canal, campania, cliente, estado, caja permiten UPDATE. No hay columna version ni updated_at con CHECK de versión. Dos administradores pueden pisarse sin detección.

🔵 P3 — Bajo
H-25. txid_current() deprecado en PG 13+.
Usar pg_current_xact_id() o pg_current_xact_id_if_assigned().

H-26. empresa.branch_id con DEFAULT gen_random_uuid().
El default es inútil porque la FK a sucursal falla en commit si no se inserta la sucursal correspondiente. Ruido.

H-27. Bloques DO $$ con CREATE TRIGGER/CREATE POLICY no idempotentes.
Re-ejecutar el script falla. Aceptable para migración controlada, pero conviene DROP ... IF EXISTS o IF NOT EXISTS donde exista.

H-28. CREATE TABLE sin IF NOT EXISTS.
Mismo punto.

H-29. Sin COMMENT ON en la mayoría de tablas y columnas.
Solo 4 comentarios. Para un núcleo universal que debe entender un equipo distribuido, es insuficiente.

H-30. Sin índices en cliente.correo_electronico ni cliente.telefono.
Búsquedas de CRM escanearán.

H-31. Sin índice en registro_cambios.correlation_id ni transaccion_id.
Consultas forenses por correlación o transacción serán costosas.

H-32. contexto_actor_tipo() default 'SISTEMA' cuando no hay GUC.
Puede enmascarar inserciones no atribuidas. Debería fallar cerrado o registrar 'DESCONOCIDO'.

H-33. provisionar_empresa no fija iqg.correlation_id ni iqg.direccion_ip.
Aceptable para bootstrap, pero la auditoría del alta queda sin trazabilidad de origen.

H-34. Sin CREATE EXTENSION IF NOT EXISTS pgcrypto.
En PG 16 gen_random_uuid() es built-in, pero si se necesita crypt() para algo, no está declarado.

H-35. Sin política de retención ni cifrado en reposo declarado.
Fuera del alcance del DDL, pero debe estar en el ADR del motor.

4. Contradicciones y huecos señalados
MASTER_CONTEXT.md promete "datos confiables para decidir". Pero el esquema acepta códigos de dominio libres (H-06), unidades de medida inconsistentes (H-07), y no resuelve precio efectivo multi-sucursal (H-20). La confiabilidad de los datos no está garantizada por el esquema, solo la inmutabilidad de lo que se inserte.

ARCHITECTURE.md promete "el núcleo NO conoce pizza, café ni chocolate". Correcto. Pero también promete "cualquier empresa". Con roles/permisos por sucursal (H-05) y sin tablas maestras (H-06), cualquier empresa con más de una sucursal sufre fricción administrativa severa.

Codex marca P0 "contexto RLS" y P1 "autorización pendiente". Coincido, pero subestima H-02 (derecho al olvido) y H-03 (owner superusuario). H-02 es P0 legal, no P2 de PII.

provisionar_empresa se declara "única ruta de bootstrap". Pero no crea roles ni permisos (H-09), no es idempotente (H-10) y depende de un owner no-superusuario que el esquema no garantiza (H-03). La ruta de bootstrap no está cerrada.

registro_cambios se declara "auditoría forense". Pero no audita DDL, no audita cambios de permisos, no audita accesos de lectura, y está sujeto a RLS estricto (un auditor de company no ve cross-branch). Es auditoría DML, no forense completa.

5. Lo que NO deberíamos construir todavía
Nada que dependa de SET iqg.* desde el cliente. Hasta que IQG-001.2 defina el rol intermedio.

Nada que requiera DELETE de PII. Hasta resolver H-02 con anonimización.

Agentes IA con acceso SQL directo al esquema. El GUC spoofing (H-01) los convierte en un vector de fuga cross-tenant.

Verticales (VANSAM, Café, Chocolate) sobre este núcleo. Primero cerrar H-05, H-06, H-07.

Clientes externos multi-sucursal. H-05 los hará inviables administrativamente.

Reportes fiscales o contables. Sin unicidad de identificador_fiscal (H-12), los cruces son frágiles.

Archivado o purga de auditoría. No hay política; implementarla antes de tener volumen.

6. Lo que debemos cambiar ANTES de convertir en migración
Definir el modelo de confianza de contexto. Rol de aplicación sin SET/DML directo; funciones de dominio SECURITY DEFINER que fijan iqg.* desde una sesión autenticada. Documentar pg_parameter_acl o equivalente.

Crear rol owner iqg_owner sin SUPERUSER ni BYPASSRLS. Ejecutar el DDL con ese rol. Verificar con SELECT rolsuper, rolbypassrls FROM pg_roles.

Añadir ruta de anonimización de PII. Tabla anonimizacion_solicitud y función anonimizar_cliente(cliente_id) que reemplace PII en cliente y en registro_cambios (o marque los JSONB como redactados). Sin esto, no hay GDPR.

Reescribir RLS de empresa y usuario con EXISTS (SELECT 1 FROM usuario_sucursal WHERE ... AND activo = true) en el USING. No confiar en IS NOT NULL.

Mover roles y permisos a nivel company. rol y permiso sin branch_id; usuario_rol con branch_id para la asignación concreta.

Crear tablas maestras para moneda, unidad_medida, tipo_elemento, tipo_operacion, tipo_movimiento, medio_pago, tipo_movimiento_caja, entidad_estado. FKs desde las tablas que hoy usan varchar.

Validar unidad_medida_codigo contra elemento.unidad_medida_codigo en operacion_linea y movimiento (o modelar conversiones explícitas).

Unicidad parcial en identificador_fiscal y en referencia_externa de operacion/pago.

provisionar_empresa idempotente y completa. Clave de idempotencia de tenant, creación de roles base, permisos base, y asignación al usuario inicial.

Consistencia de activo vía triggers o CHECK cruzados.

Particionamiento por rango temporal en registro_cambios, movimiento, movimiento_caja, operacion_linea, pago, operacion. Política de retención.

Tabla schema_version y pipeline de migraciones.

Reemplazar txid_current() por pg_current_xact_id().

Añadir version o updated_at con control optimista en tablas actualizables.

Batería de pruebas ejecutadas en PostgreSQL 16 efímero antes de migrar: bootstrap, dos companies, dos branches, intento de fuga RLS, GUC spoofing, precio sucesor concurrente, reversos parciales, UPDATE/DELETE/TRUNCATE bloqueados, SECURITY DEFINER con owner no-superusuario.

7. Veredicto final
APROBADO CON CONDICIONES.

El esquema es un buen punto de partida, no un producto terminado. Implementa los 5 principios con rigor poco común. Pero:

No es seguro en producción hasta cerrar H-01, H-02, H-03, H-04.

No es escalable administrativamente hasta cerrar H-05, H-06, H-07.

No es legalmente desplegable hasta cerrar H-02.

No es operable como SaaS hasta cerrar H-08, H-09, H-10, H-18.

La aprobación es del diseño, no de la implementación lista para migración. La siguiente acción no es "migrar": es IQG-001.2 con los 15 cambios de la sección 6 como alcance mínimo.

Nivel de confianza en este informe: 90%.
Nivel de confianza en que el esquema actual, sin cambios, sea seguro en producción: 5%.

Nota operativa: no puedo ejecutar git commit ni crear archivos en el repositorio desde esta conversación. El contenido de este informe es el que debe subirse a ai-council/IQG-001/reports/2026-09-10_auditoria_deepseek.md con el mensaje "IQG-001.1: Informe auditoría seguridad e integridad — DeepSeek". Si quieres, puedo reformatearlo como diff o como bloque listo para pegar en el archivo.
