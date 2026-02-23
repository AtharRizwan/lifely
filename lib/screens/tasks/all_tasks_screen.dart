import 'package:flutter/material.dart';

import '../../utils/navigation.dart';
import '../../widgets/cards/task_card.dart';

class AllTasksScreen extends StatelessWidget {
  const AllTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('All tasks')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TaskCard(
            title: 'Read Chapter 5',
            subtitle: 'Cognitive Science - 7:00 pm',
            badge: 'Academics',
            accent: theme.colorScheme.primary,
            onTap: () => openTaskDetails(context, 'Read Chapter 5'),
          ),
          const SizedBox(height: 12),
          TaskCard(
            title: 'Lab report outline',
            subtitle: 'Bio 204 - 2:30 pm',
            badge: 'Deadline',
            accent: const Color(0xFFD8A15C),
            onTap: () => openTaskDetails(context, 'Lab report outline'),
          ),
          const SizedBox(height: 12),
          TaskCard(
            title: 'TA office hours',
            subtitle: 'Stats - 4:10 pm',
            badge: 'Calendar',
            accent: const Color(0xFF6C8A7B),
            onTap: () => openTaskDetails(context, 'TA office hours'),
          ),
        ],
      ),
    );
  }
}
