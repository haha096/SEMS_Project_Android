// lib/ui/control/control.dart
import 'package:flutter/material.dart';
import 'package:sems_project/src/service/api_client.dart';
import '../../src/constants.dart';
import '../common/header.dart';
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import 'package:flutter/foundation.dart' show kIsWeb;

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});
  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  bool _loading = true;
  String? _error;

  bool _powerOn = false;
  bool _autoMode = true;
  int _manualLevel = 1; // 1~3단
  bool _saving = false;

  // ✅ 실내 상태 (WebSocket으로 실시간 수신)
  double? _inTemp;
  double? _inHum;
  double? _inPm10;
  double? _inPm25;
  DateTime? _lastUpdate;

  // ✅ WebSocket 관련
  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _reconnectTimer;
  int _retrySec = 1;
  bool _disposed = false;

  String get _wsUrl {
    if (kIsWeb) return 'ws://localhost:8080/ws/sensor';
    return 'ws://127.0.0.1:8080/ws/sensor';
  }

  @override
  void initState() {
    super.initState();
    _connectWs(); // 실내 데이터 WebSocket 연결
    _load(); // 제어 상태는 REST로 가져옴
  }

  @override
  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _sub?.cancel();
    _channel?.sink.close(ws_status.normalClosure);
    super.dispose();
  }

  // ─────────── WebSocket 연결 ───────────
  void _connectWs() {
    _reconnectTimer?.cancel();
    _retrySec = 1;
    debugPrint('[control] WS connecting -> $_wsUrl');

    try {
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      _sub = _channel!.stream.listen(
        _onWsMessage,
        onError: (e) {
          debugPrint('[control] WS error: $e');
          _scheduleReconnect('onError');
        },
        onDone: () {
          debugPrint('[control] WS closed');
          _scheduleReconnect('onDone');
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint('[control] WS connect() failed: $e');
      _scheduleReconnect('connect() failed');
    }
  }

  void _scheduleReconnect(String reason) {
    if (_disposed) return;
    _sub?.cancel();
    _channel = null;

    final wait = Duration(seconds: _retrySec.clamp(1, 10));
    debugPrint('[control] reconnect in ${wait.inSeconds}s ($reason)');
    _reconnectTimer = Timer(wait, () {
      _retrySec = (_retrySec * 2).clamp(2, 10);
      _connectWs();
    });
  }

  void _onWsMessage(dynamic event) {
    debugPrint('[control] WS recv: $event');
    try {
      final map = json.decode(event as String) as Map<String, dynamic>;

      double? numOrNull(String k) {
        final v = map[k];
        return v == null ? null : double.tryParse(v.toString());
      }

      final temp = numOrNull('TEMP');
      final hum = numOrNull('HUM');
      final pm10 = numOrNull('PM10');
      final pm25 = numOrNull('PM2.5') ?? numOrNull('PM2_5');

      if (!_disposed) {
        setState(() {
          _inTemp = temp;
          _inHum = hum;
          _inPm10 = pm10;
          _inPm25 = pm25;
          _lastUpdate = DateTime.now();
        });
      }
    } catch (e) {
      debugPrint('[control] parse fail: $e');
    }
  }

  // ─────────── REST 통신 (제어 상태) ───────────
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dio = await ApiClient.instance;
      final res = await dio.get('/api/motor/state'); // { powerOn, mode, level }

      final data = res.data as Map<String, dynamic>? ?? {};
      setState(() {
        _powerOn = (data['powerOn'] as bool?) ?? false;
        _autoMode = (data['mode'] as String?) == 'AUTO';
        _manualLevel = (data['level'] as int?) ?? 1;

        // 필요 시 실내값도 서버에서 주면 여기서 매핑
        _inTemp ??= 23;
        _inHum  ??= 40;
        _inPm10 ??= 43;
        _inPm25 ??= 18;
      });
    } catch (e) {
      setState(() => _error = '상태를 불러오지 못했습니다.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ✅ 전원 제어
  Future<void> _setPower(bool on) async {
    final prev = _powerOn;
    setState(() => _powerOn = on);

    try {
      final dio = await ApiClient.instance;
      final res = await dio.post('/api/motor/power', data: {'on': on});
      final msg = res.data?.toString() ?? '전원 명령 전송';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

      // 서버 상태와 재동기화 (웹/다른 클라에서 바뀐 경우 포함)
      await _load();
    } catch (e) {
      setState(() => _powerOn = prev);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('전원 제어 실패')),
      );
    }
  }

  // ✅ 자동/수동 모드 제어
  Future<void> _setMode(bool auto) async {
    if (!_powerOn) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('전원을 켠 뒤에 모드를 바꿀 수 있어요.')),
      );
      return;
    }

    final prev = _autoMode;
    setState(() => _autoMode = auto);

    try {
      final dio = await ApiClient.instance;
      final res = auto
          ? await dio.get('/api/motor/auto')
          : await dio.post('/api/motor/manual', data: {'level': _manualLevel});

      final msg = res.data?.toString() ?? '모드 명령 전송';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

      // 서버 상태와 재동기화
      await _load();
    } catch (e) {
      setState(() => _autoMode = prev);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모드 변경 실패')),
      );
    }
  }

  // ✅ 수동 강도 저장
  Future<void> _save() async {
    if (_autoMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('수동 모드에서만 설정을 저장할 수 있어요.')),
      );
      return;
    }
    if (!_powerOn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('전원을 켠 뒤 저장하세요.')),
      );
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final dio = await ApiClient.instance;
      final res = await dio.post('/api/motor/manual', data: {'level': _manualLevel});
      final msg = res.data?.toString() ?? '설정 저장 완료';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

      // 저장 후 서버 상태 재조회(웹과 동기화)
      await _load();
    } catch (e) {
      setState(() => _error = '저장 실패');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ─────────── UI 구성 ───────────
  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
  );

  Widget _segButton({
    required String label,
    required bool active,
    required VoidCallback? onTap,
  }) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: active ? AppColors.primary : Colors.white,
          foregroundColor: active ? Colors.white : AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          minimumSize: const Size.fromHeight(44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }

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

  Widget _indoorCard() {
    final t = _inTemp != null ? '${_inTemp!.toStringAsFixed(0)}°C' : '--';
    final h = _inHum != null ? '${_inHum!.toStringAsFixed(0)}%' : '--';
    final p10 = _inPm10 != null ? '${_inPm10!.toStringAsFixed(0)}㎍/m³' : '--';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            _metricRow('온도', t),
            Divider(color: Colors.grey.shade200, height: 1),
            _metricRow('습도', h),
            Divider(color: Colors.grey.shade200, height: 1),
            _metricRow('미세먼지', p10),
          ],
        ),
      ),
    );
  }

  Widget _manualLevelCard() {
    final enabled = _powerOn && !_autoMode;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (i) {
            final level = i + 1;
            final active = _manualLevel == level;
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: active ? AppColors.primary : Colors.white,
                foregroundColor: active ? Colors.white : AppColors.primary,
                minimumSize: const Size(80, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: const BorderSide(color: AppColors.primary),
              ),
              onPressed: enabled ? () => setState(() => _manualLevel = level) : null,
              child: Text('${level}단'),
            );
          }),
        ),
      ),
    );
  }

  // ─────────── 빌드 ───────────
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
                  OutlinedButton(onPressed: _load, child: const Text('다시 시도')),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SemsHeader(),
          const SizedBox(height: 4),

          const Text('실내 상황', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          _indoorCard(),

          _sectionTitle('공기청정기 전원'),
          Row(
            children: [
              _segButton(label: 'ON', active: _powerOn, onTap: () => _setPower(true)),
              const SizedBox(width: 10),
              _segButton(label: 'OFF', active: !_powerOn, onTap: () => _setPower(false)),
            ],
          ),
          const SizedBox(height: 18),

          _sectionTitle('공기청정기 제어 모드'),
          Row(
            children: [
              _segButton(label: '자동', active: _autoMode, onTap: _powerOn ? () => _setMode(true) : null),
              const SizedBox(width: 10),
              _segButton(label: '수동', active: !_autoMode, onTap: _powerOn ? () => _setMode(false) : null),
            ],
          ),
          const SizedBox(height: 18),

          _sectionTitle('수동 모드 강도 설정'),
          _manualLevelCard(),
          const SizedBox(height: 8),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 0,
            ),
            onPressed: (_powerOn && !_autoMode && !_saving) ? _save : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(_saving ? '저장 중...' : '저장',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}