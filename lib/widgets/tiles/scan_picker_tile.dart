import 'package:flutter/material.dart';

class ScanPickerTile extends StatelessWidget {
  const ScanPickerTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onSelect,
  });

  final String title;
  final String subtitle;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(
          Icons.description_outlined,
          color: theme.colorScheme.primary,
        ),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onSelect,
      ),
    );
  }
}
