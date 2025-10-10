import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class StompService with ChangeNotifier {
  StompClient? _client;
  bool get connected => _client?.connected == true;

  // 최신 센서 값 보관 (백엔드 Main.js의 키와 맞춤)
  double? temp;   // TEMP
  double? hum;    // HUM
  double? pm10;   // PM10
  double? pm25;   // "PM2.5"

  void connect({
    String? url,
    String topic = '/topic/sensor',
  }) {
    if (connected) return;

    _client = StompClient(
      config: StompConfig(
        // 에뮬레이터/기기에 맞게 바꿔줘
        url: url ?? _defaultWsUrl(),
        reconnectDelay: const Duration(seconds: 2),
        onConnect: (StompFrame f) {
          _client?.subscribe(
            destination: topic,
            callback: (StompFrame msg) {
              if (msg.body == null) return;
              final m = jsonDecode(msg.body!);

              // 안전하게 파싱
              temp = _toDouble(m['TEMP']);
              hum  = _toDouble(m['HUM']);
              pm10 = _toDouble(m['PM10'] ?? m['PM10'.toString()]);
              pm25 = _toDouble(m['PM2.5'] ?? m['PM2_5'] ?? m['PM25']);

              notifyListeners();
            },
          );
        },
        onWebSocketError: (e) => debugPrint('WS error: $e'),
      ),
    )..activate();
  }

  void disconnect() => _client?.deactivate();

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  String _defaultWsUrl() {
    // Android 에뮬레이터: 10.0.2.2, iOS 시뮬레이터: localhost
    // 실제 기기라면 PC IP로 바꿔줘 (예: ws://192.168.x.x:8080/ws)
    return kIsWeb
        ? 'ws://localhost:8080/ws'
        : 'ws://10.0.2.2:8080/ws';
  }
}