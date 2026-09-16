# IQG-005 IPCENTER — NATIONAL SOCIAL FORENSIC PASS 2

**Date:** 2026-09-16  
**Lead:** ChatGPT / Chief Architect & AI Council Coordinator  
**Status:** `NATIONAL_SCOPE_ACTIVE / SOCIAL_RESEARCH_CONTINUES`

## 1. Scope correction

IPCenter is not to be analyzed as a Cochabamba-local business. The commercial target is **Bolivia-wide**. Research must cover national demand, competitors, sourcing, trust, price, availability, logistics and social-market signals.

Priority geographies for initial national coverage:
- Santa Cruz de la Sierra / Montero
- La Paz
- El Alto
- Cochabamba / Quillacollo
- Sucre
- Oruro
- Tarija
- Potosí
- then other departments as evidence appears

`CITY != MARKET_BOUNDARY`.

A seller located in one city may compete nationally through WhatsApp, Facebook, TikTok, Instagram, catalogs, courier and national delivery.

## 2. Research doctrine

Primary sensors:
1. Facebook pages, public groups, comments and Marketplace surfaces.
2. TikTok public content and indexed references.
3. Instagram public business/creator surfaces.
4. WhatsApp Business public links/catalog/community surfaces and IPCENTER first-party data when authorized.
5. Public catalogs, ecommerce, Linktree/link hubs, directories, reviews, Reddit/community discussions and local field capture.

Rules:
- `NOT_INDEXED != NOT_AVAILABLE`.
- A social signal is not a sale.
- Followers are not customers.
- Cross-city shipping means competitors must be modeled nationally.
- Do not infer population prevalence from social samples.
- Preserve source URL, date, observed_at, city if explicit, platform and confidence.

## 3. National seller/competitor evidence surfaced in Pass 2

### Santa Cruz high-density cluster

Public evidence now shows a dense cluster of technology/gaming sellers and physical commercial hubs in Santa Cruz, especially around Chiriguano/Indana/Neval and other computer-shopping centers.

Examples surfaced:
- IRIS COMPUTER — website, TikTok, Facebook, Instagram, YouTube, Discord, Kick and several named sales advisers; Santa Cruz physical store. Public copy states personalized recommendation by budget/need.
- JC COMPUTERS — Facebook, TikTok, WhatsApp, laptop catalog, PC Gamer channel; Comercial Chiriguano and another Santa Cruz branch.
- CYREX STORE — Santa Cruz + Cochabamba, TikTok, Facebook, WhatsApp Community, web catalog, national reach; La Paz expansion teased publicly.
- Grupo Tecnológico NF — Santa Cruz + Cochabamba; WhatsApp, TikTok, Facebook, Instagram; explicitly maps laptops to architecture, engineering, design, content creation and business use cases.
- Mac One — Santa Cruz; public listings include Alienware/MSI/ASUS gaming laptops, WhatsApp, delivery and national shipping signals.
- Importadora TIO Bolivia — Santa Cruz; imports refurbished laptops from Miami and advertises shipments throughout Bolivia.
- Ahorro Computer — Santa Cruz; public catalog, WhatsApp and national shipping.
- COMPUCENTER Bolivia — Santa Cruz; physical store, website, WhatsApp and computer/laptop categories.
- Macroinfo — Comercial Chiriguano; public WhatsApp links and national shipping.
- Viralnet Mall — Santa Cruz; TikTok, Instagram, Facebook and WhatsApp catalog.

This is **not yet an exhaustive competitor registry**; it proves Santa Cruz requires a dedicated social-market subgraph rather than a handful of stores.

### La Paz / El Alto cluster

Evidence surfaced:
- Origins Gamer Store — La Paz + El Alto, Instagram, WhatsApp, national shipping, payment/delivery options and gaming product lines.
- PPLEY — La Paz; Facebook, Instagram, TikTok, WhatsApp, Discord, WhatsApp community and product catalogs.
- ExoTech — La Paz; current web catalog of laptops including gaming/high-performance equipment.
- Caletazo Import — El Alto; computers/laptops/accessories with public commercial contacts.
- Importadora Ardunel — multi-city network including La Paz, El Alto, Cochabamba, Santa Cruz, Potosí, Oruro, Tarija and Sucre, with national shipping and a public WhatsApp group.

### Cochabamba cluster

Existing local evidence remains relevant nationally because many stores ship across Bolivia:
- Grupo Tecnológico NF
- CYREX STORE
- Punto Tecnológico
- COMPUBOL
- sYsbol
- IPCENTER historical/current digital footprint

### Sucre / Oruro

A 2026 gaming catalog surfaced with physical stores in Sucre and Oruro, WhatsApp contacts, national shipping and cash-on-delivery references for Santa Cruz, Potosí, La Paz, Cochabamba and Tarija. This is evidence that secondary-city sellers can operate nationally.

### Nationwide formal/enterprise suppliers

INTECSA publicly states branches in La Paz and Santa Cruz plus national shipping. These firms matter for B2B/procurement benchmarking even if they are not direct gamer-shop competitors.

