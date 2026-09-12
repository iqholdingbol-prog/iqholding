# IQG-100 — Síntesis ChatGPT del challenge de Claude sobre Daily Engine

**Fecha:** 2026-09-12
**Autoridad arquitectónica:** ChatGPT
**Fuente:** `2026-09-12_claude_daily_engine_challenge.md`

## Veredicto de síntesis

`ACCEPT_WITH_CORRECTIONS`

Claude encuentra debilidades reales de producto, pero mezcla hallazgos estructurales sólidos con cifras y umbrales aún no verificados en VANSAM.

## Aceptado

### 1. Dos contextos de uso, un solo motor

IQ GROWTH debe diferenciar la experiencia de:
- operador presente: acción ejecutable ahora o siguiente ventana;
- dueño remoto: estado, tendencia, excepciones y acciones aprobadas/rechazadas.

No son dos productos ni dos motores.

### 2. Tendencia por encima de semáforo estático

`BAJO_OBJETIVO`/`EN_OBJETIVO` se conserva como contexto, pero no debe ser el titular permanente.

El titular debe priorizar cambio/tendencia respecto a un periodo comparable. Para VANSAM se probará una ventana móvil configurable; 7 días es hipótesis inicial, no regla universal.

### 3. Separar cobertura y objetivo

- `COBERTURA_MINIMA`: piso económico estimado necesario para cubrir costos configurados.
- `OBJETIVO_DUENO`: meta económica/operativa declarada y versionada por el dueño.

Nunca confundir punto de equilibrio con éxito empresarial.

### 4. Acción con ventana de ejecución

Toda acción debe incluir:
- `execution_window_start`;
- `execution_window_end` o condición de oportunidad;
- responsable;
- caducidad cuando corresponda.

Una recomendación no ejecutable en su contexto temporal no compite por `NEXT_BEST_ACTION`.

### 5. Impacto auditable

Las etiquetas visuales pueden existir, pero toda recomendación debe mostrar debajo:
- cálculo o rango económico;
- unidad del negocio;
- datos que lo sostienen;
- supuestos;
- esfuerzo aproximado;
- confianza explicada.

### 6. Repetición y enfriamiento

Cada categoría/segmento/destinatario debe tener cooldown y requerir nueva evidencia antes de repetirse.

Rechazos repetidos de una misma categoría deben degradar su prioridad y generar aprendizaje de preferencia, no insistencia automática.

### 7. Datos faltantes como microacción

Si falta un dato crítico, no mostrar solo `DATOS_INSUFICIENTES`.

Mostrar la menor acción necesaria para recuperar capacidad de decisión:

`Falta actualizar costo X — estimado 20–60 segundos`.

### 8. Observación antes/después sin falsa causalidad

El MVP conserva medición posterior, pero cambia el lenguaje:
- `OUTCOME_OBSERVED`;
- periodo previo/posterior;
- confusores;
- `ATTRIBUTION = UNDETERMINED/LOW_CONFIDENCE` por defecto.

No se declara que la acción causó el cambio.

### 9. Simplificar estado de acción en UI

En interfaz MVP usar:
`PROPUESTA → APROBADA → HECHA → DESCARTADA`.

El modelo de datos puede preservar mayor riqueza detrás si no añade fricción visible.

## Modificado / rechazado

### Foto/OCR obligatoria antes del piloto — RECHAZADO COMO GATE

El problema real aceptado es `COST_DATA_FRESHNESS` y `MANUAL_INPUT_BURDEN`.

El piloto puede comenzar con cualquier captura sostenible que mantenga frescura suficiente:
- entrada rápida;
- CSV;
- POS;
- foto/OCR;
- factura electrónica;
- otra integración.

Foto/OCR sigue como hipótesis de canal de bajo esfuerzo, no prerrequisito.

### 20 acciones distintas — RECHAZADO COMO UMBRAL

No existe evidencia para fijar `>=20`.

Se medirá:
- tasa de repetición;
- porcentaje de recomendaciones nuevas/relevantes;
- agotamiento de categorías;
- utilidad percibida.

### Absence test oculto — RECHAZADO

No se retirará deliberadamente una función importante sin conocimiento dentro de un piloto controlado.

El absence test será acordado, temporal y operacionalmente seguro; puede ocultarse el objetivo exacto de medición si es ético/contractualmente correcto, pero no poner al operador en riesgo ni engañarlo materialmente.

### 10x impacto/esfuerzo — RECHAZADO COMO REGLA UNIVERSAL

Puede probarse como heurística en análisis, pero no se canoniza sin calibración real.

### Eliminar MEASURED/LEARNED totalmente — MODIFICADO

Se elimina cualquier semántica causal fuerte del MVP. Se conserva observación y aprendizaje explícitamente etiquetado como exploratorio/observacional.

### Señal comercial externa fuera del piloto — MODIFICADO

No es requisito para evaluar usabilidad diaria de VANSAM, pero sigue siendo gate separado antes de declarar validación comercial externa.

## Decisión final

El motor diario permanece válido, pero pasa de:

`ESTADO → BRECHA → ACCIÓN`

a:

`TENDENCIA + COBERTURA + OBJETIVO → CONTEXTO DEL USUARIO → UNA ACCIÓN EJECUTABLE → RESULTADO OBSERVADO`

El siguiente paso no es más teoría: construir `VANSAM BASELINE V1` y validar si la ventana móvil, el objetivo y las fuentes de acción producen señal útil con datos reales.
