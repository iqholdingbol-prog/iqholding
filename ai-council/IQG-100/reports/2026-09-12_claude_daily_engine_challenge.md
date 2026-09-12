# IQG-100 — Claude Daily Decision Engine Challenge

**Fecha:** 2026-09-12
**Rol:** Claude — Product & Systems Challenger
**Estado:** evidencia independiente, no canónica por sí sola

## Veredicto

`DAILY_ENGINE_NEEDS_REFINEMENT`

## Hallazgos principales

Claude identifica como riesgos principales:

1. El producto aporta información distinta a operador presencial y dueño remoto; propone diferenciar énfasis por rol sin cambiar el motor económico.
2. Un estado binario permanente `BAJO_OBJETIVO` puede perder valor informativo; propone mostrar movimiento/tendencia como titular y dejar cobertura/objetivo como contexto.
3. Con bajo volumen, la señal diaria puede ser demasiado ruidosa; propone una ventana móvil de 7 días como referencia principal para VANSAM.
4. El inventario de acciones puede agotarse y las recomendaciones volverse repetitivas.
5. No debe fingirse aprendizaje causal con bajo volumen; propone registrar observación antes/después sin atribuir causalidad.
6. Etiquetas ALTO/MEDIO/BAJO deben explicarse con números y evidencia visibles.
7. Cada acción debe tener ventana de ejecución para evitar recomendar algo cuando ya no puede ejecutarse.
8. Cobertura/punto de equilibrio debe distinguirse del objetivo económico declarado por el dueño.
9. Cuando faltan datos, el sistema debe pedir exactamente el dato mínimo faltante en vez de mostrar una pantalla vacía.
10. La degradación/frescura de costos es un riesgo de abandono central; Claude propone foto/OCR como solución prioritaria.
11. El estado de acciones puede simplificarse en el MVP.
12. Métricas subjetivas de 'decisiones influidas' son débiles; recomienda privilegiar conducta observable y absence test.
13. La señal comercial externa puede diferirse respecto al primer piloto.

## Recomendaciones específicas de Claude

- Dos énfasis de vista: operador y dueño remoto.
- Tendencia diaria + ventana móvil de 7 días.
- Una acción principal con posibilidad de ver alternativas.
- Impacto estimado expresado en Bs/unidades, esfuerzo en minutos y evidencia visible.
- Ventana de ejecución explícita.
- Separar `COBERTURA` de `OBJETIVO`.
- Simplificar estados de acción.
- Evitar atribución causal fuerte.
- Diseñar mecanismo de actualización de costos de muy bajo esfuerzo.

## Hipótesis/umbrales que NO se consideran verificados

No se adoptan automáticamente como hechos ni umbrales canónicos:

- 12,8 pizzas/día;
- 74/90 pizzas semanales;
- 20 acciones distintas mínimas;
- ±5 pedidos/día de varianza;
- 300 pedidos/mes como base estadística exacta;
- foto/OCR obligatoria antes de iniciar piloto;
- absence test oculto/sin aviso;
- regla fija `impacto >= 10x costo del esfuerzo`;
- cualquier cifra económica previa a `VANSAM BASELINE V1`.

Estas cifras requieren revalidación o son propuestas de diseño, no evidencia canónica.
