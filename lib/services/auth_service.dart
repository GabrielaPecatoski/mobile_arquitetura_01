import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user.dart';
import '../utils/http_helper.dart';
import 'account_store.dart';

class AuthService {
  static Future<User> register({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
  }) {
    return AccountStore.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      username: username,
      password: password,
    );
  }

  static Future<User> login(String username, String password) async {
    final localUser = await AccountStore.authenticate(username, password);
    if (localUser != null) return localUser;

    final body = jsonEncode({
      'username': username,
      'password': password,
      'expiresInMins': 30,
    });

    final http.Response response;
    try {
      response = await HttpHelper.post('/auth/login', body);
    } catch (_) {
      throw Exception(
        'Sem conexão com o servidor. Verifique sua internet ou entre com uma conta criada no app.',
      );
    }

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
