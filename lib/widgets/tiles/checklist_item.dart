import 'package:flutter/material.dart';

class ChecklistItem extends StatelessWidget {
  const ChecklistItem({super.key, required this.text, required this.done});

  final String text;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          color: done
              ? Theme.of(context).colorScheme.primary
              : const Color(0xFF9BA1AE),
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
      ],
    );
  }
}
