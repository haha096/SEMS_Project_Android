// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:web_socket_channel/status.dart' as ws_status;
// import '../../src/constants.dart';
// import '../common/header.dart';
// import 'package:dio/dio.dart';
// import '../../src/service/api_client.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   bool _loading = true;
//   String? _error;
//
//   double? _inTemp, _inHum, _inPm10, _inPm25;
//   double? _outTemp, _outHum, _outPm10, _outPm25;
//
//   DateTime? _lastUpdate;
//
//   WebSocketChannel? _channel;
//   StreamSubscription? _sub;
//   Timer? _reconnectTimer;
//   Timer? _noMsgFallbackTimer;
//   int _retrySec = 1;
//   bool _disposed = false;
//
//   // ★ 플랫폼별 WS URL (Android 에뮬/웹 동시 지원)
//   String get _wsUrl {
//     if (kIsWeb) {
//       // 웹(Chrome)에서 돌릴 때는 보통 PC의 localhost
//       return 'ws://localhost:8080/ws/sensor';
//       // 필요하면 PC IP로: 'ws://192.168.x.x:8080/ws/sensor'
//     } else {
//       // Android 에뮬레이터
//       return 'ws://10.0.2.2:8080/ws/sensor';
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _connectWs();
//   }
//
//   @override
//   void dispose() {
//     _disposed = true;
//     _noMsgFallbackTimer?.cancel();
//     _reconnectTimer?.cancel();
//     _sub?.cancel();
//     _channel?.sink.close(ws_status.normalClosure);
//     super.dispose();
//   }
//
//   void _connectWs() {
//     _reconnectTimer?.cancel();
//     _retrySec = 1;
//
//     if (!_disposed) {
//       setState(() { _loading = true; _error = null; });
//     }
//
//     debugPrint('[home] WS connecting -> $_wsUrl');
//     try {
//       _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
//       _sub = _channel!.stream.listen(
//         _onWsMessage,
//         onError: (e, st) {
//           debugPrint('[home] WS onError: $e');
//           _scheduleReconnect('onError: $e');
//         },
//         onDone: () {
//           debugPrint('[home] WS onDone (closed by server/client)');
//           _scheduleReconnect('onDone/closed');
//         },
//         cancelOnError: true,
//       );
//
//       // 연결 시도 직후 로딩 해제 & 5초 무메시지면 latest 한 번 가져오기
//       if (!_disposed) {
//         setState(() { _loading = false; _error = null; });
//       }
//       _noMsgFallbackTimer?.cancel();
//       _noMsgFallbackTimer = Timer(const Duration(seconds: 5), _fetchLatestOnce);
//
//     } catch (e) {
//       debugPrint('[home] WS connect() failed: $e');
//       _scheduleReconnect('connect() failed: $e');
//     }
//   }
//
//   void _scheduleReconnect(String reason) {
//     debugPrint('[home] _scheduleReconnect: $reason');
//     _sub?.cancel();
//     _channel = null;
//
//     if (!_disposed && _loading) {
//       setState(() {
//         _loading = false;
//         _error = '실시간 연결 실패: $reason';
//       });
//     }
//
//     _reconnectTimer?.cancel();
//     final wait = Duration(seconds: _retrySec.clamp(1, 10));
//     debugPrint('[home] reconnect in ${wait.inSeconds}s');
//     _reconnectTimer = Timer(wait, () {
//       _retrySec = (_retrySec * 2).clamp(2, 10);
//       _connectWs();
//     });
//   }
//
//   void _onWsMessage(dynamic event) {
//     debugPrint('[home] WS message: $event');
//     print('[WS] recv: $event');
//     try {
//       final map = json.decode(event as String) as Map<String, dynamic>;
//
//       double? numOrNull(String k) {
//         final v = map[k];
//         return v == null ? null : double.tryParse(v.toString());
//       }
//
//       final temp = numOrNull('TEMP');
//       final hum  = numOrNull('HUM');
//       final pm10 = numOrNull('PM10');
//       final pm25 = numOrNull('PM2.5') ?? numOrNull('PM2_5');
//
//       if (!_disposed) {
//         setState(() {
//           _inTemp = temp;
//           _inHum  = hum;
//           _inPm10 = pm10;
//           _inPm25 = pm25;
//           _lastUpdate = DateTime.now();
//           _error = null;
//         });
//       }
//
//       _noMsgFallbackTimer?.cancel();
//     } catch (e) {
//       debugPrint('[home] parse fail: $e');
//     }
//   }
//
//   Future<void> _fetchLatestOnce() async {
//     if (_disposed) return;
//     try {
//       final dio = await ApiClient.instance;               // baseUrl: http://10.0.2.2:8080
//       final res = await dio.get('/sensor/latest');
//       final m = res.data as Map<String, dynamic>?;
//
//       if (m != null && m.isNotEmpty) {
//         if (!_disposed) {
//           setState(() {
//             _inTemp = _toDouble(m['temperature']);
//             _inHum  = _toDouble(m['humidity']);
//             _inPm10 = _toDouble(m['pm10']);
//             _inPm25 = _toDouble(m['pm2_5']);
//             _lastUpdate = DateTime.now();
//           });
//         }
//         debugPrint('[home] /sensor/latest applied: $_inTemp / $_inHum / $_inPm10');
//       } else {
//         debugPrint('[home] /sensor/latest empty');
//       }
//     } catch (e) {
//       debugPrint('[home] /sensor/latest error: $e');
//     }
//   }
//
//   double? _toDouble(dynamic v) => v == null ? null : double.tryParse(v.toString());
//
//   // --- UI helpers ---
//   String _fmt(double? v, String unit) => v == null ? '--' : '${v.toStringAsFixed(0)}$unit';
//
//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Column(
//         children: [SemsHeader(), Expanded(child: Center(child: CircularProgressIndicator()))],
//       );
//     }
//
//     if (_error != null) {
//       return Column(
//         children: [
//           const SemsHeader(),
//           Expanded(
//             child: Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(_error!, style: const TextStyle(color: Colors.red)),
//                   const SizedBox(height: 8),
//                   OutlinedButton(onPressed: _connectWs, child: const Text('다시 연결')),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       );
//     }
//
//     final inTemp = _fmt(_inTemp, '°C');
//     final inHum  = _fmt(_inHum,  '%');
//     final inPm10 = _fmt(_inPm10, ' ㎍/m³');
//
//     String? lastLabel;
//     if (_lastUpdate != null) {
//       final hh = _lastUpdate!.hour.toString().padLeft(2, '0');
//       final mm = _lastUpdate!.minute.toString().padLeft(2, '0');
//       lastLabel = '최근 값 기준 $hh:$mm';
//     }
//
//     Widget _metricRow(String name, String value) => Padding(
//       padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
//       child: Row(children: [
//         Expanded(child: Text(name, style: const TextStyle(fontSize: 16))),
//         Container(width: 1, height: 20, color: Colors.grey.shade300),
//         const SizedBox(width: 12),
//         Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
//       ]),
//     );
//
//     Widget _metricsCard(String title, List<MapEntry<String, String>> metrics) => Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
//         Card(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//           margin: const EdgeInsets.only(top: 8),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 4),
//             child: Column(
//               children: [
//                 for (int i = 0; i < metrics.length; i++) ...[
//                   _metricRow(metrics[i].key, metrics[i].value),
//                   if (i != metrics.length - 1) Divider(color: Colors.grey.shade200, height: 1),
//                 ]
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//
//     return RefreshIndicator(
//       onRefresh: () async => _connectWs(),
//       child: ListView(
//         padding: const EdgeInsets.symmetric(horizontal: AppDimens.p),
//         children: [
//           const SemsHeader(),
//           const SizedBox(height: 4),
//           if (lastLabel != null)
//             Padding(
//               padding: const EdgeInsets.only(left: 12, bottom: 6),
//               child: Text(lastLabel, style: const TextStyle(fontSize: 12, color: Colors.grey)),
//             ),
//           _metricsCard("실내 상황", [
//             MapEntry("온도", inTemp),
//             MapEntry("습도", inHum),
//             MapEntry("미세먼지 PM10", inPm10),
//           ]),
//           const SizedBox(height: 16),
//           _metricsCard("실외 상황", [
//             MapEntry("온도(실외)", _fmt(_outTemp, '°C')),
//             MapEntry("습도(실외)", _fmt(_outHum, '%')),
//             MapEntry("미세먼지 PM10", _fmt(_outPm10, ' ㎍/m³')),
//             MapEntry("초미세먼지 PM2.5", _fmt(_outPm25, ' ㎍/m³')),
//           ]),
//         ],
//       ),
//     );
//   }
// }


