#!/bin/bash

# Rinderline Documentation Server Script
# Este script facilita la ejecución local de la documentación con Jekyll

set -e

echo "🚀 Rinderline Documentation Server"
echo "===================================="
echo ""

# Verificar si Ruby está instalado
if ! command -v ruby &> /dev/null; then
    echo "❌ Error: Ruby no está instalado"
    echo "📥 Descárgalo desde: https://www.ruby-lang.org/en/downloads/"
    exit 1
fi

echo "✅ Ruby encontrado: $(ruby -v)"
echo ""

# Verificar si Bundler está instalado
if ! command -v bundle &> /dev/null; then
    echo "📦 Instalando Bundler..."
    gem install bundler
    echo "✅ Bundler instalado"
    echo ""
fi

# Verificar si Gemfile existe
if [ ! -f "Gemfile" ]; then
    echo "❌ Error: Gemfile no encontrado"
    echo "📁 Asegúrate de estar en la carpeta raíz del proyecto"
    exit 1
fi

# Instalar dependencias
echo "📦 Instalando dependencias..."
bundle install

echo ""
echo "🔨 Construyendo sitio..."
echo "===================================="
echo ""

# Ejecutar Jekyll
bundle exec jekyll serve --baseurl "/rinderline"
