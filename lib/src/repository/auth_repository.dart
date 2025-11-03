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
        '/api/auth/login',
        data: {'id': id, 'password': password}, // 백엔드 파라미터명에 맞춰 필요시 조정
      );
      print('로그인 응답: ${res.statusCode} ${res.data}');

      if (res.statusCode != 200) return false;

      // 세션(쿠키) 기반 성공 케이스: 토큰이 없어도 200이면 성공 처리
      // 만약 JWT도 내려오면 저장(하이브리드 대응)
      String? token;
       final data = res.data;
       if (data is Map && data['token'] is String) {
         token = data['token'] as String;
       } else {
         token = res.headers.map['authorization']?.first;
       }
       if (token != null && token.isNotEmpty) {
         if (token.toLowerCase().startsWith('bearer ')) {
           token = token.substring(7);
         }
         await ApiClient.saveToken(token);
       }
       return true;
    } on DioError catch (e) {
      print('로그인 DioError: ${e.response?.statusCode} ${e.response?.data}');
      return false;
    } catch (e) {
      print('로그인 일반 오류: $e');
      return false;
    }
  }

  Future<bool> meOk() async {
    try {
      final r = await _dio.get('/api/auth/me',
          options: Options(validateStatus: (_) => true));
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Future<bool> checkSession() async {
  //   for (final p in ['/api/user/session', '/api/user/me', '/me']) {
  //     try {
  //       final r = await _dio.get(p, options: Options(validateStatus: (_) => true));
  //       if (r.statusCode == 200) return true;
  //     } catch (_) {}
  //   }
  //   return false;
  // }

  Future<bool> checkSession() async {
    try {
      final r = await _dio.get(
        '/api/auth/session',
        options: Options(validateStatus: (_) => true),
      );
      print('session 응답: ${r.statusCode} ${r.data}');
      return r.statusCode == 200;
    } catch (e) {
      print('checkSession 오류: $e');
      return false;
    }
  }

  Future<void> logout() async {
    for (final p in ['/api/auth/logout', '/logout']) {
      try { await _dio.post(p, options: Options(validateStatus: (_) => true)); } catch (_) {}
    }
  }
}