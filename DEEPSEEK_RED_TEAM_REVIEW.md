DEEPSEEK_RED_TEAM_INITIAL.md
Resumen ejecutivo de riesgos
IQ GROWTH no es un producto: es una ambición de ERP/CRM/finanzas/RRHH/préstamos/IA multiempresa para tres negocios radicalmente distintos —restaurante/pizzería, agricultura/exportación y manufactura de chocolates—. Esa amplitud es el primer riesgo existencial. El proyecto puede fracasar por cinco causas principales:

Fuga o cruce de datos entre empresas. En un SaaS multiempresa, un fallo de aislamiento destruye la confianza y mata el negocio.

Agentes IA con permisos excesivos. Son un insider threat con esteroides: pueden leer, escribir, exfiltrar o borrar datos entre tenants.

Dependencia crítica de Firebase u otra nube. Sin capa de abstracción, migrar es reescribir; los costos por uso pueden crecer sin control.

Incumplimiento legal y de privacidad. RRHH, nómina, préstamos, socios, exportación y agricultura traen obligaciones regulatorias que no se resuelven con “lo hacemos después”.

Hipótesis de negocio no probadas. Asumir que un mismo núcleo sirve para pizzería, finca exportadora y fábrica de chocolates es una fantasía operativa. Sin verticalización, el producto será un monstruo que no encaja en ningún cliente.

La regla de oro se cumple: si algo parece malo, lo diré sin suavizarlo. IQ GROWTH, tal como está planteado, tiene más probabilidades de morir por sobredimensionamiento, deuda técnica y riesgos P0 que por falta de ideas.

Lista de hallazgos clasificados por gravedad
🔴 P0 — Crítico → puede destruir el proyecto
P0-01. Aislamiento multi-tenant no demostrado.
Categorías: seguridad, fuga/cruce de datos, arquitectura, escalabilidad externa.
Si IQ GROWTH será SaaS multiempresa para VANSAM, Café Zacarías, Chocolates La Florita y clientes externos, el aislamiento no puede ser “confiamos en Firebase”. Un error en reglas de seguridad, una consulta sin tenant_id, un índice compartido, una caché mal segmentada, un log con datos cruzados o un agente IA sin filtro puede exponer inventario, ventas, finanzas, RRHH o préstamos de otra empresa. En multi-tenant, esto no es un bug: es el fin del negocio. Si no hay pruebas automáticas de fuga entre tenants, no se debe vender a terceros.

P0-02. Autorización y permisos de agentes IA sin modelo de mínimo privilegio.
Categorías: IA, permisos excesivos, autenticación/autorización, seguridad.
Los “futuros agentes IA” aparecen en la estrategia sin un diseño de permisos. Si un agente hereda un token amplio, una service account o acceso a todos los tenants, puede exfiltrar datos, modificar inventario, aprobar préstamos o borrar registros. El prompt injection desde datos de clientes —correos, descripciones de productos, facturas— es un vector real. Un agente con escritura autónoma y permisos amplios es un P0, no una feature.

P0-03. Dependencia total de Firebase/cloud sin capa de abstracción.
Categorías: Firebase, vendor lock-in, arquitectura, costos ocultos.
Firebase es excelente para prototipos, pero es una trampa estratégica si se convierte en el núcleo. Reglas de seguridad, Auth, Firestore, Functions, Storage y Hosting tienen APIs propietarias. Migrar a otro cloud implica reescribir. Además, los costos por lecturas/escrituras/egress/functions pueden explotar con clientes externos. Sin presupuestos por tenant, alertas y plan de salida, el proveedor puede bloquear, encarecer o condicionar el proyecto.

P0-04. Cumplimiento legal y privacidad no resuelto.
Categorías: privacidad, cumplimiento, RRHH, finanzas, exportación.
La estrategia incluye datos de RRHH, nómina, préstamos, socios, exportación y agricultura. Eso toca protección de datos personales, retención, consentimiento, transferencia internacional, regulación laboral, financiera y fitosanitaria. No se menciona GDPR, leyes locales, AML/KYC, certificaciones de exportación ni auditoría fiscal. Si esto no se diseña antes, el producto puede ser ilegal en varios mercados.

