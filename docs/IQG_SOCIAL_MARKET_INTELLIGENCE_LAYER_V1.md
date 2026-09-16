# IQ GROWTH — Social & Market Intelligence Layer V1

**Fecha:** 2026-09-16  
**Estado:** `ARCHITECTURE_CONCEPT_V1`  
**Autoridad:** Iván Quea — CEO / Product Owner  
**Coordinación:** ChatGPT — Chief Architect / AI Council Coordinator

## 1. Tesis estratégica

En Bolivia y otros mercados con baja indexación web, una parte material de la señal comercial vive fuera de Google y sitios web tradicionales: Facebook, Instagram, TikTok, WhatsApp Business, marketplaces, delivery apps, grupos/comunidades, comentarios públicos, publicaciones, catálogos visibles y observación humana.

IQ GROWTH no debe limitar Market Intelligence a fuentes web indexadas. Debe construir una capa universal capaz de recolectar, normalizar, auditar y convertir señales fragmentadas en evidencia accionable.

Objetivo:

`FUENTE → OBSERVACIÓN → PROVENANCE/PERMISO → NORMALIZACIÓN → SEÑAL → AGREGACIÓN → DIAGNÓSTICO → ACCIÓN → RESULTADO`

La ventaja no será acumular datos indiscriminadamente, sino convertir señales reales en decisiones reproducibles y medibles.

## 2. Principio de acceso

Romper la barrera de información NO significa vulnerar cuentas privadas, evadir autenticación, saltarse controles de plataforma o penetrar conversaciones ajenas.

IQ GROWTH debe combinar rutas legítimas y trazables:

1. `PUBLIC_WEB` — contenido públicamente accesible e indexado.
2. `PUBLIC_AUTHENTICATED` — contenido visible legítimamente a un usuario autenticado, sujeto a términos/permisos de plataforma.
3. `FIRST_PARTY_BUSINESS` — datos de cuentas propias de IQHOLDING o clientes que conecten voluntariamente sus cuentas.
4. `USER_AUTHORIZED` — datos accedidos mediante OAuth/scopes otorgados.
5. `CUSTOMER_INTERACTION` — conversaciones e interacciones con nuestros propios negocios, dentro de propósito/retención definidos.
6. `HUMAN_OBSERVED` — evidencia que una persona puede ver legítimamente y captura estructuradamente.
7. `LICENSED_PROVIDER` — proveedor autorizado de social listening/data access cuando la plataforma no expone API comercial suficiente.
8. `PRIVATE_CONSENTED` — información privada aportada con autorización explícita y propósito determinado.

Nunca usar bypass técnico para obtener `PRIVATE_UNAUTHORIZED`.

## 3. Fuentes objetivo

### Facebook
- páginas propias/autorizadas;
- publicaciones y comentarios accesibles por Graph API/permisos aprobados;
- menciones, engagement y conversaciones de páginas propias donde aplique;
- contenido público de terceros solo mediante acceso permitido por Meta o captura humana legítima.

### Instagram
- cuentas profesionales propias/autorizadas;
- media, comentarios, menciones, hashtags y mensajes según scopes disponibles;
- perfiles de terceros solo dentro de capacidades oficiales/permisos de plataforma;
- captura humana para evidencia pública no expuesta por API.

### TikTok
- cuentas propias/autorizadas mediante Login Kit/Display API y scopes disponibles;
- contenido público visible mediante métodos permitidos;
- Commercial Content API para datos comerciales/publicitarios cuando corresponda;
- Research Tools NO se consideran dependencia comercial del producto, porque TikTok los restringe a investigadores elegibles/no comerciales;
- para señales orgánicas no disponibles por API comercial: captura humana o proveedores autorizados/licenciados.

### WhatsApp Business
- WABA/números propios o conectados voluntariamente;
- mensajes/eventos recibidos mediante Cloud API/webhooks para first-party CRM;
- catálogos visibles de terceros pueden registrarse como evidencia humana cuando el usuario los ve legítimamente;
- nunca acceder a chats privados de terceros ni grupos privados sin autorización.

### Otros
- Google/Maps;
- marketplaces;
- delivery apps;
- directorios;
- sitios web;
- formularios;
- tickets/recibos;
- observación de campo;
- encuestas;
- llamadas/chat propios;
- archivos/documentos aportados por el negocio.

## 4. Social Signal Lake — modelo conceptual

Toda observación entra primero como evidencia, no como verdad universal.

### RAW_OBSERVATION
- observation_id
- company_id / business_unit_id cuando corresponda
- source_platform
- source_type
- source_object_id cuando exista
- source_url/ref
- observed_at
- collected_at
- collector: system / human / authorized_app / provider
- access_class
- access_basis
- raw_text/media_ref
- language
- evidence_ref
- freshness
- confidence
- retention_class

