import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const LingoApp());
}

class LingoApp extends StatelessWidget {
  const LingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lingo-Abyssinia',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const Scaffold(
        body: Center(
          child: Text('Lingo-Abyssinia Scaffolding Complete'),
        ),
      ),
    );
  }
}
