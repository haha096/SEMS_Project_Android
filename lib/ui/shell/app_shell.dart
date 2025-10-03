import 'package:flutter/material.dart';
import '../../src/constants.dart';      // 공용 상수(색상/ApiConfig)가 src에 있으니 이렇게
import '../home/home_page.dart';
import '../control/control.dart';
import '../mypage/mypage.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final _pages = const [HomePage(), ControlPage(), MyPage()];
  final _titles = const ["SEMS 시스템 관리자", "SEMS 시스템 관리자", "SEMS 시스템 관리자"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: AppColors.primary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '메인'),
          BottomNavigationBarItem(icon: Icon(Icons.tune_outlined), label: '제어'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '내정보'),
        ],
      ),
    );
  }
}