import 'package:flutter/material.dart';
import '../../src/constants.dart';      // 공용 상수(색상/ApiConfig)가 src에 있으니 이렇게
import '../common/navibar.dart';
import '../home/home_page.dart';
import '../control/control.dart';
import '../mypage/mypage.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // (SemsNavBar: 제어=1, 메인=0, 내정보=2)
  int _index = 0; // 시작은 메인
  final _pages = const [
    HomePage(),   // index 0 = 메인
    ControlPage(),// index 1 = 제어
    MyPage(),     // index 2 = 내정보
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: SemsNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}