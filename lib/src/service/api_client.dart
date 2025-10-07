import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ApiClient {
  static Dio? _dio;

  // 최초 1회 초기화 + Dio 반환
  static Future<Dio> get instance async {
    if (_dio != null) return _dio!;

    final dio = Dio(BaseOptions(
      //baseUrl: "http://10.0.2.2:8080",
      baseUrl : "http://127.0.0.1:8080",
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (_) => true,
    ));

    // 영구 쿠키 저장 (JSESSIONID 유지)
    final dir = await getApplicationDocumentsDirectory();
    final jar = PersistCookieJar(
      storage: FileStorage(p.join(dir.path, ".cookies")),
      ignoreExpires: false,
    );
    dio.interceptors.add(CookieManager(jar));

    _dio = dio;
    return _dio!;
  }

  // ✅ 기존 코드 호환용: ApiClient.dio 로 접근 가능하게
  static Dio get dio {
    final d = _dio;
    if (d == null) {
      throw StateError('ApiClient not initialized. Call `await ApiClient.instance` first.');
    }
    return d;
  }
}