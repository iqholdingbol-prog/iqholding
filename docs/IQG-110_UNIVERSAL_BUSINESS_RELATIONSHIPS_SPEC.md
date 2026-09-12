# IQG-110 — Universal Business Relationships Specification

**Proyecto:** IQ GROWTH  
**Estado:** diseño canónico previo a implementación  
**Fecha:** 2026-09-11  
**Autoridad:** Iván Quea — CEO / Product Owner  
**Arquitectura y síntesis:** ChatGPT  
**Validación futura:** Claude (producto/sistemas), DeepSeek (integridad/seguridad), Gemini (evidencia externa cuando corresponda), Codex (implementación futura)

---

## 1. Propósito

IQ GROWTH debe representar correctamente empresas familiares y no familiares sin confundir relaciones jurídicas, laborales, financieras ni administrativas.

Una misma persona puede relacionarse con una empresa de varias formas simultáneas, pero cada relación debe conservar identidad, vigencia, reglas, documentos y efectos propios.

Principio central:

> **PERSONA ≠ SOCIO ≠ EMPLEADO ≠ ADMINISTRADOR ≠ ACREEDOR ≠ APORTANTE ≠ BENEFICIARIO DE UTILIDADES**

La coincidencia de una misma persona en varias relaciones no autoriza al sistema a fusionarlas.

Toda relación definida en este documento debe evaluarse, cuando produzca efectos jurídicos, a través de la capa de cumplimiento definida en `docs/IQG-120_JURISDICTIONAL_COMPLIANCE_ARCHITECTURE.md`.

---

## 2. Relaciones universales mínimas

### R1 — Persona
Entidad humana o jurídica de referencia.

Puede tener múltiples relaciones con una o más empresas.

No implica por sí sola ningún permiso, porcentaje, salario, deuda ni derecho económico.

### R2 — Participación societaria
Representa la relación de una persona con el capital/propiedad formal de una empresa cuando corresponda.

Debe conservar:
- empresa;
- titular;
- tipo de participación/cuota/acción según forma jurídica;
- porcentaje o unidades;
- fecha de vigencia;
- fecha de término cuando exista;
- documento/acuerdo de soporte;
- estado;
- historial de cambios.

Nunca inferir participación desde:
- préstamos;
- trabajo realizado;
- salario;
- parentesco;
- administración;
- retiros;
- transferencias informales de dinero.

### R3 — Empleo / relación laboral
Debe registrar por separado:
- empresa;
- trabajador;
- cargo/función;
- salario/remuneración;
- vigencia;
- jornada/horario si aplica;
- incidencias;
- pagos laborales;
- documento/contrato cuando corresponda;
- estado.

Ser socio no convierte automáticamente a una persona en empleado y ser empleado no la convierte en socio.

### R4 — Administración / autoridad
Representa poderes y permisos de gestión.

Debe separar:
- rol administrativo;
- alcance;
- sucursal/empresa;
- permisos;
- vigencia;
- quién otorgó/revocó;
- soporte documental cuando corresponda.

Ser socio no implica automáticamente autorización operativa ilimitada.

### R5 — Aporte de capital
Entrada de recursos formalmente destinada a capital/aporte patrimonial.

Debe conservar:
- aportante;
- empresa;
- fecha;
- monto/activo aportado;
- moneda/valoración;
- documento;
- relación con participación si legalmente corresponde;
- estado.

No confundir con préstamo.

### R6 — Préstamo / financiamiento de socio o tercero
Representa deuda de la empresa frente a una persona/entidad.

Debe conservar:
- acreedor;
- empresa;
- fecha;
- capital;
- moneda;
- interés/tipo de interés cuando corresponda;
- plazo;
- calendario/cuotas;
- pagos;
- saldo;
- documento/acuerdo;
- estado.

Regla universal:

> **Un préstamo no modifica automáticamente una participación societaria.**

### R7 — Retiro
Salida de dinero o activo hacia una persona relacionada que no debe clasificarse automáticamente como salario, préstamo pagado o distribución de utilidad.

Debe exigir clasificación explícita y trazabilidad.

