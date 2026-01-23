/// Vernacure - Main Entry Point
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vernacure/config/theme.dart';
import 'package:vernacure/screens/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('🚀 VERNACURE APP STARTING...');
  debugPrint('═══════════════════════════════════════════════════════════');
  runApp(
    const ProviderScope(
      child: VernacureApp(),
    ),
  );
}

class VernacureApp extends StatelessWidget {
  const VernacureApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('📱 VernacureApp build() called');
    return MaterialApp(
      title: 'Vernacure',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const WelcomeScreen(),
    );
  }
}
