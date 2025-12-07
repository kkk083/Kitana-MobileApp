$PubspecPath = "C:\Users\rstev\Documents\DepotGit\kintana_project_GL\kintana_project_GL\view\flutter_application\pubspec.yaml"
$MainPath = "C:\Users\rstev\Documents\DepotGit\kintana_project_GL\kintana_project_GL\view\flutter_application\lib\main.dart"
$FlutterPath = "C:\Users\rstev\Documents\DepotGit\kintana_project_GL\kintana_project_GL\view\flutter_application"

Write-Host "1. Ajout des dependances..." -ForegroundColor Cyan

# Lire le contenu
$content = Get-Content -Path $PubspecPath -Raw

if ($content -notmatch "http:") {
    # Remplacer flutter: par les dépendances + flutter:
    # Attention aux espaces qui sont importants en YAML
    $newDependencies = "  http: ^1.1.0`n  shared_preferences: ^2.2.2`n  flutter:"
    $content = $content -replace "  flutter:", $newDependencies
    Set-Content -Path $PubspecPath -Value $content -Encoding UTF8
    Write-Host "   - Dependances ajoutees" -ForegroundColor Green
} else {
    Write-Host "   - Dependances deja presentes" -ForegroundColor Yellow
}

Write-Host "2. Installation (flutter pub get)..." -ForegroundColor Cyan
Set-Location -Path $FlutterPath
cmd /c "flutter pub get"

Write-Host "3. Mise a jour de main.dart..." -ForegroundColor Cyan

$MainContent = @"
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

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
Write-Host "   - main.dart mis a jour" -ForegroundColor Green

Write-Host ""
Write-Host "TERMINE ! Relancez Flutter (R dans le terminal)" -ForegroundColor Green
