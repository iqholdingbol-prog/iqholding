# CLAUDE_PRODUCT_SYSTEMS_REVIEW.md

**Ticket:** IQG-000-C
**Rol:** Product & Systems Challenger — AI Council de IQHOLDING
**Fecha:** 10 de septiembre de 2026
**Postura:** cuestionar, no confirmar. Este documento está escrito para incomodar, no para aprobar.
**Alcance:** producto y sistemas. No decide arquitectura, no elige base de datos, no escribe código.

---

## 0. Advertencia de método (léelo antes que nada)

Este análisis es independiente, pero **no es omnisciente**. Trabajo con lo que está declarado en el ticket y con lo que tú mismo has registrado sobre las tres empresas. Hay decisiones aquí que dependen de datos que no tengo.

**Supuestos que estoy haciendo (corrígeme si alguno es falso):**

| # | Supuesto | Si es falso, cambia… |
|---|---|---|
| S1 | El equipo de desarrollo eres tú, con apoyo de IA. No hay programadores contratados a tiempo completo. | Todo el plan de 90 días |
| S2 | VANSAM es la única de las tres empresas con transacciones diarias hoy. Café y Chocolate aún no venden con volumen sostenido. | La secuencia de pruebas (sección 9) |
| S3 | La planta industrial de Senkata todavía no está operativa. | El alcance de los módulos de manufactura |
| S4 | No hay presupuesto asignado para infraestructura mensual más allá de decenas de dólares. | Las restricciones técnicas (sección 15) |
| S5 | No existe hoy un contador ni un sistema contable formal integrado. | Lo que hay que aplazar (sección 7) |

**Lo que NO sé y necesito que respondas** está al final, en la sección 18. No lo he inventado ni rellenado.

---

## 1. Conclusión general

**El plan no tiene un problema de tecnología. Tiene un problema de identidad.**

Lo que está escrito en el ticket describe **cuatro productos distintos** presentados como uno solo:

1. Un **POS/operación** para un restaurante que factura decenas de tickets al día.
2. Un **sistema agroindustrial de lotes y trazabilidad** para café, con exportación.
3. Un **sistema de manufactura y distribución** para chocolate.
4. Un **SaaS vendible a terceros** (IQ GROWTH como producto de mercado).

Los tres primeros son un ERP interno hecho a medida. El cuarto es un negocio de software. **No son el mismo producto y casi nunca comparten el mismo código sin una reescritura.** Un ERP interno se optimiza para *tu* operación; un SaaS se optimiza para el promedio de mil operaciones ajenas. Perseguir ambos en paralelo, con un equipo de una persona, es la forma más confiable de terminar con un producto que no sirve del todo para ninguno.

**El segundo hallazgo es más duro:** el objetivo declarado es *"que nuestras tres empresas vendan más y sean más rentables"*, pero **casi ninguno de los ocho requisitos listados vende nada**. Multiempresa, multisucursal, modular, auditable, preparado para IA: son atributos de administración. Ninguno hace que se venda una pizza más. La lista de requisitos y el objetivo declarado apuntan en direcciones opuestas.

**El tercer hallazgo es el que menos te va a gustar:** VANSAM está declarado como *"el primer laboratorio real"*, pero según tu propio registro operativo **VANSAM no está en condiciones de ser laboratorio de nada todavía** — sin horno de pizza dedicado, sin máquina de espresso, con rotación alta de personal, con Samira sola en el local y con sueldos ofrecidos por debajo del salario mínimo. Un laboratorio donde el instrumento principal está roto no produce datos válidos. **Cualquier medición de "el software subió las ventas" hecha en esa condición será ruido.**

**Veredicto:** el plan es ambicioso y coherente *como visión de 5 años*. Como plan de ejecución de los próximos 90 días es sobredimensionado por un factor de al menos 10x. Recomiendo recortar agresivamente, secuenciar en vez de paralelizar, y arreglar la operación física de VANSAM antes de escalar el software.

---

## 2. ¿Qué estamos intentando construir realmente?

Separemos lo que hay debajo del nombre "IQ GROWTH":

| Producto real | Cliente | Cómo se mide el éxito | Madurez hoy | ¿Debe existir ahora? |
|---|---|---|---|---|
| **A. POS + operación de restaurante** | VANSAM (uso interno) | Ventas/día, ticket promedio, tiempo de atención, merma | v9 en producción (HTML único + Firebase) | **Sí — es lo único vivo** |
| **B. Trazabilidad y costos agroindustriales** | Café Zacarías (uso interno) | Costo por kg por etapa, rendimiento cereza→oro→tostado | No existe | Modelo sí, software no |
| **C. Manufactura + distribución** | Chocolates La Florita (uso interno) | Costo por lote, merma, rotación por punto de venta | No existe | Modelo sí, software no |
| **D. SaaS B2B para emprendedores bolivianos** | Terceros que pagan Bs 79–249/mes | Clientes pagando, retención, CAC | Idea | **No todavía** |
| **E. Marketplace B2B de compras agregadas** | Terceros + proveedores mayoristas | Volumen transado, comisión | Idea | **Eliminar del plan actual** |

**Lo que realmente estás construyendo, si soy honesto:** un sistema de información para tu propio grupo empresarial, con la esperanza de que después sea vendible. Eso es legítimo y es como nacieron varios productos buenos. Pero la esperanza no debe dictar la arquitectura del día 1. **Diseñar hoy para 3.000 clientes externos que aún no existen es lo que convierte un proyecto de 3 meses en uno de 3 años.**

### La pregunta incómoda sobre el producto D

Tu meta registrada es 3.000 clientes × Bs 149 promedio ≈ Bs 5,3M anuales. Hagamos la aritmética que el plan no hace:

