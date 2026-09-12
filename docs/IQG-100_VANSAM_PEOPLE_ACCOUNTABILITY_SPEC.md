# IQG-100 — VANSAM People, Accountability & Attendance Specification

**Estado:** diseño canónico de producto previo a implementación  
**Fecha:** 2026-09-12  
**Autoridad:** Iván Quea — CEO / Product Owner  
**Arquitectura y síntesis:** ChatGPT

---

## 1. Objetivo

VANSAM debe poder operar con orden, continuidad y trazabilidad aun cuando Iván no esté presente y, progresivamente, cuando Samira tampoco deba sostener físicamente la operación diaria.

El sistema debe responder, con evidencia:

- quién debía hacer qué;
- cuándo debía hacerlo;
- qué ocurrió realmente;
- quién reportó una incidencia;
- quién era responsable funcional del proceso;
- cómo se resolvió;
- si el problema se repite;
- qué impacto operativo/comercial tuvo.

El sistema NO debe convertirse en una máquina de castigo ni asumir culpabilidad automática. Debe registrar hechos, responsabilidades asignadas, respuestas y patrones.

---

## 2. Personal y remuneración adaptable

IQ GROWTH no hardcodea salarios por cargo.

Cada relación laboral/operativa debe soportar:

- persona;
- cargo;
- sucursal;
- tipo de jornada;
- horario pactado;
- días de trabajo;
- remuneración base;
- bonos variables;
- alimentación/beneficios configurables;
- vigencia desde/hasta;
- jurisdicción;
- estado de validación laboral;
- costo empresa estimado cuando esté disponible.

### VANSAM — hipótesis actuales

- Hornero/armador: `Bs 3.300/mes` propuesto.
- Mesera/cajera: `Bs 1.800–2.000/mes` propuesto, pendiente definir jornada/modalidad y validación laboral.
- Samira: remuneración actual `Bs 2.500/mes`; debe separarse su remuneración actual de la futura función/reemplazo operativo.
- Iván: excluido de la operación laboral ordinaria de VANSAM; su rol es CEO/propietario/gestión estratégica, no debe usarse como mano de obra gratuita para calcular la operación estable.

### Regla de cumplimiento

La remuneración propuesta puede guardarse como `PROPOSED`, pero una relación no debe marcarse `COMPLIANT` solo porque el usuario ingresó un monto. Debe evaluarse por jornada, jurisdicción y normativa aplicable.

---

## 3. Roles operativos VANSAM

### 3.1 Administradora / responsable de abastecimiento

Responsabilidades candidatas de Samira mientras permanezca en el rol:

- asegurar stock comercial de sala;
- gestionar compras/reposición asignadas;
- revisar faltantes;
- coordinar proveedores;
- mantener disponibilidad de bebidas y otros productos asignados;
- validar costos de compra/captura de insumos;
- revisar incidencias que le correspondan;
- preparar transición futura a otra persona responsable.

Ejemplo:

`Coca-Cola no disponible → responsabilidad funcional: abastecimiento sala → responsable vigente: Samira`.

Esto NO significa culpabilidad automática. Puede haber proveedor incumplido, bloqueo, falla de caja, error de conteo, recepción tardía u otra causa.

### 3.2 Hornero / armador

Responsabilidades candidatas:

- mise en place asignado;
- disponibilidad de masa según plan;
- armado;
- horno;
- tiempos;
- calidad;
- limpieza de su sector al cierre;
- reportar faltantes o bloqueos que impidan producir.

### 3.3 Mesera / cajera

Responsabilidades candidatas:

- apertura de caja/terminal;
- toma y confirmación de pedidos;
- atención de salón;
- bebidas y productos de sala asignados;
- cobro/registro según permisos;
- informar indisponibilidades;
- registrar incidencias operativas observadas;
- limpieza de su sector al cierre.

### 3.4 Cocina hamburguesas

Hamburguesas se incorporan inicialmente viernes, sábado y domingo.

