// import 'package:flutter/material.dart';
// import 'package:sems_project/src/repository/auth_repository.dart';
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   final _id = TextEditingController();
//   final _pw = TextEditingController();
//   final _repo = AuthRepository();
//   bool _loading = false;
//   String _msg = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _smoke(); // 서버 살아있는지 확인
//   }
//
//   Future<void> _smoke() async {
//     final ok = await _repo.health();
//     if (!mounted) return;
//     setState(() => _msg = ok ? '서버 OK' : '서버 응답 없음');
//   }
//
//   Future<void> _doLogin() async {
//     setState(() {
//       _loading = true;
//       _msg = '';
//     });
//     final ok = await _repo.login(_id.text.trim(), _pw.text.trim());
//     if (!mounted) return;
//     setState(() => _loading = false);
//
//     if (ok && await _repo.checkSession()) {
//       if (!mounted) return;
//       Navigator.pushReplacementNamed(context, '/home'); // 성공 시 홈으로 이동
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('로그인 실패 또는 세션 없음')),
//       );
//     }
//   }
//
//   Future<void> _checkSession() async {
//     final ok = await _repo.checkSession();
//     if (!mounted) return;
//     setState(() => _msg = ok ? '세션 있음' : '세션 없음');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('로그인')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Align(alignment: Alignment.centerLeft, child: Text(_msg)),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _id,
//               decoration: const InputDecoration(labelText: 'ID'),
//             ),
//             TextField(
//               controller: _pw,
//               decoration: const InputDecoration(labelText: 'Password'),
//               obscureText: true,
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _loading ? null : _doLogin,
//               child: _loading
//                   ? const CircularProgressIndicator()
//                   : const Text('로그인'),
//             ),
//             ElevatedButton(
//               onPressed: _checkSession,
//               child: const Text("세션 확인"),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../src/constants.dart'; // AppColors, AppDimens, ApiConfig 등

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
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
      // TODO: 실제 API 연동 시 여기에 붙이세요.
      // await api.login(_idCtrl.text.trim(), _pwCtrl.text);
      await Future.delayed(const Duration(milliseconds: 600)); // 데모용

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/app');
    } catch (e) {
      setState(() { _error = "로그인에 실패했어요. 아이디/비밀번호를 확인해주세요."; });
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
                      onPressed: _loading ? null : _onLogin,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(_loading ? "로그인 중..." : "로그인"),
                      ),
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