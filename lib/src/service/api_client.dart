import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import '../constants.dart';

// class ApiClient {
//   static late final Dio dio;
//   static late final CookieJar cookieJar;
//
//   static void init() {
//     dio = Dio(BaseOptions(
//       baseUrl: Env.baseUrl,
//       connectTimeout: const Duration(seconds: 5),
//       receiveTimeout: const Duration(seconds: 10),
//       followRedirects: true,
//       validateStatus: (s) => s != null && s < 500,
//     ));
//     cookieJar = CookieJar();
//     dio.interceptors.add(CookieManager(cookieJar));
//   }
// }


class ApiClient {
  static late final Dio dio;
  static late final CookieJar cookieJar;

  /// 반드시 앱 시작 시 main()에서 ApiClient.init()을 호출하세요.
  static void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,              // ← http://10.0.2.2:8080 이어야 함
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 10),
        followRedirects: true,
        // 4xx는 throw 안 하고 response로 받게 함
        validateStatus: (s) => s != null && s < 500,
      ),
    );

    cookieJar = CookieJar();
    dio.interceptors
      ..add(CookieManager(cookieJar))
      ..add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
        ),
      );
  }
}