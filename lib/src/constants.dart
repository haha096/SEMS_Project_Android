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

class Env {
  static const baseUrl = 'http://10.0.2.2:8080'; // ← PC IPv4 주소
  static const mqttHost = '192.168.0.23';            // MQTT도 같이 수정
  static const mqttPort = 1883;
  static const mqttClientId = 'flutter_test';
  static const subTopic = 'sems/room1/state/power';
  static const pubTopic = 'control/room1/power';
}