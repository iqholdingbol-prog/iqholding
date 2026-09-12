# IQG-003 — Café Don Zacarías Vertical V2

**Fecha:** 2026-09-12
**Estado:** diseño de vertical, no implementación
**Autoridad de negocio:** Iván Quea — CEO / Product Owner
**Objetivo:** usar Café Don Zacarías como laboratorio agroindustrial completo para demostrar que IQ GROWTH soporta inversión agrícola, labores por campaña, cosecha, beneficio, secado, transformación, trazabilidad, manufactura, exportación, distribución móvil/fija y venta multicanal sin modificar el Core universal.

## 1. Tipo de negocio

`LAND_DEVELOPMENT + AGRICULTURE + FIELD_LABOR + HARVEST + PRIMARY_PROCESSING + DRYING + LOGISTICS + INDUSTRIAL_PROCESSING + MANUFACTURING + PACKAGING + WHOLESALE + RETAIL + MOBILE_COMMERCE + EXPORT`

El vertical no empieza en la planta ni en la venta. Empieza desde la decisión de invertir en un terreno y acompaña el producto hasta el cliente final.

## 2. Cadena end-to-end real

```text
EVALUAR TERRENO
  ↓
DEFINIR ÁREA / HECTÁREAS A IMPLANTAR
  ↓
DESMONTE / PREPARACIÓN DE TERRENO
  ↓
COMPRA / PRODUCCIÓN DE PLANTINES
  ↓
PLANTACIÓN
  ↓
MANTENIMIENTO DEL CULTIVO
  ├─ deshierbe periódico
  ├─ fumigación / manejo definido por finca
  ├─ machete / motodesyerbadora / otros recursos
  └─ trabajo propio o contratado
  ↓
COSECHA
  ├─ jornaleros
  ├─ pago por jornada o unidad (ej. lata)
  ├─ desayuno / almuerzo / cena cuando corresponda
  └─ hospedaje cuando corresponda
  ↓
BENEFICIO DIARIO POST-COSECHA
  ├─ despulpado
  ├─ café pergamino
  └─ sultana/cáscara como coproducto aprovechable
  ↓
SECADO EN ORIGEN
  ├─ cachis/caches o superficies de secado usadas localmente
  ├─ camas africanas
  ├─ secadores u otra tecnología
  ├─ riesgo de lluvia
  └─ decisiones de recoger/cubrir/mover producto
  ↓
TRANSPORTE YUNGAS → EL ALTO / SENKATA
  ↓
PLANTA
  ├─ terminar/estabilizar secado
  ├─ control de humedad
  ├─ trilla
  ├─ selección/clasificación
  └─ almacenamiento
  ↓
DESTINO A: EXPORTACIÓN VERDE o TRANSFORMACIÓN
  ↓
TOSTADO
  ├─ café especial
  ├─ café torrado/caramelado de primeras
  └─ café torrado/caramelado de descartes (“basuritas”)
  ↓
MOLIENDA / EMPAQUE
  ↓
DISTRIBUCIÓN
  ├─ punto fijo
  ├─ feria
  ├─ puesto callejero
  ├─ carrito/venta ambulante
  ├─ vehículo de venta
  ├─ mayorista
  └─ exportación / B2B
  ↓
VENTA Y RECOMPRA
```

## 3. Antes de plantar: inversión y diseño agrícola

IQ GROWTH debe soportar una unidad de inversión agrícola desde cero.

Por cada proyecto/parcela:
- finca/localización;
- superficie total;
- superficie a intervenir;
- hectáreas planificadas;
- hectáreas efectivamente implantadas;
- fecha de inicio;
- presupuesto;
- responsables;
- variedad(es);
- densidad/distancia de plantación cuando se registre;
- cantidad de plantines requerida;
- cantidad comprada/producida;
- costo por plantín/lote;
- proveedor/origen;
- pérdidas de plantines;
- reposición;
- evidencia/documentos.

## 4. Mano de obra agrícola configurable

El sistema no asume una única modalidad.

Una labor puede ejecutarse:
- por propietario/familia;
- por jornal;
- por contrato cerrado;
- por unidad producida/recogida;
- por cuadrilla;
- por tercero/proveedor de servicio.

Eventos agrícolas iniciales:
- desmonte;
- preparación;
- hoyado/plantación;
- resiembra;
- deshierbe;
- fumigación/tratamiento cuando corresponda;
- poda/manejo futuro;
- cosecha;
- beneficio;
- secado;
- transporte.

Cada labor registra:
- parcela/campaña;
- actividad;
- fecha/periodo;
- persona/cuadrilla/contratista;
- modalidad de pago;
- unidad (jornada, contrato, lata, kg, ha, etc.);
- cantidad;
- tarifa;
- alimentación/hospedaje/transporte adicionales;
- herramientas/equipos usados;
- costo total observado;
- evidencia;
- incidencia/resultados.

Las obligaciones laborales/comerciales aplicables pertenecen al Compliance Layer; el vertical registra la realidad operacional.

## 5. Recursos y equipos de campo

El Core debe modelar recursos genéricos; Café activa semántica agrícola.