El flujo de cocina debe distinguir línea/producto pero compartir cola operativa cuando corresponda:

- PIZZA;
- HAMBURGUESA;
- otras líneas futuras.

La asignación de responsable debe ser explícita por turno y sector.

---

## 4. Matriz de responsabilidad

El sistema debe manejar una matriz tipo RACI simplificada por tarea/proceso:

- `RESPONSABLE_PRIMARIO` — ejecuta/asegura el proceso;
- `RESPONSABLE_RESPALDO` — cubre si el primario no puede;
- `INFORMADO` — debe recibir alerta;
- `APROBADOR` — cuando corresponda.

Ejemplos:

| Proceso | Responsable primario | Respaldo | Informado |
|---|---|---|---|
| stock bebidas sala | administradora/abastecimiento | cajera designada | dueño remoto |
| masa lista antes de servicio | hornero/armador o rol asignado | cocina apoyo | administradora |
| caja abierta | mesera/cajera | administradora | dueño remoto |
| cierre sector cocina | hornero/armador | apoyo cocina | administradora |
| cierre sector sala | mesera/cajera | apoyo sala | administradora |

La matriz es configurable y versionada. Cambiar responsable hoy no reescribe quién era responsable la semana pasada.

---

## 5. Incidencias y reclamos internos

Nombre de producto recomendado: **INCIDENCIA OPERATIVA**, no “reclamo” como concepto principal.

Un reclamo puede ser una clase de incidencia, pero el objetivo es resolver procesos y medir recurrencia, no crear conflicto entre personas.

### 5.1 Ejemplos

- `SIN_STOCK_BEBIDA`
- `MASA_NO_LISTA`
- `INSUMO_FALTANTE`
- `CAJA_NO_ABIERTA`
- `PEDIDO_RETRASADO`
- `EQUIPO_FALLANDO`
- `LIMPIEZA_INCOMPLETA`
- `PEDIDO_MAL_ENTREGADO`
- `CLIENTE_NO_ATENDIDO`
- `PROVEEDOR_NO_ENTREGO`
- `OTRO`

### 5.2 Campos mínimos

Cada incidencia registra:

- `incident_id`;
- empresa/sucursal;
- fecha/hora servidor;
- turno;
- canal de origen;
- reportado por;
- tipo;
- descripción original;
- proceso afectado;
- responsable funcional vigente;
- persona señalada si el reportante la indicó;
- evidencia opcional;
- impacto observable;
- pedido/venta afectada cuando exista;
- severidad operacional;
- estado;
- respuesta del responsable;
- causa confirmada o `UNKNOWN`;
- resolución;
- fecha cierre;
- aprobador/revisor cuando corresponda.

### 5.3 Principio de no culpabilidad automática

`RESPONSABLE_FUNCIONAL` no equivale a `CULPABLE`.

Ejemplo:

La cajera reporta:

> “No pude vender Coca-Cola 600 porque no había stock.”

El sistema puede determinar:

- proceso: `ABASTECIMIENTO_SALA`;
- responsable funcional vigente: Samira;
- impacto: venta perdida/alternativa ofrecida;
- estado: `OPEN`.

Luego Samira responde:

> “Proveedor no entregó pese al pedido realizado ayer.”

La causa puede pasar a `PROVEEDOR_NO_ENTREGO` con evidencia. El historial conserva ambas versiones.

---

## 6. Canal WhatsApp para incidencias

WhatsApp puede ser un canal de entrada, pero **el número de teléfono por sí solo no debe ser identidad suficiente**.

### Vinculación inicial

Una persona autorizada vincula su WhatsApp a su identidad IQ GROWTH mediante proceso de pairing/confirmación.

El sistema conserva:

- persona/usuario vinculado;
- número/canal asociado;
- fecha de vinculación;
- empresa/sucursal;
- estado activo/revocado.

### Flujo conceptual