### NORMALIZED_SIGNAL
- signal_id
- observation_id(s)
- signal_type
- entity/product/need references cuando puedan resolverse
- geography cuando esté explícita
- timestamp/window
- normalized_value/text
- confidence
- inference_level
- classifier_version

### SIGNAL TYPES iniciales
- `PRICE_INQUIRY`
- `PRICE_SENSITIVITY`
- `PRODUCT_REQUEST`
- `AVAILABILITY_REQUEST`
- `COMPATIBILITY_QUESTION`
- `PURCHASE_INTENT`
- `DELIVERY_DEMAND`
- `CITY_DEMAND`
- `WAIT_TIME_COMPLAINT`
- `SERVICE_COMPLAINT`
- `QUALITY_COMPLAINT`
- `PRODUCT_PREFERENCE`
- `PROMOTION_INTEREST`
- `WARRANTY_CONCERN`
- `TRUST_CONCERN`
- `IMPORT_REQUEST`
- `HARD_TO_FIND_PRODUCT`
- `RECOMMENDATION_REQUEST`
- `POSITIVE_EXPERIENCE`
- `NEGATIVE_EXPERIENCE`
- otros versionables/configurables.

## 5. No perfilar personas innecesariamente

El valor principal está en necesidades, fricciones, preferencias comerciales y resultados; no en crear expedientes privados de individuos.

Por defecto NO inferir ni usar para Growth Engine categorías sensibles como salud, religión, ideología política, orientación sexual u otros rasgos privados/sensibles.

No unir identidades entre plataformas solo por parecido. `TikTok handle + Facebook name + phone` solo se vincula con evidencia verificable, first-party relation o consentimiento.

La unidad preferida para inteligencia de mercado es la señal agregada/cohorte, salvo cuando la relación first-party con el cliente requiere CRM individual legítimo.

## 6. First-party intelligence

Para cuentas propias, cada conversación o interacción puede alimentar CRM con provenance:

`CONTACT → NEED → CATEGORY → PRODUCT → BUDGET → QUOTE → DECISION → PURCHASE → DELIVERY → WARRANTY → REPEAT`

No todos los mensajes se convierten automáticamente en CRM definitivo. La IA propone clasificación y mantiene el mensaje/evidencia original para auditoría.

Aplicaciones:
- IPCENTER: reconstruir demanda histórica por producto/ciudad/necesidad.
- VANSAM: preguntas, reservas, delivery, quejas, preferencias y recompra.
- Café Zacarías: rutas, distribuidores, tiendas, restaurantes/hoteles y pedidos.
- Chocolates: sabores, presentaciones, regalos, mayoristas y distribución.

## 7. Public social intelligence

La capa debe medir mercado sin confundir conversación con ventas.

Ejemplo:

5.000 comentarios públicos pueden clasificarse en:
- PRICE_INQUIRY = 412
- DELIVERY_DEMAND = 280
- PRODUCT_PREFERENCE = 190
- WAIT_TIME_COMPLAINT = 75

Esto representa señales observadas, NO clientes, ventas ni market share.

Toda agregación debe mostrar:
- N observaciones;
- ventana temporal;
- fuentes/plataformas;
- cobertura;
- deduplicación aplicada;
- confianza;
- limitaciones.

## 8. Human Evidence Collector

Cuando una superficie es legítimamente visible pero no existe API utilizable, IQ GROWTH debe permitir captura humana estructurada.

Ejemplo:

`WhatsApp Business catalog de competidor → producto → precio → screenshot → fecha → negocio → collected_by → visibility class → confidence`.

La evidencia humana debe guardar original y no convertirse automáticamente en verdad permanente.

El Human Evidence Collector es una capacidad universal para:
- WhatsApp catalogs;
- Stories/Reels;
- TikTok/FB/IG comments visibles;
- menús;
- marketplaces logueados;
- delivery apps;
- field research.

## 9. Evidence & permission contract

Cada observación debe portar, cuando aplique:
- `SOURCE_PLATFORM`
- `SOURCE_OBJECT_ID`
- `SOURCE_URL/REF`
- `OBSERVED_AT`
- `COLLECTED_AT`
- `ACCESS_CLASS`
- `ACCESS_BASIS`
- `AUTH_SCOPE/CONSENT_REF` cuando exista
- `EVIDENCE_REF`
- `RAW_CONTENT_REF`
- `FRESHNESS`
- `CONFIDENCE`
- `RETENTION_CLASS`
- `DELETE/REVOCATION_STATE` cuando corresponda

El sistema debe poder responder: “¿de dónde salió esta afirmación y con qué permiso fue observada?”

## 10. Pipeline de inteligencia

