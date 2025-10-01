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
import 'package:sems_project/ui/login/login_page.dart';
import 'src/service/api_client.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient.init(); // ★ Dio + CookieManager 초기화
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SEMS',
      home: const LoginPage(), // ★ 처음 화면은 로그인 페이지
      routes: {
        '/home': (_) => const HomePage(), // ★ 로그인 성공 시 이동할 홈 화면
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HOME')),
      body: const Center(child: Text('로그인 성공! 홈 화면입니다.')),
    );
  }
}