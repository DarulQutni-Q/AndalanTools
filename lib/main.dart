import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/theme.dart';
import 'features/home/presentation/home_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: AndalanToolsApp(),
    ),
  );
}

class AndalanToolsApp extends StatelessWidget {
  const AndalanToolsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Andalan Tools',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
