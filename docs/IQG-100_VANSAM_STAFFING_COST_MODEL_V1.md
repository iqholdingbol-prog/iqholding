# IQG-100 — VANSAM Staffing Cost Model V1

**Estado:** diseño operativo/financiero previo a implementación  
**Fecha:** 2026-09-12  
**Autoridad:** Iván Quea — CEO / Product Owner  
**Arquitectura:** ChatGPT

## 1. Principio

Los salarios nunca se hardcodean por cargo. Cada relación laboral/operativa registra monto, jornada, vigencia, modalidad y jurisdicción. El sistema debe poder recalcular escenarios sin modificar historia.

## 2. Componentes conocidos actuales

Costos mensuales no laborales confirmados/actuales:

- alquiler: Bs 2.000;
- luz: Bs 450;
- agua: Bs 150;
- internet: Bs 50.

Subtotal conocido: **Bs 2.650/mes**.

## 3. Escenario de personal propuesto por CEO

- Samira: Bs 2.500/mes actual, naturaleza laboral/administrativa a separar y validar;
- hornero/armador: Bs 3.300/mes propuesto;
- mesera/cajera: Bs 1.800–2.000/mes propuesto, sujeto a jornada real y validación laboral;
- apoyo eventual: configurable por turno/día;
- Iván: excluido del trabajo operativo ordinario y no debe contarse como mano de obra gratuita para evaluar el modelo estable.

### Escenario aritmético de presupuesto, NO declaración de cumplimiento

Usando mesera Bs 2.000:

`2.650 + 2.500 + 3.300 + 2.000 = Bs 10.450/mes`

Este monto no incluye cargas/beneficios laborales, apoyo eventual, alimentación, transporte, merma, mantenimiento, impuestos, marketing ni otros costos.

## 4. Compliance laboral

El sistema mantiene estados separados:

- `PROPOSED`;
- `PENDING_JOURNEY_DEFINITION`;
- `LEGAL_REVIEW_REQUIRED`;
- `CONFIGURED_COMPLIANT` solo cuando la regla jurisdiccional vigente lo permita y esté validada.

No convertir un presupuesto salarial en hecho legal.

## 5. Fórmula de escenario

`costo_personal_mes = suma(remuneracion_base_vigente + componentes_variables_estimados + cargas_configuradas)`

`costo_operativo_conocido_mes = costos_no_laborales + costo_personal_mes + otros_costos_recurrentes`

`cobertura_ventas_requerida = costo_operativo_conocido_mes / margen_contribucion_estimado`

La última fórmula solo se usa cuando el margen está suficientemente fresco y no se presenta como utilidad contable.

## 6. Escenarios que el producto debe soportar

### ACTUAL
Personal realmente presente hoy.

### ESTABLE
Personal suficiente para operar sin Iván físicamente.

### INDEPENDIENTE_DE_SAMIRA
Modelo donde la operación no depende de Samira en presencia diaria; su función debe estar delegada/reemplazada.

### CRECIMIENTO
Dotación necesaria para 30–50 pizzas/día y posteriormente mayor volumen.

Cada escenario conserva supuestos, vigencia y diferencias de costo.

## 7. Variables pendientes VANSAM

- jornada exacta hornero/armador;
- hora de entrada necesaria para mise en place/masa;
- jornada exacta mesera/cajera;
- si existe relevo o apoyo pico;
- rol futuro de Samira: administradora remota, compras/abastecimiento, supervisión, o salida de operación;
- costo laboral total por persona conforme jurisdicción;
- política de comidas/beneficios;
- bonos de producción/puntualidad/calidad si se usan.

## 8. Regla histórica

Cambiar salario o jornada crea una nueva versión `effective_from`; nunca recalcula periodos anteriores.

**CEO_ACTION_REQUIRED:** parcial — faltan jornadas y rol futuro de Samira para cerrar escenario ESTABLE.