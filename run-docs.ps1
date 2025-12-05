# Rinderline Documentation Server Script (Windows PowerShell)
# Este script facilita la ejecucion local de la documentacion con Jekyll

Write-Host "[*] Rinderline Documentation Server" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Verificar si Ruby esta instalado
try {
    $ruby_version = ruby -v 2>$null
    Write-Host "[OK] Ruby encontrado: $ruby_version" -ForegroundColor Green
}
catch {
    Write-Host "[ERROR] Ruby no esta instalado" -ForegroundColor Red
    Write-Host "[INFO] Descargalo desde: https://www.ruby-lang.org/en/downloads/" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Verificar si Bundler esta instalado
try {
    $bundle_version = bundle -v 2>$null
    Write-Host "[OK] Bundler encontrado: $bundle_version" -ForegroundColor Green
}
catch {
    Write-Host "[INFO] Instalando Bundler..." -ForegroundColor Yellow
    gem install bundler
    Write-Host "[OK] Bundler instalado" -ForegroundColor Green
}

Write-Host ""

# Verificar si Gemfile existe
if (-Not (Test-Path "Gemfile")) {
    Write-Host "[ERROR] Gemfile no encontrado" -ForegroundColor Red
    Write-Host "[INFO] Asegurate de estar en la carpeta raiz del proyecto" -ForegroundColor Yellow
    exit 1
}

# Instalar dependencias
Write-Host "[INFO] Instalando dependencias..." -ForegroundColor Yellow
bundle install

Write-Host ""
Write-Host "[*] Construyendo sitio..." -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Ejecutar Jekyll
bundle exec jekyll serve

Write-Host ""
Write-Host "[OK] Servidor detenido" -ForegroundColor Green
