# IQG-122 — Legal Defensibility Addendum

**Proyecto:** IQ GROWTH  
**Estado:** canónico transversal previo a implementación  
**Fecha:** 2026-09-11  
**Autoridad:** Iván Quea — CEO / Product Owner  
**Arquitectura y síntesis:** ChatGPT  
**Origen de challenge:** Claude — `ai-council/IQG-110/reports/2026-09-11_2355_claude_legal_risk_challenge.md`

---

## 1. Propósito

Este addendum refina `IQG-110`, `IQG-120` e `IQG-121` para reducir riesgo de litigio sin adjudicar derechos, fabricar hechos jurídicos ni retener/borrar evidencia de forma improcedente.

Principio:

> **IQ GROWTH registra hechos, fuentes, declaraciones, calificaciones y decisiones con procedencia; no sustituye a juez, autoridad, abogado, contador ni profesional competente.**

---

## 2. Modelo epistemológico obligatorio

Todo dato material debe poder distinguir al menos:

- `FACT_VERIFIED`
- `USER_DECLARED`
- `DOCUMENT_SUPPORTED`
- `THIRD_PARTY_ATTESTED`
- `LEGAL_EFFECT_VERIFIED`
- `SYSTEM_INFERRED`
- `PENDING_CLASSIFICATION`
- `PENDING_HUMAN_REVIEW`
- `PENDING_LEGAL_REVIEW`
- `CONTRADICTED`
- `DISPUTED`
- `UNVERIFIABLE`
- `VERIFICATION_EXPIRED`
- `WITHDRAWN`
- `SUPERSEDED`
- `INVALIDATED`

No deben fusionarse estas tres afirmaciones:

1. el documento existe;
2. el documento contiene una afirmación;
3. esa afirmación produce determinado efecto jurídico.

La carga de un documento nunca implica automáticamente `LEGAL_EFFECT_VERIFIED`.

---

## 3. Propiedad y derechos controvertidos

Se prohíbe un campo canónico `propietario_economico` que pretenda adjudicar quién es el dueño real.

Cuando exista incertidumbre o conflicto, el sistema debe registrar por separado:

- titularidad registral documentada cuando exista;
- declaración de una parte;
- acuerdo privado;
- expectativa/promesa;
- reclamación;
- evidencia;
- contradicción;
- controversia;
- resolución/acto de autoridad cuando esté verificado.

La UI debe mostrar las fuentes y su estado, no sintetizar automáticamente un veredicto de propiedad.

---

## 4. Hecho económico antes que calificación

Un movimiento económico verificable debe registrarse aunque su naturaleza jurídica/contable todavía no esté resuelta.

Estado inicial permitido:

`PENDING_CLASSIFICATION`

Debe conservar:

- actor/persona involucrada;
- empresa;
- monto/activo;
- moneda;
- fecha/hora;
- medio;
- descripción original;
- fuente/evidencia;
- actor que registró;
- estado epistemológico.

No produce automáticamente efectos sobre equity, deuda, salario, utilidad o propiedad.

La reclasificación posterior debe ser versionada e incluir:

- autor;
- autoridad/permiso;
- motivo;
- evidencia;
- fecha;
- clasificación anterior/nueva;
- aprobación/revisión exigida por jurisdicción.

Los pendientes deben tener seguimiento y SLA/configuración por jurisdicción/empresa para evitar abandono indefinido.

---

## 5. Saldos e inferencias

Una cuenta corriente consolidada puede existir como vista operativa, pero su saldo se marca `SYSTEM_INFERRED`.

No debe presentarse automáticamente como deuda jurídicamente exigible.

Especialmente, un gasto de empresa asociado a una persona no se convierte unilateralmente en cuenta por cobrar. Puede registrarse como hecho y pasar a `PENDING_ACKNOWLEDGEMENT`/estado equivalente hasta existir reconocimiento, decisión autorizada o calificación válida.

---

## 6. Aportes no monetarios y trabajo

Uso de activos, trabajo, conocimiento, marca u otros aportes no monetarios deben ser modelables como hechos/acuerdos, pero ningún tipo genera automáticamente capital, porcentaje o renuncia salarial.

Cuando exista trabajo a cambio de equity, servicios de socio u otras combinaciones con riesgo laboral/societario:

`JURISDICTION_DEPENDENT` + revisión profesional cuando corresponda.

Las advertencias y acuses de conocimiento son evidencia de proceso, pero **no sustituyen cumplimiento legal ni eliminan derechos**.

---

## 7. DISPUTE y LEGAL HOLD

Debe existir una arquitectura de controversias con:

- `dispute_id`;
- materia/objeto afectado;
- partes;
- quién la abrió y con qué autoridad;
- evidencia;
- alcance;
- fecha;
- estado;
- automatizaciones suspendidas;
- legal hold asociado cuando corresponda;
- notificaciones;
- revisores;
- resolución y autoridad;
- estado de firmeza/revisión/apelación cuando sea aplicable.

### Congelación quirúrgica

Una controversia debe bloquear únicamente operaciones dependientes del hecho disputado.

Ejemplo: disputa de porcentaje puede bloquear modificación/distribución de equity afectado, pero no debe paralizar ventas, cocina, nómina no relacionada o actividad comercial ordinaria.

