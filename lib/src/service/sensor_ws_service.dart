// import 'dart:async';
// import 'dart:convert';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:web_socket_channel/status.dart' as status;
// import '../model/dto/sensor_data.dart';
//
// class SensorWsService {
//   SensorWsService._();
//   static final SensorWsService instance = SensorWsService._();
//
//   final _controller = StreamController<SensorData>.broadcast();
//   Stream<SensorData> get stream => _controller.stream;
//
//   WebSocketChannel? _channel;
//   Timer? _reconnectTimer;
//
//   // 에뮬레이터 → 10.0.2.2 / 실제 기기 → PC IP로 바꿔주세요
//   static const String wsUrl = 'ws://10.0.2.2:8080/ws/sensor'; // ← 엔드포인트 맞추기
//
//   void connect() {
//     if (_channel != null) return;
//
//     _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
//
//     _channel!.stream.listen((event) {
//       try {
//         final Map<String, dynamic> jsonMap =
//         event is String ? json.decode(event) : json.decode(utf8.decode(event));
//         final data = SensorData.fromJson(jsonMap);
//         _controller.add(data);
//       } catch (_) {
//         // 파싱 실패 무시
//       }
//     }, onError: (e) {
//       _scheduleReconnect();
//     }, onDone: () {
//       _scheduleReconnect();
//     });
//   }
//
//   void _scheduleReconnect() {
//     _disposeChannel();
//     _reconnectTimer?.cancel();
//     _reconnectTimer = Timer(const Duration(seconds: 2), connect);
//   }
//
//   void _disposeChannel() {
//     try { _channel?.sink.close(status.goingAway); } catch (_) {}
//     _channel = null;
//   }
//
//   void dispose() {
//     _reconnectTimer?.cancel();
//     _disposeChannel();
//     _controller.close();
//   }
// }


// sensor_ws_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';              // ← 요걸로
import 'package:web_socket_channel/status.dart' as ws;     // close codes
import '../model/dto/sensor_data.dart';

class SensorWsService {
  SensorWsService._();
  static final SensorWsService instance = SensorWsService._();

  final _controller = StreamController<SensorData>.broadcast();
  Stream<SensorData> get stream => _controller.stream;

  IOWebSocketChannel? _channel;
  Timer? _reconnectTimer;

  // ✅ 물리 디바이스 + adb reverse
  static const String wsUrl = 'ws://127.0.0.1:8080/ws/sensor';

  void connect() {
    if (_channel != null) return;

    try {
      print('[ws] connecting -> $wsUrl');
      _channel = IOWebSocketChannel.connect(
        Uri.parse(wsUrl),
        headers: {'Origin': 'http://localhost'}, // (권장) Origin 검사 우회용
        pingInterval: const Duration(seconds: 20),
      );

      _channel!.stream.listen((event) {
        try {
          final Map<String, dynamic> jsonMap =
          event is String ? json.decode(event) : json.decode(utf8.decode(event));
          _controller.add(SensorData.fromJson(jsonMap));
        } catch (e) {
          print('[ws] parse fail: $e');
        }
      }, onError: (e, st) {
        print('[ws] onError: $e');
        _scheduleReconnect();
      }, onDone: () {
        final code = _channel?.innerWebSocket?.closeCode;
        final reason = _channel?.innerWebSocket?.closeReason;
        print('[ws] onDone. code=$code reason=$reason');
        _scheduleReconnect();
      });
    } catch (e) {
      print('[ws] connect() exception: $e');
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _disposeChannel();
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 2), connect);
  }

  void _disposeChannel() {
    try { _channel?.sink.close(ws.goingAway); } catch (_) {}
    _channel = null;
  }

  void dispose() {
    _reconnectTimer?.cancel();
    _disposeChannel();
    _controller.close();
  }
}