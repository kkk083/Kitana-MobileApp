<#
.SYNOPSIS
    Générateur de fichiers Flutter pour Kintana Project
.DESCRIPTION
    Ce script crée les fichiers Flutter nécessaires directement dans le projet
    en contournant les limitations d'édition.
#>

$ProjectRoot = "C:\Users\rstev\Documents\DepotGit\kintana_project_GL\kintana_project_GL\view\flutter_application\lib"

# Assurer que les répertoires existent
New-Item -ItemType Directory -Force -Path "$ProjectRoot\models" | Out-Null
New-Item -ItemType Directory -Force -Path "$ProjectRoot\services" | Out-Null
New-Item -ItemType Directory -Force -Path "$ProjectRoot\screens" | Out-Null
New-Item -ItemType Directory -Force -Path "$ProjectRoot\widgets" | Out-Null

Write-Host "Création des fichiers Flutter dans $ProjectRoot..." -ForegroundColor Cyan

# 1. MODEL USER
$UserModelContent = @"
class User {
  final int? idUser;
  final String nom;
  final String email;
  final String role;
  final String? token;
  final String? dateCreation;

  User({
    this.idUser,
    required this.nom,
    required this.email,
    required this.role,
    this.token,
    this.dateCreation,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUser: json['id_user'],
      nom: json['nom'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'etudiant',
      token: json['token'],
      dateCreation: json['date_creation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_user': idUser,
      'nom': nom,
      'email': email,
      'role': role,
      'token': token,
      'date_creation': dateCreation,
    };
  }
}
"@
Set-Content -Path "$ProjectRoot\models\user_model.dart" -Value $UserModelContent -Encoding UTF8
Write-Host "✅ user_model.dart créé" -ForegroundColor Green

# 2. API CONFIG
$ApiConfigContent = @"
class ApiConfig {
  // CONFIGURATION URL - A ADAPTER SELON VOTRE ENVIRONNEMENT
  
  // Pour Web/Chrome (par défaut)
  static const String baseUrl = 'http://localhost:5000/api/auth';
  
  // Pour Android Emulator
  // static const String baseUrl = 'http://10.0.2.2:5000/api/auth';
}
"@
Set-Content -Path "$ProjectRoot\services\api_config.dart" -Value $ApiConfigContent -Encoding UTF8
Write-Host "✅ api_config.dart créé" -ForegroundColor Green

# 3. API SERVICE
$ApiServiceContent = @"
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class ApiService {
  // INSCRIPTION AVEC RÔLE
  static Future<Map<String, dynamic>> register({
    required String nom,
    required String email,
    required String password,
    String role = 'etudiant',
  }) async {
    try {
      print('📤 Envoi inscription: nom=\$nom, email=\$email, role=\$role');
      
      final response = await http.post(
        Uri.parse('\${ApiConfig.baseUrl}/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nom': nom,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      print('📥 Réponse reçue: \${response.statusCode}');
      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        // Note: On ne connecte pas automatiquement ici car on redirige vers le login
        return {
          'success': true,
          'message': data['message'] ?? 'Inscription réussie !',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de l''inscription',
        };
      }
    } catch (e) {
      print('❌ Erreur: \$e');
      return {
        'success': false,
        'message': 'Impossible de se connecter au serveur.',
      };
    }
  }

  // CONNEXION
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('\${ApiConfig.baseUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await _saveToken(data['token']);
        await _saveUser(data['user']);
        return {
          'success': true,
          'message': 'Connexion réussie !',
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur de connexion',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur serveur: \$e'};
    }
  }

  // HELPERS
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> _saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user));
  }
}
"@
Set-Content -Path "$ProjectRoot\services\api_service.dart" -Value $ApiServiceContent -Encoding UTF8
Write-Host "✅ api_service.dart créé" -ForegroundColor Green

# 4. CUSTOM SNACKBAR
$SnackbarContent = @"
import 'package:flutter/material.dart';

class CustomSnackbar {
  static void show(BuildContext context, {required String message, required bool isSuccess}) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(isSuccess ? Icons.check_circle : Icons.error, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
        ],
      ),
      backgroundColor: isSuccess ? Colors.green.shade600 : Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void success(BuildContext context, String message) => show(context, message: message, isSuccess: true);
  static void error(BuildContext context, String message) => show(context, message: message, isSuccess: false);
}
"@
Set-Content -Path "$ProjectRoot\widgets\custom_snackbar.dart" -Value $SnackbarContent -Encoding UTF8
Write-Host "✅ custom_snackbar.dart créé" -ForegroundColor Green

# 5. REGISTER SCREEN
$RegisterScreenContent = @"
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
  
  // Rôle sélectionné par défaut
  String _selectedRole = 'etudiant';
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Liste des rôles
  final List<DropdownMenuItem<String>> _roleItems = const [
    DropdownMenuItem(value: 'etudiant', child: Text('Étudiant')),
    DropdownMenuItem(value: 'professeur', child: Text('Professeur')),
    DropdownMenuItem(value: 'admin', child: Text('Administrateur')),
  ];

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await ApiService.register(
      nom: _nomController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole, // Envoi du rôle
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      if (mounted) {
        CustomSnackbar.success(context, 'Inscription réussie ! Redirection vers la connexion...');
        
        // Attendre 1.5 secondes avant redirection
        await Future.delayed(const Duration(milliseconds: 1500));
        
        if (mounted) {
          // REDIRECTION AUTOMATIQUE VERS LOGIN
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade900, Colors.blue.shade500],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Créer un compte',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 30),

                      TextFormField(
                        controller: _nomController,
                        decoration: InputDecoration(
                          labelText: 'Nom complet',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value!.isEmpty ? 'Requis' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => !value!.contains('@') ? 'Email invalide' : null,
                      ),
                      const SizedBox(height: 16),

                      // LISTE DÉROULANTE POUR LE RÔLE
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          labelText: 'Vous êtes un...',
                          prefixIcon: const Icon(Icons.work),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: _roleItems,
                        onChanged: (value) => setState(() => _selectedRole = value!),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value!.length < 8 ? '8 caractères min' : null,
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade800,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('S''INSCRIRE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: Text("Déjà un compte ? Se connecter", style: TextStyle(color: Colors.blue.shade800)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
"@
Set-Content -Path "$ProjectRoot\screens\register_screen.dart" -Value $RegisterScreenContent -Encoding UTF8
Write-Host "✅ register_screen.dart créé avec redirection automatique" -ForegroundColor Green

# 6. LOGIN SCREEN (Pour s'assurer que la redirection fonctionne)
$LoginScreenContent = @"
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/custom_snackbar.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    
    final result = await ApiService.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      if (mounted) CustomSnackbar.success(context, result['message']);
      // Redirection vers Home ici
    } else {
      if (mounted) CustomSnackbar.error(context, result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Connexion', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Mot de passe', border: OutlineInputBorder())),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _isLoading ? null : _handleLogin, child: const Text('SE CONNECTER'))),
              TextButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: const Text('Créer un compte'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
"@
Set-Content -Path "$ProjectRoot\screens\login_screen.dart" -Value $LoginScreenContent -Encoding UTF8
Write-Host "✅ login_screen.dart créé" -ForegroundColor Green

Write-Host ""
Write-Host "🎉 GÉNÉRATION TERMINÉE ! Fichiers créés dans view/flutter_application/lib/" -ForegroundColor Yellow
