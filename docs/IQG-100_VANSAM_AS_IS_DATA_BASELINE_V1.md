# IQG-100 — VANSAM AS-IS Data Baseline V1

**Fecha:** 2026-09-14
**Estado:** captura de realidad operativa actual, previa a implementación
**Autoridad de negocio:** Iván Quea — CEO / Product Owner

## 1. Calendario confirmado
- VANSAM opera 6 días: miércoles, jueves, viernes, sábado, domingo y lunes.
- Martes = `PLANNED_CLOSED`; nadie trabaja martes.
- Atención desde 16:00.
- Salón hasta 23:00.
- Para llevar hasta 23:30.
- Después, cada colaborador limpia su propio sector.

## 2. Dimensiones físicas aproximadas
- Local total: ~8 m × 8 m = ~64 m².
- Salón: ~6 m × 8 m = ~48 m².
- Cocina: ~2 m × 8 m = ~16 m².
- Existe muro/división longitudinal entre salón y cocina; no se propone derribarlo.
- Fachada mantiene dos vanos/cortinas existentes; rediseño estético no altera estructura por ahora.

## 3. Flujo actual de pedido — AS-IS
1. Cliente entra y camina hasta caja.
2. Cajera entrega menú o cliente decide parado frente a caja.
3. Cliente consulta/pide producto.
4. Cajera ofrece bebida/acompañamiento de forma manual.
5. Cajera anota pedido en papel/cuaderno.
6. Se cobra en caja.
7. Cliente busca mesa.
8. Cajera va físicamente a cocina y comunica el pedido verbalmente.
9. Samira arma y hornea actualmente.
10. Cajera lleva bebida primero y luego entrega pizza/comida cuando está lista.
11. No existe actualmente un flujo digital confiable caja→cocina.

Riesgos actuales:
- duplicación verbal/manual;
- pérdida de tiempo caja↔cocina;
- errores de tamaño/toppings/mesa/tipo de pedido;
- sin timestamp operativo confiable por etapa;
- cliente puede consumir bebida antes de que llegue comida;
- cuello de botella depende de Samira.

## 4. Personal real actual
- Samira: armado + horno + administración + masa + compras; hamburguesas viernes/sábado/domingo.
- Iván: actualmente apoya en horno o caja según necesidad, pero objetivo confirmado = salir de operación y quedar CEO/supervisión remota.
- Ayudante/cajera actual: lunes, miércoles, viernes y sábado.
- Cuando no viene la ayudante, Samira e Iván cubren la operación.

## 5. Estructura objetivo mínima
- Hornero/armador fijo.
- Mesera/cajera fija.
- Samira transitoria en masa/compras/administración, con objetivo de dejar de ser crítica.
- Futuro administrador/a reemplaza administración operativa de Samira.
- Iván fuera de trabajo operativo.

## 6. Cocina e inventario físico observado
### Cocina
- dos mostradores/almacenamientos: uno de vidrio y uno de madera;
- dos conservadoras;
- conservadora de toppings con queso, chorizo, salchicha, salsa/aderezos, jamón, tomate y otros insumos en tappers;
- congeladora/conservadora de acero inoxidable principalmente para masa y otros insumos;
- tablet 13";
- horno artesanal actual;
- futuro horno pizzero 72×72 cm.

### Sala
- PC táctil 23";
- TV LG 42";
- bebidas/gaseosas/jugos;
- muestras/productos de chocolate;
- cafetera Oster;
- licuadora;
- mostrador largo de vidrio iluminado ~4 m × 0,60 m;
- refrigerador/exhibidor de bebidas;
- pared verde/césped artificial pensada como zona fotográfica/Instagram;
- mesas negras + algunas mesas redondas de madera;
- espejo grande con LED propuesto para pared lateral.

## 7. Dispositivos objetivo
- 23" táctil: POS, caja, check-in/out, incidencias, gestión principal de sala.
- 13" cocina: KDS ligero para pedidos pizza/hamburguesa; texto grande y pocos botones.
- 42" cliente: confirmación pedido, estado del pedido, cross-sell y promociones con aprobación del cliente.

## 8. Horno
### Actual
- artesanal/hechizo; genera complejidad operativa y cuello de botella.

### Futuro
- horno pizzero 72×72 cm.
- capacidad declarada aproximada: 2 pizzas grandes de 36 cm simultáneas o 3 medianas/pequeñas.
- tiempos reales de cocción y capacidad por hora todavía deben medirse una vez instalado.

## 9. Registro actual de ventas
- POS actual no está funcionando de forma operativa.
- Las ventas se anotan en hoja/cuaderno.
- Existe registro manual de pedidos/ventas.
- Hasta que el nuevo sistema funcione, este registro debe considerarse fuente operativa primaria, con limitaciones de evidencia.

## 10. Datos económicos ya conocidos
- Ventas cuando abre: ~Bs 800/día como referencia actual del CEO.
- Volumen: ~12 pizzas/día promedio, rango ~8–16.
- Operación planificada: 26 días/mes aprox. por calendario 6 días/semana.
- Costos fijos conocidos: alquiler 2.000; luz 450; agua 150; internet 50; Samira 2.500; apoyo eventual normalizado ~1.525/mes.
- Margen promedio listado de pizzas ~39,6%: provisional, no equivale a margen neto ni utilidad.

## 11. Incidencias y responsabilidad
- El sistema debe registrar faltantes, errores, retrasos, limpieza, stock, proveedor, sistema, preparación, caja, atención y personal.
- Cada incidencia conserva quién reportó, proceso afectado, responsable funcional, respuesta y estado.
- Responsable funcional != culpable.
- Samira puede visualizar incidencias, pero no borrarlas ni reescribirlas.
- Iván debe poder verlas remotamente.
- WhatsApp puede ser canal futuro si el número está vinculado a identidad autorizada.

## 12. Siguiente trabajo de datos
Prioridad:
1. catálogo real vigente;
2. receta/costo por producto y tamaño;
3. compras/stock crítico;
4. personal/jornadas/pagos reales;
5. ciclo operativo completo de 6 días;
6. tiempos reales desde pedido hasta entrega;
7. ventas por producto/tamaño/canal;
8. faltantes/incidencias;
9. capacidad del nuevo horno cuando esté instalado;
10. cálculo de cobertura y punto de equilibrio por escenario actual, equipado, formal y autónomo.

## 13. Gate
`VANSAM_AS_IS_BASELINE_CAPTURED`

No se autoriza todavía implementación amplia de producto sobre estos datos hasta cerrar los datos mínimos faltantes y el gate técnico IQG-001.2.
