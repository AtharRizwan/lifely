import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.accent,
    this.isCompleted = false,
    this.onTap,
    this.heroTag,
  });

  final String title;
  final String subtitle;
  final String badge;
  final Color accent;
  final bool isCompleted;
  final VoidCallback? onTap;

  /// Must be unique on screen; build it with [taskHeroTag] from the task id.
  final String? heroTag;

  static String taskHeroTag(String taskId) => 'task-hero-$taskId';

  @override
  Widget build(BuildContext context) {
    final card = _buildCard(context);
    final tag = heroTag;
    return tag == null ? card : Hero(tag: tag, child: card);
  }

  Widget _buildCard(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.2)
                      : accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
