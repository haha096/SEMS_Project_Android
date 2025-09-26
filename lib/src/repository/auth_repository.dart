import 'package:dio/dio.dart';
import '../service/api_client.dart';

class AuthRepository {
  Dio get _dio => ApiClient.dio;

  Future<bool> login(String username, String password) async {
    final candidates = [
      // REST 스타일
      _LoginCall(path: '/api/user/login', asForm: false),
      // Spring formLogin
      _LoginCall(path: '/login', asForm: true),
    ];

    for (final c in candidates) {
      try {
        final res = await _dio.post(
          c.path,
          data: {'username': username, 'password': password},
          options: c.asForm
              ? Options(
            contentType: Headers.formUrlEncodedContentType,
            followRedirects: false,
            validateStatus: (_) => true, // 302 포함
          )
              : null,
        );
        final ok = res.statusCode == 200 || res.statusCode == 204 || res.statusCode == 302;
        if (ok) return true;
        // 401/403이면 더 시도해도 소용없으니 바로 실패 처리
        if (res.statusCode == 401 || res.statusCode == 403) return false;
      } catch (_) {/* 다음 후보로 */}
    }
    return false;
  }

  Future<bool> checkSession() async {
    final candidates = [
      '/api/user/session',
      '/api/user/me',
      '/user/me',
      '/me',
    ];
    for (final p in candidates) {
      try {
        final r = await _dio.get(p, options: Options(validateStatus: (_) => true));
        if (r.statusCode == 200) return true;
      } catch (_) {/* 계속 시도 */}
    }
    return false;
  }

  Future<void> logout() async {
    // 두 가지 다 시도
    for (final p in ['/api/user/logout', '/logout']) {
      try { await _dio.post(p, options: Options(validateStatus: (_) => true)); } catch (_) {}
    }
  }
}

class _LoginCall {
  final String path;
  final bool asForm;
  _LoginCall({required this.path, this.asForm = false});
}