### R8 — Distribución de utilidades/dividendos
Solo puede registrarse como tal cuando exista un resultado distribuible y una decisión/documento válido conforme a la estructura jurídica y normativa aplicable.

No usar saldo de caja como equivalente de utilidad distribuible.

Debe conservar:
- periodo;
- base de cálculo;
- monto aprobado;
- beneficiarios;
- criterio/porcentaje aplicado;
- fecha de decisión;
- fecha de pago;
- documento/acta cuando corresponda;
- estado.

### R9 — Cuenta corriente con relacionado
Cuando una persona tenga múltiples movimientos con la empresa, IQ GROWTH puede mostrar una vista consolidada, pero sin perder la naturaleza de cada movimiento.

Ejemplo:
- préstamo: +10.000;
- reembolso de préstamo: -2.000;
- salario pendiente: +2.500;
- distribución aprobada: +1.500.

La vista consolidada NO debe convertirlos en una sola deuda indiferenciada.

---

## 3. Invariantes de dominio

1. `participación societaria` y `préstamo` son dominios independientes.
2. `empleo` y `participación societaria` son dominios independientes.
3. `administración` y `propiedad` son dominios independientes.
4. `salario` y `distribución de utilidad` son conceptos distintos.
5. `aporte de capital` y `préstamo` son conceptos distintos.
6. `retiro` debe tener clasificación explícita.
7. `caja disponible` no equivale a `utilidad distribuible`.
8. cambios históricos no se sobrescriben: se registran con vigencia temporal.
9. toda operación crítica registra actor, fecha, motivo, valor anterior/nuevo cuando corresponda.
10. el sistema no inventa reglas legales, laborales, fiscales, sucesorias o societarias; parametriza y conserva evidencia.
11. parentesco nunca reduce derechos ni crea privilegios jurídicos automáticos.
12. una acción material solo puede ejecutarse si su jurisdicción y regla aplicable están resueltas o si el flujo exige revisión humana/legal.

---

## 4. Modelo temporal

Las relaciones deben ser versionables.

Ejemplo:

`SOCIO A 40%: 2026-01-01 → 2026-06-30`

`SOCIO A 50%: 2026-07-01 → vigente`

Los reportes históricos deben usar la relación vigente en la fecha del hecho, no la relación actual.

No se permite reescribir retrospectivamente una participación, salario, permiso o acuerdo sin evento de corrección auditado.

---

## 5. Documentos y evidencia

Cada relación puede tener evidencia asociada:
- contrato;
- acta;
- escritura;
- comprobante;
- recibo;
- resolución interna;
- documento laboral;
- documento fiscal/contable;
- anexo;
- nota de conciliación.

IQ GROWTH debe registrar metadatos y referencia documental; no debe asumir que la mera carga de un archivo valida jurídicamente su contenido.

---

## 6. Empresas familiares

En empresas familiares, el sistema debe evitar especialmente estas inferencias:

- “es mi hermano/padre/pareja, por tanto es socio”;
- “trabaja aquí, por tanto tiene porcentaje”;
- “puso dinero, por tanto aumentó su porcentaje”;
- “retiró dinero, por tanto era utilidad”;
- “administra el negocio, por tanto puede disponer de cualquier activo”;
- “la empresa le debe dinero, por tanto tiene derechos societarios adicionales”.

Parentesco puede registrarse como contexto opcional fuera del motor financiero, pero nunca debe crear derechos automáticos ni reducir los derechos de la persona reconocidos por la jurisdicción aplicable.

---

## 7. Separación contable mínima

Todo movimiento entre empresa y persona relacionada debe clasificarse al menos como uno de:

- aporte de capital;
- préstamo recibido;
- pago de préstamo;
- interés;
- salario/remuneración;
- reembolso de gasto;
- compra/venta con relacionado;
- retiro pendiente de clasificar;
- distribución de utilidad;
- devolución de aporte cuando jurídicamente corresponda;
- otro documentado.

No permitir categoría genérica permanente `socio/familia`.

---

## 8. Autorizaciones

