// lib/ui/login/login_page.dart
//login 테스트

import 'package:flutter/material.dart';
import 'package:sems_project/src/constants.dart';
import 'package:sems_project/src/repository/auth_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _repo = AuthRepository();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _idCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      final id = _idCtrl.text.trim();
      final pw = _pwCtrl.text;

      // 1) 로그인 (JSON: { "id": "...", "password": "..." })
      final ok = await _repo.login(id, pw);

      // 2) 세션 확인 (쿠키)
      final hasSession = await _repo.checkSession();

      if (!mounted) return;
      if (ok && hasSession) {
        Navigator.of(context).pushNamedAndRemoveUntil('/app', (route) => false);
      } else {
        setState(() { _error = "로그인 정보 없음"; });
      }
    } catch (e) {
      setState(() { _error = "로그인 중 오류: $e"; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 로그인은 앱바 없이 깔끔하게
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 로고
                    Column(
                      children: const [
                        Text(
                          "SEMS",
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "SMART ENVIRONMENTAL",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textWeak,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),

                    // 아이디
                    const Text("아이디",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _idCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: "아이디",
                      ),
                      validator: (v) =>
                      (v == null || v.trim().isEmpty) ? "아이디를 입력하세요" : null,
                    ),
                    const SizedBox(height: AppDimens.gap),

                    // 비밀번호
                    const Text("비밀번호",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _pwCtrl,
                      obscureText: _obscure,
                      onFieldSubmitted: (_) => _onLogin(),
                      decoration: InputDecoration(
                        hintText: "비밀번호",
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                        ),
                      ),
                      validator: (v) =>
                      (v == null || v.isEmpty) ? "비밀번호를 입력하세요" : null,
                    ),

                    const SizedBox(height: AppDimens.gap),

                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(_error!,
                            style: const TextStyle(color: Colors.red)),
                      ),

                    // 로그인 버튼
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,   // #3572FF
                        foregroundColor: Colors.white,        // 글자색
                        minimumSize: const Size.fromHeight(48),
                        shape: const StadiumBorder(),         // 목업같이 pill 모양
                        elevation: 0,
                      ),
                      onPressed: _loading ? null : _onLogin,
                      child: Text(_loading ? "로그인 중..." : "로그인"),
                    ),

                    const SizedBox(height: 12),
                    // 링크 라인
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {}, // TODO: 아이디 찾기 연결
                          child: const Text("아이디 찾기"),
                        ),
                        const Text("  |  ",
                            style: TextStyle(color: AppColors.textWeak)),
                        TextButton(
                          onPressed: () {}, // TODO: 비밀번호 찾기 연결
                          child: const Text("비밀번호 찾기"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 도움/진행 안내(선택)
                    Text(
                      "서버: ${ApiConfig.baseUrl}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textWeak),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}