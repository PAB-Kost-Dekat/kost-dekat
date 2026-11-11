import 'package:flutter/material.dart';

import 'halaman/halaman_login.dart';
import 'service/kos_service.dart';
import 'tema/tema_kosdekat.dart';

void main() {
  runApp(const KosDekatApp());
}

class KosDekatApp extends StatelessWidget {
  const KosDekatApp({super.key, this.home, this.kosService});

  final Widget? home;
  final KosService? kosService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KosDekat',
      theme: temaTerang,
      darkTheme: temaGelap,
      themeMode: ThemeMode.system,
      home: home ?? HalamanLogin(kosService: kosService),
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
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