```text
WhatsApp empleado
    ↓
mensaje / foto / audio
    ↓
identidad vinculada
    ↓
IA extrae propuesta de incidencia
    ↓
TIPO + PROCESO + POSIBLE RESPONSABLE + FECHA + EVIDENCIA
    ↓
confirmación del remitente si hay ambigüedad
    ↓
INCIDENCIA OPERATIVA
    ↓
notificación al responsable
    ↓
respuesta / resolución / cierre
```

La IA nunca debe acusar automáticamente a una persona. Puede proponer el proceso y el responsable configurado.

### Ejemplo

Mensaje desde WhatsApp vinculado de la cajera:

> “Hoy no pude entregar Coca 600 porque se terminó.”

Salida propuesta:

```text
Tipo: SIN_STOCK_BEBIDA
Reporta: Cajera X
Proceso: ABASTECIMIENTO_SALA
Responsable funcional: Samira
Impacto: producto no disponible
Fecha/hora: servidor
Estado: OPEN
```

Si hay duda, preguntar antes de registrar una conclusión material.

---

## 7. Estados de incidencia

MVP:

- `OPEN`
- `ACKNOWLEDGED`
- `IN_REVIEW`
- `RESOLVED`
- `DISMISSED_WITH_REASON`

No borrar incidencias.

Correcciones generan historial.

---

## 8. Métricas de responsabilidad

El sistema NO debe crear un “puntaje de empleado” opaco.

Debe mostrar hechos medibles por persona/rol/proceso:

- incidencias asignadas;
- incidencias reconocidas;
- tiempo hasta respuesta;
- tiempo hasta resolución;
- recurrencia por tipo;
- turnos afectados;
- faltantes atribuibles al proceso;
- pedidos/ventas afectados cuando pueda medirse;
- puntualidad;
- asistencia;
- tareas de apertura/cierre completadas;
- observaciones y explicaciones.

Cualquier evaluación laboral/adversa posterior requiere revisión humana y cumplimiento jurisdiccional.

---

## 9. Asistencia y horarios

### 9.1 Dispositivo primario

La pantalla táctil de 23 pulgadas en caja será el **terminal primario de check-in/check-out** de VANSAM.

Razones:

- está en sala;
- es más fluida que la tablet de cocina;
- sirve como punto central del turno;
- permite timestamp servidor y control de sucursal.

### 9.2 Identificación

MVP recomendado:

1. empleado selecciona/escanea su identidad;
2. introduce PIN personal o credencial individual;
3. sistema registra `CHECK_IN` con hora servidor y dispositivo;
4. al salir repite para `CHECK_OUT`.

No usar un PIN compartido.

No permitir que la cajera marque asistencia de otros salvo flujo excepcional auditado.

### 9.3 Correcciones

Si alguien olvidó marcar:

- solicita corrección;
- indica hora declarada y motivo;
- un responsable autorizado aprueba/rechaza;
- nunca se modifica silenciosamente el evento original.

### 9.4 Limpieza final

El turno no termina automáticamente a las 23:00/23:30.

Debe distinguirse:

- `SERVICE_END_TABLE = 23:00`;
- `SERVICE_END_TAKEAWAY = 23:30`;
- `CLEANING_START`;
- `SECTOR_CLOSED`;
- `CHECK_OUT`.

La salida laboral real es el `CHECK_OUT`, no el último pedido.

### 9.5 Geolocalización/biometría

No requerida para MVP.

La terminal física de sucursal + credencial individual + timestamp servidor ofrece menor fricción y menor riesgo de privacidad.

Si en el futuro se requieren controles adicionales, deben evaluarse legalmente antes de usar biometría o geolocalización individual.

---

## 10. Tareas recurrentes y checklist

No todo debe convertirse en incidencia.

Procesos previsibles deben ser tareas/checklists:

### Apertura

- caja lista;
- POS online;
- bebidas críticas disponibles;
- masa/preparaciones listas;
- insumos críticos disponibles;
- equipos operativos;
- salón listo.

### Durante operación

