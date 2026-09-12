# IQG-121 — Legal Risk Governance

**Proyecto:** IQ GROWTH  
**Estado:** principio canónico de gobierno jurídico  
**Autoridad:** Iván Quea — CEO / Product Owner  
**Arquitectura y síntesis:** ChatGPT

## 1. Objetivo

IQ GROWTH debe diseñarse para reducir de forma sistemática el riesgo jurídico de todas las partes relacionadas con una empresa y del propio proveedor del software.

El sistema no puede garantizar ausencia de demandas, litigios, sanciones o controversias. Su objetivo es prevenir riesgos previsibles, conservar evidencia, respetar derechos, impedir automatizaciones peligrosas y escalar a revisión humana/profesional cuando exista incertidumbre jurídica material.

## 2. Sujetos protegidos

La arquitectura debe considerar, según corresponda:
- clientes/consumidores;
- trabajadores y contratistas;
- socios/accionistas;
- administradores y representantes;
- familiares vinculados a la empresa;
- proveedores;
- acreedores y prestamistas;
- titulares de datos personales;
- terceros afectados;
- IQHOLDING / IQ GROWTH como proveedor del software;
- operadores y usuarios autorizados del sistema.

Ninguna relación familiar, societaria, laboral, comercial o tecnológica elimina derechos que correspondan por la jurisdicción aplicable.

## 3. Principio de doble protección

Cada función de alto impacto debe evaluarse desde dos perspectivas:

1. **Protección del sujeto afectado:** derechos, debido proceso, privacidad, propiedad, salario, crédito, consumo, contrato u otros aplicables.
2. **Protección de la empresa y de IQ GROWTH:** autorización, evidencia, trazabilidad, límites del producto, responsabilidad, integridad y cumplimiento jurisdiccional.

No diseñar controles destinados únicamente a proteger a una parte.

## 4. Regla de no automatización jurídica de alto impacto

Una IA no puede por sí sola, en producción:
- despedir, sancionar o reducir remuneraciones;
- transferir propiedad o participaciones;
- modificar derechos societarios;
- aprobar o ejecutar distribuciones de utilidades;
- crear obligaciones crediticias materiales sin autorización;
- eliminar evidencia sujeta a deber de conservación;
- resolver controversias de propiedad;
- admitir responsabilidad legal en nombre de una empresa;
- aceptar términos contractuales materiales;
- ejecutar decisiones que una jurisdicción reserve a una persona, órgano, profesional o autoridad.

El flujo permitido es:

`DETECTAR → EXPLICAR → MOSTRAR EVIDENCIA/NORMA → RECOMENDAR → SOLICITAR APROBACIÓN/REVISIÓN → REGISTRAR DECISIÓN`

## 5. Evidencia y defensa

Toda decisión material debe poder reconstruirse con:
- actor;
- fecha/hora servidor;
- empresa/sucursal;
- jurisdicción aplicable;
- regla/version normativa utilizada cuando corresponda;
- evidencia disponible en ese momento;
- autorización;
- valor anterior y nuevo;
- motivo;
- documentos relacionados;
- intervención humana/profesional cuando haya sido exigida.

La evidencia debe ser íntegra, con historia preservada y sin sobreescritura silenciosa.

## 6. Consentimiento y conocimiento

Cuando una operación requiera consentimiento, aceptación, autorización o información previa según la ley aplicable, IQ GROWTH debe registrar el evento y su versión documental.

El sistema no debe usar una casilla genérica de “acepto” para cubrir obligaciones legales distintas.

## 7. Privacidad y minimización

Recolectar únicamente datos necesarios para fines legítimos y configurados.

Datos sensibles o de alto riesgo requieren controles reforzados, acceso mínimo, auditoría y reglas de retención/eliminación según jurisdicción.

Una solicitud de rectificación/eliminación nunca debe ejecutarse destruyendo datos que exista obligación jurídica de conservar; esos conflictos deben escalarse según el Compliance Pack aplicable.

## 8. Contratos y límites del producto

Las condiciones comerciales de IQ GROWTH deberán definir claramente, cuando llegue la fase contractual:
- alcance del servicio;
- responsabilidades del cliente;
- responsabilidades del proveedor;
- límites de automatización;
- naturaleza de recomendaciones de IA;
- disponibilidad y continuidad;
- protección de datos;
- seguridad;
- integraciones de terceros;
- propiedad/licencias;
- soporte;
- terminación y exportación de datos;
- ley/jurisdicción o mecanismo de resolución de controversias cuando jurídicamente corresponda.

No utilizar cláusulas abusivas ni pretender excluir responsabilidades que la ley aplicable no permita excluir.

## 9. Terceros e integraciones

Toda dependencia externa (pagos, WhatsApp, Meta, nube, OCR, IA, facturación, etc.) debe tener identificados:
- proveedor;
- datos intercambiados;
- función;
- dependencia operacional;
- riesgos;
- condiciones relevantes;
- mecanismo de fallback cuando sea razonable.

IQ GROWTH no debe presentar como propia una garantía que dependa de un tercero no controlado.

## 10. Cumplimiento por jurisdicción

Este documento se aplica junto con `IQG-120_JURISDICTIONAL_COMPLIANCE_ARCHITECTURE.md`.

Reglas jurídicas concretas deben residir en Compliance Packs versionados y sustentados en fuentes oficiales o revisión profesional válida.

Ante ausencia, contradicción o incertidumbre material:

`REQUIRES_HUMAN_LEGAL_REVIEW`

El sistema debe preferir bloquear una operación jurídica crítica antes que inventar una regla.

## 11. Gestión de incidentes

Debe existir posteriormente un proceso para:
- incidente de seguridad;
- acceso indebido;
- error financiero material;
- incumplimiento de privacidad;
- disputa societaria;
- reclamo laboral;
- reclamo de consumidor;
- error de recomendación de IA con impacto material;
- solicitud de autoridad competente.

El incidente debe conservar cronología, acciones tomadas, responsables y evidencia.

## 12. Revisión profesional

IQ GROWTH no sustituye abogado, contador, auditor, especialista laboral, fiscal o regulatorio cuando la decisión requiera competencia profesional o interpretación jurídica.

La plataforma puede ayudar a detectar, documentar, aplicar reglas previamente validadas y preparar evidencia; no debe inventar asesoría profesional definitiva.

## 13. Gate de lanzamiento por país

Antes de comercializar IQ GROWTH en una jurisdicción nueva debe existir como mínimo:
1. mapa de riesgos legales relevante al producto;
2. Compliance Pack inicial;
3. política de privacidad/retención compatible;
4. términos contractuales revisados;
5. matriz de decisiones automáticas vs humanas;
6. procedimiento de incidentes y derechos del titular;
7. validación profesional de las áreas materiales que corresponda.

No basta con traducir la interfaz para declarar un país soportado.

## 14. Principio final

> **IQ GROWTH debe ayudar a tomar mejores decisiones sin quitar derechos, inventar autoridad ni esconder responsabilidad.**

La protección jurídica se diseña desde el Core, pero las reglas concretas se validan por jurisdicción.

**CEO_ACTION_REQUIRED:** false.
