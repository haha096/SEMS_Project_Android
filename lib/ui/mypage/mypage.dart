// import 'package:flutter/material.dart';
// import '../../src/constants.dart';
// import '../../src/storage/secure_storage.dart'; // SecureStore.clear() 사용
//
// class MyPage extends StatelessWidget {
//   const MyPage({super.key});
//
//   Future<void> _logout(BuildContext context) async {
//     final ok = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('로그아웃'),
//         content: const Text('정말 로그아웃하시겠어요?'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
//           TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('로그아웃')),
//         ],
//       ),
//     );
//
//     if (ok != true) return;
//
//     await AppStorage.clear();               // 저장된 JWT/설정 등 정리
//     if (context.mounted) {
//       Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);  // 로그인 화면으로
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       padding: const EdgeInsets.all(20),
//       children: [
//         // 상단 파란 타이틀 블록 (목업 스타일 유지)
//         Container(
//           padding: const EdgeInsets.symmetric(vertical: 28),
//           decoration: BoxDecoration(
//             color: AppColors.primary,
//             borderRadius: BorderRadius.circular(22),
//           ),
//           alignment: Alignment.center,
//           child: const Text(
//             "SEMS 시스템 관리자",
//             style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
//           ),
//         ),
//         const SizedBox(height: 16),
//
//         // 내정보 카드
//         Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: AppColors.primary,
//             borderRadius: BorderRadius.circular(22),
//           ),
//           child: const Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("내정보", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
//               SizedBox(height: 18),
//               Row(children: [
//                 Text("ID    ", style: TextStyle(color: Colors.white, fontSize: 16)),
//                 Text("admin", style: TextStyle(color: Colors.white, fontSize: 16)),
//               ]),
//               SizedBox(height: 12),
//               Row(children: [
//                 Text("email  ", style: TextStyle(color: Colors.white, fontSize: 16)),
//                 Flexible(child: Text("admin@admin", style: TextStyle(color: Colors.white, fontSize: 16))),
//               ]),
//             ],
//           ),
//         ),
//         const SizedBox(height: 18),
//
//         // 링크 라인
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextButton(onPressed: () {/* TODO: 아이디 변경 */}, child: const Text("아이디 바꾸기")),
//             const Text("  |  "),
//             TextButton(onPressed: () {/* TODO: 비밀번호 변경 */}, child: const Text("비밀번호 바꾸기")),
//           ],
//         ),
//         const SizedBox(height: 10),
//
//         // ✅ 로그아웃 버튼 (파랑 아웃라인, 둥근 모양)
//         OutlinedButton.icon(
//           icon: const Icon(Icons.logout),
//           label: const Text("로그아웃", style: TextStyle(fontWeight: FontWeight.w700)),
//           style: OutlinedButton.styleFrom(
//             foregroundColor: AppColors.primary,
//             side: const BorderSide(color: AppColors.primary, width: 1.5),
//             minimumSize: const Size.fromHeight(50),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
//           ),
//           onPressed: () => _logout(context),
//         ),
//
//         const SizedBox(height: 24),
//       ],
//     );
//   }
// }


import 'package:flutter/material.dart';
import '../../src/constants.dart';
import '../../src/storage/secure_storage.dart'; // AppStorage가 여기 있으면 경로 유지
import '../common/header.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

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

    await AppStorage.clear();  // ← 프로젝트에 맞게 AppStorage 사용
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SemsHeader(), // ✅ 상단 파란 헤더
        const SizedBox(height: 4),

        // 내정보 카드
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("내정보", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              SizedBox(height: 18),
              Row(children: [
                Text("ID    ", style: TextStyle(color: Colors.white, fontSize: 16)),
                Text("admin", style: TextStyle(color: Colors.white, fontSize: 16)),
              ]),
              SizedBox(height: 12),
              Row(children: [
                Text("email  ", style: TextStyle(color: Colors.white, fontSize: 16)),
                Flexible(child: Text("admin@admin", style: TextStyle(color: Colors.white, fontSize: 16))),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 링크 라인
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(onPressed: () {/* TODO: 아이디 변경 */}, child: const Text("아이디 바꾸기")),
            const Text("  |  "),
            TextButton(onPressed: () {/* TODO: 비밀번호 변경 */}, child: const Text("비밀번호 바꾸기")),
          ],
        ),
        const SizedBox(height: 10),

        // 로그아웃
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