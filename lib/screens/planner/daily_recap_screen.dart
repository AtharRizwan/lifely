import 'package:flutter/material.dart';

import '../../widgets/cards/recap_card.dart';
import '../../widgets/tiles/simple_list_tile.dart';

class DailyRecapScreen extends StatelessWidget {
  const DailyRecapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily recap')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          RecapCard(completed: 2, pending: 3, mood: 'Steady'),
          SizedBox(height: 12),
          SimpleListTile(
            icon: Icons.check_circle_outline,
            title: 'Finished tasks',
            subtitle: 'Read Chapter 5, Lab outline',
          ),
          SizedBox(height: 10),
          SimpleListTile(
            icon: Icons.pending_actions_outlined,
            title: 'Pending tasks',
            subtitle: 'TA office hours, Quiz prep',
          ),
        ],
      ),
    );
  }
}
