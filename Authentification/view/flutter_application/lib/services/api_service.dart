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
      // ignore: avoid_print
      print('Envoi inscription: nom=$nom, email=$email, role=$role');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nom': nom,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      // ignore: avoid_print
      print('Réponse reçue: ${response.body}');
      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Inscription réussie !',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de l\'inscription',
        };
      }
    } catch (e) {
      // ignore: avoid_print
      print('Erreur: $e');
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
        Uri.parse('${ApiConfig.baseUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
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
      return {'success': false, 'message': 'Erreur serveur: $e'};
    }
  }

  // DEMANDE DE RÉINITIALISATION DE MOT DE PASSE
  static Future<Map<String, dynamic>> requestPasswordReset(String email) async {
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
          'message': data['message'],
          'token': data['token'], // ATTENTION : Uniquement pour test/MVP
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de la demande',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur serveur: $e'};
    }
  }

  // RÉINITIALISATION DE MOT DE PASSE
  static Future<Map<String, dynamic>> resetPassword(
    String token,
    String newPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token, 'new_password': newPassword}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de la réinitialisation',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur serveur: $e'};
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
