# IQG-100 — Handoff Claude: Daily Decision Engine Challenge

**Estado:** listo para challenge externo; sin implementación.

## Contexto autosuficiente

El primer producto de IQ GROWTH debe responder:

> ¿Cómo está mi negocio frente a su objetivo económico y cuál es la acción concreta más útil que debo ejecutar ahora?

No es POS, dashboard, chatbot, ERP ni asesor legal.

### Estado económico

- `EN_OBJETIVO`
- `BAJO_OBJETIVO`
- `DATOS_INSUFICIENTES`

Usa margen de contribución, objetivo de cobertura y brecha/excedente estimado.

No llama `ganancia neta` ni `utilidad distribuible` a esos cálculos.

### Calidad

Cada cálculo declara `DATA_FRESHNESS`, `DATA_COMPLETENESS`, `DATA_CONFIDENCE` y supuestos.

Con confianza baja, prioriza corregir datos antes que dar una recomendación económica fuerte.

### NEXT_BEST_ACTION

Solo una acción visible por defecto.

Categorías iniciales:
- recuperación de clientes;
- mix/producto;
- disponibilidad/faltante;
- continuidad operacional;
- capacidad/flujo;
- acción comercial local simple;
- precio/promoción solo con aprobación explícita.

Filtro previo: datos suficientes, acción ejecutable, medible, reversible cuando sea posible, sin alto impacto jurídico/laboral/fiscal/societario.

Priorización por bandas:
1. elegibilidad/seguridad;
2. impacto económico ALTO/MEDIO/BAJO;
3. confianza ALTA/MEDIA/BAJA;
4. urgencia HOY/72H/SEMANA;
5. esfuerzo BAJO/MEDIO/ALTO;
6. reversibilidad;
7. no repetición sin nueva evidencia.

Puede responder `NO_RECOMMENDATION_WITH_REASON`.

### Tarjeta de acción

`PROBLEMA → EVIDENCIA → ACCIÓN → IMPACTO ESPERADO → COSTO/ESFUERZO → CONFIANZA`

Estados:
`PROPOSED → APPROVED | REJECTED → EXECUTED → MEASURED → LEARNED`, más `EXPIRED`, `CANCELLED`, `INCONCLUSIVE`.

### Pantalla primera capa

Debe entenderse en <10 segundos:
- estado económico;
- brecha estimada;
- objetivo;
- una acción;
- impacto;
- esfuerzo;
- confianza;
- frescura de datos;
- botón preparar/ejecutar con aprobación humana.

No debe mostrar diez gráficos ni diez recomendaciones.

### Día 0 VANSAM

Ninguna cifra histórica es baseline automático.

Inputs a revalidar:
- calendario operativo;
- costos fijos;
- ventas recientes;
- método de costo variable;
- productos/categorías;
- clientes si se usarán acciones de recuperación;
- tiempos/capacidad si existe dato;
- faltantes;
- confusores.

Estados del dato:
`OBSERVED_CURRENT`, `DOCUMENT_SUPPORTED`, `OWNER_CONFIRMED`, `SYSTEM_CALCULATED`, `ESTIMATED`, `STALE`, `UNKNOWN`.

Gate:
- `READY_FOR_PILOT`
- `READY_WITH_LIMITATIONS`
- `NOT_READY`

En `NOT_READY`, la primera acción es cerrar la brecha de datos, no hacer marketing.

### Piloto

30 días. Separa Product Value Gate de Business Outcome Gate.

Product Value provisional:
- consulta recurrente;
- completitud >=90% para cálculo mínimo;
- >=8 recomendaciones accionables;
- >=5 ejecutadas/aprobadas;
- >=3 decisiones influidas;
- time-to-value <=15 minutos;
- ausencia del resumen se nota;
- una señal comercial externa fuerte.

No afirmar causalidad estadística fuerte.

## Misión de Claude

Ataca el producto, no la seguridad del Core ni la legislación.

Responde:

1. ¿La pregunta central es suficientemente valiosa para abrir el producto todos los días?
2. ¿El estado `EN_OBJETIVO / BAJO_OBJETIVO / DATOS_INSUFICIENTES` es demasiado simplista?
3. ¿La brecha de cobertura puede inducir decisiones malas aunque el cálculo sea correcto?
4. ¿Qué falla en mostrar solo una `NEXT_BEST_ACTION`?
5. ¿Cuándo debería haber `NO_RECOMMENDATION_WITH_REASON`?
6. ¿Las bandas de impacto/confianza/urgencia/esfuerzo son suficientes o esconden arbitrariedad?
7. ¿Cómo evitar recomendaciones repetitivas o triviales?
8. ¿Qué haría que Samira deje de abrirlo después de una semana?
9. ¿Qué información debería aparecer obligatoriamente en la primera pantalla y qué sobra?
10. ¿Cómo demostrar en 30 días que es mejor que ChatGPT + Excel + POS?
11. ¿Cuál es el failure mode más probable en VANSAM?
12. ¿Qué capacidad única añadirías y cuál eliminarías del MVP?

Para cada hallazgo:
- ID;
- severidad CRITICAL/HIGH/MEDIUM/LOW;
- problema;
- consecuencia;
- corrección;
- antes del piloto / diferible.

Entrega final:
A. pantalla ideal revisada;
B. algoritmo de priorización mínimo revisado, sin pseudociencia;
C. 5 razones por las que el operador abandonaría el producto;
D. 5 señales tempranas de product-market value;
E. una prueba de 30 días corregida;
F. qué eliminar del MVP;
G. veredicto exactamente uno:

`DAILY_ENGINE_STRONG`
`DAILY_ENGINE_NEEDS_REFINEMENT`
`DAILY_ENGINE_NOT_USEFUL_ENOUGH`
