Los cinco documentos no están accesibles. Pero tengo algo más valioso: **el código fuente real de V11**, que es el objeto de la migración. Voy a auditar contra la fuente de verdad en lugar de contra un plan que no puedo leer.

### ACCESO A DOCUMENTOS

No pude acceder a ninguno de los cinco documentos solicitados:

- `docs/MASTER_CONTEXT.md` — NO ACCESIBLE
- `docs/ARCHITECTURE.md` — NO ACCESIBLE
- `docs/IQG-001.3_MIGRATION_PLAN.md` — NO ACCESIBLE
- `docs/audits/V11_CODEX_AUDIT.md` — NO ACCESIBLE
- `schemas/core_schema.sql` — NO ACCESIBLE

Lo verificable es el **código fuente de V11**, que es el origen de los datos a migrar. Desafío el plan contra la fuente de verdad, no contra su descripción. Todo hallazgo abajo está verificado en el código, no inferido.

---

### 1. HISTORIA Y DATOS

**M-01 · CRITICAL · Pérdida activa de datos hoy, no en la migración**

`guardarEdicionCliente()` reconstruye el objeto cliente desde cero con 10 campos. Los campos `direccion`, `ultimoProducto`, `ultimoTamano`, `tipoPedidoFrecuente`, `alertaSatisfaccion`, `registradoQR` no están en la reconstrucción.

*Escenario:* corriges el nombre mal escrito de un cliente de delivery. Su dirección se borra. Nadie se entera.

*Consecuencia:* el snapshot que tomes para migrar ya está degradado, y sigue degradándose cada día.

*Cambio:* parche de emergencia a V11 hoy — `fbUpdate` en vez de reconstrucción. **Antes de Codex y antes del snapshot.**

**M-02 · CRITICAL · Pedido ≠ venta cobrada (confirmado)**

No existe en V11 ningún campo de pago: ni método, ni monto recibido, ni cambio, ni confirmación. `total` es una suma de precios de lista, no evidencia de cobro. No hay cierre de caja conciliable — el "Cierre de Caja" solo suma `historial`.

*Consecuencia:* si el plan mapea `pedido → venta_cobrada`, está fabricando un hecho financiero que nunca existió.

*Cambio:* todo pedido V11 debe entrar como `venta_legacy` con `payment_status = UNKNOWN` y `payment_evidence = NONE`. No debe alimentar arqueo, flujo de caja ni ingresos conciliados.

**M-03 · CRITICAL · El 100% de `historial/` dice "pendiente"**

`enviarPedidoConCliente` escribe el pedido en `pedidos/` y en `historial/`. Pero `marcarListo()` solo actualiza `pedidos/{num}/estado`. `historial/` jamás se actualiza. Además el sistema **nunca lee** `historial/` — la vista de reportes se llena desde el listener de `pedidos/`.

*Consecuencia:* `historial/` es una copia muerta y desincronizada. Si el plan lo usa como fuente de "ventas completadas", todas entran como no entregadas.

*Cambio:* declarar `pedidos/` como única fuente. Importar `historial/` solo como verificación de divergencia.

**M-04 · CRITICAL · Colisión silenciosa de número de pedido**

`numPedido = maxNum + 1`, calculado localmente desde el listener. La escritura es `fbSet('pedidos/' + numPedido, pedido)` — un `set()`, que **sobrescribe sin aviso**.

*Escenario:* caja toma pedido #47 mientras la tablet aún no recibió el evento. Ambos calculan 47. El segundo borra al primero.

*Consecuencia:* pedidos desaparecidos sin rastro. No puedes detectar cuántos perdiste porque no queda hueco en la numeración.

*Cambio:* la reconciliación no puede basarse en continuidad de `num`. Requiere conteo cruzado `pedidos` vs `historial` vs stock consumido.

**M-05 · CRITICAL · Stock histórico irreconstruible**

`descontarStock()` hace `STOCK[ing].cantidad = Math.max(0, cantidad - gramos/1000)`. No hay registro de movimiento. El `Math.max(0,...)` además **destruye la evidencia** de haber vendido sin stock registrado.

