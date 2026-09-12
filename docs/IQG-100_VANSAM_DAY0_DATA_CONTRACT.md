# IQG-100 — VANSAM Day 0 Data Contract

**Proyecto:** IQ GROWTH  
**Laboratorio:** VANSAM  
**Estado:** canónico para preparación del piloto; no implementación  
**Autoridad:** Iván Quea — CEO / Product Owner

---

## 1. Propósito

Definir qué datos deben confirmarse antes de calcular el baseline del piloto de 30 días.

Ninguna cifra histórica usada en conversaciones, challenges de IA o estimaciones preliminares se convierte automáticamente en baseline.

El Día 0 existe para separar:

`DATO CONOCIDO` de `HIPÓTESIS` de `ESTIMACIÓN` de `DATO FALTANTE`.

---

## 2. Estado epistemológico por dato

Cada input debe llevar uno de:

- `OBSERVED_CURRENT` — observado/obtenido directamente y vigente;
- `DOCUMENT_SUPPORTED` — respaldado por documento vigente;
- `OWNER_CONFIRMED` — confirmado por Iván/Samira pero sin evidencia documental cargada;
- `SYSTEM_CALCULATED` — calculado a partir de inputs identificados;
- `ESTIMATED` — aproximación declarada;
- `STALE` — conocido pero posiblemente desactualizado;
- `UNKNOWN` — no disponible.

El motor no debe ocultar esta clasificación.

---

## 3. Calendario operativo

Campos mínimos:

- sucursal;
- zona horaria;
- días planificados de apertura por semana;
- horario por día;
- días de descanso;
- cierres planificados;
- cierres no planificados de los últimos 30 días;
- motivo del cierre cuando se conozca;
- horas efectivamente disponibles para vender.

### Regla

El objetivo diario no puede dividir simplemente costos mensuales entre 30 si el negocio no opera 30 días.

---

## 4. Costos fijos

Cada costo fijo debe registrarse individualmente:

- `cost_id`;
- concepto;
- monto;
- moneda;
- periodicidad;
- fecha de vigencia;
- empresa/sucursal;
- incluido en objetivo de cobertura: sí/no;
- evidencia/confirmación;
- estado epistemológico;
- notas.

Categorías iniciales candidatas:

- alquiler;
- salarios/remuneraciones fijas;
- luz base;
- agua;
- internet;
- software/servicios recurrentes;
- mantenimiento fijo;
- otros compromisos recurrentes.

No clasificar automáticamente como fijo un costo que dependa del volumen.

---

## 5. Costos variables

El piloto permite precisión progresiva.

Métodos permitidos:

### EXACT_PRODUCT
Costo estimado por producto/tamaño desde receta/insumos suficientemente actualizados.

### CATEGORY_PERCENT
Porcentaje aproximado de costo variable sobre venta por categoría.

### UNIT_ESTIMATE
Costo variable estimado por unidad/ticket.

### HYBRID
Productos principales exactos + resto por categoría.

Cada método registra:
- fuente;
- fecha de última actualización;
- cobertura del catálogo;
- confianza;
- supuestos.

No exigir `EXACT_PRODUCT` para activar el primer valor.

---

## 6. Ventas

Fuente inicial preferida: datos del POS VANSAM cuando sean utilizables.

Campos mínimos por hecho de venta observado:

- fecha/hora;
- order/legacy id;
- líneas;
- producto/categoría;
- cantidad;
- precio observado;
- descuento observado cuando exista;
- total observado;
- canal/tipo de pedido cuando exista;
- estado de calidad.

### Restricción legado

V11 no debe usarse para declarar automáticamente:
- pago efectivamente recibido;
- caja conciliada;
- utilidad neta;
- inventario histórico exacto.

El piloto debe distinguir `ORDER_OBSERVED` de `PAID_SALE_VERIFIED` cuando la fuente no permita confirmar ambos.

---

## 7. Productos y categorías

Mínimo:

