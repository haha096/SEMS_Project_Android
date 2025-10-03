import 'package:flutter/material.dart';
import 'package:sems_project/src/service/api_client.dart';
import 'package:sems_project/ui/home/home_page.dart';

// 패키지명은 pubspec.yaml의 name과 동일해야 합니다.
// (예: name: sems_app 라면 아래처럼 package:sems_app/..)
import 'ui/common/theme.dart';
import 'ui/login/login_page.dart';
import 'ui/shell/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient.init();
  runApp(const SemsApp());
}

class SemsApp extends StatelessWidget {
  const SemsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SEMS',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/app': (_) => const AppShell(), // 하단 탭
      },
    );
  }
}
