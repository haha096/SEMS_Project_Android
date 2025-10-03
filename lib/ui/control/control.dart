
import 'package:flutter/material.dart';
import 'package:sems_project/src/service/api_client.dart';
import '../../src/constants.dart';
import '../common/header.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});
  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  bool _loading = true;
  String? _error;

  // 제어 상태
  bool _powerOn = false;
  bool _autoMode = true;
  int _setTemp = 26;

  // ✅ 실내 상황 (상단 카드용)
  double? _inTemp;  // °C
  double? _inHum;   // %
  double? _inPm10;  // ㎍/m³
  double? _inPm25;  // ㎍/m³

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      await Future.delayed(const Duration(milliseconds: 300)); // 데모
      setState(() {
        _powerOn = true;
        _autoMode = true;
        _setTemp = 26;
        _inTemp = 23;
        _inHum = 40;
        _inPm10 = 43;
        _inPm25 = 18;
      });
    } catch (e) {
      setState(() => _error = '상태를 불러오지 못했습니다.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// 전원 제어 API
  Future<void> _setPower(bool on) async {
    final prev = _powerOn;
    setState(() => _powerOn = on);
    try {
      await ApiClient.dio.post('/api/motor/power', data: {'on': on});
    } catch (_) {
      setState(() => _powerOn = prev);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('전원 제어 실패')),
      );
    }
  }

  /// 모드 제어 API
  Future<void> _setMode(bool auto) async {
    if (!_powerOn) {   // ← 전원이 꺼져있으면 모드 변경 불가
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('전원을 켠 뒤에 모드를 바꿀 수 있어요.')),
      );
      return;
    }

    final prev = _autoMode;
    setState(() => _autoMode = auto);

    try {
      if (auto) {
        await ApiClient.dio.get('/api/motor/auto');
      } else {
        final level = _tempToLevel(_setTemp);
        await ApiClient.dio.post('/api/motor/manual', data: {'level': level});
      }
    } catch (_) {
      setState(() => _autoMode = prev);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모드 변경 실패')),
      );
    }
  }

  /// 설정 저장 API (수동 모드일 때만 가능)
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

    setState(() { _saving = true; _error = null; });
    try {
      final level = _tempToLevel(_setTemp);
      await ApiClient.dio.post('/api/motor/manual', data: {'level': level});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장되었습니다.')),
      );
    } catch (e) {
      setState(() => _error = '저장 실패');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  int _tempToLevel(int t) {
    if (t <= 24) return 1;
    if (t <= 27) return 2;
    return 3;
  }

  // --- UI ---
  Widget _sectionTitle(String text) =>
      Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)));

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
    final t  = _inTemp != null ? '${_inTemp!.toStringAsFixed(0)}°C' : '--';
    final h  = _inHum  != null ? '${_inHum!.toStringAsFixed(0)}%'  : '--';
    final p10= _inPm10 != null ? '${_inPm10!.toStringAsFixed(0)} ㎍/m³' : '--';

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

  Widget _tempCard() {
    final enabled = _powerOn && !_autoMode;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Text(
              '$_setTemp도',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: enabled ? Colors.black : Colors.grey,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: enabled ? () => setState(() => _setTemp++) : null,
              icon: const Icon(Icons.keyboard_arrow_up, size: 28),
              tooltip: '온도 올림',
            ),
            IconButton(
              onPressed: enabled && _setTemp > 0
                  ? () => setState(() => _setTemp--)
                  : null,
              icon: const Icon(Icons.keyboard_arrow_down, size: 28),
              tooltip: '온도 내림',
            ),
          ],
        ),
      ),
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
              _segButton(label: 'ON',  active: _powerOn,  onTap: () => _setPower(true)),
              const SizedBox(width: 10),
              _segButton(label: 'OFF', active: !_powerOn, onTap: () => _setPower(false)),
            ],
          ),
          const SizedBox(height: 18),

          _sectionTitle('공기청정기 제어'),
          Row(
            children: [
              _segButton(label: '자동', active: _autoMode, onTap: _powerOn ? () => _setMode(true) : null),
              const SizedBox(width: 10),
              _segButton(label: '수동', active: !_autoMode, onTap: _powerOn ? () => _setMode(false) : null),
            ],
          ),
          const SizedBox(height: 18),

          _sectionTitle('공기청정기 설정온도'),
          _tempCard(),
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
              child: Text(_saving ? '저장 중...' : '저장', style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}