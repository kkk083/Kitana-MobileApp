# 🚀 Fichiers Flutter à Créer - Instructions Complètes

## ⚠️ IMPORTANT : Les fichiers suivants doivent être créés MANUELLEMENT

Le .gitignore bloque le répertoire `lib/`. Vous devez créer ces fichiers manuellement dans votre projet Flutter.

---

## 📁 FICHIER 1 : `lib/services/api_config.dart`

**Chemin complet** : `view/flutter_application/lib/services/api_config.dart`

```dart
class ApiConfig {
  // ⚠️ IMPORTANT : Modifiez baseUrl selon votre plateforme
  
  // Pour Web (Chrome)
  static const String baseUrl = 'http://localhost:5000/api/auth';
  
  // Pour Android Emulator
  // static const String baseUrl = 'http://10.0.2.2:5000/api/auth';
  
  // Pour appareil physique (remplacez par votre IP)
  // static const String baseUrl = 'http://192.168.1.XXX:5000/api/auth';
}
```

---

## 📁 FICHIER 2 : `lib/services/api_service.dart`

**Chemin complet** : `view/flutter_application/lib/services/api_service.dart`

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
      print('📤 Envoi inscription: nom=$nom, email=$email');
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nom': nom,
          'email': email,
          'password': password,
        }),
      );

      print('📥 Réponse reçue: ${response.statusCode}');
      print('📥 Body: ${response.body}');

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
      print('❌ Erreur: $e');
      return {
        'success': false,
        'message': 'Impossible de se connecter au serveur. Vérifiez que l\'API est démarrée sur http://localhost:5000',
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
      print('📤 Envoi connexion: email=$email');
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('📥 Réponse: ${response.statusCode} - ${response.body}');

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
      print('❌ Erreur: $e');
      return {
        'success': false,
        'message': 'Impossible de se connecter au serveur',
      };
    }
  }

  // ============================================================================
  // MODIFIER LE MOT DE PASSE (SIMPLE - SANS EMAIL)
  // ============================================================================
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'Vous devez être connecté',
        };
      }

      print('📤 Modification mot de passe');
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      print('📥 Réponse: ${response.statusCode} - ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Mot de passe modifié !',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de la modification',
        };
      }
    } catch (e) {
      print('❌ Erreur: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion',
      };
    }
  }

  // ============================================================================
  // VÉRIFIER EMAIL
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
    print('✅ Token sauvegardé');
  }

  static Future<void> _saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user));
    print('✅ User sauvegardé: ${user['nom']}');
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

## 📁 FICHIER 3 : `lib/widgets/custom_snackbar.dart`

**Chemin complet** : `view/flutter_application/lib/widgets/custom_snackbar.dart`

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

## 📋 INSTRUCTIONS D'INSTALLATION

### 1. Ajouter les dépendances

Dans `pubspec.yaml` :

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  shared_preferences: ^2.2.2
```

Puis :
```bash
cd view/flutter_application
flutter pub get
```

### 2. Créer les fichiers

Créez **manuellement** chaque fichier ci-dessus dans votre éditeur de code (VS Code, Android Studio, etc.)

### 3. Modifier vos écrans existants

Ajoutez ces imports en haut de vos fichiers d'écran :

```dart
import '../services/api_service.dart';
import '../widgets/custom_snackbar.dart';
```

---

## 📝 EXEMPLE D'UTILISATION DANS UN ÉCRAN

### Dans votre écran d'inscription :

```dart
Future<void> _handleRegister() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  final result = await ApiService.register(
    nom: _nomController.text.trim(),
    email: _emailController.text.trim(),
    password: _passwordController.text,
  );

  setState(() => _isLoading = false);

  if (result['success']) {
    if (mounted) {
      CustomSnackbar.success(context, result['message']);
      // Naviguer ou rester sur la page
    }
  } else {
    if (mounted) {
      CustomSnackbar.error(context, result['message']);
    }
  }
}
```

### Dans votre écran de connexion :

```dart
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
      // Naviguer vers l'accueil
    }
  } else {
    if (mounted) {
      CustomSnackbar.error(context, result['message']);
    }
  }
}
```

### Dans votre écran de modification de mot de passe :

```dart
Future<void> _handleChangePassword() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  final result = await ApiService.changePassword(
    currentPassword: _currentPasswordController.text,
    newPassword: _newPasswordController.text,
  );

  setState(() => _isLoading = false);

  if (result['success']) {
    if (mounted) {
      CustomSnackbar.success(context, result['message']);
      Navigator.pop(context); // Retour à l'écran précédent
    }
  } else {
    if (mounted) {
      CustomSnackbar.error(context, result['message']);
    }
  }
}
```

---

## 🔍 DÉBOGAGE

Si l'inscription ne fonctionne toujours pas :

### 1. Vérifiez que l'API fonctionne :

Ouvrez votre navigateur et allez sur : `http://localhost:5000/health`

Vous devriez voir :
```json
{
  "status": "healthy",
  "database": "connected",
  "api_version": "1.0.0"
}
```

### 2. Testez l'inscription directement :

Ouvrez la console du navigateur (F12) dans votre app Flutter et regardez les logs.

### 3. Vérifiez les logs de l'API :

Dans le terminal où `python app.py` tourne, vous devriez voir les requêtes arriver.

### 4. Testez avec curl :

```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"nom":"Test User","email":"test@example.com","password":"Test1234"}'
```

---

## ✅ CHECKLIST FINALE

- [ ] Créer `lib/services/api_config.dart`
- [ ] Créer `lib/services/api_service.dart`
- [ ] Créer `lib/widgets/custom_snackbar.dart`
- [ ] Ajouter les dépendances dans `pubspec.yaml`
- [ ] Exécuter `flutter pub get`
- [ ] Modifier les écrans pour utiliser `ApiService`
- [ ] Vérifier que l'API tourne (`http://localhost:5000/health`)
- [ ] Tester une inscription
- [ ] Regarder les logs dans les 2 terminaux (Flask + Flutter)

**Une fois ces étapes faites, l'inscription devrait fonctionner !** 🎉