1. `INGEST`
2. `DEDUPLICATE`
3. `LANGUAGE/NORMALIZE`
4. `ENTITY_RESOLUTION`
5. `PRODUCT/NEED MATCH`
6. `SIGNAL CLASSIFICATION`
7. `SENTIMENT/INTENT` como señales auxiliares, no verdad
8. `AGGREGATION`
9. `TREND/ANOMALY`
10. `HYPOTHESIS`
11. `HUMAN REVIEW` cuando material
12. `GROWTH ACTION`
13. `RESULT MEASUREMENT`

## 11. Calidad y anti-alucinación

- conservar texto/evidencia original;
- separar observación de inferencia;
- versionar clasificadores/prompts;
- mostrar N y cobertura;
- declarar ACCESS_LIMITATION;
- no extrapolar seguidores a clientes;
- no extrapolar comentarios a ventas;
- no extrapolar precio visible a precio vigente indefinidamente;
- no convertir sentimiento en causalidad.

## 12. Aplicación a VANSAM

La investigación digital anterior encontró poca información web indexada en Zona Sur. Esto NO implica ausencia de información de mercado.

Nueva estrategia:
- Facebook/TikTok/Instagram: comentarios, productos, promociones y señales públicas accesibles;
- WhatsApp catalogs visibles: captura humana;
- delivery apps logueadas: captura humana estructurada;
- field research: evidencia física;
- first-party VANSAM: mensajes/ventas/quejas reales.

Resultado esperado: reemplazar `WEB_INDEXED_ONLY` por `MULTI_SOURCE_MARKET_EVIDENCE`.

## 13. Aplicación a IPCENTER

IPCenter puede convertirse en el laboratorio más fuerte de esta capa por su huella histórica digital y base first-party.

Objetivos:
- recuperar activos digitales;
- clasificar conversaciones históricas propias cuando sea técnicamente/legalmente disponible;
- detectar necesidades repetidas;
- mapear ciudad/producto/presupuesto/compatibilidad;
- conectar demanda con Product Fit/sourcing/quotation;
- aprender qué productos difíciles aparecen antes de ampliar catálogo.

No importar indiscriminadamente contactos/mensajes al Core sin propósito, provenance y política de retención.

## 14. Aplicación universal

Esta capa NO debe hardcodearse para redes específicas en el Core.

Arquitectura:

`SOURCE ADAPTER → EVIDENCE CONTRACT → NORMALIZED SIGNAL → MARKET INTELLIGENCE CAPABILITY`

Los adapters de Meta/TikTok/WhatsApp/marketplaces cambian; el contrato de evidencia y señales debe sobrevivir.

## 15. Fases

### Fase 0 — diseño/evidencia
- definir access classes;
- signal taxonomy;
- provenance contract;
- first-party vs public separation;
- retention/privacy principles;
- manual collector specification.

### Fase 1 — manual-first
- VANSAM microzona;
- IPCENTER digital assets;
- capturas estructuradas;
- clasificación IA asistida;
- agregados simples.

### Fase 2 — cuentas propias
- Meta/Instagram/WhatsApp connectors oficiales;
- webhooks;
- CRM first-party;
- human review.

### Fase 3 — social listening escalable
- APIs permitidas;
- proveedores licenciados;
- adapters versionados;
- deduplicación y analytics.

### Fase 4 — Growth Engine
- señales → hipótesis → acciones → medición de resultado.

No programar esta capa antes de cerrar gates técnicos actuales de IQG-001; el diseño puede avanzar en paralelo.

## 16. AI Council roles

- **ChatGPT:** arquitectura, synthesis, governance, evidence contract.
- **Gemini:** external platform capability + market evidence + source discovery.
- **Claude:** product/UX challenge, taxonomy usefulness, operator burden, false insight risks.
- **DeepSeek:** privacy/security/data-integrity/red-team, identity-linking/fraud/provenance attack.
- **Codex:** implementación solo cuando el gate técnico permita; nunca introducir scraping/bypass no autorizado.
- **Iván:** define objetivos, activos first-party disponibles y decisiones materiales.

## 17. Criterio de éxito

La capa funciona cuando IQ GROWTH puede responder de forma trazable:
- qué está pidiendo el mercado;
- dónde;
- cuándo;
- con qué intensidad observable;
- qué fricción expresa;
- qué evidencia soporta la afirmación;
- qué parte es first-party vs pública;
- qué acción ejecutamos;
- qué resultado produjo.

Sin confundir señales con ventas y sin depender de una única plataforma.

**Estado:** `SOCIAL_MARKET_INTELLIGENCE_LAYER_DEFINED_V1`  
**IMPLEMENTATION_GATE:** bloqueada hasta que IQG-001 permita capacidades nuevas.