P0-05. Pérdida o corrupción de datos por falta de transacciones, backups y DR.
Categorías: datos, integridad, producción, inventario, ventas.
Inventario, lotes, producción, ventas y finanzas requieren atomicidad. Si Firestore se usa sin transacciones multi-documento bien pensadas, dos usuarios o agentes pueden sobrescribir stock, duplicar ventas o corromper lotes. Sin backups probados, versionado, recuperación ante desastres y restauración granular, un incidente puede borrar meses de operación. Esto es P0 porque sin datos confiables no hay ERP.

🟠 P1 — Alto → bloquea o encarece gravemente
P1-01. Auditoría y trazabilidad insuficiente.
Categorías: auditoría, trazabilidad, cumplimiento, forense.
No basta con logs de aplicación. Se necesita registro inmutable de quién hizo qué, cuándo, desde qué tenant, con qué usuario o agente, con valores antes/después. Sin esto, no hay forense, no hay cumplimiento, no hay depuración multi-tenant y no se puede confiar en el sistema.

P1-02. Autenticación débil.
Categorías: autenticación, seguridad, sesiones.
Falta MFA, SSO empresarial, rotación de tokens, gestión de sesiones, revocación y API keys por tenant. Si un cliente externo exige SAML/OIDC, Firebase Auth puede no bastar. El account takeover en un SaaS financiero/ERP es catastrófico.

P1-03. Costos ocultos que crecen con el uso.
Categorías: costos, Firebase, escalabilidad.
Lecturas/escrituras de Firestore, almacenamiento, egress, invocaciones de Functions y tokens de IA escalan con cada cliente, cada pedido, cada lote y cada consulta. Sin cuotas por tenant, alertas y optimización, el margen puede desaparecer. Un cliente intensivo puede consumir más de lo que paga.

P1-04. Puntos únicos de fallo.
Categorías: arquitectura, SPOF, disponibilidad.
Una sola región, un solo proyecto Firebase, un solo administrador, una sola base de datos, un solo proveedor de IA, un solo servicio de pagos. Cualquier caída o error humano detiene todas las empresas a la vez. No hay redundancia real ni plan de continuidad.

P1-05. Escalabilidad con clientes externos.
Categorías: escalabilidad, multi-tenant, rendimiento.
Firebase tiene cuotas y límites. Con muchos tenants, el “ruido vecino” afecta a todos. Sin pruebas de carga multi-tenant, particionado, índices adecuados y límites por plan, el sistema se degradará justo cuando empiece a crecer.

P1-06. Sobreingeniería desde el día uno.
Categorías: sobreingeniería, estrategia, producto.
Quieren préstamos, socios, RRHH, finanzas, CRM, inteligencia de mercado, agentes IA y tres verticales. Eso no es un MVP, es un castillo de naipes. Construir todo antes de validar un solo flujo crítico es la forma más rápida de quemar recursos.

P1-07. Riesgos de integrar agentes IA.
Categorías: IA, seguridad, negocio.
Los agentes IA alucinan, no son deterministas, dependen de APIs externas y pueden ser manipulados. Si se usan para producción, inventario, ventas o finanzas sin supervisión humana, pueden tomar decisiones erróneas o destructivas. Además, el costo por token puede ser impredecible.

P1-08. Permisos excesivos a agentes IA.
Categorías: IA, permisos, autorización.
Un agente no debe tener más permisos que un usuario humano del mismo rol. Si puede leer todos los tenants, escribir en cualquier módulo o ejecutar acciones sin aprobación, es un riesgo P0 disfrazado de P1. Debe operar en sandbox, con permisos mínimos, auditoría y confirmación humana para escrituras.

