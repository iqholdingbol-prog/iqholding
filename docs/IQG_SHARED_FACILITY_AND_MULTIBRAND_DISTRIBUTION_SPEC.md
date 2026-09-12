# IQ GROWTH — Shared Facility & Multibrand Distribution Spec

**Fecha:** 2026-09-12
**Estado:** arquitectura conceptual canónica, previa a implementación

## 1. Propósito

Permitir que múltiples líneas, marcas o empresas compartan infraestructura física, personal, vehículos, rutas y puntos de venta sin mezclar inventarios, costos, propiedad, ventas ni responsabilidades.

Casos de referencia:
- Café Don Zacarías + Chocolates La Florita en planta Senkata;
- un vendedor que comercializa ambas marcas;
- Toyota Hiace 1982 o Ford Ranger 2008 como unidades comerciales/logísticas;
- carrito ambulante con múltiples productos/marcas.

## 2. Principios duros

1. `SHARED_RESOURCE != SHARED_OWNERSHIP`.
2. `SHARED_LOCATION != SHARED_INVENTORY`.
3. `SHARED_SELLER != SHARED_MARGIN`.
4. `SHARED_ROUTE != SHARED_CASH_ACCOUNT`.
5. Todo movimiento conserva `company_id / business_unit / brand / item / lot` según aplique.
6. Un recurso familiar o de tercero usado por la empresa no se convierte automáticamente en activo empresarial.
7. Historia sagrada: asignaciones y costos se versionan por fecha.

## 3. Facility universal

`FACILITY` puede ser:
- planta;
- tienda;
- almacén;
- finca;
- taller;
- oficina;
- cocina;
- punto de distribución;
- otro.

Una facility puede alojar múltiples `OPERATING_UNIT`.

Ejemplo Senkata:
```text
FACILITY: Planta Senkata
  ├─ Café Don Zacarías
  │   ├─ secado
  │   ├─ trilla
  │   ├─ tostado
  │   ├─ molienda
  │   └─ empaque
  └─ Chocolates La Florita
      ├─ recepción cacao
      ├─ formulación
      ├─ producción
      ├─ moldeado
      └─ empaque
```

## 4. Recurso compartido

Un `RESOURCE` puede ser:
- máquina;
- herramienta;
- espacio;
- vehículo;
- persona/servicio;
- energía/utilidad;
- otro recurso productivo.

Para compartirlo se registra:
- propietario;
- operador/usuario;
- periodo de uso;
- proceso;
- tiempo/cantidad consumida;
- costo directo;
- regla de asignación de costo si es común;
- evidencia;
- mantenimiento/incidencia.

No usar repartos arbitrarios sin marcar el método.

## 5. Inventario segregado dentro de ubicación compartida

El mismo almacén físico puede contener stock de varias líneas.

Cada saldo se determina por:
- owner/business unit;
- brand;
- item;
- variant/presentation;
- lot/batch;
- unit;
- location/bin cuando aplique.

Nunca sumar como intercambiable productos de marcas o lotes distintos solo porque están físicamente juntos.

## 6. Vendedor multimarcas

Un vendedor puede estar autorizado para vender varias marcas/productos en una misma jornada.

`SALES_ASSIGNMENT` define:
- persona;
- fecha/turno;
- ruta/zona;
- punto/vehículo/carrito;
- marcas autorizadas;
- catálogo/precios permitidos;
- stock asignado;
- medios de cobro permitidos.

Rendición:
```text
STOCK_INICIAL
+ TRANSFERENCIAS
- VENTAS
- MUESTRAS/PROMOS AUTORIZADAS
- DEVOLUCIONES A ORIGEN
- MERMAS/FALTANTES JUSTIFICADOS
= STOCK_ESPERADO_FINAL
```

Comparar contra conteo físico final.

## 7. Punto de venta universal

`SALES_POINT` puede ser:
- fijo;
- temporal/feria;
- callejero fijo;
- carrito;
- ambulante/persona;
- vehículo;
- showroom;
- tienda;
- digital/e-commerce;
- mayorista/distribuidor.

Un punto puede cambiar de ubicación por evento sin convertirse en una nueva empresa.

## 8. Vehículo como activo operativo

Campos conceptuales:
- vehicle_id;
- propietario legal;
- empresa/unidad que lo usa;
- tipo de acuerdo de uso;
- conductor/responsable;
- capacidad;
- ruta;
- combustible;
- mantenimiento;
- inventario cargado;
- ventas/cobros relacionados;
- kilómetros cuando se mida;
- incidencias.

Casos actuales de referencia:
- Toyota Hiace 1982: uso comercial futuro, pendiente de laminado/adaptación;
- Ford Ranger 2008: propiedad del hermano de Iván, posible uso comercial por él.

## 9. Caja y cobro en distribución

Un vendedor puede cobrar por:
- efectivo;
- QR/transferencia;
- crédito autorizado;
- otro medio configurado.

`SALE != PAYMENT != CASH_MOVEMENT` sigue siendo regla central.

Al cerrar ruta/punto:
- ventas esperadas;
- pagos recibidos;
- efectivo esperado;
- efectivo rendido;
- diferencias;
- cuentas por cobrar;
- stock esperado/físico;
- gastos autorizados;
- incidencias.

## 10. Precio multicanal

Un mismo item/presentación puede tener precios por:
- minorista;
- mayorista;
- ciudad;
- punto;
- vendedor autorizado;
- volumen;
- cliente/acuerdo;
- campaña;
- vigencia temporal.

Nunca alterar ventas históricas cuando cambia la tarifa.

## 11. Aplicabilidad universal

Esta capacidad no es específica de café/chocolate. Debe servir para:
- distribuidora con preventistas;
- ferretería con vendedores móviles;
- alimentos/bebidas;
- cosméticos;
- textiles;
- farmacia/distribución cuando compliance lo permita;
- servicios técnicos móviles;
- food trucks;
- agroinsumos;
- cualquier negocio con recursos/puntos compartidos y distribución multicanal.

## 12. Gate

Antes de implementación:
- validar aislamiento entre empresas/unidades;
- definir reglas de transferencia/consignación;
- definir conciliación stock/caja;
- soportar propiedad externa de activos;
- soportar costos compartidos sin falsa precisión;
- revisar con DeepSeek aislamiento/fraude cuando entre a diseño técnico.

**Estado:** `SHARED_FACILITY_MULTIBRAND_MODEL_DEFINED`
**CEO_ACTION_REQUIRED:** false
