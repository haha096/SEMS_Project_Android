import 'dart:convert';
import 'package:dio/dio.dart';

class EnvironmentApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:8080', // 에뮬=10.0.2.2, 실기기=PC IP
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 10),
  ))..interceptors.add(LogInterceptor(
      request: true, requestBody: true, responseBody: true, error: true));

  // 실내 최신 (MQTT → DB)
  Future<Map<String, dynamic>> fetchIndoorNow() async {
    final r = await _dio.get('/sensor/latest');
    return Map<String, dynamic>.from(r.data);
  }

  // 실외 현재 (날씨 + 먼지)
  Future<Map<String, dynamic>> fetchOutdoorNow() async {
    // 1) 날씨: 컨트롤러가 String(JSON) 반환 → decode 필요
    final weatherRes = await _dio.get('/weather/outdoor');
    final String weatherText = weatherRes.data is String
        ? weatherRes.data
        : weatherRes.data.toString();
    final weatherJson = jsonDecode(weatherText);

    // TODO: 실제 키 경로 맞추기 (예시는 temp/hum로 가정)
    final double? temp = _asDouble(_pick(weatherJson, ['temp', 'temperature', 'ta']));
    final double? hum  = _asDouble(_pick(weatherJson, ['hum', 'humidity', 'rh']));

    // 2) 먼지: DustDto 바로 JSON
    final dustRes = await _dio.get('/api/dust');
    final dust = Map<String, dynamic>.from(dustRes.data);
    final double? pm10 = _asDouble(dust['pm10']);
    final double? pm25 = _asDouble(dust['pm25']);

    return {
      'temp': temp,
      'hum': hum,
      'pm10': pm10,
      'pm25': pm25,
    };
  }

  // 유틸
  dynamic _pick(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      if (m.containsKey(k)) return m[k];
    }
    return null;
  }
  double? _asDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}