# IQG-005 — IPCENTER Vertical V1

**Fecha:** 2026-09-15
**Estado:** `DESIGN_CANONICAL_V1`
**Autoridad de negocio:** Iván Quea, CEO
**Relación:** vertical de IQ GROWTH; no es un Core separado.

## 1. Propósito
IPCenter es una empresa real de IQHOLDING en proceso de reactivación y el cuarto laboratorio vivo de IQ GROWTH. Su función es validar capacidades que VANSAM, Café Zacarías y Chocolates no fuerzan con la misma intensidad: Product Fit, sourcing, cotización, procurement, verificación de proveedores, serialización, logística, compliance, garantía y trazabilidad de una adquisición bajo pedido.

## 2. Posicionamiento
Identidad histórica: importación de laptops de gama alta.

Evolución objetivo:
> El cliente dice qué necesita; IPCENTER entiende la necesidad, encuentra alternativas, verifica fuentes/proveedores, cotiza y coordina la adquisición cuando sea viable.

No es una tienda que deba almacenar miles de SKUs. Debe poder operar con catálogo dinámico/bajo pedido.

## 3. Categorías
### Entrada controlada
- laptops;
- celulares.

### Expansión según evidencia
- drones;
- componentes/accesorios tecnológicos;
- repuestos automotrices;
- productos especializados difíciles de conseguir.

La expansión se decide por demanda, margen, riesgo, logística y cumplimiento, no por cantidad de categorías.

## 4. Flujo vertical
```text
CUSTOMER_REQUEST
    ↓
NEED / REQUIREMENTS
    ↓
PRODUCT_FIT
    ↓
PRODUCT_CANDIDATES
    ↓
SUPPLIER_OFFERS
    ↓
SUPPLIER_VERIFICATION
    ↓
QUOTE / ROUTE / PRICE
    ↓
CUSTOMER_APPROVAL
    ↓
PROCUREMENT
    ↓
RECEIPT / EVIDENCE
    ↓
LOGISTICS
    ↓
BOLIVIA RECEIPT / CONTROL
    ↓
DELIVERY
    ↓
WARRANTY / CRM / LEARNING
```

## 5. Separaciones inviolables
- `CUSTOMER_REQUEST != QUOTATION`
- `QUOTATION != CUSTOMER_ORDER`
- `CUSTOMER_ORDER != PROCUREMENT_ORDER`
- `ORDER != SALE`
- `SALE != PAYMENT`
- `PAYMENT != CASH_MOVEMENT`
- `PROCUREMENT != FULFILLMENT`
- `PRODUCT_MODEL != PHYSICAL_UNIT`

Una unidad física puede tener serial, IMEI, número de parte u otro identificador. El modelo del producto no debe confundirse con la unidad entregada.

## 6. Product Fit
El sistema debe poder capturar necesidad antes de sugerir producto. Ejemplo de laptop:
- uso/profesión;
- aplicaciones;
- presupuesto;
- movilidad/peso;
- batería;
- CPU/GPU/VRAM/RAM/SSD;
- pantalla;
- preferencia de marca cuando exista;
- urgencia.

Salida deseada: alternativas comparables con razones y nivel de confianza, no una recomendación opaca.

## 7. Sourcing y proveedores
Registrar por oferta:
- proveedor;
- URL/evidencia;
- producto/configuración exacta;
- precio y moneda;
- disponibilidad observada y fecha;
- condición: nuevo/usado/refurbished/etc.;
- garantía/devolución;
- reputación/evidencia;
- ubicación;
- riesgos/incertidumbre.

No inventar `Supplier Score` sin metodología documentada. Si se usa puntuación, debe guardar componentes, evidencia, fecha y fórmula/version.

## 8. Pricing
Separar vista interna y vista cliente.

