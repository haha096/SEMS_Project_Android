import 'package:dio/dio.dart';
import '../service/api_client.dart';

class MotorApi {
  static final Dio _dio = ApiClient.dio;

  static Future<String> power(bool on) async {
    try {
      final r = await _dio.post('/api/motor/power', data: {'on': on});
      return 'HTTP ${r.statusCode} / ${r.data}';
    } on DioException catch (e) {
      return 'ERR ${e.response?.statusCode} / ${e.response?.data ?? e.message}';
    }
  }

  static Future<String> auto() async {
    try {
      final r = await _dio.get('/api/motor/auto');
      return 'HTTP ${r.statusCode} / ${r.data}';
    } on DioException catch (e) {
      return 'ERR ${e.response?.statusCode} / ${e.response?.data ?? e.message}';
    }
  }

  static Future<String> manual(int level) async {
    try {
      final r = await _dio.post('/api/motor/manual', data: {'level': level});
      return 'HTTP ${r.statusCode} / ${r.data}';
    } on DioException catch (e) {
      return 'ERR ${e.response?.statusCode} / ${e.response?.data ?? e.message}';
    }
  }
}