// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:mqtt_client/mqtt_client.dart';
// import 'package:mqtt_client/mqtt_server_client.dart';
// import 'package:cookie_jar/cookie_jar.dart';
// import 'package:dio_cookie_manager/dio_cookie_manager.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: TestPage(),
//     );
//   }
// }
//
// class TestPage extends StatefulWidget {
//   @override
//   State<TestPage> createState() => _TestPageState();
// }
//
// class _TestPageState extends State<TestPage> {
//   String _log = "대기 중...";
//   final dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:8080"))
//     ..interceptors.add(CookieManager(CookieJar()));
//   MqttServerClient? client;
//
//   Future<void> _login() async {
//     try {
//       final res = await dio.post(
//         "http://10.0.2.2:8080/api/user/login",
//         data: {"id": "admin", "password": "admin"},
//       );
//       setState(() => _log = "로그인 성공: ${res.data}");
//     } catch (e) {
//       setState(() => _log = "로그인 실패: $e");
//     }
//   }
//
//   Future<void> _connectMqtt() async {
//     final c = MqttServerClient("10.0.2.2", "flutter_test");
//     c.port = 1883;
//     c.logging(on: true);
//     c.keepAlivePeriod = 20;
//
//     c.onConnected = () {
//       if (mounted) setState(() => _log = "MQTT 연결됨");
//     };
//     c.onDisconnected = () {
//       if (mounted) setState(() => _log = "MQTT 연결 끊김");
//     };
//
//     // 필요하면 전역으로 쓰기 위해 참조 저장
//     client = c;
//
//     final msg = MqttConnectMessage()
//         .withClientIdentifier("flutter_test")
//         .startClean()
//         .withWillQos(MqttQos.atLeastOnce);
//     c.connectionMessage = msg;
//
//     try {
//       await c.connect("admin", "admin1234");
//
//       // 상태 토픽 구독 (옵션)
//       c.subscribe("sems/room/1/state/power", MqttQos.atLeastOnce);
//       c.updates?.listen((events) {
//         final m = events.first.payload as MqttPublishMessage;
//         final payload = MqttPublishPayload.bytesToStringAsString(m.payload.message);
//         if (mounted) setState(() => _log = "수신: $payload");
//       });
//     } catch (e) {
//       if (mounted) setState(() => _log = "MQTT 연결 실패: $e");
//       c.disconnect();
//     }
//   }
//
//   void _sendPower(bool on) {
//     final builder = MqttClientPayloadBuilder()..addString('{"on": $on}');
//     client?.publishMessage(
//       "sems/room/1/cmd/power",
//       MqttQos.atLeastOnce,
//       builder.payload!,
//     );
//     setState(() => _log = "발행: $on");
//   }
//
//   Future<void> _checkSession() async {
//     try {
//       final res = await dio.get("/api/user/session");
//       setState(() => _log = "세션 확인: ${res.data}");
//     } catch (e) {
//       setState(() => _log = "세션 확인 실패: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("연동 테스트")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Text(_log, style: const TextStyle(fontSize: 16)),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _login,
//               child: const Text("Spring 로그인 테스트"),
//             ),
//             ElevatedButton(
//               onPressed: _connectMqtt,
//               child: const Text("MQTT 연결"),
//             ),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () => _sendPower(true),
//                     child: const Text("전원 켜기"),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () => _sendPower(false),
//                     child: const Text("전원 끄기"),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

import 'package:sems_project/src/repository/motor_api.dart';
import 'package:sems_project/src/service/api_client.dart';
import 'package:sems_project/ui/login/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient.init(); // Dio + CookieManager 초기화(세션 쿠키 유지)
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SEMS',
      home: const LoginPage(),              // 처음 화면: 로그인
      routes: {
        '/home': (_) => const HomePage(),   // 로그인 성공 시 이동
      },
    );
  }
}

/// 로그인 성공 후 이동하는 홈 화면: 전원/모드/속도 제어 테스트용
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

enum Mode { auto, manual }

class _HomePageState extends State<HomePage> {
  String _log = '로그인 성공! 제어 준비 완료';
  bool _powerOn = false;
  Mode _mode = Mode.auto;
  int _level = 1; // 1~3
  int get _minL => 1;
  int get _maxL => 3;

  Future<void> _setPower(bool on) async {
    try {
      final msg = await MotorApi.power(on);
      setState(() {
        _powerOn = on;
        _log = 'POWER ${on ? "ON" : "OFF"}: $msg';
      });
    } catch (e) {
      setState(() => _log = 'POWER 실패: $e');
    }
  }

  Future<void> _setAuto() async {
    try {
      final msg = await MotorApi.auto();
      setState(() {
        _mode = Mode.auto;
        _log = 'AUTO 모드: $msg';
      });
    } catch (e) {
      setState(() => _log = 'AUTO 실패: $e');
    }
  }

  Future<void> _saveManual() async {
    try {
      final msg = await MotorApi.manual(_level);
      setState(() {
        _mode = Mode.manual;
        _log = 'MANUAL 모드 및 속도($_level) 명령 전송 완료: $msg';
      });
    } catch (e) {
      setState(() => _log = 'MANUAL 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selText =
        '현재 설정: ${_mode == Mode.auto ? "자동" : "수동 $_level단"} / 전원 ${_powerOn ? "ON" : "OFF"}';

    return Scaffold(
      appBar: AppBar(title: const Text('HOME 제어 테스트')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 로그 영역(스크롤 가능)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(_log, softWrap: true),
                ),
              ),
              const SizedBox(height: 12),

              // 제어 버튼들
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // 전원
                  ElevatedButton(
                    onPressed: () => _setPower(true),
                    child: const Text('POWER ON'),
                  ),
                  OutlinedButton(
                    onPressed: () => _setPower(false),
                    child: const Text('POWER OFF'),
                  ),

                  // 모드
                  ElevatedButton(
                    onPressed: _setAuto,
                    child: const Text('AUTO'),
                  ),
                  ElevatedButton(
                    onPressed: _saveManual, // 현재 level로 수동 적용
                    child: const Text('MANUAL 적용'),
                  ),

                  // 수동 속도 조절
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('$_level단', style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => setState(() {
                        if (_level < _maxL) _level++;
                      }),
                      child: const Text('▲'),
                    ),
                    const SizedBox(width: 6),
                    OutlinedButton(
                      onPressed: () => setState(() {
                        if (_level > _minL) _level--;
                      }),
                      child: const Text('▼'),
                    ),
                  ]),
                ],
              ),

              const SizedBox(height: 8),
              Text(selText),
            ],
          ),
        ),
      ),
    );
  }
}