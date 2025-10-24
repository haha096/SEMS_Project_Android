import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// 무선 디버깅 방법
// 1. cmd에서 cd C:\Users\사용자\AppData\Local\Android\Sdk\platform-tools
// 들어가서 adb devices로 connect된 device들 확인
// 없으면 adb connect (무선 디버깅의 폰의) IP:포트 로 연결하고
// adb reverse tcp:8080 tcp:8080 명령어 쳐서 서버랑 연결

//2. 안드로이드에서 무선 디버깅 연결
// 개발자모드에서 무선디버깅 킨 다음 IP주소와 포트 확인해서 1번을 수행

class ApiClient {
  static Dio? _dio;

  // 최초 1회 초기화 + Dio 반환
  static Future<Dio> get instance async {
    if (_dio != null) return _dio!;

    final dio = Dio(BaseOptions(
      //baseUrl: "http://10.0.2.2:8080",
      //baseUrl : "http://192.168.56.1:8080",
      baseUrl : "http://127.0.0.1:8080",
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (_) => true,
    ));

    dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
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