- producto;
- categoría;
- tamaño/variante cuando aplique;
- precio vigente;
- activo/inactivo;
- costo variable disponible;
- método de costo;
- contribución estimada;
- fecha de vigencia.

No duplicar precios sin autoridad de fuente.

---

## 8. Clientes

Opcional para activar cálculo económico; necesario para acciones de recuperación.

Campos mínimos cuando exista base válida:

- identificador interno;
- nombre cuando corresponda;
- teléfono/WhatsApp cuando corresponda;
- consentimiento/base de uso pendiente de capa jurisdiccional;
- primera compra observada;
- última compra observada;
- frecuencia observada;
- gasto/contribución acumulada estimada;
- fuente/calidad.

No considerar dos teléfonos parecidos como misma persona por inferencia automática.

---

## 9. Capacidad y tiempos

Inputs simples para VANSAM:

- hora del pedido;
- hora de inicio de preparación cuando exista;
- hora listo cuando exista;
- hora entrega/salida cuando exista;
- número de pedidos simultáneos;
- incidencias del horno/equipo;
- personal presente;
- cierre/indisponibilidad.

Si V11 no conserva estos eventos con calidad suficiente, el piloto puede capturarlos prospectivamente.

---

## 10. Disponibilidad / faltantes

Mínimo operacional:

- producto/insumo afectado;
- inicio de faltante;
- fin;
- causa conocida;
- pedidos/ventas potencialmente afectados cuando sean observables;
- acción tomada.

No exigir inventario perpetuo exacto en el primer piloto.

---

## 11. Registro de confusores

Durante baseline/piloto debe existir un log simple de:

- cierre;
- enfermedad/viaje;
- cambio de personal;
- horno/equipo;
- cambio de horario;
- precio;
- promoción;
- faltante;
- feriado/evento local;
- problema de servicio;
- otro evento material.

Cada confusor lleva fecha, duración y nota.

---

## 12. Métricas derivadas permitidas

Con datos suficientes se puede calcular:

- ventas observadas;
- margen de contribución estimado;
- objetivo de cobertura;
- brecha/excedente;
- operaciones/unidades por día;
- ticket promedio observado;
- contribución estimada por ticket;
- contribución estimada por producto/categoría;
- frecuencia/recencia de clientes;
- disponibilidad;
- tiempos operativos observados.

Cada métrica debe heredar calidad/confianza de sus inputs.

---

## 13. Gate Día 0

### READY_FOR_PILOT

Solo si:

- calendario operativo actual confirmado;
- costos fijos relevantes identificados;
- ventas recientes utilizables;
- método de costo variable definido al menos de forma aproximada;
- no existe contradicción material no resuelta en los inputs mínimos;
- se puede calcular una brecha con confianza al menos MEDIA.

### READY_WITH_LIMITATIONS

Si puede calcularse la brecha pero existen limitaciones explícitas que no invalidan el piloto.

### NOT_READY

Si falta información suficiente para que el estado económico sea útil o si los datos de ventas no son confiables.

En `NOT_READY`, la primera recomendación del sistema es cerrar la brecha de datos, no una acción comercial.

---

## 14. Día 0 no implica contabilidad oficial

El contrato de datos del piloto es para gestión y validación de producto.

No sustituye:
- contabilidad;
- conciliación bancaria;
- declaración fiscal;
- estados financieros;
- auditoría.

Los cálculos derivados deben conservar esa separación terminológica.

---

## 15. Resultado esperado del Día 0

El piloto no empieza con un número heredado de una conversación.

Debe producir una ficha versionada:

```text
VANSAM BASELINE V1
Periodo: ...
Calendario confirmado: ...
Costos fijos incluidos: ...
Método de costo variable: ...
Fuente de ventas: ...
DATA_COMPLETENESS: ...
DATA_FRESHNESS: ...
DATA_CONFIDENCE: ...
Limitaciones: ...
Aprobado para piloto por: ...
```

Toda modificación posterior crea una nueva versión del baseline.

**CEO_ACTION_REQUIRED:** false hasta que deba confirmarse el baseline real.
