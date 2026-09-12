# IQG-100 — MVP Wedge Specification

**Proyecto:** IQ GROWTH  
**Estado:** canónico para diseño de producto, previo a implementación  
**Fecha:** 2026-09-11  
**Autoridad:** Iván Quea — CEO / Product Owner  
**Arquitectura y síntesis:** ChatGPT  
**Evidencia previa:** Gemini market validation + Claude product wedge challenge

---

## 1. Propósito del primer MVP

El primer MVP de IQG-100 no intentará resolver todas las palancas de crecimiento ni demostrar todavía la universalidad completa del sistema.

Debe resolver una sola pregunta recurrente y económicamente útil para el dueño:

> **¿Cómo está mi negocio frente a su objetivo económico y cuál es la acción concreta más útil que debo ejecutar ahora?**

El producto debe transformar hechos operativos en una decisión accionable sin exigir que el dueño interprete dashboards complejos.

---

## 2. Wedge único

### WEDGE

**Control Diario de Crecimiento** — nombre interno provisional, no marca comercial aprobada.

### Resultado mínimo

El dueño debe poder abrir una pantalla y entender en segundos:

1. qué margen/contribución produjo el periodo evaluado;
2. cuál era el objetivo de cobertura económico;
3. qué brecha o excedente existe;
4. qué significa operacionalmente esa brecha;
5. cuál es la `NEXT_BEST_ACTION` recomendada;
6. por qué se recomienda;
7. qué resultado tuvo después si se ejecutó.

---

## 3. Terminología económica

IQ GROWTH no debe presentar una estimación operacional como utilidad contable.

### Términos permitidos

- margen de contribución observado;
- objetivo de cobertura;
- brecha de cobertura estimada;
- excedente sobre objetivo estimado;
- resultado operativo estimado, únicamente cuando se declaren supuestos.

### Términos prohibidos sin contabilidad suficiente

- `ganancia neta de hoy`;
- `utilidad distribuible de hoy`;
- `dinero ganado por IQ GROWTH` como causalidad absoluta.

---

## 4. Cálculo mínimo del objetivo

Versión inicial:

`objetivo_cobertura_dia = costos_fijos_periodo / dias_operativos_planificados_periodo`

`margen_contribucion_periodo = ventas_netas - costos_variables_estimados`

`brecha_cobertura = margen_contribucion_periodo - objetivo_cobertura_periodo`

Cuando `brecha_cobertura < 0`, existe déficit respecto al objetivo.

Cuando `brecha_cobertura >= 0`, existe excedente respecto al objetivo de cobertura.

Los cálculos deben mostrar:
- periodo;
- supuestos;
- calidad de datos;
- confianza.

### Evolución posterior

Con suficiente historia se podrá ponderar el objetivo según:
- día de semana;
- horario;
- estacionalidad;
- feriados;
- capacidad;
- cierres planificados;
- patrones por sucursal.

---

## 5. Traducción operacional

El core debe calcular la brecha en términos económicos.

Cada vertical puede traducirla a una unidad comprensible.

### VANSAM

Ejemplos:
- Bs de contribución faltante;
- pizzas equivalentes según contribución media;
- tickets equivalentes;
- ventas adicionales requeridas.

Estas equivalencias deben estar marcadas como estimaciones.

### Otros rubros futuros

La misma brecha podría traducirse a:
- servicios;
- unidades;
- kg;
- contratos;
- clientes;
- horas facturables.

El core nunca contiene lógica `pizza`.

---

## 6. Datos mínimos para activar

El modo de activación rápida debe poder entregar primer valor en **<=15 minutos** cuando exista acceso a ventas.

Inputs iniciales:

1. empresa/sucursal;
2. calendario y días operativos;
3. costos fijos aproximados del periodo;
4. ventas;
5. costo variable aproximado por categoría, porcentaje o fuente equivalente;
6. opcional: identidad/contacto de cliente;
7. opcional: disponibilidad/faltantes básicos.

No exigir para el primer valor:
- recetas completas;
- costo exacto de cada ingrediente;
- integración omnicanal;
- inventario avanzado;
- campañas complejas;
- agentes autónomos.

La precisión debe mejorar progresivamente sin bloquear activación.

---

## 7. Calidad y frescura de datos

Un cálculo correcto con datos viejos sigue siendo un producto malo.

IQ GROWTH debe medir:
- `DATA_FRESHNESS`;
- `DATA_COMPLETENESS`;
- `DATA_CONFIDENCE`;
- `MANUAL_INPUT_BURDEN`.

### Objetivo estratégico

Reducir progresivamente la necesidad de digitación manual.

Canales candidatos futuros:
- integración POS/ERP;
- importación CSV;
- factura electrónica;
- foto/OCR de factura o nota de compra;
- captura rápida asistida;
- integración con proveedor;
- propuesta automática + confirmación humana.

La foto/OCR es hipótesis de canal de captura, no diferenciador probado por sí mismo.

---

## 8. NEXT_BEST_ACTION

El sistema no debe mostrar una lista interminable de recomendaciones.

Debe seleccionar una acción principal basándose inicialmente en:
- impacto económico estimado;
- urgencia;
- costo/esfuerzo;
- confianza;
- reversibilidad.

### Fuentes iniciales de acción

- aumentar volumen;
- corregir mix de baja contribución;
- recuperar clientes inactivos cuando haya datos;
- evitar faltante crítico;
- reducir cierre/indisponibilidad;
- corregir una anomalía operativa simple;
- ejecutar una acción comercial registrada.

