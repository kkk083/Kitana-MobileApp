$ProjectRoot = "C:\Users\rstev\Documents\DepotGit\kintana_project_GL\kintana_project_GL\view\flutter_application\lib"

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "   NETTOYAGE ET VALIDATION FLUTTER" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan

# 1. SUPPRIMER LES FICHIERS OBSOLÈTES
Write-Host "1. Suppression des fichiers obsoletes..." -ForegroundColor Yellow

$filesToDelete = @(
    "$ProjectRoot\screens\auth_screen.dart",
    "$ProjectRoot\services\auth_service_example.dart",
    "$ProjectRoot\screens\home_screen_example.dart",
    "$ProjectRoot\widgets\kintana_widgets.dart",
    "$ProjectRoot\widgets\sparkle_icon.dart"
)

foreach ($file in $filesToDelete) {
    if (Test-Path $file) {
        Remove-Item $file -Force
        Write-Host "   - Supprime: $file" -ForegroundColor Red
    }
}

# 2. RÉÉCRIRE REGISTER_SCREEN (Sécurité)
Write-Host "2. Validation de register_screen.dart..." -ForegroundColor Yellow

$RegisterContent = @"
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/custom_snackbar.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // ROLE PAR DEFAUT
  String _selectedRole = 'etudiant';
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  // LISTE DES ROLES
  final List<DropdownMenuItem<String>> _roleItems = const [
    DropdownMenuItem(value: 'etudiant', child: Text('Étudiant')),
    DropdownMenuItem(value: 'professeur', child: Text('Professeur')),
    DropdownMenuItem(value: 'admin', child: Text('Administrateur')),
  ];

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // APPEL API AVEC ROLE
    final result = await ApiService.register(
      nom: _nomController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      if (mounted) {
        CustomSnackbar.success(context, 'Inscription réussie ! Redirection...');
        // DELAI PUIS REDIRECTION AUTOMATIQUE
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } else {
      if (mounted) {
        CustomSnackbar.error(context, result['message']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Créer un compte', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _nomController,
                  decoration: const InputDecoration(labelText: 'Nom', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
                  validator: (v) => !v!.contains('@') ? 'Invalide' : null,
                ),
                const SizedBox(height: 16),
                // MENU DEROULANT ROLE
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Rôle', border: OutlineInputBorder(), prefixIcon: Icon(Icons.work)),
                  items: _roleItems,
                  onChanged: (v) => setState(() => _selectedRole = v!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) => v!.length < 8 ? '8 caractères min' : null,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading ? const CircularProgressIndicator() : const Text('S''INSCRIRE'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: const Text('Déjà un compte ? Se connecter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
"@
Set-Content -Path "$ProjectRoot\screens\register_screen.dart" -Value $RegisterContent -Encoding UTF8
Write-Host "   - register_screen.dart mis a jour" -ForegroundColor Green


# 3. VERIFIER MAIN.DART
Write-Host "3. Mise a jour main.dart..." -ForegroundColor Yellow

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
Set-Content -Path "$ProjectRoot\main.dart" -Value $MainContent -Encoding UTF8
Write-Host "   - main.dart pointe sur LoginScreen" -ForegroundColor Green

Write-Host ""
Write-Host "✅ NETTOYAGE TERMINE !" -ForegroundColor Green
Write-Host "Relancez Flutter (R) maintenant." -ForegroundColor Cyan
