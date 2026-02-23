import 'package:flutter/material.dart';

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

class _AddTaskScreenState extends State<AddTaskScreen> {
  final Set<String> _selectedCategories = {'Academics'};
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  List<String> _summaryBullets = const [];
  String? _extractedText;

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
    showSnackBar(context, 'Created 3 tasks from scan.');
  }

  void _summarizeNotes() {
    final text = _notesController.text.trim();
    setState(() {
      _summaryBullets = _generateSummaryBullets(text);
    });
    showSnackBar(context, 'Summary ready.');
  }

  void _applyRewrite() {
    const suggestion = 'Review quiz material on Sunday afternoon';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
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
                  hintText: '“Quiz prep Sunday afternoon”',
                ),
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
              const InsightCard(
                title: 'Review quiz material on Sunday afternoon',
                body: 'Category: Academics - Due: Sun, 4:00 pm',
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
              const PrimaryButton(label: 'Add task'),
            ]),
          ),
        ),
      ],
    );
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