Ejemplos:
- machetes;
- motodesyerbadoras;
- despulpadora;
- herramientas de fumigación/manejo;
- camas africanas;
- secadores;
- depósitos;
- transporte.

Por recurso:
- propietario;
- ubicación;
- disponibilidad;
- capacidad;
- combustible/energía;
- mantenimiento;
- horas/uso;
- operador;
- costo;
- incidencia.

## 6. Cosecha y pago por unidad

La cosecha debe soportar pago por:
- jornal;
- lata;
- kg;
- qq;
- contrato;
- otra unidad configurada.

Por cosechador/cuadrilla:
- fecha;
- parcela;
- cantidad cosechada;
- unidad;
- tarifa vigente;
- pago calculado;
- pago observado;
- alimentación entregada;
- hospedaje;
- anticipos;
- evidencia;
- calidad/incidencias si se mide.

Nunca hardcodear `lata` como unidad universal: es una unidad operacional configurable y convertible cuando exista equivalencia verificada.

## 7. Beneficio húmedo diario y coproductos

La cereza cosechada del día debe tener trazabilidad hacia el beneficio realizado ese mismo día o el flujo realmente ocurrido.

Registrar:
- cereza recibida;
- lote/parcela origen;
- peso/volumen;
- hora/fecha;
- despulpadora usada;
- operador;
- salida principal;
- merma;
- agua/proceso si se decide medir;
- incidencias.

Coproducto importante:
- `SULTANA/CASCARA_DE_CAFE`.

La sultana no se modela como basura por defecto: puede ser coproducto con cantidad, secado, inventario, costo atribuible y venta propios.

## 8. Secado en clima húmedo y transferencia a El Alto

El secado es un proceso crítico y sensible a lluvia/humedad.

IQ GROWTH debe registrar:
- método de secado;
- ubicación;
- fecha/hora de inicio/fin;
- lote;
- cantidad;
- humedad medida cuando exista;
- responsable;
- eventos de lluvia;
- recogida/cobertura/reubicación;
- horas interrumpidas;
- merma/contaminación/incidencia;
- costo.

Métodos configurables:
- cachis/caches usados por la finca;
- camas africanas;
- secador mecánico/solar/otro;
- combinaciones.

Contexto operativo de Café Don Zacarías:
- en zona húmeda el producto seco puede volver a absorber humedad;
- parte del producto se transporta a El Alto/Senkata para terminar o estabilizar secado;
- en El Alto el ambiente facilita conservar mejor el producto seco.

El sistema debe permitir una misma etapa productiva distribuida entre ubicaciones sin romper trazabilidad.

## 9. Logística Yungas → planta Senkata/El Alto

Cada traslado debe conservar:
- lote(s);
- origen;
- destino;
- cantidad salida;
- cantidad recepción;
- unidad;
- humedad/calidad salida y recepción cuando exista;
- vehículo/transportista;
- responsable;
- costo transporte;
- fecha/hora;
- pérdidas/diferencias;
- evidencia.

## 10. Planta Senkata/El Alto

Procesos esperados:
- recepción;
- estabilización/finalización de secado;
- almacenamiento;
- trilla de pergamino;
- selección/clasificación;
- preparación de verde para venta/exportación;
- tostado;
- molienda;
- empaque.

Cada transformación consume lotes y crea lotes de salida sin reescribir el pasado.

## 11. Calidad y clasificación

Eventos configurables:
- humedad;
- defectos;
- descarte;
- clasificación;
- tamaño/malla cuando aplique;
- catación;
- puntuación;
- notas sensoriales;
- aceptación/rechazo;
- responsable/evaluador;
- evidencia.

Estado actual conocido del proyecto: café de finca referido alrededor de 85 puntos; tratar como contexto hasta existir registro de catación/lote verificable.

## 12. Rutas de producto

El mismo origen puede terminar en distintos destinos:

### A. Verde/exportación
`PERGAMINO → TRILLA → SELECCIÓN → VERDE → EXPORTACIÓN/B2B`

### B. Especial tostado
`VERDE CALIDAD ESPECIAL → TOSTADO → MOLIENDA OPCIONAL → EMPAQUE`

### C. Torrado/caramelado
Puede usar:
- café de primera destinado a esa línea;
- descartes/subproductos aptos según criterio del negocio;
- clasificación comercial separada.

La línea torrada nunca debe mezclarse silenciosamente con especial: origen, calidad, costo, formulación/proceso y lote deben quedar separados.

## 13. Portafolio comercial inicial propuesto por CEO

Configuración comercial deseada, todavía sujeta a validación de costos/precios:

1. `TORRADO_BASE` — referencia objetivo aprox. Bs 50–60/kg.
2. `TORRADO_PREMIUM` — referencia objetivo aprox. Bs 80/kg.
3. `ESPECIAL_BASE` — referencia objetivo aprox. Bs 120/kg.
4. `ESPECIAL_PREMIUM` — referencia objetivo aprox. Bs 160/kg.

Cada línea deberá distinguirse visualmente, potencialmente mediante colores/envases diferentes.

