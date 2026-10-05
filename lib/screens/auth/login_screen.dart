import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../data/app_store.dart';
import '../../utils/validators.dart';
import '../../widgets/buttons/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onSignupTap,
  });

  final VoidCallback onLogin;
  final VoidCallback onSignupTap;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    final store = AppScope.of(context);
    final result = await store.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);
    switch (result) {
      case AuthResult.success:
        widget.onLogin();
        break;
      case AuthResult.notFound:
        setState(() => _errorMessage = 'No account found with this email.');
        break;
      case AuthResult.wrongPassword:
        setState(() => _errorMessage = 'Incorrect password. Try again.');
        break;
      case AuthResult.invalidCredentials:
        setState(() => _errorMessage = 'Email or password is incorrect.');
        break;
      case AuthResult.network:
        setState(() => _errorMessage = 'No connection. Check your internet and try again.');
        break;
      case AuthResult.invalidEmail:
        setState(() => _errorMessage = 'Invalid email format.');
        break;
      case AuthResult.invalidInput:
        setState(() => _errorMessage = 'Please enter email and password.');
        break;
      case AuthResult.userDisabled:
        setState(() => _errorMessage = 'Account disabled. Contact support.');
        break;
      case AuthResult.tooManyRequests:
        setState(() => _errorMessage = 'Too many attempts. Try later.');
        break;
      case AuthResult.failure:
        setState(() => _errorMessage = 'Something went wrong. Try again.');
        break;
      default:
        setState(() => _errorMessage = 'An error occurred.');
    }
  }

  void _showForgotPassword() {
    showDialog(
      context: context,
      builder: (_) => _ForgotPasswordDialog(
        initialEmail: _emailController.text.trim(),
        onSend: AppScope.of(context).sendPasswordReset,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to keep your plans flowing.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) =>
                                  Validators.validateEmail(value).errorMessage,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter your password.';
                                }
                                if (value.length < 6) {
                                  return 'Use at least 6 characters.';
                                }
                                return null;
                              },
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _isSubmitting ? null : _showForgotPassword,
                                child: const Text('Forgot password?'),
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (_errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: theme.colorScheme.error,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],
                            PrimaryButton(
                              label: _isSubmitting
                                  ? 'Signing in...'
                                  : 'Sign in',
                              onPressed: _isSubmitting ? null : _submit,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: _isSubmitting ? null : widget.onSignupTap,
                      child: const Text('New here? Create an account'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ForgotPasswordDialog extends StatefulWidget {
  const _ForgotPasswordDialog({required this.initialEmail, required this.onSend});

  final String initialEmail;
  final Future<AuthResult> Function(String email) onSend;

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialEmail);
  bool _sending = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _controller.text.trim();
    final validation = Validators.validateEmail(email);
    if (validation.isInvalid) {
      setState(() => _error = validation.errorMessage);
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    final result = await widget.onSend(email);
    if (!mounted) return;
    setState(() {
      _sending = false;
      switch (result) {
        case AuthResult.success:
          _sent = true;
          break;
        case AuthResult.invalidEmail:
          _error = 'That email address looks invalid.';
          break;
        case AuthResult.network:
          _error = 'No connection. Try again when you are online.';
          break;
        case AuthResult.tooManyRequests:
          _error = 'Too many attempts. Try again later.';
          break;
        default:
          _error = "Couldn't send the reset link. Try again.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) {
      return AlertDialog(
        title: const Text('Check your inbox'),
        content: Text(
          'If an account exists for ${_controller.text.trim()}, a password reset link is on its way.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      );
    }
    return AlertDialog(
      title: const Text('Reset password'),
      content: TextField(
        controller: _controller,
        autofocus: widget.initialEmail.isEmpty,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(labelText: 'Email', errorText: _error),
        onSubmitted: (_) => _sending ? null : _send(),
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _sending ? null : _send,
          child: Text(_sending ? 'Sending…' : 'Send link'),
        ),
      ],
    );
  }
}