- Para llegar a 3.000 clientes en 3 años necesitas **~85–100 altas netas por mes, sostenidas, durante 36 meses**.
- Con una rotación (churn) mensual del 4% —optimista para PyMEs pequeñas— a 3.000 clientes estás perdiendo **120 clientes/mes** solo por abandono. Es decir: para *mantenerte* en 3.000 necesitas vender 120/mes para siempre.
- Eso no es un producto. Eso es **un equipo comercial**, soporte telefónico, onboarding, cobranza y capacitación. Es una empresa de servicios disfrazada de software.

No digo que sea imposible. Digo que **el cuello de botella de IQ GROWTH como negocio nunca va a ser el código** — va a ser la distribución y el soporte. Y el plan actual invierte 100% del esfuerzo en el código.

---

## 3. ¿Qué riesgo de sobreingeniería existe?

**Alto. Es el riesgo número uno del proyecto.**

Los ocho adjetivos del ticket son, cada uno, una decisión de arquitectura con costo real. Puestos juntos y al mismo tiempo, describen Odoo o SAP Business One — productos con cientos de personas-año encima.

| Adjetivo pedido | Costo real si se implementa ahora | ¿Cuándo se necesita de verdad? | Veredicto |
|---|---|---|---|
| **Multiempresa** | Una clave de alcance (`empresa_id`) en cada tabla, cada consulta y cada permiso | Cuando hay ≥2 empresas cargando datos | **Sí, ahora — pero solo en el modelo de datos, no en la interfaz.** Es barato hoy, carísimo de retrofitear |
| **Multisucursal** | Segunda clave de alcance, transferencias entre sucursales, stock por ubicación | Cuando exista la 2ª sucursal | **Solo el campo. Nada de UI ni transferencias** |
| **Multirubro** | Modelos genéricos + configuración por vertical; duplica el diseño de cada pantalla | Cuando el 2º rubro cargue datos reales | **Aplazar. Es la fuente principal de sobreingeniería** |
| **Modular** | Fronteras entre módulos, contratos internos, activación/desactivación | Cuando haya clientes que compren módulos distintos | **Aplazar. Hoy "modular" = carpetas ordenadas, no un motor de módulos** |
| **Seguro** | Autenticación real, roles, cifrado, gestión de secretos | **Desde el día 1** | **Sí, ahora. Y hoy no lo está** (ver contradicción C4) |
| **Auditable** | Registro inmutable de quién hizo qué y cuándo | **Desde el día 1** | **Sí, ahora. Es barato y sin esto no hay confianza en los números** |
| **Preparado para IA** | Datos limpios, con fecha, con unidades y con historia. Nada más | Desde el día 1, gratis | **Sí — pero significa "datos bien guardados", no "módulo de IA"** |
| **De empresa pequeña a administración integral** | Es el requisito más caro del documento | Nunca, tal como está escrito | **Eliminar del alcance. Ver contradicción C2** |

**Regla que propongo adoptar:** *cada adjetivo que no cambie el modelo de datos se aplaza; cada adjetivo que sí lo cambie se implementa hoy, mínimamente, sin interfaz.*

Es decir: pon `empresa_id`, `sucursal_id`, `usuario_id` y `fecha_registro` en todo desde el primer día. **No construyas ni una sola pantalla para administrarlos hasta que haya una segunda empresa o sucursal cargando datos reales.**

---

## 4. Contradicciones detectadas en el plan actual

Esta es la sección más importante del documento.

### C1 — El objetivo es vender más; los requisitos son administrativos

*"IQ GROWTH debe ayudar PRIMERO a que nuestras tres empresas vendan más y sean más rentables"* vs. una lista de ocho requisitos donde ninguno es de venta. Ni CRM, ni promociones, ni recompra, ni velocidad de cobro aparecen entre los "debe ser". **O el objetivo está mal escrito, o los requisitos son los de otro producto.** Hay que elegir uno.

### C2 — "MVP" y "de empresa pequeña a administración integral" son incompatibles

Un MVP es un recorte deliberado. "Que sirva desde una empresa pequeña hasta la administración integral" es lo contrario: es el compromiso de cubrir todos los casos. **Pedir ambas cosas en el mismo documento garantiza que el MVP se infle hasta dejar de ser MVP.** Solo puedes tener una.

### C3 — "No elijas base de datos" pero la decisión ya está tomada de facto

El ticket dice explícitamente que la base de datos quede abierta. Pero **el POS v9 ya está en producción sobre Firebase Realtime Database**, con datos reales de VANSAM. Eso no es una decisión abierta: es una decisión tomada, sin haberla evaluado contra los requisitos del ticket. Y hay fricción concreta: los requisitos "auditable", "multiempresa" y "reportes con historia" son precisamente donde Realtime Database es más incómoda (sin consultas relacionales, sin integridad referencial, costo por volumen descargado, reglas de seguridad difíciles de auditar).

**No estoy diciendo que cambies de base de datos.** Estoy diciendo que **el plan cree que la decisión está abierta y no lo está**, y esa brecha entre el documento y la realidad es peligrosa. Ver sección 15 para cómo mantenerla genuinamente abierta.

### C4 — "Seguro y auditable" vs. contraseña de administrador en un archivo HTML

El acceso al modo admin del POS es una contraseña fija incrustada en un archivo HTML público servido desde Netlify. Cualquiera que abra el código fuente la ve. **No es un detalle: es la refutación directa del requisito "seguro".** Y sin usuarios individuales, tampoco hay nada que auditar — no se puede saber *quién* anuló una venta, solo que "el admin" lo hizo.

Este es el defecto más urgente de todo el sistema actual, y es el que menos aparece en el plan.

### C5 — El laboratorio principal no está operativo

