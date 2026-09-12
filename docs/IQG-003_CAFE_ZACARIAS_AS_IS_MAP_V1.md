# IQG-003 — Café Don Zacarías AS-IS Map V1

**Fecha:** 2026-09-12
**Estado:** mapa operativo real inicial, previo a implementación
**Autoridad de negocio:** Iván Quea — CEO / Product Owner

## 1. Propósito

Capturar cómo funciona hoy y cómo se expande Café Don Zacarías desde finca hasta venta, separando hechos confirmados, estimaciones y datos todavía desconocidos.

Estados usados:
- `CEO_CONFIRMED`
- `CEO_ESTIMATED`
- `CEO_PROPOSED`
- `UNKNOWN/TO_VERIFY`

## 2. Finca y superficie

| Campo | Valor | Estado |
|---|---:|---|
| Superficie finca familiar | 10 ha | CEO_CONFIRMED |
| Superficie actualmente productiva | 4 ha | CEO_CONFIRMED |
| Manejo actual | no tecnificado | CEO_CONFIRMED |
| Expansión evaluada | +2 a +4 ha | CEO_PROPOSED |
| Edad plantación productiva | 15–20 años aprox. | CEO_ESTIMATED |
| Variedad histórica recordada | Caturra | CEO_CONTEXT |
| Variedades actuales exactas | pendiente | UNKNOWN/TO_VERIFY |

Contexto regional del CEO: propiedades de la zona pueden tener aproximadamente 10–40 ha y su valor depende de productividad, ubicación y lo que contiene el predio. No usar como tasación.

## 3. Implantación / expansión

Para cada nueva hectárea debe registrarse como proyecto de inversión agrícola:
- superficie planificada;
- desmonte/preparación;
- plantines requeridos/comprados/producidos;
- hoyado/plantación;
- mano de obra;
- herramientas/equipos;
- alimentación/hospedaje si existe;
- transporte;
- pérdidas/reposición de plantines;
- costo total;
- fecha de inicio/fin;
- responsable;
- evidencia.

Referencia del CEO:
- implantación/inversión: ~Bs 5.000–8.000/ha (`CEO_ESTIMATED`);
- costo exacto de plantines: `UNKNOWN`;
- falta verificar si Bs 5.000–8.000 incluye plantines, jornales, herramientas y todos los componentes o solo parte del proceso.

## 4. Mano de obra agrícola

Modalidades reales a soportar:
- trabajo propio/familiar;
- jornal;
- cuadrilla;
- contrato cerrado por labor;
- pago por unidad producida/recolectada;
- tercero/proveedor de servicios.

Referencia actual:
- jornal ~Bs 100/día (`CEO_ESTIMATED`).

El sistema debe registrar además costos no monetarios/directos asociados al trabajo:
- desayuno;
- almuerzo;
- cena;
- hospedaje;
- transporte;
- herramientas/combustible cuando la empresa los aporta.

Nunca mezclar `pago_jornal` con `costo_total_labor`.

## 5. Labores recurrentes

### Confirmadas/referidas
- deshierbe periódico;
- machete;
- motodesyerbadora;
- motosierra para determinadas labores;
- picota para plantación/preparación.

### Por verificar
- fumigación: el CEO no ha observado que se realice actualmente;
- productos usados;
- frecuencia;
- dosis;
- responsable;
- costo.

Cada labor debe poder relacionarse con:
- parcela/hectárea;
- fecha;
- superficie atendida;
- personas/cuadrilla;
- modalidad de pago;
- herramienta/equipo;
- combustible/insumos;
- horas/jornales;
- costo;
- incidencia;
- evidencia.

## 6. Cosecha

Modelo real:
- cosecha manual con jornaleros cuando el volumen lo exige;
- pago por lata como unidad operativa;
- referencia desde ~Bs 25/lata (`CEO_ESTIMATED`);
- alimentación y hospedaje cuando corresponde.

IQ GROWTH debe preservar la unidad original `LATA` aunque después exista una conversión verificada a kg.

Cada evento de cosecha registra:
- parcela;
- fecha;
- recolector/cuadrilla;
- latas/unidad original;
- peso si se mide;
- tarifa vigente;
- pago monetario;
- alimentación;
- hospedaje;
- transporte;
- total costo cosecha;
- lote/cosecha de destino.

## 7. Beneficio diario

La cosecha del día requiere procesamiento posterior; el despulpado no debe quedar desacoplado del evento de cosecha.

Registrar:
- cantidad recibida;
- hora inicio/fin;
- despulpadora/equipo;
- operador;
- café resultante;
- sultana/cáscara resultante;
- agua/energía/combustible cuando aplique;
- merma;
- incidencia;
- lote de salida.

