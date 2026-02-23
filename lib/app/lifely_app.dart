import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'lifely_shell.dart';

class LifelyApp extends StatefulWidget {
  const LifelyApp({super.key});

  @override
  State<LifelyApp> createState() => _LifelyAppState();
}

class _LifelyAppState extends State<LifelyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _updateThemeMode(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lifely',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: _themeMode,
      home: LifelyShell(
        themeMode: _themeMode,
        onThemeModeChanged: _updateThemeMode,
      ),
    );
  }
}
