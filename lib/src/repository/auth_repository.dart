import 'package:dio/dio.dart';
import '../service/api_client.dart';

class AuthRepository {
  Dio get _dio => ApiClient.dio;

  Future<bool> health() async {
    try {
      final r = await _dio.get('/'); // 혹은 헬스엔드포인트 있으면 거기로
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> login(String id, String password) async {
    try {
      final res = await _dio.post(
        '/api/user/login',
        data: {'id': id, 'password': password},
      );

      print('로그인 응답: ${res.statusCode} ${res.data}');
      if (res.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on DioError catch (e) {
      print('로그인 DioError: ${e.response?.statusCode} ${e.response?.data}');
      return false;
    } catch (e) {
      print('로그인 일반 오류: $e');
      return false;
    }
  }

  Future<bool> checkSession() async {
    for (final p in ['/api/user/session', '/api/user/me', '/me']) {
      try {
        final r = await _dio.get(p, options: Options(validateStatus: (_) => true));
        if (r.statusCode == 200) return true;
      } catch (_) {}
    }
    return false;
  }

  Future<void> logout() async {
    for (final p in ['/api/user/logout', '/logout']) {
      try { await _dio.post(p, options: Options(validateStatus: (_) => true)); } catch (_) {}
    }
  }
}