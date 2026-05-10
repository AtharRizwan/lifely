import 'package:flutter/material.dart';

import '../../ai/ai_notes_summarizer.dart';
import '../../data/app_scope.dart';
import '../../data/app_store.dart';
import '../../models/app_models.dart';
import '../../utils/navigation.dart';
import '../../utils/ocr_service.dart';
import '../../utils/snackbar.dart';
import '../../widgets/app_bars/lifely_sliver_app_bar.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/buttons/theme_toggle_button.dart';
import '../../widgets/cards/capture_card.dart';
import '../../widgets/cards/insight_card.dart';
import '../../widgets/inputs/category_chip.dart';
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
  final Set<String> _selectedCategories = {'Academics'};
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  AiSummaryResult? _aiResult;
  String? _extractedText;
  final List<String> _createdTasks = [];
  final OcrService _ocrService = OcrService.instance;
  final _aiSummarizer = AiNotesSummarizer();

  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
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

  void _toggleCategory(String label) {
    setState(() {
      if (_selectedCategories.contains(label)) {
        _selectedCategories.remove(label);
      } else {
        _selectedCategories.add(label);
      }
    });
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
      final task = TaskItem(
        id: 'task-${DateTime.now().millisecondsSinceEpoch}-${created.length}',
        title: line.length > 60 ? '${line.substring(0, 57)}...' : line,
        subtitle: 'From scan - Today',
        category: 'Academics',
        accent: 0xFF5B8E7D,
        scheduledAt: DateTime.now(),
        estimatedMinutes: 30,
        isCompleted: false,
      );
      store.addTask(task);
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
    final suggestion = '${text[0].toUpperCase()}${text.substring(1)}';
    setState(() {
      _taskController.text = suggestion;
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
              ...result.deadlines.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.event, size: 16, color: theme.colorScheme.error),
                    const SizedBox(width: 6),
                    Flexible(child: Text(d, style: theme.textTheme.bodySmall)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _addTaskFromBullet(d),
                    ),
                  ],
                ),
              )),
            ],
            if (result.keyPoints.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Key points', style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              ...result.keyPoints.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Flexible(child: Text(p, style: theme.textTheme.bodySmall)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _addTaskFromBullet(p),
                    ),
                  ],
                ),
              )),
            ],
            if (result.actionItems.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Action items', style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              ...result.actionItems.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.checklist, size: 16, color: const Color(0xFFD8A15C)),
                    const SizedBox(width: 6),
                    Flexible(child: Text(a, style: theme.textTheme.bodySmall)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _addTaskFromBullet(a),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

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
    final trimmed = text.length > 60 ? '${text.substring(0, 57)}...' : text;
    store.addTask(TaskItem(
      id: 'task-${DateTime.now().millisecondsSinceEpoch}-${text.hashCode}',
      title: trimmed,
      subtitle: 'From AI summary - Today',
      category: _selectedCategories.isEmpty ? 'General' : _selectedCategories.first,
      accent: 0xFF5B8E7D,
      scheduledAt: DateTime.now(),
      estimatedMinutes: 30,
      isCompleted: false,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final scrollView = CustomScrollView(
      slivers: [
        LifelySliverAppBar(
          title: 'Quick add',
          subtitle: 'Type or speak naturally',
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
                decoration: const InputDecoration(
                  hintText: '“Add a task in your own words”',
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Add task now',
                onPressed: () => _addTask(store),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 18),
              SectionHeader(
                title: 'AI rewrite',
                action: 'Apply',
                onActionTap: _applyRewrite,
              ),
              const SizedBox(height: 10),
              if (_taskController.text.trim().isEmpty)
                Text(
                  'Write a draft task to see a suggested rewrite.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                      ),
                )
              else
                InsightCard(
                  title: _taskController.text.trim(),
                  body: 'Tap Apply to rewrite for clarity.',
                ),
              const SizedBox(height: 16),
              const SectionHeader(title: 'Quick categories'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  CategoryChip(
                    label: 'Academics',
                    selected: _selectedCategories.contains('Academics'),
                    onTap: () => _toggleCategory('Academics'),
                  ),
                  CategoryChip(
                    label: 'Group work',
                    selected: _selectedCategories.contains('Group work'),
                    onTap: () => _toggleCategory('Group work'),
                  ),
                  CategoryChip(
                    label: 'Admin',
                    selected: _selectedCategories.contains('Admin'),
                    onTap: () => _toggleCategory('Admin'),
                  ),
                  CategoryChip(
                    label: 'Wellness',
                    selected: _selectedCategories.contains('Wellness'),
                    onTap: () => _toggleCategory('Wellness'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_createdTasks.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Created from scan',
                      style: Theme.of(context).textTheme.titleSmall,
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
                color: Theme.of(context).dividerTheme.color ?? Colors.transparent,
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

extension on _AddTaskScreenState {
  void _addTask(AppStore store) {
    final text = _taskController.text.trim();
    if (text.isEmpty) return;
    final task = TaskItem(
      id: 'task-${DateTime.now().millisecondsSinceEpoch}',
      title: text,
      subtitle: 'Quick add - Today',
      category:
          _selectedCategories.isEmpty ? 'General' : _selectedCategories.first,
      accent: 0xFF5B8E7D,
      scheduledAt: DateTime.now(),
      estimatedMinutes: 45,
      isCompleted: false,
    );
    store.addTask(task);
    _taskController.clear();
  }
}
