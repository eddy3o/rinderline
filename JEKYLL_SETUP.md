# Rinderline - Ejecutar Documentación con Jekyll

## 🚀 Instalación y Ejecución Local

### Requisitos Previos

- **Ruby 3.1+** instalado ([descargar](https://www.ruby-lang.org/en/downloads/))
- **Bundler** instalado (`gem install bundler`)
- Git

### Paso 1: Clonar el Repositorio

```bash
git clone https://github.com/eddy3o/rinderline.git
cd rinderline
```

### Paso 2: Instalar Dependencias

```bash
bundle install
```

Esto instalará Jekyll, el tema `just-the-docs`, y todas las dependencias del Gemfile.

### Paso 3: Ejecutar Localmente

```bash
bundle exec jekyll serve
```

Verás un output similar a:

```
Configuration file: /path/to/rinderline/_config.yml
            Source: /path/to/rinderline
       Destination: /path/to/rinderline/_site
 Incremental build: enabled
      Generating...
                    done in 1.234 seconds.
 Auto-regeneration: enabled for '/path/to/rinderline'
    Server address: http://127.0.0.1:4000
  Server running...
  Press Ctrl-C to stop.
```

Accede a **http://localhost:4000/rinderline/** en tu navegador.

---

## 📝 Estructura de Documentación

```
rinderline/
├── _config.yml              # Configuración de Jekyll
├── Gemfile                  # Dependencias Ruby
├── docs/
│   ├── index.md            # Página principal con tabla de contenidos
│   ├── 01-backend.md       # Documentación Backend
│   ├── 02-frontend.md      # Documentación Frontend
│   └── 03-manual.md        # Manual de Usuario
└── README.md               # Este archivo
```

---

## 🎨 Temas y Personalización

### Tema: Just-the-Docs

Este proyecto usa el tema **just-the-docs** que incluye:

- ✅ **Sidebar automático** con índice de contenidos
- ✅ **Búsqueda integrada** en toda la documentación
- ✅ **Responsive design** (funciona en móvil)
- ✅ **Dark mode** automático
- ✅ **Navegación jerárquica** con `has_children`
- ✅ **Sintaxis highlighting** para código

### Personalización del `_config.yml`

Para cambiar:

- **Título y descripción:**

  ```yaml
  title: Mi Nuevo Título
  description: Mi descripción
  ```

- **Color del tema:**

  ```yaml
  color_scheme: dark # light, dark, custom
  ```

- **Links externos (aux_links):**
  ```yaml
  aux_links:
    "GitHub":
      - "https://github.com/eddy3o/rinderline"
  ```

---

## 📄 Agregar Nuevas Páginas

### Crear una Nueva Página Markdown

1. Crea un archivo en `docs/`:

   ```bash
   touch docs/04-api-reference.md
   ```

2. Agrega el frontmatter YAML:

   ```yaml
   ---
   layout: default
   title: API Reference
   nav_order: 5
   parent: Backend Documentation
   description: "API endpoints and examples"
   ---
   ```

3. Escribe el contenido en Markdown

4. **Ejecuta** `bundle exec jekyll serve` para ver cambios

### Jerarquía de Páginas

```yaml
# Página padre
---
layout: default
title: Backend Documentation
nav_order: 2
has_children: true
---
# Página hija
---
layout: default
title: API Endpoints
nav_order: 1
parent: Backend Documentation
---
```

---

## 🔍 Búsqueda y Navegación

La búsqueda está **habilitada automáticamente** en `just-the-docs`.

- Acceso: Botón de **"Search"** en la esquina superior
- Busca en: Títulos, headings, contenido
- Resultado: Click para ir a la página

---

## 🚀 Desplegar en GitHub Pages

### Opción 1: Deployment Automático (Recomendado)

1. **Push a GitHub:**

   ```bash
   git add .
   git commit -m "Update documentation"
   git push origin main
   ```

2. **Configurar GitHub Pages:**

   - Ve a **Settings → Pages**
   - Source: `Deploy from a branch`
   - Branch: `main`, folder: `/ (root)`
   - Save

3. **GitHub Actions ejecutará automáticamente** `jekyll build`

4. La documentación se desplegará en:
   ```
   https://eddy3o.github.io/rinderline/
   ```

### Opción 2: Build Local y Push

```bash
bundle exec jekyll build

# Agrega el sitio generado
git add _site/
git commit -m "Build static site"
git push origin main
```

---

## 📚 Sintaxis Markdown Recomendada

### Headings

```markdown
# H1 - Título Principal

## H2 - Sección

### H3 - Subsección

#### H4 - Detalles
```

### Tablas

```markdown
| Columna 1 | Columna 2 |
| --------- | --------- |
| Valor 1   | Valor 2   |
```

### Código

```markdown
# Inline code

`variable_name`

# Code block

\`\`\`python
def my_function():
return "Hello"
\`\`\`

# Code block con lenguaje especificado

\`\`\`bash
echo "Hello"
\`\`\`
```

### Énfasis

```markdown
**Negrita**
_Itálica_
~~Tachado~~
```

### Listas

```markdown
- Item 1
- Item 2
  - Sub-item 2.1
  - Sub-item 2.2

1. Primer item
2. Segundo item
3. Tercer item
```

### Links

```markdown
[Texto del link](https://ejemplo.com)
[Link relativo]({% link docs/archivo.md %})
```

### Callouts

```markdown
> **Note:** Este es un callout
> puedes agregar múltiples líneas

> **Warning:** Advertencia importante
```

---

## 🐛 Troubleshooting

### Error: "bundler: command not found"

**Solución:**

```bash
gem install bundler
```

### Error: "Could not find gem 'just-the-docs'"

**Solución:**

```bash
bundle install
```

### La página no se actualiza en localhost

**Solución:**

- Presiona `Ctrl+C` para detener Jekyll
- Ejecuta `bundle exec jekyll serve` nuevamente
- Limpia caché del navegador (Ctrl+Shift+Delete)

### GitHub Pages no actualiza la documentación

**Solución:**

- Verifica que el branch esté en **Settings → Pages**
- Comprueba que el `_config.yml` tiene la URL correcta
- Espera 1-2 minutos a que se ejecuten las GitHub Actions
- Verifica el estado en **Actions** tab

---

## 📖 Recursos Útiles

- [Just-the-Docs Documentation](https://just-the-docs.github.io/just-the-docs/)
- [Jekyll Documentation](https://jekyllrb.com/)
- [Markdown Guide](https://www.markdownguide.org/)
- [GitHub Pages Docs](https://docs.github.com/en/pages)

---

## ⚙️ Variables de Configuración

El archivo `_config.yml` contiene:

| Variable          | Descripción                       |
| ----------------- | --------------------------------- |
| `title`           | Título del sitio                  |
| `description`     | Meta description                  |
| `url`             | URL base (para production)        |
| `baseurl`         | Ruta relativa (para GitHub Pages) |
| `remote_theme`    | Tema remoto de GitHub             |
| `color_scheme`    | Esquema de colores (light/dark)   |
| `search_enabled`  | Habilitar búsqueda (true/false)   |
| `heading_anchors` | Anchors automáticos en headings   |
| `aux_links`       | Links externos en header          |
| `footer_content`  | Contenido del footer              |

---

## 🎓 Tips y Buenas Prácticas

1. **Usa `nav_order`** para controlar el orden de aparición en el sidebar
2. **Agrega `has_children: true`** para crear secciones colapsibles
3. **Mantén frontmatter YAML** siempre al inicio del archivo
4. **Escribe headings descriptivos** para mejorar SEO y navegación
5. **Crea tablas de contenidos** al inicio de documentos largos
6. **Usa ejemplos de código** para aclarar conceptos técnicos
7. **Links internos** con `{% link docs/archivo.md %}`
8. **Imágenes:** Crea carpeta `assets/images/` y referencia como `![alt text](/assets/images/file.jpg)`

---

## 📝 Licencia

Este proyecto está bajo licencia [MIT](LICENSE).

---

**Última actualización:** Diciembre 2025  
**Versión:** 1.0
