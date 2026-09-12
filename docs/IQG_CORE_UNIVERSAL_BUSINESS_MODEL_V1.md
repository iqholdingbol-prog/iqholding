# IQ GROWTH — Universal Business Model V1

**Fecha:** 2026-09-12
**Estado:** arquitectura canónica conceptual, previa a implementación
**Autoridad:** Iván Quea — CEO / Product Owner

## 1. Propósito

IQ GROWTH debe poder organizar y hacer crecer empresas pequeñas, medianas o grandes; formales, informales o en transición; de productos, servicios, agricultura, manufactura, comercio, distribución, proyectos o combinaciones.

El Core no debe programarse alrededor de VANSAM, Café Don Zacarías ni Chocolates La Florita. Esos negocios son laboratorios que fuerzan al Core a demostrar universalidad.

Principio:

`CORE UNIVERSAL → CAPACIDADES → ADAPTADOR VERTICAL → CONFIGURACIÓN EMPRESA`

No:

`NUEVO RUBRO → NUEVAS TABLAS/REGLAS EN EL CORE`

## 2. Regla anti-hardcode

No hardcodear como universales:
- 7 días por semana;
- martes abierto/cerrado;
- pizza;
- café;
- chocolate;
- kg como única unidad;
- tienda fija;
- facturación obligatoria como realidad observada;
- trabajador formal como única realidad posible;
- un solo tipo de precio;
- un solo tipo de inventario;
- una única cadena productiva.

Todo lo anterior debe ser configuración o capacidad activable.

## 3. Identidad organizacional

Capacidades universales:
- ORGANIZATION/COMPANY;
- BRANCH/OPERATING_UNIT;
- LOCATION;
- PERSON;
- ROLE;
- RELATIONSHIP;
- PERMISSION;
- OWNER/PARTNER relation separada de EMPLOYEE/ADMIN/LENDER/CONTRACTOR;
- evidencia/auditoría.

Una persona puede tener múltiples relaciones simultáneas sin mezclarlas.

## 4. Calendario y ciclo operativo configurable

Conceptos:
- `OPERATING_CALENDAR`;
- `OPERATING_CYCLE`;
- `PLANNED_OPEN`;
- `PLANNED_CLOSED`;
- `ACTUAL_OPEN`;
- `ACTUAL_CLOSE`;
- `UNPLANNED_CLOSURE`;
- `SEASON/CAMPAIGN`;
- `PROJECT_PERIOD`;
- `APPOINTMENT_WINDOW`.

Ejemplos:
- VANSAM: miércoles→lunes operativos; martes descanso planificado.
- fábrica: lunes→viernes.
- hotel: 24/7.
- agricultura: campañas y labores por etapa/temporada.
- consultorio: citas.
- construcción: proyecto/hito.

Un día planificado cerrado nunca cuenta como falla operativa.

## 5. Unidad de medida universal

IQ GROWTH debe soportar catálogo versionado de unidades y conversiones verificadas.

Dimensiones iniciales:
- cantidad: unidad, docena, caja, paquete;
- masa: g, kg, lb, qq, saco;
- volumen: ml, L, lata operacional;
- superficie: m², ha;
- longitud;
- tiempo: minuto, hora, jornada;
- servicio/proyecto;
- moneda;
- unidades definidas por empresa.

Reglas:
- la unidad operativa puede existir sin conversión estándar;
- una conversión solo se usa cuando está verificada;
- conservar siempre unidad original del hecho;
- conversiones futuras no reescriben historia.

## 6. Catálogo, familia, variante y presentación

Modelo conceptual:

```text
ITEM_FAMILY
  ↓
ITEM / PRODUCT / SERVICE
  ↓
VARIANT
  ↓
PRESENTATION
  ↓
UNIT_OF_MEASURE
  ↓
PRICE_VERSION
```

Atributos configurables:
- nombre;
- marca;
- tipo;
- forma;
- tamaño;
- color;
- peso/volumen;
- calidad/clase;
- empaque;
- formulación;
- canal;
- imagen;
- códigos internos/externos.

Debe soportar desde un chocolatito individual hasta café por kg, una pizza por tamaño, una hora profesional o un contrato de servicio.

## 7. Precio temporal y multicanal

Un mismo ítem puede tener simultáneamente:
- minorista;
- mayorista;
- por cantidad;
- por canal;
- por ciudad;
- por punto de venta;
- por cliente/acuerdo;
- promoción temporal;
- moneda distinta cuando corresponda.

