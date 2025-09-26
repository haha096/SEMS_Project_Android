import 'package:dio/dio.dart';
import '../service/api_client.dart';

class AuthRepository {
  Dio get _dio => ApiClient.dio;

  Future<bool> health() async {
    final r = await _dio.get('/actuator/health');
    return r.statusCode == 200;
  }

  Future<bool> login(String username, String password) async {
    final r = await _dio.post('/api/user/login', data: {
      'username': username,
      'password': password,
    });
    return r.statusCode == 200 || r.statusCode == 204 || r.statusCode == 302;
  }

  Future<bool> checkSession() async {
    final r = await _dio.get('/api/user/session');
    return r.statusCode == 200;
  }

  Future<void> logout() async {
    await _dio.post('/api/user/logout');
  }
}