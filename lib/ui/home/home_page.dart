// import 'package:flutter/material.dart';
// import '../common/header.dart';
// import '../../src/constants.dart';
// import 'dart:async';
// import 'dart:convert';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:web_socket_channel/status.dart' as ws_status;

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
//   // ✅ 실내 상황
//   double? _inTemp;  // °C
//   double? _inHum;   // %
//   double? _inPm10;  // ㎍/m³
//   double? _inPm25;  // ㎍/m³
//
//   // ✅ 실외 상황
//   double? _outTemp;  // °C
//   double? _outHum;   // %
//   double? _outPm10;  // ㎍/m³
//   double? _outPm25;  // ㎍/m³
//
//   @override
//   void initState() {
//     super.initState();
//     _load();
//   }
//
//   /// TODO: 실제 API 연동
//   /// - GET /api/indoor/summary  -> { temp, hum, pm10, pm25 }
//   /// - GET /api/outdoor/summary -> { temp, hum, pm10, pm25 }
//   Future<void> _load() async {
//     setState(() { _loading = true; _error = null; });
//     try {
//       // 데모 더미 데이터
//       await Future.delayed(const Duration(milliseconds: 400));
//       setState(() {
//         // 실내
//         _inTemp = 23; _inHum = 40; _inPm10 = 43; _inPm25 = 18;
//         // 실외
//         _outTemp = 19; _outHum = 55; _outPm10 = 31; _outPm25 = 12;
//       });
//     } catch (e) {
//       setState(() => _error = "데이터를 불러오지 못했습니다.");
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }
//
//   // --- 공용 UI ---
//   Widget _metricRow(String name, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
//       child: Row(
//         children: [
//           Expanded(child: Text(name, style: const TextStyle(fontSize: 16))),
//           Container(width: 1, height: 20, color: Colors.grey.shade300),
//           const SizedBox(width: 12),
//           Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
//         ],
//       ),
//     );
//   }
//
//   Widget _metricsCard({
//     required String title,
//     required List<MapEntry<String, String>> metrics,
//   }) {
//     return Column(
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
//                   if (i != metrics.length - 1)
//                     Divider(color: Colors.grey.shade200, height: 1),
//                 ]
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Column(
//         children: [
//           SemsHeader(),
//           Expanded(child: Center(child: CircularProgressIndicator())),
//         ],
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
//                   SizedBox(height: 8),
//                   OutlinedButton(onPressed: _load, child: const Text("다시 시도")),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       );
//     }
//
//     // 값 포맷팅
//     final inTemp  = _inTemp  != null ? "${_inTemp!.toStringAsFixed(0)}°C"   : "--";
//     final inHum   = _inHum   != null ? "${_inHum!.toStringAsFixed(0)}%"     : "--";
//     final inPm10  = _inPm10  != null ? "${_inPm10!.toStringAsFixed(0)} ㎍/m³": "--";
//     // final inPm25  = _inPm25  != null ? "${_inPm25!.toStringAsFixed(0)} ㎍/m³": "--";
//
//     final outTemp = _outTemp != null ? "${_outTemp!.toStringAsFixed(0)}°C"   : "--";
//     final outHum  = _outHum  != null ? "${_outHum!.toStringAsFixed(0)}%"     : "--";
//     final outPm10 = _outPm10 != null ? "${_outPm10!.toStringAsFixed(0)} ㎍/m³": "--";
//     final outPm25 = _outPm25 != null ? "${_outPm25!.toStringAsFixed(0)} ㎍/m³": "--";
//
//     return RefreshIndicator(
//       onRefresh: _load,
//       child: ListView(
//         padding: const EdgeInsets.symmetric(horizontal: AppDimens.p),
//         children: [
//           const SemsHeader(), // 상단 헤더
//           const SizedBox(height: 4),
//
//           // ✅ 실내 상황
//           _metricsCard(
//             title: "실내 상황",
//             metrics: [
//               MapEntry("온도", inTemp),
//               MapEntry("습도", inHum),
//               MapEntry("미세먼지", inPm10),
//               // 필요 시: MapEntry("초미세먼지 PM2.5", inPm25),
//             ],
//           ),
//
//           const SizedBox(height: 16),
//
//           // ✅ 실외 상황
//           _metricsCard(
//             title: "실외 상황",
//             metrics: [
//               MapEntry("온도(실외)", outTemp),
//               MapEntry("습도(실외)", outHum),
//               MapEntry("미세먼지 PM10", outPm10),
//               MapEntry("초미세먼지 PM2.5", outPm25),
//             ],
//           ),
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
import 'package:dio/dio.dart';
import '../../src/service/api_client.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = true;
  String? _error;

  double? _inTemp, _inHum, _inPm10, _inPm25;
  double? _outTemp, _outHum, _outPm10, _outPm25;

  DateTime? _lastUpdate;

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _reconnectTimer;
  Timer? _noMsgFallbackTimer;
  int _retrySec = 1;
  bool _disposed = false;

  // ★ 플랫폼별 WS URL (Android 에뮬/웹 동시 지원)
  String get _wsUrl {
    if (kIsWeb) {
      // 웹(Chrome)에서 돌릴 때는 보통 PC의 localhost
      return 'ws://localhost:8080/ws/sensor';
      // 필요하면 PC IP로: 'ws://192.168.x.x:8080/ws/sensor'
    } else {
      // Android 에뮬레이터
      return 'ws://10.0.2.2:8080/ws/sensor';
    }
  }

  @override
  void initState() {
    super.initState();
    _connectWs();
  }

  @override
  void dispose() {
    _disposed = true;
    _noMsgFallbackTimer?.cancel();
    _reconnectTimer?.cancel();
    _sub?.cancel();
    _channel?.sink.close(ws_status.normalClosure);
    super.dispose();
  }

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
    print('[WS] recv: $event');
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
      final dio = await ApiClient.instance;               // baseUrl: http://10.0.2.2:8080
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

  // --- UI helpers ---
  String _fmt(double? v, String unit) => v == null ? '--' : '${v.toStringAsFixed(0)}$unit';

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Column(
        children: [SemsHeader(), Expanded(child: Center(child: CircularProgressIndicator()))],
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
      onRefresh: () async => _connectWs(),
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
          _metricsCard("실내 상황", [
            MapEntry("온도", inTemp),
            MapEntry("습도", inHum),
            MapEntry("미세먼지 PM10", inPm10),
          ]),
          const SizedBox(height: 16),
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