- reposición;
- control de faltantes;
- tiempos;
- limpieza continua;

### Cierre

- último servicio;
- caja cerrada;
- cocina limpia;
- sala limpia;
- equipos apagados según procedimiento;
- stock crítico reportado;
- incidencias abiertas revisadas.

Una tarea incumplida puede generar incidencia automática o propuesta de incidencia según severidad.

---

## 11. Separación de pantallas/dispositivos

### PC táctil 23" — CAJA / OPERACIÓN DE SALA

Funciones primarias:

- check-in/check-out;
- POS/caja;
- atención de pedidos;
- salón / llevar / delivery cuando corresponda;
- pagos;
- disponibilidad de bebidas/sala;
- incidencias rápidas;
- apertura/cierre de turno;
- panel de tareas de sala.

### Tablet 13" — KITCHEN DISPLAY

Debe ser deliberadamente ligera.

Funciones primarias:

- pedidos pendientes;
- línea PIZZA/HAMBURGUESA;
- tamaños/modificadores muy visibles;
- tiempos;
- estado preparación;
- listo;
- alertas de faltante/incidencia de cocina;
- checklist mínimo de cocina.

NO cargar administración, reportes complejos ni funciones de caja en esta tablet.

### TV 42" — CUSTOMER DISPLAY / PROMOTION

Pantalla sin privilegios operativos.

Puede mostrar:

- pedido del cliente antes de confirmar;
- tamaño/productos/extras;
- total;
- promociones y cross-sell generados/propuestos por IA;
- confirmación visual;
- estado básico del pedido cuando corresponda;
- QR/registro/feedback.

La IA puede proponer ofertas, pero no debe cambiar precio ni agregar producto sin aprobación/confirmación.

---

## 12. IA en responsabilidades e incidencias

IA puede:

- clasificar texto/audio/foto;
- detectar posible proceso responsable;
- detectar recurrencia;
- resumir incidentes;
- identificar tendencias;
- sugerir causa;
- sugerir acción preventiva;
- detectar contradicciones;
- pedir aclaración;
- alertar de posible error de dato.

IA no puede:

- declarar culpabilidad laboral;
- sancionar;
- descontar salario;
- despedir;
- cambiar sueldo;
- inventar responsabilidad no configurada;
- cerrar unilateralmente una disputa entre personas.

---

## 13. Scorecard remoto del dueño

Iván debe poder ver remotamente, sin operar VANSAM:

- ¿abrió a tiempo?;
- quién hizo check-in;
- personal faltante;
- ventas/pedidos/pizzas;
- disponibilidad operacional;
- faltantes críticos;
- incidencias nuevas;
- incidencia recurrente por proceso;
- pedidos retrasados;
- cierre completado;
- hora real de cierre del personal;
- acción prioritaria del día;
- tendencia 7 días;
- costos desactualizados/anómalos.

No debe requerir WhatsApp manual a Samira para conocer el estado normal del negocio.

---

## 14. Principio de independencia

La operación objetivo es:

> **VANSAM funciona correctamente sin que Iván tenga que trabajar físicamente en el local y, una vez estabilizada, sin depender de que Samira esté presente todos los días.**

El sistema debe medir dependencia de persona clave:

- procesos con un único responsable;
- ausencia sin respaldo;
- cierres causados por ausencia;
- tareas críticas no delegadas.

---

## 15. Gate antes de implementación

Antes de Codex:

1. cerrar IQG-001.2;
2. definir jornadas reales de hornero/armador y mesera/cajera;
3. validar estructura salarial/laboral;
4. confirmar responsabilidades de Samira;
5. definir quién prepara masa y desde qué hora;
6. definir checklists de apertura/cierre;
7. probar flujo de incidencia en papel/WhatsApp manual antes de automatizar;
8. definir identidad/vinculación WhatsApp futura;
9. validar UX por dispositivo.

**CEO_ACTION_REQUIRED:** false para arquitectura; faltan parámetros operativos para cerrar el modelo VANSAM.