## 4. National demand / friction signals surfaced

Public Bolivia community discussions provide strong qualitative signal categories, without claiming population prevalence:

### TRUST / PHYSICAL-PRESENCE RISK
Users repeatedly ask whether an importadora/store is trustworthy, whether it has a physical office and whether apparently low prices signal fraud. A 2026 discussion about an Oruro high-end-laptop seller contains multiple allegations of a nonexistent/fraudulent storefront. This makes trust verification a material product problem.

### LOCAL VS IMPORT DECISION
Recent Santa Cruz discussions explicitly compare buying locally versus importing from the US. Users frame the tradeoff around price, warranty, import complexity, exact model/configuration and trust.

### EXACT-MODEL / SUBSTITUTION RISK
A Cochabamba-related 2026 discussion reports a buyer being offered RAM/motherboard variants different from the requested exact SKU and warns buyers to insist on exact catalog models. This is highly relevant to IPCENTER Passport / Product Fit / procurement traceability.

### PRICE DISCOVERY
Users describe searching several stores, Marketplace and importers because prices are fragmented and many sellers do not publish current prices. This supports a price/availability intelligence problem, but not yet a price-premium percentage.

### HARD-TO-FIND PRODUCTS
Public users ask where to find particular gamepads, GPUs, laptops or configurations and are referred to Facebook groups, importers or national shipping. This is a concrete hard-to-find sourcing signal.

### NATIONAL SHIPPING / CITY DEMAND
Questions regularly originate outside the seller’s city. Sellers increasingly advertise national shipping, while users ask whether businesses ship to their department. IPCENTER should model `DEMAND_CITY` separately from `SELLER_CITY`.

### USE-CASE FIT
Users ask for laptops by workload: architecture, AutoCAD, Lumion, Revit, Photoshop, DaVinci Resolve, Premiere, gaming and professional work. Competitors already partially address this, so IPCENTER cannot claim generic Product Fit as unique without a deeper advantage.

### SANTA CRUZ CLIMATE / MAINTENANCE SIGNAL
A 2026 Santa Cruz discussion reports concerns about heat affecting high-performance PCs and increased cooling/maintenance needs. This may create a regional service/maintenance/product-configuration signal; it remains qualitative and requires broader corroboration.

## 5. Important strategic correction

`PRODUCT_FIT` alone is not a unique moat.

Several competitors already publicly claim to advise customers by budget/use or map devices to architecture/engineering/design/gaming. IPCENTER differentiation must go deeper:

`NEED → SOFTWARE/WORKLOAD → EXACT REQUIREMENT → LOCAL/IMPORT OPTIONS → CURRENT PRICE → AVAILABILITY → VERIFIED SUPPLIER → WARRANTY → DELIVERY TIME → RISK → QUOTE → SERIAL/PROVENANCE → OUTCOME`

The learning loop after the sale is likely more defensible than generic product recommendation.

## 6. National graph model to build

Every market entity should be represented as nodes/edges:

`BUSINESS → CITY/BRANCH → FACEBOOK → INSTAGRAM → TIKTOK → WHATSAPP → CATALOG → PRODUCTS → PRICES → WARRANTIES → DELIVERY → REVIEWS/COMMENTS → DEMAND SIGNALS`

Cross-city edges:
- national shipping
- local delivery
- branches
- WhatsApp sales
- physical pickup
- import-on-demand

Customer-demand observations must be modeled separately from seller marketing content.

## 7. Next research passes

1. Expand Santa Cruz seller/account registry substantially; do not stop at known neighbors.
2. Resolve each seller’s social handles and public WhatsApp/catalog links.
3. Build city-by-city social competitor maps for La Paz/El Alto, Santa Cruz, Cochabamba, Sucre/Oruro, Tarija/Potosí.
4. Harvest public user-language and demand/friction signals from discussions/comments/reviews.
5. Track exact product/configuration/price only when source/date are explicit.
6. Separate new / refurbished / used / preorder / import-on-demand.
7. Build trust evidence: physical location, verified business identity, warranty, complaints, delivery claims, reviews, serial/model substitution risks.
8. Add B2B procurement and hard-to-find product evidence after laptop/PC core dataset has sufficient coverage.
9. Route resulting dataset to Claude for decision-value analysis and DeepSeek for manipulation/bias/provenance red-team.

## 8. Current decision state

No final wedge selected. No inventory recommendation. No market-size claim.

What is supported now:
- IPCENTER must be modeled as a **national digital/sourcing business**.
- Santa Cruz is a major research priority, not a peripheral city.
- Bolivia’s technology commerce is heavily mediated by social + WhatsApp + physical-store trust + national shipping.
- The market is sufficiently rich that an evidence graph can be built; prior claims of insufficient online evidence were caused in part by inadequate search coverage.

`NATIONAL SOCIAL FORENSIC PASS 2 COMPLETE — CONTINUE DATASET EXPANSION`