VANSAM se define como *"el primer laboratorio real, allí probamos todo"*. Pero: no hay horno de pizza dedicado (se usa un horno adaptado, lento y sobredimensionado), no hay máquina de espresso (el lado café está limitado), la rotación de personal es alta y Samira está sola. **Un experimento corrido sobre una operación inestable no produce conclusiones — produce anécdotas.**

Si el objetivo real es "vender más", el retorno de comprar un horno de pizza adecuado es casi con seguridad mayor, más rápido y más barato que el de cualquier módulo de software del plan. **Esa comparación no está hecha en ninguna parte del plan.**

### C6 — El laboratorio es la empresa donde tienes menos control

Tienes el 40% de VANSAM; Samira el 60%. Estás construyendo el activo estratégico del grupo (IQ GROWTH) usando como banco de pruebas, datos y operación la empresa donde **no tienes la mayoría**. Preguntas sin respuesta en el plan: ¿de quién son los datos de clientes de VANSAM? ¿Quién es dueño del código? ¿Qué pasa con IQ GROWTH si la sociedad con Samira cambia?

**Esto debe quedar por escrito antes de escribir más código, no después.** IQ GROWTH debe ser propiedad de IQHOLDING, no de VANSAM, y VANSAM debe figurar como usuario/licenciatario.

### C7 — Las tres empresas están en etapas incomparables

VANSAM opera hoy. Café Zacarías tiene finca y un galpón vacío en Senkata. Chocolates La Florita se desarrollará *junto a* Café Zacarías en una planta que aún no existe. **Construir requisitos para las tres a la vez significa que dos de cada tres requisitos son imaginarios.** Los requisitos imaginarios siempre están mal, y siempre se descubre tarde.

### C8 — Riesgo laboral que ningún software resuelve

Sueldos ofrecidos de Bs 2.000–2.500 contra un salario mínimo que registraste en Bs 3.300. Si ese dato sigue vigente, **hay una exposición legal y una explicación estructural de la rotación de personal** que ningún sistema de gestión va a arreglar. Es un problema de costos y de modelo de negocio del restaurante, no de tecnología. *(Verificar el salario mínimo vigente para 2026 antes de actuar — no lo doy por confirmado.)*

### C9 — El marketplace B2B es otro negocio entero

*"Agregar demanda de negocios y conectarlos con proveedores mayoristas, ganar comisión"* es un negocio de logística, crédito y relaciones con proveedores. No comparte prácticamente nada con un POS salvo la base de clientes. Está listado como si fuera un módulo más. **No es un módulo. Es una segunda empresa.**

---

## 5. MVP propuesto

**Nombre de trabajo: IQ GROWTH v1 — "Vender, Cobrar, Saber".**

Definición en una frase: *el sistema mínimo que permite registrar cada venta en segundos, cuadrar la caja al cierre, y saber al día siguiente qué se vendió, a quién y con cuánto margen.*

### Alcance INCLUIDO

| Módulo | Qué hace | Por qué está | Vertical |
|---|---|---|---|
| **Venta rápida** | Registrar un pedido y cobrarlo en <15 segundos, funcionando sin internet | Es el único punto donde el software toca el dinero | Universal |
| **Caja y cierre de turno** | Apertura, movimientos, arqueo, diferencia | Sin cuadre no hay confianza en ningún otro número | Universal |
| **Catálogo y precios** | Productos, precios, combos, disponible/agotado | Prerrequisito de todo | Universal |
| **Cliente por teléfono** | Teléfono → nombre, dirección, "lo de siempre" | **Único módulo del MVP que sube ventas directamente** | Universal |
| **Insumos críticos** | Solo los 15–20 insumos que causan quiebre o merma. No inventario total | Quiebre de stock = venta perdida | Universal |
| **Compras y gastos** | Registro simple con fecha, proveedor, monto, categoría | Sin costos no hay margen; sin margen "rentabilidad" es opinión | Universal |
| **Usuarios y roles reales** | Dueño / encargado / cajero, cada uno con su acceso | Cierra C4. Habilita auditoría | Universal |
| **Bitácora de auditoría** | Quién, qué, cuándo — inmutable, especialmente anulaciones y descuentos | Barato ahora, imposible de reconstruir después | Universal |
| **Tablero diario** | Ventas, tickets, ticket promedio, top productos, margen estimado, quiebres | Es *el producto*. Lo demás es captura de datos | Universal |

### Decisiones estructurales del MVP (sin interfaz)

- `empresa_id`, `sucursal_id`, `usuario_id`, `fecha_registro` en **todo** registro, desde el primer día.
- **Un solo modelo genérico de movimiento de inventario**, con cuatro tipos: `entrada`, `salida`, `ajuste`, **`transformación`** (N insumos → M productos, con rendimiento).
- Toda cifra monetaria con moneda explícita y **entero en centavos**, nunca decimal flotante.
- Exportación diaria completa a un formato neutro (CSV/JSON). Es lo que mantiene abierta la decisión de base de datos.

> **La única apuesta arquitectónica que vale la pena hacer hoy es `transformación`.** Es la abstracción que cubre, con un solo modelo: la receta de una pizza, el tueste del café (cereza → pergamino → oro → tostado, con factor de rendimiento en cada etapa) y la producción de un lote de chocolate. Si esa pieza está bien hecha, las tres verticales caben. Si está mal hecha, hay que reescribir el núcleo. **Es el único lugar donde recomiendo pensar de más.**

### Definición de "terminado" (no negociable)

El MVP está terminado cuando, durante **14 días seguidos en VANSAM**:

1. El 100% de las ventas se registran en el sistema (no en cuaderno paralelo).
2. La caja cuadra al cierre con una diferencia menor a Bs 20 en al menos 12 de los 14 días.
3. Un cajero nuevo aprende a usarlo en menos de 20 minutos, sin ti presente.
4. El tablero del día siguiente está listo sin intervención manual tuya.

