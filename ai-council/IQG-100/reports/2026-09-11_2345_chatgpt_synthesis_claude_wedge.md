# IQG-100 — Síntesis ChatGPT del Product Wedge Challenge de Claude

**Fecha:** 2026-09-11  
**Rol:** Chief Architect & AI Council Coordinator  
**Fuente revisada:** `ai-council/IQG-100/reports/2026-09-11_2335_claude_product_wedge.md`  
**Estado:** decisión de producto previa a implementación

---

## 1. Conclusión

Se acepta el veredicto de Claude en lo esencial:

**PRODUCT WEDGE TOO BROAD**.

El primer Growth Engine no debe vender tres pilares independientes (`proteger margen + retención + experimentos`). Debe resolver una sola pregunta recurrente del dueño y derivar una acción concreta.

### Wedge adoptado conceptualmente

**¿Estoy cubriendo el objetivo económico del negocio y cuál es la acción más útil ahora?**

La formulación evita dos errores:
- no llama `ganancia diaria` a una estimación incompleta;
- no ata el producto a pizzas ni restaurantes.

---

## 2. Hallazgos aceptados

### A1 — Un solo wedge antes de múltiples motores

Aceptado.

Los motores de margen, recompra, adquisición u operación pueden existir por debajo, pero el MVP no debe presentarlos como productos paralelos. Deben competir por producir una sola `NEXT_BEST_ACTION` ligada al objetivo económico.

### A2 — Experimentos no son propuesta comercial inicial

Aceptado con modificación.

El rigor de medición sigue siendo constitucional dentro de IQ GROWTH, pero `experimentos medibles` deja de ser pilar visible del MVP.

En negocios de bajo volumen se usará inicialmente:
- registro de cambio/intervención;
- baseline simple;
- antes/después o periodos comparables;
- confusores conocidos;
- confianza BAJA/MEDIA/ALTA;
- prohibición de afirmar causalidad fuerte sin evidencia.

El sistema puede evolucionar a A/B o métodos más rigurosos cuando el volumen lo soporte.

### A3 — Time-to-first-value muy corto

Aceptado.

Objetivo de producto: **primer valor en <=15 minutos** para un negocio nuevo cuando las ventas estén disponibles.

Inputs mínimos del modo rápido:
- calendario/días operativos;
- costos fijos aproximados;
- ventas;
- costo variable aproximado por categoría o porcentaje;
- opcionalmente cliente/contacto.

Costeo detallado por receta/SKU queda como refinamiento progresivo, no prerequisito de activación.

### A4 — VANSAM primero, otros verticales después

Aceptado como orden de validación, no como cambio de visión.

Café Zacarías y Chocolates La Florita siguen siendo laboratorios estratégicos, pero no se implementarán simultáneamente dentro del primer MVP de IQG-100. Primero se demuestra el ciclo en VANSAM; luego se prueba portabilidad.

### A5 — Pantalla ejecutiva mínima

Aceptado.

La pantalla inicial debe responder sin interpretación:
1. estado económico respecto al objetivo;
2. brecha restante o excedente;
3. objetivo próximo;
4. una acción recomendada.

Los dashboards analíticos pueden existir como segunda capa, no como experiencia principal.

### A6 — Human-in-the-loop para acciones externas

Aceptado.

En el MVP requieren aprobación humana:
- mensajes a clientes;
- promociones;
- descuentos;
- cambios de precio;
- compras;
- cualquier acción irreversible o con impacto externo.

Cálculos, alertas y recomendaciones pueden ser automáticos.

### A7 — El verdadero problema técnico es la carga de datos

Aceptado parcialmente.

La ventaja no está en calcular punto de equilibrio: Excel puede hacerlo. El requisito estratégico es mantener datos suficientemente frescos **sin convertir al dueño en contador o digitador**.

La captura por foto de factura/nota de compra es una vía candidata, no un foso probado ni una obligación del primer MVP.

---

## 3. Hallazgos modificados o no aceptados literalmente

### M1 — No usar `gané/perdí hoy` como hecho contable

Claude propone mostrar `ganaste Bs X` por día. No se adopta literalmente.

Un prorrateo diario de costos fijos no equivale necesariamente a utilidad contable diaria. Puede haber:
- estacionalidad por día;
- costos devengados no capturados;
- compras/activos;
- depreciación;
- obligaciones laborales/fiscales;
- días cerrados;
- variación fuerte de mix.

Terminología permitida inicialmente:
- `objetivo de cobertura del periodo`;
- `margen de contribución observado`;
- `brecha de cobertura estimada`;
- `excedente sobre objetivo estimado`;
- `resultado operativo estimado`, únicamente con supuestos visibles.

### M2 — No dividir costos mensuales simplemente entre 30

El objetivo diario debe considerar días operativos y eventualmente ponderación por patrón semanal/estacional.

MVP inicial:

