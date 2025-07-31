import 'dart:convert';
import 'package:books_review/models/user.dart';
import 'api_service.dart';

class AuthService {
  static Future<User?> login(String username, String password) async {
    final response = await ApiService.post('/login', {
      'username': username,
      'password': password,
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    }
    return null;
  }
}
