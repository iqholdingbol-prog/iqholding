# IQG-100 — Piloto VANSAM 30 días

**Proyecto:** IQ GROWTH  
**Laboratorio:** VANSAM  
**Estado:** diseño de validación de producto, no implementación  
**Fecha:** 2026-09-11  
**Autoridad:** Iván Quea — CEO / Product Owner

---

## 1. Objetivo

Validar si el primer wedge de IQ GROWTH produce utilidad práctica suficiente para que el operador consulte el sistema de forma recurrente, ejecute decisiones apoyadas por él y perciba pérdida de valor cuando se retira.

La prueba NO busca demostrar causalidad estadística fuerte ni declarar que todo cambio económico fue causado por IQ GROWTH.

Pregunta de producto:

> **¿El sistema ayuda al operador a entender su brecha económica y tomar una acción concreta que de otra manera no habría priorizado?**

---

## 2. Wedge probado

**¿Cómo está VANSAM frente a su objetivo económico y cuál es la acción concreta más útil ahora?**

Salida diaria mínima:

1. margen de contribución observado/estimado;
2. objetivo de cobertura del día/periodo;
3. brecha o excedente;
4. traducción a unidades/tickets equivalentes;
5. una `NEXT_BEST_ACTION`;
6. confianza/calidad de datos;
7. resultado posterior cuando corresponda.

---

## 3. Día 0 — Revalidación obligatoria

Antes de usar cualquier cifra histórica como baseline se debe revalidar:

- costos fijos mensuales actuales;
- días/horarios operativos reales;
- alquiler;
- salarios y jornadas;
- servicios;
- otros costos fijos recurrentes;
- ticket/promedio de venta actual;
- contribución aproximada por categoría/producto;
- disponibilidad real del local;
- volumen actual de operaciones/unidades.

Las cifras anteriores usadas en conversaciones o análisis de Claude se consideran **hipótesis de trabajo**, no baseline canónico, hasta ser confirmadas.

---

## 4. Fuentes de datos iniciales

### Permitidas

- ventas/pedidos V11 para volumen, líneas y totales cuando la calidad lo permita;
- costos fijos confirmados manualmente;
- costo variable aproximado por categoría;
- horarios/cierres reales;
- clientes/contactos cuando exista consentimiento y dato suficiente;
- observaciones operativas registradas.

### Limitaciones V11

No usar V11 para afirmar:
- pago confirmado;
- caja histórica conciliada;
- utilidad neta;
- inventario histórico exacto;
- causalidad de campañas.

---

## 5. Baseline

Preferencia:
- usar 28–30 días históricos comparables si la calidad de ventas y disponibilidad del local es suficiente.

Si no existe historia comparable:
- usar una fase observacional inicial de 7 días y mantener la interpretación como exploratoria.

Registrar confusores:
- cierres;
- enfermedad/viajes;
- cambio de personal;
- cambio de horno/equipo;
- faltantes;
- promociones externas;
- feriados;
- eventos locales;
- clima severo;
- cambios de precio.

---

## 6. Métricas de producto

### P1 — Uso
- días en que se consulta el estado diario;
- hora de consulta;
- operador que consulta.

Objetivo provisional:
`>=25 de 30 días operativos disponibles`.

### P2 — Calidad de datos
- DATA_COMPLETENESS;
- DATA_FRESHNESS;
- DATA_CONFIDENCE;
- incidencias de dato faltante.

Objetivo provisional:
`DATA_COMPLETENESS >=90%` para los cálculos mínimos.

### P3 — Recomendaciones
- acciones generadas;
- acciones descartadas;
- acciones aprobadas;
- acciones ejecutadas;
- motivo de rechazo.

Objetivo provisional:
- >=8 acciones accionables;
- >=5 ejecutadas/aprobadas.

### P4 — Decisiones influenciadas
Registrar una decisión solo si el operador declara que la información cambió prioridad, timing o elección.

Objetivo provisional:
`>=3 decisiones influidas`.

### P5 — Time-to-value
Simular activación limpia con datos mínimos.

Objetivo:
`<=15 minutos` hasta obtener primera brecha y recomendación útil.

---

## 7. Métricas económicas exploratorias

