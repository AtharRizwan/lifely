import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../data/app_store.dart';
import '../../models/app_models.dart';
import '../../utils/constants.dart';
import '../../utils/time.dart';
import '../../utils/validators.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/cards/task_card.dart';
import '../../widgets/inputs/date_time_field.dart';
import '../../widgets/sheets/reschedule_sheet.dart';
import '../../widgets/ui_state/error_banners.dart';

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
  late DateTime _scheduledAt;
  String? _titleError;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _subtitleController = TextEditingController();
    _selectedCategory = 'Academics';
    _estimatedMinutes = 45;
    _scheduledAt = DateTime.now();
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
      _titleError = null;
      _titleController.text = task.title;
      _subtitleController.text = task.subtitle;
      _selectedCategory = task.category;
      _estimatedMinutes = task.estimatedMinutes;
      _scheduledAt = task.scheduledAt;
    });
  }

  void _saveEditing(TaskItem task, AppStore store) {
    final titleCheck = Validators.validateTaskTitle(_titleController.text);
    final notesCheck = Validators.validateTaskNotes(_subtitleController.text);
    if (titleCheck.isInvalid || notesCheck.isInvalid) {
      setState(() => _titleError = titleCheck.errorMessage ?? notesCheck.errorMessage);
      return;
    }
    final updated = task.copyWith(
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      category: _selectedCategory,
      accent: AppColors.categoryAccent(_selectedCategory),
      estimatedMinutes: _estimatedMinutes,
      scheduledAt: _scheduledAt,
    );
    store.updateTask(updated);
    setState(() => _isEditing = false);
  }

  void _cancelEditing() {
    setState(() => _isEditing = false);
  }

  Future<void> _reschedule(TaskItem task, AppStore store) async {
    final picked = await showRescheduleSheet(context, task.scheduledAt);
    if (picked == null) return;
    store.rescheduleTask(task.id, picked);
  }

  Future<void> _confirmRemove(TaskItem task, AppStore store) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove task?'),
        content: Text('"${task.title}" will be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Remove',
              style: TextStyle(color: Theme.of(dialogContext).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    // Let the pop transition (and its Hero flight back to the list card)
    // finish before the card disappears.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final removed = await store.removeTask(task.id);
    if (removed == null) return;
    messenger.showSnackBar(SnackBar(
      content: const Text('Task removed'),
      action: SnackBarAction(label: 'Undo', onPressed: () => store.addTask(removed)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final task = store.taskById(widget.taskId);

    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task details')),
        body: EmptyState(
          icon: Icons.search_off_rounded,
          title: 'This task no longer exists',
          subtitle: 'It may have been removed on another screen or device.',
          actionLabel: 'Go back',
          onAction: () => Navigator.of(context).pop(),
        ),
      );
    }

    if (_isEditing) {
      return _buildEditor(task, store, theme);
    }

    final now = DateTime.now();
    final overdue = task.isOverdue(now);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Task details'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => _startEditing(task),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Hero(
            tag: TaskCard.taskHeroTag(task.id),
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
                    if (task.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        task.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _detailRow(
                      theme,
                      Icons.event_outlined,
                      overdue
                          ? 'Overdue · was due ${formatDueLabel(task.scheduledAt, now)}'
                          : 'Due ${formatDueLabel(task.scheduledAt, now)}',
                      overdue ? theme.colorScheme.error : Color(task.accent),
                    ),
                    const SizedBox(height: 10),
                    _detailRow(theme, Icons.bookmark_border, task.category, Color(task.accent)),
                    const SizedBox(height: 10),
                    _detailRow(
                      theme,
                      Icons.timer_outlined,
                      'Est. ${task.estimatedMinutes} min',
                      Color(task.accent),
                    ),
                    if (task.completedAt != null) ...[
                      const SizedBox(height: 10),
                      _detailRow(
                        theme,
                        Icons.done_all_rounded,
                        'Completed ${formatDueLabel(task.completedAt!, now)}',
                        theme.colorScheme.primary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (task.isCompleted)
            PrimaryButton(
              label: 'Mark as not done',
              onPressed: () => store.uncompleteTask(task.id),
            )
          else ...[
            PrimaryButton(
              label: 'Mark complete',
              onPressed: () => store.completeTask(task.id),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => _reschedule(task, store),
              child: const Text('Reschedule'),
            ),
          ],
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => _confirmRemove(task, store),
            child: Text(
              'Remove task',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(ThemeData theme, IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }

  Widget _buildEditor(TaskItem task, AppStore store, ThemeData theme) {
    final categories = {...AppStrings.categories, _selectedCategory}.toList();
    final durations = {...AppStrings.taskDurations, _estimatedMinutes}.toList()..sort();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _cancelEditing,
        ),
        title: const Text('Edit task'),
        actions: [
          IconButton(
            tooltip: 'Save',
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
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: 'Title', errorText: _titleError),
            onChanged: (_) {
              if (_titleError != null) setState(() => _titleError = null);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _subtitleController,
            decoration: const InputDecoration(labelText: 'Notes'),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          DateTimeField(
            label: 'Due',
            value: _scheduledAt,
            onChanged: (value) => setState(() => _scheduledAt = value),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: const InputDecoration(labelText: 'Category'),
            items: categories.map((cat) {
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
            items: durations.map((mins) {
              return DropdownMenuItem(value: mins, child: Text('$mins min'));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _estimatedMinutes = value);
              }
            },
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Save changes',
            onPressed: () => _saveEditing(task, store),
          ),
        ],
      ),
    );
  }
}
