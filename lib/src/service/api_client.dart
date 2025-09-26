import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import '../constants.dart';

class ApiClient {
  static late final Dio dio;
  static late final CookieJar cookieJar;

  static void init() {
    dio = Dio(BaseOptions(
      baseUrl: Env.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      followRedirects: true,
      validateStatus: (s) => s != null && s < 500,
    ));
    cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));
  }
}