P1-09. Modelo de dominio inadecuado para tres verticales.
Categorías: arquitectura, negocio, producto.
Restaurante, agricultura/exportación y manufactura de chocolates tienen entidades, unidades, ciclos, mermas, lotes, certificaciones y regulaciones distintas. Un solo modelo “inventario/ventas” será un monstruo. O se verticaliza por dominio, o el producto no servirá bien a ninguno.

P1-10. Dependencia de proveedores de IA, pagos, contabilidad y exportación.
Categorías: vendor lock-in, integraciones, negocio.
Cada integración externa añade bloqueo, costos y puntos de fallo. Si el proveedor cambia precios, API o términos, IQ GROWTH queda rehén.

P1-11. Falta de separación de entornos y gestión de secretos.
Categorías: seguridad, arquitectura, DevOps.
Dev/prod mezclados, claves en cliente, logs con datos sensibles, acceso humano sin control. Un error aquí puede filtrar datos o romper producción.

P1-12. Exportación/agricultura: trazabilidad, certificaciones y aduanas.
Categorías: cumplimiento, agricultura, exportación.
Café Zacarías exporta. Eso implica fitosanitario, origen, lotes, certificaciones, aduanas y documentación. Si el sistema no está diseñado para trazabilidad de exportación, no sirve para ese negocio.

P1-13. RRHH/nómina: datos sensibles y leyes laborales.
Categorías: RRHH, privacidad, cumplimiento.
Nómina, contratos, desempeño y datos personales requieren cifrado, retención y cumplimiento laboral. No es un módulo CRUD más.

P1-14. Préstamos/socios: regulación financiera.
Categorías: finanzas, cumplimiento, negocio.
Préstamos y socios tocan AML/KYC, usura, conflictos de interés, reportes regulatorios y riesgo crediticio. Si no hay asesoría legal, es una bomba.

P1-15. Hipótesis de negocio débiles o no probadas.
Categorías: negocio, estrategia.
No está probado que los clientes paguen por un SaaS unificado, ni que IQHOLDING pueda vender a terceros, ni que los módulos tengan product-market fit. Tampoco está claro si el objetivo es digitalizar las empresas propias o vender software. Esas son dos estrategias distintas.

🟡 P2 — Medio → problema serio pero manejable
P2-01. Deuda técnica por Firebase.
Si se usa Firebase como base, se acumulará deuda en reglas, funciones y modelos. Manejable si se encapsula desde el inicio.

P2-02. Observabilidad insuficiente.
Sin métricas, trazas y alertas por tenant, no se detectan fugas, cuellos de botella ni costos anómalos.

P2-03. Sin plan de respuesta a incidentes.
No hay procedimiento para brechas, caídas, corrupción de datos o abuso de agentes IA.

P2-04. Integraciones contables/fiscales.
Cada país y régimen fiscal requiere formatos, impuestos y reportes. No es plug-and-play.

P2-05. CRM: consentimiento, duplicados y marketing.
Datos de clientes, consentimiento, campañas y privacidad. Manejable con diseño.

P2-06. Backups no cifrados o no probados.
Un backup que no se restaura no es backup. Debe cifrarse y probarse periódicamente.

P2-07. Gestión de identidades externas.
Clientes, proveedores y socios pueden necesitar acceso limitado. Sin roles externos, se abren puertas.

P2-08. SSO empresarial no previsto.
Los clientes externos grandes exigirán SAML/OIDC. Firebase Auth puede quedarse corto.

P2-09. Localización, monedas e idiomas.
VANSAM, Café Zacarías y La Florita pueden operar en monedas, impuestos e idiomas distintos. No es solo traducir botones.

P2-10. Agentes IA: costos variables, latencia y no determinismo.
Pueden ser útiles, pero su comportamiento no es reproducible. Requieren evaluación constante.

P2-11. Inteligencia de Mercado: licencias, scraping y propiedad intelectual.
Si se alimenta de scraping o datos de terceros, hay riesgo legal y de calidad.