**Si no se cumplen los cuatro, no se construye ningún módulo nuevo.** Ninguno.

---

## 6. Lo que ELIMINARÍA del plan inicial

Eliminar ≠ aplazar. Esto lo sacaría del documento por completo, para dejar de gastar atención en ello.

| Elemento | Por qué eliminarlo |
|---|---|
| **Marketplace B2B de compras agregadas** | Es otra empresa (logística + crédito + proveedores). Contamina todas las decisiones de producto. Si algún día se hace, se hace desde cero (C9) |
| **"De empresa pequeña a administración integral"** | Es un anti-requisito: no se puede diseñar contra él y garantiza inflación de alcance (C2) |
| **"Modular" como motor de módulos activables** | Hoy no hay a quién venderle módulos sueltos. Reemplazar por "código ordenado en carpetas por dominio" |
| **Meta de 3.000 clientes como guía de diseño** | Está bien como ambición; es dañina como criterio técnico. Diseñar para 3.000 empresas hoy es diseñar para nadie |
| **"Preparado para IA" como módulo** | Reemplazar por una regla de datos: fecha, unidad, autor e historia en todo registro. Eso *es* estar preparado para IA. Un "módulo de IA" sobre datos sucios no sirve |
| **Multirubro como requisito del MVP** | Se gana escribiendo bien `transformación`, no configurando rubros |

---

## 7. Lo que APLAZARÍA (con condición de desbloqueo)

Cada aplazamiento tiene una condición objetiva. Sin la condición, un aplazamiento es solo una lista de deseos.

| Elemento | Se desbloquea cuando… |
|---|---|
| Facturación electrónica / SIAT | Se verifique la obligación legal vigente para cada empresa. **Si resulta obligatoria hoy, sube a prioridad 1 y reordena todo el plan.** Esta verificación es urgente (ver P1, sección 18) |
| Contabilidad completa | Haya contador asignado y plan de cuentas definido |
| Multisucursal (interfaz, transferencias, stock por ubicación) | Exista la 2ª sucursal con ventas |
| Multiempresa (interfaz de administración) | La 2ª empresa cargue datos ≥30 días seguidos |
| Módulo de exportación de café (contratos, contenedores, documentación) | Haya un comprador extranjero real con contrato firmado |
| Trazabilidad de finca por parcela | Haya una cosecha registrada completa en modo simple |
| Tienda en línea / e-commerce propio | El pedido por WhatsApp esté saturando la capacidad de atención |
| App móvil de clientes | Existan ≥300 clientes identificados y recurrentes |
| Programa de puntos formal | El cupón simple de retorno haya demostrado funcionar |
| Control de empleados (marcaciones, horarios) | Haya ≥8 empleados y el problema sea medible |
| IQ GROWTH como SaaS vendido a terceros | VANSAM haya operado 90 días con el sistema y tengas el **antes/después medido**. Sin ese número no tienes argumento de venta |
| Módulos de la planta industrial de Senkata | La planta exista físicamente y produzca |
| API pública / white-label / marketplace de módulos | Nunca en este horizonte |

---

## 8. Universal vs. vertical

Este corte determina si el sistema envejece bien o se convierte en tres sistemas pegados con cinta.

### Universal (núcleo compartido, se construye una vez)

- Identidad, usuarios, roles y permisos
- Empresas y sucursales (alcance de datos)
- Catálogo de productos, unidades de medida, precios y listas de precio
- **Movimientos de inventario** (entrada / salida / ajuste / **transformación con rendimiento**)
- Ventas y documentos de venta
- Caja, arqueo y cierre de turno
- Clientes e historial de compra
- Compras, proveedores y gastos
- Costos y márgenes
- Reportes y tablero
- Bitácora de auditoría
- Exportación de datos

### Vertical (específico, se construye solo cuando ese negocio lo pide)

| VANSAM (restaurante) | Café Zacarías (agroindustria) | Chocolates La Florita (manufactura) |
|---|---|---|
| Mesas y comandas | Parcelas y cosechas por lote | Fórmulas / lista de materiales |
| Pantalla de cocina | Etapas: cereza → pergamino → oro → tostado | Órdenes de producción |
| Recetas y escandallo | Factores de rendimiento por etapa | Lotes con fecha de vencimiento |
| Delivery y zonas | Perfiles de tueste | Empaque y presentaciones |
| Franjas horarias pico | Análisis de taza / calidad | Distribución y consignación |
| Merma de preparación | Certificaciones y origen | Rotación por punto de venta |
| | Contratos y logística de exportación | Canal mayorista B2B |

**Prueba de fuego para decidir si algo es universal:** *¿las tres empresas lo necesitarían aunque las otras dos no existieran?* Si la respuesta no es un sí inmediato, es vertical. La tentación de "generalizarlo por si acaso" es exactamente la sobreingeniería que hay que evitar.

---

## 9. ¿Cómo probar simultáneamente VANSAM, Café y Chocolate?

**Respuesta directa: no lo hagas. Es la pregunta equivocada.**

Razones concretas:

- **Ciclos de aprendizaje incompatibles.** VANSAM genera decenas de transacciones al día: aprendes en 2 semanas. El café tiene **una cosecha al año**: si te equivocas en el modelo de datos de cosecha, el próximo intento es en 12 meses. Chocolate depende de una planta que aún no opera.
- **Probar tres cosas a la vez con una persona** significa que ninguna se prueba bien y ninguna falla se atribuye con claridad.

### Lo que sí propongo: probar el **modelo**, no el software

