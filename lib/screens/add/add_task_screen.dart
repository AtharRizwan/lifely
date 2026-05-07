import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../data/app_store.dart';
import '../../models/app_models.dart';
import '../../utils/navigation.dart';
import '../../utils/snackbar.dart';
import '../../widgets/app_bars/lifely_sliver_app_bar.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/buttons/theme_toggle_button.dart';
import '../../widgets/cards/capture_card.dart';
import '../../widgets/cards/insight_card.dart';
import '../../widgets/cards/summary_card.dart';
import '../../widgets/inputs/category_chip.dart';
import '../../widgets/tiles/scan_picker_tile.dart';
import '../../widgets/tiles/section_header.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<bool> onThemeModeChanged;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> with SingleTickerProviderStateMixin {
  final Set<String> _selectedCategories = {'Academics'};
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  List<String> _summaryBullets = const [];
  String? _extractedText;
  final List<String> _createdTasks = [];

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

  void _simulateScan(String source) {
    setState(() {
      _extractedText =
          'Neuro midterm notes: revise chapter 5, complete lab outline, schedule TA hours.';
    });
    showSnackBar(context, '$source captured. Text extracted.');
  }

  void _convertExtractedToTasks() {
    if (_extractedText == null) {
      showSnackBar(context, 'Scan notes or capture an image first.');
      return;
    }
    final store = AppScope.of(context);
    final bullets = _generateSummaryBullets(_extractedText!);
    final created = <String>[];
    for (final line in bullets.take(3)) {
      final task = TaskItem(
        id: 'task-${DateTime.now().millisecondsSinceEpoch}-${created.length}',
        title: line,
        subtitle: 'From scan - Today',
        category: 'Academics',
        accent: 0xFF5B8E7D,
        scheduledAt: DateTime.now(),
        estimatedMinutes: 40,
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
    showSnackBar(context, 'Created ${created.length} tasks from scan.');
  }

  void _summarizeNotes() {
    final text = _notesController.text.trim();
    setState(() {
      _summaryBullets = _generateSummaryBullets(text);
    });
    showSnackBar(context, 'Summary ready.');
  }

  void _applyRewrite() {
    final text = _taskController.text.trim();
    if (text.isEmpty) {
      showSnackBar(context, 'Add a draft task first.');
      return;
    }
    final suggestion = '${text[0].toUpperCase()}${text.substring(1)}';
    setState(() {
      _taskController.text = suggestion;
    });
    showSnackBar(context, 'Rewrite applied to quick add.');
  }

  void _openScanGallery() {
    _showScanPicker(
      context,
      onSelect: (text) {
        setState(() {
          _extractedText = text;
        });
      },
    );
  }

  List<String> _generateSummaryBullets(String text) {
    if (text.isEmpty) {
      return const [
        'Focus on the highest-impact task first.',
        'Batch low-priority items into one block.',
        'End with a quick review and reset.',
      ];
    }
    final fragments = text
        .split(RegExp(r'[\n\.]+'))
        .map((fragment) => fragment.trim())
        .where((fragment) => fragment.isNotEmpty)
        .toList();
    if (fragments.length >= 3) {
      return fragments.take(5).toList();
    }
    return const [
      'Summarize key tasks and deadlines.',
      'Identify one priority for today.',
      'Capture next steps for follow-up.',
    ];
  }

  @override
  void dispose() {
    _taskController.dispose();
    _notesController.dispose();
    _scaleController.dispose();
    super.dispose();
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
            IconButton(
              icon: const Icon(Icons.mic_none_rounded),
              onPressed: () =>
                  showSnackBar(context, 'Voice input is coming soon.'),
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
                onCapture: () => _simulateScan('Camera'),
                onScan: _openScanGallery,
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
              SummaryCard(bullets: _summaryBullets),
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
    if (text.isEmpty) {
      showSnackBar(context, 'Enter a task first.');
      return;
    }
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
    showSnackBar(context, 'Task added.');
  }
}

void _showScanPicker(
  BuildContext context, {
  required ValueChanged<String> onSelect,
}) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent scans',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ScanPickerTile(
                title: 'Study notes - 2 pages',
                subtitle: 'Captured today, 3:12 pm',
                onSelect: () {
                  Navigator.of(sheetContext).pop();
                  onSelect(
                    'Study notes: revise chapter 5, complete lab outline, schedule TA hours.',
                  );
                  showSnackBar(context, 'Scan selected. Text extracted.');
                },
              ),
              const SizedBox(height: 10),
              ScanPickerTile(
                title: 'Whiteboard recap',
                subtitle: 'Captured yesterday, 7:40 pm',
                onSelect: () {
                  Navigator.of(sheetContext).pop();
                  onSelect(
                    'Whiteboard: prioritize lab, read chapter 5, review stats quiz notes.',
                  );
                  showSnackBar(context, 'Scan selected. Text extracted.');
                },
              ),
              const SizedBox(height: 10),
              ScanPickerTile(
                title: 'Lab outline draft',
                subtitle: 'Captured yesterday, 9:05 am',
                onSelect: () {
                  Navigator.of(sheetContext).pop();
                  onSelect(
                    'Lab outline: draft intro, add references, finalize methods section.',
                  );
                  showSnackBar(context, 'Scan selected. Text extracted.');
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
