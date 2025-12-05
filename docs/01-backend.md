---
layout: default
title: Documentación Backend
nav_order: 2
has_children: true
description: "Documentación técnica del Backend de Rinderline"
---

# Documentación Técnica - Backend de Rinderline

**Versión:** 1.0  
**Fecha:** Noviembre 2025  
**Framework:** Django 5.2.8 + Django REST Framework 3.15.2 + PostgreSQL  
**Stack:** Python 3.11+ | Django ORM | Token Authentication  
**Despliegue:** Gunicorn + Nginx (Render/Railway) | AWS S3

---

## ÍNDICE

1. [Introducción Técnica](#1-introducción)
2. [Arquitectura General](#2-arquitectura-general)
3. [Estructura del Proyecto](#3-estructura-del-proyecto)
4. [Modelos y Base de Datos](#4-modelos-y-base-de-datos)
5. [API y Endpoints](#5-api-y-endpoints)
6. [Autenticación y Seguridad](#6-autenticación-y-seguridad)
7. [Servicios y Lógica de Negocio](#7-servicios-y-lógica-de-negocio)
8. [Integraciones Externas](#8-integraciones-externas)
9. [Configuración y Despliegue](#9-configuración-y-despliegue)
10. [Troubleshooting y Errores Comunes](#10-troubleshooting-y-errores-comunes)

---

## RESUMEN EJECUTIVO

El backend de Rinderline es una **API REST monolítica construida con Django REST Framework** que gestiona la lógica de negocio completa para la administración de gastos empresariales internacionales.

### Características Clave:

- **Autenticación Token-based:** Sin JWT, utilizando DRF Token Authentication con soporte para múltiples usuarios
- **Arquitectura de Capas:** Views → Services → ORM → Database, con separación clara por features
- **Integraciones:** AWS S3 (almacenamiento), SAP ERP (en desarrollo), APIs de tasas de cambio, Sentry (monitoreo)
- **Soft Delete:** Eliminación lógica en documentos para auditoría completa

### Tecnologías:

- **Backend:** Python 3.11+, Django 5.2.8, DRF 3.15.2
- **BD:** SQLite (dev), PostgreSQL (prod)
- **Autenticación:** Token DRF (no JWT)
- **Almacenamiento:** AWS S3
- **Monitoreo:** Sentry + Prometheus
- **Despliegue:** Gunicorn + Nginx + Render/Railway

---

## 1. Introducción

**Nota:** Esta documentación cubre exclusivamente el backend de Rinderline; los detalles del frontend se documentan en su apartado correspondiente.

### 1.1 Objetivo del Sistema

El backend de Rinderline está diseñado para ofrecer una API robusta y escalable que permita a las empresas gestionar sus gastos internacionales de forma eficiente y segura. Su principal objetivo es centralizar el registro, procesamiento y análisis de gastos —incluyendo viáticos, proveedores y aprobaciones multinivel— con soporte para múltiples monedas y corporativos.

### 1.2 Contexto y Alcance del Backend

Dentro de la arquitectura de Rinderline, el backend cumple la función de:

- **Exponer endpoints RESTful** que implementan la lógica de negocio
- **Validar y almacenar datos** en la base PostgreSQL
- **Gestionar autenticación y autorización** mediante tokens seguros
- **Interactuar con servicios externos** (SAP, AWS S3, APIs de tipo cambio)

El alcance de esta documentación se centra únicamente en los componentes y procesos correspondientes al backend.

### 1.3 Separación de Responsabilidades con el Frontend

Para garantizar una arquitectura desacoplada y mantenible, además de escalable y pensada a futuro para su versión móvil, Rinderline sigue el patrón de separación clara de responsabilidades:

**Backend:**

- Encargado de la lógica de negocio, almacenamiento de datos y seguridad
- Expone una API RESTful documentada con Swagger
- Maneja validaciones complejas y reglas de negocio

**Frontend:**

- Aplicación basada en Next.js que consume la API del backend
- Maneja la interfaz de usuario y experiencia del usuario
- Implementa validaciones de cliente y almacenamiento local

Este enfoque facilita:

- El desarrollo independiente de cada capa
- La evolución y escalabilidad de cada parte
- La mejora de la calidad del código al mantener responsabilidades bien delimitadas
- Facilita testing y debugging de forma aislada

---

## 2. Arquitectura General

### 2.1 Diagrama General del Sistema

```mermaid
flowchart TB
 subgraph Frontend["RINDERLINE FRONTEND"]
        A1["Login / Signup"]
        A2["Documents Management"]
        A3["Approvals System"]
        A4["Dashboard Analytics"]
  end
 subgraph Endpoints["API v1 Endpoints"]
        E1[/"api/v1/app/auth"/]
        E2[/"api/v1/app/documents"/]
        E3[/"api/v1/app/approvals"/]
        E4[/"api/v1/app/dashboards"/]
        E5[/"api/v1/app/sap"/]
        E6[/"api/v1/app/admin"/]
  end
 subgraph Middleware["Middleware & Interceptors"]
        M1["CORS Handler"]
        M2["Token Authentication"]
        M3["Error Handler"]
        M4["Locale Middleware"]
  end
 subgraph Services["Services Layer"]
        S1["Dashboard Service"]
        S2["Approver Dashboard Service"]
        S3["AWS S3 File Store<br>- PDFs<br>- Documents<br>- Uploads"]
        S4["Document Builder"]
        S5["Exchange Rate Service"]
  end
 subgraph DAL["Data Access Layer"]
        D1["Django ORM Models"]
        D2["Query Optimization"]
        D3["Filtering & Pagination"]
  end
 subgraph Backend["RINDERLINE BACKEND API"]
        Endpoints
        Middleware
        Services
        DAL
  end
 subgraph Storage["Storage"]
        DB["SQLite3 Database<br>- SQLAlchemy<br>- Models<br>- Relations<br>- Indexes"]
        APIs["External APIs<br>- Exchange Rates<br>- SAP ERP<br>- Sentry"]
  end
    A1 --> Backend
    A2 --> Backend
    A3 --> Backend
    A4 --> Backend
    Backend --> Storage
```

---

### 2.2 Componentes Principales

#### **A. API Backend (Django REST Framework)**

**Tecnología:** Django 5.2.8 + Django REST Framework 3.15.2

**Responsabilidades:**

- Gestión de endpoints REST para todos los módulos
- Autenticación y autorización de usuarios
- Validación de datos de entrada
- Manejo de respuestas en formato JSend
- Integración con base de datos

**Componentes:**

```
rinderline/
├── settings.py           # Configuración principal de Django
├── urls.py               # Rutas principales de la API
├── wsgi.py               # WSGI para producción
└── asgi.py               # ASGI para desarrollo

app/
├── models.py             # Modelos de base de datos (19 modelos)
├── auth.py               # ViewSet de autenticación
├── renderers.py          # JSend Renderer personalizado
├── filters.py            # Filtros para queries
├── pagination.py         # Configuración de paginación
├── urls.py               # Rutas del app
├── permissions.py        # Permisos customizados
├── parsers.py            # Parsers para multipart/form-data
├── adapters/             # Adaptadores para servicios externos
├── builder/              # Patrón Builder para documentos
├── features/
│   ├── web/              # API endpoints públicos
│   │   ├── approvals/    # Endpoints de aprobaciones
│   │   ├── dashboards/   # Endpoints de dashboards
│   │   ├── documents/    # Endpoints de documentos
│   │   ├── info/         # Endpoints informativos
│   │   ├── reports/      # Endpoints de reportes
│   │   ├── sap/          # Integración SAP
│   │   └── serializers/  # Serializadores de datos
│   └── admin/            # API endpoints administrativos
├── services/             # Lógica de negocio
│   ├── dashboard_service.py
│   ├── approver_dashboard_service.py
│   └── appraisal_service.py
└── tests/                # Suite de pruebas
```

---

#### **B. Base de Datos (SQLite3)**

**Tipo:** SQLite3 (Desarrollo) / PostgreSQL (Producción)

**Modelos Principales:**

| Modelo              | Descripción               | Relaciones                        |
| ------------------- | ------------------------- | --------------------------------- |
| **User**            | Usuarios del sistema      | Company, Groups, Area             |
| **Company**         | Empresas/Organizaciones   | Groups, Currency                  |
| **CostCenter**      | Centros de costo          | Company                           |
| **Document**        | Documentos o informes     | User, Company, CostCenter         |
| **DocumentExpense** | Gastos individuales       | Document, Supplier, Tax, Currency |
| **DocumentTravel**  | Viajes                    | Document, Route                   |
| **DocumentPerDiem** | Viáticos                  | Document, PerDiem                 |
| **ApprovalHistory** | Historial de aprobaciones | User, Document (Generic FK)       |
| **ExpenseFile**     | Archivos adjuntos         | DocumentExpense                   |
| **Supplier**        | Proveedores               | -                                 |
| **Area**            | Áreas de la empresa       | Company                           |
| **Tax**             | Impuestos                 | Company                           |
| **ExpenseConcept**  | Conceptos de gasto        | Company                           |
| **PerDiem**         | Viáticos configurables    | Company                           |
| **Route**           | Rutas de viaje            | Company, Location                 |
| **Currency**        | Monedas                   | Company                           |

**Relaciones Clave:**

- Relaciones de Foreign Key con `on_delete=models.PROTECT` (datos críticos)
- Relaciones Many-to-Many para permisos
- Generic Foreign Key para ApprovalHistory (polimorfismo)
- Soft delete (logical delete) en documents con campo `erased_at`

---

#### **C. Capa de Servicios**

**Ubicación:** `app/services/`

**Servicios Disponibles:**

1. **DashboardService** (`dashboard_service.py`)

   - Calcula resúmenes para empleados
   - Agrupa documentos por estado
   - Calcula totales y promedios

2. **ApproverDashboardService** (`approver_dashboard_service.py`)

   - Dashboards para aprobadores por usuario
   - Dashboards para aprobadores por centro de costo
   - Dashboards para aprobadores por empresa

3. **AppraisalService** (`appraisal_service.py`)
   - Lógica de aprobación
   - Validación de niveles de aprobación
   - Actualización de estados

---

#### **D. Capa de Adaptadores**

**Ubicación:** `app/adapters/`

**Adaptadores Disponibles:**

1. **ExchangeRateService**
   - Integración con API de tasas de cambio
   - Conversión de divisas
   - Caché de tasas

---

#### **E. Patrón Builder**

**Ubicación:** `app/builder/`

**Propósito:**

- Construcción compleja de documentos con múltiples items
- Validación y cálculo de totales
- Conversión de divisas
- Asociación de archivos

**Método:**

```python
DocumentBuilder()
    .create_document(data, user)
    .add_expense(expense_data)
    .add_travel(travel_data)
    .add_per_diem(per_diem_data)
    .build()
```

---

### 2.3 Estilo Arquitectónico

**Tipo:** **REST API Monolítica con Arquitectura de Capas**

#### **Características:**

1. **Estilo REST**

   - Métodos HTTP estándar: GET, POST, PUT, PATCH, DELETE
   - Recursos definidos (/documents, /approvals, etc.)
   - Versionado en URL (/api/v1/)
   - HATEOAS parcial (referencias en respuestas)

2. **Arquitectura de Capas**

   ```mermaid
   flowchart TB
    A["Presentation Layer<br/>(Views / ViewSets)"]
    B["Business Logic Layer<br/>(Services)"]
    C["Data Access Layer<br/>(Models / ORM)"]
    D["Database Layer<br/>(SQLite / PostgreSQL)"]

    A --> B --> C --> D
   ```

3. **Patrones Utilizados**

   - **ViewSet Pattern**: Manejo de CRUD con DRF
   - **Builder Pattern**: Construcción de documentos complejos
   - **Adapter Pattern**: Integración con servicios externos
   - **Generic Foreign Key**: Polimorfismo en ApprovalHistory

4. **Aislamiento de Responsabilidades**
   - Features: Separadas por dominio (web, admin)
   - Serializers: Validación y transformación de datos
   - Filters: Lógica de filtrado
   - Permissions: Control de acceso

---

### 2.4 Flujo General de una Petición (Request Lifecycle)

#### **Ciclo Completo de una Petición:**

```mermaid
flowchart TB

    %% CLIENT REQUEST
    A["**CLIENT REQUEST**<br/>POST /api/v1/app/documents/"]

    %% 1. URL ROUTING
    B["**1. DJANGO URL ROUTING**<br/><br/>rinderline/urls.py → app/urls.py → features/web/urls.py<br/>Coincide con: path('documents/', DocumentListView.as_view())"]

    %% 2. MIDDLEWARE (REQUEST)
    C["**2. MIDDLEWARE PROCESSING (Request Phase)**<br/><br/>✓ CorsMiddleware – Validar origen CORS<br/>✓ SecurityMiddleware – Headers de seguridad<br/>✓ SessionMiddleware – Sesión<br/>✓ AuthenticationMiddleware – Identificación<br/>✓ LocaleMiddleware – Idioma"]

    %% 3. VIEW/VIEWSET
    D["**3. VIEW/VIEWSET PROCESSING**<br/><br/>DocumentListView.post(request)<br/><br/>a) Autenticación: TokenAuthentication<br/>- Extraer token del header Authorization<br/>- Validar token en DB<br/>- Asignar request.user<br/><br/>b) Permisos: IsAuthenticated<br/>- request.user debe existir<br/><br/>c) Throttling: Anon/User Rate Throttle<br/>- Límite 1000 req/day<br/><br/>d) Filtering: DjangoFilterBackend<br/>- Aplicar filtros"]

    %% 4. SERIALIZER VALIDATION
    E["**4. SERIALIZER VALIDATION**<br/><br/>DocumentSerializer.is_valid()<br/><br/>✓ Validar campos requeridos<br/>✓ Tipos de datos<br/>✓ Ranges (max_digits, decimal_places)<br/>✓ Validar Foreign Keys<br/>✓ Validadores custom<br/><br/>Si falla → 400 Bad Request (JSend fail)"]

    %% 5. BUSINESS LOGIC (SERVICES)
    F["**5. BUSINESS LOGIC (Services Layer)**<br/><br/>DocumentService.create_document()<br/><br/>✓ Usar DocumentBuilder<br/>✓ Validar reglas de negocio<br/>✓ Conversiones de divisas<br/>✓ Auditoría si aplica<br/>✓ Notificaciones si aplica"]

    %% 6. ORM / DB OPERATIONS
    G["**6. DATABASE OPERATIONS (ORM Layer)**<br/><br/>Document.objects.create(... )<br/><br/>✓ Validaciones de modelo (clean())<br/>✓ Insertar en DB<br/>✓ Retornar objeto<br/><br/>Si hay error → 500 Error"]

    %% 7. RESPONSE SERIALIZATION
    H["**7. RESPONSE SERIALIZATION**<br/><br/>DocumentSerializer(document).data<br/><br/>✓ Convertir objeto a dict<br/>✓ Campos permitidos<br/>✓ Relaciones anidadas<br/>✓ Transformaciones custom"]

    %% 8. RENDERER
    I["**8. RENDERER (JSendRenderer)**<br/><br/>{<br/>  status: 'success',<br/>  data: { ... }<br/>}"]

    %% 9. MIDDLEWARE (RESPONSE)
    J["**9. MIDDLEWARE PROCESSING (Response Phase)**<br/><br/>✓ CORS Headers<br/>✓ Security Headers<br/>✓ Content-Type JSON<br/><br/>Response Headers:<br/>• Content-Type: application/json<br/>• Access-Control-Allow-Origin: https://frontend.com<br/>• X-Content-Type-Options: nosniff<br/>• X-Frame-Options: DENY"]

    %% FINAL RESPONSE
    K["**RESPONSE TO CLIENT**<br/><br/>HTTP/1.1 201 Created<br/>Content-Type: application/json<br/><br/>{ status: 'success', data: { id: 1, title: 'Gasto de viaje', ... } }"]

    %% FLOW CONNECTIONS
    A --> B --> C --> D --> E --> F --> G --> H --> I --> J --> K

```

---

#### **Casos de Error en el Ciclo:**

```mermaid
flowchart TB

    %% ERROR 401 - INVALID TOKEN
    E401["**ERROR: Token No Válido**<br/><br/>Status: 401 Unauthorized<br/>Fase: Authentication<br/><br/>{<br/>  status: 'fail',<br/>  message: 'Invalid token'<br/>}"]

    %% ERROR 400 - VALIDATION ERROR
    E400["**ERROR: Validación de Datos**<br/><br/>Status: 400 Bad Request<br/>Fase: Serializer Validation<br/><br/>{<br/>  status: 'fail',<br/>  message: 'Validation error',<br/>  errors: {...}<br/>}"]

    %% ERROR 404 - NOT FOUND
    E404["**ERROR: Recurso No Encontrado**<br/><br/>Status: 404 Not Found<br/>Fase: Database Query<br/><br/>{<br/>  status: 'fail',<br/>  message: 'Document not found'<br/>}"]

    %% ERROR 500 - DATABASE ERROR
    E500["**ERROR: Error de Base de Datos**<br/><br/>Status: 500 Internal Server Error<br/>Fase: Database Operations<br/><br/>{<br/>  status: 'error',<br/>  message: 'An error occurred'<br/>}<br/><br/>Log: Enviado a Sentry"]

    %% ORDER (optional)
    E401 --> E400 --> E404 --> E500
```

---

### 2.5 Integraciones Externas

#### **A. Autenticación (Token-Based)**

**Implementación:** Django Rest Framework Token Authentication

**Flujo:**

```
1. Usuario hace login
   POST /api/v1/app/auth/login/
   Body: {"username": "...", "password": "..."}

2. Backend valida credenciales contra modelo User
3. Backend genera/recupera Token
4. Respuesta: {"token": "abc123def456..."}

5. Cliente almacena token en localStorage/sessionStorage

6. Peticiones posteriores incluyen token:
   GET /api/v1/app/documents/
   Headers: Authorization: Token abc123def456...

7. Backend valida token y asocia a usuario
```

**Características:**

- Tokens almacenados en tabla `authtoken_token`
- 1 token por usuario (se reemplaza al login)
- Sin expiración en el código (se puede agregar)
- Logout elimina el token

---

#### **B. API de Tasas de Cambio**

**Servicio:** ExchangeRateService (`app/adapters/adapters.py`)

**Propósito:** Convertir montos entre divisas

**Flujo:**

```
1. Al crear DocumentExpense con currency ≠ base_currency
2. ExchangeRateService obtiene tasa de cambio
3. Calcula: converted_amount = original_amount / exchange_rate
4. Guarda ambos valores en DB

Métodos:
- get_rate(from_currency, to_currency) → float
- convert(amount, from_currency, to_currency) → float
```

---

#### **C. Almacenamiento en AWS S3**

**Configuración:** STORAGES en settings.py

**Uso:**

- Documentos PDF (field: Document.file)
- Archivos de gastos (ExpenseFile)

**Configuración:**

```python
AWS_STORAGE_BUCKET_NAME = os.getenv('AWS_STORAGE_BUCKET_NAME')
AWS_ACCESS_KEY_ID = os.getenv('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = os.getenv('AWS_SECRET_ACCESS_KEY')
AWS_S3_CUSTOM_DOMAIN = 'bucket-name.s3.amazonaws.com'
```

**Rutas:**

- Documentos: `documents/{year}/{month}/{filename}`

---

#### **D. Integración SAP ERP (en desarrollo)**

**Endpoints:**

- GET `/api/v1/app/sap/documents/` - Listar documentos en SAP
- POST `/api/v1/app/sap/documents/send/` - Enviar documento a SAP

**Flujo:**

```
1. Usuario completa documento en Rinderline
2. Usuario aprueba y marca para enviar
3. Sistema convierte documento a formato SAP
4. Envía datos a API SAP
5. SAP confirma recepción
6. Sistema guarda external_code de SAP
```

**Formato de Integración:** Por definir (JSON, XML, SOAP, etc.)

---

#### **E. Monitoreo y Logging (Sentry)**

**Configuración:** `django_sentry` (puede agregarse)

**Captura:**

- Excepciones no manejadas
- Errores 500+
- Errores de base de datos
- Timeouts

**Propósito:**

- Alertas en tiempo real
- Tracking de errores
- Stack traces completos

---

#### **F. Email (Futuro)**

**Servicio:** Django Email Backend (por configurar)

**Casos de Uso:**

- Notificación de documentos pendientes de aprobación
- Confirmación de aprobación/rechazo
- Recordatorios de vencimientos

---

#### **G. Análisis y Métricas (Prometheus)**

**Instalado:** `django-prometheus` en requirements.txt

**Endpoints:**

- `/metrics` - Métricas Prometheus
- Recolecta: Latencias, requests, errores, etc.

---

## Resumen de Arquitectura

| Aspecto                   | Implementación                    |
| ------------------------- | --------------------------------- |
| **Patrón Arquitectónico** | Monolito con capas (MVC)          |
| **Estilo API**            | REST con JSend                    |
| **Autenticación**         | Token (DRF)                       |
| **Base de Datos**         | SQLite (Dev) / PostgreSQL (Prod)  |
| **ORM**                   | Django ORM                        |
| **Validación**            | Serializers + Model validation    |
| **Almacenamiento**        | AWS S3                            |
| **Cache**                 | Por implementar                   |
| **Cola de Tareas**        | Por implementar (Celery)          |
| **Logging**               | Django + Sentry                   |
| **Monitoreo**             | Prometheus                        |
| **Despliegue**            | Gunicorn + Nginx (Render/Railway) |

---

## 3. Estructura del Proyecto

### 3.1 Estructura de Carpetas

```
rinderline_backend/rinderline/
│
├── rinderline/                    # Configuración del proyecto
│   ├── settings.py               # Configuración de Django (DEBUG, DATABASES, APPS, etc.)
│   ├── urls.py                   # Rutas principales (API v1, admin, swagger)
│   ├── wsgi.py                   # Entry point para producción (Gunicorn)
│   ├── asgi.py                   # Entry point para desarrollo (Uvicorn)
│   └── __pycache__/
│
├── app/                           # Aplicación principal
│   ├── models.py                 # 19 modelos de Django ORM
│   ├── auth.py                   # ViewSet de autenticación (login, register, logout)
│   ├── admin.py                  # Configuración de Django Admin
│   ├── apps.py                   # Configuración de la app
│   ├── urls.py                   # URLs raíz del app
│   ├── renderers.py              # JSendRenderer personalizado
│   ├── filters.py                # Filtros para queries (DocumentFilter, ItemsFilter)
│   ├── pagination.py             # Configuración de paginación (SmallPagination)
│   ├── parsers.py                # Parser multipart/form-data restructure_multipart()
│   ├── forms.py                  # Formularios Django (validación)
│   ├── __init__.py
│   │
│   ├── adapters/                 # Patrón Adapter para servicios externos
│   │   ├── adapters.py           # ExchangeRateService
│   │   └── __pycache__/
│   │
│   ├── builder/                  # Patrón Builder para documentos complejos
│   │   ├── builder.py            # Clase DocumentBuilder
│   │   ├── use_cases.py          # Use Cases (CreateDocument, AddExpense, etc.)
│   │   └── __pycache__/
│   │
│   ├── features/                 # Separación de features por dominio
│   │   ├── web/                  # API endpoints públicos (usuarios normales)
│   │   │   ├── urls.py           # Rutas de web features
│   │   │   ├── permissions.py    # Permisos customizados
│   │   │   │
│   │   │   ├── approvals/        # Feature: Aprobaciones
│   │   │   │   └── views.py      # Views: Pending, History, Update
│   │   │   │
│   │   │   ├── dashboards/       # Feature: Dashboards
│   │   │   │   └── views.py      # Views: Employee, UserApprover, etc.
│   │   │   │
│   │   │   ├── documents/        # Feature: Documentos
│   │   │   │   └── views.py      # Views: List, Detail, Items
│   │   │   │
│   │   │   ├── info/             # Feature: Información general
│   │   │   │   └── views.py      # Views: Test, User, Profile, Suppliers
│   │   │   │
│   │   │   ├── reports/          # Feature: Reportes
│   │   │   │   └── views.py      # Views: Upload, Delete Status
│   │   │   │
│   │   │   ├── sap/              # Feature: Integración SAP
│   │   │   │   └── views.py      # Views: SAP Documents, SAP Post
│   │   │   │
│   │   │   └── serializers/      # Serializadores (validación y transformación)
│   │   │       ├── serializers.py   # Serializers principales
│   │   │       ├── approvals.py     # Serializadores de aprobaciones
│   │   │       ├── common.py        # Serializadores comunes
│   │   │       ├── documents.py     # Serializadores de documentos
│   │   │       ├── items.py         # Serializadores de items
│   │   │       ├── sap.py           # Serializadores SAP
│   │   │       └── __pycache__/
│   │   │
│   │   └── admin/                # API endpoints administrativos
│   │       ├── urls.py           # Rutas de admin features
│   │       ├── admin.py          # Configuración y registros
│   │       ├── serializers.py    # Serializadores admin
│   │       └── __pycache__/
│   │
│   ├── services/                 # Capa de servicios (lógica de negocio)
│   │   ├── dashboard_service.py           # Cálculos de dashboard empleado
│   │   ├── approver_dashboard_service.py  # Cálculos de dashboard aprobador
│   │   ├── appraisal_service.py           # Lógica de aprobación
│   │   └── __pycache__/
│   │
│   ├── migrations/               # Migraciones de base de datos
│   │   ├── 0001_initial.py
│   │   ├── 0002_groups_rename_user_approvalhistory_approver_and_more.py
│   │   ├── ... (más migraciones)
│   │   └── __pycache__/
│   │
│   ├── tests/                    # Suite de pruebas
│   │   ├── test_*.py
│   │   └── __pycache__/
│   │
│   └── __pycache__/
│
├── locale/                        # Internacionalización (i18n)
│   ├── de/
│   │   └── LC_MESSAGES/
│   ├── en/
│   │   └── LC_MESSAGES/
│   ├── es/
│   │   └── LC_MESSAGES/
│   └── fr/
│       └── LC_MESSAGES/
│
├── stylescss/                     # Estilos estáticos
│   └── admin/
│
├── templates/                     # Plantillas HTML (Django Admin)
│   └── admin/
│
├── venv/                          # Virtual environment (no versionado)
│
├── .env                           # Variables de entorno (no versionado)
├── db.sqlite3                     # Base de datos SQLite (no versionado)
├── manage.py                      # CLI de Django
├── build.sh                       # Script de build para producción
├── requirements.txt               # Dependencias de Python
└── README.md                      # Documentación del proyecto
```

---

### 3.2 Explicación de Módulos Clave

#### **A. rinderline/ (Configuración)**

| Archivo       | Responsabilidad                                                                                          |
| ------------- | -------------------------------------------------------------------------------------------------------- |
| `settings.py` | Configuración global: DEBUG, ALLOWED_HOSTS, DATABASES, INSTALLED_APPS, MIDDLEWARE, AUTH, CORS, AWS, etc. |
| `urls.py`     | Rutas principales: `/admin/`, `/api/v1/app/`, `/api/v1/app/swagger/`                                     |
| `wsgi.py`     | WSGI para servidores como Gunicorn (producción)                                                          |
| `asgi.py`     | ASGI para servidores async como Uvicorn (desarrollo)                                                     |

---

#### **B. app/ (Aplicación Principal)**

| Módulo          | Responsabilidad                                              |
| --------------- | ------------------------------------------------------------ |
| `models.py`     | Definición de 19 modelos ORM (User, Company, Document, etc.) |
| `auth.py`       | ViewSet REST para login, register, logout con Token Auth     |
| `admin.py`      | Registros en Django Admin con filtros y permisos por grupo   |
| `filters.py`    | Filtros DjangoFilter para búsqueda y filtrado de documentos  |
| `pagination.py` | Configuración de paginación (15 items por página)            |
| `renderers.py`  | Custom renderer JSend para respuestas estándar               |
| `parsers.py`    | Parser para multipart/form-data con arrays anidados          |

---

#### **C. app/adapters/ (Servicios Externos)**

**ExchangeRateService**

- Obtiene tasas de cambio de API externa
- Convierte montos entre monedas
- Integración con DocumentBuilder

---

#### **D. app/builder/ (Patrón Builder)**

```
builder.py
├── DocumentBuilder           # Clase que implementa el patrón Builder
│   ├── create_document()     # Crea documento base
│   ├── add_expense()         # Agrega gasto
│   ├── add_travel()          # Agrega viaje
│   ├── add_per_diem()        # Agrega viático
│   └── build()               # Retorna documento construido
│
use_cases.py
├── CreateDocumentUseCase
├── AddExpenseToDocumentUseCase
├── AddTravelToDocumentUseCase
└── AddPerDiemToDocumentUseCase
```

---

#### **E. app/features/ (Separación por Dominio)**

**Estructura de Feature:**

```
feature/
├── views.py              # ViewSets/Views REST
├── urls.py               # Rutas específicas
├── serializers/          # Serializadores
│   ├── serializers.py    # Serializadores comunes
│   └── specific.py       # Serializadores específicos
├── permissions.py        # Permisos customizados
└── __pycache__/
```

**Features Disponibles:**

1. **web/approvals/** - Gestión de aprobaciones

   - Listar pendientes
   - Historial de aprobaciones
   - Actualizar estado de gastos/viajes/viáticos

2. **web/dashboards/** - Dashboards e informes

   - Dashboard empleado
   - Dashboard aprobador por usuario
   - Dashboard aprobador por centro de costo
   - Dashboard aprobador por empresa

3. **web/documents/** - Gestión de documentos

   - Listar documentos
   - Detalle de documento
   - Items de documento

4. **web/info/** - Información general

   - Perfil de usuario
   - Información de empresa
   - Proveedores
   - Reportes

5. **web/reports/** - Reportes

   - Subir reportes
   - Eliminar lógico de reportes

6. **web/sap/** - Integración SAP

   - Listar documentos en SAP
   - Enviar documentos a SAP

7. **admin/** - Endpoints administrativos
   - Gestión de usuarios
   - Gestión de configuración

---

#### **F. app/services/ (Lógica de Negocio)**

**DashboardService**

```python
def get_employee_dashboard(user):
    # Agrupa documentos por estado
    # Calcula totales y promedios
    # Retorna resumen para dashboard
```

**ApproverDashboardService**

```python
def get_approver_dashboard_user(approver):
    # Documentos pendientes de aprobación
    # Agrupados por usuario

def get_approver_dashboard_cost_center(approver):
    # Documentos pendientes de aprobación
    # Agrupados por centro de costo

def get_approver_dashboard_company(approver):
    # Documentos pendientes de aprobación
    # Agrupados por empresa
```

**AppraisalService**

```python
def approve_expense(expense, approver, comments):
    # Valida que approver tiene permisos
    # Actualiza estado a APPROVED
    # Crea registro de ApprovalHistory

def reject_expense(expense, approver, comments):
    # Valida que approver tiene permisos
    # Actualiza estado a REJECTED
    # Crea registro de ApprovalHistory
```

---

#### **G. app/serializers/ (Validación y Transformación)**

Estructura de serializadores:

```python
# common.py - Serializadores comunes
class UserSerializer
class CompanySerializer
class CostCenterSerializer

# documents.py - Serializadores de documentos
class DocumentSerializer
class DocumentListSerializer
class DocumentDetailSerializer

# items.py - Serializadores de items
class DocumentExpenseSerializer
class DocumentTravelSerializer
class DocumentPerDiemSerializer
class ExpenseFileSerializer

# approvals.py - Serializadores de aprobaciones
class ApprovalHistorySerializer
class ApprovalUpdateSerializer

# sap.py - Serializadores SAP
class SapDocumentSerializer
```

---

### 3.3 Convenciones de Nombres y Estilos

#### **A. Nomenclatura de Modelos**

```
✓ User (no Users)
✓ Company (no Companies)
✓ Document (no Documents)
✓ DocumentExpense (no ExpenseDocument)
✓ ApprovalHistory (no ApprovalHistories)
```

**Reglas:**

- Singular
- PascalCase
- Descriptivo del dominio

---

#### **B. Nomenclatura de ViewSets**

```
✓ DocumentListView          # Para listar y crear
✓ DocumentDetailView        # Para retrieve, update, delete
✓ ApprovalPendingListView   # Para listar pendientes
✓ Auth (ViewSet)            # Para acciones especiales (login, register)
```

**Convención:**

- `{Model}ListView` para GET list y POST create
- `{Model}DetailView` para GET detail, PUT/PATCH, DELETE
- `{Action}{Entity}View` para vistas específicas
- Heredan de `generics.ListAPIView`, `generics.RetrieveUpdateAPIView`, etc.

---

#### **C. Nomenclatura de URLs**

```
✓ /api/v1/app/documents/                     # List/Create
✓ /api/v1/app/documents/<int:pk>/            # Detail/Update/Delete
✓ /api/v1/app/documents/<int:pk>/items/      # Sub-recursos
✓ /api/v1/app/documents/<int:pk>/delete/     # Acciones POST custom
✓ /api/v1/app/approvals/pending/             # Listados filtrados
```

**Convención:**

- Versionado en URL (`/api/v1/`)
- Recursos en plural
- Sub-recursos anidados
- Acciones custom como sub-rutas POST

---

#### **D. Nomenclatura de Serializers**

```
✓ DocumentSerializer          # Para create/update
✓ DocumentListSerializer      # Para list (campos limitados)
✓ DocumentDetailSerializer    # Para detail (campos completos)
✓ DocumentApprovalSerializer  # Para contexto específico
```

**Convención:**

- `{Model}Serializer` para CRUD completo
- `{Model}{Action}Serializer` para acciones específicas
- Separados en archivos por feature

---

#### **E. Estilo de Código Python**

**PEP 8 Compliance:**

- 4 espacios de indentación
- Máximo 79 caracteres por línea (docstrings 72)
- Nombres de variables: `snake_case`
- Nombres de constantes: `UPPER_CASE`
- Nombres de clases: `PascalCase`

**Ejemplo:**

```python
class DocumentSerializer(serializers.ModelSerializer):
    """Serializador para Document model con validación custom."""

    user = UserSerializer(read_only=True)
    cost_center = CostCenterSerializer(read_only=True)

    class Meta:
        model = Document
        fields = ['id', 'title', 'state', 'user', 'cost_center']
        read_only_fields = ['id', 'created_at', 'updated_at']

    def validate_title(self, value):
        """Validar que el título no esté vacío."""
        if not value or len(value.strip()) == 0:
            raise serializers.ValidationError("El título no puede estar vacío.")
        return value
```

---

#### **F. Estilo de API Responses**

**Éxito (JSend):**

```json
{
  "status": "success",
  "data": {
    "id": 1,
    "title": "Gasto de viaje",
    "state": "SAVED"
  }
}
```

**Error de Validación:**

```json
{
  "status": "fail",
  "message": "Validation error",
  "errors": {
    "title": ["Este campo es requerido."],
    "amount": ["Este valor debe ser un decimal válido."]
  }
}
```

**Error de Servidor:**

```json
{
  "status": "error",
  "message": "An error occurred"
}
```

---

### 3.4 Dependencias y Librerías Importantes

#### **A. Framework y ORM**

| Paquete             | Versión | Propósito         |
| ------------------- | ------- | ----------------- |
| Django              | 5.2.8   | Framework web     |
| djangorestframework | 3.15.2  | REST API          |
| psycopg2-binary     | 2.9.10  | Driver PostgreSQL |

---

#### **B. Autenticación y Autorización**

| Paquete                  | Versión         | Propósito            |
| ------------------------ | --------------- | -------------------- |
| rest_framework.authtoken | Incluido en DRF | Token authentication |
| django-cors-headers      | 4.4.0           | CORS handling        |

---

#### **C. Documentación y Validación**

| Paquete       | Versión | Propósito                     |
| ------------- | ------- | ----------------------------- |
| drf-yasg      | 1.21.8  | Documentación Swagger/OpenAPI |
| PyYAML        | 6.0.2   | Parsing YAML                  |
| django-filter | 25.2    | Filtrado de queries           |

---

#### **D. Almacenamiento**

| Paquete         | Versión | Propósito         |
| --------------- | ------- | ----------------- |
| django-storages | 1.14.4  | Backend S3        |
| boto3           | 1.36.16 | Cliente AWS SDK   |
| s3transfer      | 0.11.2  | Transferencias S3 |

---

#### **E. Monitoreo y Logging**

| Paquete           | Versión | Propósito           |
| ----------------- | ------- | ------------------- |
| sentry-sdk        | 1.32.0  | Error tracking      |
| django-prometheus | 2.3.1   | Métricas Prometheus |
| prometheus-client | 0.17.1  | Cliente Prometheus  |

---

#### **F. Utilidades**

| Paquete         | Versión     | Propósito            |
| --------------- | ----------- | -------------------- |
| python-dotenv   | 1.0.1       | Variables de entorno |
| requests        | 2.32.3      | Cliente HTTP         |
| python-dateutil | 2.9.0.post0 | Manejo de fechas     |
| pytz            | 2025.1      | Zonas horarias       |

---

#### **G. Producción**

| Paquete         | Versión | Propósito                 |
| --------------- | ------- | ------------------------- |
| gunicorn        | 23.0.0  | WSGI server               |
| whitenoise      | 6.7.0   | Servir archivos estáticos |
| uvicorn         | 0.32.0  | ASGI server               |
| dj-database-url | 2.3.0   | Parsing URL de DB         |

---

## Resumen de Estructura

| Aspecto               | Detalle                                      |
| --------------------- | -------------------------------------------- |
| **Tipo de Proyecto**  | Django REST API                              |
| **Patrón**            | MVC (Models, Views, Controllers/Serializers) |
| **Organización**      | Por features + servicios                     |
| **Documentación API** | Swagger + OpenAPI (drf-yasg)                 |
| **Testing**           | Por implementar                              |
| **Linting**           | Por implementar (recomendado: black, flake8) |
| **Validación**        | Serializers + Modelo                         |
| **Autenticación**     | Token based                                  |
| **Almacenamiento**    | AWS S3 + SQLite/PostgreSQL                   |

---

## 4. Modelos y Base de Datos

### 4.1 Diagrama Entidad-Relación (ER)

```
┌─────────────┐              ┌────────────────┐
│   Groups    │◄─────────────┤   Company      │
│             │ FK           │                │
│ - id (PK)   │              │ - id (PK)      │
│ - name      │              │ - name (UQ)    │
└─────────────┘              │ - rut (UQ)     │
      ▲                       │ - address      │
      │ M2M                   │ - email        │
      │                       │ - sap_code     │
      │                       │ - clvct        │
      │                       │ - base_currency(FK)
      │                       └────────────────┘
      │                              ▲
      │                              │ 1
      │                        ┌─────┴──────┐
      │                        │            │
┌──────┴──────┐          ┌─────▼────┐ ┌──────▼────┐
│   User      │          │ Currency │ │CostCenter │
│             │          │          │ │           │
│ - id (PK)   │          │ - id(PK) │ │ - id(PK)  │
│ - username  │          │ - name   │ │ - name(UQ)│
│ - rut (UQ)  │          │ - comments   │ - code(UQ)│
│ - role      │          └──────────┘ │ - company │
│ - company   │                         └───────────┘
│ - area      │                              ▲
│ - password  │                              │ 1
└─────────────┘                              │
      │                                      │
      │ 1                        ┌───────────┴─────────────┐
      │                          │ N                     N │
      ▼ N                 ┌──────▼────────┐      ┌────────▼──────┐
┌────────────────────┐    │  Document    │      │    Access    │
│ UserApprover       │    │              │      │              │
│ - user (FK)        │    │ - id (PK)    │      │ - user (FK)  │
│ - can_approve_for  │    │ - title      │      │ - costcenter │
│   (M2M User)       │    │ - state      │      │   (FK)       │
└────────────────────┘    │ - enterprise │      │ - comments   │
                          │   (FK)       │      └──────────────┘
┌──────────────────────┐  │ - user (FK)  │
│CostCenterApprover    │  │ - cost_center│      ┌──────────────┐
│ - user (FK)          │  │   (FK)       │      │     Area     │
│ - cost_center        │  │ - file       │      │              │
│   (M2M CostCenter)   │  │ - paid       │      │ - id (PK)    │
└──────────────────────┘  │ - erased_at  │      │ - name       │
                          │ - created_at │      │ - company(FK)│
┌──────────────────────┐  │ - updated_at │      └──────────────┘
│ CompanyApprover      │  └──────────────┘
│ - user (FK)          │         ▲
│ - company            │         │ 1
│   (M2M Company)      │         │
└──────────────────────┘         │
                                 │ N
        ┌────────────────────────┼────────────────┬──────────────┐
        │                        │                │              │
   ┌────▼──────────┐      ┌──────▼─────────┐ ┌──▼──────────┐ ┌──▼──────────┐
   │DocumentExpense│      │DocumentTravel  │ │DocumentPerD│ │ApprovalHis  │
   │               │      │                │ │iem         │ │tory         │
   │ - id (PK)     │      │ - id (PK)      │ │            │ │             │
   │ - title       │      │ - date         │ │ - id (PK)  │ │ - id (PK)   │
   │ - document    │      │ - number_people│ │ - initial_ │ │ - level     │
   │   (FK)        │      │ - total        │ │   date     │ │ - approver  │
   │ - supplier    │      │ - route (FK)   │ │ - final_   │ │   (FK)      │
   │   (FK)        │      │ - comments     │ │   date     │ │ - document  │
   │ - tax (FK)    │      │ - document (FK)│ │ - total    │ │   (FK)      │
   │ - currency    │      │ - erased_at    │ │ - per_diem │ │ - is_approved
   │   (FK)        │      │ - created_at   │ │   (FK)     │ │ - operation_│
   │ - expense_    │      │ - updated_at   │ │ - document │ │   date      │
   │   concept(FK) │      └────────────────┘ │   (FK)     │ │ - comments  │
   │ - created_at  │                        │ - erased_at│ │             │
   │ - updated_at  │                        │ - created_│ │ (Generic FK)│
   │ - erased_at   │                        │   at       │ │             │
   └────┬──────────┘                        │ - updated_│ └─────────────┘
        │                                   │   at      │
        │ 1                                 │ - erased_ │
        │                                   │   at      │
        ▼ N                                 └───────────┘
   ┌──────────────────┐
   │  ExpenseFile     │   ┌────────────┐    ┌──────────┐   ┌──────────┐
   │                  │   │   Supplier │    │   Tax    │   │PerDiem   │
   │ - id (PK)        │   │            │    │          │   │          │
   │ - file           │   │ - id (PK)  │    │ - id(PK) │   │ - id(PK) │
   │ - document_      │   │ - name     │    │ - name   │   │ - name   │
   │   expense (FK)   │   │ - rut (UQ) │    │ - percentage│ │ - amount │
   │ - uploaded_at    │   │ - company  │    │ - company│   │ - company│
   └──────────────────┘   │   (FK)     │    │  (FK)    │   │  (FK)    │
                          └────────────┘    └──────────┘   └──────────┘

                      ┌────────────────┐   ┌──────────────┐
                      │ ExpenseConcept │   │ DocumentClass│
                      │                │   │              │
                      │ - id (PK)      │   │ - id (PK)    │
                      │ - name         │   │ - name       │
                      │ - description  │   │ - code       │
                      │ - company (FK) │   │ - document_  │
                      └────────────────┘   │   type       │
                                           │ - expense_   │
                      ┌────────────────┐   │   type       │
                      │   Location     │   │ - expense_   │
                      │                │   │   concept(FK)│
                      │ - id (PK)      │   │ - company(FK)│
                      │ - name         │   └──────────────┘
                      │ - description  │
                      └────────────────┘   ┌──────────────────┐
                             ▲            │AccountingAccount │
                             │ 2           │                  │
                      ┌──────┴────────┐    │ - id (PK)        │
                      │    Route      │    │ - name           │
                      │               │    │ - code           │
                      │ - id (PK)     │    │ - account        │
                      │ - name        │    │ - document_type  │
                      │ - distance_km │    │ - expense_concept│
                      │ - toll_cost   │    │ - company (FK)   │
                      │ - company(FK) │    └──────────────────┘
                      └────────────────┘

Legend:
  PK = Primary Key
  FK = Foreign Key
  UQ = Unique
  M2M = Many-to-Many
  1 = One
  N = Many
```

---

### 4.2 Modelos Principales (Descripción Uno por Uno)

#### **Nivel 1: Organización y Usuarios**

##### **1. Groups**

**Propósito:** Agrupar empresas y usuarios por clasificación organizacional.

**Campos:**

- `id` (PK): Identificador único
- `name` (CharField, max_length=100): Nombre del grupo

**Relaciones:**

- Company (1:N) - Un grupo tiene muchas empresas
- User (M2M) - Un grupo tiene muchos usuarios

**Ejemplo:** `Grupo Constructora`, `Grupo Retail`, `Grupo Financiero`

---

##### **2. Company**

**Propósito:** Representa cada empresa/organización del sistema.

**Campos:**

- `id` (PK): Identificador único
- `name` (CharField, max_length=40, unique=True): Nombre de la empresa
- `rut` (CharField, max_length=10, unique=True): Identificador fiscal (RUT, en el caso de Chile)
- `address` (CharField, max_length=120): Dirección física
- `email` (CharField, max_length=60): Email de contacto
- `sap_code` (CharField, max_length=20): Código para integración SAP
- `clvct` (CharField, max_length=10): Código cliente
- `group` (FK → Groups): Grupo a que pertenece
- `base_currency` (FK → Currency): Moneda base para conversiones
- `currencies_allowed` (M2M → Currency): Monedas permitidas para gasto
- `created_at`, `updated_at` (DateTimeField)

**Relaciones:**

- Groups (N:1) - FK con PROTECT
- Currency (N:1) - Base currency
- User (1:N) - Usuarios de la empresa
- CostCenter (1:N) - Centros de costo
- Area (1:N) - Áreas
- Supplier (1:N) - Proveedores
- Document (1:N) - Documentos
- Route (1:N) - Rutas
- Tax (1:N) - Impuestos
- ExpenseConcept (1:N) - Conceptos de gasto
- PerDiem (1:N) - Viáticos
- DocumentClass (1:N) - Clasificación de documentos
- AccountingAccount (1:N) - Cuentas contables

**Validaciones:**

- `name` debe ser único
- `rut` debe ser único

---

##### **3. User (Custom Auth Model)**

**Propósito:** Usuarios del sistema con roles diferenciados.

**Campos:**

- Heredados de AbstractUser: `username`, `password`, `email`, `first_name`, `last_name`, `is_active`, `is_staff`, `is_superuser`, `date_joined`, `last_login`
- `role` (CharField, choices=['USER', 'APPROVER', 'ADMIN']): Rol del usuario
- `rut` (CharField, max_length=20, unique=True): Identificador fiscal
- `phone` (CharField, max_length=20, nullable): Teléfono
- `updated_at` (DateTimeField)

**Relaciones:**

- `company` (FK → Company): Empresa del usuario
- `area` (FK → Area): Área del usuario
- `group` (M2M → Groups): Grupos a los que pertenece

**Validaciones:**

```python
def clean():
    # La empresa del usuario debe pertenece a alguno de sus grupos
    if company and group.exists():
        validate company.group in user.group.all()
```

**Roles:**

- `USER`: Usuario normal que crea documentos
- `APPROVER`: Puede aprobar documentos según permisos
- `ADMIN`: Acceso completo

---

##### **4. Area**

**Propósito:** Organizar usuarios por áreas dentro de una empresa.

**Campos:**

- `id` (PK): Identificador único
- `name` (CharField, max_length=40): Nombre del área
- `code` (CharField, max_length=10, unique=True): Código único
- `description` (CharField, max_length=40): Descripción
- `company` (FK → Company): Empresa propietaria
- `created_at`, `updated_at` (DateTimeField)

**Ejemplo:** `IT`, `Recursos Humanos`, `Operaciones`, `Ventas`

---

##### **5. Access**

**Propósito:** Definir acceso de usuarios a centros de costo específicos.

**Campos:**

- `id` (PK): Identificador único
- `user` (FK → User): Usuario con acceso
- `cost_center` (FK → CostCenter): Centro de costo autorizado
- `comments` (TextField): Notas sobre el acceso
- `created_at`, `updated_at` (DateTimeField)

**Propósito:** Control de acceso granular a centros de costo

---

#### **Nivel 2: Permisos y Aprobaciones**

##### **6. UserApprover**

**Propósito:** Define qué usuarios puede aprobar un aprobador.

**Campos:**

- `id` (PK): Identificador único
- `user` (FK → User): El aprobador
- `can_approve_for` (M2M → User): Usuarios que puede aprobar

**Flujo:** Usuario A aprueba documentos de Usuarios B, C, D

---

##### **7. CostCenterApprover**

**Propósito:** Define qué centros de costo puede aprobar un usuario.

**Campos:**

- `id` (PK): Identificador único
- `user` (FK → User): El aprobador
- `cost_center` (M2M → CostCenter): Centros de costo que puede aprobar

**Flujo:** Usuario A aprueba documentos de los centros de costo X, Y, Z

---

##### **8. CompanyApprover**

**Propósito:** Define qué empresas puede aprobar un usuario.

**Campos:**

- `id` (PK): Identificador único
- `user` (FK → User): El aprobador
- `company` (M2M → Company): Empresas que puede aprobar

**Flujo:** Usuario A aprueba documentos de las empresas Empresa1, Empresa2

---

##### **9. ApprovalHistory**

**Propósito:** Auditoría completa de aprobaciones (4 niveles).

**Campos:**

- `id` (PK): Identificador único
- `level` (IntegerField, choices=[1, 2, 3, 4]): Nivel de aprobación
- `operation_date` (DateTimeField, auto_now_add): Fecha de operación
- `is_approved` (BooleanField): True si aprobó, False si rechazó
- `comments` (TextField, nullable): Comentarios del aprobador
- `approver` (FK → User): Usuario que aprobó
- `document` (FK → Document): Documento asociado
- `content_type` (FK → ContentType): Tipo genérico de objeto
- `object_id` (PositiveIntegerField): ID del objeto aprobado
- `content_object` (Generic FK): Referencia al objeto (Expense, Travel, PerDiem)

**Constraints:**

```python
UniqueConstraint(
    fields=['content_type', 'object_id', 'level'],
    name='uniq_approval_per_level_per_object'
)
# Asegura que no puede haber 2 aprobaciones del mismo nivel para el mismo objeto
```

**Propósito:** Permite polimorfismo - el mismo modelo maneja aprobaciones de DocumentExpense, DocumentTravel, DocumentPerDiem

---

#### **Nivel 3: Operaciones - Documentos y Gastos**

##### **10. Document**

**Propósito:** Documento padre que agrupa gastos, viajes y viáticos.

**Campos:**

- `id` (PK): Identificador único
- `title` (CharField, max_length=40): Título del documento
- `description` (TextField): Descripción detallada
- `document_date` (DateTimeField): Fecha del documento
- `state` (CharField, choices=['SAVED', 'PENDING', 'APPROVED', 'REJECTED']): Estado
- `recorded_subtotal` (DecimalField, 100,10): Subtotal en moneda original
- `recorded_total` (DecimalField, 100,10): Total con impuestos en moneda original
- `converted_subtotal` (DecimalField, 100,10): Subtotal convertido a base_currency
- `converted_total` (DecimalField, 100,10): Total convertido a base_currency
- `external_code` (TextField, nullable): Código de referencia en SAP
- `paid` (BooleanField): Indica si fue pagado
- `file` (FileField, nullable): PDF del documento (AWS S3)
- `erased_at` (DateTimeField, nullable): Timestamp de borrado lógico
- `enterprise` (FK → Company): Empresa del documento
- `user` (FK → User): Usuario creador
- `cost_center` (FK → CostCenter): Centro de costo
- `created_at`, `updated_at` (DateTimeField)

**Métodos:**

```python
def erase():
    # Soft delete - marca erased_at sin eliminar de DB
    erased_at = now()
    save()
```

**Estados:**

- `SAVED`: Borrador, en edición
- `PENDING`: Enviado para aprobación
- `APPROVED`: Aprobado en todos los niveles
- `REJECTED`: Rechazado

---

##### **11. DocumentExpense**

**Propósito:** Gasto individual dentro de un documento.

**Campos:**

- `id` (PK): Identificador único
- `title` (CharField, max_length=40): Descripción del gasto
- `description` (TextField): Detalle adicional
- `document_number` (CharField, max_length=40): Número de factura/recibo
- `expense_date` (DateTimeField): Fecha del gasto
- `expense_type` (CharField, choices=['RECIBO', 'FACTURA_EXCENTA', 'FACTURA_ELECTRONICA', 'BOLETA_ELECTRONICA', 'BOLETA']): Tipo de comprobante
- `recorded_subtotal` (DecimalField, 100,10): Subtotal sin impuesto
- `converted_subtotal` (DecimalField, 100,10): Subtotal convertido
- `recorded_total` (DecimalField, 100,10): Total con impuesto
- `converted_total` (DecimalField, 100,10): Total convertido
- `external_code` (CharField, max_length=40, nullable): Código SAP
- `document` (FK → Document): Documento padre
- `supplier` (FK → Supplier, nullable): Proveedor
- `expense_concept` (FK → ExpenseConcept): Concepto del gasto
- `currency` (FK → Currency): Moneda original
- `tax` (FK → Tax): Impuesto aplicado
- `erased_at` (DateTimeField, nullable): Soft delete
- `created_at`, `updated_at` (DateTimeField)

**Métodos Especiales:**

```python
def save(self, *args, **kwargs):
    # Al crear: actualiza totales del documento
    if not self.pk:
        super().save()
        self.update_document_total()
    # Al actualizar: solo si no está marcado como eliminado
    elif not self.erased_at:
        self.update_document_total()
        super().save()

def erase(self):
    # Soft delete
    erased_at = now()
    save()

def update_document_total(self):
    # Agrega montos al documento padre
    document.converted_subtotal += converted_subtotal
    document.converted_total += converted_total
    document.save()
```

**Regla de Negocio:** Al crear/actualizar, recalcula totales del documento padre

---

##### **12. ExpenseFile**

**Propósito:** Adjuntos (imágenes, PDFs) para un gasto.

**Campos:**

- `id` (PK): Identificador único
- `file` (FileField, upload_to='expense_files/'): Archivo en AWS S3
- `document_expense` (FK → DocumentExpense): Gasto asociado
- `uploaded_at` (DateTimeField, auto_now_add)

**Propósito:** Evidencia de gastos (fotos de recibos, PDFs)

---

##### **13. DocumentTravel**

**Propósito:** Gasto por viaje dentro de un documento.

**Campos:**

- `id` (PK): Identificador único
- `date` (DateTimeField): Fecha del viaje
- `number_people` (IntegerField): Cantidad de personas
- `reason` (TextField): Motivo del viaje
- `total` (DecimalField, 100,10): Costo total del viaje
- `external_code` (CharField, max_length=40, nullable): Código SAP
- `comments` (TextField): Comentarios
- `route` (FK → Route): Ruta del viaje
- `document` (FK → Document): Documento padre
- `erased_at` (DateTimeField, nullable): Soft delete
- `created_at`, `updated_at` (DateTimeField)

**Métodos:**

```python
def save(self):
    # Similar a DocumentExpense - actualiza documento padre
    if not self.pk:
        super().save()
        self.update_document_total()
    elif not self.erased_at:
        self.update_document_total()
        super().save()
```

---

##### **14. DocumentPerDiem**

**Propósito:** Gasto por viático (gastos diarios) dentro de un documento.

**Campos:**

- `id` (PK): Identificador único
- `initial_date` (DateTimeField): Fecha inicial del viático
- `final_date` (DateTimeField): Fecha final del viático
- `total` (DecimalField, 100,10): Monto total del viático
- `external_code` (CharField, max_length=40, nullable): Código SAP
- `reason` (TextField): Motivo del viático
- `per_diem` (FK → PerDiem): Configuración de viático
- `document` (FK → Document): Documento padre
- `erased_at` (DateTimeField, nullable): Soft delete
- `created_at`, `updated_at` (DateTimeField)

**Métodos:**

```python
def save(self):
    # Similar a DocumentExpense - actualiza documento padre
    if not self.pk:
        super().save()
        self.update_document_total()
    elif not self.erased_at:
        self.update_document_total()
        super().save()
```

---

#### **Nivel 4: Configuración y Maestros**

##### **15. Supplier**

**Propósito:** Proveedores/acreedores del sistema.

**Campos:**

- `id` (PK): Identificador único
- `name` (CharField, max_length=40): Nombre del proveedor
- `rut` (CharField, max_length=10, unique=True): RUT del proveedor
- `address` (CharField, max_length=40): Dirección
- `email` (CharField, max_length=20): Email
- `phone` (CharField, max_length=20): Teléfono
- `company` (FK → Company): Empresa propietaria
- `created_at`, `updated_at` (DateTimeField)

---

##### **16. CostCenter**

**Propósito:** Centros de costo para clasificar gastos.

**Campos:**

- `id` (PK): Identificador único
- `name` (CharField, max_length=40, unique=True): Nombre único
- `code` (CharField, max_length=10, unique=True): Código único
- `description` (CharField, max_length=40): Descripción
- `company` (FK → Company): Empresa propietaria
- `created_at`, `updated_at` (DateTimeField)

**Ejemplo:** `CECO-001`, `CECO-002`, `ADMIN`, `VENTAS`

---

##### **17. Tax**

**Propósito:** Impuestos aplicables a gastos.

**Campos:**

- `id` (PK): Identificador único
- `name` (CharField, max_length=40): Nombre (ej: "IVA")
- `description` (TextField): Descripción
- `percentage` (DecimalField, 5,2): Porcentaje del impuesto
- `company` (FK → Company): Empresa propietaria
- `created_at`, `updated_at` (DateTimeField)

**Ejemplo:** IVA 19%, IVA Reducido 4%, Sin impuesto 0%

---

##### **18. ExpenseConcept**

**Propósito:** Clasificación de conceptos de gasto, también identificado como categoría.

**Campos:**

- `id` (PK): Identificador único
- `name` (CharField, max_length=40): Nombre del concepto
- `description` (TextField): Descripción
- `company` (FK → Company): Empresa propietaria
- `created_at`, `updated_at` (DateTimeField)

**Ejemplo:** `Alimentación`, `Transporte`, `Hospedaje`, `Servicios Profesionales`

---

##### **19. PerDiem**

**Propósito:** Configuración de montos de viáticos por día.

**Campos:**

- `id` (PK): Identificador único
- `name` (CharField, max_length=40): Nombre del tipo de viático
- `description` (TextField): Descripción
- `amount` (DecimalField, 100,10): Monto diario
- `company` (FK → Company): Empresa propietaria
- `created_at`, `updated_at` (DateTimeField)

**Ejemplo:**

- Viático Nacional: $50.000/día
- Viático Internacional: $100.000/día

---

##### **20. Route**

**Propósito:** Rutas de viaje preconfiguradas.

**Campos:**

- `id` (PK): Identificador único
- `name` (CharField, max_length=40): Nombre de la ruta
- `description` (TextField): Descripción
- `distance_km` (DecimalField, 100,10): Distancia en km
- `toll_cost` (DecimalField, 100,10): Costo de peajes
- `origin` (FK → Location, nullable): Ubicación origen
- `destination` (FK → Location, nullable): Ubicación destino
- `company` (FK → Company): Empresa propietaria
- `created_at`, `updated_at` (DateTimeField)

**Validaciones:**

```python
def clean():
    # Origin y destination deben ser diferentes
    validate origin != destination

def save():
    # Distance no puede ser negativa
    validate distance_km >= 0
```

---

##### **21. Location**

**Propósito:** Ubicaciones geográficas para rutas (a mejorar con integración a una API geográfica).

**Campos:**

- `id` (PK): Identificador único
- `name` (CharField, max_length=40): Nombre de la ubicación
- `description` (TextField): Descripción
- `created_at`, `updated_at` (DateTimeField)

**Ejemplo:** `Santiago`, `Valparaíso`, `Concepción`, `Oficina Centro`

---

##### **22. Currency**

**Propósito:** Monedas disponibles en el sistema.

**Campos:**

- `id` (PK): Identificador único
- `name` (CharField, max_length=50): Código o nombre (ej: "USD", "CLP", "EUR")
- `comments` (TextField, nullable): Notas
- `created_at`, `updated_at` (DateTimeField)

**Meta:**

```python
verbose_name = 'Currency'
verbose_name_plural = 'Currencies'
db_table = 'currency'
```

---

#### **Nivel 5: Integración con Sistemas Externos**

##### **23. DocumentClass**

**Propósito:** Mapeo de tipos de documento para integración SAP.

**Campos:**

- `id` (PK): Identificador único
- `name` (CharField, max_length=50): Nombre descriptivo
- `code` (CharField, max_length=50): Código en SAP
- `document_type` (CharField, choices=['EXPENSE', 'TRAVEL', 'PER_DIEM']): Tipo de documento
- `expense_type` (CharField, choices=[...], nullable): Para EXPENSE, tipo de comprobante
- `expense_concept` (FK → ExpenseConcept, nullable): Para EXPENSE, concepto
- `company` (FK → Company): Empresa propietaria
- `comments` (TextField): Notas
- `created_at`, `updated_at` (DateTimeField)

**Validaciones:**

```python
def clean():
    if document_type == 'EXPENSE':
        # Debe tener expense_type y expense_concept
        validate expense_type is not None
        validate expense_concept is not None
    elif document_type == 'TRAVEL':
        # No debe tener expense_type ni expense_concept
        validate expense_type is None
        validate expense_concept is None
    elif document_type == 'PER_DIEM':
        # No debe tener expense_type ni expense_concept
        validate expense_type is None
        validate expense_concept is None
```

---

##### **24. AccountingAccount**

**Propósito:** Mapeo de cuentas contables para integración SAP.

**Campos:**

- `id` (PK): Identificador único
- `name` (CharField, max_length=50): Nombre de la cuenta
- `code` (CharField, max_length=50): Código contable
- `account` (CharField, max_length=50): Número de cuenta en SAP
- `document_type` (CharField, choices=['EXPENSE', 'TRAVEL', 'PER_DIEM']): Tipo de documento
- `expense_concept` (FK → ExpenseConcept, nullable): Para EXPENSE
- `company` (FK → Company): Empresa propietaria
- `comments` (TextField): Notas
- `created_at`, `updated_at` (DateTimeField)

**Validaciones:**

```python
def clean():
    if document_type == 'EXPENSE':
        validate expense_concept is not None
    elif document_type in ['TRAVEL', 'PER_DIEM']:
        validate expense_concept is None
```

---

### 4.3 Campos Importantes y Relaciones

#### **Campos Críticos con on_delete=models.PROTECT**

Previenen eliminación de registros relacionados:

```
Company
├── Groups (PROTECT)        # No puede eliminar grupo si tiene empresas
├── Currency (PROTECT)      # No puede eliminar moneda base si está en uso
└── User.company (PROTECT)  # No puede eliminar empresa si tiene usuarios

User
├── Company (PROTECT)       # No puede eliminar si tiene usuarios
└── Area (PROTECT)          # No puede eliminar área si tiene usuarios

Document
├── Enterprise/Company (PROTECT) # No puede eliminar empresa
├── User (PROTECT)               # No puede eliminar usuario
└── CostCenter (PROTECT)         # No puede eliminar centro costo

DocumentExpense
├── Document (PROTECT)      # No puede eliminar documento si tiene gastos
├── Supplier (PROTECT)      # No puede eliminar proveedor
├── ExpenseConcept (PROTECT)# No puede eliminar concepto
├── Currency (PROTECT)      # No puede eliminar moneda
└── Tax (PROTECT)           # No puede eliminar impuesto
```

---

#### **Campos con on_delete=models.CASCADE**

Eliminan registros dependientes:

```
ExpenseFile
└── DocumentExpense (CASCADE) # Elimina archivos si se elimina gasto
```

---

#### **Soft Delete (Borrado Lógico)**

Modelos con campo `erased_at`:

```
Document
├── erase()  # Marca erased_at = now()
└── Consultas deben filtrar donde erased_at IS NULL

DocumentExpense
├── erase()  # Marca erased_at = now()
└── update_document_total() se salta si erased_at not null

DocumentTravel
├── erase()
└── Similar a DocumentExpense

DocumentPerDiem
├── erase()
└── Similar a DocumentExpense
```

---

### 4.4 Reglas de Negocio Dentro de Modelos

#### **Autoincremento de Totales**

```python
# DocumentExpense.save()
if not self.pk:  # Creación
    super().save()
    self.update_document_total()
    # Agrega montos al documento padre

# DocumentTravel.save()
if not self.pk:  # Creación
    super().save()
    self.update_document_total()
    # Agrega montos al documento padre

# DocumentPerDiem.save()
if not self.pk:  # Creación
    super().save()
    self.update_document_total()
    # Agrega montos al documento padre
```

**Efecto:** Document.converted_total se actualiza automáticamente

---

#### **Validación de Rutas**

```python
# Route.clean()
if origin == destination:
    raise ValidationError('Origin and destination must be different')

# Route.save()
if distance_km < 0:
    raise ValidationError('Distance cannot be negative')
```

---

#### **Validación de Usuario y Compañía**

```python
# User.clean()
if self.company and self.group.exists():
    if self.company.group not in self.group.all():
        raise ValidationError(
            'La compañía seleccionada no pertenece a los grupos del usuario'
        )
```

**Propósito:** Asegurar que la empresa del usuario pertenece a uno de sus grupos

---

#### **Unicidad Compuesta en ApprovalHistory**

```python
# Meta constraint
UniqueConstraint(
    fields=['content_type', 'object_id', 'level'],
    name='uniq_approval_per_level_per_object'
)
```

**Propósito:** Evitar aprobaciones duplicadas del mismo nivel para el mismo objeto

---

### 4.5 Migraciones (Estructura y Comandos)

#### **Archivos de Migraciones**

```
app/migrations/
├── __init__.py
├── 0001_initial.py           # Creación inicial de modelos
├── 0002_groups_rename_...py  # Rename y ajustes
├── 0003_currency.py          # Agregar Currency
├── 0004_insert_currencys.py  # Data insertion
├── 0005_company_currencies_allowed.py
├── 0006_company_base_currency.py
├── 0007_documentexpense_currency.py
├── 0008_alter_company_address_...py
├── 0009_document_file.py
├── 0010_location_route_...py
├── 0011_document_paid_...py
├── 0012_approvalhistory_content_type_and_more.py
└── __pycache__/
```

---

#### **Comandos Django para Migraciones**

```bash
# Crear migración automática
python manage.py makemigrations

# Aplicar migraciones
python manage.py migrate

# Ver estado de migraciones
python manage.py showmigrations

# Deshacer última migración
python manage.py migrate app 0011

# Ver SQL de una migración
python manage.py sqlmigrate app 0012

# Ver cambios sin aplicar
python manage.py makemigrations --dry-run --verbosity 3
```

---

#### **Proceso de Migración en Producción**

```bash
# 1. Crear cambios en models.py
# 2. Crear migración
python manage.py makemigrations

# 3. Validar migración
python manage.py sqlmigrate app <numero>

# 4. Revisar cambios en git antes de deploy

# 5. En producción
python manage.py migrate --no-input

# 6. Verificar
python manage.py showmigrations
```

---

## Resumen de Base de Datos

| Aspecto                | Detalles                                                                                  |
| ---------------------- | ----------------------------------------------------------------------------------------- |
| **Total de Modelos**   | 24 modelos                                                                                |
| **Nivel 1 (Org)**      | 5 modelos (Groups, Company, User, Area, Access)                                           |
| **Nivel 2 (Permisos)** | 4 modelos (UserApprover, CostCenterApprover, CompanyApprover, ApprovalHistory)            |
| **Nivel 3 (Ops)**      | 5 modelos (Document, DocumentExpense, DocumentTravel, DocumentPerDiem, ExpenseFile)       |
| **Nivel 4 (Config)**   | 6 modelos (Supplier, CostCenter, Tax, ExpenseConcept, PerDiem, Route, Location, Currency) |
| **Nivel 5 (ERP)**      | 2 modelos (DocumentClass, AccountingAccount)                                              |
| **Borrado Lógico**     | Document, DocumentExpense, DocumentTravel, DocumentPerDiem                                |
| **Soft Protect**       | 25+ relaciones con on_delete=PROTECT                                                      |
| **Generic Relations**  | ApprovalHistory → DocumentExpense/Travel/PerDiem                                          |
| **Many-to-Many**       | 8 relaciones M2M (Groups, Permisos, Currencies)                                           |

---

## 5. API y Endpoints

### 5.1 Convenciones de Rutas (REST, Versión, Prefijos)

#### **Estructura General de URLs**

```
https://api.rinderline.com/api/v1/app/{feature}/{resource}/{action}
│                                │  │   │         │         │
│                                │  │   │         │         └─ Acciones custom (POST)
│                                │  │   │         └─ Recurso (plural)
│                                │  │   └─ Feature/dominio
│                                │  └─ Prefijo app
│                                └─ Versionado
```

#### **Patrones de URL**

```
GET    /api/v1/app/documents/                    # Listar documentos
POST   /api/v1/app/documents/                    # Crear documento

GET    /api/v1/app/documents/<id>/               # Detalle de documento
PUT    /api/v1/app/documents/<id>/               # Actualizar completo
PATCH  /api/v1/app/documents/<id>/               # Actualizar parcial
DELETE /api/v1/app/documents/<id>/               # Eliminar

GET    /api/v1/app/documents/?state=PENDING      # Filtrar por query param
GET    /api/v1/app/documents/?page=2&limit=15    # Paginación

POST   /api/v1/app/documents/<id>/items/         # Sub-recurso
GET    /api/v1/app/approvals/pending/            # Listado filtrado
POST   /api/v1/app/auth/login/                   # Acción custom
```

#### **Prefijos y Namespaces**

```
/api/v1/          # Versionado explícito para backward compatibility
/api/v1/app/      # Aplicación principal (no admin)
/api/v1/app/auth/        # AuthViewSet
/api/v1/app/documents/   # Web feature - Documentos
/api/v1/app/approvals/   # Web feature - Aprobaciones
/api/v1/app/dashboards/  # Web feature - Dashboards
/api/v1/app/info/        # Web feature - Información
/api/v1/app/reports/     # Web feature - Reportes
/api/v1/app/sap/         # Web feature - SAP
/api/v1/app/admin/       # Admin feature - Administración
```

---

### 5.2 Autenticación y Autorización

#### **Token Authentication**

```
Flujo:
1. Cliente hace POST /api/v1/app/auth/login/
   Body: {"username": "juan", "password": "pass123"}

2. Backend valida credenciales y genera Token
   Response: {"token": "abc123def456xyz789"}

3. Cliente almacena token en localStorage

4. Cliente incluye en headers de siguientes requests:
   Authorization: Token abc123def456xyz789
   (o alternativo: Authorization: Bearer abc123def456xyz789)

5. Backend valida token y asigna user a request.user
```

#### **Clases de Autenticación**

```python
authentication_classes = [
    TokenAuthentication,      # Authorization: Token <key>
    BasicAuthentication       # Authorization: Basic <base64(user:pass)>
]
```

#### **Clases de Permisos**

```python
permission_classes = [
    permissions.IsAuthenticated,  # Usuario debe estar autenticado
    permissions.IsAdminUser,      # Usuario debe ser staff/admin
    custom.IsApprover,            # Usuario tiene rol APPROVER
    custom.IsEmployeeApprover,    # Usuario puede aprobar por usuarios
    custom.IsCostCenterApprover,  # Usuario puede aprobar por ceco
    custom.IsCompanyApprover      # Usuario puede aprobar por empresa
]
```

#### **Validación de Permisos en Tiempo de Ejecución**

```python
# En views.py
def get(self, request):
    # Validar permisos granulares
    if not request.user.is_authenticated:
        raise PermissionDenied("User not authenticated")

    if request.user.role not in ['APPROVER', 'ADMIN']:
        raise PermissionDenied("User is not an approver")

    # Validar acceso a documento específico
    document = Document.objects.get(id=pk)
    if document.user != request.user and not is_approver_for(request.user, document):
        raise PermissionDenied("No access to this document")
```

---

### 5.3 Endpoints Principales (GET/POST/PUT/PATCH/DELETE)

#### **AUTENTICACIÓN - /api/v1/app/auth/**

| Método   | Endpoint          | Descripción             | Autenticación   |
| -------- | ----------------- | ----------------------- | --------------- |
| **POST** | `/auth/register/` | Registrar nuevo usuario | Ninguna         |
| **POST** | `/auth/login/`    | Login y obtener token   | Ninguna         |
| **POST** | `/auth/logout/`   | Logout (elimina token)  | Token requerido |

**Ejemplo POST /auth/login/**

```http
POST /api/v1/app/auth/login/ HTTP/1.1
Content-Type: application/json

{
  "username": "juan.perez",
  "password": "Segura123!"
}
```

**Response 200 OK**

```json
{
  "status": "success",
  "data": {
    "token": "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6"
  }
}
```

---

#### **DOCUMENTOS - /api/v1/app/documents/**

| Método     | Endpoint                    | Descripción                   | Headers |
| ---------- | --------------------------- | ----------------------------- | ------- |
| **GET**    | `/documents/`               | Listar documentos del usuario | Token   |
| **GET**    | `/documents/?state=PENDING` | Filtrar por estado            | Token   |
| **GET**    | `/documents/drafts/`        | Listar solo SAVED             | Token   |
| **POST**   | `/documents/`               | Crear documento               | Token   |
| **GET**    | `/documents/<id>/`          | Detalle de documento          | Token   |
| **GET**    | `/documents/<id>/items/`    | Items del documento           | Token   |
| **PUT**    | `/documents/<id>/`          | Actualizar documento          | Token   |
| **DELETE** | `/documents/<id>/delete/`   | Soft delete de documento      | Token   |

**Ejemplo GET /documents/**

```http
GET /api/v1/app/documents/?state=PENDING&page=1 HTTP/1.1
Authorization: Token a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
```

**Response 200 OK**

```json
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "title": "Viaje a Santiago",
      "description": "Viaje de negocios Q4",
      "state": "PENDING",
      "enterprise": "Empresa ABC",
      "user": "juan.perez",
      "cost_center": "CECO-001",
      "recorded_total": 1500000.0,
      "converted_total": 1500000.0,
      "paid": false,
      "created_at": "2025-11-30T10:30:00Z"
    }
  ],
  "pagination": {
    "count": 5,
    "next": "?page=2",
    "previous": null,
    "page_size": 15
  }
}
```

**Ejemplo POST /documents/**

```http
POST /api/v1/app/documents/ HTTP/1.1
Authorization: Token a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
Content-Type: multipart/form-data

document[title]=Gasto Hotel&
document[description]=Hotel Sheraton&
expenses[0][title]=Hospedaje 1 noche&
expenses[0][amount]=250000&
expenses[0][tax_id]=1&
expenses[0][currency_id]=1&
expenses[0][expense_concept_id]=3
```

---

#### **APROBACIONES - /api/v1/app/approvals/**

| Método    | Endpoint                     | Descripción               | Requiere   |
| --------- | ---------------------------- | ------------------------- | ---------- |
| **GET**   | `/approvals/pending/`        | Documentos pendientes     | IsApprover |
| **GET**   | `/approvals/history/`        | Historial de aprobaciones | IsApprover |
| **GET**   | `/approvals/documents/<id>/` | Detalle para aprobar      | IsApprover |
| **PATCH** | `/approvals/expenses/<id>/`  | Aprobar/Rechazar gasto    | IsApprover |
| **PATCH** | `/approvals/travels/<id>/`   | Aprobar/Rechazar viaje    | IsApprover |
| **PATCH** | `/approvals/per-diems/<id>/` | Aprobar/Rechazar viático  | IsApprover |

**Ejemplo GET /approvals/pending/**

```http
GET /api/v1/app/approvals/pending/ HTTP/1.1
Authorization: Token a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
```

**Response 200 OK**

```json
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "title": "Viaje a Santiago",
      "user": "juan.perez",
      "cost_center": "CECO-001",
      "state": "PENDING",
      "items": [
        {
          "type": "expense",
          "id": 1,
          "title": "Hotel",
          "amount": 250000,
          "pending_approval": true
        },
        {
          "type": "travel",
          "id": 2,
          "title": "Pasaje aéreo",
          "amount": 450000,
          "pending_approval": true
        }
      ]
    }
  ]
}
```

**Ejemplo PATCH /approvals/expenses/<id>/**

```http
PATCH /api/v1/app/approvals/expenses/1/ HTTP/1.1
Authorization: Token a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
Content-Type: application/json

{
  "is_approved": true,
  "comments": "Aprobado. Monto acorde a política.",
  "level": 1
}
```

**Response 200 OK**

```json
{
  "status": "success",
  "data": {
    "message": "Expense approved at level 1"
  }
}
```

---

#### **DASHBOARDS - /api/v1/app/dashboards/**

| Método  | Endpoint                             | Descripción                     | Requiere             |
| ------- | ------------------------------------ | ------------------------------- | -------------------- |
| **GET** | `/dashboards/employee/`              | Dashboard empleado              | IsAuthenticated      |
| **GET** | `/dashboards/approvers/user/`        | Dashboard aprobador por usuario | IsEmployeeApprover   |
| **GET** | `/dashboards/approvers/cost-center/` | Dashboard aprobador por ceco    | IsCostCenterApprover |
| **GET** | `/dashboards/approvers/company/`     | Dashboard aprobador por empresa | IsCompanyApprover    |

**Ejemplo GET /dashboards/employee/**

```http
GET /api/v1/app/dashboards/employee/ HTTP/1.1
Authorization: Token a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
```

**Response 200 OK**

```json
{
  "status": "success",
  "data": {
    "barChartData": {
      "months": ["Ene", "Feb", "Mar"],
      "values": [150000, 250000, 180000]
    },
    "pieChartData": {
      "labels": ["Gastos", "Viajes", "Viáticos"],
      "values": [60, 30, 10]
    },
    "stats": {
      "total_expenses": 1500000.0,
      "pending_approval": 2,
      "approved": 5,
      "rejected": 1
    }
  }
}
```

---

#### **INFORMACIÓN - /api/v1/app/info/**

| Método   | Endpoint             | Descripción                      | Autenticación |
| -------- | -------------------- | -------------------------------- | ------------- |
| **GET**  | `/test/`             | Test del API                     | Ninguna       |
| **GET**  | `/users/me/`         | Perfil del usuario actual        | Token         |
| **PUT**  | `/users/me/profile/` | Actualizar perfil                | Token         |
| **POST** | `/suppliers/`        | Crear proveedor                  | Token         |
| **GET**  | `/information/`      | Información accesible al usuario | Token         |

**Ejemplo GET /users/me/**

```http
GET /api/v1/app/users/me/ HTTP/1.1
Authorization: Token a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
```

**Response 200 OK**

```json
{
  "status": "success",
  "data": {
    "id": 1,
    "username": "juan.perez",
    "email": "juan@company.com",
    "first_name": "Juan",
    "last_name": "Pérez",
    "phone": "+56912345678",
    "rut": "12.345.678-9",
    "company": "Empresa ABC",
    "role": "USER",
    "is_active": true,
    "is_user_approver": false,
    "is_cost_center_approver": false,
    "is_company_approver": false
  }
}
```

---

#### **REPORTES - /api/v1/app/reports/**

| Método   | Endpoint                  | Descripción           | Autenticación |
| -------- | ------------------------- | --------------------- | ------------- |
| **POST** | `/reports/upload/`        | Subir archivo PDF     | Token         |
| **POST** | `/documents/<id>/delete/` | Marcar como eliminado | Token         |

**Ejemplo POST /reports/upload/**

```http
POST /api/v1/app/reports/upload/ HTTP/1.1
Authorization: Token a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
Content-Type: multipart/form-data

document_id=1&
file=<archivo.pdf>
```

---

#### **SAP - /api/v1/app/sap/**

| Método   | Endpoint               | Descripción                      | Autenticación |
| -------- | ---------------------- | -------------------------------- | ------------- |
| **GET**  | `/sap/documents/`      | Listar documentos enviados a SAP | Token         |
| **POST** | `/sap/documents/send/` | Enviar documento a SAP           | Token         |

**Ejemplo GET /sap/documents/**

```http
GET /api/v1/app/sap/documents/ HTTP/1.1
Authorization: Token a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
```

---

### 5.4 Respuestas Estándar (Success, Error)

#### **Formato JSend**

La API utiliza estándar **JSend** para respuestas consistentes.

##### **Respuesta Exitosa**

```json
{
  "status": "success",
  "data": {
    "id": 1,
    "name": "Documento",
    "created_at": "2025-11-30T10:30:00Z"
  }
}
```

**Casos:**

- `GET /documents/` → 200 OK
- `POST /documents/` → 201 Created
- `PATCH /documents/<id>/` → 200 OK
- `DELETE /documents/<id>/` → 204 No Content

##### **Respuesta de Error de Validación**

```json
{
  "status": "fail",
  "message": "Validation error",
  "errors": {
    "title": ["Este campo es requerido."],
    "amount": ["Este valor debe ser un decimal válido."],
    "expense_concept": ["Este objeto no existe."]
  }
}
```

**HTTP Status:** 400 Bad Request

##### **Respuesta de Error de Autorización**

```json
{
  "status": "fail",
  "message": "Permission denied",
  "errors": {
    "detail": "You do not have permission to perform this action."
  }
}
```

**HTTP Status:** 403 Forbidden

##### **Respuesta de Error de Autenticación**

```json
{
  "status": "fail",
  "message": "Authentication failed",
  "errors": {
    "detail": "Invalid token."
  }
}
```

**HTTP Status:** 401 Unauthorized

##### **Respuesta de Recurso No Encontrado**

```json
{
  "status": "fail",
  "message": "Not found",
  "errors": {
    "detail": "Document not found."
  }
}
```

**HTTP Status:** 404 Not Found

##### **Respuesta de Error de Servidor**

```json
{
  "status": "error",
  "message": "An error occurred"
}
```

**HTTP Status:** 500 Internal Server Error

**Nota:** Stack trace se envía a Sentry (no al cliente)

---

### 5.5 Manejo de Errores y Validaciones

#### **Niveles de Validación**

```
1. Serializer Level (DRF)
   ├─ Campo requerido
   ├─ Tipo de dato
   ├─ Rango/length
   └─ Validadores custom

2. Model Level (Django)
   ├─ clean() method
   ├─ Constraints
   └─ Foreign Key existence

3. Business Logic Level (Services)
   ├─ Reglas de negocio
   ├─ Permisos
   └─ Estados válidos

4. Database Level
   ├─ Integrity constraints
   ├─ Unique constraints
   └─ Foreign key constraints
```

#### **Ejemplo: Validación de Gasto**

```python
# serializers.py
class DocumentExpenseSerializer(serializers.ModelSerializer):
    class Meta:
        model = DocumentExpense
        fields = ['title', 'description', 'amount', 'tax', 'currency']

    def validate_title(self, value):
        if not value or len(value.strip()) == 0:
            raise serializers.ValidationError("Título no puede estar vacío")
        return value

    def validate_amount(self, value):
        if value <= 0:
            raise serializers.ValidationError("Monto debe ser mayor a 0")
        if value > 10000000:
            raise serializers.ValidationError("Monto excede límite de $10M")
        return value

    def validate(self, data):
        # Validación entre campos
        if data['tax'].company != data['currency'].company:
            raise serializers.ValidationError({
                'tax': "Impuesto no válido para esta moneda"
            })
        return data

# models.py
class DocumentExpense(models.Model):
    # ... campos ...

    def clean(self):
        # Validación a nivel de modelo
        if self.recorded_subtotal < 0:
            raise ValidationError("Subtotal no puede ser negativo")

    def save(self, *args, **kwargs):
        self.clean()
        super().save(*args, **kwargs)
```

#### **Códigos de Error HTTP Comunes**

| Código  | Significado           | Ejemplo                            |
| ------- | --------------------- | ---------------------------------- |
| **400** | Bad Request           | Validación fallida                 |
| **401** | Unauthorized          | Token inválido o ausente           |
| **403** | Forbidden             | Falta de permisos                  |
| **404** | Not Found             | Recurso no existe                  |
| **409** | Conflict              | Violación de constraints           |
| **422** | Unprocessable Entity  | Datos inválidos para procesamiento |
| **500** | Internal Server Error | Error no manejado                  |
| **503** | Service Unavailable   | Base de datos caída                |

---

### 5.6 Ejemplos de Request/Response por Endpoint

#### **1. Crear Documento Completo**

**Request:**

```http
POST /api/v1/app/documents/ HTTP/1.1
Authorization: Token abc123...
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary

------WebKitFormBoundary
Content-Disposition: form-data; name="document[title]"

Viaje a Valparaíso
------WebKitFormBoundary
Content-Disposition: form-data; name="document[description]"

Viaje de trabajo a cliente principal
------WebKitFormBoundary
Content-Disposition: form-data; name="document[cost_center_id]"

1
------WebKitFormBoundary
Content-Disposition: form-data; name="document[document_date]"

2025-11-30T10:00:00Z
------WebKitFormBoundary
Content-Disposition: form-data; name="expenses[0][title]"

Pasaje aéreo
------WebKitFormBoundary
Content-Disposition: form-data; name="expenses[0][amount]"

500000
------WebKitFormBoundary
Content-Disposition: form-data; name="expenses[0][tax_id]"

1
------WebKitFormBoundary
Content-Disposition: form-data; name="expenses[0][currency_id]"

1
------WebKitFormBoundary
Content-Disposition: form-data; name="expenses[0][expense_concept_id]"

2
------WebKitFormBoundary
Content-Disposition: form-data; name="expenses[0][supplier_id]"

5
------WebKitFormBoundary
Content-Disposition: form-data; name="travels[0][route_id]"

3
------WebKitFormBoundary
Content-Disposition: form-data; name="travels[0][total]"

150000
------WebKitFormBoundary--
```

**Response:**

```json
{
  "status": "success",
  "data": {
    "id": 42,
    "title": "Viaje a Valparaíso",
    "description": "Viaje de trabajo a cliente principal",
    "state": "SAVED",
    "recorded_total": 650000.0,
    "converted_total": 650000.0,
    "items": [
      {
        "type": "expense",
        "id": 100,
        "title": "Pasaje aéreo",
        "amount": 500000
      },
      {
        "type": "travel",
        "id": 50,
        "title": "Viaje",
        "amount": 150000
      }
    ]
  }
}
```

---

#### **2. Enviar Documento a Aprobación**

**Request:**

```http
PATCH /api/v1/app/documents/42/ HTTP/1.1
Authorization: Token abc123...
Content-Type: application/json

{
  "state": "PENDING"
}
```

**Response:**

```json
{
  "status": "success",
  "data": {
    "id": 42,
    "state": "PENDING",
    "message": "Document sent for approval"
  }
}
```

---

#### **3. Aprobar Gasto**

**Request:**

```http
PATCH /api/v1/app/approvals/expenses/100/ HTTP/1.1
Authorization: Token approver_token...
Content-Type: application/json

{
  "is_approved": true,
  "comments": "Aprobado. Monto dentro de política.",
  "level": 1
}
```

**Response:**

```json
{
  "status": "success",
  "data": {
    "id": 100,
    "title": "Pasaje aéreo",
    "is_approved": true,
    "approval_level": 1,
    "message": "Expense approved at level 1"
  }
}
```

---

#### **4. Rechazar Gasto**

**Request:**

```http
PATCH /api/v1/app/approvals/expenses/100/ HTTP/1.1
Authorization: Token approver_token...
Content-Type: application/json

{
  "is_approved": false,
  "comments": "Rechazado: No hay justificación suficiente para este monto.",
  "level": 1
}
```

**Response:**

```json
{
  "status": "fail",
  "message": "Expense rejected",
  "data": {
    "id": 100,
    "is_approved": false,
    "approval_level": 1,
    "comments": "Rechazado: No hay justificación..."
  }
}
```

---

#### **5. Listar Historial de Aprobaciones**

**Request:**

```http
GET /api/v1/app/approvals/history/?page=1 HTTP/1.1
Authorization: Token approver_token...
```

**Response:**

```json
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "level": 1,
      "operation_date": "2025-11-30T15:45:00Z",
      "is_approved": true,
      "comments": "Aprobado",
      "approver": "carlos.supervisor",
      "object_type": "DocumentExpense",
      "object_id": 100,
      "object_title": "Pasaje aéreo"
    },
    {
      "id": 2,
      "level": 2,
      "operation_date": "2025-11-30T16:30:00Z",
      "is_approved": true,
      "comments": "OK",
      "approver": "maria.gerente",
      "object_type": "DocumentExpense",
      "object_id": 100,
      "object_title": "Pasaje aéreo"
    }
  ],
  "pagination": {
    "count": 15,
    "next": "?page=2",
    "previous": null
  }
}
```

---

## Resumen de API

| Aspecto             | Detalles                                |
| ------------------- | --------------------------------------- |
| **Versión**         | v1 (versionado en URL)                  |
| **Formato**         | JSON + JSend                            |
| **Autenticación**   | Token (DRF)                             |
| **Autorización**    | Permisos granulares                     |
| **Paginación**      | 15 items por página                     |
| **Filtrado**        | Query parameters                        |
| **Total Endpoints** | 25+ endpoints                           |
| **Validación**      | 3 niveles (Serializer, Model, Business) |
| **Errores**         | Códigos HTTP estándar + JSend           |

---

## 6. Servicios / Casos de Uso

### 6.1 Lógica de Negocio Central

#### **Flujos Principales**

##### **A. Creación de Documento**

```
Usuario crea documento
    ↓
[SAVED] - Borrador editable
    ↓
Usuario agrega gastos, viajes, viáticos
    ↓ (por cada item)
Calcula totales automáticamente
    ↓
Usuario marca como PENDING
    ↓
[PENDING] - Enviar a aprobación
    ↓
Aprobadores revisan
    ↓
Niveles de aprobación (1, 2, 3)
    ↓
Si todo se aprueba en nivel actual → avanza nivel
    ↓
Si rechaza en cualquier nivel → vuelta a SAVED
    ↓
Nivel 3 completo → [APPROVED]
    ↓
[APPROVED] - Listo para pago
```

##### **B. Flujo de Aprobación (Multi-nivel)**

```
Level 1: Aprobador directo del usuario (UserApprover)
         ├─ Aprueba gastos del usuario
         └─ Solo ve sus users

Level 2: Aprobador por Centro de Costo (CostCenterApprover)
         ├─ Aprueba gastos del ceco
         └─ Solo ve sus cecos

Level 3: Aprobador por Empresa (CompanyApprover)
         ├─ Aprueba gastos de la empresa
         └─ Solo ve sus empresas
```

**Lógica de Avance:**

```
Cuando TODOS los items (expenses, travels, perdiems)
están aprobados en nivel N:
    → Sistema crea ApprovalHistory automática para nivel N
    → Si N < 3: estado permanece PENDING (espera nivel N+1)
    → Si N == 3: estado cambia a APPROVED
```

---

### 6.2 Servicios Reutilizables

#### **1. DashboardEmployeeService**

**Ubicación:** `app/services/dashboard_service.py`

**Propósito:** Generar datos de dashboard para empleados

**Métodos:**

```python
class DashboardEmployeeService:
    def __init__(self, user):
        # Inicializa con usuario actual

    def get_bar_chart_data(self):
        """Gráfico de barras por concepto de gasto (mes actual)"""
        # Retorna top 5 conceptos de gasto
        return [
            {"name": "Alimentación", "count": 12},
            {"name": "Transporte", "count": 8},
            ...
        ]

    def get_emissions_pie_chart_data(self):
        """Gráfico pie de tipos de gasto"""
        # Distribución: Gastos, Viajes, Viáticos
        return {
            "labels": ["Expenses", "Travels", "PerDiems"],
            "values": [60, 30, 10]
        }

    def get_expense_data(self):
        """Lista formateada de últimos 10 gastos del mes"""
        return [
            {
                "id": 1,
                "expense": "Hotel",
                "category": "Hospedaje",
                "amount": "250000.00 CLP",
                "status": "APPROVED",
                "date": "30/11/2025"
            },
            ...
        ]

    def get_payment_status_data(self):
        """Estado de pago de gastos aprobados"""
        return [
            {
                "id": 1,
                "amount": "250000.00 CLP",
                "situation": true,  # Pagado
                "date": "30/11/2025"
            },
            ...
        ]

    def get_stats_data(self):
        """Estadísticas comparadas mes anterior"""
        return {
            "travels": {
                "amount": 1500000.0,
                "percentage": 15.5,
                "trend": "up"
            },
            "perdiem": {
                "amount": 300000.0,
                "percentage": 8.2,
                "trend": "down"
            }
        }
```

**Uso:**

```python
# En view
dashboard = DashboardEmployeeService(request.user)
data = {
    "barChart": dashboard.get_bar_chart_data(),
    "pieChart": dashboard.get_emissions_pie_chart_data(),
    "expenses": dashboard.get_expense_data(),
    "payments": dashboard.get_payment_status_data(),
    "stats": dashboard.get_stats_data()
}
return Response(data)
```

---

#### **2. ApprovalService**

**Ubicación:** `app/services/appraisal_service.py`

**Propósito:** Orquestar lógica de aprobación multi-nivel

**Métodos Principales:**

```python
class ApprovalService:

    @staticmethod
    def process_expense_approval(expense, approver, level, is_approved, comments):
        """
        Procesa la aprobación de un gasto en un nivel específico

        1. Valida que el approver tiene permisos
        2. Crea registro en ApprovalHistory
        3. Si es aprobado: verifica si todos están aprobados en este nivel
        4. Si todo aprobado: avanza automáticamente
        5. Si es rechazado: marca documento como SAVED para re-edición
        """
        # Validación de permisos
        if not _check_approver_permission(approver, expense, level):
            raise PermissionDenied("No permission to approve")

        # Crear registro de aprobación
        approval = ApprovalHistory.objects.create(
            content_type=ContentType.objects.get_for_model(DocumentExpense),
            object_id=expense.id,
            approver=approver,
            level=level,
            is_approved=is_approved,
            comments=comments,
            document=expense.document
        )

        if is_approved:
            # Si todos están aprobados en este nivel
            # → avanza automáticamente al siguiente
            return _check_and_advance_document_level(expense.document, level)
        else:
            # Si rechaza: documento vuelve a SAVED
            expense.document.state = 'SAVED'
            expense.document.save()
            return f"Expense rejected. Document returned to SAVED."

    @staticmethod
    def process_travel_approval(travel, approver, level, is_approved, comments):
        """Similar a process_expense_approval pero para DocumentTravel"""
        # ... lógica similar

    @staticmethod
    def process_perdiem_approval(perdiem, approver, level, is_approved, comments):
        """Similar a process_expense_approval pero para DocumentPerDiem"""
        # ... lógica similar

    @staticmethod
    def get_approvable_documents(approver):
        """
        Retorna documentos que el approver puede aprobar
        basado en:
        - UserApprover: usuarios asignados
        - CostCenterApprover: centros de costo asignados
        - CompanyApprover: empresas asignadas

        Filtra solo PENDING con items sin aprobar
        """
        # Obtener docs de usuarios asignados
        user_docs = Document.objects.filter(
            user__in=UserApprover.objects.filter(
                user=approver
            ).values_list('can_approve_for')
        )

        # Obtener docs de cecos asignados
        ceco_docs = Document.objects.filter(
            cost_center__in=CostCenterApprover.objects.filter(
                user=approver
            ).values_list('cost_center')
        )

        # Obtener docs de empresas asignadas
        company_docs = Document.objects.filter(
            enterprise__in=CompanyApprover.objects.filter(
                user=approver
            ).values_list('company')
        )

        # Unir y filtrar PENDING
        return (user_docs | ceco_docs | company_docs).filter(
            state='PENDING',
            erased_at__isnull=True
        ).distinct()

    @staticmethod
    def enrich_document_with_items(document):
        """
        Enriquece documento con sus items (expenses, travels, perdiems)
        y estado de aprobación
        """
        return {
            "id": document.id,
            "title": document.title,
            "items": [
                *_get_document_expenses_with_status(document),
                *_get_document_travels_with_status(document),
                *_get_document_perdiems_with_status(document)
            ]
        }
```

**Validación de Permisos Internos:**

```python
def _check_approver_permission(approver, item, level):
    """
    Verifica si approver puede aprobar un item en un nivel

    Level 1: UserApprover
    Level 2: CostCenterApprover
    Level 3: CompanyApprover
    """
    document = item.document

    if level == 1:
        # ¿Approver está en UserApprover para este usuario?
        return UserApprover.objects.filter(
            user=approver,
            can_approve_for=document.user
        ).exists()

    elif level == 2:
        # ¿Approver está en CostCenterApprover para este ceco?
        return CostCenterApprover.objects.filter(
            user=approver,
            cost_center=document.cost_center
        ).exists()

    elif level == 3:
        # ¿Approver está en CompanyApprover para esta empresa?
        return CompanyApprover.objects.filter(
            user=approver,
            company=document.enterprise
        ).exists()

    return False
```

---

#### **3. ApproverDashboardService**

**Ubicación:** `app/services/approver_dashboard_service.py`

**Propósito:** Dashboards específicos para cada tipo de aprobador

**Clases:**

```python
class UserApproverDashboardService:
    """Para aprobadores por usuario"""
    def get_stats_cards_data(self):
        # Aprobaciones este mes vs mes anterior

    def get_employees_data(self):
        # Lista de empleados que puede aprobar

    def get_pending_approvals_data(self):
        # Documentos pendientes de su aprobación

    def get_expense_chart_data(self):
        # Gráfico de gastos a aprobar

class CostCenterApproverDashboardService:
    """Para aprobadores por centro de costo"""
    def get_stats_cards_data(self):
        # Aprobaciones por ceco

    def get_cost_centers_data(self):
        # Lista de cecos que puede aprobar

    def get_pending_approvals_data(self):
        # Documentos pendientes por ceco

class CompanyApproverDashboardService:
    """Para aprobadores por empresa"""
    def get_stats_cards_data(self):
        # Aprobaciones por empresa

    def get_companies_data(self):
        # Lista de empresas que puede aprobar

    def get_pending_approvals_data(self):
        # Documentos pendientes por empresa
```

---

#### **4. DocumentBuilder**

**Ubicación:** `app/builder/builder.py`

**Propósito:** Construcción compleja de documentos con validación

```python
class DocumentBuilder:
    def __init__(self):
        self.document = None

    def create_document(self, data, user):
        """
        Crea documento base

        Calcula:
        - recorded_subtotal = 0
        - recorded_total = 0
        - converted_subtotal = 0
        - converted_total = 0
        """
        cost_center = CostCenter.objects.get(name=data["access"].cost_center)
        enterprise = cost_center.company

        self.document = Document.objects.create(
            title=data["title"],
            description=data["description"],
            document_date=data["document_date"],
            recorded_subtotal=0.0,
            recorded_total=0.0,
            converted_subtotal=0.0,
            converted_total=0.0,
            state=data["state"],
            enterprise=enterprise,
            cost_center=cost_center,
            user=user
        )
        return self

    def add_expense(self, expense_data):
        """
        Agrega gasto y recalcula totales

        1. Obtiene tasa de cambio si moneda ≠ base_currency
        2. Calcula: total = subtotal * (1 + tax%)
        3. Convierte a base_currency
        4. Crea DocumentExpense
        5. Actualiza Document.totales
        """
        tax = expense_data["tax"]
        recorded_total = float(expense_data["recorded_subtotal"]) * (1 + float(tax.percentage)/100)

        base_currency = self.document.user.company.base_currency
        converted_subtotal = float(expense_data["recorded_subtotal"])
        converted_total = recorded_total

        if base_currency != expense_data["currency"]:
            # Obtener tasa de cambio
            exchange_rate = ExchangeRateService().get_rate(
                base_currency,
                expense_data["currency"]
            )
            converted_subtotal = float(expense_data["recorded_subtotal"]) / exchange_rate
            converted_total = recorded_total / exchange_rate

        # Actualizar totales del documento
        self.document.recorded_subtotal += float(expense_data['recorded_subtotal'])
        self.document.recorded_total += recorded_total
        self.document.converted_subtotal += converted_subtotal
        self.document.converted_total += converted_total

        # Crear gasto
        DocumentExpense.objects.create(
            title=expense_data['title'],
            description=expense_data['description'],
            expense_date=expense_data['expense_date'],
            expense_type=expense_data['expense_type'],
            recorded_subtotal=expense_data['recorded_subtotal'],
            converted_subtotal=converted_subtotal,
            recorded_total=recorded_total,
            converted_total=converted_total,
            document=self.document,
            supplier=expense_data.get('supplier'),
            expense_concept=expense_data['expense_concept'],
            currency=expense_data['currency'],
            tax=tax
        )
        return self

    def add_travel(self, travel_data):
        """Agrega viaje"""
        # Similar a add_expense
        pass

    def add_per_diem(self, perdiem_data):
        """Agrega viático"""
        # Similar a add_expense
        pass

    def build(self):
        """Retorna documento construido"""
        self.document.save()
        return self.document
```

**Uso:**

```python
builder = DocumentBuilder()
document = builder.create_document(data, user) \
    .add_expense(expense_data) \
    .add_travel(travel_data) \
    .add_per_diem(perdiem_data) \
    .build()
```

---

### 6.3 Trabajo Asíncrono (Si Aplica: Celery, Workers, Cron Jobs)

#### **Actualmente No Implementado, pensado para desarrollo en el futuro**

Con Celery:

```python
# Tareas pendientes de implementar

@shared_task
def send_approval_notification(approval_id):
    """
    Enviar notificación de aprobación/rechazo
    Triggers: cuando se crea ApprovalHistory
    Async: true
    Retry: 3 veces
    """
    pass

@shared_task
def send_document_reminder():
    """
    Enviar recordatorio de documentos pendientes
    Schedule: Diariamente a las 9:00 AM
    Cron: "0 9 * * *"
    """
    pass

@shared_task
def sync_documents_to_sap.delay(document_id):
    """
    Enviar documento a SAP (puede tomar tiempo)
    Triggers: cuando estado = APPROVED y marked_for_sap = true
    Async: true
    Retry: 5 veces con backoff
    """
    pass

@shared_task
def generate_monthly_report(company_id, month, year):
    """
    Generar reporte mensual de gastos
    Schedule: Primer día del mes a las 00:00 AM
    Async: true
    """
    pass
```

**Configuración Recomendada (settings.py):**

```python
CELERY_BROKER_URL = 'redis://localhost:6379'
CELERY_RESULT_BACKEND = 'redis://localhost:6379'
CELERY_ACCEPT_CONTENT = ['json']
CELERY_TASK_SERIALIZER = 'json'
CELERY_RESULT_SERIALIZER = 'json'
CELERY_TIMEZONE = 'America/Santiago'

CELERY_BEAT_SCHEDULE = {
    'send-daily-reminders': {
        'task': 'app.tasks.send_document_reminder',
        'schedule': crontab(hour=9, minute=0),
    },
    'generate-monthly-report': {
        'task': 'app.tasks.generate_monthly_report',
        'schedule': crontab(day_of_month=1, hour=0, minute=0),
    },
}
```

---

### 6.4 Integraciones Externas (APIs de Terceros)

#### **1. Tasas de Cambio (ExchangeRateService)**

**Ubicación:** `app/adapters/adapters.py`

**Propósito:** Convertir montos entre monedas

**Implementación:**

```python
class ExchangeRateService:
    """
    Integración con API de tasas de cambio
    Proveedor actual: Por definir (recomendado: Fixer.io, OpenExchangeRates)
    """

    API_URL = os.getenv('EXCHANGE_RATE_API_URL', 'https://api.example.com')
    API_KEY = os.getenv('EXCHANGE_RATE_API_KEY')
    CACHE_TIME = 3600  # 1 hora

    def __init__(self):
        self.cache = {}
        self.cache_timestamp = {}

    def get_rate(self, from_currency, to_currency):
        """
        Obtiene tasa de cambio entre dos monedas

        Retorna: float (tasa de conversión)
        Ejemplo: get_rate('USD', 'CLP') → 850.5
        """
        # Verificar caché
        cache_key = f"{from_currency}_{to_currency}"
        if cache_key in self.cache:
            if time.time() - self.cache_timestamp[cache_key] < self.CACHE_TIME:
                return self.cache[cache_key]

        # Consultar API
        try:
            response = requests.get(
                f"{self.API_URL}/rates",
                params={
                    'from': from_currency,
                    'to': to_currency,
                    'apikey': self.API_KEY
                },
                timeout=5
            )
            response.raise_for_status()
            rate = response.json()['rate']

            # Guardar en caché
            self.cache[cache_key] = rate
            self.cache_timestamp[cache_key] = time.time()

            return rate
        except Exception as e:
            logger.error(f"Error fetching exchange rate: {e}")
            # Fallback: retornar 1.0 o tasa anterior
            return self.cache.get(cache_key, 1.0)

    def convert(self, amount, from_currency, to_currency):
        """
        Convierte monto entre monedas

        Ejemplo: convert(100, 'USD', 'CLP') → 85050
        """
        if from_currency == to_currency:
            return amount

        rate = self.get_rate(from_currency, to_currency)
        return amount * rate
```

**Uso:**

```python
# En DocumentBuilder.add_expense()
service = ExchangeRateService()
converted_amount = service.convert(
    amount=250000,
    from_currency=expense_data['currency'],
    to_currency=base_currency
)
```

---

#### **2. Integración SAP (SapService)**

**Ubicación:** `app/features/web/sap/views.py`

**Propósito:** Enviar documentos aprobados a SAP

**Flujo:**

```
1. Usuario marca documento como APPROVED
2. Usuario accede a /sap/documents/send/
3. Backend convierte documento a formato SAP:
   - Mapea DocumentClass → SAP document type
   - Mapea ExpenseConcept → SAP account
   - Mapea AccountingAccount → SAP GL account
4. Envía POST a API SAP
5. SAP retorna external_code
6. Sistema guarda external_code en Document.external_code

Datos enviados a SAP:
{
  "document_type": "ZXP1",  # De DocumentClass.code
  "document_date": "2025-11-30",
  "items": [
    {
      "account": "1000",  # De AccountingAccount.account
      "amount": 250000.00,
      "concept": "Hospedaje",
      "supplier": "Hotel ABC"
    }
  ],
  "company_code": "1000"  # De Company.sap_code
}
```

**Ejemplo de Respuesta SAP:**

```json
{
  "status": "success",
  "document_number": "FI-2025-0001234",
  "posting_date": "2025-11-30"
}
```

---

#### **3. Email Notifications (Futuro)**

**Casos de Uso:**

```python
# Notificación: Documento enviado a aprobación
send_email(
    to=approver.email,
    subject="Documento pendiente de aprobación",
    template="approval_needed",
    context={
        "document": document,
        "sender": user,
        "approval_url": "..."
    }
)

# Notificación: Documento aprobado
send_email(
    to=user.email,
    subject="Documento aprobado",
    template="approval_success",
    context={
        "document": document,
        "approver": approver
    }
)

# Notificación: Documento rechazado
send_email(
    to=user.email,
    subject="Documento rechazado",
    template="approval_rejected",
    context={
        "document": document,
        "approver": approver,
        "comments": comments
    }
)
```

---

## Resumen de Servicios

| Servicio                     | Tipo         | Responsabilidad                   |
| ---------------------------- | ------------ | --------------------------------- |
| **DashboardEmployeeService** | Cálculo      | Datos para dashboard empleado     |
| **ApproverDashboardService** | Cálculo      | Datos para dashboards aprobadores |
| **ApprovalService**          | Orquestación | Lógica multi-nivel de aprobación  |
| **DocumentBuilder**          | Construcción | Build de documentos complejos     |
| **ExchangeRateService**      | Integración  | Conversión de divisas             |
| **SapService**               | Integración  | Envío a SAP ERP                   |
| **EmailService**             | Notificación | Correos (futuro)                  |
| **CeleryTasks**              | Async        | Tareas asíncronas (futuro)        |

---

## 7. Seguridad

### 7.1 Principios Aplicados (JWT, CSRF, CORS, etc.)

#### **A. Token Authentication (No JWT, Token DRF)**

**Implementación:** Django REST Framework Token Authentication

```
NO es JWT. Es un token opaco generado por DRF:
- Almacenado en tabla: authtoken_token
- Estructura: 40 caracteres hexadecimales aleatorios
- No contiene claims (stateless en BD)
- Sin expiración por defecto (pero se puede agregar)
```

**Header de Autenticación:**

```http
Authorization: Token a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
```

**Flujo:**

```
1. POST /auth/login/ con credenciales
2. Backend valida contra modelo User
3. Backend busca o crea Token para ese User
4. Respuesta: {"token": "abc123..."}
5. Cliente almacena en localStorage
6. Cliente envía en headers de siguientes requests
7. Middleware valida token en tabla authtoken_token
8. Si válido: request.user = User asociado
9. Si inválido: Response 401 Unauthorized
```

**Ventajas:**

- Simple de implementar
- No requiere secrets compartidos
- Stateless para cliente
- Compatible con mobile/spa

**Desventajas:**

- No hay expiración automática
- No hay refresh tokens
- Requiere validación en BD en cada request

---

#### **B. CSRF (Cross-Site Request Forgery)**

**Estado:** Configurado en Django pero NO requerido en DRF

```python
# settings.py
MIDDLEWARE = [
    'django.middleware.csrf.CsrfViewMiddleware',
    # ...
]

# tokens.py - CSRF automático
# Django genera token CSRF para cada sesión
# Se valida automáticamente en POST/PUT/DELETE form-urlencoded
```

**En API REST JSON:**

- CSRF está DESHABILITADO porque:
  - Los tokens se validan por Authorization header
  - Un atacante no puede forjar requests JSON desde otro dominio
  - El navegador bloquea requests cross-origin sin CORS

**Si se requiere CSRF:**

```python
# Agregar a view
from rest_framework.decorators import csrf_protect

@csrf_protect  # Fuerza validación CSRF
def sensitive_view(request):
    pass
```

---

#### **C. CORS (Cross-Origin Resource Sharing)**

**Instalado:** django-cors-headers 4.4.0

**Configuración Actual:**

```python
# settings.py
INSTALLED_APPS = [
    'corsheaders',
    ...
]

MIDDLEWARE = [
    "corsheaders.middleware.CorsMiddleware",  # Debe ser primero
    "django.middleware.common.CommonMiddleware",
    ...
]

# CORS settings
CORS_ALLOWED_ORIGINS = [
    "https://rinderline-webapp.vercel.app",
]

if DEBUG:
    CORS_ALLOW_ALL_ORIGINS = True  # ⚠️ Solo en desarrollo
```

**Headers CORS Automáticos:**

```http
Access-Control-Allow-Origin: https://rinderline-webapp.vercel.app
Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS
Access-Control-Allow-Headers: Authorization, Content-Type
Access-Control-Allow-Credentials: true
```

**Preflight Requests:**

```http
# Cliente envía
OPTIONS /api/v1/app/documents/
Access-Control-Request-Method: POST
Access-Control-Request-Headers: Authorization

# Servidor responde con headers CORS
# Cliente procede con POST
```

---

#### **D. HTTPS/TLS**

**Forzado en Producción:**

```python
# settings.py (Render)
if not DEBUG:
    SECURE_SSL_REDIRECT = True
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True
    SECURE_HSTS_SECONDS = 31536000  # 1 año
    SECURE_HSTS_INCLUDE_SUBDOMAINS = True
    SECURE_HSTS_PRELOAD = True
```

**Headers de Seguridad:**

```http
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
```

---

### 7.2 Manejo de Contraseñas y Tokens

#### **A. Hash de Contraseñas**

**Algoritmo:** PBKDF2 + SHA256 (Django default)

```python
# Cuando usuario se registra
user = User.objects.create_user(
    username='juan',
    password='Segura123!'  # ← Se hashea automáticamente
)

# Django la guarda como:
# pbkdf2_sha256$600000$salt$hash
```

**Validación:**

```python
# Cuando usuario hace login
user.check_password('Segura123!')  # True
user.check_password('WrongPass')   # False

# Usa algoritmo PBKDF2 configurado
```

**Configuración:**

```python
# settings.py
PASSWORD_HASHERS = [
    'django.contrib.auth.hashers.PBKDF2PasswordHasher',
    'django.contrib.auth.hashers.PBKDF2SHA1PasswordHasher',
    'django.contrib.auth.hashers.Argon2PasswordHasher',  # Más fuerte
    'django.contrib.auth.hashers.BCryptSHA256PasswordHasher',
]

PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
        'OPTIONS': {
            'min_length': 8,
        }
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]
```

**Mejora Recomendada:**

```python
# Cambiar a Argon2 (más seguro)
# pip install argon2-cffi

PASSWORD_HASHERS = [
    'django.contrib.auth.hashers.Argon2PasswordHasher',  # Primero
    'django.contrib.auth.hashers.PBKDF2PasswordHasher',
    ...
]
```

---

#### **B. Token Storage**

**En Base de Datos:**

```python
# authtoken/models.py
class Token(models.Model):
    key = models.CharField(max_length=40, primary_key=True)
    user = models.OneToOneField(
        User,
        related_name='auth_token',
        on_delete=models.CASCADE
    )
    created = models.DateTimeField(auto_now_add=True)
```

**Generación:**

```python
from rest_framework.authtoken.models import Token

# Al login
token, created = Token.objects.get_or_create(user=user)

# Si token ya existe, se reutiliza
# Si necesitas nuevo: Token.objects.filter(user=user).delete()
```

**Almacenamiento en Cliente (Frontend):**

```javascript
// En localStorage (NO seguro contra XSS)
localStorage.setItem("authToken", response.token);

// En sessionStorage (se borra al cerrar navegador)
sessionStorage.setItem("authToken", response.token);

// En Cookie httpOnly (mejor, pero requiere CSRF)
// (Backend debe configurar)
```

---

#### **C. Token Logout**

**Implementación Actual:**

```python
# auth.py
@action(detail=False, methods=['post'])
def logout(self, request):
    try:
        request.user.auth_token.delete()
        return Response({'detail': 'Logged out'}, status=200)
    except AttributeError:
        return Response({'detail': 'Invalid token'}, status=400)
```

**Flujo:**

```
1. Cliente envía POST /auth/logout/ con token en header
2. Backend identifica al usuario del token
3. Backend elimina Token de BD
4. Token ya no es válido
5. Próximas requests con ese token → 401 Unauthorized
```

---

### 7.3 Sanitización y Validaciones

#### **A. Validación de Entrada**

**Niveles:**

```
1. Serializer Level (DRF)
   - max_length
   - regex patterns
   - custom validators

2. Model Level (Django)
   - clean() method
   - Constraints

3. Business Logic Level
   - Reglas de negocio
   - Permisos
```

**Ejemplo: Validación de DocumentExpense**

```python
# serializers.py
class DocumentExpenseSerializer(serializers.ModelSerializer):
    class Meta:
        model = DocumentExpense
        fields = ['title', 'amount', 'tax', 'currency']

    def validate_title(self, value):
        # Evitar inyección SQL
        if '<script>' in value.lower():
            raise ValidationError("Invalid characters in title")

        # Validar longitud
        if len(value) > 40:
            raise ValidationError("Title too long")

        return value.strip()

    def validate_amount(self, value):
        # Validar número positivo
        if value <= 0:
            raise ValidationError("Amount must be positive")

        # Validar límite razonable
        if value > Decimal('99999999.9999999999'):
            raise ValidationError("Amount exceeds maximum")

        return value

    def validate(self, data):
        # Validación entre campos
        if data['tax'].company != data['currency'].company:
            raise ValidationError("Tax and currency mismatch")

        return data
```

**Tipos de Inyección Prevenidos:**

```
1. SQL Injection
   ✓ Django ORM escapea automáticamente
   ✗ Si usas raw SQL: usar parametrized queries

2. XSS (Cross-Site Scripting)
   ✓ Serializers escapean HTML por defecto
   ✓ Frontend debería usar innerText, no innerHTML
   ✗ Si devuelves HTML: usar mark_safe() con cuidado

3. NoSQL Injection
   ✓ No aplicable (usamos SQL)

4. Command Injection
   ✓ No aplicable (no ejecutamos comandos del sistema)
```

---

#### **B. Sanitización de Salida**

```python
# En serializers
class DocumentSerializer(serializers.ModelSerializer):
    title = serializers.SerializerMethodField()

    def get_title(self, obj):
        # Si necesitas HTML, usa mark_safe con cuidado
        # Por defecto Django escapea
        return obj.title  # Automáticamente escapado
```

---

### 7.4 Seguridad de Archivos (PDFs, Uploads)

#### **A. Almacenamiento en AWS S3**

**Configuración:**

```python
# settings.py
AWS_ACCESS_KEY_ID = os.getenv('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = os.getenv('AWS_SECRET_ACCESS_KEY')
AWS_STORAGE_BUCKET_NAME = os.getenv('AWS_STORAGE_BUCKET_NAME')
AWS_S3_REGION_NAME = 'us-east-1'
AWS_S3_CUSTOM_DOMAIN = f'{AWS_STORAGE_BUCKET_NAME}.s3.amazonaws.com'
AWS_S3_OBJECT_PARAMETERS = {
    'CacheControl': 'max-age=86400',
}

STORAGES = {
    'default': {
        'BACKEND': 'storages.backends.s3boto3.S3Boto3Storage',
    },
    'staticfiles': {
        'BACKEND': 'storages.backends.s3boto3.S3Boto3Storage',
    }
}
```

**Rutas Seguras:**

```python
# Cada archivo en ruta con ID de usuario/documento
# Previene acceso directo a archivos de otros usuarios

upload_to='documents/{year}/{month}/{filename}'
# Resultado: documents/2025/11/user_123_doc_456.pdf

upload_to='expense_files/{id}_{filename}'
# Resultado: expense_files/100_receipt_001.pdf
```

---

#### **B. Validación de Tipo de Archivo**

```python
# parsers.py / serializers.py
import magic

class FileValidator:
    ALLOWED_MIME_TYPES = [
        'application/pdf',
        'image/jpeg',
        'image/png',
    ]

    MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB

    @staticmethod
    def validate_file(file):
        # Validar tamaño
        if file.size > FileValidator.MAX_FILE_SIZE:
            raise ValidationError(f"File too large (max {5}MB)")

        # Validar tipo MIME (por magic bytes, no extensión)
        mime_type = magic.from_buffer(file.read(1024), mime=True)
        file.seek(0)  # Reset

        if mime_type not in FileValidator.ALLOWED_MIME_TYPES:
            raise ValidationError(f"Invalid file type: {mime_type}")

        # Validar extensión (como defensa adicional)
        name = file.name.lower()
        allowed_extensions = ['.pdf', '.jpg', '.jpeg', '.png']
        if not any(name.endswith(ext) for ext in allowed_extensions):
            raise ValidationError("Invalid file extension")

        return True
```

**Uso:**

```python
class ExpenseFileSerializer(serializers.ModelSerializer):
    class Meta:
        model = ExpenseFile
        fields = ['file']

    def validate_file(self, value):
        FileValidator.validate_file(value)
        return value
```

---

#### **C. Control de Acceso a Archivos**

```python
# views.py - Download/Retrieve archivo
class FileDownloadView(views.APIView):
    def get(self, request, file_id):
        # 1. Obtener archivo
        file = ExpenseFile.objects.get(id=file_id)

        # 2. Validar permisos
        expense = file.document_expense
        if expense.document.user != request.user:
            # Verificar si es aprobador
            if not is_approver_for(request.user, expense.document):
                raise PermissionDenied("No access to this file")

        # 3. Retornar archivo
        return Response({
            'url': file.file.url,  # URL presignada S3
            'name': file.file.name
        })
```

**URLs Presignadas en S3:**

```python
# boto3 genera URLs presignadas (válidas por tiempo limitado)
from django.core.files.storage import default_storage

url = default_storage.url(file_path)
# O con expiración:
url = default_storage.url(file_path, parameters={
    "ResponseContentDisposition": "attachment; filename=file.pdf"
}, expire_secs=3600)
```

---

### 7.5 Logs y Auditorías

#### **A. Logging de Acciones**

**Configuración:**

```python
# settings.py
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'file': {
            'level': 'INFO',
            'class': 'logging.FileHandler',
            'filename': 'logs/app.log',
            'formatter': 'verbose',
        },
        'console': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
        },
    },
    'loggers': {
        'app': {
            'handlers': ['file', 'console'],
            'level': 'INFO',
            'propagate': False,
        },
    },
}

logger = logging.getLogger('app')
```

**Eventos a Loguear:**

```python
# services/appraisal_service.py
logger.info(f"User {approver.username} approved expense {expense.id} at level {level}")
logger.warning(f"User {approver.username} rejected expense {expense.id}")

# auth.py
logger.info(f"User {user.username} logged in from {request.META.get('REMOTE_ADDR')}")
logger.warning(f"Failed login attempt for username {username}")

# views.py
logger.error(f"Permission denied: User {user.id} accessed document {doc_id}")
```

**Salida Ejemplo:**

```
INFO 2025-11-30 15:45:00 appraisal_service User carlos.supervisor approved expense 100 at level 1
INFO 2025-11-30 15:50:00 appraisal_service User maria.gerente approved expense 100 at level 2
INFO 2025-11-30 16:00:00 appraisal_service User juan.perez logged in from 192.168.1.100
WARNING 2025-11-30 16:05:00 auth Failed login attempt for username juan.perez (wrong password)
ERROR 2025-11-30 16:10:00 views Permission denied: User 5 accessed document 42
```

---

#### **B. Auditoría con ApprovalHistory**

**Tabla de Auditoría Integrada:**

```python
class ApprovalHistory(models.Model):
    # Quién, Qué, Cuándo, Resultado
    approver = models.ForeignKey(User, ...)  # Quién
    content_type = GenericForeignKey(...)    # Qué (tipo)
    object_id = models.PositiveIntegerField()# Qué (ID)
    operation_date = models.DateTimeField(auto_now_add=True)  # Cuándo
    level = models.IntegerField(choices=...)  # Nivel
    is_approved = models.BooleanField()      # Resultado
    comments = models.TextField()             # Justificación
```

**Query Auditoría:**

```python
# Ver toda la aprobación de un documento
history = ApprovalHistory.objects.filter(
    document=document
).select_related('approver').order_by('level')

for record in history:
    print(f"Level {record.level}: {record.approver.username} "
          f"{'Approved' if record.is_approved else 'Rejected'} "
          f"at {record.operation_date}")
```

---

## Checklist de Seguridad

| Item                    | Estado             | Notas                              |
| ----------------------- | ------------------ | ---------------------------------- |
| **Autenticación**       | ✅ Token DRF       | Considerar agregar expiración      |
| **CSRF**                | ✅ Configurado     | Deshabilitado en API (OK)          |
| **CORS**                | ✅ Configurado     | Solo Vercel en prod                |
| **HTTPS**               | ✅ Forzado         | En producción Render               |
| **Contraseñas**         | ✅ PBKDF2          | Considerar migrar a Argon2         |
| **Validación Input**    | ✅ Serializers     | Implementado en 3 niveles          |
| **Sanitización Output** | ✅ Django default  | Escapea HTML automáticamente       |
| **Archivos**            | ✅ S3 + Validación | MIME type + size + extensión       |
| **Logging**             | ✅ Configurado     | Rotación de logs recomendada       |
| **Auditoría**           | ✅ ApprovalHistory | Historial completo de aprobaciones |
| **Error Tracking**      | ✅ Sentry          | Configurado para alertas           |
| **Rate Limiting**       | ⚠️ Parcial         | 1000 req/day, considerar mejorar   |
| **SQL Injection**       | ✅ Previsto        | Django ORM no vulnerable           |
| **XSS**                 | ✅ Prevenido       | Serializers escapean               |
| **Secrets**             | ✅ .env            | Nunca en git                       |

---

## 8. Configuración y Entornos

### 8.1 Variables de Entorno

#### **A. Setup Local (.env)**

Crear archivo `.env` en raíz del proyecto:

```bash
# Django Configuration
DJANGO_SECRET_KEY=your-super-secret-key-here-change-in-production
DEBUG=True

# Database
DB_ENGINE=django.db.backends.sqlite3
# O para PostgreSQL:
# DB_ENGINE=django.db.backends.postgresql
# DB_NAME=rinderline_db
# DB_USER=rinderline_user
# DB_PASSWORD=secure_password_here
# DB_HOST=localhost
# DB_PORT=5432

# AWS S3 (File Storage)
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
AWS_STORAGE_BUCKET_NAME=rinderline-storage-bucket
AWS_S3_REGION_NAME=us-east-1

# CORS
CORS_ALLOWED_ORIGINS=http://localhost:3000,https://rinderline-webapp.vercel.app

# Sentry (Error Tracking)
SENTRY_DSN=https://xxx@yyy.ingest.sentry.io/zzz

# Email (SMTP)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_HOST_USER=noreply@rinderline.com
EMAIL_HOST_PASSWORD=your-app-password
EMAIL_USE_TLS=True

# Exchange Rate Service
EXCHANGE_RATE_API_KEY=your-api-key-here

# SAP Integration
SAP_HOST=https://sap-system.example.com
SAP_USERNAME=sap_user
SAP_PASSWORD=sap_password

# Celery / Redis
CELERY_BROKER_URL=redis://localhost:6379/0
CELERY_RESULT_BACKEND=redis://localhost:6379/0

# Environment
ENVIRONMENT=development
```

---

#### **B. Variables por Entorno**

**Desarrollo (DEBUG=True):**

```
- SQLite local
- CORS abierto a localhost:3000
- DEBUG mode activo (stack traces)
- Media files local
- Emails en console
- Sin validación HTTPS
```

**Staging (DEBUG=False, pero con logs detallados):**

```
- PostgreSQL remoto
- CORS a dominio de staging
- DEBUG mode desactivo
- Archivos en S3
- Emails reales
- HTTPS forzado
- Monitoreo de errores Sentry
```

**Producción (DEBUG=False, máxima seguridad):**

```
- PostgreSQL remoto
- CORS solo a rinderline-webapp.vercel.app
- DEBUG mode desactivo
- Archivos en S3
- Emails reales (Gmail/SendGrid)
- HTTPS forzado con HSTS
- Monitoreo de errores Sentry
- Rate limiting activo
- Backups de BD automáticos
```

---

### 8.2 Django Settings.py (Estructura Actual)

#### **A. Detección de Entorno**

```python
# settings.py
from pathlib import Path
import os
from dotenv import load_dotenv

load_dotenv()  # Carga .env

BASE_DIR = Path(__file__).resolve().parent.parent

# Auto-detect si está en Render o local
DEBUG = 'RENDER' not in os.environ

# Si está en Render: producción
# Si no está en Render: desarrollo/staging local
```

---

#### **B. Configuración por Sección**

**1. Security**

```python
SECRET_KEY = os.getenv('DJANGO_SECRET_KEY')

DEBUG = 'RENDER' not in os.environ

ALLOWED_HOSTS = [
    'rinderline-api.onrender.com',      # Render
    'rinderline-webapp.vercel.app',      # Frontend
    'localhost',
    '127.0.0.1',
]

# CSRF & CORS
CSRF_COOKIE_SECURE = not DEBUG        # True en producción
SESSION_COOKIE_SECURE = not DEBUG     # True en producción
SECURE_SSL_REDIRECT = not DEBUG       # True en producción
SECURE_HSTS_SECONDS = 31536000 if not DEBUG else 0
```

**2. Database**

```python
# Desarrollo (SQLite)
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

# Producción (PostgreSQL - comentado para cambiar)
"""
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.getenv('DB_NAME'),
        'USER': os.getenv('DB_USER'),
        'PASSWORD': os.getenv('DB_PASSWORD'),
        'HOST': os.getenv('DB_HOST'),
        'PORT': os.getenv('DB_PORT'),
        'ATOMIC_REQUESTS': True,
        'CONN_MAX_AGE': 600,
    }
}
"""
```

**3. Static & Media Files**

```python
STATIC_URL = '/static/'

STATICFILES_DIRS = [
    os.path.join(BASE_DIR, 'stylescss')
]

# En producción
if not DEBUG:
    STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')
    STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'
```

**4. S3 Storage**

```python
AWS_ACCESS_KEY_ID = os.getenv('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = os.getenv('AWS_SECRET_ACCESS_KEY')
AWS_STORAGE_BUCKET_NAME = os.getenv('AWS_STORAGE_BUCKET_NAME')
AWS_S3_CUSTOM_DOMAIN = f'{AWS_STORAGE_BUCKET_NAME}.s3.amazonaws.com'
AWS_S3_FILE_OVERWRITE = False

STORAGES = {
    'default': {
        'BACKEND': 'storages.backends.s3boto3.S3Boto3Storage',
    },
    'staticfiles': {
        'BACKEND': 'storages.backends.s3boto3.S3Boto3Storage',
    }
}
```

**5. REST Framework**

```python
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.TokenAuthentication',
    ],
    'DEFAULT_RENDERER_CLASSES': [
        'app.renderers.JSendRenderer',
    ],
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',
        'rest_framework.throttling.UserRateThrottle',
    ],
    'DEFAULT_THROTTLE_RATES': {
        'anon': '1000/day',
        'user': '1000/day',
    },
    'DEFAULT_FILTER_BACKENDS': [
        'django_filters.rest_framework.DjangoFilterBackend'
    ],
}
```

**6. CORS**

```python
CORS_ALLOWED_ORIGINS = [
    "https://rinderline-webapp.vercel.app",
]

if DEBUG:
    CORS_ALLOW_ALL_ORIGINS = True  # Permite localhost:3000, localhost:8000, etc.
```

**7. Internacionalización**

```python
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

LANGUAGES = [
    ('en', 'English'),
    ('es', 'Spanish'),
    ('fr', 'French'),
    ('de', 'German'),
]

LOCALE_PATHS = [
    os.path.join(BASE_DIR, 'locale'),
]
```

---

### 8.3 Despliegue en Render

#### **A. Configuración en Render Dashboard**

```
Project: rinderline-backend
Region: Ohio (us-east-1)
Plan: Starter/Standard (según tráfico)

Build Command:
./build.sh

Start Command:
gunicorn rinderline.wsgi:application --bind 0.0.0.0:$PORT

Environment Variables:
- DJANGO_SECRET_KEY: [Generate strong key]
- DEBUG: False
- DB_ENGINE: django.db.backends.postgresql
- DB_NAME: rinderline_db
- DB_USER: postgres_user
- DB_PASSWORD: [Render DB password]
- DB_HOST: [Render internal DB host]
- DB_PORT: 5432
- AWS_ACCESS_KEY_ID: [AWS IAM credentials]
- AWS_SECRET_ACCESS_KEY: [AWS IAM credentials]
- AWS_STORAGE_BUCKET_NAME: rinderline-prod-storage
- SENTRY_DSN: [Sentry project DSN]
- ENVIRONMENT: production
```

---

#### **B. Build Script (build.sh)**

```bash
#!/bin/bash
# build.sh - Render deployment script

set -o errexit  # Exit on error

# 1. Install Python dependencies
pip install --upgrade pip
pip install -r requirements.txt

# 2. Collect static files
python manage.py collectstatic --no-input

# 3. Run migrations
python manage.py migrate

# 4. Create superuser (opcional, si no existe)
# python manage.py createsuperuser --no-input
```

**Permisos:**

```bash
chmod +x build.sh
```

---

#### **C. Gunicorn Configuration**

**gunicorn_config.py (opcional, para production tuning):**

```python
import multiprocessing

# Número de workers basado en CPU cores
workers = multiprocessing.cpu_count() * 2 + 1

# Threads por worker
threads = 2

# Timeout (segundos)
timeout = 30

# Bind
bind = "0.0.0.0:8000"

# Logs
accesslog = "-"
errorlog = "-"
loglevel = "info"

# Keep-alive
keepalive = 2
```

**En Render Start Command:**

```bash
gunicorn -c gunicorn_config.py rinderline.wsgi:application
```

---

### 8.4 Base de Datos

#### **A. Migraciones**

**Crear migración después de cambiar models:**

```bash
python manage.py makemigrations
python manage.py migrate
```

**Listar migraciones:**

```bash
python manage.py showmigrations
```

**Revertir migración:**

```bash
python manage.py migrate app 0008_previous_migration
```

**Estado actual:**

```bash
python manage.py migrate --plan  # Ver migrations a aplicar
```

---

#### **B. SQLite (Desarrollo)**

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}
```

**Ubicación:** `rinderline/db.sqlite3`

**Inicializar:**

```bash
python manage.py migrate
```

**Backup:**

```bash
cp db.sqlite3 db.sqlite3.backup
```

---

#### **C. PostgreSQL (Producción/Staging)**

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.getenv('DB_NAME'),
        'USER': os.getenv('DB_USER'),
        'PASSWORD': os.getenv('DB_PASSWORD'),
        'HOST': os.getenv('DB_HOST'),
        'PORT': os.getenv('DB_PORT'),
        'ATOMIC_REQUESTS': True,       # Transacciones atómicas
        'CONN_MAX_AGE': 600,           # Connection pooling
    }
}
```

**Instalación Local (Windows PowerShell):**

```powershell
# 1. Install PostgreSQL from https://www.postgresql.org/download/windows/

# 2. Start PostgreSQL service
Get-Service postgresql* | Start-Service

# 3. Create database
psql -U postgres -c "CREATE DATABASE rinderline_db;"
psql -U postgres -c "CREATE USER rinderline_user WITH PASSWORD 'password';"
psql -U postgres -c "ALTER ROLE rinderline_user SET client_encoding TO 'utf8';"
psql -U postgres -c "ALTER ROLE rinderline_user SET default_transaction_isolation TO 'read committed';"
psql -U postgres -c "ALTER ROLE rinderline_user SET default_transaction_deferrable TO on;"
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE rinderline_db TO rinderline_user;"

# 4. Connect and verify
psql -U rinderline_user -d rinderline_db
```

**Backup & Restore:**

```bash
# Backup
pg_dump -U rinderline_user -h localhost rinderline_db > backup.sql

# Restore
psql -U rinderline_user -h localhost rinderline_db < backup.sql
```

---

### 8.5 Requirements.txt

```
Django==5.2.8
djangorestframework==3.15.2
django-cors-headers==4.4.0
django-filter==24.3
drf-yasg==1.21.7
whitenoise==6.6.0
boto3==1.34.33
django-storages==1.14.2
psycopg2-binary==2.9.9
celery==5.3.4
redis==5.0.1
sentry-sdk==1.39.2
python-decouple==3.8
python-dotenv==1.0.0
requests==2.31.0
Pillow==10.1.0
gunicorn==21.2.0
```

**Instalar:**

```bash
pip install -r requirements.txt
```

**Generar requirements.txt:**

```bash
pip freeze > requirements.txt
```

---

### 8.6 Checklist de Deployment

| Paso                 | Descripción                       | Prod | Staging | Dev |
| -------------------- | --------------------------------- | ---- | ------- | --- |
| **1. Código**        | Último commit en main             | ✅   | ✅      | -   |
| **2. Env Vars**      | Todos los .env configurados       | ✅   | ✅      | ✅  |
| **3. Migrations**    | Ejecutar makemigrations + migrate | ✅   | ✅      | ✅  |
| **4. Static Files**  | Collectstatic en S3               | ✅   | ✅      | -   |
| **5. Tests**         | Todos los tests pasando           | ✅   | ✅      | ✅  |
| **6. Security**      | DEBUG=False, SECRET_KEY único     | ✅   | ✅      | ✅  |
| **7. DB Backup**     | Backup de BD anterior             | ✅   | ✅      | -   |
| **8. SSL/TLS**       | HTTPS forzado                     | ✅   | ✅      | -   |
| **9. CORS**          | Dominios correctos configurados   | ✅   | ✅      | ✅  |
| **10. Monitoring**   | Sentry conectado                  | ✅   | ✅      | -   |
| **11. Logs**         | Logging configurado               | ✅   | ✅      | ✅  |
| **12. Health Check** | Endpoint /health/ funcionando     | ✅   | ✅      | ✅  |

---

### 8.7 Troubleshooting Común

#### **A. Errores de Migración**

```python
# Error: Relation "app_model" does not exist
# Solución:
python manage.py migrate --fake-initial
python manage.py migrate

# Error: Duplicated columns
# Solución:
python manage.py migrate app zero
python manage.py migrate
```

#### **B. Problemas de Estáticos**

```python
# Archivos .js/.css no se cargan
# Solución:
python manage.py collectstatic --no-input --clear

# En settings.py verificar:
STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'
```

#### **C. Conexión a BD**

```bash
# PostgreSQL no conecta
# Verificar:
psql -U rinderline_user -h localhost -d rinderline_db

# SQLite corrupta
python manage.py dbshell
.quit

# Eliminar y recrear
rm db.sqlite3
python manage.py migrate
```

#### **D. Errores de Permisos S3**

```python
# Error: Access Denied
# Verificar en AWS:
1. AWS_ACCESS_KEY_ID correcto
2. AWS_SECRET_ACCESS_KEY correcto
3. IAM user tiene permisos S3:GetObject, S3:PutObject
4. Bucket name correcto

# En Django:
AWS_QUERYSTRING_AUTH = False  # URLs públicas sin firma
```

---

## Resumen de Configuración por Entorno

```
┌─────────────────────────────────────────────────────────┐
│           DESARROLLO (DEBUG=True, Local)                │
├─────────────────────────────────────────────────────────┤
│ DB: SQLite (db.sqlite3)                                 │
│ Storage: Local filesystem                               │
│ CORS: Abierto (localhost:3000, localhost:8000)          │
│ Email: Console backend                                  │
│ Logs: Console + archivo                                 │
│ Secretos: .env local                                    │
│ HTTPS: No required                                      │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│         STAGING (DEBUG=False, Remote server)            │
├─────────────────────────────────────────────────────────┤
│ DB: PostgreSQL (Render managed)                         │
│ Storage: AWS S3                                         │
│ CORS: staging-api.example.com + vercel.app              │
│ Email: SMTP real (Gmail/SendGrid)                       │
│ Logs: Sentry + archivo                                  │
│ Secretos: Render environment variables                  │
│ HTTPS: Forzado (Let's Encrypt)                          │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│      PRODUCCIÓN (DEBUG=False, Render managed)           │
├─────────────────────────────────────────────────────────┤
│ DB: PostgreSQL (Render managed + backups)               │
│ Storage: AWS S3 (prod bucket)                           │
│ CORS: rinderline-webapp.vercel.app (solo)               │
│ Email: SMTP con alta confiabilidad                      │
│ Logs: Sentry alertas + auditlog                         │
│ Secretos: Render secrets (cifrados)                     │
│ HTTPS: Forzado + HSTS + preload                         │
│ Rate limiting: Activo (1000 req/día)                    │
│ Backups: Diarios + replicación                          │
└─────────────────────────────────────────────────────────┘
```

---

## Documentación Técnica - Resumen General

Esta documentación cubre 8 puntos principales del backend Rinderline:

1. **Arquitectura General:** Componentes, request lifecycle, integraciones
2. **Estructura del Proyecto:** Carpetas, módulos, convenciones, dependencias
3. **Modelos y BD:** 24 modelos, diagrama ER, validaciones, migraciones
4. **API y Endpoints:** 25+ endpoints, autenticación, autorización, ejemplos
5. **Servicios:** Business logic, async tasks, integraciones externas
6. **Seguridad:** Autenticación, CSRF/CORS, validación, auditoría
7. **Configuración:** Variables de entorno, settings.py, despliegue
8. **Entornos:** Dev/Staging/Prod, migraciones, monitoreo
