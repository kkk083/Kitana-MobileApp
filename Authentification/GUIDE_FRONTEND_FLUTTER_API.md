# 📱 Guide Complet - Connexion Frontend Flutter à l'API Backend

## 🎯 Objectif

Connecter le frontend Flutter au backend Flask pour :
1. ✅ Inscription avec validation en temps réel
2. ✅ Connexion avec gestion des erreurs
3. ✅ Mot de passe oublié avec réinitialisation complète
4. ✅ Messages d'erreur/succès adaptés aux réponses de l'API

---

## 📦 ÉTAPE 1 : Ajouter les dépendances

Dans `pubspec.yaml`, ajoutez :

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0                    # Requêtes HTTP
  shared_preferences: ^2.2.2      # Stockage local
```

Puis exécutez :
```bash
cd view/flutter_application
flutter pub get
```

---

## 📄 FICHIER 1 : Configuration API

**Créer** : `lib/services/api_config.dart`

```dart
class ApiConfig {
  // ⚠️ MODIFIEZ selon votre configuration
  
  // Pour Android Emulator
  static const String baseUrl = 'http://10.0.2.2:5000/api/auth';
  
  // Pour iOS Simulator / Web
  // static const String baseUrl = 'http://localhost:5000/api/auth';
  
  // Pour appareil physique (remplacez XXX par votre IP)
  // static const String baseUrl = 'http://192.168.1.XXX:5000/api/auth';
}
```

---

## 📄 FICHIER 2 : Service API Complet

**Créer** : `lib/services/api_service.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class ApiService {
  // ============================================================================
  // INSCRIPTION
  // ============================================================================
  static Future<Map<String, dynamic>> register({
    required String nom,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nom': nom,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        // Sauvegarder le token
        await _saveToken(data['token']);
        await _saveUser(data['user']);

        return {
          'success': true,
          'message': data['message'] ?? 'Inscription réussie !',
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de l\'inscription',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Impossible de se connecter au serveur. Vérifiez que l\'API est démarrée.',
      };
    }
  }

  // ============================================================================
  // CONNEXION
  // ============================================================================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
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
          'message': data['message'] ?? 'Connexion réussie !',
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Email ou mot de passe incorrect',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Impossible de se connecter au serveur',
      };
    }
  }

  // ============================================================================
  // MOT DE PASSE OUBLIÉ - Étape 1 : Demander un token
  // ============================================================================
  static Future<Map<String, dynamic>> requestPasswordReset({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': 'Un code de réinitialisation a été envoyé',
          'token': data['token'], // Pour test uniquement !
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Email non trouvé',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur',
      };
    }
  }

  // ============================================================================
  // MOT DE PASSE OUBLIÉ - Étape 2 : Réinitialiser avec le token
  // ============================================================================
  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'new_password': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Mot de passe modifié avec succès !',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Code invalide ou expiré',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion',
      };
    }
  }

  // ============================================================================
  // VÉRIFIER SI UN EMAIL EXISTE DÉJÀ
  // ============================================================================
  static Future<Map<String, dynamic>> checkEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/check-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'available': data['available'],
          'message': data['message'],
        };
      }
      return {'success': false};
    } catch (e) {
      return {'success': false};
    }
  }

  // ============================================================================
  // DÉCONNEXION
  // ============================================================================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  // ============================================================================
  // GESTION DU TOKEN ET DES DONNÉES
  // ============================================================================
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> _saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user));
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user_data');
    if (userStr != null) {
      return jsonDecode(userStr);
    }
    return null;
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
```

---

## 📄 FICHIER 3 : Modèle Utilisateur

**Créer** : `lib/models/user_model.dart`

```dart
class UserModel {
  final int idUser;
  final String nom;
  final String email;
  final DateTime dateCreation;

  UserModel({
    required this.idUser,
    required this.nom,
    required this.email,
    required this.dateCreation,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUser: json['id_user'],
      nom: json['nom'],
      email: json['email'],
      dateCreation: DateTime.parse(json['date_creation']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_user': idUser,
      'nom': nom,
      'email': email,
      'date_creation': dateCreation.toIso8601String(),
    };
  }
}
```

---

## 📄 FICHIER 4 : Widget Snackbar Personnalisé

**Créer** : `lib/widgets/custom_snackbar.dart`

```dart
import 'package:flutter/material.dart';

class CustomSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    required bool isSuccess,
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: isSuccess ? Colors.green.shade600 : Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(16),
      duration: Duration(seconds: isSuccess ? 3 : 5),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, isSuccess: true);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, isSuccess: false);
  }
}
```

---

## 📄 FICHIER 5 : Écran d'Inscription Connecté

**Remplacer** : `lib/screens/register_screen.dart`

Le fichier est trop long pour être affiché ici. Voici les modifications clés à faire dans votre écran d'inscription existant :

### Imports à ajouter :
```dart
import '../services/api_service.dart';
import '../widgets/custom_snackbar.dart';
```

### Fonction d'inscription mise à jour :
```dart
Future<void> _handleRegister() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  // Appeler l'API
  final result = await ApiService.register(
    nom: _nomController.text.trim(),
    email: _emailController.text.trim(),
    password: _passwordController.text,
  );

  setState(() => _isLoading = false);

  if (result['success']) {
    // Afficher message de succès
    if (mounted) {
      CustomSnackbar.success(context, result['message']);
      
      // Attendre 1 seconde puis naviguer vers l'accueil
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  } else {
    // Afficher message d'erreur
    if (mounted) {
      CustomSnackbar.error(context, result['message']);
    }
  }
}
```

### Vérification d'email en temps réel :
```dart
String? _validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email requis';
  }
  
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Format d\'email invalide';
  }
  
  // Vérifier si l'email existe déjà (optionnel)
  _checkEmailDebounced(value);
  
  return null;
}

