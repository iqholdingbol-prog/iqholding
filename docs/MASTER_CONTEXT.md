# MASTER_CONTEXT.md
## IQ GROWTH — Contexto Constitucional
### Versión: 1.2 · Fecha: 2026-09-12 · Autoridad: Iván Quea, CEO

---

## 1. VISIÓN
IQ GROWTH es un Sistema Operativo de Crecimiento Empresarial, no simplemente un POS ni un ERP. Su propósito no es registrar operaciones, sino ayudar a cualquier empresa a entender, organizar, decidir y ejecutar acciones que generen crecimiento medible y rentable. Se prueba en laboratorios reales y se diseña para prestar servicio a cualquier rubro, tamaño y nivel de formalización.

La ambición no es obligar al negocio a adaptarse al software. **IQ GROWTH se configura alrededor de la realidad del negocio, la organiza, la mide y encuentra medios para mejorarla y vender más de forma rentable.**

## 2. PROBLEMA QUE RESUELVE
Las empresas administran pero frecuentemente NO saben:
- ¿De dónde vienen realmente mis clientes?
- ¿Qué producto/servicio me genera más contribución?
- ¿Dónde se pierde dinero, tiempo, calidad o continuidad?
- ¿Qué acción debo tomar ahora para crecer?
- ¿Funcionó realmente esa acción?
- ¿Qué parte de mi operación depende de una sola persona?
- ¿Cómo cambia el negocio entre canales, ciudades, sucursales o rutas?

IQ GROWTH responde con datos confiables, trazabilidad y decisiones accionables.

## 3. LOS 5 PRINCIPIOS INVIOLABLES
1. **UNIVERSALIDAD** — El núcleo nunca será exclusivo de un rubro. VANSAM, Café Don Zacarías y Chocolates La Florita son laboratorios de validación. El producto se diseña para cualquier empresa.
2. **AISLAMIENTO TOTAL** — Todo registro lleva company_id + branch_id + usuario + fecha_servidor. Ningún dato se mezcla entre empresas.
3. **HISTORIA SAGRADA** — El pasado no se sobrescribe. Todo cambio conserva trazabilidad. Fecha oficial del servidor como verdad temporal del sistema; las correcciones crean nuevos eventos.
4. **ARQUITECTURA EVOLUTIVA** — Núcleo universal separado de capacidades, configuración y verticales específicas. No construir funciones futuras innecesarias hoy ni contaminar el Core con lógica de un rubro.
5. **VALOR ANTES QUE FUNCIONES** — La cadena de crecimiento:
   DATOS → MEDICIÓN → DIAGNÓSTICO → DECISIÓN → ACCIÓN → RESULTADO → APRENDIZAJE → CRECIMIENTO

## 4. LABORATORIOS DE VALIDACIÓN
- **#1 VANSAM / IQG-002** — venta directa, servicio gastronómico, pedidos, cocina, caja, CRM, personal, continuidad y operación remota.
- **#2 Café Don Zacarías / IQG-003** — inversión agrícola, finca, parcelas, campañas, mano de obra agrícola, cosecha, beneficio, secado, coproductos, lotes, calidad, logística Yungas→El Alto, planta, exportación, transformación y comercialización fija/móvil.
- **#3 Chocolates La Florita / IQG-004** — procurement de cacao/insumos, formulaciones, lotes, manufactura, variedad de modelos/formas/pesos, empaque, mayorista/minorista y distribución fija/móvil.

Los tres laboratorios deben validar el mismo Core, no crear tres sistemas independientes.

## 5. CLIENTE FUTURO
Cualquier empresa u organización económica que venda productos o servicios y desee crecer con evidencia confiable: microempresa, PYME, empresa mediana o grande; formal, parcialmente formal, informal registrada o en transición; retail, servicio, agricultura, manufactura, distribución, proyectos o combinaciones.

Después de los laboratorios internos, IQ GROWTH debe probar universalidad con negocios externos de rubros distintos para evitar diseñar solo alrededor de IQHOLDING.

## 6. MODELO DE NEGOCIO
- Suscripción/planes escalables según valor y capacidades usadas; pricing definitivo no canonizado todavía.
- Demostrar valor mediante resultados/decisiones útiles antes de proclamar validación comercial.
- Cada cliente ve solo sus datos → aislamiento total = condición de confianza.

## 7. ARQUITECTURA CONCEPTUAL

```text
CORE UNIVERSAL
    ↓
CAPACIDADES REUTILIZABLES
    ↓
ADAPTADOR VERTICAL
    ↓
CONFIGURACIÓN DE EMPRESA
```

### CORE UNIVERSAL
- Identidad, Empresa, Sucursal/Unidad Operativa, Usuarios, Roles y Relaciones.
- Calendarios/ciclos operativos configurables.
- Catálogo genérico, familias, variantes, presentaciones y precios vigentes.
- Unidades de medida y conversiones verificadas.
- Cliente, Canal, Campaña, Vendedor/Ruta.
- Compra/recepción/proveedor.
- Operación, Venta, Pago, Caja separados.
- Movimientos e Inventario.
- Transformación genérica INPUT→PROCESS→OUTPUT.
- Lotes/series/calidad cuando se activen.
- Activos/recursos/equipos/vehículos y su propiedad/uso separados.
- Fuerza laboral/contratistas y responsabilidades.
- Incidencias.
- Compliance Layer versionado.
- Auditoría inmutable + trazabilidad temporal.
- Growth Engine.

