$PubspecPath = "C:\Users\rstev\Documents\DepotGit\kintana_project_GL\kintana_project_GL\view\flutter_application\pubspec.yaml"
$MainPath = "C:\Users\rstev\Documents\DepotGit\kintana_project_GL\kintana_project_GL\view\flutter_application\lib\main.dart"
$FlutterPath = "C:\Users\rstev\Documents\DepotGit\kintana_project_GL\kintana_project_GL\view\flutter_application"

# 1. Ajouter les dépendances au pubspec.yaml
Write-Host "Ajout des dépendances dans pubspec.yaml..." -ForegroundColor Cyan

# Lire le contenu actuel
$content = Get-Content -Path $PubspecPath -Raw

# Vérifier si http est déjà présent (pour éviter les doublons)
if ($content -notmatch "http:") {
    # Insérer les dépendances sous "dependencies:"
    # On cherche "flutter:" sous dependencies et on insère avant
    $content = $content -replace "  flutter:", "  http: ^1.1.0`n  shared_preferences: ^2.2.2`n  flutter:"
    Set-Content -Path $PubspecPath -Value $content -Encoding UTF8
    Write-Host "✅ Dépendances http et shared_preferences ajoutées" -ForegroundColor Green
} else {
    Write-Host "ℹ️ Dépendances déjà présentes" -ForegroundColor Yellow
}

# 2. Lancer flutter pub get
Write-Host "Installation des dépendances..." -ForegroundColor Cyan
Set-Location -Path $FlutterPath
# Utiliser cmd /c pour lancer flutter car c'est un fichier batch
cmd /c "flutter pub get"
Write-Host "✅ flutter pub get terminé" -ForegroundColor Green

# 3. Corriger main.dart pour pointer vers LoginScreen
Write-Host "Mise à jour de main.dart..." -ForegroundColor Cyan

$MainContent = @"
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
// import 'screens/register_screen.dart'; // Décommenter pour commencer par l'inscription

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kintana Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
"@

Set-Content -Path $MainPath -Value $MainContent -Encoding UTF8
Write-Host "✅ main.dart mis à jour" -ForegroundColor Green

Write-Host ""
Write-Host "🎉 TOUT EST PRÊT ! RELANCEZ FLUTTER (Appuyez sur 'R' dans le terminal flutter)" -ForegroundColor Yellow
