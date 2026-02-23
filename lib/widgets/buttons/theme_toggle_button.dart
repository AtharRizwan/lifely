import 'package:flutter/material.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({
    super.key,
    required this.isDark,
    required this.onChanged,
  });

  final bool isDark;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
      onPressed: () => onChanged(!isDark),
    );
  }
}
