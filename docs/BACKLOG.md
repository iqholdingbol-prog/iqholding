# BACKLOG.md
## IQ GROWTH — Lista de Tareas y Hoja de Ruta
### Versión: 1.0 · Fecha: 2026-09-10 · Prioridad: Por orden descendente

---

## 📋 CONVENCIONES
- **IQG-001** = Fundación del Núcleo Universal
- **IQG-002** = Laboratorio VANSAM
- **IQG-003** = Laboratorio Café Zacarías
- **IQG-004** = Laboratorio Chocolates La Florita
- **IQG-100+** = Funciones de crecimiento y valor agregado

> Responsables: C = Codex (construye), G = Gemini (mercado), Ds = DeepSeek (seguridad), Cl = Claude (producto), Ch = ChatGPT (arquitectura), Iván = Decisión final

---

## 🔴 IQG-001 — FUNDACIÓN DEL NÚCLEO (PRIORIDAD MÁXIMA)

### IQG-001.1 — Modelo de Datos y Migración
- [ ] Definir esquema de base de datos según ARCHITECTURE.md
- [ ] Crear tablas: Empresa, Sucursal, Usuario, Roles
- [ ] Crear tablas: Elemento, Precio_Vigente (con vigencia de fechas)
- [ ] Crear tablas: Cliente, Operacion, Operacion_Linea, Pago
- [ ] Crear tablas: Movimiento, Registro_Cambios
- [ ] Establecer regla: TODO lleva company_id + branch_id
- [ ] Establecer regla: fecha_operacion = fecha servidor, inmutable
- [ ] Establecer regla: Precio_Vigente se inserta nuevo, NUNCA se edita
- [ ] Auditoría de integridad por DeepSeek

### IQG-001.2 — Motor de Seguridad y Aislamiento
- [ ] Filtro automático: toda consulta lleva company_id
- [ ] Verificación: usuario solo ve datos de su sucursal
- [ ] Regla: sin company_id → consulta RECHAZADA
- [ ] Prueba de fugas: DeepSeek intenta acceder entre empresas
- [ ] Sistema de permisos por rol

### IQG-001.3 — Migración de Datos V11 → IQ GROWTH
- [ ] Extraer datos reales de VANSAM POS V11
- [ ] Transformar al nuevo modelo respetando historia
- [ ] Preservar fechas originales como fecha_operacion
- [ ] Preservar precios originales en Operacion_Linea
- [ ] Validación: suma de ventas V11 = suma en nuevo sistema
- [ ] Prueba paralela: ambos sistemas funcionan a la vez

### IQG-001.4 — Auditoría Final del Núcleo
- [ ] Claude revisa coherencia con producto y crecimiento
- [ ] DeepSeek intenta romper seguridad, integridad y aislamiento
- [ ] ChatGPT verifica alineación con los 5 principios
- [ ] Iván aprueba puesta en marcha del núcleo

---

## 🟡 IQG-002 — VANSAM COMO PRIMER LABORATORIO
- [ ] Adaptar flujos operativos a vertical VANSAM
- [ ] Mantener V11 funcionando mientras se prueba nuevo
- [ ] Migración en producción sin interrupción
- [ ] Validación real con ventas diarias
- [ ] Medir: ¿creció la visibilidad de clientes registrados?

---

## 🟠 IQG-003 / IQG-004 — CAFÉ Y CHOCOLATE
- [ ] Definir modelo de datos específico (verticales separadas)
- [ ] Trazabilidad de lotes y producción
- [ ] Fórmulas y transformación
- [ ] NO modificar el núcleo para implementarlos

---

## 🟢 IQG-100 — MOTOR DE CRECIMIENTO (EL VALOR)
- [ ] ¿Quiénes son mis clientes más frecuentes?
- [ ] ¿Qué producto genera más ganancia real?
- [ ] ¿De dónde vienen mis clientes por mes?
- [ ] ¿Qué acción/campaña generó mayor retorno?
- [ ] Panel: Margen incremental generado por IQ GROWTH
- [ ] Gemini valida métricas contra estándares del mercado

---

## ✅ PRIMER PASO INMEDIATO
> **Abrir IQG-001.1 — Codex empieza a construir el esquema de base de datos.**
> ChatGPT entrega el modelo → Codex lo implementa → DeepSeek lo audita → Claude lo revisa → Iván lo aprueba.