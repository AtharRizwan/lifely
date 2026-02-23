import 'package:flutter/material.dart';

import '../buttons/primary_button.dart';

class CaptureCard extends StatelessWidget {
  const CaptureCard({
    super.key,
    required this.extractedText,
    required this.onCapture,
    required this.onScan,
    required this.onConvert,
  });

  final String? extractedText;
  final VoidCallback onCapture;
  final VoidCallback onScan;
  final VoidCallback onConvert;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Capture a note', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Scan handwritten notes or capture a photo to extract tasks.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCapture,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onScan,
                    icon: const Icon(Icons.document_scanner_outlined),
                    label: const Text('Scan'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.dividerTheme.color ?? Colors.transparent,
                ),
              ),
              child: Text(
                extractedText ??
                    'Extracted text will appear here after a scan.',
                style: theme.textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 12),
            PrimaryButton(label: 'Convert to tasks', onPressed: onConvert),
          ],
        ),
      ),
    );
  }
}
