import 'dart:async';

import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/splash_screen.dart';

enum AuthStage { splash, login, signup }

class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key, required this.onAuthenticated});

  final VoidCallback onAuthenticated;

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  AuthStage _stage = AuthStage.splash;
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    _splashTimer = Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) {
        return;
      }
      setState(() => _stage = AuthStage.login);
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  void _showLogin() {
    setState(() => _stage = AuthStage.login);
  }

  void _showSignup() {
    setState(() => _stage = AuthStage.signup);
  }

  @override
  Widget build(BuildContext context) {
    switch (_stage) {
      case AuthStage.splash:
        return const SplashScreen();
      case AuthStage.login:
        return LoginScreen(
          onLogin: widget.onAuthenticated,
          onSignupTap: _showSignup,
        );
      case AuthStage.signup:
        return SignupScreen(
          onSignup: widget.onAuthenticated,
          onLoginTap: _showLogin,
        );
    }
  }
}
