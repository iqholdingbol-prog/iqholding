# IQG-100 — VANSAM Responsibility Matrix V1

**Estado:** diseño operativo previo a implementación
**Fecha:** 2026-09-12

## 1. Objetivo

Hacer que VANSAM pueda operar sin dependencia personal de Iván y, progresivamente, sin dependencia diaria de Samira.

`PERSONA → ROL → PROCESO → RESPONSABILIDAD → EVIDENCIA → INCIDENCIA → RESPUESTA → HISTORIAL`

Responsabilidad funcional no equivale a culpabilidad automática.

## 2. Iván

- excluido de operación cotidiana de VANSAM;
- CEO/supervisión remota;
- acceso de lectura a todas las incidencias y métricas;
- decisiones estratégicas;
- no debe ser reemplazo habitual de caja, cocina, compras o sala.

## 3. Samira — fase actual

Responsabilidades actuales:
- administradora operativa;
- elaboración de masa con receta propia;
- compras de insumos;
- stock de sala/bebidas y abastecimiento general;
- hamburguesas viernes, sábado y domingo;
- supervisión de incidencias;
- puede ver y responder registros, pero no editarlos ni eliminarlos.

Meta futura:
- dejar administración diaria;
- quedar como socia/supervisora;
- administrador operativo futuro asumirá procesos transferibles.

### Riesgo de continuidad

Actualmente la receta de masa es conocimiento exclusivo de Samira. Esto constituye `KEY_PERSON_DEPENDENCY`.

Para que VANSAM pueda operar sin ella deberá elegirse posteriormente una de estas estrategias:
1. Samira produce/prepara masa o premezcla por adelantado bajo proceso controlado;
2. receta protegida se comparte con persona de confianza bajo control de acceso/acuerdo;
3. fórmula se divide en premezcla secreta + procedimiento operativo;
4. otro método que preserve secreto y continuidad.

Mientras esto no se resuelva, Samira sigue siendo dependencia crítica de producción.

## 4. Hornero / armador

Responsabilidades previstas:
- preparar toppings de cocina de pizza;
- mise en place de su estación;
- armado de pizzas;
- horneado;
- control visual/calidad de salida;
- limpieza y cierre de su sector;
- reportar faltantes, retrasos de masa, equipo o insumos mediante incidencia;
- marcar entrada/salida individual.

No es responsable de la masa mientras la elaboración permanezca asignada a Samira.

## 5. Mesera / cajera

Responsabilidades previstas:
- apertura y orden de sala/caja;
- caja/POS;
- atención salón y para llevar;
- registrar tipo de pedido;
- bebidas;
- abastecer aderezos y consumibles de sala;
- mantener limpios y ordenados sala/caja y su estación;
- detectar faltantes visibles de sala;
- registrar incidencia cuando un faltante impide o afecta venta;
- marcar entrada/salida individual;
- cierre/limpieza de su sector.

Principio: `DUEÑA_OPERATIVA_DE_SALA`, no propietaria jurídica.

Ejemplo:
- Coca-Cola faltante → mesera registra incidencia;
- responsable de abastecimiento vigente → Samira/administrador según fecha;
- sistema conserva reporte, respuesta y resolución.

## 6. Administrador operativo futuro

Deberá sustituir progresivamente tareas hoy concentradas en Samira:
- compras;
- abastecimiento;
- stock;
- control de personal;
- apertura/cierre administrativo;
- respuesta a incidencias;
- coordinación de proveedores;
- verificación de caja y operación;
- seguimiento de KPIs.

No podrá borrar incidencias ni auditoría.

## 7. Pantallas

### PC táctil 23" — sala/caja
- POS;
- asistencia;
- caja;
- incidencias de sala;
- apertura/cierre;
- identificación de personal;
- confirmaciones.

### Tablet 13" — cocina
Diseño ligero:
- pedidos de pizza;
- pedidos de hamburguesas;
- estado PREPARANDO/LISTO;
- tiempos;
- faltante/incidencia rápida;
- alta legibilidad.

No cargar administración pesada ni reportes complejos.

### TV 42" — cliente
- pedido visible/confirmación;
- promociones contextuales;
- cross-selling;
- extras;
- productos disponibles;
- cliente acepta/rechaza sugerencia.

IA puede recomendar; nunca añade un producto sin confirmación.

## 8. Incidencias por WhatsApp — arquitectura conceptual

Número previamente vinculado a trabajador/usuario.

Canales aceptables futuros:
- texto;
- audio;
- foto.

IA extrae:
- reportante;
- hora;
- categoría;
- proceso afectado;
- destinatario/responsable vigente;
- evidencia;
- impacto aproximado.

Antes de persistir una acusación material, mostrar resumen y permitir confirmación/corrección.

Visibilidad inicial:
- trabajador: sus incidencias y respuestas;
- Samira/administrador: todas las de VANSAM;
- Iván: todas, en lectura/supervisión;
- nadie salvo flujo de corrección auditado puede borrar o reescribir.

## 9. Ejemplos

### Falta Coca-Cola
`REPORTA=CAJERA → TIPO=STOCKOUT_SALA → RESPONSABLE=ABASTECIMIENTO → RESPUESTA → RESOLUCIÓN`

### Masa no lista
`REPORTA=HORNERO → TIPO=PREPARACION_MASA → RESPONSABLE=SAMIRA (fase actual) → RESPUESTA → RESOLUCIÓN`

### Topping faltante
`REPORTA=HORNERO → TIPO=MISE_EN_PLACE → RESPONSABLE=HORNERO si debía prepararlo / ABASTECIMIENTO si nunca ingresó insumo`

El motor debe identificar la etapa causal antes de atribuir responsabilidad.

## 10. Estado

Matriz suficiente para diseño de procesos. Falta definir:
- hora de ingreso de Samira para masa;
- hora de ingreso del hornero antes de apertura;
- horario legal final de mesera/cajera;
- administrador futuro;
- solución a dependencia de receta de masa.

**CEO_ACTION_REQUIRED:** solo cuando se elija estrategia de continuidad de receta y horario final.