import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

import '../../src/constants.dart';
import '../common/header.dart';

// [ADD] 실외 REST 호출에 사용할 Dio 클라이언트
import 'package:dio/dio.dart';
import '../../src/service/api_client.dart'; // ApiClient.instance (baseUrl: http://10.0.2.2:8080)

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = true;
  String? _error;

  // ✅ 실내(WS로 갱신)
  double? _inTemp, _inHum, _inPm10, _inPm25;

  // ✅ 실외(REST로 1분 주기 갱신)  // [ADD] 이미 있었지만 주석으로 명확화
  double? _outTemp, _outHum, _outPm10, _outPm25;

  DateTime? _lastUpdate;

  // --- WebSocket (실내) ---
  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _reconnectTimer;
  Timer? _noMsgFallbackTimer;
  int _retrySec = 1;

  // [ADD] 실외 주기 갱신 타이머
  Timer? _outdoorTimer;

  bool _disposed = false;

  // ★ 플랫폼별 WS URL (Android 에뮬/웹 동시 지원)
  String get _wsUrl {
    if (kIsWeb) {
      return 'ws://localhost:8080/ws/sensor'; // 웹
    } else {
      return 'ws://10.0.2.2:8080/ws/sensor';   // 에뮬레이터
    }
  }

  @override
  void initState() {
    super.initState();
    _connectWs();          // 실내(WS) 연결

    _fetchOutdoor();       // [ADD] 실외 1회 즉시 로드
    _outdoorTimer?.cancel();
    _outdoorTimer = Timer.periodic(
      const Duration(minutes: 1),
          (_) { if (!_disposed) _fetchOutdoor(); }, // [ADD] 1분마다 실외 갱신
    );
  }

  @override
  void dispose() {
    _disposed = true;

    _noMsgFallbackTimer?.cancel();
    _reconnectTimer?.cancel();
    _sub?.cancel();
    _channel?.sink.close(ws_status.normalClosure);

    _outdoorTimer?.cancel(); // [ADD] 실외 타이머 정리

    super.dispose();
  }

  // -------------------------
  // 실내: WebSocket 연결/재연결
  // -------------------------
  void _connectWs() {
    _reconnectTimer?.cancel();
    _retrySec = 1;

    if (!_disposed) {
      setState(() { _loading = true; _error = null; });
    }

    debugPrint('[home] WS connecting -> $_wsUrl');
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      _sub = _channel!.stream.listen(
        _onWsMessage,
        onError: (e, st) {
          debugPrint('[home] WS onError: $e');
          _scheduleReconnect('onError: $e');
        },
        onDone: () {
          debugPrint('[home] WS onDone (closed by server/client)');
          _scheduleReconnect('onDone/closed');
        },
        cancelOnError: true,
      );

      // 연결 시도 직후 로딩 해제 & 5초 무메시지면 latest 한 번 가져오기
      if (!_disposed) {
        setState(() { _loading = false; _error = null; });
      }
      _noMsgFallbackTimer?.cancel();
      _noMsgFallbackTimer = Timer(const Duration(seconds: 5), _fetchLatestOnce);
    } catch (e) {
      debugPrint('[home] WS connect() failed: $e');
      _scheduleReconnect('connect() failed: $e');
    }
  }

  void _scheduleReconnect(String reason) {
    debugPrint('[home] _scheduleReconnect: $reason');
    _sub?.cancel();
    _channel = null;

    if (!_disposed && _loading) {
      setState(() {
        _loading = false;
        _error = '실시간 연결 실패: $reason';
      });
    }

    _reconnectTimer?.cancel();
    final wait = Duration(seconds: _retrySec.clamp(1, 10));
    debugPrint('[home] reconnect in ${wait.inSeconds}s');
    _reconnectTimer = Timer(wait, () {
      _retrySec = (_retrySec * 2).clamp(2, 10);
      _connectWs();
    });
  }

  void _onWsMessage(dynamic event) {
    debugPrint('[home] WS message: $event');
    try {
      final map = json.decode(event as String) as Map<String, dynamic>;

      double? numOrNull(String k) {
        final v = map[k];
        return v == null ? null : double.tryParse(v.toString());
      }

      final temp = numOrNull('TEMP');
      final hum  = numOrNull('HUM');
      final pm10 = numOrNull('PM10');
      final pm25 = numOrNull('PM2.5') ?? numOrNull('PM2_5');

      if (!_disposed) {
        setState(() {
          _inTemp = temp;
          _inHum  = hum;
          _inPm10 = pm10;
          _inPm25 = pm25;
          _lastUpdate = DateTime.now();
          _error = null;
        });
      }

      _noMsgFallbackTimer?.cancel();
    } catch (e) {
      debugPrint('[home] parse fail: $e');
    }
  }

  Future<void> _fetchLatestOnce() async {
    if (_disposed) return;
    try {
      final dio = await ApiClient.instance; // baseUrl: http://10.0.2.2:8080
      final res = await dio.get('/sensor/latest');
      final m = res.data as Map<String, dynamic>?;

      if (m != null && m.isNotEmpty) {
        if (!_disposed) {
          setState(() {
            _inTemp = _toDouble(m['temperature']);
            _inHum  = _toDouble(m['humidity']);
            _inPm10 = _toDouble(m['pm10']);
            _inPm25 = _toDouble(m['pm2_5']);
            _lastUpdate = DateTime.now();
          });
        }
        debugPrint('[home] /sensor/latest applied: $_inTemp / $_inHum / $_inPm10');
      } else {
        debugPrint('[home] /sensor/latest empty');
      }
    } catch (e) {
      debugPrint('[home] /sensor/latest error: $e');
    }
  }

  double? _toDouble(dynamic v) => v == null ? null : double.tryParse(v.toString());

  // -------------------------
  // [ADD] 실외: REST로 1분마다 갱신
  // -------------------------
  Future<void> _fetchOutdoor() async {
    if (_disposed) return;
    try {
      final dio = await ApiClient.instance; // baseUrl: http://10.0.2.2:8080
      final sw = Stopwatch()..start();

      // 1) 날씨 (6초 타임아웃)
      Response wRes;
      try {
        wRes = await dio.get(
          '/weather/outdoor',
          options: Options(receiveTimeout: const Duration(seconds: 6)),
        );
        debugPrint('[outdoor] weather OK ${sw.elapsedMilliseconds}ms type=${wRes.data.runtimeType}');
      } on DioException catch (e) {
        debugPrint('[outdoor] weather FAIL (${e.type}) after ${sw.elapsedMilliseconds}ms: $e');
        rethrow; // 날씨 없으면 카드 의미가 없으니 실패 처리
      }

      // 2) 먼지 (6초 타임아웃, 실패해도 날씨만 표시)
      Map<String, dynamic>? d;
      try {
        final dRes = await dio.get(
          '/api/dust',
          options: Options(receiveTimeout: const Duration(seconds: 6)),
        );
        d = dRes.data is Map
            ? Map<String, dynamic>.from(dRes.data as Map)
            : Map<String, dynamic>.from(jsonDecode(dRes.data.toString()));
        debugPrint('[outdoor] dust OK ${sw.elapsedMilliseconds}ms');
      } catch (e) {
        debugPrint('[outdoor] dust FAIL ${sw.elapsedMilliseconds}ms: $e');
      }

      final Map<String, dynamic> w = wRes.data is Map
          ? Map<String, dynamic>.from(wRes.data as Map)
          : Map<String, dynamic>.from(jsonDecode(wRes.data.toString()));

      double? _toD(v) => v == null ? null : (v is num ? v.toDouble() : double.tryParse(v.toString()));

      // 공급자별 키 후보 넓게
      final outTemp = _toD(w['temp'] ?? w['temperature'] ?? w['T1H'] ?? w['ta']);
      final outHum  = _toD(w['humidity'] ?? w['hum'] ?? w['REH'] ?? w['rh']);

      final outPm10 = _toD(d?['pm10Value'] ?? d?['pm10']);
      final outPm25 = _toD(d?['pm25Value'] ?? d?['pm25']);

      debugPrint('[outdoor] parsed => temp=$outTemp, hum=$outHum, pm10=$outPm10, pm25=$outPm25');

      if (!_disposed) {
        setState(() {
          _outTemp = outTemp;
          _outHum  = outHum;
          _outPm10 = outPm10;
          _outPm25 = outPm25;
          _lastUpdate = DateTime.now();
        });
      }
    } catch (e) {
      debugPrint('[home] _fetchOutdoor error: $e');
    }
  }

  // --- UI helpers ---
  String _fmt(double? v, String unit) => v == null ? '--' : '${v.toStringAsFixed(0)}$unit';

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Column(
        children: [
          SemsHeader(),
          Expanded(child: Center(child: CircularProgressIndicator())),
        ],
      );
    }

    if (_error != null) {
      return Column(
        children: [
          const SemsHeader(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  OutlinedButton(onPressed: _connectWs, child: const Text('다시 연결')),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // 표시값 포맷
    final inTemp = _fmt(_inTemp, '°C');
    final inHum  = _fmt(_inHum,  '%');
    final inPm10 = _fmt(_inPm10, ' ㎍/m³');

    String? lastLabel;
    if (_lastUpdate != null) {
      final hh = _lastUpdate!.hour.toString().padLeft(2, '0');
      final mm = _lastUpdate!.minute.toString().padLeft(2, '0');
      lastLabel = '최근 값 기준 $hh:$mm';
    }

    Widget _metricRow(String name, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      child: Row(children: [
        Expanded(child: Text(name, style: const TextStyle(fontSize: 16))),
        Container(width: 1, height: 20, color: Colors.grey.shade300),
        const SizedBox(width: 12),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      ]),
    );

    Widget _metricsCard(String title, List<MapEntry<String, String>> metrics) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          margin: const EdgeInsets.only(top: 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (int i = 0; i < metrics.length; i++) ...[
                  _metricRow(metrics[i].key, metrics[i].value),
                  if (i != metrics.length - 1) Divider(color: Colors.grey.shade200, height: 1),
                ]
              ],
            ),
          ),
        ),
      ],
    );

    return RefreshIndicator(
      // [CHANGE] 당겨서 새로고침: 실내 WS 재연결 + 실외 즉시 갱신 둘 다
      onRefresh: () async {
        _connectWs();
        await _fetchOutdoor(); // [ADD]
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.p),
        children: [
          const SemsHeader(),
          const SizedBox(height: 4),
          if (lastLabel != null)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 6),
              child: Text(lastLabel, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ),

          // ✅ 실내 상황 (WS)
          _metricsCard("실내 상황", [
            MapEntry("온도", inTemp),
            MapEntry("습도", _fmt(_inHum, '%')),
            MapEntry("미세먼지 PM10", inPm10),
          ]),

          const SizedBox(height: 16),

          // ✅ 실외 상황 (REST 1분 주기)  // [ADD] 값이 주기적으로 반영됨
          _metricsCard("실외 상황", [
            MapEntry("온도(실외)", _fmt(_outTemp, '°C')),
            MapEntry("습도(실외)", _fmt(_outHum, '%')),
            MapEntry("미세먼지 PM10", _fmt(_outPm10, ' ㎍/m³')),
            MapEntry("초미세먼지 PM2.5", _fmt(_outPm25, ' ㎍/m³')),
          ]),
        ],
      ),
    );
  }
}