`objetivo_cobertura_dia = costos_fijos_periodo / dias_operativos_planificados`

Luego puede evolucionar a objetivos ponderados por día/hora con datos suficientes.

### M3 — `13 pizzas mañana` es traducción vertical, no modelo core

El core calcula una brecha económica. El vertical puede traducirla a unidades equivalentes utilizando contribución media o por mix, mostrando que es una estimación.

Ejemplo VANSAM:
`brecha Bs → pizzas equivalentes`.

Otro negocio podría mostrar:
`brecha Bs → tickets / servicios / unidades / kg / contratos equivalentes`.

### M4 — No canonizar la afirmación de “10 meses por experimento”

La conclusión general de bajo poder estadístico es razonable, pero el número exacto depende de métrica, varianza, baseline, efecto esperado, diseño y nivel de confianza.

Por tanto se adopta la regla de **no exigir experimentación formal en bajo volumen**, no el cálculo específico.

### M5 — Foto de factura no es el foso por decreto

Se adopta como hipótesis de producto:

`DATA_CAPTURE_FRICTION` es una amenaza crítica para IQ GROWTH.

Posibles soluciones futuras:
- foto/OCR;
- importación de factura electrónica cuando exista;
- integración proveedor/ERP;
- CSV;
- captura rápida asistida;
- inferencia con confirmación humana.

Debe validarse cuál reduce esfuerzo realmente en Bolivia y otros mercados.

### M6 — Retención no desaparece

No será módulo comercial inicial, pero puede producir una `NEXT_BEST_ACTION` cuando los datos demuestren que recuperar clientes es la forma más eficiente de cerrar la brecha económica.

---

## 4. Primer producto reducido

### Nombre interno provisional

**Daily Growth Control** / **Control Diario de Crecimiento**.

No es nombre comercial aprobado.

### Pregunta central

> **¿Cómo está el negocio frente a su objetivo económico y qué acción concreta conviene ejecutar ahora?**

### Salida mínima

1. margen/contribución observado del periodo;
2. objetivo de cobertura;
3. brecha o excedente estimado;
4. traducción operacional comprensible;
5. una `NEXT_BEST_ACTION` priorizada;
6. razón/evidencia;
7. acción con aprobación humana;
8. seguimiento posterior del resultado.

---

## 5. NEXT_BEST_ACTION

El MVP no necesita seis módulos visibles. Necesita un selector de acción simple.

Fuentes iniciales permitidas:
- volumen/ventas;
- mix/contribución;
- clientes inactivos si existe identidad;
- disponibilidad/faltantes simples;
- continuidad/horarios;
- acción comercial registrada.

Cada candidata recibe inicialmente:
- impacto económico estimado;
- esfuerzo/costo;
- confianza;
- urgencia;
- reversibilidad.

El sistema muestra **una acción principal**, no diez recomendaciones.

---

## 6. Prueba VANSAM 30 días corregida

La prueba separa `PRODUCT VALUE` de `BUSINESS OUTCOME`.

### Gate A — Producto

PASS provisional si:
- pantalla de cierre/estado consultada >=25 de 30 días operativos disponibles;
- datos mínimos suficientes >=90% de los días evaluados;
- >=8 recomendaciones accionables generadas;
- >=5 acciones aprobadas/ejecutadas;
- >=3 decisiones registradas que el operador reconoce que fueron influidas por IQ GROWTH;
- tiempo de primer valor en una configuración nueva simulada <=15 minutos;
- operador puede explicar el estado económico y acción sin interpretar un dashboard complejo.

### Gate B — Resultado económico

Medir, pero NO exigir causalidad fuerte:
- brecha media de cobertura antes/después;
- margen de contribución diario/semanal;
- operaciones/unidades por día;
- frecuencia de días que alcanzan objetivo;
- costos/merma evitados cuando sean verificables;
- resultado de cada acción con nivel de confianza.

### Gate C — Prueba de ausencia

Tras uso suficiente, retirar/ocultar temporalmente el resumen y evaluar si el operador lo solicita o recrea manualmente.

### Gate D — Señal comercial externa

Mostrar el producto a al menos un dueño externo compatible y medir una señal fuerte:
- intención de piloto;
- disposición a conectar datos;
- anticipo/pago;
- o compromiso verificable equivalente.

Un elogio verbal no cuenta como validación comercial.

---

## 7. Estado del ticket

Gemini validó mercado con condiciones.
Claude demostró que el wedge anterior era demasiado amplio.
ChatGPT reduce el primer producto a una pregunta central y una acción priorizada.

**SIGUIENTE:** formalizar `IQG-100_MVP_WEDGE_SPEC.md` y mantenerlo fuera de Codex hasta que IQG-001.2 cierre y el CEO apruebe el alcance del producto.

**CEO_ACTION_REQUIRED:** false para documentación; la aprobación de implementación vendrá después.
