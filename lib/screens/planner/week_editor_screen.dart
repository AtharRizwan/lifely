import 'package:flutter/material.dart';

import '../../utils/snackbar.dart';
import '../../widgets/cards/action_card.dart';

class WeekEditorScreen extends StatelessWidget {
  const WeekEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit week')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ActionCard(
            title: 'Adjust study blocks',
            subtitle: 'Balance deep work across days.',
            actionLabel: 'Update blocks',
            onAction: () => showSnackBar(context, 'Blocks updated.'),
          ),
          const SizedBox(height: 12),
          ActionCard(
            title: 'Add recurring tasks',
            subtitle: 'Daily recap and review.',
            actionLabel: 'Add recurring',
            onAction: () => showSnackBar(context, 'Recurring tasks added.'),
          ),
        ],
      ),
    );
  }
}