### Formato obligatorio

Toda acción debe explicar:

**PROBLEMA** → **EVIDENCIA** → **ACCIÓN** → **IMPACTO ESPERADO** → **COSTO/ESFUERZO** → **CONFIANZA**

---

## 9. Human-in-the-loop

Automático sin aprobación:
- cálculo económico;
- detección de anomalías;
- alertas;
- priorización;
- generación de borradores;
- registro de cambios;
- medición posterior.

Requiere aprobación humana:
- mensaje al cliente;
- promoción;
- descuento;
- cambio de precio;
- orden de compra;
- modificación irreversible;
- acción externa con costo o riesgo material.

El MVP puede preparar una acción y abrir la herramienta correspondiente; no necesita automatizar terceros para demostrar valor.

---

## 10. Pantalla principal del MVP

Primera capa: máxima simplicidad.

Ejemplo conceptual:

```text
ESTADO ECONÓMICO      EN OBJETIVO / BAJO OBJETIVO
BRECHA                -Bs 180
OBJETIVO PRÓXIMO      +Bs 180 de contribución

ACCIÓN RECOMENDADA
14 clientes están inactivos hace >21 días.
Recuperar 3 tickets promedio cubriría ~Bs X de la brecha.
[PREPARAR ACCIÓN]

Confianza: MEDIA
Datos actualizados: 21:42
```

No mostrar por defecto:
- diez gráficos;
- rankings irrelevantes;
- vanity metrics;
- decenas de alertas simultáneas.

La analítica detallada puede vivir detrás de una segunda capa.

---

## 11. Medición de cambios

`Experimentos medibles` deja de ser pilar comercial inicial, pero la disciplina de aprendizaje permanece.

Por cada cambio relevante registrar:
- fecha;
- problema;
- baseline;
- acción;
- costo;
- resultado posterior;
- periodo comparable;
- confusores conocidos;
- confianza;
- aprendizaje.

No exigir A/B testing formal cuando el volumen no lo soporte.

No afirmar causalidad fuerte cuando solo hay comparación observacional.

---

## 12. Alcance inicial por vertical

### MVP activo

**VANSAM únicamente.**

### Laboratorios estratégicos posteriores

- Café Zacarías;
- Chocolates La Florita.

No se eliminan de la visión. Se difiere su implementación para evitar validar tres modelos operativos simultáneamente.

Cuando VANSAM demuestre valor y exista señal comercial externa, Café y Chocolates se usarán para probar portabilidad del núcleo.

---

## 13. Prueba VANSAM — 30 días

La prueba separa adopción de producto de resultado empresarial.

### A. Product Value Gate

PASS provisional si:
- el estado/cierre se consulta >=25 de 30 días operativos disponibles;
- `DATA_COMPLETENESS >= 90%` para el cálculo mínimo;
- se generan >=8 recomendaciones accionables;
- se ejecutan >=5 acciones aprobadas;
- existen >=3 decisiones que el operador reconoce como influidas por IQ GROWTH;
- primer valor de una configuración nueva simulada <=15 minutos;
- Samira/Iván pueden entender el estado sin análisis adicional.

### B. Business Outcome Gate

Medir:
- margen de contribución;
- brecha de cobertura;
- días en objetivo;
- operaciones/unidades;
- ticket/contribución por ticket;
- costos o merma evitados verificables;
- resultado de las acciones.

No declarar que IQ GROWTH causó toda mejora observada.

### C. Absence Test

Después de uso suficiente, retirar temporalmente el resumen y observar:
- si el operador lo pide de vuelta;
- si intenta recrearlo manualmente;
- qué decisión pierde sin él.

### D. Señal comercial externa

Antes de llamar al producto comercialmente validado, obtener al menos una señal fuerte de un negocio externo compatible:
- piloto aceptado;
- datos conectados;
- adelanto/pago;
- compromiso verificable equivalente.

Un comentario positivo no cuenta como validación.

---

## 14. Lo que queda fuera del MVP

- agentes autónomos;
- contabilidad fiscal completa;
- facturación tributaria como diferenciador;
- gateway de pagos;
- marketing automation completo;
- loyalty como módulo separado;
- inventario avanzado;
- forecasting complejo;
- A/B testing formal por defecto;
- benchmarking entre tenants;
- Café/Chocolate implementados simultáneamente;
- OCR/foto de factura obligatorio desde día 1;
- pricing definitivo;
- success fee.

---

## 15. Gate para Codex

Este documento **NO es una orden de implementación todavía**.

Codex recibe IQG-100 únicamente cuando:
1. IQG-001.2 cierre seguridad/PG16;
2. IQG-001.3 tenga contrato de migración estable;
3. el esquema final pueda representar hechos económicos necesarios;
4. ChatGPT traduzca este MVP a contratos técnicos;
5. Iván apruebe explícitamente el alcance de implementación.

Hasta entonces, IQG-100 permanece en diseño de producto.

---

## 16. Definición de éxito conceptual

El primer IQ GROWTH debe demostrar este ciclo:

`HECHO ECONÓMICO → BRECHA → UNA ACCIÓN → EJECUCIÓN HUMANA → RESULTADO → APRENDIZAJE`

Si solo muestra ventas y gráficos, es un dashboard.

Si solo calcula costos, es una hoja de cálculo.

Si solo genera ideas, es un chatbot.

IQ GROWTH empieza a existir cuando **prioriza una decisión económicamente relevante usando datos frescos, reduce el esfuerzo del dueño y aprende del resultado**.
