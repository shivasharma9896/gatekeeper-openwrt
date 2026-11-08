import 'package:flutter/material.dart';

import 'data/router_repository.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/shell/app_shell.dart';

class GateKeeperApp extends StatelessWidget {
  const GateKeeperApp({
    required this.repository,
    super.key,
  });

  final RouterRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GateKeeper for OpenWrt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F8FC),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: Builder(
        builder: (context) => OnboardingScreen(
          repository: repository,
          onConnected: (router) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => AppShell(
                  repository: repository,
                  router: router,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
