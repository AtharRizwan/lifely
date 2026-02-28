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
    final theme = Theme.of(context);
    return SliverAppBar(
      floating: true,
      pinned: false,
      toolbarHeight: 80,
      collapsedHeight: 80,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        expandedTitleScale: 1.15,
        title: DefaultTextStyle(
          style: theme.textTheme.titleLarge ?? const TextStyle(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
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