| Empresa | Qué se prueba | Cómo |
|---|---|---|
| **VANSAM** | El **producto completo** | Software real, uso diario, 14 días de criterio de cierre |
| **Café Zacarías** | Solo el **modelo de datos** | "Modo cuaderno": planilla estructurada con las columnas exactas del modelo (lote, etapa, kg entrada, kg salida, rendimiento, costo). Cero interfaz |
| **Chocolates La Florita** | Solo el **modelo de datos** | Igual: planilla de lote, fórmula, insumos, kg producidos, merma, costo unitario |

Si la planilla del café y la del chocolate **caben en el modelo genérico de `transformación`** sin torcerlo, el diseño está validado. Si no caben, acabas de descubrir gratis y en una semana algo que te habría costado tres meses de código.

> Esto también responde una pregunta que el ticket no hace: **la validación arquitectónica no necesita software.** Necesita datos reales en la forma correcta.

### Orden recomendado

1. **VANSAM** — producto real (semanas 1–8)
2. **Chocolates La Florita** — segunda vertical, mínima (semanas 9–13), porque produce lotes con frecuencia semanal/mensual: ciclo de aprendizaje corto
3. **Café Zacarías** — última, porque el ciclo es anual y está atado a la planta

**Contraintuitivo a propósito:** el café es tu apuesta estratégica más grande, y por eso mismo debe ser el último en recibir software. No se construye la pieza más cara sobre el modelo menos probado.

---

## 10. ¿Qué necesitamos medir desde esta semana?

**Antes de escribir una línea de código nuevo.** Y a mano si hace falta.

**El argumento más fuerte de este documento:** si no capturas la línea base *ahora*, nunca vas a poder demostrar que IQ GROWTH sirvió. Y sin esa demostración, IQ GROWTH no es vendible a nadie — ni a un cliente, ni a un socio, ni a un banco. **La línea base vale más que cualquier funcionalidad del trimestre.**

### VANSAM — diario, desde el lunes

| Métrica | Por qué | Fuente hoy |
|---|---|---|
| Ventas totales (Bs) | Base de todo | Caja |
| N.º de tickets | Separa "vendí más" de "cobré más caro" | Conteo |
| **Ticket promedio** | Métrica objetivo directa | Cálculo |
| Mix por producto (unidades) | Qué sostiene el negocio | POS |
| Margen bruto por producto | Vender más ≠ ganar más | Costeo manual |
| Ventas por franja horaria | Decide horarios y personal | Registro |
| Quiebres de stock (¿qué faltó?) | **Venta perdida invisible** | Cuaderno del encargado |
| Merma (masa, insumos) | Fuga silenciosa de margen | Cierre |
| Diferencia de caja | Salud del control | Arqueo |
| Clientes identificados por teléfono | Base de toda fidelización futura | POS |
| % de compra repetida a 30 días | El indicador que más importa a mediano plazo | Cálculo mensual |

### Café Zacarías — por lote

Kg entrada y salida por etapa · rendimiento (%) · costo acumulado por kg en cada etapa · precio de venta por canal (local vs. exportación) · días de proceso.

### Chocolates La Florita — por lote

Kg/unidades producidas · merma · costo unitario real vs. teórico · rotación por punto de venta · devoluciones/vencimientos.

### Métrica única de gobierno para el grupo

**Margen bruto semanal por empresa.** Una sola cifra, cada lunes, para las tres. Si el sistema no puede producir esa cifra, el sistema no está sirviendo para el objetivo declarado.

---

## 11. Funcionalidades por impacto comercial

### 11.1 ¿Qué aumenta ventas directamente?

Advertencia honesta: **la mayoría del software no aumenta ventas.** Lo que aumenta ventas es no quedarse sin lo que más se vende, cobrar rápido, y que la gente vuelva.

| Funcionalidad | Impacto | Esfuerzo | ¿MVP? |
|---|---|---|---|
| **Alerta de quiebre de los 10 productos top** | Alto — cada quiebre es venta perdida y cliente perdido | Bajo | **Sí** |
| **Cobro rápido / menos cola** | Alto en horas pico | Bajo | **Sí** |
| **Reconocer al cliente por teléfono ("lo de siempre")** | Alto — convierte el pedido por WhatsApp en 30 segundos | Medio | **Sí** |
| Ajustar horarios y personal según ventas por franja | Alto | Nulo (es una decisión, no un módulo) | **Sí** |
| Pedido por WhatsApp ordenado con confirmación | Medio-alto | Medio | Fase 2 |
| Promociones con medición de resultado | Medio | Medio | Fase 2 |
| Delivery propio con costo controlado | Medio | Medio | Fase 2 |
| Tienda en línea | Bajo hoy | Alto | Aplazar |

> **Lo que probablemente sube más las ventas de VANSAM en 90 días no está en esta tabla: es un horno de pizza adecuado.** Un Challenger que no dice esto no está haciendo su trabajo.

### 11.2 ¿Qué aumenta el ticket promedio?

| Funcionalidad | Cómo funciona | Esfuerzo |
|---|---|---|
| **Sugerencia en pantalla al cobrar** | El POS muestra 2 acompañamientos del producto elegido; el cajero solo pregunta | Bajo — **mejor relación impacto/esfuerzo de todo el plan** |
| **Combos con precio ancla** | Combo levemente más caro que el producto solo, con valor percibido claro | Bajo |
| **Escalonamiento de tamaños** | Mediana/grande con diferencia de precio menor a la de costo percibido | Bajo |
| **Medir mix antes y después** | Sin medición no sabes si el upsell funcionó o el cajero lo ignoró | Bajo |
| Café y chocolate en presentaciones (250g/500g/1kg) | Sube el ticket sin más tráfico | Bajo |
| Packs de regalo / corporativo (Zacarías + La Florita juntos) | **Venta cruzada entre marcas del grupo — hoy no está en el plan** | Medio |
| Precio por franja horaria | Llena horas muertas | Medio |

