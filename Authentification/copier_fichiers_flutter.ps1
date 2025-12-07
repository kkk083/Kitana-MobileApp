# Script PowerShell pour copier automatiquement les fichiers Flutter
Write-Host ""
Write-Host "================================================================" -ForegroundColor Yellow
Write-Host "  COPIE DES FICHIERS FLUTTER" -ForegroundColor Yellow
Write-Host "================================================================" -ForegroundColor Yellow
Write-Host ""

$projectRoot = $PSScriptRoot
$flutterRoot = Join-Path $projectRoot "view\flutter_application\lib"
$sourceDir = Join-Path $projectRoot "flutter_files"

# Vérifier que le dossier flutter_files existe
if (-not (Test-Path $sourceDir)) {
    Write-Host "[ERREUR] Le dossier flutter_files n'existe pas !" -ForegroundColor Red
    pause
    exit 1
}

Write-Host "[1/4] Creation des dossiers..." -ForegroundColor Cyan

# Créer les dossiers services et widgets
$servicesDir = Join-Path $flutterRoot "services"
$widgetsDir = Join-Path $flutterRoot "widgets"

New-Item -ItemType Directory -Force -Path $servicesDir | Out-Null
New-Item -ItemType Directory -Force -Path $widgetsDir | Out-Null

Write-Host "  - Dossiers crees" -ForegroundColor Green
Write-Host ""

Write-Host "[2/4] Copie des fichiers..." -ForegroundColor Cyan

# Copier les fichiers
$files = @(
    @{Source="api_config.dart"; Dest=$servicesDir; Name="api_config.dart"},
    @{Source="api_service.dart"; Dest=$servicesDir; Name="api_service.dart"},
    @{Source="custom_snackbar.dart"; Dest=$widgetsDir; Name="custom_snackbar.dart"}
)

$copiedCount = 0
foreach ($file in $files) {
    $sourcePath = Join-Path $sourceDir $file.Source
    $destPath = Join-Path $file.Dest $file.Name
    
    if (Test-Path $sourcePath) {
        Copy-Item $sourcePath $destPath -Force
        Write-Host "  + $($file.Name) copie" -ForegroundColor Green
        $copiedCount++
    } else {
        Write-Host "  - $($file.Name) NON TROUVE !" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "[3/4] Verification..." -ForegroundColor Cyan

# Vérifier que les fichiers existent
$allExist = $true
foreach ($file in $files) {
    $destPath = Join-Path $file.Dest $file.Name
    if (Test-Path $destPath) {
        Write-Host "  $([char]0x2713) $($file.Name)" -ForegroundColor Green
    } else {
        Write-Host "  $([char]0x2717) $($file.Name) MANQUANT" -ForegroundColor Red
        $allExist = $false
    }
}

Write-Host ""
Write-Host "[4/4] Installation des dependances..." -ForegroundColor Cyan

# Aller dans le répertoire Flutter
Set-Location (Join-Path $projectRoot "view\flutter_application")

# Installer les dépendances
Write-Host "  - Installation de http et shared_preferences..." -ForegroundColor Yellow
flutter pub add http shared_preferences 2>&1 | Out-Null
flutter pub get 2>&1 | Out-Null

Write-Host "  - Dependances installees" -ForegroundColor Green
Write-Host ""

# Retourner au répertoire racine
Set-Location $projectRoot

if ($copiedCount -eq 3 -and $allExist) {
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host "  COPIE REUSSIE ! ($copiedCount/3 fichiers)" -ForegroundColor Green
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "PROCHAINES ETAPES:" -ForegroundColor Yellow
    Write-Host "  1. Ouvrez vos ecrans Flutter (register_screen.dart, etc.)" -ForegroundColor White
    Write-Host "  2. Ajoutez les imports:" -ForegroundColor White
    Write-Host "     import '../services/api_service.dart';" -ForegroundColor Cyan
    Write-Host "     import '../widgets/custom_snackbar.dart';" -ForegroundColor Cyan
    Write-Host "  3. Utilisez ApiService.register(), login(), etc." -ForegroundColor White
    Write-Host "  4. Relancez : flutter run -d chrome" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "================================================================" -ForegroundColor Red
    Write-Host "  ERREUR - Certains fichiers n'ont pas pu etre copies" -ForegroundColor Red
    Write-Host "================================================================" -ForegroundColor Red
}

Write-Host "Appuyez sur une touche pour fermer..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
