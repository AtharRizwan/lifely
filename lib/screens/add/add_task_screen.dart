import 'package:flutter/material.dart';

import '../../ai/ai_notes_summarizer.dart';
import '../../ai/ai_quick_add.dart';
import '../../data/app_scope.dart';
import '../../data/app_store.dart';
import '../../models/app_models.dart';
import '../../utils/constants.dart';
import '../../utils/navigation.dart';
import '../../utils/ocr_service.dart';
import '../../utils/snackbar.dart';
import '../../utils/time.dart';
import '../../utils/validators.dart';
import '../../widgets/app_bars/lifely_sliver_app_bar.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/buttons/theme_toggle_button.dart';
import '../../widgets/cards/capture_card.dart';
import '../../widgets/cards/insight_card.dart';
import '../../widgets/inputs/category_chip.dart';
import '../../widgets/inputs/date_time_field.dart';
import '../../widgets/tiles/section_header.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    this.extractedText,
  });

  final ThemeMode themeMode;
  final ValueChanged<bool> onThemeModeChanged;
  final String? extractedText;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> with SingleTickerProviderStateMixin {
  static const _parser = QuickAddParser();
  static const _rewriter = TaskRewriter();

  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  AiSummaryResult? _aiResult;
  String? _extractedText;
  final List<String> _createdTasks = [];
  final OcrService _ocrService = OcrService.instance;
  final _aiSummarizer = AiNotesSummarizer();

  // Values detected from the text fill these until the user sets them by hand.
  QuickAddResult? _parsed;
  String _category = 'Academics';
  late DateTime _due;
  int _minutes = 45;
  bool _dueTouched = false;
  bool _minutesTouched = false;
  bool _categoryTouched = false;
  String? _titleError;
  String? _lastAdded;

  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _due = _defaultDue(DateTime.now());
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _scaleController.forward();
    if (widget.extractedText != null) {
      _extractedText = widget.extractedText;
    }
  }

  DateTime _defaultDue(DateTime now) =>
      DateTime(now.year, now.month, now.day, now.hour + 1);

  void _onTaskTextChanged(String text) {
    final now = DateTime.now();
    final parsed = text.trim().isEmpty ? null : _parser.parse(text, now);
    setState(() {
      _parsed = parsed;
      _titleError = null;
      _lastAdded = null;
      if (!_dueTouched) _due = parsed?.due ?? _defaultDue(now);
      if (!_minutesTouched) _minutes = parsed?.minutes ?? 45;
      if (!_categoryTouched && parsed?.category != null) {
        _category = parsed!.category!;
      }
    });
  }

  void _resetComposer() {
    _taskController.clear();
    _parsed = null;
    _dueTouched = false;
    _minutesTouched = false;
    _categoryTouched = false;
    _due = _defaultDue(DateTime.now());
    _minutes = 45;
  }

  Future<void> _captureFromCamera() async {
    try {
      showSnackBar(context, 'Processing image...');
      final result = await _ocrService.extractTextFromCamera();
      if (result.isSuccess && mounted) {
        setState(() => _extractedText = result.text);
      } else if (mounted) {
        showSnackBar(context, result.errorMessage);
      }
    } catch (e) {
      if (mounted) showSnackBar(context, 'Camera unavailable. Please try again.');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      showSnackBar(context, 'Processing image...');
      final result = await _ocrService.extractTextFromGallery();
      if (result.isSuccess && mounted) {
        setState(() => _extractedText = result.text);
      } else if (mounted) {
        showSnackBar(context, result.errorMessage);
      }
    } catch (e) {
      if (mounted) showSnackBar(context, 'Could not open gallery. Please try again.');
    }
  }

  /// Builds a task from a line of scanned or summarised text, using any date,
  /// duration or category found in it.
  TaskItem _taskFromLine(String line, String idSuffix, {required String source}) {
    final now = DateTime.now();
    final parsed = _parser.parse(line, now);
    final text = parsed.title.isEmpty ? line.trim() : parsed.title;
    final title = text.length > 60 ? '${text.substring(0, 57)}...' : text;
    final category = parsed.category ?? _category;
    return TaskItem(
      id: 'task-${now.millisecondsSinceEpoch}-$idSuffix',
      title: title,
      subtitle: source,
      category: category,
      accent: AppColors.categoryAccent(category),
      scheduledAt: parsed.due ?? _defaultDue(now),
      estimatedMinutes: parsed.minutes ?? 30,
      isCompleted: false,
    );
  }

  void _convertExtractedToTasks() {
    if (_extractedText == null) return;
    final store = AppScope.of(context);
    final aiResult = _aiSummarizer.summarize(_extractedText!);
    final created = <String>[];
    final bulletsToAdd = [
      ...aiResult.deadlines,
      ...aiResult.actionItems,
      ...aiResult.keyPoints,
    ];
    for (final line in bulletsToAdd.take(5)) {
      store.addTask(_taskFromLine(line, '${created.length}', source: 'From scan'));
      created.add(line);
    }
    setState(() {
      _createdTasks
        ..clear()
        ..addAll(created);
    });
  }

  void _summarizeNotes() {
    final text = _notesController.text.trim();
    if (text.isEmpty) return;
    final result = _aiSummarizer.summarize(text);
    setState(() {
      _aiResult = result;
    });
  }

  void _applyRewrite() {
    final text = _taskController.text.trim();
    if (text.isEmpty) return;
    final rewritten = _rewriter.rewrite(text, DateTime.now());
    setState(() {
      // The rewrite drops date and duration words, so keep what was detected.
      final parsed = _parsed;
      if (parsed?.due != null) _dueTouched = true;
      if (parsed?.minutes != null) _minutesTouched = true;
      if (parsed?.category != null) _categoryTouched = true;
      _taskController.text = rewritten;
      _parsed = _parser.parse(rewritten, DateTime.now());
    });
  }

  @override
  void dispose() {
    _taskController.dispose();
    _notesController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Widget _buildAiSummaryResults() {
    final theme = Theme.of(context);
    if (_aiResult == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Tap "Summarize notes" to get AI-powered insights.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    final result = _aiResult!;
    final hasContent = result.keyPoints.isNotEmpty ||
        result.actionItems.isNotEmpty ||
        result.deadlines.isNotEmpty;

    if (!hasContent) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('AI Summary', style: theme.textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'No structured content found. Try adding more detail.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text('AI Summary', style: theme.textTheme.titleMedium),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSentimentColor(result.sentimentScore).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getSentimentLabel(result.sentimentScore),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _getSentimentColor(result.sentimentScore),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (result.overallSummary.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                result.overallSummary,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
            if (result.categories.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: result.categories.map((cat) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(cat, style: theme.textTheme.labelSmall),
                  );
                }).toList(),
              ),
            ],
            if (result.deadlines.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Deadlines', style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              ...result.deadlines.map((d) => _summaryRow(
                    d,
                    Icon(Icons.event, size: 16, color: theme.colorScheme.error),
                  )),
            ],
            if (result.keyPoints.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Key points', style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              ...result.keyPoints.map((p) => _summaryRow(
                    p,
                    Icon(Icons.lightbulb_outline, size: 16, color: theme.colorScheme.primary),
                  )),
            ],
            if (result.actionItems.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Action items', style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              ...result.actionItems.map((a) => _summaryRow(
                    a,
                    const Icon(Icons.checklist, size: 16, color: Color(0xFFD8A15C)),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String text, Widget icon) {
    final theme = Theme.of(context);
    final added = _addedBullets.contains(text);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon,
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
          IconButton(
            tooltip: added ? 'Added as a task' : 'Add as a task',
            icon: Icon(
              added ? Icons.check_circle : Icons.add_circle_outline,
              size: 18,
              color: added ? theme.colorScheme.primary : null,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: added ? null : () => _addTaskFromBullet(text),
          ),
        ],
      ),
    );
  }

  final Set<String> _addedBullets = {};

  Color _getSentimentColor(double score) {
    if (score > 0.6) return const Color(0xFF4CAF50);
    if (score < 0.4) return const Color(0xFFE57373);
    return const Color(0xFFFFB74D);
  }

  String _getSentimentLabel(double score) {
    if (score > 0.6) return 'Positive';
    if (score < 0.4) return 'Challenging';
    return 'Neutral';
  }

  void _addTaskFromBullet(String text) {
    final store = AppScope.of(context);
    store.addTask(_taskFromLine(text, '${text.hashCode}', source: 'From AI summary'));
    setState(() => _addedBullets.add(text));
  }

  void _addTask(AppStore store) {
    final text = _taskController.text.trim();
    if (text.isEmpty) {
      setState(() => _titleError = 'Describe the task first.');
      return;
    }
    final parsed = _parser.parse(text, DateTime.now());
    final title = parsed.title.isEmpty ? text : parsed.title;
    final validation = Validators.validateTaskTitle(title);
    if (validation.isInvalid) {
      setState(() => _titleError = validation.errorMessage);
      return;
    }
    final task = TaskItem(
      id: 'task-${DateTime.now().millisecondsSinceEpoch}',
      title: '${title[0].toUpperCase()}${title.substring(1)}',
      subtitle: '',
      category: _category,
      accent: AppColors.categoryAccent(_category),
      scheduledAt: _due,
      estimatedMinutes: _minutes,
      isCompleted: false,
    );
    store.addTask(task);
    setState(() {
      _lastAdded = 'Added "${task.title}" · ${formatDueLabel(task.scheduledAt, DateTime.now())}';
      _titleError = null;
      _resetComposer();
    });
  }

  Widget _buildDetectedChip(ThemeData theme) {
    final parsed = _parsed;
    if (parsed == null || !parsed.hasDetections) return const SizedBox.shrink();
    final parts = <String>[
      if (parsed.due != null) formatDueLabel(parsed.due!, DateTime.now()),
      if (parsed.minutes != null) '${parsed.minutes} min',
      if (parsed.category != null) parsed.category!,
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Detected: ${parts.join(' · ')}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final draft = _taskController.text.trim();
    final rewritten = draft.isEmpty ? '' : _rewriter.rewrite(draft, DateTime.now());
    final durations = {...AppStrings.taskDurations, _minutes}.toList()..sort();
    final scrollView = CustomScrollView(
      slivers: [
        LifelySliverAppBar(
          title: 'Quick add',
          subtitle: 'Type naturally, like "essay tomorrow 3pm"',
          actions: [
            ThemeToggleButton(
              isDark: widget.themeMode == ThemeMode.dark,
              onChanged: widget.onThemeModeChanged,
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              TextField(
                controller: _taskController,
                maxLines: 3,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                onChanged: _onTaskTextChanged,
                decoration: InputDecoration(
                  hintText: '“Read chapter 4 by friday for 1h”',
                  errorText: _titleError,
                ),
              ),
              _buildDetectedChip(theme),
              const SizedBox(height: 16),
              DateTimeField(
                label: 'Due',
                value: _due,
                onChanged: (value) => setState(() {
                  _due = value;
                  _dueTouched = true;
                }),
              ),
              const SizedBox(height: 16),
              Text('Time needed', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: durations
                    .map((minutes) => CategoryChip(
                          label: '$minutes min',
                          selected: _minutes == minutes,
                          onTap: () => setState(() {
                            _minutes = minutes;
                            _minutesTouched = true;
                          }),
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
                          onTap: () => setState(() {
                            _category = category;
                            _categoryTouched = true;
                          }),
                        ))
                    .toList(),
              ),
              if (_lastAdded != null) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(_lastAdded!, style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              SectionHeader(
                title: 'AI rewrite',
                action: rewritten.isNotEmpty && rewritten != draft ? 'Apply' : null,
                onActionTap: _applyRewrite,
              ),
              const SizedBox(height: 10),
              if (draft.isEmpty)
                Text(
                  'Write a draft task to see a suggested rewrite.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                )
              else if (rewritten == draft)
                Text(
                  'Your title already reads clearly.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                )
              else
                InsightCard(
                  title: rewritten,
                  body: 'Tap Apply to use this shorter title. The detected date and time are kept.',
                ),
              const SizedBox(height: 18),
              SectionHeader(
                title: 'Quick add from camera or scans',
                action: 'Learn more',
                onActionTap: () => openOcrHelp(context),
              ),
              const SizedBox(height: 10),
              CaptureCard(
                extractedText: _extractedText,
                onCapture: _captureFromCamera,
                onScan: _pickFromGallery,
                onConvert: _convertExtractedToTasks,
              ),
              const SizedBox(height: 18),
              SectionHeader(
                title: 'Auto notes summarizer',
                action: 'Generate',
                onActionTap: _summarizeNotes,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Paste long notes to condense into bullet points.',
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Summarize notes',
                onPressed: _summarizeNotes,
              ),
              const SizedBox(height: 12),
              _buildAiSummaryResults(),
              const SizedBox(height: 24),
              if (_createdTasks.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Created from scan',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    ..._createdTasks.map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('• $task'),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
            ]),
          ),
        ),
      ],
    );

    return Column(
      children: [
        Expanded(child: scrollView),
        Container(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 12),
          decoration: BoxDecoration(
            color: widget.themeMode == ThemeMode.dark ? const Color(0xFF0D0F14) : Colors.white,
            border: Border(
              top: BorderSide(
                color: theme.dividerTheme.color ?? Colors.transparent,
              ),
            ),
          ),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: PrimaryButton(
              label: 'Add task',
              onPressed: () => _addTask(store),
            ),
          ),
        ),
      ],
    );
  }
}