> **Oportunidad que el plan no menciona:** VANSAM vende pizzas, café y chocolates. Café Zacarías y Chocolates La Florita **producen** café y chocolates. VANSAM debería ser el primer punto de venta y el laboratorio de precios de las otras dos marcas. Eso sube el ticket de VANSAM y le da ventas y retroalimentación real a las otras dos, sin construir nada. **Es sinergia de negocio disponible hoy, no de software.**

### 11.3 ¿Qué aumenta recompra y fidelidad?

| Funcionalidad | Impacto | Nota crítica |
|---|---|---|
| **Captura del teléfono en cada venta** | Máximo | **Es lo único verdaderamente urgente.** Todo lo demás de esta tabla es imposible sin esto. Cada día sin capturar es historia perdida para siempre |
| "Lo de siempre" al reconocer al cliente | Alto | Ya identificado en tus requisitos. Correcto |
| Cupón de retorno con vencimiento corto | Alto | Simple, medible, sin sistema de puntos |
| Aviso a clientes sin compra en 30 días | Alto | Segmento pequeño, mensaje manual al inicio |
| Suscripción mensual de café (Zacarías) | Alto | **Es el modelo de recompra natural del café.** Ingreso recurrente sin construir SaaS |
| Reposición programada B2B (La Florita) | Alto | Llamar al punto de venta antes de que se le acabe |
| Programa de puntos formal | Medio | Caro de administrar, fácil de abandonar. **Aplazar** |
| App de clientes | Bajo hoy | Aplazar |

---

## 12. ¿Cómo evitar que la tecnología ralentice el negocio?

Reglas duras. Propongo adoptarlas como política escrita, no como buenas intenciones.

1. **El sistema nunca puede impedir una venta.** Sin internet, sin luz, sin servidor: se vende igual y se sincroniza después. Si el sistema puede bloquear el cobro, el sistema es un riesgo, no una herramienta.
2. **Regla de los 20 minutos.** Si un empleado nuevo no aprende un módulo en 20 minutos sin ti, el módulo está mal diseñado. Se rediseña, no se capacita más.
3. **Regla de los 15 segundos.** Registrar y cobrar una venta típica en menos de 15 segundos. Si un módulo nuevo sube ese tiempo, se revierte.
4. **Regla del papel en paralelo.** El cuaderno sigue durante 3 semanas después de cada lanzamiento. Se retira solo cuando los números coinciden.
5. **Regla de las 2 semanas.** Módulo que no se usa 2 semanas seguidas se apaga y se saca de la pantalla. No se "mejora": se apaga.
6. **Un responsable de datos por empresa.** Una persona con nombre. Si nadie es responsable, los datos se pudren en 30 días y las decisiones basadas en ellos son peores que no tener sistema.
7. **Nunca dos lanzamientos a la vez.** Un cambio, medir, siguiente.
8. **Ningún módulo nuevo mientras el MVP no cumpla su definición de terminado.**
9. **Respaldo diario automático y exportación en formato neutro.** Probado restaurándolo al menos una vez.
10. **El dueño no diseña la pantalla del cajero.** Tú quieres 40 campos; el cajero necesita 3. Gana el cajero.

---

## 13. Riesgos de experiencia de usuario

| Riesgo | Por qué es real aquí | Mitigación |
|---|---|---|
| **Diseñar para el dueño, no para el operario** | Tú entiendes el sistema completo; el cajero tiene 40 segundos y las manos con harina | Botones grandes, 3 campos, cero texto libre en caja |
| **Rotación alta de personal** | Está documentada en VANSAM. Cada persona nueva reaprende todo | El sistema debe ser aprendible sin manual. La rotación es un requisito de diseño, no un accidente |
| **Conectividad** | El Alto variable; **la finca en Teoponte casi con certeza sin internet estable** | Funcionamiento sin conexión obligatorio. Para la finca: captura sin conexión o en papel, carga posterior |
| **Captura del teléfono percibida como molestia** | El cliente con prisa no quiere dar datos | Pedirlo solo en delivery y en pedidos por WhatsApp, donde es natural |
| **Datos falsos** | Bajo presión, el operario pone cualquier cosa para avanzar | Menos campos obligatorios, valores por defecto, validación al momento |
| **El módulo de inventario abandonado en la semana 3** | Es el fracaso más común y más predecible de todo el proyecto | Solo 15–20 insumos críticos. Nunca inventario total al inicio |
| **Pantallas pensadas para escritorio usadas en celular** | La operación real ocurre en celular | Diseñar primero para celular |
| **Fatiga de alertas** | Demasiadas notificaciones = ninguna se lee | Máximo 3 alertas activas por rol |

---

## 14. Riesgos operativos