**Regla:** estos precios son `CEO_PROPOSED`, no `CURRENT_VERIFIED_PRICE`, hasta confirmar presentación, costo, peso, canal y margen.

## 14. Presentaciones y unidades

Café puede venderse desde aproximadamente 60 g hasta 1 kg o más.

El sistema debe soportar:
- g;
- kg;
- lb;
- qq;
- saco;
- lata u otras unidades operativas;
- conversiones verificadas;
- presentación fija;
- peso variable;
- venta fraccionada;
- venta por mayor volumen.

Ejemplos:
- 60 g;
- 100 g;
- 250 g;
- 500 g;
- 1 kg;
- >1 kg configurado por pedido.

No crear un SKU nuevo manualmente por cada combinación cuando pueda modelarse como `producto base + variante + presentación + unidad + precio vigente`.

## 15. Canales y puntos de venta universales

La comercialización no puede asumir tienda fija.

Tipos de punto/canal:
- tienda física;
- puesto fijo callejero;
- feria temporal;
- carrito ambulante;
- vendedor ambulante;
- vehículo de venta;
- distribuidor;
- mayorista;
- B2B;
- e-commerce/futuro;
- exportación.

Cada punto puede tener:
- ubicación fija, zona o ruta;
- responsable;
- inventario asignado;
- caja propia o compartida;
- horario/ciclo;
- gastos;
- ventas;
- devoluciones;
- incidencias;
- metas;
- margen;
- movilidad.

La configuración puede variar por ciudad: una estrategia válida en El Alto (ferias/puestos/ambulante) no se impone a Santa Cruz u otra ciudad.

## 16. Activos móviles de comercialización

Contexto actual a soportar:
- Toyota Hiace 1982 de IQHOLDING, mecánicamente operativa pero pendiente de laminado/adaptación para trabajo comercial;
- Ford Ranger 2008 de un hermano del CEO, posible activo de venta operado por ese vendedor, con propiedad separada de la empresa si corresponde.

Un vehículo no se vuelve automáticamente activo de la empresa por ser usado comercialmente. Registrar:
- propietario;
- empresa/relación de uso;
- conductor/vendedor;
- inventario cargado;
- ruta/zona;
- salida/retorno;
- ventas;
- combustible;
- gastos;
- mantenimiento;
- faltantes/sobrantes;
- caja/pagos;
- incidencias.

## 17. Growth Engine Café

Palancas potenciales por etapa:

### Finca
- costo por ha;
- supervivencia de plantines;
- productividad por parcela;
- costo de deshierbe/manejo;
- costo de cosecha por unidad;
- productividad de cuadrillas.

### Beneficio/secado
- rendimiento cereza→pergamino;
- rendimiento de sultana;
- tiempo de secado;
- pérdidas por lluvia;
- humedad;
- costo energético/laboral.

### Planta
- rendimiento pergamino→verde;
- % descarte;
- utilización de equipos;
- costo de trilla/tostado/molienda;
- calidad.

### Comercial
- margen por línea/presentación;
- margen por canal;
- rotación por punto;
- rendimiento por vendedor/ruta;
- recompra;
- mayorista vs minorista;
- costo de distribución;
- stock inmovilizado.

## 18. Preguntas que IQ GROWTH debe poder responder

- ¿Cuánto hemos invertido realmente desde preparar una hectárea hasta obtener café vendible?
- ¿Qué parcela/campaña produjo qué lote y cuánto costó?
- ¿Qué modalidad de trabajo fue más eficiente: propio, jornal, contrato o unidad?
- ¿Cuánto cuesta una lata/kg de cosecha incluyendo alimentación/hospedaje?
- ¿Dónde perdemos rendimiento o calidad?
- ¿Qué método de secado funciona mejor bajo lluvia/humedad?
- ¿Cuánto producto salió de Yungas y cuánto llegó a El Alto?
- ¿Qué porcentaje termina en especial, torrado, descarte, sultana o venta verde?
- ¿Cuál línea deja mayor contribución real?
- ¿Qué presentación y canal funciona mejor en cada ciudad?
- ¿Qué vendedor/punto/ruta vende y cobra correctamente?
- ¿Qué inventario lleva cada vehículo o puesto?
- ¿Qué acción concreta mejora rendimiento, calidad, rotación o margen?

## 19. Qué prueba este vertical para el Core universal

Café Don Zacarías obliga al Core a soportar:
- inversiones de largo plazo antes de vender;
- activos/terreno/parcela;
- unidades productivas;
- campañas no diarias;
- mano de obra multimodal;
- pagos por unidad/jornada/contrato;
- gastos accesorios de personal;
- equipos móviles y productivos;
- coproductos;
- múltiples transformaciones;
- humedad/calidad;
- logística entre ubicaciones;
- manufactura;
- unidades/pesos variables;
- presentaciones y variantes;
- exportación;
- venta fija y móvil;
- inventario por vendedor/vehículo/punto;
- mayorista/minorista;
- ciudades con modelos comerciales distintos.

**Gate:** `CAFE_VERTICAL_V2_END_TO_END_DEFINED`
**CEO_ACTION_REQUIRED:** false
