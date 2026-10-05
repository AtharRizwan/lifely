import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../buttons/primary_button.dart';
import '../inputs/category_chip.dart';
import '../inputs/date_time_field.dart';

/// Opens a sheet to create a planner block (or edit [initial]). Resolves to
/// the saved block, or null if the sheet was dismissed.
Future<PlannerBlock?> showPlannerBlockSheet(
  BuildContext context, {
  PlannerBlock? initial,
  DateTime? start,
  int durationMinutes = 60,
  String title = '',
  String detail = '',
}) {
  return showModalBottomSheet<PlannerBlock>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => PlannerBlockSheet(
      initial: initial,
      defaultStart: start ?? _nextFullHour(DateTime.now()),
      defaultDuration: durationMinutes,
      defaultTitle: title,
      defaultDetail: detail,
    ),
  );
}

DateTime _nextFullHour(DateTime now) =>
    DateTime(now.year, now.month, now.day, now.hour + 1);

class PlannerBlockSheet extends StatefulWidget {
  const PlannerBlockSheet({
    super.key,
    this.initial,
    required this.defaultStart,
    this.defaultDuration = 60,
    this.defaultTitle = '',
    this.defaultDetail = '',
  });

  final PlannerBlock? initial;
  final DateTime defaultStart;
  final int defaultDuration;
  final String defaultTitle;
  final String defaultDetail;

  @override
  State<PlannerBlockSheet> createState() => _PlannerBlockSheetState();
}

class _PlannerBlockSheetState extends State<PlannerBlockSheet> {
  static const _durations = [30, 45, 60, 90, 120, 180];

  late final TextEditingController _titleController;
  late final TextEditingController _detailController;
  late DateTime _start;
  late int _duration;
  late String _category;
  String? _titleError;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _titleController = TextEditingController(text: initial?.title ?? widget.defaultTitle);
    _detailController = TextEditingController(text: initial?.detail ?? widget.defaultDetail);
    _start = initial?.start ?? widget.defaultStart;
    _duration = initial?.durationMinutes ?? widget.defaultDuration;
    _category = initial == null
        ? 'Academics'
        : AppStrings.categories.firstWhere(
            (category) => AppColors.categoryAccent(category) == initial.accent,
            orElse: () => 'Academics',
          );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  void _save() {
    final validation = Validators.validateTaskTitle(_titleController.text);
    if (validation.isInvalid) {
      setState(() => _titleError = validation.errorMessage);
      return;
    }
    final initial = widget.initial;
    Navigator.of(context).pop(PlannerBlock(
      id: initial?.id ?? 'plan-${DateTime.now().millisecondsSinceEpoch}',
      start: _start,
      durationMinutes: _duration,
      title: _titleController.text.trim(),
      detail: _detailController.text.trim(),
      accent: AppColors.categoryAccent(_category),
      taskId: initial?.taskId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final durations = {..._durations, _duration}.toList()..sort();
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.initial == null ? 'New planner block' : 'Edit planner block',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              autofocus: widget.initial == null && widget.defaultTitle.isEmpty,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Title',
                errorText: _titleError,
              ),
              onChanged: (_) {
                if (_titleError != null) setState(() => _titleError = null);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _detailController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Detail (optional)'),
            ),
            const SizedBox(height: 16),
            DateTimeField(
              label: 'Starts',
              value: _start,
              onChanged: (value) => setState(() => _start = value),
            ),
            const SizedBox(height: 16),
            Text('Length', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: durations
                  .map((minutes) => CategoryChip(
                        label: minutes < 60 || minutes % 60 != 0
                            ? '$minutes min'
                            : '${minutes ~/ 60} h',
                        selected: _duration == minutes,
                        onTap: () => setState(() => _duration = minutes),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text('Category', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppStrings.categories
                  .map((category) => CategoryChip(
                        label: category,
                        selected: _category == category,
                        onTap: () => setState(() => _category = category),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: widget.initial == null ? 'Add block' : 'Save changes',
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
