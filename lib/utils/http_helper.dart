import 'package:http/http.dart' as http;

class HttpHelper {
  static const String _baseUrl = 'https://dummyjson.com';

  static Map<String, String> _headers({String? token}) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<http.Response> get(String path, {String? token}) {
    return http.get(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(token: token),
    );
  }

  static Future<http.Response> post(
    String path,
    String body, {
    String? token,
  }) {
    return http.post(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(token: token),
      body: body,
    );
  }
}