### VERTICALES
- VANSAM → semántica gastronómica/POS/KDS/mesa/llevar/hamburguesa/pizza.
- Café Don Zacarías → semántica agrícola, cosecha, secado, calidad y transformación cafetalera.
- Chocolates La Florita → semántica de formulaciones, moldes, manufactura y productos de cacao.

**El Core no conoce pizza, café ni chocolate.**

## 8. UNIVERSALIDAD OPERATIVA
IQ GROWTH no hardcodea una “empresa típica”. Debe permitir configurar:
- calendario y ciclo operativo (no asumir 7 días abiertos);
- temporadas/campañas/proyectos/citas;
- unidades locales o sectoriales;
- origen de producto: comprado, producido, cosechado, transformado, servicio;
- trabajo propio, empleado, jornal, contrato, cuadrilla, pago por unidad u otra relación registrada;
- tienda fija, sucursal, puesto callejero, feria, carrito, vendedor ambulante, vehículo, ruta, distribuidor, mayorista, e-commerce o exportación;
- inventario en almacén, planta, finca, vendedor, vehículo, puesto o tercero;
- múltiples precios por presentación/canal/cliente/fecha;
- legalidad/formalidad separada de realidad observada.

Un día planificado cerrado es una condición normal del calendario, no una falla. Ejemplo vigente de laboratorio: VANSAM opera miércoles→lunes y martes es descanso planificado; este detalle vive en su configuración/estado, no como regla del Core.

## 9. MÉTRICA DE ÉXITO NORTE
La métrica económica superior es contribución/margen incremental atribuible o asociado a intervenciones con evidencia suficiente, declarando confianza y límites de causalidad. No se mide éxito por ventas totales, seguidores o actividad del software.

El producto inicial puede usar objetivos de cobertura y contribución estimada; no debe llamar “utilidad neta” a estimaciones incompletas.

## 10. REALIDAD FORMAL E INFORMAL
IQ GROWTH debe registrar la realidad de negocios formales, informales y en transición sin certificar como jurídicamente válida una práctica solo porque ocurre.

Modelo:

`HECHO REAL OBSERVADO → OBLIGACIÓN VERSIONADA → BRECHA → MATERIALIDAD/RIESGO → PLAN DE TRANSICIÓN`

No existe `modo informal = permitido`. Existe registro honesto de realidad + compliance aplicable cuando pueda verificarse.

## 11. REGLA DE SEPARACIÓN EMPRESARIAL Y FAMILIAR
IQ GROWTH debe representar por separado relaciones que en una empresa familiar pueden coexistir en una misma persona:
- socio / participación societaria;
- empleado / salario / beneficios;
- administrador / permisos de gestión;
- prestamista / préstamo y saldo;
- aporte de capital;
- retiro;
- distribución de utilidades;
- propietario de activo usado por la empresa;
- proveedor/contratista;
- vendedor/distribuidor.

Nunca se debe inferir que un préstamo cambia una participación societaria, que ser socio equivale a ser empleado, que un salario es distribución de utilidad, que el saldo de caja equivale a utilidad distribuible o que usar un vehículo familiar lo convierte en activo de la empresa. Las reglas legales, laborales, fiscales y contables deben parametrizarse y validarse conforme a la normativa aplicable; IQ GROWTH no debe inventarlas.

## 12. CONTEXTO DETALLADO DE LOS LABORATORIOS
El detalle operativo cambia y se conserva fuera de este documento constitucional:
- `docs/IQG-100_*` — VANSAM / Growth Engine.
- `docs/IQG-003_CAFE_ZACARIAS_VERTICAL_V1.md` — cadena cafetalera end-to-end.
- `docs/IQG-004_CHOCOLATES_LA_FLORITA_VERTICAL_V1.md` — manufactura/distribución chocolate.
- `docs/IQG_CORE_UNIVERSAL_BUSINESS_MODEL_V1.md` — capacidades universales derivadas de los laboratorios.
- `docs/CURRENT_STATE.md` y `docs/EXECUTION_STATE.md` — estado operativo/camino técnico.

## 13. GOBERNANZA DEL AI COUNCIL
- **Iván** → CEO / Product Owner / autoridad final. Decide visión, prioridades, presupuesto, arquitectura irreversible y releases críticos.
- **ChatGPT** → Chief Architect & AI Council Coordinator. Integra estrategia, arquitectura, análisis y asigna especialistas.
- **Codex** → Principal Engineer. Construye, prueba, migra y modifica código de producto.
- **Claude** → Product & Systems Challenger. Cuestiona alcance, producto, UX, sobreingeniería y supuestos.
- **DeepSeek** → Red Team, Security & Data Integrity Auditor. Intenta romper seguridad, aislamiento e integridad.
- **Gemini** → Market Intelligence & External Evidence Lead. Aporta mercado, competencia, precios, demanda y evidencia externa.
- **Dola** → Executive Assistant & Operational Helper. Apoya al CEO con capturas, pasos simples, secretaría, recordatorios y consultas operativas pequeñas; no coordina el camino crítico técnico.

Regla principal:
**Iván dirige. ChatGPT coordina. Codex construye. Claude desafía. DeepSeek intenta romper. Gemini aporta evidencia externa. Dola apoya al CEO.**
