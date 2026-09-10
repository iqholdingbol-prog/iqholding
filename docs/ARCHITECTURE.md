# ARCHITECTURE.md
## IQ GROWTH — Arquitectura del Núcleo Universal
### Versión: 1.0 · Fecha: 2026-09-10 · Principios: Universalidad, Aislamiento, Historia Sagrada, Evolutiva, Valor antes que Funciones

---

## 🏛️ PRINCIPIOS ARQUITECTÓNICOS INQUEBRANTABLES

### 1. AISLAMIENTO OBLIGATORIO
> TODO registro lleva `company_id` + `branch_id`. Ninguna consulta omite este filtro. Los datos de una empresa NUNCA aparecen en otra.

### 2. INMUTABILIDAD TEMPORAL
> TODO evento lleva `created_at` (fecha oficial del servidor). NUNCA se borra ni se sobrescribe. Las correcciones se registran como NUEVO evento con referencia al anterior.
> - `valid_from` → desde cuándo es válido
> - `valid_to` → hasta cuándo es válido (NULL = vigente)
> - Cambiar algo hoy = crear NUEVO registro, NO tocar el de ayer

### 3. MODELO UNIVERSAL
> El núcleo NO conoce «pizza», «café» ni «chocolate». Conoce:
> - **Elemento** → cosa que se vende o usa
> - **Movimiento** → entrada o salida de algo
> - **Operación** → transacción con cliente
> - **Estado** → etapa de un proceso

### 4. SEPARACIÓN NÚCLEO / VERTICALES
> Núcleo = lo que toda empresa necesita. Verticales = lo específico de cada rubro. El núcleo NO se modifica para agregar un rubro nuevo.

---

## 🗂️ MODELO DE DATOS — NÚCLEO UNIVERSAL

### Identidad y Contexto