### Interna
- costo producto;
- impuestos/tasas verificadas cuando correspondan;
- transporte/logística;
- seguros/comisiones;
- conversión monetaria y tipo de cambio usado;
- costo de gestión;
- reserva/garantía/riesgo cuando esté definida;
- margen comercial;
- precio final.

### Cliente
- producto/configuración;
- precio final;
- vigencia de cotización;
- plazo/rango estimado;
- condiciones;
- garantía;
- hitos de seguimiento aplicables.

El costo de adquisición y margen interno no son obligatoriamente visibles al cliente cuando IPCENTER compra y revende.

## 9. Modelos de ingreso posibles
- `COMMERCE`: IPCENTER compra y revende con margen.
- `SOURCING_SERVICE`: tarifa fija/porcentaje/híbrida por búsqueda/adquisición.
- `B2B_PROCUREMENT`: servicio de compras internacionales/tecnológicas para empresas.

Los porcentajes/márgenes no se canonizan hasta medir costo real, riesgo y mercado.

## 10. Compliance e importabilidad
La IA puede realizar preclasificación y reunir evidencia, pero no declarar legalidad material sin fuente/regla verificable.

Semáforo conceptual:
- `GREEN`: aparentemente viable según reglas/fuentes vigentes;
- `YELLOW`: requiere revisión;
- `ORANGE`: categoría especializada/regulada o evidencia insuficiente;
- `RED`: no operable por política/restricción confirmada.

Toda regla material debe llevar jurisdicción, fuente, fecha de vigencia y estado de verificación; integra IQG-120+, no crea un sistema legal paralelo.

## 11. Evidencia / Passport comercial
`IPCenter Passport` puede ser la presentación comercial del capability universal de provenance/custody/evidence.

Eventos posibles:
- selección;
- compra confirmada;
- recepción en nodo/origen;
- foto/estado/etiqueta;
- serial cuando corresponda;
- despacho;
- transporte;
- recepción Bolivia;
- control;
- entrega/conformidad;
- garantía/incidencia.

No prometer que un paquete jamás será abierto; registrar inspecciones legítimas cuando ocurran.

## 12. IA / agentes
Responsabilidades lógicas iniciales:
1. Customer Need / Product Fit
2. Product Intelligence
3. Sourcing / Supplier Verification
4. Compliance / Route Intelligence
5. Pricing / Quotation
6. Order / Logistics / Evidence
7. CRM / Market Intelligence

Estas responsabilidades no obligan a crear siete servicios/agentes autónomos desde V1. Primero pueden ser capacidades coordinadas con human-in-the-loop.

## 13. Human-in-the-loop
Requieren aprobación humana, como mínimo:
- compra;
- proveedor nuevo material;
- operación de alto valor/riesgo;
- excepción de margen/política;
- decisión regulatoria incierta;
- devolución/garantía material;
- publicación/compromiso comercial sensible.

## 14. Growth Engine para IPCENTER
Preguntas clave:
- ¿qué están pidiendo los clientes?
- ¿qué solicitudes se convierten en cotización?
- ¿qué cotizaciones se convierten en venta?
- ¿qué categorías dejan contribución real?
- ¿qué proveedor/ruta produce mejor relación costo-tiempo-riesgo?
- ¿qué canales generan clientes rentables?
- ¿qué antiguos clientes se reactivan?
- ¿dónde se pierden ventas: respuesta, precio, disponibilidad, confianza, tiempo o riesgo?

## 15. Regla de arquitectura
El Core no conoce `laptop`, `iPhone`, `drone`, `Miami`, `courier` o `repuesto de auto`. Esos conceptos viven en vertical/configuración/datos. El Core aporta las capacidades universales de necesidad, catálogo, proveedores, cotización, procurement, venta, pago, inventario/serialización, evidencia, logística, garantía, compliance y crecimiento.

**Verdicto:** `VERTICAL_READY_FOR_AS_IS_AND_DATA_CONTRACT`; no implica permiso para código vertical antes del gate IQG-001.2.