*Consecuencia:* no existe kardex. Cualquier "stock histórico" migrado sería inventado.

*Cambio:* migrar únicamente el saldo actual como **conteo físico inicial** con fecha de corte. Cero movimientos históricos. Nunca presentarlo como kardex.

**M-06 · HIGH · El margen histórico es ficción**

`calcularCosto()` usa `INSUMOS[x].pg` — el precio **de hoy**. No hay historial de precios de insumo.

*Escenario:* la caja de tomate pasó de 30 a 500 Bs. Recalculas el margen de una pizza de hace tres semanas con el precio actual.

*Consecuencia:* rentabilidad histórica fabricada. Peor: si migras estos números como hechos, envenenas la línea base contra la que medirás el crecimiento.

*Cambio:* prohibido migrar costo/margen por pedido histórico. El costeo nativo empieza el día 1 de IQ GROWTH con precios sellados por fecha.

**M-07 · HIGH · Ingresos de delivery invisibles**

`tarifaDelivery` se guarda dentro de `cliente` pero **nunca se suma a** `total`. Verificado: `total` solo acumula `precio + extraTotal` de los items.

*Consecuencia:* todo pedido delivery está subvaluado. Si migras `total` como ingreso, subestimas sistemáticamente y el error crece con el volumen de delivery.

*Cambio:* recalcular ingreso legacy como `total + cliente.tarifaDelivery`, marcado como `reconstructed = true`.

**M-08 · HIGH · Dos formatos de fecha incompatibles**

Pedidos: `toISOString()` (UTC, sin ambigüedad). Clientes: `toLocaleDateString('es-BO')` → `DD/MM/YYYY`, dependiente de locale del dispositivo.

*Consecuencia:* `primeraVisita` y `ultimaVisita` no son comparables con `pedido.hora`. Cualquier cálculo de frecuencia o recencia cruzando ambos está mal.

*Cambio:* no confiar en las fechas del objeto cliente. Reconstruir primera/última compra desde los pedidos.

**M-09 · HIGH · La clave del cliente es su teléfono**

`clienteId = 'wsp_' + numero`. Al cambiar el número, `guardarEdicionCliente` hace `remove()` + `set()` en clave nueva. Pero los pedidos históricos guardan el teléfono **copiado dentro** de `cliente.wsp`.

*Consecuencia:* cliente que cambia de número queda partido en dos identidades, y los pedidos viejos apuntan a una clave que ya no existe. Riesgo inverso: dos personas que compartieron un teléfono (familiar, del local) se fusionan en una sola.

*Cambio:* generar `person_id` sintético. El teléfono pasa a ser atributo, nunca identidad. **No fusionar automáticamente por teléfono** — marcar candidatos para revisión humana.

---

### 2. PRODUCTO

**M-10 · HIGH · `ultimoProducto` no es una preferencia**

Se asigna `pedidoItems[0].nombre` — el primer item que Samira tocó en pantalla. No es el más pedido, ni el más caro, ni una elección del cliente.

*Consecuencia:* la función "Lo de siempre" sugiere un dato arbitrario. Migrarlo como `producto_favorito` convierte ruido de interfaz en hecho de negocio.

*Cambio:* descartar el campo. Recalcular preferencia real desde los items de los pedidos, y solo con 3+ compras.

**M-11 · HIGH · `ticketPromedio` sesgado**

`totalGastado` solo acumula cuando se ingresó teléfono. Un cliente que compró 10 veces pero dio su número 3 veces tiene `visitas: 3`.

*Consecuencia:* frecuencia y gasto subestimados de forma desigual entre clientes. Inutilizable para segmentación.

*Cambio:* recalcular desde pedidos. Marcar cada cliente con `cobertura_identificacion` para saber cuánto confiar en su historia.

**M-12 · HIGH · Dos fuentes de verdad para precios y stock**

`localStorage` (`vs_costos`, `vs_stock`) y Firebase (`config/`). `cargarLocal()` corre al arranque; `fbOnce('config')` llega después y pisa — pero solo las claves que existan en Firebase.