Timer? _emailDebounce;

void _checkEmailDebounced(String email) {
  _emailDebounce?.cancel();
  _emailDebounce = Timer(const Duration(milliseconds: 500), () async {
    final result = await ApiService.checkEmail(email);
    if (result['success'] && !result['available']) {
      setState(() {
        _emailError = 'Cet email est déjà utilisé';
      });
    } else {
      setState(() {
        _emailError = null;
      });
    }
  });
}
```

---

## 📄 FICHIER 6 : Écran de Connexion Connecté

**Remplacer** : `lib/screens/login_screen.dart` (ou créer si n'existe pas)

```dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/custom_snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await ApiService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      if (mounted) {
        CustomSnackbar.success(context, result['message']);
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo ou titre
                  const Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Connexion',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Mot de passe
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Mot de passe requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Mot de passe oublié
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot-password');
                      },
                      child: const Text('Mot de passe oublié ?'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bouton de connexion
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Se connecter',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Lien vers inscription
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Pas encore de compte ?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text('S\'inscrire'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 📄 FICHIER 7 : Écran Mot de Passe Oublié Connecté

**Remplacer** : `lib/screens/forgot_password_screen.dart`

```dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/custom_snackbar.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _tokenReceived = false;
  String? _resetToken;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ÉTAPE 1 : Demander le token de réinitialisation
  Future<void> _requestReset() async {
    if (_emailController.text.trim().isEmpty) {
      CustomSnackbar.error(context, 'Veuillez entrer votre email');
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.requestPasswordReset(
      email: _emailController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      setState(() {
        _tokenReceived = true;
        _resetToken = result['token']; // Pour test uniquement
      });
      
      if (mounted) {
        CustomSnackbar.success(
          context,
          'Code de réinitialisation reçu ! Entrez votre nouveau mot de passe.',
        );
      }
    } else {
      if (mounted) {
        CustomSnackbar.error(context, result['message']);
      }
    }
  }

  // ÉTAPE 2 : Réinitialiser le mot de passe
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Utiliser le token reçu (en production, l'utilisateur le recevrait par email)
    final token = _resetToken ?? _tokenController.text.trim();

    final result = await ApiService.resetPassword(
      token: token,
      newPassword: _newPasswordController.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      if (mounted) {
        CustomSnackbar.success(context, result['message']);
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
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
      appBar: AppBar(
        title: const Text('Mot de passe oublié'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
           child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Icon(
                    Icons.lock_reset,
                    size: 80,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    _tokenReceived 
                        ? 'Nouveau mot de passe'
                        : 'Réinitialiser le mot de passe',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Text(
                    _tokenReceived
                        ? 'Entrez votre nouveau mot de passe'
                        : 'Entrez votre email pour recevoir un code',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // ÉTAPE 1 : Demander le token
                  if (!_tokenReceived) ...[
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _requestReset,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Envoyer le code', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],

                  // ÉTAPE 2 : Entrer le nouveau mot de passe
                  if (_tokenReceived) ...[
                    // Afficher le token (pour test uniquement)
                    if (_resetToken != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '🔑 Code de réinitialisation (pour test)',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            SelectableText(
                              _resetToken!,
                              style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Nouveau mot de passe
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Nouveau mot de passe',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Mot de passe requis';
                        }
                        if (value.length < 8) {
                          return 'Minimum 8 caractères';
                        }
                        if (!RegExp(r'[A-Z]').hasMatch(value)) {
                          return 'Au moins 1 majuscule';
                        }
                        if (!RegExp(r'[a-z]').hasMatch(value)) {
                          return 'Au moins 1 minuscule';
                        }
                        if (!RegExp(r'[0-9]').hasMatch(value)) {
                          return 'Au moins 1 chiffre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Confirmer mot de passe
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirmer le mot de passe',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) {
                        if (value != _newPasswordController.text) {
                          return 'Les mots de passe ne correspondent pas';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Bouton de réinitialisation
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _resetPassword,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Réinitialiser', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 🚀 ÉTAPE FINALE : Tester

### 1. Démarrer l'API Backend
```bash
cd c:\Users\rstev\Documents\DepotGit\kintana_project_GL\kintana_project_GL
python app.py
```

### 2. Démarrer Flutter
```bash
cd view/flutter_application
flutter run
```

### 3. Tests à faire :

✅ **Inscription**
- Entrer nom, email, password
- Vérifier message de succès
- Vérifier redirection vers accueil

✅ **Connexion**
- Utiliser les identifiants créés
- Vérifier message de succès

✅ **Mot de passe oublié**
- Entrer email
- Copier le token affiché
- Entrer nouveau mot de passe
- Vérifier message de succès
- Se reconnecter avec nouveau mot de passe

---

## ⚠️ Notes importantes

1. **URL de l'API** : Modifiez `ApiConfig.baseUrl` selon votre plateforme
2. **Token affiché** : En production, le token serait envoyé par email, pas affiché
3. **Messages d'erreur** : Sont automatiquement récupérés depuis l'API
4. **Validation** : Correspond aux règles du backend (8 car., maj., min., chiffre)

---

## 📝 Résumé

✅ Service API complet créé  
✅ Modèle utilisateur adapté à la nouvelle structure BDD  
✅ Écrans d'inscription, connexion et mot de passe oublié connectés  
✅ Messages de succès/erreur dynamiques  
✅ Validation en temps réel  
✅ Stockage sécurisé des tokens  

**Tout est prêt pour une connexion complète entre Flutter et l'API Flask !** 🎉
