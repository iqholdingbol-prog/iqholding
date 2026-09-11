# IQG-100 — Growth Engine Specification

**Proyecto:** IQ GROWTH  
**Estado:** especificación de producto previa a implementación  
**Fecha:** 2026-09-11  
**Autoridad:** Iván Quea — CEO / Product Owner  
**Arquitectura y síntesis:** ChatGPT  
**Validación futura:** Gemini (mercado/evidencia), Claude (producto), DeepSeek (integridad), Codex (implementación futura)

---

## 1. Propósito

IQ GROWTH no se diferencia por registrar más datos que un POS/ERP. Se diferencia por convertir datos empresariales confiables en decisiones y acciones cuyo resultado económico pueda medirse.

Cadena oficial:

`DATOS → MEDICIÓN → DIAGNÓSTICO → DECISIÓN → ACCIÓN → RESULTADO → APRENDIZAJE → CRECIMIENTO`

El sistema debe responder no solo **qué pasó**, sino:

1. ¿Qué está limitando el crecimiento?
2. ¿Qué acción concreta conviene ejecutar?
3. ¿Qué resultado se esperaba?
4. ¿Qué ocurrió realmente después de ejecutar la acción?
5. ¿Cuánto margen incremental puede atribuirse razonablemente a esa intervención?
6. ¿Qué aprendemos para la siguiente decisión?

---

## 2. North Star

**Margen de contribución incremental generado por intervenciones atribuibles a IQ GROWTH.**

No usar como North Star:
- ventas brutas;
- seguidores;
- alcance;
- cantidad de funciones usadas;
- número de reportes;
- número de recomendaciones emitidas.

Una recomendación sin acción no genera valor. Una acción sin resultado medido no puede demostrar valor.

---

## 3. Unidad central de valor: Intervención de Crecimiento

Toda intervención debe tener como mínimo:

- `intervention_id`
- company_id
- branch_id cuando corresponda
- problema/hipótesis
- evidencia previa
- métrica objetivo
- baseline
- acción recomendada
- responsable
- fecha_inicio
- fecha_fin o ventana de evaluación
- costo de la acción
- resultado observado
- método de comparación
- nivel de confianza
- margen incremental estimado
- estado: PROPUESTA / APROBADA / EN_EJECUCION / MEDIDA / APRENDIDA / DESCARTADA
- trazabilidad de quién recomendó, aprobó, ejecutó y evaluó

El sistema nunca debe presentar causalidad fuerte cuando solo existe correlación.

---

## 4. Seis motores de crecimiento universales

IQ GROWTH debe organizar sus diagnósticos inicialmente alrededor de seis palancas universales.

### G1 — Mercado / ubicación
Preguntas:
- ¿estamos vendiendo en una zona y segmento compatibles con nuestra oferta?
- ¿la capacidad de pago soporta el precio?
- ¿la competencia deja una oportunidad defendible?

Métricas posibles:
- tráfico estimado/observado;
- tasa de conversión física;
- precios de competencia;
- radio de clientes;
- demanda por horario;
- margen por zona/canal.

### G2 — Adquisición
Preguntas:
- ¿de dónde vienen los clientes?
- ¿qué canal/campaña/creador produce clientes reales?

Métricas:
- leads;
- clientes nuevos;
- CAC;
- conversión por canal;
- primera compra atribuida;
- margen de primera compra;
- payback de adquisición.

### G3 — Conversión
Preguntas:
- ¿cuántas oportunidades terminan en compra?
- ¿dónde abandona el cliente?

Métricas:
- oportunidades/visitas;
- pedidos iniciados;
- ventas completadas;
- abandono;
- tiempo de atención;
- disponibilidad;
- cancelaciones.

### G4 — Ticket / mix / margen
Preguntas:
- ¿qué combinación de productos incrementa margen sin destruir conversión?
- ¿qué productos venden mucho pero aportan poco?

Métricas:
- ticket promedio;
- margen por ticket;
- unidades por operación;
- attachment rate;
- mix de productos;
- margen por producto/variante;
- descuentos/promociones.

### G5 — Recompra / retención
Preguntas:
- ¿los clientes vuelven?
- ¿cuándo dejan de volver?
- ¿qué acción recupera clientes?

Métricas:
- repetición 7/30/60/90 días según rubro;
- frecuencia;
- cohortes;
- churn/inactividad;
- recuperación;
- valor acumulado del cliente;
- margen acumulado.

### G6 — Operación / capacidad
Preguntas:
- ¿la operación impide vender más o destruye margen?
- ¿qué cuello de botella genera espera, merma, cancelación o baja satisfacción?

Métricas:
- tiempo por etapa;
- capacidad por hora;
- utilización;
- faltantes;
- merma;
- errores/retrabajo;
- cancelaciones;
- tiempos de espera;
- productividad;
- costo operacional por unidad.

---

## 5. Hechos vs estimaciones

Todo insight debe declarar su clase epistemológica:

- **OBSERVADO:** proviene de datos transaccionales/operativos verificables.
- **CALCULADO:** transformación determinista de hechos observados.
- **ESTIMADO:** usa modelos, muestreo o datos externos incompletos.
- **INFERIDO POR IA:** razonamiento basado en evidencia pero no hecho directo.
- **HIPÓTESIS:** propuesta aún no probada.

La UI y API deben permitir distinguir estas categorías. IQ GROWTH nunca debe mostrar una inferencia como si fuera un hecho.

---

## 6. Baseline y comparación

Ninguna intervención puede declarar crecimiento sin una línea base definida.

Métodos iniciales permitidos:

