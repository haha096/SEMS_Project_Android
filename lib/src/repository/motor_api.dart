// lib/src/repository/motor_api.dart
import 'package:dio/dio.dart';
import 'package:sems_project/src/service/api_client.dart';

class MotorApi {
  static Dio get _dio => ApiClient.dio;

  /// 전원 on/off
  static Future<String> power(bool on) async {
    final res = await _dio.post(
      '/api/motor/power',
      data: {'on': on},
      options: Options(validateStatus: (_) => true),
    );
    if (res.statusCode == 200) {
      // 컨트롤러가 text/plain으로 "전원 ON/OFF 명령 전송 완료" 반환
      return res.data?.toString() ?? 'OK';
    }
    throw Exception('POWER 실패: ${res.statusCode} ${res.data}');
  }

  /// AUTO 모드
  static Future<String> auto() async {
    final res = await _dio.get(
      '/api/motor/auto',
      options: Options(validateStatus: (_) => true),
    );
    if (res.statusCode == 200) {
      return res.data?.toString() ?? 'OK';
    }
    throw Exception('AUTO 실패: ${res.statusCode} ${res.data}');
  }

  /// MANUAL + 속도(level 1~3)
  static Future<String> manual(int level) async {
    final res = await _dio.post(
      '/api/motor/manual',
      data: {'level': level},
      options: Options(validateStatus: (_) => true),
    );
    if (res.statusCode == 200) {
      return res.data?.toString() ?? 'OK';
    }
    throw Exception('MANUAL 실패: ${res.statusCode} ${res.data}');
  }
}