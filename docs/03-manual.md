---
layout: default
title: Manual de Usuario
nav_order: 4
has_children: true
description: "Guía completa de usuario para la aplicación Rinderline"
---

# Manual de Usuario — Rinderline

**Versión:** 1.0  
**Fecha:** Noviembre 2025  
**Aplicación:** Rinderline - Gestión de Gastos Empresariales  
**Público:** Empleados, Aprobadores, Administradores  
**Idioma:** Español (disponible también en EN, FR, DE)

---

## ÍNDICE

1. [Introducción](#1-introducción)
2. [Acceso a la Aplicación](#2-acceso-a-la-aplicación)
3. [Roles y Permisos](#3-roles-y-permisos)
4. [Interfaz Principal](#4-interfaz-principal-frontend)
5. [Gestión de Usuarios](#5-gestión-de-usuarios-si-aplica)
6. [Módulo de Documentos y Gastos](#6-módulo-principal-de-la-aplicación--documentos-y-gastos)
7. [Módulo de Aprobaciones](#7-módulo-de-aprobaciones)
8. [Dashboard y Reportes](#8-dashboard-y-reportes)
9. [Perfil y Configuración](#9-perfil-y-configuración)
10. [Preguntas Frecuentes (FAQ)](#10-preguntas-frecuentes-faq)
11. [Errores y Soluciones](#11-errores-y-soluciones)

---

## RESUMEN EJECUTIVO

**Rinderline** es una plataforma web centralizada para la gestión integral de gastos corporativos, que permite a los empleados registrar, documentar y enviar comprobantes de gastos para su aprobación en múltiples niveles jerárquicos.

### Para Empleados:

- ✅ Crear documentos de gasto (gastos, viajes, viáticos)
- ✅ Adjuntar comprobantes (PDF, imágenes)
- ✅ Enviar para aprobación
- ✅ Rastrear estado y comentarios

### Para Aprobadores:

- ✅ Revisar documentos pendientes
- ✅ Aprobar o rechazar con comentarios
- ✅ Visualizar dashboard con pendientes por nivel
- ✅ Filtrar y buscar documentos asignados

### Para Administradores:

- ✅ Gestionar usuarios (crear, editar, desactivar)
- ✅ Configurar catálogos (centros de costo, conceptos de gasto, impuestos)
- ✅ Definir estructura de aprobación (niveles y aprobadores)
- ✅ Monitorear actividad y auditoría

### Características Principales:

| Feature                       | Descripción                                                        |
| ----------------------------- | ------------------------------------------------------------------ |
| **Multi-nivel de Aprobación** | Flujo de aprobación con hasta 4 niveles jerárquicos                |
| **Multi-moneda**              | Soporte para múltiples monedas con conversión automática           |
| **Adjuntos de Comprobantes**  | Subida de PDF e imágenes con validación y almacenamiento en AWS S3 |
| **Soft Delete / Auditoría**   | Registro completo de cambios sin eliminación física                |
| **Reportes Visuales**         | Dashboards con gráficos, filtros y exportación a Excel/PDF         |
| **Internacionalización**      | Disponible en 4 idiomas (ES, EN, FR, DE)                           |

---

## 1. Introducción

### 1.1 Propósito del manual

Este manual explica de forma práctica y dirigida cómo usar la aplicación Rinderline: desde el acceso, flujos básicos, roles y permisos, hasta la gestión de documentos. Está pensado para entregar instrucciones claras a **usuarios comunes**, **aprobadores** y **administradores**, combinando explicación paso a paso con recomendaciones y restricciones.

### 1.2 ¿Qué es la aplicación y para qué sirve?

Rinderline es una aplicación web para la gestión de documentos y gastos corporativos: crear reportes, subir comprobantes (PDF/imagenes), enviar documentos a aprobación en varios niveles y, finalmente, integrarlos con sistemas externos (p. ej. SAP) o procesarlos para pago.

### 1.3 Público objetivo

- **Usuario (Employee / Reporter):** Crea documentos y items (gastos, viajes, per diems), envía para aprobación, revisa historial.
- **Aprobador (Approver):** Revisa, aprueba o rechaza documentos asignados según su nivel (L1–L3). Tiene dashboard con pendientes y herramientas de filtrado.
- **Administrador (Admin):** Gestiona catálogos, usuarios, permisos y configuración global del sistema.

### 1.4 Requisitos mínimos

- Navegadores soportados: versiones modernas de Chrome, Edge, Firefox y Safari; se recomienda la última versión estable.
- Conexión: 1 Mbps estable mínimo para subida de archivos; recomendable conexión más rápida para cargas de múltiples PDFs.
- Dispositivos: Desktop y tablet (la app es responsive; en móvil algunas tablas se muestran con scroll horizontal).
- Archivos: PDFs, JPG/JPEG, PNG; máximo 5 MB por archivo y hasta 10 archivos por documento (restricciones del frontend).

---

## 2. Acceso a la Aplicación

**Esta sección te guía a través del proceso de autenticación y configuración inicial.**

### 2.1 URL de acceso

- **Desarrollo:** `http://localhost:3000`
- **Producción:** `https://rinderline-webapp.vercel.app`

Rutas públicas principales: `/`, `/login`, `/signup`. Rutas protegidas: `/web/*` (dashboard, gastos, aprobaciones, admin, settings).

### 2.2 Inicio de sesión

1. Accede a `/login`.
2. Ingresa usuario (o email) y contraseña. Validaciones en cliente: username 3–20 caracteres; password mínimo 6 caracteres.
3. Al enviar, la app hace `POST /auth/login/` y recibe `{ token, user, redirectTo }`.
4. El token se guarda en `localStorage` y queda incluido en el header `Authorization: Token {token}` para las siguientes peticiones.

**Estado y manejo de errores:** 401 limpia token y redirige a `/login`; errores 500 muestran mensaje genérico.

### 2.3 Primer acceso y configuración inicial

- Tras registro automático (signup) el usuario es redirigido a `/web/settings` para completar su perfil.
- Se recomienda subir foto, verificar datos de la empresa/área y configurar preferencias (idioma, notificaciones).
- En caso de que sea un registro, es necesario conocer el RUT de la empresa a la que se va a pertenecer, sino existe devolverá un error.

### 2.4 Cierre de sesión

- Desde el avatar/menú: `Logout` → (opcional) `POST /auth/logout/`.
- Al cerrar sesión se elimina el token de `localStorage`, se limpia el estado global y se redirige a `/login`.
- Sincronización entre pestañas: la app escucha eventos `storage` para propagar logout.

---

## 3. Roles y Permisos

**Comprende los diferentes tipos de usuario y sus capacidades en el sistema.**

### 3.1 Tipos de usuarios

- **USER (Empleado):** Crea y edita sus documentos; no puede aprobar sus propios documentos.
- **APPROVER:** Usuario con permiso para aprobar en alguno de los niveles definidos por la empresa.
- **ADMIN:** Gestión total (usuarios, catálogos, configuración, paneles de administración).

### 3.2 Permisos y restricciones por rol

- Los aprobadores ven paneles distintos (dashboard de aprobador) y accesos a endpoints de revisión y aprobación.
- Los administradores pueden gestionar compañías, áreas, centros de costo, monedas, impuestos y permisos.
- Accesos a menús y botones cambian dinámicamente según el rol del token autenticado.

### 3.3 Acciones no permitidas / reglas de negocio clave

- **Un usuario no puede aprobar sus propios documentos.** Si un usuario creó o ya intervino en un documento, el sistema evita que ese mismo usuario emita la aprobación final en ese mismo documento, por lo tanto ya no lo podrá visualizar.
- **Estados y transiciones:** SAVED → PENDING → (PENDING_L2/PENDING_L3) → APPROVED → PAID. Rechazos devuelven a REJECTED y permiten edición+reenvío (en desarrollo).
- **Borrado lógico:** documentos y items usan `erased_at` (soft delete) — no se eliminan físicamente por seguridad/auditoría.

---

## 4. Interfaz Principal (Frontend)

**Conoce la estructura visual y componentes de la aplicación.**

### 4.1 Descripción general del dashboard

- Dashboard con KPI cards (gastos por categoría, montos, tendencias), tablas de documentos y gráficos (bar/pie) para analítica rápida.
- Cards y gráficos son interactivos: click en un segmento o fila abre detalles en modal/drawer.

### 4.2 Menú de navegación

- Sidebar colapsable, con items según rol: Dashboard, Mis Gastos, Aprobaciones (si aplica), Reportes, Admin, Configuración.
- En móvil el sidebar viene colapsado y es accesible desde el trigger en el header.

### 4.3 Barra superior (perfil, notificaciones, logout)

- Contiene: trigger del sidebar (mobile), título dinámico, botones de acción (ej. "Subir Gasto"), icono de notificaciones y avatar con menú de cuenta/logout.

### 4.4 Elementos comunes de la UI

- **Tablas:** Columnas dinámicas, paginación (5/10/20), checkboxes de selección, acciones inline.
- **Filtros:** Search con debounce 500ms, select por estado (SAVED/PENDING/APPROVED/REJECTED), date range, select por tipo/centro de costo.
- **Modales:** Create/Edit, Approval Confirmation, Delete Confirmation, Details (drawer/modal).
- **Adjuntos:** Drag-and-drop para PDFs e imágenes con preview y barra de progreso.
- **Badges/Indicadores de estado:** colores por estado (ej. amarillo=PENDING, verde=APPROVED, rojo=REJECTED).

---

## 5. Gestión de Usuarios (Si aplica)

**Solo para administradores: crear, editar y gestionar usuarios del sistema.**

> Nota: acceso a este módulo normalmente reservado a administradores.

### 5.1 Ver lista de usuarios

- Vista con paginación y filtros (por empresa, rol, estado activo/inactivo).
- Columnas típicas: Nombre, Email, Rol, Empresa, Área, Último login, Estado.

### 5.2 Crear usuario

- Formulario: email, username, nombre, apellido, empresa, área, rol, contraseña temporal.
- Validaciones cliente+servidor: email único, username 3–20 chars, contraseña con políticas mínimas.

### 5.3 Editar perfil propio

- Los usuarios pueden editar su propio perfil desde `/web/settings`: nombre, teléfono, foto, preferencia de idioma y seguridad (2FA si activa).

### 5.4 Editar roles/permisos

- Solo Admin puede cambiar rol y permisos. Cambios de rol actualizan menú y accesos al siguiente inicio de sesión (se recomienda invalidar sesión y forzar re-login si hay cambio crítico).

### 5.5 Desactivar usuario

- Opción para desactivar (no eliminar). Usuario desactivado no puede iniciar sesión; datos permanecen para auditoría. Admin puede reactivar.

---

## 6. Módulo Principal de la Aplicación — Documentos y Gastos

**Crea, edita y gestiona documentos de gasto con adjuntos.**

### 6.1 Crear documento

1. Ir a **Mis Documentos / Mis Gastos**.
2. Dar clic en **“Nuevo Documento”**.
3. Completar los campos obligatorios: tipo de gasto, fecha, monto, descripción, moneda y centro de costo.
4. Guardar como **Draft (SAVED)** o enviar directamente a aprobación.

**Reglas importantes:**

- Validaciones en frontend para prevenir datos incompletos.
- Se utiliza _soft delete_ para mantener trazabilidad.

### 6.2 Subir archivos (PDF, imágenes)

- Se permite arrastrar y soltar archivos o seleccionarlos desde el explorador.
- Tipos permitidos: **PDF, JPG, PNG**.
- Tamaño máximo por archivo: **5 MB**.
- Vista previa incluida; errores de formato o peso se muestran inmediatamente.

El sistema realiza la subida al servidor o almacenamiento externo.

### 6.3 Editar documento (EN DESARROLLO)

- Los documentos en estado **SAVED** o **REJECTED** pueden editarse.
- Los documentos en **PENDING** o superiores no pueden modificarse.
- La edición incluye: actualizar montos, corregir descripciones, reemplazar o eliminar anexos.

### 6.4 Archivar o eliminar documento

- No existe eliminación permanente; se usa **borrado lógico**, esto significa que existirá en la base de datos aunque haya sido eliminado eliminado.

### 6.5 Filtros y búsqueda

- Búsqueda por texto con _debounce_.
- Filtros por estado (SAVED, PENDING, APPROVED, REJECTED), por rango de fechas y por centro de costo.
- Filtro por tipo de documento (viajes, reembolsos, gastos operativos, etc.).

### 6.6 Historial del documento

- Incluye: fecha de creación, últimos cambios, aprobaciones previas, rechazos, usuario responsable y comentarios.
- El backend registra cada transición de estado.

---

## 7. Módulo de Aprobaciones

Este módulo solo está disponible para usuarios con rol **APROVADOR** o **ADMIN**.

### 7.1 Flujo de aprobación

Los documentos pasan por un flujo de aprobación en uno o varios niveles (L1, L2, L3). El flujo se define según:

- Tipo de documento.
- Centro de costo.
- Empresa.

### 7.2 Aprobar o rechazar

1. Acceder a **Aprobaciones**.
2. Seleccionar documento pendiente.
3. Ver detalles, anexos y comentarios.
4. Seleccionar: **Aprobar** o **Rechazar**.
5. Confirmar en el modal.

### 7.3 Motivo de rechazo

- Si el usuario rechaza el documento, debe indicar un motivo.

### 7.4 Niveles de aprobación

- Un documento puede requerir 1, 2 o 3 niveles.
- Cuando un nivel aprueba, el documento pasa automáticamente al siguiente.
- En L3, la aprobación marca el documento como **APPROVED**.

### 7.5 Restricciones del sistema

- Un aprobador **no puede volver a aprobar** un documento que ya aprobó.
- Un usuario **jamás puede aprobar su propio documento**.
- Si el documento no pertenece al centro de costo, empresa o flujo del aprobador, el sistema bloquea la acción.

---

## 8. Configuración de la Cuenta

### 8.1 Actualizar datos personales

- Desde el menú, opción **“settings”**.
- Modificar: nombre, teléfono, idioma y zona horaria.

### 8.2 Cambiar contraseña

- Acceder a **settings**.
- Validación de contraseña actual y nueva.

### 8.3 Preferencias de usuario

- Configuración de idioma (ES/EN/DE/FR).

---

## 11. Administración del Sistema

Este módulo es exclusivo para perfiles con rol **ADMIN**.

### 11.1 Configuración global

- Ajustes de empresa como logotipo, nombre, políticas internas y configuración de aprobación.
- Parámetros generales: límites de carga de archivos, moneda por defecto, métodos de autenticación.

### 11.2 Catálogos y listas

- Administración de catálogos como: **Monedas, Áreas, Empresas, Centros de Costo, Tipos de Documento**.
- Posibilidad de crear, editar, desactivar y reactivar elementos.

### 11.3 Gestión de permisos

- Asignación o modificación de roles.
- Activación de usuarios como aprobadores.
- Configuración de niveles de aprobación según empresa/área.

### 11.4 Tareas programadas / Panel admin

- Acceso directo al panel administrativo del backend (si está habilitado).
- Visualización de logs, ejecuciones automáticas y tareas internas.

---

---

## ERRORES Y SOLUCIONES COMUNES

### Problema: No puedo iniciar sesión

- Verifique que el usuario esté activo.
- Asegúrese de que su contraseña es correcta.
- Si olvidó su contraseña, comuniquese con un supervisor.

### Problema: No carga un archivo PDF

- Verifique el tamaño (máx. 5MB) y el formato del archivo.
- Revise su conexión a internet.

### Problema: No se muestra información en la tabla

- Compruebe que los filtros no estén restringiendo la búsqueda.
- Actualice la página.

### Problema: No puedo aprobar un documento

###

- Verifique que el documento pertenece a su nivel de aprobación.
- Asegúrese de no haber aprobado el documento previamente.
- Confirme que no es el creador del documento.

### Problema: Error 500 o 403

- El error 403 generalmente ocurre por permisos insuficientes.
- El error 500 indica problemas internos; contacte a soporte.

---

## Preguntas Frecuentes (FAQ)

### ¿Por qué no me aparecen mis documentos?

- Puede haber filtros activos.
- El documento pudo ser archivado.

### ¿Qué significa el estado X?

- **SAVED**: Borrador.
- **PENDING**: En proceso de aprobación.
- **REJECTED**: Requiere corrección.
- **APPROVED**: Completamente aprobado.

### ¿Cómo sé si ya aprobaron mi documento?

- Recibirá una notificación.
- Puede revisar el historial del documento.

---

## Anexos

### 14.1 Glosario

- **Borrador (SAVED):** Documento aún no enviado.
- **Pendiente (PENDING):** En espera de aprobación.
- **Rechazado (REJECTED):** Requiere correcciones.
- **Aprobado (APPROVED):** Con todas las aprobaciones completas.
- **Soft Delete:** Eliminación lógica del documento.

### 14.2 Screenshots del sistema

- Pantallas del dashboard.
- Vista de documentos.
- Vista de aprobaciones.
- Tablas con filtros.

### 14.3 Flujos de procesos

- Flujo de creación de documentos.
- Flujo completo de aprobaciones.
- Flujo de recuperación de contraseña.

### 14.4 Contacto de soporte

- Email: [edgardo.gonzalez.23@hotmail.com]
- Disponibilidad: Lunes a viernes de 9am a 6pm.

---

**Fin del Manual de Usuario — Rinderline (Partes 1, 2 y 3)**.

### Anexos recomendados para esta sección

1. Flujo visual de creación de documento.
2. Ejemplo de tabla con filtros activos.
3. Pantalla del módulo de aprobaciones.
4. Modal de aprobación/rechazo.
5. Vista del panel de notificaciones.
6. Pantalla de configuración de cuenta.

---

_Fin de la Parte 2 (Puntos 6–9). La Parte 3 contendrá los puntos 10–14 junto con la propuesta completa de anexos y glosario._

### Anexos (imágenes a incluir para estos primeros 5 puntos)

**Imágenes/diagramas recomendados (se ubicarán al final del documento):**

1. **Diagrama general de la aplicación** (arquitectura cliente-servidor, endpoints principales).
2. **Flujo de inicio de sesión / recuperación de contraseña** (pantallas y endpoints).
3. **Mapa de roles y permisos** (quién puede ver/hacer qué).
4. **Wireframe del dashboard** (sidebar, header, KPI cards, tabla).
5. **Formulario de creación de usuario** (campos y validaciones visibles).

---

_Fin de la Parte 1 (Puntos 1–5). En la Parte 2 entregaré los puntos 6–9 y en la Parte 3 los puntos 10–14 junto con los anexos visuales y el glosario._
