# IQG-100 — Addendum canónico al Daily Decision Engine tras challenge de Claude

**Fecha:** 2026-09-12
**Estado:** canónico para diseño de producto, previo a implementación
**Aplica a:** `docs/IQG-100_DAILY_DECISION_ENGINE_SPEC.md`, `docs/IQG-100_MVP_WEDGE_SPEC.md`, `docs/IQG-100_VANSAM_30_DAY_PILOT.md`

## 1. Decisión de producto

Se mantiene la pregunta central:

> ¿Cómo está mi negocio frente a su objetivo económico y cuál es la acción concreta más útil que debo ejecutar ahora?

Pero el motor diario se refina para no convertirse en un semáforo estático ni en una recomendación desconectada del momento de ejecución.

## 2. Dos contextos de uso

### Operador presente

Prioridad:
- qué requiere atención;
- qué puede ejecutarse ahora o en la próxima ventana;
- dato mínimo faltante;
- acción concreta.

### Dueño remoto

Prioridad:
- tendencia;
- cobertura;
- objetivo;
- excepciones;
- acción priorizada;
- qué aprobó/rechazó/ejecutó el operador.

Un solo motor económico alimenta ambas vistas.

## 3. Jerarquía visual revisada

El estado `EN_OBJETIVO/BAJO_OBJETIVO` ya no es titular obligatorio.

Orden preferido:

1. movimiento/tendencia;
2. posición respecto a `COBERTURA_MINIMA`;
3. posición respecto a `OBJETIVO_DUENO`;
4. una acción ejecutable;
5. impacto/rango, esfuerzo y ventana;
6. calidad/frescura del dato.

Para VANSAM se probará una ventana móvil corta (inicialmente candidata de 7 días), pero la duración debe validarse con `VANSAM BASELINE V1` y no se hardcodea en Core.

## 4. Cobertura != objetivo

`COBERTURA_MINIMA`:
piso económico estimado necesario para cubrir los costos configurados bajo los supuestos declarados.

`OBJETIVO_DUENO`:
meta declarada y versionada por el propietario/administrador autorizado.

El sistema puede mostrar simultáneamente:
- debajo de cobertura;
- cubriendo costos pero debajo de objetivo;
- en/sobre objetivo.

No llamar utilidad contable a ninguno de estos cálculos.

## 5. NEXT_BEST_ACTION revisada

Una candidata solo compite si:
- datos suficientes;
- acción permitida por alcance;
- ejecutable dentro de ventana relevante;
- no está en cooldown;
- tiene impacto/rango estimable;
- esfuerzo estimable;
- no requiere una decisión jurídica/laboral/fiscal/societaria fuera del producto.

Orden inicial sin score opaco:
1. elegibilidad/seguridad;
2. impacto económico/rango visible;
3. urgencia/ventana;
4. menor esfuerzo cuando impactos sean comparables;
5. mayor confianza de datos;
6. menor repetición reciente.

Si no existe candidata responsable:

`NO_RECOMMENDATION_WITH_REASON`

acompañada siempre de:
- motivo;
- dato/condición que la desbloquearía;
- siguiente microacción si existe.

## 6. Acción explicable

Toda tarjeta debe mostrar o permitir abrir:
- problema;
- evidencia;
- cálculo/rango de impacto;
- unidad del negocio;
- esfuerzo aproximado;
- ventana de ejecución;
- supuestos;
- frescura;
- por qué ganó frente a otras candidatas.

Las bandas ALTO/MEDIO/BAJO son únicamente resumen visual; no sustituyen los valores subyacentes.

## 7. Repetición

El motor debe soportar:
- cooldown por categoría;
- cooldown por cliente/segmento/destinatario;
- nueva evidencia requerida para repetir una acción materialmente igual;
- registro de rechazo con motivo;
- degradación de prioridad tras rechazos repetidos sin evidencia nueva.

No se fija todavía un número mínimo universal de acciones distintas.

## 8. Datos faltantes

Nunca usar una pantalla vacía como respuesta primaria.

Si el dato falta y es recuperable, convertirlo en microacción:

`Necesito actualizar X para calcular Y`.

Debe mostrar esfuerzo estimado y método de captura disponible.

## 9. Frescura de costos

Se reconoce `COST_DATA_FRESHNESS` como riesgo crítico de producto.

Objetivo:
actualizar costos con fricción mínima.

Canales permitidos en orden de disponibilidad, no de obligación:
- captura rápida manual;
- importación;
- integración POS/ERP/proveedor;
- factura electrónica;
- foto/OCR;
- propuesta automática con confirmación humana.

No se exige foto/OCR para iniciar piloto.

## 10. Estados de acción

UI MVP:
- `PROPUESTA`;
- `APROBADA`;
- `HECHA`;
- `DESCARTADA`.

El sistema puede registrar internamente eventos posteriores de observación sin exponer maquinaria innecesaria al operador.

## 11. Medición posterior

No eliminar la disciplina de medición.

Después de una acción registrar:
- periodo anterior;
- periodo posterior;
- resultado observado;
- confusores;
- atribución: `UNDETERMINED`, salvo evidencia superior;
- notas del operador.

Nunca transformar automáticamente correlación en causalidad.

## 12. Absence test

Debe ser:
- acordado dentro del piloto;
- temporal;
- reversible;
- operacionalmente seguro;
- sin pérdida de datos.

No se autoriza retirar silenciosamente una capacidad crítica para engañar al operador.

## 13. Métricas del piloto revisadas

Mantener:
- uso recurrente por rol;
- acciones aprobadas/ejecutadas dentro de ventana;
- rechazo con motivo;
- corrección voluntaria de datos;
- tiempo a primera utilidad;
- freshness/completeness;
- absence test;
- tendencia económica observada.

Separar claramente:
- validación de producto en VANSAM;
- validación comercial externa.

La segunda no es condición para que el piloto interno sea informativo, pero sigue siendo requisito antes de declarar product-market signal externo.

## 14. Gate siguiente

No pasar a Codex.

Siguiente evidencia requerida:

`VANSAM BASELINE V1`

para validar:
- ventana móvil adecuada;
- cobertura mínima real;
- objetivo del dueño;
- fuentes de acción disponibles;
- frescura de costos;
- inventario real de recomendaciones;
- diferencias de valor entre operador y dueño remoto.

**CEO_ACTION_REQUIRED:** true únicamente para confirmar el `OBJETIVO_DUENO` y cifras actuales durante Baseline V1.
