import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../models/app_models.dart';
import '../../widgets/buttons/primary_button.dart';

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({super.key, required this.taskId});

  final String taskId;

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  bool _isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late String _selectedCategory;
  late int _estimatedMinutes;

  final List<String> _categories = [
    'Academics',
    'Group work',
    'Admin',
    'Wellness',
    'Routine',
    'Social',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _subtitleController = TextEditingController();
    _selectedCategory = 'Academics';
    _estimatedMinutes = 45;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  void _startEditing(TaskItem task) {
    setState(() {
      _isEditing = true;
      _titleController.text = task.title;
      _subtitleController.text = task.subtitle;
      _selectedCategory = task.category;
      _estimatedMinutes = task.estimatedMinutes;
    });
  }

  void _saveEditing(TaskItem task, dynamic store) {
    final updated = task.copyWith(
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      category: _selectedCategory,
      estimatedMinutes: _estimatedMinutes,
    );
    store.updateTask(updated);
    setState(() => _isEditing = false);
  }

  void _cancelEditing() {
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final task = store.tasks.firstWhere(
      (item) => item.id == widget.taskId,
      orElse: () => TaskItem(
        id: widget.taskId,
        title: 'Task',
        subtitle: 'Details unavailable',
        category: 'General',
        accent: 0xFF5B8E7D,
        scheduledAt: DateTime.now(),
        estimatedMinutes: 45,
        isCompleted: false,
      ),
    );

    if (_isEditing) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: _cancelEditing,
          ),
          title: const Text('Edit task'),
          actions: [
            IconButton(
              icon: const Icon(Icons.check_rounded),
              onPressed: () => _saveEditing(task, store),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _subtitleController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _estimatedMinutes,
              decoration: const InputDecoration(labelText: 'Estimated time (minutes)'),
              items: [15, 30, 45, 60, 90, 120].map((mins) {
                return DropdownMenuItem(value: mins, child: Text('$mins min'));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _estimatedMinutes = value);
                }
              },
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Task details'),
        actions: [
          if (!task.isCompleted)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => _startEditing(task),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Hero(
            tag: 'task-hero-${task.title}',
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(task.title, style: theme.textTheme.titleLarge),
                        ),
                        if (task.isCompleted)
                          Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      task.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          color: Color(task.accent),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(task.category, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          color: Color(task.accent),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Est. ${task.estimatedMinutes} min',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: task.isCompleted ? 'Completed' : 'Mark complete',
            onPressed: task.isCompleted
                ? null
                : () => store.completeTask(task.id),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {
              store.rescheduleTask(
                task.id,
                task.scheduledAt.add(const Duration(days: 1)),
              );
            },
            child: const Text('Reschedule'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              store.removeTask(task.id);
              Navigator.of(context).pop();
            },
            child: Text(
              'Remove task',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}