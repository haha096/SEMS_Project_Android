import 'package:flutter/material.dart';
import 'package:sems_project/src/service/api_client.dart';
import '../../src/constants.dart';
import '../common/header.dart';
import '../../src/storage/secure_storage.dart'; // AppStorage.clear() 사용

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String? userId;
  String? email;
  String? nickname;
  bool? isAdmin;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchSessionInfo();
  }

  Future<void> _fetchSessionInfo() async {
    try {
      final res = await ApiClient.dio.get("/api/auth/session");

      if (res.statusCode == 200) {
        setState(() {
          userId = res.data['userId'];
          email = res.data['email'];
          nickname = res.data['nickname'];
          isAdmin = res.data['isAdmin'] == true;
          loading = false;
        });
      } else {
        setState(() => loading = false);
        debugPrint("세션 없음: ${res.data}");
      }
    } catch (e) {
      debugPrint("세션 정보 불러오기 실패: $e");
      setState(() => loading = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠어요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('로그아웃')),
        ],
      ),
    );

    if (ok != true) return;

    await AppStorage.clear(); // 저장된 토큰/쿠키 등 삭제
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SemsHeader(),
        const SizedBox(height: 8),

        // 내정보 카드
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "내정보",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              Row(children: [
                const Text("ID    ", style: TextStyle(color: Colors.white, fontSize: 16)),
                Text(userId ?? "-", style: const TextStyle(color: Colors.white, fontSize: 16)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                const Text("닉네임 ", style: TextStyle(color: Colors.white, fontSize: 16)),
                Text(nickname ?? "-", style: const TextStyle(color: Colors.white, fontSize: 16)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                const Text("Email ", style: TextStyle(color: Colors.white, fontSize: 16)),
                Flexible(
                  child: Text(email ?? "-", style: const TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                const Text("권한  ", style: TextStyle(color: Colors.white, fontSize: 16)),
                Text(isAdmin == true ? "관리자" : "일반 사용자",
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 아이디·비밀번호 변경 라인
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // TODO: 아이디 변경 로직 추가
              },
              child: const Text("아이디 바꾸기"),
            ),
            const Text("  |  "),
            TextButton(
              onPressed: () {
                // TODO: 비밀번호 변경 로직 추가
              },
              child: const Text("비밀번호 바꾸기"),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 로그아웃 버튼
        OutlinedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text("로그아웃", style: TextStyle(fontWeight: FontWeight.w700)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          ),
          onPressed: () => _logout(context),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}
