import 'package:flutter/material.dart';

import '../../widgets/tiles/timeline_entry.dart';

class DayViewScreen extends StatelessWidget {
  const DayViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Day view')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TimelineEntry(
            time: '9:00',
            title: 'Neuroscience lecture',
            detail: 'Hall B',
            accent: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          const TimelineEntry(
            time: '11:30',
            title: 'Library focus',
            detail: 'Chapter 5 notes',
            accent: Color(0xFF6C8A7B),
          ),
          const SizedBox(height: 12),
          const TimelineEntry(
            time: '2:30',
            title: 'Lab report outline',
            detail: 'Submit to portal',
            accent: Color(0xFFD8A15C),
          ),
        ],
      ),
    );
  }
}