Cada precio tiene vigencia. Nunca reescribir ventas históricas.

## 8. Origen del producto/servicio

El Core debe distinguir:
- `PURCHASED` — comprado a proveedor;
- `PRODUCED` — producido internamente;
- `HARVESTED` — producido/cosechado en unidad agrícola;
- `TRANSFORMED` — resultado de transformación;
- `SERVICE_DELIVERED`;
- `CONSIGNED`;
- otros configurables.

Ejemplos:
- Café: puede originarse desde finca propia.
- Chocolate: cacao comprado a proveedor y luego transformado.
- Ferretería: producto comprado y revendido.
- Agencia: servicio producido por horas/personas.

## 9. Compras y procurement

Capacidades:
- proveedor;
- solicitud;
- orden cuando se use;
- recepción;
- precio/fecha;
- cantidad/unidad;
- lote;
- transporte;
- gasto asociado;
- evidencia;
- pago separado;
- devolución;
- calidad/incidencia.

La compra actualiza costo hacia adelante según método configurado; nunca modifica el costo histórico de un hecho ya ocurrido.

## 10. Producción, transformación y proyectos

Modelo genérico:

`INPUT(S) → PROCESS/TRANSFORMATION → OUTPUT(S)`

Soporta:
- receta de pizza;
- café cereza→pergamino→verde→tostado;
- cacao/insumos→chocolate;
- materia prima→manufactura;
- horas/equipo→servicio/proyecto;
- producto→reparación/reacondicionamiento.

Cada transformación registra:
- entradas;
- unidades;
- lotes;
- responsables;
- recursos/equipos;
- tiempo;
- costo;
- salida(s);
- coproductos;
- merma/descarte;
- calidad;
- incidencias;
- evidencia.

## 11. Lotes, series y trazabilidad

Activable según rubro:
- `BATCH/LOT`;
- `SERIAL_NUMBER`;
- `EXPIRY`;
- `QUALITY_GRADE`;
- provenance/origen.

No todas las empresas necesitan lotes. El Core debe soportarlos sin exigirlos.

## 12. Inventario universal y ubicación

Todo stock tiene:
- item/variante/presentación;
- cantidad;
- unidad;
- ubicación/custodio;
- estado;
- lote/serie si aplica;
- costo asociado;
- fecha;
- evidencia.

Ubicaciones pueden ser:
- almacén;
- tienda;
- cocina;
- finca;
- planta;
- vehículo;
- carrito;
- puesto de feria;
- tercero;
- vendedor;
- ubicación temporal.

Transferir stock crea movimientos; no cambia mágicamente su ubicación actual.

## 13. Activos y recursos

Recursos universales:
- terreno;
- maquinaria;
- herramienta;
- vehículo;
- horno;
- PC/tablet/TV;
- local;
- mobiliario;
- recurso alquilado/prestado/de tercero.

Separar:
- propietario legal/declarado;
- empresa usuaria;
- contrato/relación de uso;
- custodio;
- ubicación;
- disponibilidad;
- mantenimiento;
- costo;
- capacidad;
- evidencia.

Usar el vehículo de un familiar no convierte automáticamente ese vehículo en activo de la empresa.

## 14. Fuerza laboral y contratistas

El Core registra realidad sin asumir una sola forma laboral:
- empleado;
- propietario que trabaja;
- familiar;
- contratista;
- cuadrilla;
- jornalero;
- pago por unidad;
- apoyo eventual;
- proveedor de servicio.

Por vínculo:
- función;
- periodo;
- horario/jornada cuando exista;
- unidad de pago;
- tarifa/salario;
- pago observado;
- responsabilidades;
- asistencia cuando corresponda;
- incidencias;
- evidencia;
- cumplimiento/brecha a través del Compliance Layer.

El software no cambia la naturaleza jurídica de una relación por una etiqueta.

## 15. Responsabilidad operativa

Todo proceso importante puede tener:
- responsable principal;
- respaldo;
- sector;
- SLA/objetivo;
- evidencia;
- incidencia;
- respuesta;
- estado.

`RESPONSABLE` no equivale automáticamente a `CULPABLE`.

## 16. Puntos de venta y canales

Un canal/punto de venta puede ser:
- tienda fija;
- sucursal;
- puesto fijo callejero;
- feria temporal;
- carrito ambulante;
- vendedor ambulante;
- vehículo;
- ruta;
- distribuidor;
- mayorista;
- B2B;
- marketplace/e-commerce;
- delivery;
- exportación;
- canal futuro configurable.