*Escenario:* la PC de caja cambia el precio del queso sin internet. La tablet lo cambia con internet. Nadie sabe cuál ganó.

*Consecuencia:* el stock y los precios que migres dependen de **qué dispositivo abras**.

*Cambio:* antes del corte, congelar y comparar `localStorage` de cada dispositivo contra Firebase. Documentar divergencias. Decisión humana sobre cuál prevalece.

**M-13 · MEDIUM · Productos identificados por string**

Los items guardan `nombre` y un `id` corto (`'nb'`, `'4q'`), pero `RECETAS` y `PV` se indexan **por nombre**. `"Pizza Vansam ⭐"` lleva un emoji. Mitad y mitad guarda `id: 'mitad'` con nombre compuesto `"1/2 X + 1/2 Y"`.

*Consecuencia:* si renombras o quitas un producto, los pedidos históricos quedan huérfanos. El emoji rompe el match.

*Cambio:* crear catálogo legacy congelado con SKU sintético por nombre exacto encontrado. Nunca reconciliar por nombre en runtime.

**M-14 · MEDIUM · Satisfacción huérfana**

`satisfaccion/{timestamp}` guarda `cliente` pero **no** el número de pedido.

*Consecuencia:* no puedes responder "qué pedido recibió 2 estrellas". El NPS legacy no es accionable.

*Cambio:* archivar como serie temporal agregada. No migrar como métrica por pedido.

**M-15 · MEDIUM · No existe cancelación**

Los únicos estados son `pendiente` y `listo`. Un pedido anulado verbalmente queda `pendiente` para siempre o se marca `listo` sin haberse entregado.

*Consecuencia:* pedidos viejos en `pendiente` son ambiguos: ¿se perdieron, se cancelaron, o cocina olvidó tocar el botón? **No inferir.**

*Cambio:* importar como `estado_legacy = INDETERMINADO`. Prohibido mapear a "cancelado" o "entregado".

**M-16 · MEDIUM · Reloj del dispositivo**

`hora: new Date().toISOString()` — cliente, no servidor. La tablet de cocina con hora desfasada produce pedidos con timestamps imposibles.

*Cambio:* validar monotonía contra `num`. Marcar anomalías, no corregirlas silenciosamente.

---

### 3. OPERACIÓN Y CUTOVER

**M-17 · CRITICAL · Idempotencia falsa**

Si el importador usa `num` como clave de idempotencia, M-04 lo rompe: dos pedidos distintos pudieron compartir número, y el que sobrevivió borró al otro. Reimportar no reproduce el mismo resultado si alguien tocó V11 entre corridas.

*Cambio:* clave de idempotencia compuesta — `hash(num + hora + total + items)`. Detectar y reportar colisiones, no resolverlas automáticamente.

**M-18 · HIGH · El snapshot no captura estado local**

Un snapshot de Firebase no ve `localStorage` de la PC de caja ni de la tablet. Tampoco ve un pedido en el carrito sin enviar.

*Cambio:* el corte debe ser **físico**: con el local cerrado, carrito vacío, y exportación manual de `localStorage` de cada dispositivo antes de poner V11 en solo-lectura.

**M-19 · HIGH · V11 no tiene modo solo-lectura**

No existe interruptor. "Read-only" significaría no abrir la app — dependiendo de que nadie tenga la URL en un favorito.

*Cambio:* implementar bandera `sistema_bloqueado` en Firebase que V11 lea y que deshabilite "ENVIAR A COCINA". Sin esto no hay ventana de corte real.

**M-20 · MEDIUM · Rollback sin punto de retorno**

`fbRemove` en edición de clientes ya ejecuta borrados destructivos. No hay papelera ni versionado.

*Cambio:* export JSON completo de RTDB, guardado fuera de Firebase, antes de cualquier operación.

---

### 4. ARQUITECTURA UNIVERSAL

**M-21 · HIGH · Conceptos de pizzería incrustados en estructuras que serían del núcleo**

Pertenecen al **vertical VANSAM**, no al core:

| Concepto en V11 | Dónde vive hoy | Dónde debe vivir |
| --- | --- | --- |
| `sz` = P/M/G | campo del item | atributo de variante, vertical |
| `toppings[]` | campo del item | modificadores, vertical |
| `RECETAS` por nombre de pizza | objeto global | BOM/receta, módulo producción |
| `esMitadMitad`, `id:'mitad'` | item | composición de producto, vertical |
| `tipo` = salon/llevar/delivery | dentro de `cliente` | canal de venta, **core** — pero como catálogo configurable, no enum fijo |
| `estado` = pendiente/listo | pedido | workflow de preparación, vertical restaurante |
| `tarifaDelivery` | dentro de `cliente` | **error de modelado** — es un cargo de la venta, no un atributo de la persona |

`tarifaDelivery` dentro del objeto cliente es el caso más claro de contaminación: un cargo variable por transacción guardado como si fuera propiedad de una persona.

---

### A. TOP 10 RIESGOS

1. **M-01** — V11 destruye direcciones hoy; el snapshot nace degradado
2. **M-02** — pedidos sin evidencia de cobro convertidos en ingresos
3. **M-04** — pedidos sobrescritos e indetectables
4. **M-03** — `historial/` muerto usado como fuente de verdad
5. **M-05** — stock histórico inventado por ausencia de kardex
6. **M-06** — márgenes históricos calculados con precios de hoy
7. **M-12** — localStorage divergente entre dispositivos
8. **M-07** — ingresos de delivery sistemáticamente perdidos
9. **M-09** — fusión o partición incorrecta de clientes por teléfono
10. **M-19** — imposibilidad de congelar V11 durante el corte

### B. MIGRAR AL CORE

Pedidos (`num`, `hora`, `items[]`, `total`, `nota`) como `venta_legacy` con `payment_status=UNKNOWN`; identidad de clientes (nombre, teléfono, zona, dirección, cumpleaños) con `person_id` nuevo; catálogo legacy congelado con SKU sintético; saldo de stock actual como conteo físico inicial; precios de venta vigentes al corte.

### C. ARCHIVAR, NO IMPORTAR

`historial/` completo (como evidencia de divergencia); `satisfaccion/` (serie agregada); `ultimoProducto` / `ultimoTamano`; `ticketPromedio` y `visitas` precalculados; `alertaSatisfaccion`; dumps de `localStorage` por dispositivo; el HTML de V11 como artefacto de auditoría.

### D. DESCARTAR

Solo dos, con justificación: **estados `pendiente` de pedidos antiguos** — no descartar el registro, descartar la *interpretación* del estado. Y **`config/stock` como histórico** — el saldo se conserva como conteo inicial, pero cualquier intento de derivar movimientos pasados debe descartarse por imposibilidad matemática.

### E. DECISIONES QUE REQUIEREN CEO

1. **¿Los pedidos legacy cuentan como ventas cobradas?** Afecta toda la línea base contra la que medirás crecimiento. Mi recomendación: no.
2. **¿Se para Vansam para el corte?** Sin ventana de cierre real, la reconciliación es aproximada. Cuesta unas horas de venta.
3. **¿Clientes con mismo teléfono se fusionan?** Irreversible. Recomiendo revisión manual — son pocos.
4. **¿La línea base de crecimiento arranca en cero el día 1 de IQ GROWTH, o se presenta continuidad con V11?** Estratégico: define si tu caso de éxito para vender a terceros es honesto o cuestionable.

### F. VEREDICTO

**PLAN UNSAFE**

Dos razones independientes, cada una suficiente:

No pude leer el plan — ningún documento fue accesible — y no certifico lo que no verifico.

Y más grave: **V11 está perdiendo datos en producción en este momento.** Cada edición de cliente borra su dirección. Cualquier plan de migración, por bueno que sea, opera sobre una fuente que se degrada mientras se planifica. El primer movimiento no es migrar — es detener la hemorragia con un parche a V11 hoy, tomar el export completo, y recién entonces evaluar el plan con los cinco documentos a la vista.