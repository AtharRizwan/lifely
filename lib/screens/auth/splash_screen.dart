import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showLogo = false;
  bool _showTitle = false;
  bool _showTagline = false;
  bool _showSpinner = false;

  @override
  void initState() {
    super.initState();
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) setState(() => _showLogo = true);
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) setState(() => _showTitle = true);
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) setState(() => _showTagline = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => _showSpinner = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.surface,
              colors.surfaceContainerHighest.withValues(alpha: 0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -40,
              child: _GlowOrb(
                size: 200,
                color: colors.primary.withValues(alpha: 0.15),
              ),
            ),
            Positioned(
              bottom: -90,
              left: -60,
              child: _GlowOrb(
                size: 220,
                color: colors.primary.withValues(alpha: 0.12),
              ),
            ),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedOpacity(
                        opacity: _showLogo ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: _LogoMark(color: colors.primary),
                      ),
                      const SizedBox(height: 24),
                      AnimatedOpacity(
                        opacity: _showTitle ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: Text('Lifely', style: theme.textTheme.headlineLarge),
                      ),
                      const SizedBox(height: 8),
                      AnimatedOpacity(
                        opacity: _showTagline ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          'Your day, curated with calm focus.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      AnimatedOpacity(
                        opacity: _showSpinner ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.95),
            color.withValues(alpha: 0.55),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'L',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
