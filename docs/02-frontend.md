---
layout: default
title: Documentación Frontend
nav_order: 3
has_children: true
description: "Documentación técnica del Frontend de Rinderline"
---

# Documentación Técnica - Frontend de Rinderline

**Versión:** 1.0  
**Fecha:** Noviembre 2025  
**Framework:** Next.js 15.4.2 + React 19 + TypeScript  
**UI Library:** Shadcn/ui + Radix UI + Tailwind CSS  
**Despliegue:** Vercel

---

## ÍNDICE

1. [Introducción Técnica](#1-introducción-técnica)
2. [Acceso y Autenticación](#2-acceso-y-autenticación)
3. [Interfaz General](#3-interfaz-general)
4. [Dashboard / Pantalla de Inicio](#4-dashboard--pantalla-de-inicio)
5. [Módulo Principal (Documentos)](#5-módulo-principal-documentos)
6. [Módulo de Aprobaciones](#6-módulo-de-aprobaciones)
7. [Notificaciones](#7-notificaciones)
8. [Perfil y Configuración](#8-perfil-y-configuración)
9. [Sección de Administración](#9-sección-de-administración)
10. [Exportaciones y Reportes](#10-exportaciones-y-reportes)
11. [Errores Comunes](#11-errores-comunes)

---

## RESUMEN EJECUTIVO

El frontend de Rinderline es una **aplicación web moderna construida con Next.js y React** que proporciona una interfaz intuitiva para la gestión de gastos empresariales internacionales. La plataforma se sincroniza en tiempo real con el backend Django REST API.

### Características Clave:

- **App Router de Next.js:** Rutas organizadas en carpetas con layouts automáticos y renderizado híbrido (SSR/SSG/CSR)
- **TypeScript Strict:** Tipado completo para mayor seguridad en desarrollo
- **Gestión de Estado:** Zustand para store global con persistencia opcional
- **Formularios Robustos:** React Hook Form + Zod para validación declarativa
- **Design System:** Shadcn/ui + Radix UI con Tailwind CSS para estilo consistente
- **Multiidioma:** i18next con soporte para ES, EN, FR, DE
- **Dark Mode:** Temas oscuro/claro con next-themes
- **Gráficos Interactivos:** Recharts para dashboards y reportes visuales
- **Autenticación Token:** Bearer tokens almacenados en localStorage con refresh automático

### Rutas Principales:

| Sección          | Ruta               | Acceso     | Propósito                           |
| ---------------- | ------------------ | ---------- | ----------------------------------- |
| **Login**        | `/login`           | Público    | Autenticación de usuarios           |
| **Registro**     | `/signup`          | Público    | Crear nueva cuenta                  |
| **Dashboard**    | `/web`             | Protegido  | Panel principal del empleado        |
| **Gastos**       | `/web/expenses`    | Protegido  | Crear y gestionar documentos        |
| **Aprobaciones** | `/web/appraisal-*` | Protegido  | Flujo de aprobación (3 niveles)     |
| **Admin**        | `/web/admin`       | Solo admin | Gestión de usuarios y configuración |
| **Perfil**       | `/web/settings`    | Protegido  | Configuración personal              |

### Tecnologías:

- **Frontend:** Next.js 15.4.2, React 19, TypeScript 5
- **Styling:** Tailwind CSS 3.4.1, Shadcn/ui, Radix UI
- **Estado:** Zustand 5.0.8
- **Formularios:** React Hook Form + Zod
- **API Client:** Axios 1.7.9 con interceptores
- **Internacionalización:** i18next
- **Gráficos:** Recharts 3.1.2
- **Temas:** next-themes (Light/Dark mode)

---

## 1. Introducción Técnica

### Stack Tecnológico

- **Framework:** Next.js 15.4.2 (App Router)
- **Lenguaje:** TypeScript 5 con tipado estricto
- **Estado:** Zustand 5.0.8 (store global)
- **Formularios:** React Hook Form + Zod (validación)
- **API:** Axios 1.7.9 con interceptores
- **Autenticación:** Token Bearer (almacenado en localStorage)
- **Internacionalización:** i18next (EN, ES, FR, DE)
- **Temas:** next-themes (Light/Dark mode)
- **Estilos:** Tailwind CSS 3.4.1
- **Componentes:** Radix UI + Shadcn/ui custom
- **Gráficos:** Recharts 3.1.2 (Chart.js alternative)

### Estructura de Carpetas

```
src/
├─ app/                   # Next.js app router
│  ├─ layout.tsx         # Root layout
│  ├─ page.tsx           # Home page
│  ├─ login/             # Ruta pública
│  ├─ signup/            # Ruta pública
│  ├─ web/               # Rutas protegidas
│  │  ├─ layout.tsx      # Layout con sidebar
│  │  ├─ employee/
│  │  ├─ expenses/
│  │  ├─ appraisal*/     # Niveles de aprobación
│  │  ├─ admin/
│  │  └─ settings/
│  └─ i18n.ts
├─ components/           # Componentes reutilizables
│  ├─ ui/               # Componentes base (Shadcn)
│  ├─ forms/            # Formularios específicos
│  ├─ tables/           # Tablas reutilizables
│  └─ charts/           # Gráficos
├─ services/            # API + lógica
│  ├─ apiClient.ts      # Axios configurado
│  ├─ auth.ts
│  ├─ documents.ts
│  └─ constants.ts
├─ store/               # Zustand stores
├─ hooks/               # Custom hooks
├─ lib/                 # Utilidades (cn, etc)
└─ locales/             # Archivos i18n JSON
```

---

## 2. Acceso y Autenticación

### 2.1 URL Principal

**Base URL:**

- Desarrollo: `http://localhost:3000`
- Producción: `https://rinderline-webapp.vercel.app`

**Rutas públicas:**

- `/` - Home page
- `/login` - Inicio de sesión
- `/signup` - Registro
- `/forgot-password` - Recuperar contraseña
- `/reset-password?token=XYZ` - Establecer nueva contraseña

**Rutas protegidas** (require token):

- `/web` - Dashboard principal
- `/web/employee` - Panel de empleado
- `/web/expenses` - Gestión de gastos
- `/web/appraisal*` - Módulos de aprobación (3 niveles)
- `/web/admin` - Panel de administración
- `/web/settings` - Configuración de usuario

**Protección:** Middleware futuro verificará presencia de token en cookies antes de acceder a `/web/*`

---

### 2.2 Inicio de Sesión

**Ubicación:** `src/app/login/page.tsx` + `src/components/login-form.tsx`

**Funcionamiento:**

1. Usuario accede a `/login`
2. Completa formulario: username + password
3. Validación cliente con Zod:
   - Username: 3-20 caracteres
   - Password: mínimo 6 caracteres
4. Submit → POST a `/auth/login/` (FormData)
5. Backend valida credenciales contra BD
6. Respuesta: `{token, user, redirectTo}`
7. Frontend guarda token en `localStorage` bajo clave `"token"`
8. Zustand store actualiza estado de usuario
9. Router redirige a `/web`

**Interceptor Axios Request:**

- Lee token de localStorage
- Agrega header: `Authorization: Token {token}`
- Incluye idioma actual en header `Accept-Language`

**Interceptor Axios Response:**

- Status 401 → Limpia token, redirige a `/login`
- Status 500+ → Log y error genérico
- Maneja respuesta JSend: `{status, data, message}`

**Validaciones:**

- Email/Username no pueden estar vacíos
- Mostrar errores por campo en rojo
- Botón deshabilitado mientras se envía

**Estados:**

- IDLE: Formulario listo
- SUBMITTING: Petición en curso, botón deshabilitado
- ERROR: Mostrar mensaje, mantener botón activo
- SUCCESS: Redirección automática

---

### 2.3 Registro (Sign Up)

**Ubicación:** `src/app/signup/page.tsx` + `src/components/signup-form.tsx`

**Funcionamiento:**

1. Usuario accede a `/signup`
2. Completa: email, username, password (2 veces)
3. Validaciones Zod:
   - Email válido y único
   - Username: 3-20 caracteres, alpanumérico + underscore
   - Password: mínimo 8, mayúscula, número, símbolo especial
   - Las dos contraseñas coinciden
4. Indicador de fortaleza en tiempo real (Débil → Muy Fuerte)
5. Submit → POST `/auth/register/`
6. Backend crea usuario, genera token, responde
7. Frontend auto-login y redirige a `/web/settings` (completar perfil)

**Validación Password:**

- Mínimo 8 caracteres
- Al menos 1 mayúscula
- Al menos 1 número
- Al menos 1 símbolo: `!@#$%^&*`

**Errores posibles:**

- Email ya registrado
- Username ya existe
- Contraseña muy débil
- Validación del servidor

---

### 2.4 Recuperar Contraseña

**Ubicación:** `src/components/forgot-password-form.tsx`

**Flujo:**

1. Usuario olvida contraseña → Click "¿Olvidaste tu contraseña?"
2. Accede a `/forgot-password`
3. Ingresa email
4. Validación: formato email válido
5. Submit → POST `/auth/forgot-password/` con email
6. Backend busca usuario, genera token temporal, envía email
7. Frontend muestra: "Revisa tu email en los próximos 24 horas"
8. Usuario recibe email con link: `/reset-password?token=abc123xyz`
9. Accede al link (token validado cliente)
10. Ingresa nueva password 2 veces
11. Submit → POST `/auth/reset-password/` con `{token, password}`
12. Backend valida token (expiración, match), actualiza contraseña
13. Redirige a `/login` con mensaje de éxito

**Validaciones:**

- Email debe existir en BD
- Token debe ser válido y no expirado (24h)
- New password debe cumplir requisitos

---

### 2.5 Cierre de Sesión

**Ubicación:** `src/components/nav-user.tsx`

**Funcionamiento:**

1. Usuario hizo click en Avatar/Menú → Logout
2. Confirmación: "¿Estás seguro?"
3. Si confirma → POST `/auth/logout/` (opcional, con token)
4. Backend elimina token de BD (si implementa blacklist)
5. Frontend:
   - Elimina token de localStorage
   - Limpia Zustand store (user = null)
   - Limpia estado de aplicación
   - Redirige a `/login`

**Sincronización entre pestañas:**

- Evento `storage` detecta cambios en otras pestañas
- Si `localStorage.token` se elimina en tab A → tab B se da cuenta y redirige

**Confirmación visual:**

- Dialog/Modal antes de logout
- No hacer logout silenciosamente

---

## Resumen - Punto 2

| Item               | Detalles                                       |
| ------------------ | ---------------------------------------------- |
| **URL Base**       | localhost:3000 (dev), vercel.app (prod)        |
| **Login**          | /login → FormData → Token → localStorage       |
| **Signup**         | /signup → Validar → Crear usuario → Auto-login |
| **Forgot**         | /forgot-password → Email → Link token 24h      |
| **Reset**          | /reset-password?token → New password → /login  |
| **Logout**         | Perfil → Logout → Confirmar → Limpiar → /login |
| **Token Storage**  | localStorage clave "token"                     |
| **Token Header**   | `Authorization: Token {valor}`                 |
| **Auto-redirect**  | 401 → /login, /web/\* sin token → /login       |
| **Validación**     | Zod cliente + servidor                         |
| **Sincronización** | Storage events entre pestañas                  |

---

---

## 3. Interfaz General

### 3.1 Diseño General de la Pantalla Principal Protegida

**Ubicación:** `src/components/layout/main-layout.tsx`

**Estructura de Layout:**

La pantalla protegida (`/web/*`) tiene 3 componentes principales:

1. **AppSidebar** (izquierda): Navegación colapsible
2. **SiteHeader** (arriba): Barra superior con título y acciones
3. **Main Content** (centro): Área con padding responsive

**Responsive Design:**

- Mobile: Sidebar colapsado por defecto, trigger en header
- Tablet (md): Sidebar visible, width ajustable
- Desktop: Sidebar full visible

**Contenedor Principal:**

- Padding: 16px (móvil), 24px (tablet), 32px (desktop)
- Gap entre elementos: 16px
- Max width: Sin límite (full width container)
- Background: White (light), Dark gray (dark mode)

---

### 3.2 Barra Superior (Top Header)

**Ubicación:** `src/components/site-header.tsx`

**Componentes de la Barra:**

1. **Trigger Sidebar** (izquierda)

   - Botón para toggle sidebar en móvil
   - Solo visible cuando sidebar está colapsado
   - Icon: Menu (lucide-react)

2. **Separador** vertical

3. **Título de Página** (izquierda)

   - Nombre dinámico según ruta actual
   - Traducible con i18n
   - Generado automáticamente desde pathname
   - Se oculta en móvil si hay poco espacio

4. **Botones de Acción** (derecha)
   - **Primary Button:** "Subir Gasto" - Abre modal CreateExpense
   - **Secondary Button:** "Dashboard de Aprobador" (solo si rol includes APPROVER)
   - Acceso rápido a funciones principales

**Altura:** 48px (h-12)
**Border:** Bottom border subtle
**Z-index:** Mantiene sticky/fixed position

---

### 3.3 Barra Lateral / Menú de Navegación

**Ubicación:** `src/components/app-sidebar.tsx`

**Estructura Jerárquica:**

El menú cambia según rol del usuario:

**Para USER (Reporter):**

- Dashboard (con subitems: Estadísticas, Documentos Cargados, Situación de Pago)
- Mis Gastos
- Reportes
- Configuración

**Para APPROVER (Nivel 1):**

- Dashboard (cambios según nivel)
- Aprobaciones Pendientes
- Historial de Aprobaciones
- Reportes
- Configuración

**Para COMPANY_APPROVER (Nivel 3):**

- Dashboard
- Aprobaciones por Empresa
- Reportes Ejecutivos
- Gestión de Usuarios
- Configuración

**Componentes UI:**

- SidebarMenu: Lista principal
- Collapsible: Menú desplegable con subitems
- SidebarMenuButton: Items de menú
- NavUser: Footer con avatar y logout

**Icono de Cada Item:**

- Dashboard: LayoutDashboard
- Gastos: BookPlus
- Reportes: FileText
- Aprobaciones: Waypoints
- Usuarios: Users
- Configuración: Settings2
- Y más según contexto

**Estados:**

- ACTIVE: Highlightado (bg-teal-500, text white)
- HOVER: Subtle background change
- COLLAPSED: Solo iconos visibles

---

### 3.4 Tablas y Componentes Repetitivos

**Componente Base:** `src/components/defaultDataGridTable.tsx`

**Funcionalidades:**

1. **Columnas Dinámicas**

   - Array de objetos: `{field, headerName, width/flex, renderCell, sortable, type}`
   - `field`: Clave del objeto de datos
   - `renderCell`: Custom render (ej: badges, botones)
   - `type`: boolean, string, number (render automático)

2. **Paginación**

   - Seleccionable: 5, 10, 20, etc (configurable)
   - Botones: Previous, Next
   - Mostrar: "Página X de Y"
   - Opción de deshabilitar

3. **Checkboxes**

   - Select/Deselect individual
   - Select/Deselect todos en página
   - Array de rowIds seleccionados

4. **Click en Fila**

   - Callback `onRowClick(row)`
   - Usado para abrir detalles o editar

5. **Renderizado Custom**
   - Boolean: CheckCircle (verde) / XCircle (rojo)
   - Badge: Status colors (pending, approved, rejected, etc)
   - Botones: Acciones inline

**Props Configuration:**

- `columns: Column[]`
- `rows: any[]`
- `pageSizeOptions?: [5, 10]`
- `checkboxSelection?: boolean`
- `onRowClick?: (row) => void`
- `disablePagination?: boolean`

---

### 3.5 Filtros, Buscadores y Búsqueda

**Componentes Utilizados:**

1. **Input Search** (`src/components/defaultInput.tsx`)

   - Placeholder traducible
   - OnChange handler debounceado (500ms)
   - Limpiar con X button
   - Busca en múltiples campos

2. **State Filter** (`src/components/state-filter.tsx`)

   - Dropdown multi-select
   - Opciones: PENDING, APPROVED, REJECTED, SAVED
   - Checkbox para cada estado
   - Mostrar count de items por estado

3. **Select Filter** (`src/components/defaultSelect.tsx`)

   - Dropdown single-select
   - Por categoría, empresa, centro de costo, etc
   - Mostrar placeholder "Todas"

4. **Date Range Filter**
   - Input type date o date picker
   - Rango: From - To
   - Clear button

**Uso en Dashboard:**

```
[Search Input] [State Filter] [Other Filters] [Export Button]
[DataGridTable con datos filtrados]
```

**Lógica de Filtrado:**

1. Usuario ingresa criterio en input/select
2. onChange dispara handler
3. Handler actualiza state local
4. Estado se aplica a `Array.filter()` para reducir rows
5. Tabla se re-renderiza con datos filtrados
6. Paginación se resetea a página 1

**Debounce Search:**

- Evita requests por cada keystroke
- Wait 500ms después de último keystroke
- Luego ejecuta búsqueda

---

### 3.6 Modal y Dialogs

**Framework:** Radix UI Dialog + Shadcn/ui Modal

**Tipos de Modales:**

1. **CreateExpense** - Crear nuevo gasto

   - Abierto desde: Botón en header o sidebar
   - Contiene: Form para ingresar datos

2. **ApprovalConfirmation** - Confirmar aprobación/rechazo

   - Abierto desde: Click en botón "Aprobar/Rechazar"
   - Contiene: Textarea para comentarios, botones Confirmar/Cancelar

3. **DeleteConfirmation** - Confirmar eliminación

   - Abierto desde: Botón eliminar
   - Contiene: Mensaje advertencia, botones Si/No

4. **Details** - Ver detalles de documento
   - Abierto desde: Click en fila de tabla
   - Contiene: Información completa, adjuntos, historial

**Patrón Estándar:**

```
open (boolean): Controla visibilidad
setOpen (function): Update estado
Header: Título
Content: Formulario o información
Footer: Botones de acción (Cancel, Save/Submit)
```

**Cierre:**

- Click en X (close button)
- Click en Cancel
- Click fuera del modal (backdrop)
- Submit exitoso

---

### 3.7 Indicadores y Badges

**Badge States** (`src/components/status-badge.tsx`):

| Estado   | Color        | Uso                   |
| -------- | ------------ | --------------------- |
| PENDING  | Amarillo     | Esperando acción      |
| APPROVED | Verde        | Aprobado exitosamente |
| REJECTED | Rojo         | Rechazado/Denegado    |
| SAVED    | Gris         | Borrador/Sin enviar   |
| PAID     | Verde oscuro | Pagado                |

**Badge Usage:**

- Mostrar estado de documento en tabla
- Mostrar categoría/tipo
- Mostrar etiqueta

---

## Resumen - Punto 3

| Componente               | Ubicación                | Función                                  |
| ------------------------ | ------------------------ | ---------------------------------------- |
| **MainLayout**           | layout/main-layout.tsx   | Container principal con sidebar + header |
| **SiteHeader**           | site-header.tsx          | Barra superior con título y botones      |
| **AppSidebar**           | app-sidebar.tsx          | Menú lateral jerárquico por rol          |
| **DefaultDataGridTable** | defaultDataGridTable.tsx | Tabla reutilizable con paginación        |
| **Input Search**         | defaultInput.tsx         | Búsqueda en tiempo real                  |
| **State Filter**         | state-filter.tsx         | Multi-select de estados                  |
| **Modal Dialog**         | Radix UI                 | Pop-ups para acciones                    |
| **StatusBadge**          | status-badge.tsx         | Indicadores de estado coloreados         |

---

## 4. Dashboard / Pantalla de Inicio

### 4.1 Indicadores Principales

**Ubicación:** `src/app/web/page.tsx`

**Componentes KPI (Key Performance Indicators):**

El dashboard muestra tarjetas con métricas resumidas:

1. **Gastos por Categoría**

   - Gráfico de barras (ChartBarMixed)
   - Eje X: Categorías (Viajes, Dietas, Comidas, etc)
   - Eje Y: Monto en USD
   - Período: Mes actual
   - Mostrar total y promedio

2. **Gastos Totales - Viajes**

   - Monto: $XXX.XX
   - Trending: +15% vs mes anterior (con icono up/down)
   - Card responsive

3. **Gastos Totales - Per Diem**

   - Monto: $XXX.XX
   - Trending: +8% vs mes anterior
   - Card responsive

4. **Distribución de Emisiones (Pie Chart)**

   - ChartPie reutilizable
   - Mostrar porcentajes por categoría
   - Colores distintos por segmento
   - Período: Mes actual

5. **Estadísticas Generales**
   - Total de documentos
   - Documentos pendientes de aprobación
   - Documentos aprobados
   - Documentos rechazados

**Hook:** `useDashboard()`

- Fetch data desde API `/dashboard/`
- Caché los datos
- Proporciona estado: loading, error, dashboardData
- Incluye métodos para refrescar datos

---

### 4.2 Secciones Destacadas

**Tabla 1: Gastos Cargados**

| Columna     | Tipo   | Función                            |
| ----------- | ------ | ---------------------------------- |
| Fecha       | Date   | Cuándo se creó                     |
| Descripción | String | Nombre/título del gasto            |
| Categoría   | Badge  | Viajes, Dietas, etc (color)        |
| Monto       | Number | USD con 2 decimales                |
| Estado      | Badge  | PENDING, APPROVED, REJECTED, SAVED |

**Funcionalidades:**

- Click en fila → Abre modal de detalles
- Paginación: 5 ó 10 filas por página
- Búsqueda: Filtrar por descripción/fecha
- Estado Filter: Seleccionar múltiples estados
- Mostrar "No data" si vacío

**Tabla 2: Situación de Pago**

| Columna        | Tipo   | Función                      |
| -------------- | ------ | ---------------------------- |
| Fecha          | Date   | Cuándo se procesó            |
| Descripción    | String | Nombre/título                |
| Categoría      | Badge  | Clasificación                |
| Monto          | Number | USD con 2 decimales          |
| Situación Pago | Badge  | Paid (verde), Pending (gris) |

**Funcionalidades:**

- Similar a tabla de gastos
- Filtrar por: Pagado/Pendiente
- Click para ver detalles de transferencia

---

### 4.3 Accesos Rápidos

**Ubicación:** Top header + Sidebar

**Botón Principal: "Subir Gasto"**

- Ubicación: Top-right del header
- Color: Primary (Teal)
- Función: Abre modal CreateExpense
- Siempre visible

**Botón Secundario: "Dashboard de Aprobador"**

- Ubicación: Top-right del header (si rol es APPROVER)
- Color: Secondary
- Función: Navega a `/web/appraisal`
- Solo visible para roles APPROVER/COMPANY_APPROVER

**Sidebar Navigation:**

- Dashboard → Link a `/web`
- Mis Gastos → Link a `/web/expenses`
- Reportes → Link a `/web/expenses/reports`
- Configuración → Link a `/web/settings`

---

### 4.4 Carga de Datos

**Hook Principal:** `useDashboard()`

**Flujo:**

1. Component mount → useEffect dispara fetchDashboardData()
2. setLoading(true)
3. DashboardRepository.getDashboardData()
   - GET `/api/dashboard/`
   - Incluye token en header
4. Backend retorna: `{barChartData, pieChartData, expenseData, paymentData, stats}`
5. Procesar datos:
   - Agregar colores a gráficos (CHART_COLORS array)
   - Generar config para Recharts
   - Transformar datos a formato tabla
6. setDashboardData(enhancedData)
7. setLoading(false)

**Manejo de Errores:**

- Si fetch falla: setError(message)
- Mostrar: Icon ban + mensaje de error
- Botón retry para refrescar

**Optimizaciones:**

- useMemo para DashboardRepository (instancia única)
- useCallback para fetchDashboardData (evita recreación)
- Caché de datos en estado (evita refetch innecesarios)
- Debounce en filtros

---

### 4.5 Filtrado y Búsqueda en Dashboard

**Search Term (Debounceado):**

- Input busca en todos los campos del expense
- Delay: 500ms
- Reset paginación a página 1

**State Filter:**

- Multi-select checkboxes
- Opciones: SAVED, PENDING, APPROVED, REJECTED
- Por defecto: todos checked
- Mostrar count de items por estado

**Aplicación de Filtros:**

```
filteredData = allData
  .filter(item => selectedStates.includes(item.status))
  .filter(item => item.description.includes(searchTerm))
```

---

### 4.6 Gráficos y Visualización

**ChartBarMixed** (`src/components/chart-bar-stacked.tsx`)

- Gráfico de barras apiladas
- Múltiples series (si hay subcategorías)
- Tooltip al hover
- Responsive a ancho del contenedor

**ChartPie** (`src/components/chart-pie-interactive.tsx`)

- Pie chart con leyenda
- Colores CSS variables (--chart-1 a --chart-5)
- Mostrar porcentaje
- Click legend para toggle series

**Recharts Configuration:**

- Ejes con labels
- Grid background
- Tooltip con formato
- Legend con iconos

---

### 4.7 Estados de Carga

**Loading:**

- Mostrar: CircularProgress (Material-UI)
- Centrado en la página
- No bloquea header/sidebar

**Error:**

- Mostrar: Ban icon + mensaje de error
- Mensaje i18n traducido
- Botón "Reintentar"

**Empty State:**

- "No hay datos disponibles"
- Mostrar en tablas vacías
- Sugerir: "Carga tu primer gasto"

**Success:**

- Datos mostrados normalmente
- Sin mensajes visibles

---

### 4.8 Responsividad

**Mobile (< 640px):**

- Gráficos: 100% width
- Tablas: Scroll horizontal
- KPI cards: Stack vertical
- Header: Collapse title si es long

**Tablet (640px - 1024px):**

- 2 columnas de gráficos/cards
- Tablas: 5 filas por página

**Desktop (> 1024px):**

- 3 columnas layout posible
- Tablas: 10 filas por página
- Sidebar: Siempre visible

---

## Resumen - Punto 4

| Elemento         | Detalles                                            |
| ---------------- | --------------------------------------------------- |
| **KPIs**         | 4 métricas: Viajes, Per Diem, Total, Trending       |
| **Gráficos**     | Bar chart + Pie chart                               |
| **Tabla Gastos** | 5 columnas, paginación, búsqueda, filtro estado     |
| **Tabla Pagos**  | 5 columnas, paginación, filtro estado               |
| **Hook**         | useDashboard() con fetch, caché, error handling     |
| **Botones**      | "Subir Gasto" + "Dashboard Aprobador" (condicional) |
| **Carga**        | Loading spinner, Error message, Empty state         |
| **Responsive**   | Mobile-first, adapta a todos los breakpoints        |

---

## 5. Módulo Principal (Documentos / Gastos)

### 5.1 Crear Nuevo Documento

**Ubicación:** Modal `src/components/modals/create-expense.tsx`

**Activación:**

- Click botón "Subir Gasto" (header)
- Click botón "Nuevo Documento" (sidebar)
- Abre Dialog/Modal

**Opciones en Modal:**

1. **Crear Nuevo Reporte**

   - Input: Título del reporte
   - Descripción traducible
   - Submit → Navega a `/web/expenses/reports/new`
   - Crea documento draft

2. **Agregar a Reporte Existente**
   - Dropdown: Seleccionar reporte anterior
   - Submit → Navega al reporte y agrega item

**Flujo:**

1. Usuario selecciona opción
2. Completa título (si es nuevo)
3. Click "Crear" → setReportTitle(title) en Zustand
4. Redirige a página de edición
5. Página prefllena con el título

---

### 5.2 Ver Listado de Documentos

**Ubicación:** `src/app/web/expenses/page.tsx`

**Estructura:**

El listado muestra documentos agrupados por tipo:

1. **Gastos (Expenses)**

   - Fecha del gasto
   - Descripción
   - Monto (USD)
   - Estado

2. **Viajes (Travels)**

   - Origen/Destino
   - Fecha inicio/fin
   - Monto total
   - Estado

3. **Per Diem (Dietas)**
   - Período
   - Cantidad de días
   - Monto por día
   - Estado

**Visualización por Tipo:**

Cada tipo tiene color de fondo y borde distintivo:

- Gastos: Fondo gris claro, borde gris
- Viajes: Fondo azul claro, borde azul
- Per Diem: Fondo verde claro, borde verde

**Ícono por Tipo:**

- Gastos: FileStack
- Viajes: Plane
- Per Diem: Wallet

---

### 5.3 Filtrar Documentos

**Ubicación:** Top de `expenses/page.tsx`

**Filtros Disponibles:**

1. **Por Estado**

   - Componente: StateFilterBackend
   - Opciones: SAVED, PENDING, APPROVED, REJECTED
   - Multi-select con checkboxes
   - Mostrar count de items

2. **Por Tipo**

   - Dropdown: Expenses, Travels, Per Diem
   - Select único
   - "Todos los tipos" por defecto

3. **Búsqueda**

   - Input text
   - Busca en descripción/título
   - Debounceado 500ms
   - Limpiador X

4. **Por Rango de Fecha**
   - Date picker: From - To
   - Opcional
   - Reset button

**Hook:** `useItems()`

- Fetch todas los documentos del usuario
- Aplica filtros
- Retorna: filteredItems, loading, error
- Caché en Zustand

---

### 5.4 Ver Detalle

**Ubicación:** Modal `src/components/modals/details-approver.tsx` o drawer

**Activación:**

- Click en documento/item
- Abre Drawer o Modal con detalles completos

**Información Mostrada:**

**Encabezado:**

- Tipo de documento (Gasto/Viaje/Per Diem)
- ID del documento
- Estado (badge coloreado)

**Contenido:**

Para **Gastos:**

- Fecha del gasto
- Descripción detallada
- Categoría
- Monto USD
- Moneda original (si aplica)
- Impuesto/IVA
- Total
- Centro de costo
- Adjuntos (PDFs, imágenes)

Para **Viajes:**

- Origen/Destino
- Fecha inicio/fin
- Propósito
- Transporte (Aéreo, Auto, etc)
- Monto total
- Km recorridos (si aplica)
- Adjuntos (boletos, facturas)

Para **Per Diem:**

- Período (fechas)
- Cantidad de días
- Monto por día
- Total
- Justificación
- Adjuntos

**Footer:**

- Historial de cambios/comentarios (si aplica)
- Botones: Editar, Descargar, Cerrar

---

### 5.5 Editar Documento

**Ubicación:** `/web/expenses/reports/[id]/edit` o modal

**Estados Permitidos:**

- SAVED: Siempre editable
- PENDING/APPROVED/REJECTED: No editable, solo lectura
- (Solo propietario puede editar)

**Formulario Edición:**

**Para Gastos:**

- Fecha (date input)
- Descripción (text input)
- Categoría (select dropdown)
- Monto (number input)
- Moneda (select)
- Impuesto % (number)
- Centro de costo (select)
- Adjuntos (drag-drop file upload)

**Para Viajes:**

- Origen (input/autocomplete)
- Destino (input/autocomplete)
- Fecha inicio (date)
- Fecha fin (date)
- Propósito (textarea)
- Transporte (select)
- Monto (number)
- Adjuntos (file upload)

**Para Per Diem:**

- Fecha inicio (date)
- Fecha fin (date)
- Monto por día (number)
- Justificación (textarea)
- Adjuntos (file upload)

**Validaciones:**

- Campos requeridos validados antes de submit
- Monto positivo
- Fechas válidas
- Al menos 1 adjunto para ciertos tipos

**Botones:**

- Guardar (Guardar como SAVED)
- Enviar a Aprobación (cambiar a PENDING)
- Cancelar (discard changes)

---

### 5.6 Eliminar o Archivar

**Ubicación:** Botón en detalles/listado

**Eliminar:**

- Solo permite si estado es SAVED
- Abre confirmación: "¿Seguro que deseas eliminar?"
- DELETE `/expenses/{id}/`
- Remueve de lista

**Archivar:**

- Disponible en APPROVED/REJECTED
- PATCH `/expenses/{id}/` con `archived=true`
- Mueve a sección archivada
- No se muestra en listado principal por defecto

---

### 5.7 Subir Archivos (PDF, Imágenes)

**Componente:** Drag-drop zone o input file

**Soportados:**

- PDF
- JPG/JPEG
- PNG
- Máximo 5MB por archivo
- Máximo 10 archivos por documento

**Upload Process:**

1. Usuario arrastra o selecciona archivos
2. Validación cliente:
   - Tipo MIME correcto
   - Tamaño < 5MB
   - Mostrar errores en rojo
3. Preview de archivos antes de submit
4. Botón "Eliminar" por cada archivo
5. Submit formulario → POST multipart/form-data
6. Backend guarda en S3
7. Mostrar progress bar
8. Éxito → Mostrar URL o thumbnail

**Errores Posibles:**

- Archivo muy grande
- Formato no soportado
- Upload interrumpido (retry)
- Network error

**Visualización:**

- Lista de archivos cargados
- Icono por tipo (PDF, image)
- Nombre y tamaño
- Link para descargar
- Botón X para eliminar

---

### 5.8 Estados del Documento

**Máquina de Estados:**

```
SAVED (Borrador)
  ↓ (Click "Enviar a Aprobación")
PENDING (Esperando aprobación L1)
  ↓ (Aprobador L1 aprueba)
PENDING_L2 (Esperando aprobación L2)
  ↓ (Aprobador L2 aprueba)
PENDING_L3 (Esperando aprobación L3)
  ↓ (Aprobador L3 aprueba)
APPROVED (Aprobado completamente)
  ↓ (Opcional: Pagar)
PAID (Pagado)

REJECTED (En cualquier nivel)
  ↓ (Usuario puede editar y reenviarlo)
  PENDING (Resend to approval)
```

**Badges por Estado:**

- SAVED: Gris (Borrador)
- PENDING: Amarillo (En proceso)
- APPROVED: Verde (Aprobado)
- REJECTED: Rojo (Rechazado)
- PAID: Verde oscuro (Pagado)

---

## Resumen - Punto 5

| Función         | Detalles                                      |
| --------------- | --------------------------------------------- |
| **Crear**       | Modal con opción: Nuevo o Agregar a existente |
| **Listar**      | Grouped por tipo, con colores y iconos        |
| **Filtrar**     | Estado, Tipo, Búsqueda, Rango de fecha        |
| **Ver Detalle** | Drawer/Modal con info completa y historial    |
| **Editar**      | Formulario con validaciones, solo si SAVED    |
| **Eliminar**    | Confirmación, solo si SAVED                   |
| **Archivar**    | Soft delete, para APPROVED/REJECTED           |
| **Archivos**    | Drag-drop, 5MB, soporta PDF/JPG/PNG           |
| **Estados**     | 6 estados principales con transiciones        |

---

## 6. Módulo de Aprobaciones

### 6.1 Ver Documentos Pendientes de Aprobación

**Ubicación:** `src/app/web/appraisal/pending/page.tsx`

**Acceso:**

- Rutas según rol:
  - `/web/appraisal-user` - Level 1 approvals
  - `/web/appraisal-ceco` - Level 2 approvals (Cost Center)
  - `/web/appraisal-company` - Level 3 approvals (Company)

**Visualización:**

El listado agrupa documentos por usuario/empleado:

1. **Acordeón por Usuario**

   - Nombre del empleado
   - Rol/Departamento
   - Contador: "5 documentos pendientes"
   - Estado: Expandible/Colapsible

2. **Items dentro de Acordeón**

   - Por tipo: Gastos, Viajes, Per Diem
   - Información resumida:
     - Descripción
     - Monto
     - Fecha
     - Estado actual
   - Color por tipo (gris/azul/verde)

3. **Indicadores Visuales**
   - Ícono por tipo: FileStack, Plane, Wallet
   - Badge de estado: PENDING, IN_REVIEW, etc
   - Botones: Ver, Aprobar, Rechazar

**Hook:** `useAppraisalPendingDocuments()`

- Fetch `/api/appraisals/pending/`
- Filtro automático por nivel del usuario
- Retorna: documents, loading, error, count
- Cachea en Zustand
- Método refetch: `fetchDocuments()`

**Funcionalidades:**

- Paginación (10-20 items por página)
- Búsqueda por nombre de empleado
- Filtro por tipo de documento
- Ordenar por fecha/monto

---

### 6.2 Aprobar o Rechazar

**Ubicación:** Modal `src/components/modals/state-modal.tsx`

**Flujo Básico:**

1. Usuario hace click en "Aprobar" o "Rechazar"
2. Abre Dialog/Modal de confirmación
3. Mostrar:

   - Información del documento
   - Monto a autorizar
   - Datos del empleado
   - Nivel de aprobación actual

4. **Si Aprueba:**

   - PATCH `/api/appraisals/{document_id}/approve/`
   - Body: `{level, comments}`
   - Estado pasa a siguiente nivel o APPROVED si es último

5. **Si Rechaza:**
   - PATCH `/api/appraisals/{document_id}/reject/`
   - Body: `{level, reason}`
   - Estado cambia a REJECTED
   - Notifica al usuario original

**Validaciones:**

- Aprobador debe tener permiso para ese nivel
- No puede aprobar documento ya aprobado
- Motivo de rechazo es obligatorio

**Estados Modal:**

- IDLE: Esperando acción
- SUBMITTING: Petición en curso
- SUCCESS: Mostrando mensaje de éxito
- ERROR: Mostrando error

---

### 6.3 Añadir Comentarios

**Ubicación:** Textarea en modal de aprobación

**Funcionalidad:**

1. Campo textarea opcional al aprobar
2. Comentarios se guardan con la transacción de aprobación
3. Caracteres máximo: 500
4. Contador: "X/500 caracteres"

**Flujo:**

1. Usuario ingresa comentario (opcional)
2. Submit aprobación
3. Backend guarda comment + approval en ApprovalHistory
4. Usuario original ve comentario en detalles

**Contexto de Comentarios:**

- Quién comentó (approver name)
- Cuándo (timestamp)
- Qué comentó (texto)
- Acción asociada (approved, rejected)

---

### 6.4 Ver Historial de Aprobaciones

**Ubicación:** Drawer/Modal al ver detalles de documento

**Información Mostrada:**

Por cada nivel de aprobación:

1. **Nivel 1 (User Approver)**

   - Aprobador: Nombre + Email
   - Fecha/Hora de aprobación
   - Estado: Aprobado ✓ / Rechazado ✗ / Pendiente ⏳
   - Comentarios (si hay)

2. **Nivel 2 (Cost Center Approver)**

   - Aprobador: Nombre + Email
   - Fecha/Hora
   - Estado
   - Comentarios

3. **Nivel 3 (Company Approver)**
   - Aprobador: Nombre + Email
   - Fecha/Hora
   - Estado
   - Comentarios

**Timeline Visual:**

- Línea vertical conectando niveles
- Ícono verde (✓) para aprobado
- Ícono rojo (✗) para rechazado
- Ícono gris (⏳) para pendiente

---

### 6.5 Restricciones por Rol

**Permisos por Nivel:**

| Acción            | User Approver | Cost Center | Company Approver |
| ----------------- | ------------- | ----------- | ---------------- |
| Ver pendientes L1 | ✅            | ✅          | ✅               |
| Ver pendientes L2 | ❌            | ✅          | ✅               |
| Ver pendientes L3 | ❌            | ❌          | ✅               |
| Aprobar L1        | ✅            | ❌          | ❌               |
| Aprobar L2        | ❌            | ✅          | ❌               |
| Aprobar L3        | ❌            | ❌          | ✅               |
| Rechazar          | ✅ (L1)       | ✅ (L2)     | ✅ (L3)          |
| Ver historial     | ✅            | ✅          | ✅               |

**Validación Backend:**

- Se verifica rol del usuario en cada request
- No permite saltar niveles
- Tokens inválidos → 401 Unauthorized

**En Frontend:**

- Botón "Aprobar" deshabilitado si no tiene permiso
- Ocultar secciones no permitidas
- Mostrar mensaje "No tienes permiso para aprobar este nivel"

---

### 6.6 Estados Visuales del Documento

**Badges por Estado en Listado:**

| Estado     | Color      | Ícono | Significado            |
| ---------- | ---------- | ----- | ---------------------- |
| PENDING_L1 | Amarillo   | ⏳    | Esperando Nivel 1      |
| PENDING_L2 | Naranja    | ⏳    | Esperando Nivel 2      |
| PENDING_L3 | Rojo claro | ⏳    | Esperando Nivel 3      |
| APPROVED   | Verde      | ✓     | Completamente aprobado |
| REJECTED   | Rojo       | ✗     | Rechazado              |
| IN_REVIEW  | Azul       | 👁️    | Bajo revisión          |

**Información Adicional:**

- Mostrar en qué nivel está actualmente
- Mostrar quién aprobó anteriormente
- Mostrar fecha de la última acción

---

### 6.7 Dashboard de Aprobador

**Ubicación:** `/web/appraisal/reports` o `/web/appraisal-*/dashboard`

**Métricas KPI:**

1. **Pendientes de Aprobar**

   - Contador total
   - Desglose por tipo (Gastos, Viajes, Per Diem)

2. **Aprobado Este Mes**

   - Cantidad de documentos
   - Monto total

3. **Rechazado Este Mes**

   - Cantidad de documentos
   - Motivos frecuentes

4. **Tiempo Promedio de Aprobación**
   - En horas
   - Comparar vs promedio

**Gráficos:**

1. **Documentos Pendientes por Empleado**

   - Gráfico de barras horizontal
   - Top 5 empleados con más pendientes

2. **Aprobaciones por Día**

   - Gráfico de líneas (últimos 30 días)
   - Mostrar tendencia

3. **Motivos de Rechazo**
   - Pie chart con razones frecuentes
   - Top 3: Justificación insuficiente, Excede presupuesto, Documentación incompleta

---

### 6.8 Acciones en Lote (Bulk)

**Ubicación:** Si hay múltiples documentos seleccionados

**Funcionalidades Futuras:**

- [ ] Seleccionar múltiples documentos
- [ ] Checkbox para "Select all on page"
- [ ] Botón "Aprobar Seleccionados"
- [ ] Botón "Rechazar Seleccionados"
- [ ] Modal de confirmación en lote
- [ ] Procesar en background (async)

---

## Resumen - Punto 6

| Función            | Detalles                                        |
| ------------------ | ----------------------------------------------- |
| **Ver Pendientes** | Acordeón por usuario, items agrupados por tipo  |
| **Aprobar**        | Modal con confirmación, actualiza estado        |
| **Rechazar**       | Modal con razón obligatoria                     |
| **Comentarios**    | Textarea opcional, máx 500 caracteres           |
| **Historial**      | Timeline visual con todos los niveles           |
| **Restricciones**  | Por rol: L1, L2, L3 con permisos específicos    |
| **Estados**        | PENDING_L1/L2/L3, APPROVED, REJECTED, IN_REVIEW |
| **Dashboard**      | KPIs + Gráficos de aprobaciones                 |
| **Bulk Actions**   | Futuro: aprobar/rechazar múltiples              |

---

## 7. Notificaciones

### 7.1 Sistema de Notificaciones (Toast)

**Librería:** Sonner 0.10.3

**Ubicación del Toaster:**

- Componente: `src/components/ui/sonner.tsx`
- Integración: `src/app/layout.tsx` (importa Toaster)

**Configuración:**

```
- Posición: Esquina inferior derecha (default)
- Tema: Sincronizado con Light/Dark mode (next-themes)
- Duración: 4 segundos (default)
- Estilo: Tailwind + Radix UI colors
```

---

### 7.2 Tipos de Notificaciones

**1. Success Toast**

Usado para: Crear, actualizar, eliminar, aprobar, guardar

```
toast.success("Documento guardado exitosamente")
toast.success("Aprobación completada")
```

Características:

- Ícono: Checkmark verde
- Color de fondo: Verde claro
- Desaparece automáticamente en 4s

**2. Error Toast**

Usado para: Fallos en API, validación, permisos

```
toast.error("Error: No se pudo guardar el documento")
toast.error("Acceso denegado")
```

Características:

- Ícono: X roja
- Color de fondo: Rojo claro
- Puede contener detalles del error
- Desaparece en 5s (más tiempo que success)

**3. Loading Toast**

Usado para: Operaciones asíncronas en progreso

```
toast.loading("Guardando documento...")
toast.loading("Procesando aprobación...")
```

Características:

- Ícono: Spinner animado
- No desaparece automáticamente
- Se reemplaza cuando termina la operación

**4. Promise Toast**

Usado para: Operaciones que pueden tener resultado success/error

```
toast.promise(
  fetchData(),
  {
    loading: "Cargando...",
    success: "Datos cargados",
    error: "Error al cargar"
  }
)
```

Características:

- Muestra estado loading → success/error automáticamente
- Ideal para promesas
- Usado en Data Table para guardar cambios

**5. Info Toast**

Usado para: Mensajes informativos, alertas no críticas

```
toast.info("Documento expirado, por favor recargue")
```

---

### 7.3 Implementación en Componentes

**En Servicios (API calls):**

```tsx
import { toast } from "sonner";

export const saveDocument = async (data) => {
  try {
    const response = await apiClient.post("/documents", data);
    toast.success("Documento guardado");
    return response.data;
  } catch (error) {
    toast.error(`Error: ${error.message}`);
    throw error;
  }
};
```

**En Componentes (Acciones de usuario):**

```tsx
const handleApprove = async () => {
  try {
    const result = await approveDocument(docId);
    toast.success("Documento aprobado");
    refetch();
  } catch (error) {
    toast.error("No se pudo aprobar el documento");
  }
};
```

**En Data Tables (Operaciones inline):**

- Click en "Guardar" en tabla
- Muestra: `toast.loading("Saving...")`
- Si éxito: `toast.success("Done")`
- Si error: `toast.error("Error")`

---

### 7.4 Mensajes i18n

**Ubicación:** `src/locales/es.json` (y otros idiomas)

**Claves comunes:**

```json
{
  "saved": "Guardado exitosamente",
  "error": "Error",
  "errorSaving": "Error al guardar",
  "loading": "Cargando...",
  "noPermission": "No tienes permiso para realizar esta acción",
  "documentDeleted": "Documento eliminado",
  "documentApproved": "Documento aprobado",
  "documentRejected": "Documento rechazado",
  "invalidData": "Los datos ingresados son inválidos"
}
```

**Uso en toasts:**

```tsx
import { useTranslation } from "react-i18next";

const { t } = useTranslation();

toast.error(t("errorSaving"));
toast.success(t("saved"));
```

---

### 7.5 Estilo y Personalización

**Clases Tailwind aplicadas (sonner.tsx):**

| Elemento      | Clases                                                             |
| ------------- | ------------------------------------------------------------------ |
| Toast base    | `group toast group-[.toaster]:bg-background ...`                   |
| Descripción   | `group-[.toast]:text-muted-foreground`                             |
| Action button | `group-[.toast]:bg-primary group-[.toast]:text-primary-foreground` |
| Cancel button | `group-[.toast]:bg-muted group-[.toast]:text-muted-foreground`     |

**Colores por tipo (auto-aplicados):**

- Success: Verde (primary)
- Error: Rojo (destructive)
- Info: Azul (info)
- Warning: Naranja (warning)
- Loading: Gris (muted)

---

### 7.6 Casos de Uso Reales

**1. Crear Documento**

```
Usuario click "Crear" → Modal form → Submit
Toast: "loading: Guardando documento..."
Response success → toast.success("Documento guardado")
Response error → toast.error("Error: " + error.message)
```

**2. Aprobar Documento**

```
Usuario click "Aprobar" → Modal confirmación → Submit
Toast.loading("Procesando aprobación...")
Response success → toast.success("Aprobado")
Response error → toast.error("No autorizado")
```

**3. Cambiar Filtros**

```
Usuario selecciona filtro → fetch new data
Toast.loading("Filtrando...")
Response → toast.success("Aplicado")
```

**4. Error de Autenticación**

```
API returns 401 Unauthorized
Toast.error("Sesión expirada")
Redirect a /login
```

**5. Validación de Formulario**

```
Usuario submit sin llenar campos obligatorios
Toast.error("Completa todos los campos requeridos")
NO se envía al servidor
```

---

### 7.7 Duraciones y Comportamiento

| Tipo    | Duración | Desaparece Auto     | Sonido |
| ------- | -------- | ------------------- | ------ |
| Success | 4s       | ✅ Sí               | No     |
| Error   | 5s       | ✅ Sí               | No     |
| Info    | 4s       | ✅ Sí               | No     |
| Loading | ∞        | ❌ No (manual)      | No     |
| Promise | Auto     | ✅ (cuando termina) | No     |

**Comportamiento especial:**

- Múltiples toasts se apilan verticalmente
- Click en toast lo cierra inmediatamente
- Action button (si existe) ejecuta callback
- Keyboard: ESC cierra todos los toasts

---

## Resumen - Punto 7

| Función       | Tipo         | Uso                                               |
| ------------- | ------------ | ------------------------------------------------- |
| **Success**   | Sonner       | Operaciones completadas (crear, guardar, aprobar) |
| **Error**     | Sonner       | Fallos en API, validación, permisos               |
| **Loading**   | Sonner       | Operaciones en progreso (largo tiempo)            |
| **Promise**   | Sonner       | Async con resultado auto (success/error)          |
| **Info**      | Sonner       | Alertas no críticas, mensajes informativos        |
| **i18n**      | i18next      | Mensajes traducibles en 4 idiomas                 |
| **Dark Mode** | next-themes  | Automático Light/Dark sincronizado                |
| **Posición**  | Bottom-right | Esquina inferior derecha (default)                |

---

## 8. Perfil y Configuración

### 8.1 Acceso a Perfil

**Ubicación:** `/web/settings`

**Cómo acceder:**

1. Click en Avatar (esquina inferior izquierda en Sidebar)
2. Click en "Account" / "Cuenta" (icono UserCircle)
3. Redirecciona a `/web/settings`

**Componentes:**

- `src/app/web/settings/page.tsx` - Página principal
- `src/components/form/profile.tsx` - Formulario de edición
- `src/components/nav-user.tsx` - Menú desplegable del usuario

---

### 8.2 Información de Perfil

**Datos Mostrados (Read-only):**

| Campo                  | Tipo      | Descripción                           |
| ---------------------- | --------- | ------------------------------------- |
| **Avatar**             | Imagen    | Foto de perfil (grayscale en sidebar) |
| **Username**           | Texto     | Nombre de usuario único               |
| **Email**              | Correo    | Email de cuenta                       |
| **Empresa**            | Texto     | Nombre de la empresa                  |
| **RUT**                | Documento | Identificación fiscal (Chile)         |
| **Último Actualizado** | Fecha     | Cuándo se actualizó el perfil         |

**Endpoint:**

- GET `/app/users/me/` - Obtener datos del usuario actual
- Hook: `useUser()` - Custom hook para fetch automático
- Store: UserContext (React Context API)

---

### 8.3 Editar Perfil

**Formulario Editable:**

1. **Nombre (First Name)**

   - Requerido
   - Máximo 50 caracteres
   - Validación: No vacío

2. **Apellido (Last Name)**

   - Requerido
   - Máximo 50 caracteres
   - Validación: No vacío

3. **Email**

   - Requerido
   - Formato email válido
   - Validación Zod

4. **Teléfono (Phone)**
   - Opcional
   - Formato: +[1-9] con 0-15 dígitos
   - Validación regex internacional

**Validación (Zod Schema):**

```
- first_name: min 1, max 50 chars
- last_name: min 1, max 50 chars
- email: valid email format
- phone: optional, international format
```

**Guardado:**

1. Submit form → `onSubmit()`
2. Button estado: "Guardando..." (spinner)
3. Endpoint: PUT `/app/users/me/profile/`
4. Body: `{first_name, last_name, email, phone}`
5. Response: User actualizado
6. Toast: "Perfil actualizado exitosamente"
7. UI actualiza con nuevos datos

---

### 8.4 Cambiar Contraseña

**Ubicación:** Sección "Seguridad & Privacidad" en settings

**Campos:**

1. **Contraseña Actual**

   - Type: password
   - Requerido para verificación

2. **Nueva Contraseña**

   - Type: password
   - Mínimo 8 caracteres
   - Debe incluir mayúscula, minúscula, número

3. **Confirmar Contraseña**
   - Type: password
   - Debe coincidir con nueva contraseña

**Flujo:**

1. Usuario ingresa 3 contraseñas
2. Submit → Validación Zod
3. POST `/app/users/me/change-password/`
4. Body: `{current_password, new_password, confirm_password}`
5. Si success: Toast.success("Contraseña actualizada")
6. Si error: Toast.error("Contraseña actual incorrecta")

**Restricciones:**

- No puede ser igual a contraseña anterior (backend)
- Token se mantiene (no logout automático)

---

### 8.5 Configuración de Notificaciones

**Ubicación:** Sección "Notificaciones" en settings

**Opciones (Switches):**

| Tipo                    | Estado | Descripción                  |
| ----------------------- | ------ | ---------------------------- |
| **Email Notifications** | ON/OFF | Recibir alertas por correo   |
| **Push Notifications**  | ON/OFF | Notificaciones desktop/móvil |
| **SMS Notifications**   | ON/OFF | Alertas por SMS              |

**Tipos de notificaciones disponibles:**

1. **Documentos pendientes de aprobación**

   - Cuando: Nuevo documento llega para aprobación
   - Si ON: Email + Push

2. **Documento aprobado**

   - Cuando: Tu documento fue aprobado
   - Si ON: Email + Push

3. **Documento rechazado**

   - Cuando: Tu documento fue rechazado
   - Si ON: Email + Push + SMS

4. **Comentarios nuevos**
   - Cuando: Agredan comentario a tu documento
   - Si ON: Email + Push

**Guardado:**

- PATCH `/app/users/me/notifications/`
- Body: `{email: bool, push: bool, sms: bool}`
- Actualización inmediata (sin necesidad de refresh)

---

### 8.6 Apariencia & Tema

**Ubicación:** Sección "Apariencia" en settings

**Opciones de Tema:**

| Opción     | Valor  | Descripción              |
| ---------- | ------ | ------------------------ |
| **Light**  | light  | Modo claro (blanco)      |
| **Dark**   | dark   | Modo oscuro (negro/gris) |
| **System** | system | Sigue preferencia del SO |

**Implementación:**

- Hook: `useTheme()` (next-themes)
- Almacenamiento: localStorage
- Aplicación: Inmediata (sin reload)
- CSS: Tailwind dark: prefix

**Sincronización:**

- Al cambiar tema → Sonner toasts se actualizan
- Sidebar, Header, Content → Todos responden
- Charts (Recharts) → Colores adaptan automáticamente

---

### 8.7 Idioma & Región

**Ubicación:** Sección "Idioma & Región" en settings

**Idiomas Disponibles:**

| Código | Idioma   | Status |
| ------ | -------- | ------ |
| en     | English  | ✅     |
| es     | Español  | ✅     |
| fr     | Français | ✅     |
| de     | Deutsch  | ✅     |

**Timezone:**

| Valor | Descripción                |
| ----- | -------------------------- |
| UTC   | Coordinated Universal Time |
| EST   | Eastern Standard Time      |
| PST   | Pacific Standard Time      |
| CET   | Central European Time      |

**Implementación:**

- Hook: `useTranslation()` (i18next)
- Método: `i18n.changeLanguage(lang)`
- Almacenamiento: localStorage + sessionStorage
- Aplicación: Inmediata, todos los componentes se re-renderizan
- Rutas: Mantienen estado actual

**Impacto de Cambio de Idioma:**

```
Usuario selecciona FR
→ setLanguage("fr")
→ i18n.changeLanguage("fr")
→ Todas las claves t("key") se actualizan
→ LocalStorage: i18nextLng = "fr"
→ Persistente en reload
```

---

### 8.8 Privacidad & Datos

**Ubicación:** Sección "Datos & Almacenamiento" en settings

**Opciones:**

1. **Analytics & Usage Data**

   - Switch: ON/OFF
   - Si ON: Enviar datos de uso anónimos
   - Uso: Mejorar UX
   - Datos enviados:
     - Pantallas visitadas
     - Acciones principales
     - Tiempo en cada página
     - No: Datos personales, documentos, montos

2. **Exportar Datos**

   - Botón: "Export Data"
   - Descarga: JSON con todos tus datos
   - Incluye:
     - Perfil
     - Documentos
     - Historial de aprobaciones
     - Comentarios
   - Formato: YYYY-MM-DD_HH-MM-SS_export.json

3. **Desactivar Cuenta**
   - Botón: "Deactivate Account" (rojo destructivo)
   - Confirmación: Modal requiere contraseña
   - Efecto:
     - Cuenta inactiva (no se elimina)
     - No puedes login
     - Admin puede reactivar
     - Datos permanecen en sistema

---

### 8.9 Seguridad Avanzada

**Ubicación:** Sección "Seguridad & Privacidad" en settings

**Opciones:**

1. **Two-Factor Authentication (2FA)**

   - Switch: ON/OFF
   - Si activa:
     - Login requiere código OTP
     - Codes se envían por email
     - Backup codes: 10 códigos guardables
   - Configuración:
     - Email: Código 6 dígitos (válido 5 min)
     - Authenticator App (futuro): TOTP

2. **Sesiones Activas**

   - Listar todas las sesiones
   - Mostrar: Dispositivo, Ubicación, Última actividad
   - Botón: "Logout from device"
   - Efecto: Invalida token en ese dispositivo

3. **Registro de Actividad**
   - Timeline de logins
   - Mostrar: Fecha, Hora, IP, Dispositivo
   - Detectar accesos sospechosos

---

### 8.10 Estados y Errores

**Estados Posibles:**

| Estado      | Indicador        | Duración            |
| ----------- | ---------------- | ------------------- |
| **Idle**    | Campo habilitado | Esperando           |
| **Saving**  | Spinner          | Mientras POST/PATCH |
| **Success** | Toast verde      | 4s auto-close       |
| **Error**   | Toast rojo       | 5s auto-close       |
| **Loading** | Skeleton/Spinner | Mientras fetch      |

**Errores Comunes:**

| Error                     | Causa               | Solución              |
| ------------------------- | ------------------- | --------------------- |
| **Email ya existe**       | Email duplicado     | Ingresar otro email   |
| **Contraseña incorrecta** | Password actual mal | Verificar CAPS LOCK   |
| **Token expirado**        | Sesión expiró       | Auto-redirect a login |
| **Network error**         | Sin conexión        | Verificar internet    |
| **Validation error**      | Datos inválidos     | Revisar formato       |

---

## Resumen - Punto 8

| Sección            | Función                     | Endpoint                                |
| ------------------ | --------------------------- | --------------------------------------- |
| **Perfil**         | Ver/Editar datos personales | PUT `/app/users/me/profile/`            |
| **Contraseña**     | Cambiar password            | POST `/app/users/me/change-password/`   |
| **Notificaciones** | Email, Push, SMS            | PATCH `/app/users/me/notifications/`    |
| **Apariencia**     | Light/Dark/System           | next-themes localStorage                |
| **Idioma**         | EN, ES, FR, DE              | i18next changeLanguage                  |
| **Datos**          | Exportar, Analítica         | GET `/api/export/`, PATCH `/analytics/` |
| **Seguridad**      | 2FA, Sesiones               | POST `/2fa/enable/`, GET `/sessions/`   |
| **Desactivar**     | Inactivar cuenta            | POST `/users/me/deactivate/`            |

---

## 9. Sección de Administración

### 9.1 Acceso a Admin

**Ubicación:** `/web/admin`

**Requisito:** Rol `COMPANY_ADMIN` o superior

**Cómo acceder:**

1. Logueado como admin
2. Sidebar → Buscar "Admin" (solo visible si rol permite)
3. Menú principal con opciones de administración

**Submódulos Admin:**

- Usuarios (Users)
- Empresas (Companies)
- Proveedores (Suppliers)
- Áreas (Areas)
- Cost Centers (CECO)
- Conceptos de Gasto (Expense Concepts)
- Clases de Documento (Document Classes)
- Impuestos (Taxes)
- Rutas (Routes)
- Perdiems
- Aprobadores Nivel 1 (User Approvers)
- Aprobadores CECO (Cost Center Approvers)
- Aprobadores Empresa (Company Approvers)
- Contabilidad (Accounting)

---

### 9.2 Gestión de Usuarios

**Ubicación:** `/web/admin/users`

**Funcionalidad:**

1. **Listar Usuarios**

   - Tabla con DataGrid (MUI)
   - Columnas: ID, Username, Nombre, Email, RUT, Activo, Teléfono, Empresa, Rol, Área
   - Pagination: 10, 20 items por página
   - Ordenable por todas las columnas

2. **Búsqueda Global**

   - Input search
   - Busca en: Username, Nombre, Email, RUT, Teléfono, Empresa, Rol, Área
   - Real-time filtering (sin delay)

3. **Filtros Dinámicos**

   - **Estado:** Activo / Inactivo (ambos por default)
   - **Rol:** Extraído dinámicamente de usuarios
   - **Empresa:** Extraído dinámicamente de usuarios
   - **Área:** Extraído dinámicamente de usuarios
   - Múltiples selecciones permitidas

4. **Crear Usuario**

   - Botón: "Create New User"
   - Abre Modal: UserDetailsModal
   - Formulario con campos:
     - Username (unique, required)
     - Email (valid, required)
     - Password (required, min 8 chars)
     - First Name, Last Name
     - Phone (optional)
     - RUT (Chile)
     - Empresa (dropdown)
     - Rol (dropdown, options dinámicos)
     - Área (dropdown)
     - Activo (switch)

5. **Editar Usuario**

   - Click en fila → Abre modal con datos pre-llenados
   - Password: Opcional en edición (si vacío, no se actualiza)
   - Cambios: PUT `/api/admin/users/{id}/`
   - Response: Usuario actualizado

6. **Eliminar Usuario**
   - Disponible en modal de edición
   - Confirmación requerida
   - DELETE `/api/admin/users/{id}/`

**Endpoints:**

- GET `/api/admin/users/` - Listar todos
- POST `/api/admin/users/` - Crear
- PUT `/api/admin/users/{id}/` - Actualizar
- DELETE `/api/admin/users/{id}/` - Eliminar
- GET `/api/admin/users/options/` - Roles, Empresas, Áreas disponibles

---

### 9.3 Gestión de Empresas

**Ubicación:** `/web/admin/companies`

**Funcionalidad:**

1. **Listar Empresas**

   - Tabla con DataGrid
   - Columnas: ID, Nombre, Email, Teléfono, Dirección, Divisa Base
   - Filtrable por divisa

2. **Búsqueda**

   - Por nombre, email, teléfono, dirección

3. **Crear/Editar Empresa**

   - Modal: CompanyDetailsModal
   - Campos:
     - Nombre (required)
     - Email (required, valid)
     - Teléfono (optional)
     - Dirección (required)
     - Código (unique identifier)
     - Divisa Base (dropdown, dinámico)
     - Divisas Permitidas (multi-select)
     - Logo (upload image)
     - Contacto Primario (contact person)

4. **Configuración de Divisas**
   - Seleccionar divisa base (USD, EUR, CLP, etc)
   - Seleccionar divisas permitidas para la empresa
   - Tasas de cambio: Automat llenadas o manuales

**Endpoints:**

- GET `/api/admin/companies/` - Listar
- POST `/api/admin/companies/` - Crear
- PUT `/api/admin/companies/{id}/` - Actualizar
- GET `/api/admin/companies/options/` - Divisas disponibles

---

### 9.4 Gestión de Proveedores

**Ubicación:** `/web/admin/suppliers`

**Funcionalidad:**

1. **Listar Proveedores**

   - Tabla con DataGrid
   - Columnas: ID, Nombre, Email, Teléfono, RUT, Empresa, País, Ciudad
   - Filtrable por empresa

2. **Búsqueda**

   - Por nombre, email, RUT, teléfono

3. **Crear/Editar Proveedor**

   - Modal: SupplierDetailsModal
   - Campos:
     - Nombre (required)
     - Email (required, valid)
     - Teléfono (optional)
     - RUT/NIF (required, país-específico)
     - Empresa (dropdown, required)
     - Dirección (required)
     - Ciudad (required)
     - País (dropdown)
     - Tipo Proveedor (dropdown: General, Viajes, Comida, etc)
     - Contacto (nombre contacto)
     - Notas

4. **Validaciones**
   - RUT/NIF único por empresa
   - Email válido
   - Teléfono formato internacional (opcional)

**Endpoints:**

- GET `/api/admin/suppliers/` - Listar
- POST `/api/admin/suppliers/` - Crear
- PUT `/api/admin/suppliers/{id}/` - Actualizar
- DELETE `/api/admin/suppliers/{id}/` - Eliminar

---

### 9.5 Gestión de Conceptos de Gasto

**Ubicación:** `/web/admin/econcepts`

**Funcionalidad:**

1. **Listar Conceptos**

   - Tabla: ID, Nombre, Código, Descripción, Activo
   - Ejemplo: "Comida", "Transporte", "Hotel", "Misc"

2. **Crear/Editar Concepto**

   - Modal: EConceptDetailsModal
   - Campos:
     - Nombre (required)
     - Código (required, unique)
     - Descripción (optional)
     - Activo (switch)
     - Permite adjuntos (switch)
     - Requiere justificación (switch)

3. **Filtros**
   - Activo/Inactivo

**Endpoints:**

- GET `/api/admin/econcepts/` - Listar
- POST `/api/admin/econcepts/` - Crear
- PUT `/api/admin/econcepts/{id}/` - Actualizar

---

### 9.6 Gestión de Cost Centers (CECO)

**Ubicación:** `/web/admin/ceco`

**Funcionalidad:**

1. **Listar Cost Centers**

   - Tabla: ID, Código, Nombre, Empresa, Presupuesto, Usado
   - Barra de progreso: Usado vs Total

2. **Crear/Editar CECO**

   - Modal: CecoDetailsModal
   - Campos:
     - Código CECO (required, unique)
     - Nombre (required)
     - Empresa (dropdown)
     - Presupuesto Anual (número)
     - Responsable (usuario dropdown)
     - Descripción (optional)
     - Activo (switch)

3. **Visualización de Presupuesto**
   - Total presupuesto vs gastado
   - % utilizado con color (rojo si >90%)
   - Proyección a fin de año

**Endpoints:**

- GET `/api/admin/ceco/` - Listar
- POST `/api/admin/ceco/` - Crear
- PUT `/api/admin/ceco/{id}/` - Actualizar

---

### 9.7 Gestión de Áreas

**Ubicación:** `/web/admin/area`

**Funcionalidad:**

1. **Listar Áreas**

   - Tabla: ID, Nombre, Código, Empresa, Descripción

2. **Crear/Editar Área**
   - Modal: AreaDetailsModal
   - Campos:
     - Nombre (required)
     - Código (required, unique)
     - Empresa (dropdown)
     - Manager (usuario dropdown)
     - Descripción (optional)
     - Activa (switch)

**Endpoints:**

- GET `/api/admin/area/` - Listar
- POST `/api/admin/area/` - Crear
- PUT `/api/admin/area/{id}/` - Actualizar

---

### 9.8 Gestión de Aprobadores

**Ubicación:**

- Level 1: `/web/admin/uapprover`
- Level 2: `/web/admin/ceco-approver`
- Level 3: `/web/admin/company-approver`

**Funcionalidad (Similar en los 3 niveles):**

1. **Listar Aprobadores**

   - Tabla: ID, Usuario, Nombre, Email, Nivel, Activo

2. **Asignar Aprobador**

   - Click "Assign" → Modal
   - Selector de usuario (dropdown, lista de empleados)
   - Confirmar: Asigna usuario como aprobador en ese nivel

3. **Remover Aprobador**

   - Botón "Remove" en fila
   - Confirmación
   - DELETE `/api/admin/approvers/{level}/{id}/`

4. **Restricciones**
   - Usuario solo puede ser aprobador en 1 nivel
   - No puede aprobar sus propios documentos

**Endpoints (por nivel):**

- GET `/api/admin/approvers/level-1/` - Listar L1
- POST `/api/admin/approvers/level-1/` - Crear L1
- DELETE `/api/admin/approvers/level-1/{id}/` - Eliminar L1
- Similar para L2 y L3

---

### 9.9 Filtros y Búsqueda en Admin

**Patrón General:**

1. **Search Input**

   - Busca en múltiples campos simultáneamente
   - Real-time (sin botón "Buscar")
   - Case-insensitive
   - Trimming automático

2. **Filtros StateFilter**

   - Componente: `<StateFilter>`
   - Dropdown con checkboxes
   - Múltiple selección
   - Si todas descheckeadas → sin filtro
   - Si una checkeada → solo esa

3. **Combinación de Filtros**
   - AND lógico: Debe cumplir search Y todos los filtros
   - Actualización instantánea en tabla

---

### 9.10 Modales de Detalle

**Patrón General:**

1. **Dialog/Modal**

   - `<UserDetailsModal>`, `<CompanyDetailsModal>`, etc
   - Abre en modo "Create" o "Edit"
   - Form con Zod validation

2. **Acciones Comunes**

   - **Save:** POST (new) o PUT (edit)
   - **Cancel:** Cierra modal sin cambios
   - **Delete:** Abre confirmación, luego DELETE

3. **Estados**
   - Idle: Formulario normal
   - Loading: Button deshabilitado, spinner
   - Success: Toast + cierra modal + refetch tabla
   - Error: Toast rojo con mensaje

---

## Resumen - Punto 9

| Módulo          | Tabla | Crear | Editar | Eliminar |
| --------------- | ----- | ----- | ------ | -------- |
| **Usuarios**    | ✅    | ✅    | ✅     | ✅       |
| **Empresas**    | ✅    | ✅    | ✅     | ❌       |
| **Proveedores** | ✅    | ✅    | ✅     | ✅       |
| **Conceptos**   | ✅    | ✅    | ✅     | ❌       |
| **CECOs**       | ✅    | ✅    | ✅     | ❌       |
| **Áreas**       | ✅    | ✅    | ✅     | ❌       |
| **Aprobadores** | ✅    | ✅    | ❌     | ✅       |
| **Rutas**       | ✅    | ✅    | ✅     | ✅       |
| **Impuestos**   | ✅    | ✅    | ✅     | ✅       |
| **Clases Doc**  | ✅    | ✅    | ✅     | ✅       |

---

## 10. Exportaciones y Reportes

### 10.1 Sistema de Reportes

**Ubicación:** `/web/expenses/reports`

**Tipos de Reportes:**

| Tipo                  | Descripción                     | Ruta                |
| --------------------- | ------------------------------- | ------------------- |
| **Gastos (Expenses)** | Lista de gastos individuales    | `/expenses/reports` |
| **Viajes (Travel)**   | Reportes de viajes corporativos | `/expenses/reports` |
| **Per Diem**          | Dietas y viáticos               | `/expenses/reports` |

**Estructura de Reporte:**

1. **Nombre del Reporte**

   - Campo texto (editable)
   - Ej: "Reporte Q4 2024"

2. **Período**

   - Fecha inicio (date picker)
   - Fecha fin (date picker)
   - Validación: Fin >= Inicio

3. **Items Incluidos**

   - Múltiples selecciones (checkboxes)
   - Gastos, Viajes, Per Diems
   - Cantidad total mostrada

4. **Datos del Reporte**
   - Total en moneda base
   - Divisas alternativas (si aplica)
   - Monto por categoría

---

### 10.2 Crear Nuevo Reporte

**Ubicación:** `/web/expenses/reports/new`

**Flujo de Creación:**

1. **Step 1: Información Básica**

   - Nombre reporte (text input)
   - Descripción (textarea, optional)
   - Período: Desde / Hasta
   - Empresa (auto-filled)

2. **Step 2: Seleccionar Items**

   - Tabs: Gastos | Viajes | Per Diem
   - Checkbox para cada item
   - Mostrar: Fecha, Descripción, Monto, Estado
   - Botón: "Select All" en cada tab

3. **Step 3: Resumen**

   - Total gastos: XXX
   - Total viajes: XXX
   - Total per diem: XXX
   - **Total Reporte:** XXX
   - Botón: "Create Report"

4. **Estado del Reporte**
   - Nuevo reporte creado → Estado: DRAFT
   - Puede editarse antes de enviar
   - Una vez enviado → Estado: SUBMITTED

**Validaciones:**

- Nombre requerido, máx 255 caracteres
- Al menos 1 item debe seleccionarse
- Período válido (desde <= hasta)

**Endpoint:**

- POST `/reports/` - Crear nuevo reporte
- Body: `{name, description, period_from, period_to, items: [{type, id}, ...]}`
- Response: Reporte creado con ID

---

### 10.3 Listar y Filtrar Reportes

**Ubicación:** `/web/expenses/reports`

**Tabla de Reportes:**

| Columna            | Tipo    | Descripción                          |
| ------------------ | ------- | ------------------------------------ |
| **ID**             | Número  | ID único del reporte                 |
| **Nombre**         | Texto   | Nombre del reporte                   |
| **Período**        | Fecha   | Desde - Hasta                        |
| **Items**          | Número  | Cantidad de items incluidos          |
| **Total**          | Moneda  | Monto total del reporte              |
| **Estado**         | Badge   | DRAFT, SUBMITTED, APPROVED, REJECTED |
| **Fecha Creación** | Fecha   | Cuándo se creó                       |
| **Acciones**       | Botones | Ver, Editar, Eliminar, Descargar     |

**Filtros:**

1. **Búsqueda**

   - Por nombre de reporte
   - Real-time filtering

2. **Estado**

   - DRAFT: En edición
   - SUBMITTED: Enviado para aprobación
   - APPROVED: Aprobado
   - REJECTED: Rechazado
   - Múltiple selección

3. **Período**

   - Desde / Hasta (date range picker)
   - Filtra reportes dentro del rango

4. **Rango de Monto**
   - Mín / Máx
   - Filtra por total del reporte

**Búsqueda Avanzada:**

- Combinación: Nombre AND Estado AND Período AND Monto
- AND lógico entre filtros
- Actualización inmediata en tabla

---

### 10.4 Ver Detalles de Reporte

**Ubicación:** Modal o Drawer al hacer click en fila

**Información Mostrada:**

1. **Encabezado**

   - Nombre del reporte
   - ID y fecha creación
   - Estado con badge color

2. **Período**

   - Desde: DD/MM/YYYY
   - Hasta: DD/MM/YYYY
   - Duración: X días

3. **Resumen de Items**

   - Gastos: X items, Total XXX
   - Viajes: X items, Total XXX
   - Per Diem: X items, Total XXX
   - **Total Reporte: XXX**

4. **Detalles Expandibles (Accordion)**

   **Gastos:**

   - Tabla con: Fecha, Concepto, Descripción, Monto, Empresa
   - Subtotal: XXX

   **Viajes:**

   - Tabla con: Fecha, Origen, Destino, Distancia, Monto, Empresa
   - Subtotal: XXX

   **Per Diem:**

   - Tabla con: Fecha, Cantidad Días, Monto Diario, Total, País
   - Subtotal: XXX

5. **Historial de Aprobación**
   - Timeline: Creado → Enviado → Aprobado/Rechazado
   - Quién aprobó / rechazó
   - Fecha y comentarios

---

### 10.5 Editar Reporte

**Disponible solo en estado DRAFT**

**Acciones Permitidas:**

1. **Cambiar Nombre/Descripción**

   - Editar campos de texto
   - Guardar cambios: PATCH `/reports/{id}/`

2. **Cambiar Período**

   - Modificar fechas desde/hasta
   - Validación: Fin >= Inicio

3. **Agregar/Remover Items**

   - Tab para cada tipo
   - Checkboxes con items disponibles
   - Guardar selección

4. **Enviar Reporte**

   - Botón: "Submit for Approval"
   - Validación: Al menos 1 item
   - Cambia estado: DRAFT → SUBMITTED
   - POST `/reports/{id}/submit/`

5. **Cancelar Reporte**
   - Botón: "Cancel Report"
   - Confirmación requerida
   - DELETE `/reports/{id}/`
   - Solo si estado DRAFT

---

### 10.6 Exportar a Formatos

**Ubicación:** Botón "Export" en vista de reporte

**Formatos Disponibles:**

1. **CSV**

   - Estructura: Encabezado + Datos tabulares
   - Separador: Coma (,)
   - Encoding: UTF-8
   - Incluye: Todos los items del reporte
   - Acción: GET `/reports/{id}/export/csv` → Download

2. **Excel (.xlsx)**

   - Librería: Opcional (cliente o servidor)
   - Hojas: Gastos, Viajes, PerDiem, Resumen
   - Formato: Tabla con estilos
   - Acción: GET `/reports/{id}/export/xlsx` → Download

3. **PDF**

   - Librería: html2pdf o similar (cliente)
   - Contenido: Resumen + Tablas + Gráficos
   - Orientación: Vertical
   - Acción: GET `/reports/{id}/export/pdf` → Download

4. **JSON**
   - Estructura: Objetos nested
   - Incluye: Metadatos + Items + Resumen
   - Acción: GET `/reports/{id}/export/json` → Download

**Filename Pattern:**

```
{empresa}_{tipo}_{fecha_inicio}_{fecha_fin}_{timestamp}.{ext}

Ej: RinderCorp_Gastos_2024-01-01_2024-03-31_20241130_143022.csv
```

---

### 10.7 Aprobación de Reportes

**Flujo General:**

1. Usuario EMPLOYEE crea reporte
2. Estado: DRAFT (puede editarse)
3. Click "Submit for Approval"
4. Estado: SUBMITTED
5. Approver recibe notificación
6. Approver ve reporte en dashboard
7. Approver: Aprobar o Rechazar
8. Si Aproba → APPROVED
9. Si Rechaza → REJECTED (puede volver a enviarse)

**Pantalla de Aprobación:**

- Similar a aprobación de documentos
- Mostrar: Reporte, Items, Total
- Campos:
  - Aprobar / Rechazar (radio buttons)
  - Comentarios (textarea)
  - Botón: "Submit"

**Estados:**

| Estado    | Quién lo ve | Acciones                        |
| --------- | ----------- | ------------------------------- |
| DRAFT     | Creator     | Editar, Eliminar, Submit        |
| SUBMITTED | Approver    | Aprobar, Rechazar, Ver detalles |
| APPROVED  | Ambos       | Ver, Descargar, Archivar        |
| REJECTED  | Creator     | Ver razón, Editar, Re-enviar    |

---

### 10.8 Dashboards de Reportes

**Para Employee:**

- KPIs: Reportes creados, Pendientes, Aprobados
- Gráfico: Estado de reportes (pie chart)
- Gráfico: Montos por período (line chart)
- Tabla: Reportes recientes

**Para Approver:**

- KPIs: Pendientes, Aprobados mes, Rechazados
- Gráfico: Reportes por estado
- Gráfico: Tiempo promedio aprobación
- Tabla: Reportes pendientes (ordenados por antigüedad)

**Para Admin:**

- KPIs: Total reportes, Total moneda, Promedio monto
- Gráfico: Reportes por empresa
- Gráfico: Reportes por período
- Tabla: Todos los reportes con filtros avanzados

---

### 10.9 Exportación de Datos Personales

**Ubicación:** Settings → Privacidad → "Export My Data"

**Contenido del Export:**

```json
{
  "user": {
    "id": 123,
    "username": "jdoe",
    "email": "john@example.com",
    "first_name": "John",
    "last_name": "Doe"
  },
  "documents": [
    {
      "id": 456,
      "type": "EXPENSE",
      "status": "APPROVED",
      "total": 500,
      "date": "2024-01-15"
    }
  ],
  "reports": [
    {
      "id": 789,
      "name": "Q4 Report",
      "total": 5000,
      "state": "APPROVED"
    }
  ],
  "approvals": [
    {
      "id": 101112,
      "document_id": 456,
      "approver": "Manager Name",
      "status": "APPROVED",
      "date": "2024-01-20"
    }
  ],
  "export_date": "2024-11-30",
  "export_format": "JSON"
}
```

**Formato:**

- JSON comprimido en ZIP
- Archivo: `user_data_export_{timestamp}.zip`
- Incluye: Perfil, Documentos, Reportes, Historial

**Endpoint:**

- GET `/api/users/me/export/data/` - Genera y descarga JSON

---

### 10.10 Auditoría y Historial

**Ubicación:** Admin → Auditoría (futuro)

**Registro de Acciones:**

| Acción            | Usuario    | Timestamp        | Detalles                |
| ----------------- | ---------- | ---------------- | ----------------------- |
| Crear reporte     | john@ex    | 2024-01-15 10:30 | Reporte ID 789          |
| Editar reporte    | john@ex    | 2024-01-15 10:45 | Cambió nombre           |
| Enviar reporte    | john@ex    | 2024-01-15 14:00 | Enviado para aprobación |
| Aprobar reporte   | manager@ex | 2024-01-16 09:00 | Aprobado                |
| Descargar reporte | john@ex    | 2024-01-16 11:30 | Descargó CSV            |

**Disponibilidad:**

- [ ] Auditoría de reportes (futuro)
- [ ] Auditoría de aprobaciones (futuro)
- [ ] Auditoría de descargas (futuro)

---

## Resumen - Punto 10

| Funcionalidad         | Status | Descripción                    |
| --------------------- | ------ | ------------------------------ |
| **Crear Reporte**     | ✅     | Step-by-step wizard            |
| **Listar Reportes**   | ✅     | Con búsqueda y filtros         |
| **Ver Detalles**      | ✅     | Modal/Drawer con items         |
| **Editar (DRAFT)**    | ✅     | Cambiar nombre, período, items |
| **Enviar Aprobación** | ✅     | Cambiar a SUBMITTED            |
| **Aprobar Reporte**   | ✅     | Solo approvers                 |
| **Rechazar Reporte**  | ✅     | Con comentarios                |
| **Exportar CSV**      | ✅     | Descarga directa               |
| **Exportar Excel**    | ❓     | Opcional                       |
| **Exportar PDF**      | ❓     | Opcional                       |
| **Exportar JSON**     | ✅     | Datos personales               |
| **Dashboard**         | ✅     | KPIs + Gráficos                |

---

## 11. Errores Comunes

### 11.1 Errores de Autenticación

#### Error: "Token Expired" o "401 Unauthorized"

**Síntoma:**

- Toast rojo: "Session expired"
- Auto-redirect a `/login`
- No puedes acceder a rutas protegidas

**Causas:**

1. Token expiró (después de X horas)
2. Token inválido o corrupto
3. Logout desde otra pestaña del mismo navegador

**Solución:**

```
1. Ingresa nuevamente con usuario y contraseña
2. Token se regenera y almacena en localStorage
3. Refresh automático lleva a ruta anterior
```

**Técnico:**

- `apiClient.ts` → interceptor captura 401
- Limpia localStorage
- Redirige a `/login` con next/navigation
- No mostraré token en console.log (seguridad)

---

#### Error: "Invalid Credentials"

**Síntoma:**

- Login fallido
- Toast: "Invalid email or password"

**Causas:**

1. Usuario/email no existe
2. Contraseña incorrecta
3. CAPS LOCK activado
4. Email con espacios accidentales

**Solución:**

```
1. Verifica que el email esté correcto
2. Asegúrate de ingresar contraseña correcta
3. Prueba SHIFT+CAPS para desactivar CAPS LOCK
4. Copia/pega credenciales (sin espacios)
5. Si olvidas contraseña → "Forgot Password"
```

---

#### Error: "Email Already Registered"

**Síntoma:**

- Al signup: "This email is already registered"

**Causas:**

1. Ya exists una cuenta con ese email
2. Signup intenta registrar email duplicado

**Solución:**

```
1. Login si ya tienes cuenta
2. Usa diferente email
3. Si olvidaste contraseña → "Forgot Password"
```

---

### 11.2 Errores de Validación de Formularios

#### Error: "Required Field"

**Síntoma:**

- Campo con borde rojo
- Mensaje debajo: "This field is required"
- Submit bloqueado

**Causas:**

- Campo obligatorio está vacío

**Solución:**

```
1. Completa el campo con datos válidos
2. Presiona TAB para pasar al siguiente
3. Submit se activa cuando todos requeridos llenos
```

---

#### Error: "Invalid Email Format"

**Síntoma:**

- Email input con borde rojo
- Mensaje: "Enter a valid email"

**Causas:**

- Email sin formato valido
- Ej: "john@" o "john.com" (sin @)

**Solución:**

```
Formato válido: usuario@dominio.com
Ejemplos:
✅ john.doe@company.com
✅ maria+tag@example.org
❌ john@         (falta dominio)
❌ john.com      (falta @)
❌ @example.com  (falta usuario)
```

---

#### Error: "Phone Number Invalid"

**Síntoma:**

- Phone input con borde rojo
- Mensaje: "Enter a valid international phone"

**Causas:**

- Formato no reconocido
- Menos dígitos de lo esperado
- Caracteres inválidos

**Solución:**

```
Formato: +[1-9] seguido de 0-15 dígitos
Ejemplos:
✅ +56912345678 (Chile)
✅ +34912345678 (España)
✅ +33912345678 (Francia)
✅ +491234567890 (Alemania)
❌ 912345678    (sin +)
❌ +0912345678  (comienza con 0)
```

---

### 11.3 Errores de Carga de Datos

#### Error: "Network Error" o "Failed to Fetch"

**Síntoma:**

- Toast: "Network error"
- Spinner indefinido
- Tabla no muestra datos

**Causas:**

1. Sin conexión a internet
2. Servidor offline
3. CORS error (mismatched origins)
4. Timeout en request

**Solución:**

```
1. Verifica conexión internet (WiFi/Datos)
2. Recarga página: F5 o Ctrl+R
3. Espera 10 segundos y reintenta
4. Verifica que backend esté online
5. Limpia cache: Ctrl+Shift+Delete
```

---

#### Error: "Data Not Found" o "404 Not Found"

**Síntoma:**

- Toast: "Document not found"
- Vista vacía o lista sin datos

**Causas:**

1. Documento/registro fue eliminado
2. URL con ID inválido
3. Permiso insuficiente para ver recurso
4. Backend retorna 404

**Solución:**

```
1. Verifica que documento siga existiendo
2. Recarga lista para ver cambios
3. Si es URL manual, corrige el ID
4. Pide acceso a admin si es permiso
```

---

#### Error: "Timeout" o "Request Took Too Long"

**Síntoma:**

- Spinner muy tiempo
- "Request timeout" después de ~30s
- Operación no completada

**Causas:**

1. Servidor muy lento
2. Conexión muy lenta
3. Payload muy grande
4. Operación pesada en backend

**Solución:**

```
1. Reintenta la operación
2. Recarga página y vuelve a intentar
3. Si es upload de archivo grande:
   - Comprime archivos
   - Divide en múltiples uploads
4. Contacta admin si persiste
```

---

### 11.4 Errores de Archivo

#### Error: "File Upload Failed"

**Síntoma:**

- Toast: "Failed to upload file"
- Archivo no se adjunta

**Causas:**

1. Archivo muy grande (>50MB)
2. Tipo de archivo no permitido (ej: .exe)
3. Sin espacio en servidor
4. Conexión interrumpida

**Solución:**

```
1. Verifica tamaño: máx 50MB
2. Formatos permitidos: PDF, JPG, PNG, XLSX, DOC
3. Reintenta conexión WiFi/Datos
4. Intenta con archivo más pequeño
5. Si persiste, contacta soporte
```

---

#### Error: "File Not Found" al Descargar

**Síntoma:**

- Click en "Download" no descarga
- Toast: "File not found"

**Causas:**

1. Archivo fue eliminado del servidor
2. Link expiró
3. Permiso insuficiente
4. Servidor error

**Solución:**

```
1. Verifica que archivo siga existiendo
2. Recarga página
3. Reintenta descargar
4. Si no funciona, contacta admin
```

---

### 11.5 Errores de Permisos

#### Error: "Access Denied" o "You Don't Have Permission"

**Síntoma:**

- Toast: "Access denied"
- Botón gris/deshabilitado
- Ruta redirige a home

**Causas:**

1. Tu rol no permite esa acción
2. No eres approver para ese documento
3. Documento no es tuyo
4. Nivel de aprobación insuficiente

**Solución:**

```
1. Verifica tu rol en Settings → Perfil
2. Solicita al admin elevar permisos
3. Solo creator o approver pueden ver
4. Solo approver L3 puede aprobar L3
5. Contacta a tu manager
```

---

#### Error: "Role Not Assigned"

**Síntoma:**

- No ves opciones de approver
- Admin/Reports no aparecen en sidebar

**Causas:**

- Tu usuario no tiene ese rol asignado

**Solución:**

```
1. Contacta admin
2. Admin asigna rol desde: Admin → Users
3. Recarga página para ver cambios
4. Verificar con: Settings → Perfil
```

---

### 11.6 Errores de Estado y Flujo

#### Error: "Cannot Approve Already Approved Document"

**Síntoma:**

- Modal de aprobación bloqueado
- Botón "Approve" gris

**Causas:**

1. Documento ya fue aprobado
2. Ya está en siguiente nivel
3. Alguien más lo aprobó primero

**Solución:**

```
1. Recarga página
2. Ver en "Historial" quién aprobó
3. Si es error, contacta admin
```

---

#### Error: "Cannot Edit Submitted Document"

**Síntoma:**

- Formulario campos deshabilitados
- "This document is locked"

**Causas:**

- Documento fue enviado para aprobación
- Estado cambió a SUBMITTED/APPROVED

**Solución:**

```
1. Solo puedes editar documentos DRAFT
2. Si necesitas cambiar:
   - Rechaza documento (si eres approver)
   - Creator puede editar nuevo draft
3. Opción: Crear nuevo documento
```

---

#### Error: "Item Already in Report"

**Síntoma:**

- No puedes agregar item a reporte
- Mensaje: "This item is already included"

**Causas:**

- Mismo item ya está en otro reporte
- Un gasto no puede estar en 2 reportes

**Solución:**

```
1. Revisa reportes existentes
2. Elimina de reporte anterior si quieres mover
3. O crea nuevo reporte con diferentes items
```

---

### 11.7 Errores de Interfaz

#### Error: "Chart Not Rendering" o "Blank Chart"

**Síntoma:**

- Gráfico en blanco
- No muestra datos

**Causas:**

1. Datos vacíos/inválidos
2. Error en configuración de Recharts
3. Resolución muy pequeña

**Solución:**

```
1. Verifica que haya datos en período
2. Zoom out si en mobile
3. Recarga página
4. Prueba con rango diferente
```

---

#### Error: "Table Columns Not Showing"

**Síntoma:**

- Tabla vacía o columnas ocultas
- Datos no se ven

**Causas:**

1. Resolución muy pequeña
2. Columnas ocultadas accidentalmente
3. Filtro muy restrictivo

**Solución:**

```
1. En desktop: Zoom out (Ctrl+Minus)
2. En mobile: Scroll horizontal
3. Limpia filtros: Reset filters
4. Recarga página
```

---

#### Error: "Modal Not Opening"

**Síntoma:**

- Click en botón pero no abre modal
- Nada sucede

**Causas:**

1. JavaScript error
2. Componente mal renderizado
3. Estado corrupto

**Solución:**

```
1. Recarga página: F5
2. Limpia cache: Ctrl+Shift+Delete
3. Intenta en navegador diferente
4. Contacta soporte con screenshot
```

---

### 11.8 Errores de Tema/Idioma

#### Error: "Language Not Changing"

**Síntoma:**

- Cambias idioma en settings
- Interfaz permanece en anterior

**Causas:**

1. i18next no refresca
2. Componentes no suscritos a cambio
3. localStorage corrompida

**Solución:**

```
1. Recarga página: F5
2. Limpia localStorage: Ctrl+Shift+Delete
3. Intenta nuevamente
4. Si persiste: Hard refresh Ctrl+Shift+R
```

---

#### Error: "Dark Mode Not Working"

**Síntoma:**

- Cambias tema a dark
- Interfaz permanece light

**Causas:**

1. next-themes no initialized
2. Sistema operativo fuerza tema
3. CSS no aplicado

**Solución:**

```
1. Recarga página
2. Verifica en: Settings → Appearance
3. Selecciona "dark" explícitamente
4. Si sigue: Limpia cache del navegador
```

---

### 11.9 Debugging Tips

**Herramientas Disponibles:**

1. **DevTools del Navegador**

   - F12 → Console
   - Ver errores y logs
   - Inspeccionar elementos

2. **Network Tab**

   - F12 → Network
   - Ver requests/responses
   - Verificar status codes (200, 401, 404, 500)

3. **Application/Storage**

   - F12 → Application
   - Ver localStorage (token, idioma)
   - Limpiar datos de prueba

4. **React DevTools**
   - Extension: React Developer Tools
   - Inspeccionar componentes
   - Ver props y state

**Pasos para Reportar Error:**

1. Reproducir paso a paso
2. Anotar mensaje exacto de error
3. Screenshot o video corto
4. Verificar console (F12)
5. Notar navegador y SO
6. Enviar a soporte con detalles

---

## Resumen - Punto 11

| Categoría      | Error               | Solución Rápida             |
| -------------- | ------------------- | --------------------------- |
| **Auth**       | 401 Unauthorized    | Login nuevamente            |
| **Auth**       | Invalid Credentials | Verifica email/password     |
| **Validación** | Required Field      | Completa campo vacío        |
| **Validación** | Invalid Email       | Formato: user@domain.com    |
| **Red**        | Network Error       | Recarga página              |
| **Red**        | Timeout             | Reintenta después           |
| **Archivo**    | Upload Failed       | Verifica tamaño (<50MB)     |
| **Permisos**   | Access Denied       | Pide role a admin           |
| **Estado**     | Cannot Edit         | Solo DRAFT editable         |
| **UI**         | Blank Chart         | Recarga página              |
| **Idioma**     | Not Changing        | Hard refresh (Ctrl+Shift+R) |

---

## Conclusión

**Documentación Completada:**

✅ Puntos 1-11 documentados en profundidad

**Cobertura:**

- ✅ Stack tecnológico y estructura
- ✅ Autenticación y acceso
- ✅ Interfaz general y componentes
- ✅ Dashboard y KPIs
- ✅ Gestión de documentos (CRUD)
- ✅ Sistema de aprobaciones (3 niveles)
- ✅ Notificaciones (Sonner)
- ✅ Perfil y configuración
- ✅ Panel administrativo (14 módulos)
- ✅ Reportes y exportaciones
- ✅ Errores comunes y soluciones

**Próximos Pasos (Futuros):**

- [ ] Auditoría de acciones
- [ ] Two-Factor Authentication (2FA)
- [ ] API Documentation (backend)
- [ ] Performance optimization guide
- [ ] Security hardening guide
- [ ] Deployment guide (Vercel)
- [ ] Testing strategy
- [ ] Troubleshooting advanced topics

**Fecha de Última Actualización:** 30 de Noviembre 2025

---

_Fin de la Documentación Técnica Frontend - Rinderline v2.0_
