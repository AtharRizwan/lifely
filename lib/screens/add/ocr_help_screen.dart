import 'package:flutter/material.dart';

import '../../utils/snackbar.dart';
import '../../widgets/cards/action_card.dart';

class OcrHelpScreen extends StatelessWidget {
  const OcrHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('OCR help')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Turn handwritten notes into tasks in seconds.',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ActionCard(
            title: 'Capture a clear photo',
            subtitle: 'Keep lighting even and avoid shadows.',
            actionLabel: 'Try camera',
            onAction: () => showSnackBar(context, 'Camera opened.'),
          ),
          const SizedBox(height: 12),
          ActionCard(
            title: 'Crop to the notes',
            subtitle: 'Focus on the text you want converted.',
            actionLabel: 'Open scans',
            onAction: () => showSnackBar(context, 'Scan gallery opened.'),
          ),
          const SizedBox(height: 12),
          ActionCard(
            title: 'Review extracted tasks',
            subtitle: 'Confirm and edit before adding.',
            actionLabel: 'Preview',
            onAction: () => showSnackBar(context, 'Preview opened.'),
          ),
        ],
      ),
    );
  }
}
