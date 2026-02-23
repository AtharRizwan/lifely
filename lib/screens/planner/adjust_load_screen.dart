import 'package:flutter/material.dart';

import '../../utils/snackbar.dart';
import '../../widgets/cards/action_card.dart';

class AdjustLoadScreen extends StatelessWidget {
  const AdjustLoadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adjust load')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ActionCard(
            title: 'Move one task',
            subtitle: 'Shift a low-priority task to tomorrow.',
            actionLabel: 'Reschedule',
            onAction: () => showSnackBar(context, 'Task moved to tomorrow.'),
          ),
          const SizedBox(height: 12),
          ActionCard(
            title: 'Create a focus block',
            subtitle: 'Reserve 90 minutes for deep work.',
            actionLabel: 'Add block',
            onAction: () => showSnackBar(context, 'Focus block added.'),
          ),
          const SizedBox(height: 12),
          ActionCard(
            title: 'Quiet notifications',
            subtitle: 'Mute alerts for the next 2 hours.',
            actionLabel: 'Enable',
            onAction: () => showSnackBar(context, 'Quiet mode enabled.'),
          ),
        ],
      ),
    );
  }
}