| # | Riesgo | Severidad | Mitigación propuesta |
|---|---|---|---|
| R1 | **Una sola persona es CEO, product, desarrollador y soporte.** Ninguna arquitectura resuelve esto | **Crítica** | Recortar alcance hasta que quepa en una persona. Es la razón principal de este documento |
| R2 | **Seguridad actual insuficiente** (contraseña incrustada, sin usuarios individuales) | **Crítica** | Corregir en las primeras 2 semanas, antes que cualquier módulo nuevo |
| R3 | **Sin línea base medida**, IQ GROWTH nunca podrá probar que funciona | **Crítica** | Empezar a medir esta semana, a mano |
| R4 | **Propiedad del código y de los datos no definida** (VANSAM 40/60) | Alta | Documento de propiedad: IQ GROWTH es de IQHOLDING; VANSAM es licenciatario |
| R5 | **La planta industrial puede consumir todo el capital y la atención** | Alta | Que el plan de software no dependa de la planta |
| R6 | **Estacionalidad del café: una sola oportunidad de aprender al año** | Alta | Validar el modelo con planilla antes de la cosecha, no con software durante |
| R7 | **Obligación de facturación electrónica no verificada** | Alta | Verificar esta semana. Puede reordenar todo el plan (P1) |
| R8 | **Pérdida de datos / sin restauración probada** | Alta | Respaldo diario + prueba de restauración mensual |
| R9 | **Sueldos por debajo del mínimo** — exposición legal y causa estructural de rotación | Alta | Revisar estructura de costos del restaurante. No es un problema de software (C8) |
| R10 | **Dependencia de proveedor único** (Firebase/Netlify): sin contrato, sin portabilidad probada | Media | Exportación diaria en formato neutro |
| R11 | **Costos de infraestructura que crecen con el uso** | Media | Vigilar el costo por transacción desde el mes 1 |
| R12 | **VANSAM sin horno ni espresso**: el laboratorio no puede producir el experimento | Alta | Resolver equipamiento antes de medir el efecto del software (C5) |

---

## 15. Base de datos: no la elijo, pero fijo las restricciones

**Cumplo la instrucción: no cierro la decisión.** Pero una decisión "abierta" que ya está tomada de facto es la peor de las dos opciones. Así que en vez de elegir motor, propongo fijar los **requisitos que cualquier opción debe cumplir**, y una forma de mantener la decisión genuinamente reversible.

### Restricciones que la elección debe satisfacer

1. **Operación sin conexión con sincronización posterior.** *Esta es la restricción más exigente y no aparece en la lista original del ticket.* Es la que más reduce las opciones viables.
2. **Alcance multi-clave obligatorio** (`empresa_id` + `sucursal_id`) aplicado en la capa de acceso, no en cada consulta suelta.
3. **Registro de auditoría inmutable**, con autor y momento, para anulaciones, descuentos y ajustes de inventario.
4. **Integridad en operaciones de inventario.** Una transformación con 5 insumos se aplica completa o no se aplica. Una entrada a medias corrompe el costeo para siempre.
5. **Consultas históricas agregadas** (ventas por producto por mes) sin costo desproporcionado.
6. **Costo predecible** con el volumen previsto a 24 meses.
7. **Exportación completa y portabilidad probada.**

### Cómo mantener la decisión realmente abierta

- **Ninguna pantalla habla con la base de datos directamente.** Todo pasa por una capa de acceso a datos con nombres del negocio (`registrarVenta`, `aplicarTransformacion`), no de la tecnología.
- **El modelo de dominio se define primero en papel**, sin sintaxis de ningún motor.
- **Exportación diaria completa** a formato neutro desde el día 1. Mientras exista esa exportación, cambiar de motor es un proyecto de semanas, no de meses.

**Recomendación de proceso, no de producto:** haz que la decisión de motor sea explícita y fechada, evaluada contra las siete restricciones de arriba, en el **día 45** — cuando el modelo de dominio ya esté validado por el uso real. Decidirla antes es adivinar; decidirla después es pagar el costo de migrar datos vivos.

---

## 16. Recomendación de trabajo para los próximos 90 días

Tres bloques. **Cada bloque tiene una puerta de salida: si no se cumple, no se avanza.**

### Bloque 1 — Días 1 a 21: medir y asegurar (casi sin construir)

Objetivo: tener línea base y cerrar el agujero de seguridad. **La tentación de saltarse esto es exactamente el error que este documento intenta evitar.**

| # | Tarea | Responsable |
|---|---|---|
| 1 | Verificar obligación de facturación electrónica / SIAT para cada empresa | IQ |
| 2 | Definir y empezar a registrar las 11 métricas de VANSAM (a mano si hace falta) | Encargado VANSAM |
| 3 | Corregir seguridad: usuarios individuales, roles, sacar la contraseña del HTML | IQ |
| 4 | Activar bitácora de auditoría (anulaciones, descuentos, ajustes) | IQ |
| 5 | Respaldo diario + **una prueba de restauración real** | IQ |
| 6 | Documentar propiedad de IQ GROWTH (IQHOLDING dueño, VANSAM licenciatario) | IQ |
| 7 | Escribir el modelo de dominio en papel, con la abstracción `transformación` | IQ |
| 8 | Planillas "modo cuaderno" para Café y Chocolate, con las columnas del modelo | IQ |
| 9 | Decisión de equipamiento de VANSAM (horno/espresso): costo vs. retorno estimado | IQ + Samira |

**Puerta 1:** hay 14 días de métricas reales de VANSAM + seguridad corregida + respaldo probado.

---

### Bloque 2 — Días 22 a 60: MVP en VANSAM

Objetivo: que VANSAM opere con el MVP completo y que los números sean confiables.

| # | Tarea |
|---|---|
| 10 | Construir/consolidar los 9 módulos del MVP (sección 5) |
| 11 | Funcionamiento sin conexión con sincronización posterior — **no negociable** |
| 12 | Captura de teléfono del cliente en delivery y WhatsApp, con "lo de siempre" |
| 13 | Sugerencia de acompañamiento en pantalla al cobrar (upsell) |
| 14 | Alerta de quiebre de los 10 productos top |
| 15 | Tablero diario automático |
| 16 | Operación en paralelo con cuaderno durante 3 semanas |
| 17 | Capacitación con la regla de los 20 minutos, medida con cronómetro |
| 18 | Registrar Café y Chocolate en modo cuaderno, ≥4 lotes cada uno |
| 19 | **Día 45: decisión explícita y fechada de motor de base de datos**, contra las 7 restricciones |

**Puerta 2:** se cumplen los 4 criterios de "terminado" (sección 5) durante 14 días seguidos.