No asumir que una misma estrategia comercial sirve en todas las ciudades.

## 17. Comercio móvil

Una unidad móvil puede abrir/cerrar una sesión comercial:

```text
ASIGNAR VENDEDOR
+ ASIGNAR VEHÍCULO/CARRITO
+ CARGAR STOCK
+ DEFINIR ZONA/RUTA
→ VENDER/COBRAR
→ REGISTRAR GASTOS/INCIDENCIAS
→ RETORNAR
→ CONCILIAR STOCK + CAJA
```

Debe soportar movimientos de inventario entre planta/almacén y vendedor móvil.

## 18. Venta, pago y caja separados

Regla universal:

`ORDER ≠ SALE ≠ PAYMENT ≠ CASH_MOVEMENT`

La venta puede tener:
- cliente identificado o anónimo;
- canal;
- vendedor;
- ubicación/ruta;
- artículos/servicios;
- unidades;
- precio vigente;
- descuentos;
- lote/serie;
- impuestos/documentos cuando aplique;
- devolución.

Pago y caja se registran aparte.

## 19. Formalidad y realidad

IQ GROWTH debe soportar empresas:
- formal verificadas;
- parcialmente formales;
- en transición;
- con realidad operacional informal registrada.

Nunca existe `modo informal = autorizado`.

Modelo:

`HECHO REAL → OBLIGACIÓN VERSIONADA → BRECHA → MATERIALIDAD/RIESGO → PLAN DE TRANSICIÓN`

Esto aplica laboral, tributario, documental y otros dominios según jurisdicción.

## 20. Costos y economía

Debe separar:
- costo observado de caja;
- costo variable;
- costo fijo;
- costo de producción;
- costo por lote/proyecto;
- costo formal estimado;
- brecha de cumplimiento;
- margen/contribución;
- provisiones;
- estimaciones vs hechos.

No presentar contribución como utilidad contable/neto sin base suficiente.

## 21. Growth Engine universal

El motor no depende del rubro. Trabaja sobre palancas configuradas:
- adquisición;
- conversión;
- ticket/mix;
- precio/margen;
- recompra/retención;
- disponibilidad;
- productividad;
- capacidad;
- merma;
- rotación;
- calidad;
- costos;
- continuidad;
- canal/ruta;
- utilización de recursos.

Salida:

`HECHO → BRECHA/OPORTUNIDAD → UNA ACCIÓN PRIORITARIA → EJECUCIÓN HUMANA → RESULTADO OBSERVADO → APRENDIZAJE`

## 22. Tres laboratorios y qué fuerzan al Core

### VANSAM
- servicio + comercio;
- pedidos;
- cocina;
- personal;
- horarios;
- POS/KDS;
- atención;
- CRM;
- cross-sell;
- continuidad.

### Café Don Zacarías
- tierra/inversión;
- agricultura;
- campañas;
- cuadrillas/jornales/unidades;
- cosecha;
- coproductos;
- secado/clima;
- logística;
- lotes/calidad;
- transformación profunda;
- exportación;
- venta móvil/fija.

### Chocolates La Florita
- procurement externo;
- formulación;
- manufactura;
- lotes;
- muchas variantes/formas/pesos;
- empaque;
- distribución;
- venta móvil/fija;
- mayorista/minorista.

## 23. Prueba de universalidad futura

Después de validar los laboratorios propios, el Core debe probarse con negocios externos de rubros no usados para diseñarlo.

Ejemplos de stress test:
- importadora/electrónica;
- ferretería;
- taller;
- servicios profesionales;
- hotel;
- clínica/consultorio (con compliance específico);
- constructora;
- distribuidora;
- e-commerce;
- otra agricultura/manufactura.

Si un nuevo rubro exige modificar el Core con lógica específica de negocio, debe abrirse revisión arquitectónica: primero intentar resolverlo mediante capacidades/configuración/adapter.

## 24. Criterio de éxito

IQ GROWTH es realmente universal cuando una empresa nueva puede configurarse describiendo:
- qué hace/vende;
- dónde opera;
- cuándo opera;
- quién participa;
- qué compra;
- qué transforma;
- qué unidades usa;
- qué activos usa;
- cómo mueve stock;
- cómo vende/cobra;
- por qué canales;
- qué obligaciones aplican;
- qué objetivo quiere mejorar;

sin reconstruir el sistema desde cero.

**Estado:** `UNIVERSAL_BUSINESS_MODEL_DEFINED_V1`
**CEO_ACTION_REQUIRED:** false
