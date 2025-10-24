// class Env {
//   // 데스크탑(Windows)로 돌릴 땐:
//   static const baseUrlWindows = 'http://127.0.0.1:8080';
//   // 안드로이드 에뮬레이터로 돌릴 땐:
//   static const baseUrlAndroid = 'http://10.0.2.2:8080'; // <- host PC의 localhost
//
//   // 지금 어디서 돌릴지 선택 (필요에 따라 바꾸면 됨)
//   static const baseUrl = baseUrlWindows;
//
//   // MQTT
//   static const mqttHost = '10.0.2.2'; // 또는 브로커 실제 IP/도메인
//   static const mqttPort = 1883;       // TLS면 8883 + 보안 설정 필요
//   static const mqttClientId = 'flutter_test';
//   static const subTopic = 'sems/room1/state/power';
//   static const pubTopic = 'control/room1/power';
// }

import 'package:flutter/material.dart';

class Env {
  // 개발: 에뮬레이터 → 호스트 PC
  static const baseUrl = 'http://127.0.0.1:8080';
  // 배포 시:
  // static const baseUrl = 'https://api.your-domain.com';
  static const mqttHost = '192.168.0.23';            // MQTT도 같이 수정
  static const mqttPort = 1883;
  static const mqttClientId = 'flutter_test';
  static const subTopic = 'sems/room1/state/power';
  static const pubTopic = 'control/room1/power';
}

class AppColors {
  static const primary = Color(0xFF3572FF);
  static const bg = Color(0xFFF7F8FA);
  static const textStrong = Color(0xFF1F2937);
  static const textWeak = Color(0xFF6B7280);
}

class AppDimens {
  static const r = 20.0;
  static const p = 16.0;
  static const gap = 12.0;
}

class AppStrings {
  static const appName = "SEMS";
}

// 서버 주소는 여기만 바꾸면 됩니다.
class ApiConfig {
  static String baseUrl = "http://127.0.0.1:8080";
}