### Antiabuso

La arquitectura debe impedir que una persona con interés propio pueda paralizar unilateralmente la empresa mediante disputas arbitrarias. Se requieren permisos, separación de funciones, objeción/revisión y trazabilidad.

Quien abre una controversia no debe poder cerrarla unilateralmente cuando exista conflicto de interés material.

---

## 8. Retención, supresión y legal hold

No existe regla universal de "borrar siempre" ni "conservar siempre".

Ante solicitud de rectificación/supresión:

1. registrar la solicitud;
2. identificar datos alcanzados;
3. verificar Compliance Pack aplicable;
4. comprobar legal hold, investigación, auditoría o retención obligatoria;
5. si existe conflicto/incertidumbre material, `PENDING_LEGAL_REVIEW` con preservación temporal;
6. ejecutar rectificación/supresión cuando corresponda;
7. conservar únicamente la evidencia/auditabilidad permitida y necesaria según jurisdicción.

La preservación por incertidumbre no debe convertirse en retención indefinida. Debe tener revisión y escalamiento.

El borrado físico/controlado puede existir solo cuando sea jurídicamente procedente, autorizado y auditado; nunca debe evadir un legal hold o deber válido de conservación.

---

## 9. Compliance Pack reforzado

Además de IQG-120, cada regla material debe soportar:

- `verification_status`;
- `verified_by` / referencia del revisor competente;
- `verified_at`;
- `next_review_date`;
- `source_tier`;
- `supersedes`;
- `superseded_by`;
- `scope_limitations`;
- `applies_to_operations_dated_from`;
- `applies_to_operations_dated_to`;
- `action_if_uncertain`;
- `required_human_role` cuando corresponda.

Toda evaluación material sella:

- `rule_version_applied`;
- jurisdicción;
- fecha de operación;
- fecha de evaluación;
- evidencia usada;
- resultado.

Una reevaluación posterior crea una nueva evaluación versionada; no reescribe la original.

Cuando una regla esté no verificada, expirada o materialmente ambigua, el sistema no puede convertirla por inferencia en `ALLOWED`.

---

## 10. Matriz de autonomía de IA

### A — Puede automatizar

- detectar contradicciones;
- detectar verificación expirada;
- listar pendientes;
- calcular métricas/saldos claramente marcados `SYSTEM_INFERRED`;
- resumir fuentes/documentos sin emitir conclusión jurídica.

### B — Puede recomendar; requiere aprobación nominal

- clasificación de movimientos;
- acciones comerciales no jurídicas;
- borradores/mensajes;
- priorización operativa.

### C — Requiere revisión profesional/jurisdiccional cuando sea material

- laboral;
- societario;
- tributario;
- contractual;
- sucesorio;
- privacidad/datos;
- propiedad/derechos reales;
- cumplimiento sectorial regulado.

### D — Nunca autónomo

- despedir/sancionar;
- fijar o reducir salarios;
- modificar equity/derechos societarios;
- declarar propiedad;
- aprobar/distribuir utilidades;
- ejecutar movimientos financieros patrimoniales de alto impacto;
- resolver/cerrar controversias;
- eliminar evidencia bajo legal hold;
- emitir conclusiones jurídicas definitivas;
- aplicar una regla jurídica no verificada como hecho.

---

## 11. Cuatro clases de control

### Preventivo
RBAC, separación de funciones, doble aprobación, bloqueo por regla no verificada, scopes mínimos, minimización de datos.

### Detectivo
Contradicciones, verificaciones expiradas, pendientes de clasificación, alteraciones históricas, anomalías de acceso.

### Probatorio
Provenance, timestamps, versiones, hashes/documentos, reglas aplicadas, aprobaciones, advertencias/acuse cuando correspondan, logs de acceso.

### Recuperación
Versionado, rollback cuando sea seguro, re-evaluación sin sobreescritura, exportación de evidencia, recuperación ante incidentes.

---

## 12. Claims comerciales prohibidos sin base jurídica específica

IQ GROWTH no debe prometer de forma general:

- "cumple con toda la ley";
- "te protege legalmente";
- "evita demandas/juicios";
- "asesoría legal automática";
- "determina quién es propietario";
- "calcula automáticamente tus derechos";
- "genera contratos siempre válidos";
- "cumplimiento garantizado".

Posicionamiento permitido: ayudar a organizar evidencia, controles, trazabilidad, workflows y reglas jurisdiccionales verificadas, con escalamiento profesional cuando corresponda.

---

## 13. Gate antes de implementación

Antes de llevar IQG-110/120/121/122 a código:

1. DeepSeek debe red-teamear integridad, fraude, permisos, legal hold, manipulación histórica y bypass de separación de funciones;
2. reglas específicas de Bolivia deben verificarse con fuentes oficiales y revisión profesional para áreas de alto impacto;
3. definir política de datos/retención/borrado por jurisdicción;
4. definir threat model de usuario interno malicioso;
5. demostrar que una disputa no puede paralizar operación no relacionada;
6. demostrar que ninguna inferencia IA se persiste como hecho jurídico sin aprobación;
7. Codex no implementa este dominio mientras IQG-001.2 sea prioridad crítica.

**CEO_ACTION_REQUIRED:** false.