La sultana se modela como `COPRODUCT`, no como merma automática.

## 8. Secado en origen

Riesgo crítico confirmado: lluvia/humedad.

Debe existir responsable explícito de secado y eventos de:
- extender;
- mover;
- recoger/cubrir;
- medir humedad;
- reanudar secado;
- incidencia por lluvia;
- daño/calidad afectada.

Recursos configurables:
- cachi/cache/superficie local;
- cama africana;
- secador;
- infraestructura futura.

El sistema debe poder medir pérdida económica por una incidencia de lluvia sin declarar causalidad si no hay evidencia suficiente.

## 9. Transporte finca → Senkata

Referencia CEO: ~Bs 60/saco (`CEO_ESTIMATED`).

Cada movimiento logístico debe registrar:
- origen;
- destino;
- fecha;
- lote;
- sacos/unidad original;
- peso cuando exista;
- transportista;
- tarifa;
- costo total;
- humedad/situación salida;
- humedad/situación recepción;
- pérdida/daño/incidencia.

La tarifa cambia por fecha; nunca se reescribe el pasado.

## 10. Planta El Alto / Senkata — mapa funcional pendiente

La planta será el siguiente submapa detallado.

Procesos ya definidos:
1. recepción del lote;
2. estabilización/final de secado;
3. medición de humedad;
4. almacenamiento intermedio;
5. trilla;
6. selección/clasificación;
7. separación por calidad/defecto;
8. café verde para exportación/venta;
9. tostado especial;
10. torrado/caramelado;
11. molienda;
12. empaque;
13. almacenamiento terminado;
14. despacho a vendedores/puntos/clientes.

Para cada etapa se deberá mapear:
- máquina/equipo;
- operador;
- capacidad nominal/real;
- tiempo;
- consumo;
- mantenimiento;
- lote entrada/salida;
- rendimiento;
- merma;
- calidad;
- costo;
- responsable;
- incidencia.

## 11. Planta compartida Café + Chocolate

Hecho de diseño confirmado:
- ambas líneas compartirán la planta de Senkata.

Regla:
`SHARED_FACILITY != SHARED_INVENTORY`.

Un mismo edificio/recurso/equipo puede atender múltiples líneas, pero debe quedar separado:
- negocio/marca;
- lote;
- inventario;
- formulación;
- responsable;
- tiempo de uso;
- consumo;
- costo asignado;
- ingreso/venta.

## 12. Distribución multimarcas

Un mismo vendedor, carrito o vehículo puede llevar Café Don Zacarías y Chocolates La Florita.

Debe rendir por salida/ruta:
- stock inicial por producto/marca;
- transferencias recibidas;
- ventas;
- precios/canales;
- cobros;
- devoluciones;
- muestras/promociones;
- merma/faltante;
- gastos de ruta;
- stock final;
- caja final.

El vendedor no necesita dos sistemas; usa una sola sesión/contexto autorizado con inventarios separados.

## 13. Portafolio café propuesto

Cuatro familias/líneas comerciales iniciales (`CEO_PROPOSED`):
- Torrado Base ~Bs 50–60/kg;
- Torrado Premium ~Bs 80/kg;
- Especial Base ~Bs 120/kg;
- Especial Premium ~Bs 160/kg.

Presentaciones deben soportar desde ~60 g a 1 kg o más y venta por peso variable cuando corresponda.

El precio final depende de:
- presentación;
- canal;
- ciudad/zona;
- mayorista/minorista;
- fecha;
- promoción/acuerdo;
- costo y margen objetivo.

## 14. Datos todavía críticos por levantar

- variedades actuales por parcela;
- densidad/número de plantas;
- producción por hectárea/lote;
- calendario real de labores;
- costo detallado de implantación;
- precio/cantidad de plantines;
- consumo combustible de equipos;
- rendimiento de cosecha por jornal/lata;
- conversiones reales lata↔kg y saco↔kg;
- humedad objetivo por etapa;
- capacidad/estado de despulpadora y secadores;
- máquinas actuales/planificadas de Senkata;
- operadores actuales/futuros;
- costos por proceso de planta;
- catálogo definitivo de empaques;
- rutas/puntos de venta iniciales.

## 15. Siguiente subfase

`CAFE_PLANT_PROCESS_MAP_V1`

Desglosar Senkata desde recepción hasta empaque y despacho, máquina por máquina y rol por rol.

**Estado:** `CAFE_AS_IS_PRIMARY_PRODUCTION_MAPPED`
**CEO_ACTION_REQUIRED:** false hasta que haya decisiones de inversión/maquinaria concretas.
