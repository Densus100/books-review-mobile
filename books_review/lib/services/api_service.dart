import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';

  static Future<http.Response> post(String endpoint, Map<String, dynamic> data, {String? token}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return response;
  }

  static Future<http.Response> get(String endpoint, {String? token}) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    return response;
  }

  // Books (public)
  static Future<http.Response> getBooks() async {
    return get('/books');
  }
  static Future<http.Response> getBookById(String id) async {
    return get('/books/$id');
  }

  // Reviews (public)
  static Future<http.Response> getReviewsByBookId(String bookId) async {
    return get('/books/$bookId/reviews');
  }
  static Future<http.Response> createReview(Map<String, dynamic> data, String token) async {
    return post('/reviews', data, token: token);
  }

  // Favorites (user)
  static Future<http.Response> getFavorites(String token) async {
    return get('/favorites', token: token);
  }
  static Future<http.Response> addFavorite(int bookId, String token) async {
    return post('/favorites', {'bookId': bookId}, token: token);
  }
  static Future<http.Response> removeFavorite(String id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/favorites/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response;
  }
}
