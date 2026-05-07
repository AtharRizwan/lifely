import 'package:flutter/material.dart';

import '../data/app_scope.dart';
import '../data/app_store.dart';
import '../theme/app_theme.dart';
import 'auth_flow.dart';
import 'lifely_shell.dart';

class LifelyApp extends StatefulWidget {
  const LifelyApp({super.key});

  @override
  State<LifelyApp> createState() => _LifelyAppState();
}

class _LifelyAppState extends State<LifelyApp> {
  final AppStore _store = AppStore();
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _store.initialize();
    if (!mounted) {
      return;
    }
    setState(() => _isReady = true);
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      store: _store,
      child: AnimatedBuilder(
        animation: _store,
        builder: (context, _) {
          return MaterialApp(
            title: 'Lifely',
            debugShowCheckedModeBanner: false,
            theme: buildTheme(Brightness.light),
            darkTheme: buildTheme(Brightness.dark),
            themeMode: _store.themeMode,
            home: !_isReady
                ? const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  )
                : _store.isAuthenticated
                    ? LifelyShell(
                        themeMode: _store.themeMode,
                        onThemeModeChanged: (isDark) => _store.setThemeMode(
                          isDark ? ThemeMode.dark : ThemeMode.light,
                        ),
                        onLogout: _store.logout,
                      )
                    : AuthFlow(
                        onAuthenticated: (_, _) {},
                      ),
          );
        },
      ),
    );
  }
}