1. antes vs después;
2. periodo comparable;
3. cohorte comparable;
4. sucursal/control comparable cuando exista;
5. segmento expuesto vs no expuesto;
6. test A/B cuando sea operacionalmente viable.

El método usado debe quedar guardado.

Factores externos importantes deben registrarse como confusores cuando se conozcan:
- cierres del local;
- fallas de equipo;
- feriados;
- clima;
- cambios fuertes de precio;
- falta de stock;
- campañas paralelas;
- cambios de personal;
- obras/cortes de calle;
- eventos extraordinarios.

---

## 7. Fórmula económica mínima

Para una intervención:

`margen_incremental_estimado = margen_observado_periodo_intervencion - margen_baseline_ajustado - costo_intervencion`

La cifra debe acompañarse de:
- método de baseline;
- periodo;
- supuestos;
- confianza;
- factores externos conocidos.

No se debe llamar “generado por IQ GROWTH” a todo aumento observado sin criterio de atribución.

---

## 8. Recomendación accionable

Una recomendación útil debe incluir:

1. **Problema:** qué detectamos.
2. **Evidencia:** por qué creemos que existe.
3. **Impacto estimado:** qué podría mejorar.
4. **Acción:** qué hacer concretamente.
5. **Costo/esfuerzo:** cuánto cuesta o qué requiere.
6. **Responsable:** quién ejecuta.
7. **Ventana de prueba:** cuánto se observará.
8. **KPI objetivo:** qué debe moverse.
9. **Criterio de éxito/fracaso:** umbral antes de ejecutar.
10. **Plan de medición:** cómo sabremos si funcionó.

No emitir recomendaciones genéricas del tipo “publica más en redes” o “mejora la atención” sin acción medible.

---

## 9. Ciclo de aprendizaje

Después de medir una intervención, clasificar:

- FUNCIONÓ;
- FUNCIONÓ PARCIALMENTE;
- NO FUNCIONÓ;
- INCONCLUSO;
- DAÑO/RESULTADO NEGATIVO.

Guardar:
- hipótesis original;
- resultado;
- explicación;
- aprendizaje;
- siguiente recomendación.

La memoria de aprendizaje es por empresa, pero los patrones anonimizados/agregados podrían en el futuro alimentar modelos universales solo bajo arquitectura y política de privacidad explícitas.

---

## 10. Valor demostrado al cliente

El dashboard ejecutivo de IQ GROWTH debe poder mostrar, como mínimo:

### Valor económico
- margen incremental estimado acumulado;
- costo de acciones ejecutadas;
- ROI de intervenciones;
- ahorro/merma evitada cuando sea medible.

### Valor comercial
- clientes nuevos;
- tasa de recompra;
- ticket/margen por cliente;
- conversión;
- canales que realmente producen ventas.

### Valor operativo
- tiempo reducido;
- capacidad liberada;
- errores/merma/faltantes reducidos.

### Calidad de evidencia
Cada cifra atribuida debe mostrar confianza: ALTA / MEDIA / BAJA y método de cálculo.

---

## 11. VANSAM como laboratorio #1

Primeras hipótesis que VANSAM debe permitir probar, sin convertirlas aún en hechos:

1. **Capacidad/horno:** reducir tiempo de preparación aumenta pedidos completados y satisfacción.
2. **Atención:** mejor servicio aumenta conversión/recompra.
3. **Continuidad:** evitar cierres irregulares aumenta clientes recurrentes y ventas acumuladas.
4. **CRM:** capturar cliente/WhatsApp permite medir y aumentar recompra.
5. **Marketing local:** contenido/campañas correctamente atribuidos producen nuevos clientes rentables.
6. **Mix:** ciertas pizzas/bebidas/complementos elevan margen por ticket.

KPIs mínimos del laboratorio:
- operaciones/día y por hora;
- pizzas/unidades/día;
- ticket promedio;
- margen por operación;
- cliente nuevo/recurrente;
- recompra;
- fuente de adquisición;
- tiempo pedido→listo→entrega;
- cancelaciones;
- satisfacción;
- merma/faltantes;
- disponibilidad del local;
- margen incremental de intervenciones.

---

## 12. Lo que IQG-100 NO debe convertirse todavía

No construir todavía:
- agente autónomo que cambie precios sin aprobación;
- atribución causal avanzada sin datos suficientes;
- predicción compleja sin baseline;
- benchmark cruzado entre empresas con fuga de datos;
- motor universal de recomendaciones basado en datos de otros tenants sin política explícita;
- docenas de dashboards sin relación con decisiones.

Primero demostrar en VANSAM que el ciclo `detectar → recomendar → ejecutar → medir → aprender` funciona de extremo a extremo.

---

## 13. Gate de producto para implementación

IQG-100 no pasa a Codex hasta que:

1. el Core pueda producir hechos confiables;
2. IQG-001.2 cierre aislamiento/seguridad;
3. IQG-001.3 defina calidad y límites del legado;
4. Gemini valide que las métricas/propuesta de valor son relevantes frente al mercado;
5. Claude desafíe que el diseño realmente conduce a decisiones y no a reportes;
6. ChatGPT sintetice y reduzca el primer MVP de Growth Engine;
7. Iván apruebe el alcance comercial del MVP.

---

## 14. Definición de éxito del primer Growth Engine

En VANSAM, IQ GROWTH debe poder producir al menos un caso real y trazable con esta cadena:

`HECHO → PROBLEMA → RECOMENDACIÓN → ACCIÓN → RESULTADO MEDIDO → IMPACTO ECONÓMICO → APRENDIZAJE`

Si no podemos demostrar esa cadena, todavía tenemos software administrativo, no un Sistema de Crecimiento Empresarial.
