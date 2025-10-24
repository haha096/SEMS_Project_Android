// lib/src/model/outdoor_data.dart

class OutdoorData {
  final double? temp;        // 실외 온도
  final double? humidity;    // 실외 습도
  final double? windSpeed;   // 풍속
  final String? windDir;     // 풍향 (예: N, NE, SW)
  final String? weather;     // 날씨 코드 or 상태명
  final double? pm10;        // 미세먼지
  final double? pm25;        // 초미세먼지
  final String? source;      // 데이터 출처 (ultra, asos, open-meteo)
  final DateTime? updatedAt; // 갱신 시각

  OutdoorData({
    this.temp,
    this.humidity,
    this.windSpeed,
    this.windDir,
    this.weather,
    this.pm10,
    this.pm25,
    this.source,
    this.updatedAt,
  });

  /// ✅ 백엔드에서 받은 JSON(Map)을 Dart 객체로 변환
  factory OutdoorData.fromJson(Map<String, dynamic> weatherJson, Map<String, dynamic> dustJson) {
    double? _d(v) => v == null
        ? null
        : (v is num ? v.toDouble() : double.tryParse(v.toString()));

    DateTime? _t(v) => v == null ? null : DateTime.tryParse(v.toString());

    final pm10 = _d(dustJson['pm10Value'] ?? dustJson['pm10']);
    final pm25 = _d(dustJson['pm25Value'] ?? dustJson['pm25']);

    return OutdoorData(
      temp: _d(weatherJson['temp'] ?? weatherJson['temperature']),
      humidity: _d(weatherJson['humidity'] ?? weatherJson['hum']),
      windSpeed: _d(weatherJson['windSpeed']),
      windDir: weatherJson['windDir']?.toString(),
      weather: weatherJson['weather']?.toString(),
      source: weatherJson['source']?.toString(),
      updatedAt: _t(weatherJson['updatedAt']),
      pm10: pm10,
      pm25: pm25,
    );
  }

  /// ✅ UI에서 출력용 문자열
  String get formatted =>
      '온도 ${temp?.toStringAsFixed(1) ?? "-"}°C | 습도 ${humidity?.toStringAsFixed(0) ?? "-"}% | '
          'PM10 ${pm10?.toStringAsFixed(0) ?? "-"}㎍/㎥';

  /// ✅ JSON 변환 (필요 시 전송용)
  Map<String, dynamic> toJson() => {
    'temp': temp,
    'humidity': humidity,
    'windSpeed': windSpeed,
    'windDir': windDir,
    'weather': weather,
    'pm10': pm10,
    'pm25': pm25,
    'source': source,
    'updatedAt': updatedAt?.toIso8601String(),
  };
}