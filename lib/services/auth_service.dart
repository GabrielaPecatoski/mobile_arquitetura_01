import 'dart:convert';
import '../models/user.dart';
import '../utils/http_helper.dart';

class AuthService {
  static Future<User> login(String username, String password) async {
    final body = jsonEncode({
      'username': username,
      'password': password,
      'expiresInMins': 30,
    });

    final response = await HttpHelper.post('/auth/login', body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return User.fromMap(data);
    } else if (response.statusCode == 400 || response.statusCode == 401) {
      throw Exception('Credenciais inválidas. Verifique usuário e senha.');
    } else {
      throw Exception('Erro ao realizar login. Tente novamente.');
    }
  }

  static Future<User> getMe(String token) async {
    final response = await HttpHelper.get('/auth/me', token: token);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      data['accessToken'] = token;
      data['refreshToken'] = '';
      return User.fromMap(data);
    } else {
      throw Exception('Erro ao buscar dados do perfil.');
    }
  }
}