P2-12. Offline/conectividad en finca y restaurante.
Café Zacarías y VANSAM pueden tener conectividad intermitente. Sin modo offline, la operación se detiene.

🔵 P3 — Bajo → mejora o advertencia menor
P3-01. UX inconsistente.
Módulos construidos por separado tenderán a experiencias distintas.

P3-02. Documentación insuficiente.
Sin documentación de arquitectura, permisos y flujos, el equipo se vuelve dependiente de personas.

P3-03. Capacitación.
Usuarios de restaurante, finca y fábrica necesitan capacitación distinta. No es solo software.

P3-04. Naming y branding.
“IQ GROWTH” puede ser ambiguo. No es crítico, pero afecta adopción.

Lo que NO deberíamos construir todavía
Agentes IA autónomos con escritura. Ni en producción, ni en finanzas, ni en inventario. Primero permisos, auditoría y sandbox.

Módulo de préstamos y socios. Sin asesoría legal y regulación financiera, es un pasivo.

Inteligencia de Mercado con scraping. Hasta resolver licencias, calidad y privacidad.

Multi-tenant SaaS para clientes externos. Hasta demostrar aislamiento con pruebas de fuga.

App móvil offline completa. Primero definir el flujo crítico de un solo vertical.

Nómina/HR completo. Es un producto en sí mismo, con regulación laboral.

Exportación para Café Zacarías. Si no hay trazabilidad, certificaciones y aduanas, no está listo.

Contabilidad financiera completa. Integrar con contadores primero; no reemplazarlos.

Analítica cross-tenant. Es un riesgo de privacidad y fuga de datos.

Microservicios, event sourcing, CQRS o blockchain. Sobreingeniería pura para esta etapa.

Lo que debemos cambiar ANTES de empezar
Definir aislamiento multi-tenant como requisito P0. Con pruebas automáticas de fuga entre tenants, no solo buenas intenciones.

Modelo de autorización RBAC/ABAC con tenant_id en cada recurso. Verificación server-side, no en cliente. Permisos por módulo, acción y dato.

Auditoría inmutable append-only. Registrar actor, tenant, agente, IP, timestamp, valores antes/después, y motivo.

Capa de abstracción sobre Firebase. Repositorios, autenticación e integraciones desacopladas para no quedar bloqueados.

Presupuestos y cuotas por tenant. Alertas de costo, límites de uso y métricas de consumo.

Backups, DR y pruebas de restauración. Cifrado, versionado y recuperación granular.

Sandbox de agentes IA con permisos mínimos. Aprobación humana para escrituras. Auditoría total. Sin acceso cross-tenant.

Evaluación legal/privacidad por país y tipo de dato. RRHH, finanzas, exportación, agricultura y préstamos.

MVP vertical: elegir UN negocio y UN flujo crítico. Por ejemplo, inventario y ventas de Chocolates La Florita, o pedidos de VANSAM. No los tres a la vez.

Arquitectura modular por dominio, no monolito de módulos. Separar restaurante, agricultura, manufactura y finanzas con contratos claros.

Pruebas de carga multi-tenant y caos. Antes de vender a terceros.

Plan de salida de proveedor. Documentar cómo migrar datos, auth y lógica a otra nube.

Nivel de confianza
Confianza en este informe: 88%.
Los riesgos señalados son estructurales y aparecen en casi cualquier SaaS multiempresa que intenta abarcar demasiado con Firebase y agentes IA sin modelo de permisos.

Confianza en que IQ GROWTH funcione tal como está planteado: 10-15%.
No porque la idea sea mala, sino porque la ejecución propuesta es demasiado amplia, dependiente y regulada. Si no se reduce el alcance, se corrige el aislamiento multi-tenant y se diseña la seguridad/auditoría antes de construir, la probabilidad de fracaso técnico o empresarial es muy alta.

Veredicto: No construyan todo. Elijan un vertical, un flujo, un tenant. Diseñen aislamiento, permisos, auditoría y costos desde el día cero. Si no, IQ GROWTH se ahogará en su propia ambición.