Acciones sensibles requieren permisos separados:
- crear/modificar participación;
- registrar aporte de capital;
- crear préstamo;
- aprobar pago a relacionado;
- aprobar distribución;
- cambiar salario;
- otorgar/revocar administración;
- corregir periodos cerrados.

Ningún agente IA debe ejecutar autónomamente esas acciones en producción.

Además de permisos internos, las acciones de alto impacto deben pasar por el resultado jurisdiccional correspondiente: `ALLOWED`, `REQUIRES_EVIDENCE`, `REQUIRES_HUMAN_LEGAL_REVIEW` o `BLOCKED`.

---

## 9. Auditoría

Eventos mínimos:
- `OWNERSHIP_RELATION_CREATED`
- `OWNERSHIP_RELATION_CHANGED`
- `EMPLOYMENT_RELATION_CREATED`
- `EMPLOYMENT_RELATION_CHANGED`
- `ADMIN_AUTHORITY_GRANTED`
- `ADMIN_AUTHORITY_REVOKED`
- `CAPITAL_CONTRIBUTION_RECORDED`
- `RELATED_PARTY_LOAN_CREATED`
- `RELATED_PARTY_LOAN_PAYMENT_RECORDED`
- `RELATED_PARTY_WITHDRAWAL_RECORDED`
- `PROFIT_DISTRIBUTION_APPROVED`
- `PROFIT_DISTRIBUTION_PAID`
- `RELATED_PARTY_RECORD_CORRECTED`

Todo evento debe incluir empresa, actor, fecha servidor, objeto afectado, motivo y correlación con documento cuando corresponda.

Cuando exista una regla jurídica aplicable, debe registrar además `legal_rule_id`/versión o referencia equivalente utilizada al evaluar la acción.

---

## 10. UI conceptual

La ficha de una persona relacionada debe mostrar relaciones separadas, por ejemplo:

```text
PERSONA: X

SOCIO
  Participación vigente: 40%

EMPLEADO
  Cargo: Administrador
  Salario: Bs ...

ADMINISTRACIÓN
  Permiso: sucursal Cochabamba

PRÉSTAMOS
  Saldo empresa→persona: Bs ...

DISTRIBUCIONES
  Aprobadas / pagadas por periodo
```

Nunca mostrar un único “saldo del socio” que mezcle todo sin desglose.

---

## 11. Gate jurídico

El gate jurídico completo se define en `docs/IQG-120_JURISDICTIONAL_COMPLIANCE_ARCHITECTURE.md`.

Antes de habilitar reglas automáticas específicas por país, cada implementación debe validar externamente como mínimo:
- jurisdicción;
- forma jurídica de la empresa;
- reglas societarias aplicables;
- requisitos de transferencia/aporte;
- obligaciones laborales;
- impuestos/retenciones;
- privacidad/protección de datos;
- derechos de consumidor cuando corresponda;
- documentación exigible;
- restricciones de distribución;
- normativa de partes relacionadas cuando corresponda;
- jurisprudencia/criterio vinculante cuando sea material y aplicable.

IQ GROWTH debe distinguir:
- regla universal de datos;
- configuración empresarial;
- regla legal verificada por jurisdicción;
- interpretación que requiere revisión profesional.

---

## 12. MVP

No implementar todo este dominio ahora.

Para el primer MVP, el Core solo necesita estar preparado para no bloquear estas relaciones futuras.

La implementación funcional de IQG-110 pasa a backlog posterior a IQG-001.2/001.3 y al MVP de VANSAM, salvo que una necesidad real de operación lo haga prioritario.

---

## 13. Siguiente revisión especializada

1. **Claude:** desafiar si el modelo mezcla innecesariamente gobierno corporativo con operación y detectar sobreingeniería.
2. **DeepSeek:** revisar integridad temporal, segregación de permisos, fraude interno, doble clasificación y manipulación retroactiva, incluyendo interacción con IQG-120.
3. **Gemini:** solo cuando se requiera evidencia externa sobre prácticas/mercado o jurisdicción específica.
4. **Codex:** no implementar mientras su cuota esté reservada para IQG-001.2.

**CEO_ACTION_REQUIRED:** false.
