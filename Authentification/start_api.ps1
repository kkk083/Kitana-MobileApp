# ============================================================================
# Script de démarrage rapide pour l'API Kintana Project
# ============================================================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Démarrage de l'API Kintana Project" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier si Python est installé
Write-Host "Vérification de Python..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    Write-Host "✓ Python trouvé: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Python n'est pas installé ou not dans le PATH" -ForegroundColor Red
    exit 1
}

# Vérifier si les dépendances sont installées
Write-Host ""
Write-Host "Vérification des dépendances..." -ForegroundColor Yellow

$pipList = pip list 2>&1
$requiredPackages = @("Flask", "psycopg2", "bcrypt", "PyJWT", "flask-cors")
$missingPackages = @()

foreach ($package in $requiredPackages) {
    if ($pipList -notmatch $package) {
        $missingPackages += $package
    }
}

if ($missingPackages.Count -gt 0) {
    Write-Host "✗ Packages manquants: $($missingPackages -join ', ')" -ForegroundColor Red
    Write-Host ""
    Write-Host "Installation des dépendances..." -ForegroundColor Yellow
    pip install -r requirements.txt
    if ($LASTEXITCODE -ne 0) {
        Write-Host "✗ Erreur lors de l'installation des dépendances" -ForegroundColor Red
        exit 1
    }
    Write-Host "✓ Dépendances installées avec succès" -ForegroundColor Green
} else {
    Write-Host "✓ Toutes les dépendances sont installées" -ForegroundColor Green
}

# Vérifier si PostgreSQL est accessible
Write-Host ""
Write-Host "Vérification de PostgreSQL..." -ForegroundColor Yellow
try {
    $psqlVersion = psql --version 2>&1
    Write-Host "✓ PostgreSQL client trouvé: $psqlVersion" -ForegroundColor Green
} catch {
    Write-Host "⚠ PostgreSQL client non trouvé - Assurez-vous que PostgreSQL est installé" -ForegroundColor Yellow
}

# Vérifier si le fichier .env existe
Write-Host ""
if (Test-Path ".env") {
    Write-Host "✓ Fichier .env trouvé" -ForegroundColor Green
} else {
    Write-Host "⚠ Fichier .env non trouvé" -ForegroundColor Yellow
    Write-Host "  Créez un fichier .env basé sur .env.example" -ForegroundColor Yellow
}

# Démarrer l'application
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Démarrage de l'API..." -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

python app.py
