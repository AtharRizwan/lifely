import 'package:flutter/material.dart';

class LifelySliverAppBar extends StatelessWidget {
  const LifelySliverAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: false,
      expandedHeight: 112,
      flexibleSpace: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 120, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: actions
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: EdgeInsets.only(
                right: entry.key == actions.length - 1 ? 12 : 4,
              ),
              child: entry.value,
            ),
          )
          .toList(),
    );
  }
}
