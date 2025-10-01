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
//     _smoke();
//   }
//
//   Future<void> _smoke() async {
//     final ok = await _repo.health();
//     if (!mounted) return;
//     setState(() => _msg = ok ? '서버 OK' : '서버 응답 없음');
//   }
//
//   Future<void> _doLogin() async {
//     setState(() { _loading = true; _msg = ''; });
//     final ok = await _repo.login(_id.text.trim(), _pw.text.trim());
//     if (!mounted) return;
//     setState(() => _loading = false);
//     if (ok && await _repo.checkSession()) {
//       if (!mounted) return;
//       Navigator.pushReplacementNamed(context, '/home');
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('로그인 실패 또는 세션 없음')),
//       );
//     }
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
//             TextField(controller: _id, decoration: const InputDecoration(labelText: 'ID')),
//             TextField(controller: _pw, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
//             const SizedBox(height: 16),
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
import 'package:sems_project/src/repository/auth_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _id = TextEditingController();
  final _pw = TextEditingController();
  final _repo = AuthRepository();
  bool _loading = false;
  String _msg = '';

  @override
  void initState() {
    super.initState();
    _smoke(); // 서버 살아있는지 확인
  }

  Future<void> _smoke() async {
    final ok = await _repo.health();
    if (!mounted) return;
    setState(() => _msg = ok ? '서버 OK' : '서버 응답 없음');
  }

  Future<void> _doLogin() async {
    setState(() {
      _loading = true;
      _msg = '';
    });
    final ok = await _repo.login(_id.text.trim(), _pw.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);

    if (ok && await _repo.checkSession()) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home'); // 성공 시 홈으로 이동
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 실패 또는 세션 없음')),
      );
    }
  }

  Future<void> _checkSession() async {
    final ok = await _repo.checkSession();
    if (!mounted) return;
    setState(() => _msg = ok ? '세션 있음' : '세션 없음');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(alignment: Alignment.centerLeft, child: Text(_msg)),
            const SizedBox(height: 12),
            TextField(
              controller: _id,
              decoration: const InputDecoration(labelText: 'ID'),
            ),
            TextField(
              controller: _pw,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _doLogin,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('로그인'),
            ),
            ElevatedButton(
              onPressed: _checkSession,
              child: const Text("세션 확인"),
            )
          ],
        ),
      ),
    );
  }
}