Medir sin afirmar causalidad automática:

- ventas netas observadas;
- margen de contribución estimado;
- brecha de cobertura;
- frecuencia de días en objetivo;
- operaciones/día;
- unidades/pizzas por día;
- ticket promedio;
- contribución por ticket;
- mix;
- cierres/horas disponibles;
- cancelaciones;
- faltantes/merma cuando sean verificables.

Las métricas económicas se comparan contra baseline y deben mostrar confusores conocidos.

---

## 8. NEXT_BEST_ACTION — categorías permitidas en piloto

Inicialmente solo acciones que puedan ejecutarse y medirse sin integración compleja:

1. recuperar clientes inactivos;
2. promover producto/combinación con contribución favorable;
3. evitar cierre/indisponibilidad planificable;
4. corregir faltante simple;
5. ajustar preparación/capacidad cuando exista evidencia;
6. acción local/comercial puntual;
7. corrección de precio únicamente con aprobación explícita.

El sistema nunca envía mensajes, cambia precios o genera compras sin aprobación humana.

---

## 9. Registro de cada acción

Cada acción debe guardar:

- fecha;
- problema;
- evidencia;
- baseline relevante;
- acción recomendada;
- impacto esperado;
- costo/esfuerzo;
- responsable;
- aprobado/rechazado;
- fecha ejecución;
- resultado observado;
- confusores;
- confianza;
- aprendizaje;
- siguiente decisión.

---

## 10. Ritmo de 30 días

### Días 1–3 — calibración
- validar costos y calendario;
- verificar calidad de ventas;
- corregir inputs evidentes;
- no sobreoptimizar.

### Días 4–10 — uso asistido
- una recomendación máxima por día;
- registrar aceptación/rechazo;
- identificar fricción de datos/UX.

### Días 11–23 — uso operativo
- mantener flujo diario;
- priorizar acciones por impacto/esfuerzo/confianza;
- medir resultados observados.

### Días 24–27 — reducción de asistencia
- operador usa el sistema con mínima intervención del fundador/arquitecto;
- observar si entiende y actúa sin explicación adicional.

### Días 28–30 — evaluación
- cierre de métricas;
- entrevista de valor;
- preparar absence test;
- preparar demo para negocio externo.

---

## 11. Absence Test

Después del piloto, retirar temporalmente el resumen/recomendación durante un periodo corto controlado.

Observar:
- si el operador lo pide;
- qué información extraña;
- qué decisión vuelve a hacerse manualmente;
- si construye una sustitución en papel/Excel/WhatsApp.

La ausencia debe ser operacionalmente segura y no eliminar datos.

---

## 12. Señal comercial externa

Mostrar el resultado a un dueño externo que tenga:
- operación real;
- ventas recurrentes;
- costos identificables;
- capacidad de decisión;
- disposición a compartir datos mínimos.

Señal fuerte:
- acepta piloto;
- conecta/importa datos;
- paga/adelanta;
- firma compromiso concreto equivalente.

No cuentan como validación:
- “está bonito”;
- “me interesa”;
- likes;
- seguidores;
- elogios familiares/amigos.

---

## 13. GO / NO-GO del piloto

### GO — Product Signal
Si se cumplen mayormente:
- uso recurrente;
- datos suficientemente confiables;
- acciones ejecutadas;
- decisiones influidas;
- operador entiende sin explicación;
- absence test positivo;
- señal externa concreta.

### ITERATE
Si existe uso/valor pero falla:
- data freshness;
- onboarding;
- calidad de recomendaciones;
- claridad de UI;
- integración.

### NO-GO / REPENSAR WEDGE
Si:
- operador no consulta;
- recomendaciones no cambian ninguna decisión;
- ausencia no se nota;
- ChatGPT + Excel + POS ofrece valor equivalente con esfuerzo comparable;
- ningún dueño externo acepta siquiera piloto con datos.

---

## 14. Restricción

Este documento no autoriza desarrollo de IQG-100 en Codex.

Codex sigue concentrado en IQG-001.2 hasta cierre de seguridad/runtime.

El piloto se ejecutará cuando exista soporte técnico suficiente para producir hechos confiables.
