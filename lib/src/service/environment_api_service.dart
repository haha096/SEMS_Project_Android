
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:sems_project/src/model/dto/outdoor_data.dart';

class EnvironmentApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://127.0.0.1:8080',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 10),
  ))
    ..interceptors.add(LogInterceptor(
      request: true, requestBody: true,
      responseBody: true, error: true,
    ));

  Future<OutdoorData> fetchOutdoorNow() async {
    final weatherRes = await _dio.get('/weather/outdoor');
    final dustRes = await _dio.get('/api/dust');

    // 타입/콘텐츠 찍기 (한 번만 찍어봐도 충분)
    debugPrint('weatherRes.type=${weatherRes.data.runtimeType}');
    debugPrint('weatherRes.data=${weatherRes.data}');
    debugPrint('dustRes.type=${dustRes.data.runtimeType}');
    debugPrint('dustRes.data=${dustRes.data}');

    final weather = weatherRes.data is Map
        ? Map<String, dynamic>.from(weatherRes.data)
        : Map<String, dynamic>.from(jsonDecode(weatherRes.data.toString()));

    final dust = dustRes.data is Map
        ? Map<String, dynamic>.from(dustRes.data)
        : Map<String, dynamic>.from(jsonDecode(dustRes.data.toString()));

    return OutdoorData.fromJson(weather, dust);
  }
}