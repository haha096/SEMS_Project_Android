import 'package:dio/dio.dart';
import '../service/api_client.dart';

class AuthRepository {
  Dio get _dio => ApiClient.dio;

  Future<bool> login(String id, String password) async {
    try {
      final res = await _dio.post(
        '/api/user/login',
        data: {'id': id, 'password': password}, // ★ 서버 UserDTO 필드명(id, password)
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> checkSession() async {
    try {
      final r = await _dio.get('/api/user/session',
          options: Options(validateStatus: (_) => true));
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/api/user/logout',
          options: Options(validateStatus: (_) => true));
    } catch (_) {}
  }

  // 서버 살아있는지 확인용(선택)
  Future<bool> health() async {
    try {
      final r = await _dio.get('/', options: Options(validateStatus: (_) => true));
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}