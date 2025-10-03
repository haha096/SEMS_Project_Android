// import 'package:flutter/material.dart';
// import '../common/header.dart';
// import '../../src/constants.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   // --- 화면 상태 ---
//   bool _loading = true;
//   String? _error;
//   double? _temp;   // °C
//   double? _hum;    // %
//   double? _pm10;   // ㎍/m³
//   double? _pm25;   // ㎍/m³
//   bool _powerOn = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _load();
//   }
//
//   // TODO: 여기에 실제 API 연동
//   // /api/summary: { temp, hum, pm10, pm25, powerOn }
//   Future<void> _load() async {
//     setState(() { _loading = true; _error = null; });
//     try {
//       // --- 데모 더미 데이터 (API 붙이면 제거) ---
//       await Future.delayed(const Duration(milliseconds: 400));
//       setState(() {
//         _temp = 23;
//         _hum = 40;
//         _pm10 = 43;
//         _pm25 = 18;
//         _powerOn = true;
//       });
//     } catch (e) {
//       setState(() => _error = "데이터를 불러오지 못했습니다.");
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }
//
//   // TODO: 전원 제어 API 연결 (예: POST /api/device/power {on:true/false})
//   Future<void> _setPower(bool on) async {
//     setState(() => _powerOn = on); // 낙관적 업데이트
//     try {
//       // await api.post('/api/device/power', data: {'on': on});
//       // 실패 시 롤백:
//       // if (실패) setState(() => _powerOn = !on);
//     } catch (_) {
//       setState(() => _powerOn = !on);
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('전원 제어 실패')),
//       );
//     }
//   }
//
//   // --- UI 컴포넌트 ---
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
//   Widget _metricsCard() {
//     final temp = _temp != null ? "${_temp!.toStringAsFixed(0)}°C" : "--";
//     final hum  = _hum  != null ? "${_hum!.toStringAsFixed(0)}%"  : "--";
//     final pm10 = _pm10 != null ? "${_pm10!.toStringAsFixed(0)} ㎍/m³" : "--";
//     // 목업엔 pm25 표시는 없지만 필요하면 아래 한 줄 추가 가능:
//     // final pm25 = _pm25 != null ? "${_pm25!.toStringAsFixed(0)} ㎍/m³" : "--";
//
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//       margin: const EdgeInsets.only(top: 8),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 4),
//         child: Column(
//           children: [
//             _metricRow("온도", temp),
//             Divider(color: Colors.grey.shade200, height: 1),
//             _metricRow("습도", hum),
//             Divider(color: Colors.grey.shade200, height: 1),
//             _metricRow("미세먼지", pm10),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _powerControls() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text("공기청정기 전원", style: TextStyle(fontWeight: FontWeight.w700)),
//         const SizedBox(height: 8),
//         Row(
//           children: [
//             Expanded(
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: _powerOn ? AppColors.primary : Colors.white,
//                   foregroundColor: _powerOn ? Colors.white : AppColors.primary,
//                   side: const BorderSide(color: AppColors.primary),
//                   minimumSize: const Size.fromHeight(44),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//                   elevation: 0,
//                 ),
//                 onPressed: () => _setPower(true),
//                 child: const Text("ON"),
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: !_powerOn ? AppColors.primary : Colors.white,
//                   foregroundColor: !_powerOn ? Colors.white : AppColors.primary,
//                   side: const BorderSide(color: AppColors.primary),
//                   minimumSize: const Size.fromHeight(44),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//                   elevation: 0,
//                 ),
//                 onPressed: () => _setPower(false),
//                 child: const Text("OFF"),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // 로딩 화면
//     if (_loading) {
//       return const Column(
//         children: [
//           SemsHeader(), //헤더
//           Expanded(child: Center(child: CircularProgressIndicator())),
//         ],
//       );
//     }
//
//     // 에러 화면
//     if (_error != null) {
//       return Column(
//         children: [
//           const SemsHeader(), //헤더
//           Expanded(
//             child: Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(_error!, style: TextStyle(color: Colors.red)),
//                   SizedBox(height: 8),
//                   OutlinedButton(onPressed: _load, child: Text("다시 시도")),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       );
//     }
//
//     // 정상 화면
//     return RefreshIndicator(
//       onRefresh: _load,
//       child: ListView(
//         padding: const EdgeInsets.symmetric(horizontal: AppDimens.p), //좌우 패딩만
//         children: [
//           const SemsHeader(), //헤더
//           const SizedBox(height: 4),
//           const Text("실내 상황",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
//           _metricsCard(),
//           const SizedBox(height: 16),
//           _powerControls(),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import '../common/header.dart';
import '../../src/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = true;
  String? _error;

  // ✅ 실내 상황
  double? _inTemp;  // °C
  double? _inHum;   // %
  double? _inPm10;  // ㎍/m³
  double? _inPm25;  // ㎍/m³

  // ✅ 실외 상황
  double? _outTemp;  // °C
  double? _outHum;   // %
  double? _outPm10;  // ㎍/m³
  double? _outPm25;  // ㎍/m³

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// TODO: 실제 API 연동
  /// ddd
  /// - GET /api/indoor/summary  -> { temp, hum, pm10, pm25 }
  /// - GET /api/outdoor/summary -> { temp, hum, pm10, pm25 }
  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      // 데모 더미 데이터
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() {
        // 실내
        _inTemp = 23; _inHum = 40; _inPm10 = 43; _inPm25 = 18;
        // 실외
        _outTemp = 19; _outHum = 55; _outPm10 = 31; _outPm25 = 12;
      });
    } catch (e) {
      setState(() => _error = "데이터를 불러오지 못했습니다.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // --- 공용 UI ---
  Widget _metricRow(String name, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      child: Row(
        children: [
          Expanded(child: Text(name, style: const TextStyle(fontSize: 16))),
          Container(width: 1, height: 20, color: Colors.grey.shade300),
          const SizedBox(width: 12),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _metricsCard({
    required String title,
    required List<MapEntry<String, String>> metrics,
  }) {
    return Column(
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
                  if (i != metrics.length - 1)
                    Divider(color: Colors.grey.shade200, height: 1),
                ]
              ],
            ),
          ),
        ),
      ],
    );
  }

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
                  SizedBox(height: 8),
                  OutlinedButton(onPressed: _load, child: const Text("다시 시도")),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // 값 포맷팅
    final inTemp  = _inTemp  != null ? "${_inTemp!.toStringAsFixed(0)}°C"   : "--";
    final inHum   = _inHum   != null ? "${_inHum!.toStringAsFixed(0)}%"     : "--";
    final inPm10  = _inPm10  != null ? "${_inPm10!.toStringAsFixed(0)} ㎍/m³": "--";
    // final inPm25  = _inPm25  != null ? "${_inPm25!.toStringAsFixed(0)} ㎍/m³": "--";

    final outTemp = _outTemp != null ? "${_outTemp!.toStringAsFixed(0)}°C"   : "--";
    final outHum  = _outHum  != null ? "${_outHum!.toStringAsFixed(0)}%"     : "--";
    final outPm10 = _outPm10 != null ? "${_outPm10!.toStringAsFixed(0)} ㎍/m³": "--";
    final outPm25 = _outPm25 != null ? "${_outPm25!.toStringAsFixed(0)} ㎍/m³": "--";

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.p),
        children: [
          const SemsHeader(), // 상단 헤더
          const SizedBox(height: 4),

          // ✅ 실내 상황
          _metricsCard(
            title: "실내 상황",
            metrics: [
              MapEntry("온도", inTemp),
              MapEntry("습도", inHum),
              MapEntry("미세먼지", inPm10),
              // 필요 시: MapEntry("초미세먼지 PM2.5", inPm25),
            ],
          ),

          const SizedBox(height: 16),

          // ✅ 실외 상황
          _metricsCard(
            title: "실외 상황",
            metrics: [
              MapEntry("온도(실외)", outTemp),
              MapEntry("습도(실외)", outHum),
              MapEntry("미세먼지 PM10", outPm10),
              MapEntry("초미세먼지 PM2.5", outPm25),
            ],
          ),
        ],
      ),
    );
  }
}