---

### Bloque 3 — Días 61 a 90: probar el efecto y abrir la segunda vertical

Objetivo: demostrar con números si el sistema sirvió, y validar que el modelo aguanta una segunda vertical.

| # | Tarea |
|---|---|
| 20 | **Comparación antes/después**: ventas, ticket promedio, margen, quiebres, % recompra |
| 21 | Un experimento comercial medido (cupón de retorno o combo), con grupo de comparación |
| 22 | Segunda vertical mínima: **Chocolates La Florita** — lotes, fórmula, costo, merma. Nada más |
| 23 | Verificar que las planillas del café caben en el modelo `transformación`; corregir el modelo si no |
| 24 | Suscripción mensual de café: prueba manual con 10 clientes. Sin software |
| 25 | Venta cruzada: café Zacarías y chocolates La Florita como productos de VANSAM, con precio y margen medidos |
| 26 | Informe de decisión: ¿IQ GROWTH tiene caso como producto externo? Con datos, no con intuición |

**Puerta 3:** existe un antes/después medido. Si el efecto no se puede demostrar, **el problema no es que falten módulos** — es que el sistema no está atacando la palanca correcta, y hay que rediseñar la estrategia antes de seguir construyendo.

---

### Lo que NO va a pasar en estos 90 días (dicho explícitamente)

Multiempresa con interfaz · multisucursal · multirubro configurable · motor de módulos · contabilidad · exportación de café · trazabilidad de finca · e-commerce · app móvil · marketplace B2B · IA · primer cliente externo pagando.

**Si algo de esta lista entra al trimestre, algo del MVP sale. No hay capacidad para ambos.**

---

## 17. Nivel de confianza

# **72 %**

**Desglose honesto:**

| Componente | Confianza | Razón |
|---|---|---|
| Diagnóstico de sobreingeniería | **90%** | La evidencia es inequívoca: 8 adjetivos de ERP maduro + un equipo de una persona |
| Contradicciones detectadas (C1–C9) | **88%** | Salen del propio material, no de suposiciones |
| Recomendación de secuenciar en vez de paralelizar | **85%** | La estacionalidad del café es un argumento estructural, no de opinión |
| "Medir antes de construir" | **90%** | Sin línea base no hay forma de evaluar nada, ni de vender el producto después |
| Corte universal / vertical y apuesta por `transformación` | **75%** | Sólido conceptualmente, pero no lo he validado contra tus procesos reales de tueste y producción |
| MVP propuesto (los 9 módulos) | **70%** | Depende de cuánto del POS v9 sea reutilizable, que no he visto |
| Plan de 90 días | **60%** | Depende críticamente de S1 (equipo), del resultado de la verificación SIAT y de tu disponibilidad real de horas |
| Juicio sobre IQ GROWTH como SaaS externo | **65%** | Mi aritmética de churn es sólida; el mercado boliviano de SaaS para PyMEs no lo conozco a fondo |

**Qué subiría la confianza a 85%+:** respuestas a las preguntas de la sección 18, ver el código actual del POS v9, y dos semanas de datos reales de VANSAM.

---

## 18. Preguntas que necesito respondidas (no las voy a inventar)

**P1 — Facturación electrónica / SIAT: ¿VANSAM, Café Zacarías y Chocolates La Florita están obligadas hoy a emitir factura electrónica?** ¿Alguna ya emite? Esta es **la pregunta más urgente del documento**: si la respuesta es sí, sube a prioridad 1 y reordena el trimestre completo.

**P2 — Equipo.** ¿Eres tú solo el que desarrolla? ¿Cuántas horas semanales reales puedes dedicar? ¿Hay presupuesto para contratar?

**P3 — Volumen actual de VANSAM.** ¿Cuántas ventas al día y qué ticket promedio, aproximadamente? Sin esto no puedo dimensionar nada.

**P4 — Reutilización.** ¿El POS v9 es la base sobre la que se construye IQ GROWTH, o IQ GROWTH se escribe de nuevo? El plan no lo dice y cambia todo el cronograma.

**P5 — Café y Chocolate hoy.** ¿Hay ventas reales? ¿Cuántos kg al mes? ¿A quién?

**P6 — Planta de Senkata.** ¿Fecha realista de operación? ¿Está financiada?

**P7 — Propiedad.** ¿Está acordado con Samira que IQ GROWTH y los datos de clientes de VANSAM son de IQHOLDING?

**P8 — Presupuesto.** ¿Cuánto puedes gastar al mes en infraestructura y herramientas?

**P9 — Sistema actual del café y chocolate.** ¿Se registra algo hoy — cuaderno, planilla, nada?

**P10 — Definición de éxito a 90 días.** Si dentro de 90 días esto salió perfecto, ¿qué número específico habría cambiado? Si no puedes responder esto con una cifra, el proyecto no tiene criterio de éxito y ningún plan lo va a arreglar.

---

## Resumen ejecutivo en cinco frases

1. Estás construyendo cuatro productos y llamándolos uno; separa el ERP interno del SaaS vendible antes de escribir más código.
2. Los ocho requisitos describen un ERP maduro y el objetivo declarado es vender más — son incompatibles a 90 días; gana el objetivo.
3. Mide la línea base esta semana y arregla la seguridad, antes de construir cualquier módulo nuevo.
4. Prueba el producto solo en VANSAM; prueba el *modelo* de Café y Chocolate con planillas, no con software.
5. Y arregla el horno antes de arreglar el software: ninguna de las dos cosas vende pizzas si la otra está rota.

---

*Documento preparado como revisión crítica independiente. No refleja ni consulta el trabajo de otros integrantes del AI Council. Su propósito es señalar riesgos y contradicciones, no aprobar el plan.*
