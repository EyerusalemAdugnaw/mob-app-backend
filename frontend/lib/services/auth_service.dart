import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, data['token']);
          await prefs.setString('user_email', email);
          return {'error': null, 'mustChangePassword': data['user']?['mustChangePassword'] == true};
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {'error': errorData['error'] ?? 'Server error ${response.statusCode}', 'mustChangePassword': false};
        } catch (_) {
          return {'error': 'Server error ${response.statusCode}: ${response.body}', 'mustChangePassword': false};
        }
      }
      return {'error': 'Unexpected error occurred', 'mustChangePassword': false};
    } catch (e) {
      print('Login error: $e');
      return {'error': 'Network error: $e', 'mustChangePassword': false};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove('user_email');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
