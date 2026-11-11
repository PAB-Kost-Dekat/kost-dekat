import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'services/api_service.dart';

import 'halaman/halaman_login.dart';
import 'service/kos_service.dart';
import 'tema/tema_kosdekat.dart';

const apiUrl = String.fromEnvironment(
  'API_URL', defaultValue: 'http://10.0.2.2:8080');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(KosDekatApp(api: ApiService(baseUrl: apiUrl)));
}

class KosDekatApp extends StatelessWidget {
  const KosDekatApp({super.key, required this.api});
  final ApiService api;
  const KosDekatApp({super.key, this.home, this.kosService});

  final Widget? home;
  final KosService? kosService;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'KosDekat',
          debugShowCheckedModeBanner: false,
          theme: temaTerang,
          darkTheme: temaGelap,
          themeMode: mode,
          home: HomePage(api: api),
        );
      },
      builder: (context, mode, _) => MaterialApp(
        title: 'KosDekat',
        debugShowCheckedModeBanner: false,
        theme: temaTerang,
        darkTheme: temaGelap,
        themeMode: mode,
        home: home ?? HalamanLogin(kosService: kosService),
      ),
    );
  }
}
