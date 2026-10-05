import 'package:flutter/material.dart';

class TimelineEntry extends StatelessWidget {
  const TimelineEntry({
    super.key,
    required this.time,
    required this.title,
    required this.detail,
    required this.accent,
    this.onTap,
  });

  final String time;
  final String title;
  final String detail;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(time, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
