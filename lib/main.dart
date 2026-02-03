import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const LifelyApp());
}

class LifelyApp extends StatefulWidget {
  const LifelyApp({super.key});

  @override
  State<LifelyApp> createState() => _LifelyAppState();
}

class _LifelyAppState extends State<LifelyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _updateThemeMode(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lifely',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: _themeMode,
      home: LifelyShell(
        themeMode: _themeMode,
        onThemeModeChanged: _updateThemeMode,
      ),
    );
  }
}

ThemeData _buildTheme(Brightness brightness) {
  const slateBlue = Color(0xFF4A5C8A);
  const ink = Color(0xFF111318);
  const offWhite = Color(0xFFF6F5F3);
  const surfaceLight = Color(0xFFF1F2F6);
  const surfaceDark = Color(0xFF1C1F24);
  const dividerLight = Color(0xFFE5E7EB);
  const dividerDark = Color(0xFF2A2F36);

  final isDark = brightness == Brightness.dark;
  final baseTextTheme = GoogleFonts.newsreaderTextTheme();
  final bodyTextTheme = GoogleFonts.interTextTheme();
  final textColor = isDark ? const Color(0xFFE7E7EA) : ink;
  final displayTextTheme = baseTextTheme.apply(
    bodyColor: textColor,
    displayColor: textColor,
  );
  final appliedBodyTextTheme = bodyTextTheme.apply(
    bodyColor: textColor,
    displayColor: textColor,
  );

  return ThemeData(
    brightness: brightness,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: slateBlue,
      onPrimary: Colors.white,
      secondary: slateBlue.withOpacity(0.16),
      onSecondary: isDark ? Colors.white : ink,
      error: const Color(0xFFD65A5A),
      onError: Colors.white,
      surface: isDark ? surfaceDark : offWhite,
      onSurface: isDark ? const Color(0xFFE7E7EA) : ink,
      surfaceContainerHighest: isDark ? const Color(0xFF262B33) : surfaceLight,
    ),
    scaffoldBackgroundColor: isDark ? const Color(0xFF15181D) : offWhite,
    textTheme: displayTextTheme.copyWith(
      headlineLarge: displayTextTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      headlineMedium: displayTextTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
      ),
      titleLarge: displayTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleMedium: displayTextTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: appliedBodyTextTheme.bodyLarge,
      bodyMedium: appliedBodyTextTheme.bodyMedium,
      bodySmall: appliedBodyTextTheme.bodySmall,
      labelLarge: appliedBodyTextTheme.labelLarge,
      labelMedium: appliedBodyTextTheme.labelMedium,
      labelSmall: appliedBodyTextTheme.labelSmall,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: isDark ? Colors.white : ink),
      titleTextStyle: baseTextTheme.titleLarge?.copyWith(
        color: isDark ? Colors.white : ink,
        fontWeight: FontWeight.w600,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: isDark ? dividerDark : dividerLight,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF232831) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: isDark ? dividerDark : dividerLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: isDark ? dividerDark : dividerLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: slateBlue, width: 1.2),
      ),
      hintStyle: TextStyle(
        color: isDark ? const Color(0xFF9FA6B2) : const Color(0xFF8A8F9A),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: isDark ? const Color(0xFF1E232A) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: isDark ? dividerDark : dividerLight),
      ),
      margin: EdgeInsets.zero,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: isDark ? const Color(0xFF15181D) : offWhite,
      selectedItemColor: slateBlue,
      unselectedItemColor: isDark
          ? const Color(0xFF8F95A1)
          : const Color(0xFF8A8F9A),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  );
}

class LifelyShell extends StatefulWidget {
  const LifelyShell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<bool> onThemeModeChanged;

  @override
  State<LifelyShell> createState() => _LifelyShellState();
}

class _LifelyShellState extends State<LifelyShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        themeMode: widget.themeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
      ),
      PlannerScreen(
        themeMode: widget.themeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
      ),
      AddTaskScreen(
        themeMode: widget.themeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
      ),
      MoodJournalScreen(
        themeMode: widget.themeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
      ),
      NotificationsScreen(
        themeMode: widget.themeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
      ),
    ];
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_rounded),
            label: 'Planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_graph_rounded),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_rounded),
            label: 'Alerts',
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<bool> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final greeting = _timeBasedGreeting(DateTime.now());
    return CustomScrollView(
      slivers: [
        _LifelySliverAppBar(
          title: '$greeting, Lina',
          subtitle: 'Midterm week · Focus window 2:00–5:00',
          actions: [
            _ThemeToggleButton(
              isDark: themeMode == ThemeMode.dark,
              onChanged: onThemeModeChanged,
            ),
            IconButton(
              icon: const Icon(Icons.person_outline_rounded),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        SettingsScreen(onThemeModeChanged: onThemeModeChanged),
                  ),
                );
              },
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _GradientHeroCard(
                title: 'Today, keep it tight',
                body: '3 tasks · 1 class · 1 reflection',
                footer: 'Recap ready at 9:00 pm',
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _MetricTile(
                      label: 'Focus',
                      value: '2h 40m',
                      detail: 'Deep work',
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _MetricTile(
                      label: 'Mood',
                      value: 'Steady',
                      detail: 'Logged 1 hr ago',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SectionHeader(
                title: 'Today’s tasks',
                action: 'See all',
                onActionTap: () => _openAllTasks(context),
              ),
              const SizedBox(height: 10),
              _TaskCard(
                title: 'Read Chapter 5',
                subtitle: 'Cognitive Science · 7:00 pm',
                badge: 'Academics',
                accent: theme.colorScheme.primary,
                onTap: () => _openTaskDetails(context, 'Read Chapter 5'),
              ),
              const SizedBox(height: 12),
              _TaskCard(
                title: 'Lab report outline',
                subtitle: 'Bio 204 · 2:30 pm',
                badge: 'Deadline',
                accent: const Color(0xFFD8A15C),
                onTap: () => _openTaskDetails(context, 'Lab report outline'),
              ),
              const SizedBox(height: 12),
              _TaskCard(
                title: 'TA office hours',
                subtitle: 'Stats · 4:10 pm',
                badge: 'Calendar',
                accent: const Color(0xFF6C8A7B),
                onTap: () => _openTaskDetails(context, 'TA office hours'),
              ),
              const SizedBox(height: 20),
              _SectionHeader(
                title: 'Suggestion',
                action: 'Adjust load',
                onActionTap: () => _openAdjustLoad(context),
              ),
              const SizedBox(height: 10),
              _InsightCard(
                title: 'Focus: one high-impact task.',
                body:
                    'Shift low-priority items to tomorrow for a cleaner block.',
              ),
              const SizedBox(height: 20),
              _SectionHeader(
                title: 'Daily recap',
                action: 'Open',
                onActionTap: () => _openDailyRecap(context),
              ),
              const SizedBox(height: 10),
              _RecapCard(completed: 2, pending: 3, mood: 'Steady'),
              const SizedBox(height: 28),
              _OfflineBanner(text: 'Offline mode · 2 items pending sync'),
              const SizedBox(height: 20),
              _SectionHeader(
                title: 'Personal progress tracker',
                action: 'Open',
                onActionTap: () => _openInsights(context),
              ),
              const SizedBox(height: 10),
              _ProgressTeaserCard(onOpen: () => _openInsights(context)),
            ]),
          ),
        ),
      ],
    );
  }
}

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<bool> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        _LifelySliverAppBar(
          title: 'Planner',
          subtitle: 'Thursday · Week 6',
          actions: [
            _ThemeToggleButton(
              isDark: themeMode == ThemeMode.dark,
              onChanged: onThemeModeChanged,
            ),
            IconButton(
              icon: const Icon(Icons.calendar_month_outlined),
              onPressed: () =>
                  _showSnackBar(context, 'Calendar view is coming soon.'),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _WeekStrip(),
              const SizedBox(height: 18),
              _SectionHeader(
                title: 'Timeline',
                action: 'Day view',
                onActionTap: () => _openDayView(context),
              ),
              const SizedBox(height: 10),
              _TimelineEntry(
                time: '9:00',
                title: 'Neuroscience lecture',
                detail: 'Hall B',
                accent: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              _TimelineEntry(
                time: '11:30',
                title: 'Library focus',
                detail: 'Chapter 5 notes',
                accent: const Color(0xFF6C8A7B),
              ),
              const SizedBox(height: 12),
              _TimelineEntry(
                time: '2:30',
                title: 'Lab report outline',
                detail: 'Submit to portal',
                accent: const Color(0xFFD8A15C),
              ),
              const SizedBox(height: 12),
              _TimelineEntry(
                time: '4:10',
                title: 'TA office hours',
                detail: 'Stats Q&A',
                accent: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              _SectionHeader(
                title: 'Week view',
                action: 'Edit',
                onActionTap: () => _openWeekEditor(context),
              ),
              const SizedBox(height: 10),
              _WeekOverviewCard(),
            ]),
          ),
        ),
      ],
    );
  }
}

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
    _showSnackBar(context, '$source captured. Text extracted.');
  }

  void _convertExtractedToTasks() {
    if (_extractedText == null) {
      _showSnackBar(context, 'Scan notes or capture an image first.');
      return;
    }
    _showSnackBar(context, 'Created 3 tasks from scan.');
  }

  void _summarizeNotes() {
    final text = _notesController.text.trim();
    setState(() {
      _summaryBullets = _generateSummaryBullets(text);
    });
    _showSnackBar(context, 'Summary ready.');
  }

  void _applyRewrite() {
    const suggestion = 'Review quiz material on Sunday afternoon';
    setState(() {
      _taskController.text = suggestion;
    });
    _showSnackBar(context, 'Rewrite applied to quick add.');
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
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        _LifelySliverAppBar(
          title: 'Quick add',
          subtitle: 'Type or speak naturally',
          actions: [
            _ThemeToggleButton(
              isDark: widget.themeMode == ThemeMode.dark,
              onChanged: widget.onThemeModeChanged,
            ),
            IconButton(
              icon: const Icon(Icons.mic_none_rounded),
              onPressed: () =>
                  _showSnackBar(context, 'Voice input is coming soon.'),
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
              _SectionHeader(
                title: 'Quick add from camera or scans',
                action: 'Learn more',
                onActionTap: () => _openOcrHelp(context),
              ),
              const SizedBox(height: 10),
              _CaptureCard(
                extractedText: _extractedText,
                onCapture: () => _simulateScan('Camera'),
                onScan: _openScanGallery,
                onConvert: _convertExtractedToTasks,
              ),
              const SizedBox(height: 18),
              _SectionHeader(
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
              _PrimaryButton(
                label: 'Summarize notes',
                onPressed: _summarizeNotes,
              ),
              const SizedBox(height: 12),
              _SummaryCard(bullets: _summaryBullets),
              const SizedBox(height: 18),
              _SectionHeader(
                title: 'AI rewrite',
                action: 'Apply',
                onActionTap: _applyRewrite,
              ),
              const SizedBox(height: 10),
              _InsightCard(
                title: 'Review quiz material on Sunday afternoon',
                body: 'Category: Academics · Due: Sun, 4:00 pm',
              ),
              const SizedBox(height: 16),
              const _SectionHeader(title: 'Quick categories'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Chip(
                    label: 'Academics',
                    selected: _selectedCategories.contains('Academics'),
                    onTap: () => _toggleCategory('Academics'),
                  ),
                  _Chip(
                    label: 'Group work',
                    selected: _selectedCategories.contains('Group work'),
                    onTap: () => _toggleCategory('Group work'),
                  ),
                  _Chip(
                    label: 'Admin',
                    selected: _selectedCategories.contains('Admin'),
                    onTap: () => _toggleCategory('Admin'),
                  ),
                  _Chip(
                    label: 'Wellness',
                    selected: _selectedCategories.contains('Wellness'),
                    onTap: () => _toggleCategory('Wellness'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _PrimaryButton(label: 'Add task'),
            ]),
          ),
        ),
      ],
    );
  }
}

class MoodJournalScreen extends StatefulWidget {
  const MoodJournalScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<bool> onThemeModeChanged;

  @override
  State<MoodJournalScreen> createState() => _MoodJournalScreenState();
}

class _MoodJournalScreenState extends State<MoodJournalScreen> {
  String _selectedMood = 'Steady';

  void _selectMood(String mood) {
    setState(() {
      _selectedMood = mood;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _LifelySliverAppBar(
          title: 'Mood journal',
          subtitle: 'Check in with yourself',
          actions: [
            _ThemeToggleButton(
              isDark: widget.themeMode == ThemeMode.dark,
              onChanged: widget.onThemeModeChanged,
            ),
            IconButton(
              icon: const Icon(Icons.insights_outlined),
              onPressed: () => _openInsights(context),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _SectionHeader(
                title: 'Today',
                action: 'History',
                onActionTap: () => _openMoodHistory(context),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MoodChip(
                    label: 'Focused',
                    selected: _selectedMood == 'Focused',
                    onTap: () => _selectMood('Focused'),
                  ),
                  _MoodChip(
                    label: 'Steady',
                    selected: _selectedMood == 'Steady',
                    onTap: () => _selectMood('Steady'),
                  ),
                  _MoodChip(
                    label: 'Stressed',
                    selected: _selectedMood == 'Stressed',
                    onTap: () => _selectMood('Stressed'),
                  ),
                  _MoodChip(
                    label: 'Low energy',
                    selected: _selectedMood == 'Low energy',
                    onTap: () => _selectMood('Low energy'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'What is driving your mood today?',
                ),
              ),
              const SizedBox(height: 20),
              _SectionHeader(
                title: 'Suggestion',
                action: 'Adjust load',
                onActionTap: () => _openAdjustLoad(context),
              ),
              const SizedBox(height: 10),
              _InsightCard(
                title: 'Keep the next block light.',
                body: 'Finish one core task, then reset.',
              ),
              const SizedBox(height: 20),
              _SectionHeader(
                title: 'Streaks',
                action: 'Details',
                onActionTap: () => _openStreakDetails(context),
              ),
              const SizedBox(height: 10),
              _MetricTile(
                label: 'Mood streak',
                value: '5 days',
                detail: 'Consistent check-ins',
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<bool> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _LifelySliverAppBar(
          title: 'Notifications',
          subtitle: 'Gentle nudges',
          actions: [
            _ThemeToggleButton(
              isDark: themeMode == ThemeMode.dark,
              onChanged: onThemeModeChanged,
            ),
            IconButton(
              icon: const Icon(Icons.tune_rounded),
              onPressed: () => _showSnackBar(
                context,
                'Notification filters are coming soon.',
              ),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _NotificationTile(
                title: 'Lab report due tomorrow',
                body: 'Draft 2 pages to stay on track.',
                time: '2h ago',
              ),
              const SizedBox(height: 12),
              _NotificationTile(
                title: 'Missed: Stats quiz review',
                body: 'Reschedule for 7:30 pm?',
                time: 'Yesterday',
              ),
              const SizedBox(height: 12),
              _NotificationTile(
                title: 'Daily recap ready',
                body: '2 tasks done, 3 pending.',
                time: '9:05 pm',
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.onThemeModeChanged});

  final ValueChanged<bool> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: SwitchListTile(
              value: isDark,
              onChanged: onThemeModeChanged,
              title: const Text('Dark mode'),
              subtitle: const Text('Keep contrast low and focused'),
            ),
          ),
          const SizedBox(height: 12),
          _SettingsTile(title: 'Theme', value: isDark ? 'Dark' : 'Light'),
          _SettingsTile(title: 'Font size', value: 'Default'),
          _SettingsTile(title: 'Layout density', value: 'Comfortable'),
          const SizedBox(height: 20),
          _InsightCard(
            title: 'Daily affirmation',
            body: 'Small steps compound. Focus on one task now.',
          ),
        ],
      ),
    );
  }
}

class _LifelySliverAppBar extends StatelessWidget {
  const _LifelySliverAppBar({
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: false,
      expandedHeight: 112,
      flexibleSpace: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 120, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: actions
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: EdgeInsets.only(
                right: entry.key == actions.length - 1 ? 12 : 4,
              ),
              child: entry.value,
            ),
          )
          .toList(),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton({required this.isDark, required this.onChanged});

  final bool isDark;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
      onPressed: () => onChanged(!isDark),
    );
  }
}

class _GradientHeroCard extends StatelessWidget {
  const _GradientHeroCard({
    required this.title,
    required this.body,
    required this.footer,
  });

  final String title;
  final String body;
  final String footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surfaceContainerHighest,
            theme.colorScheme.surface.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: theme.dividerTheme.color ?? Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(body, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Text(
            footer,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            const SizedBox(height: 6),
            Text(value, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              detail,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action, this.onActionTap});

  final String title;
  final String? action;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        if (action != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              action ?? '',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: onActionTap == null ? null : FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.accent,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String badge;
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
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
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
                  color: accent.withOpacity(0.14),
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

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              body,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecapCard extends StatelessWidget {
  const _RecapCard({
    required this.completed,
    required this.pending,
    required this.mood,
  });

  final int completed;
  final int pending;
  final String mood;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completed: $completed',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Pending: $pending',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Mood: $mood',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.dividerTheme.color ?? Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(days.length, (index) {
        final isActive = index == 3;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.dividerTheme.color ?? Colors.transparent,
              ),
            ),
            child: Column(
              children: [
                Text(
                  days[index],
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isActive
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${index + 10}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: isActive
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.time,
    required this.title,
    required this.detail,
    required this.accent,
  });

  final String time;
  final String title;
  final String detail;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Card(
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
                      ).colorScheme.onSurface.withOpacity(0.6),
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
    );
  }
}

class _WeekOverviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Core milestones', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _ChecklistItem(text: 'Draft lab report outline', done: true),
            const SizedBox(height: 8),
            _ChecklistItem(text: 'Study group agenda', done: false),
            const SizedBox(height: 8),
            _ChecklistItem(text: 'Quiz practice set', done: false),
          ],
        ),
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.text, required this.done});

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

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.title,
    required this.body,
    required this.time,
  });

  final String title;
  final String body;
  final String time;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              body,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              time,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: theme.textTheme.titleMedium),
        trailing: Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.selected = false, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary.withOpacity(0.18)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : (theme.dividerTheme.color ?? Colors.transparent),
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
              fontWeight: selected ? FontWeight.w600 : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({required this.label, this.selected = false, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : (theme.dividerTheme.color ?? Colors.transparent),
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: selected ? Colors.white : theme.colorScheme.onSurface,
              fontWeight: selected ? FontWeight.w600 : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed ?? () => _showSnackBar(context, '$label tapped.'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class _ProgressTrackerCard extends StatelessWidget {
  const _ProgressTrackerCard({
    required this.taskStreak,
    required this.loadBalance,
    required this.achievements,
  });

  final int taskStreak;
  final double loadBalance;
  final List<String> achievements;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final balancePercent = (loadBalance * 100).round().clamp(0, 100);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Task streak', style: theme.textTheme.titleMedium),
                Text('$taskStreak days', style: theme.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 10),
            _StreakBars(activeCount: taskStreak.clamp(0, 7)),
            const SizedBox(height: 16),
            Text('Load balance', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: loadBalance.clamp(0, 1),
                      minHeight: 10,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('$balancePercent%'),
              ],
            ),
            const SizedBox(height: 16),
            Text('Achievements', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ...achievements.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item, style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakBars extends StatelessWidget {
  const _StreakBars({required this.activeCount});

  final int activeCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: List.generate(7, (index) {
        final isActive = index < activeCount;
        return Expanded(
          child: Container(
            height: 10,
            margin: EdgeInsets.only(right: index == 6 ? 0 : 6),
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}

class _CaptureCard extends StatelessWidget {
  const _CaptureCard({
    required this.extractedText,
    required this.onCapture,
    required this.onScan,
    required this.onConvert,
  });

  final String? extractedText;
  final VoidCallback onCapture;
  final VoidCallback onScan;
  final VoidCallback onConvert;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Capture a note', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Scan handwritten notes or capture a photo to extract tasks.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCapture,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onScan,
                    icon: const Icon(Icons.document_scanner_outlined),
                    label: const Text('Scan'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.dividerTheme.color ?? Colors.transparent,
                ),
              ),
              child: Text(
                extractedText ??
                    'Extracted text will appear here after a scan.',
                style: theme.textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 12),
            _PrimaryButton(label: 'Convert to tasks', onPressed: onConvert),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.bullets});

  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Summary', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _SummaryBulletList(bullets: bullets),
          ],
        ),
      ),
    );
  }
}

class _ProgressTeaserCard extends StatelessWidget {
  const _ProgressTeaserCard({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progress highlights', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Your weekly rhythm is steady. Open insights for charts and trends.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(label: 'Streak', value: '5 days'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStat(label: 'Balance', value: '68%'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStat(label: 'Achv.', value: '3'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _PrimaryButton(label: 'Open insights', onPressed: onOpen),
          ],
        ),
      ),
    );
  }
}

class _SummaryBulletList extends StatelessWidget {
  const _SummaryBulletList({required this.bullets});

  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (bullets.isEmpty) {
      return Text(
        'Generate a summary to see 3–5 bullets here.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      );
    }
    return Column(
      children: bullets
          .map(
            (bullet) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  title: Text(bullet, style: theme.textTheme.bodyMedium),
                  trailing: const Icon(Icons.add_circle_outline),
                  onTap: () =>
                      _showSnackBar(context, 'Task created from bullet.'),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: theme.textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

String _timeBasedGreeting(DateTime now) {
  final hour = now.hour;
  if (hour < 12) {
    return 'Good morning';
  }
  if (hour < 17) {
    return 'Good afternoon';
  }
  return 'Good evening';
}

void _openInsights(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const _InsightsScreen()));
}

void _openAllTasks(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const _AllTasksScreen()));
}

void _openTaskDetails(BuildContext context, String title) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => _TaskDetailsScreen(taskTitle: title)),
  );
}

void _openAdjustLoad(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const _AdjustLoadScreen()));
}

void _openDailyRecap(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const _DailyRecapScreen()));
}

void _openDayView(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const _DayViewScreen()));
}

void _openWeekEditor(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const _WeekEditorScreen()));
}

void _openMoodHistory(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const _MoodHistoryScreen()));
}

void _openStreakDetails(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const _StreakDetailsScreen()));
}

void _openOcrHelp(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const _OcrHelpScreen()));
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
              _ScanPickerTile(
                title: 'Study notes · 2 pages',
                subtitle: 'Captured today, 3:12 pm',
                onSelect: () {
                  Navigator.of(sheetContext).pop();
                  onSelect(
                    'Study notes: revise chapter 5, complete lab outline, schedule TA hours.',
                  );
                  _showSnackBar(context, 'Scan selected. Text extracted.');
                },
              ),
              const SizedBox(height: 10),
              _ScanPickerTile(
                title: 'Whiteboard recap',
                subtitle: 'Captured yesterday, 7:40 pm',
                onSelect: () {
                  Navigator.of(sheetContext).pop();
                  onSelect(
                    'Whiteboard: prioritize lab, read chapter 5, review stats quiz notes.',
                  );
                  _showSnackBar(context, 'Scan selected. Text extracted.');
                },
              ),
              const SizedBox(height: 10),
              _ScanPickerTile(
                title: 'Lab outline draft',
                subtitle: 'Captured yesterday, 9:05 am',
                onSelect: () {
                  Navigator.of(sheetContext).pop();
                  onSelect(
                    'Lab outline: draft intro, add references, finalize methods section.',
                  );
                  _showSnackBar(context, 'Scan selected. Text extracted.');
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _ScanPickerTile extends StatelessWidget {
  const _ScanPickerTile({
    required this.title,
    required this.subtitle,
    required this.onSelect,
  });

  final String title;
  final String subtitle;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(
          Icons.description_outlined,
          color: theme.colorScheme.primary,
        ),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onSelect,
      ),
    );
  }
}

class _AdjustLoadScreen extends StatelessWidget {
  const _AdjustLoadScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Adjust load')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ActionCard(
            title: 'Move one task',
            subtitle: 'Shift a low-priority task to tomorrow.',
            actionLabel: 'Reschedule',
            onAction: () => _showSnackBar(context, 'Task moved to tomorrow.'),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            title: 'Create a focus block',
            subtitle: 'Reserve 90 minutes for deep work.',
            actionLabel: 'Add block',
            onAction: () => _showSnackBar(context, 'Focus block added.'),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            title: 'Quiet notifications',
            subtitle: 'Mute alerts for the next 2 hours.',
            actionLabel: 'Enable',
            onAction: () => _showSnackBar(context, 'Quiet mode enabled.'),
          ),
        ],
      ),
    );
  }
}

class _DailyRecapScreen extends StatelessWidget {
  const _DailyRecapScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Daily recap')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _RecapCard(completed: 2, pending: 3, mood: 'Steady'),
          const SizedBox(height: 12),
          _SimpleListTile(
            icon: Icons.check_circle_outline,
            title: 'Finished tasks',
            subtitle: 'Read Chapter 5, Lab outline',
          ),
          const SizedBox(height: 10),
          _SimpleListTile(
            icon: Icons.pending_actions_outlined,
            title: 'Pending tasks',
            subtitle: 'TA office hours, Quiz prep',
          ),
        ],
      ),
    );
  }
}

class _DayViewScreen extends StatelessWidget {
  const _DayViewScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Day view')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _TimelineEntry(
            time: '9:00',
            title: 'Neuroscience lecture',
            detail: 'Hall B',
            accent: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          _TimelineEntry(
            time: '11:30',
            title: 'Library focus',
            detail: 'Chapter 5 notes',
            accent: const Color(0xFF6C8A7B),
          ),
          const SizedBox(height: 12),
          _TimelineEntry(
            time: '2:30',
            title: 'Lab report outline',
            detail: 'Submit to portal',
            accent: const Color(0xFFD8A15C),
          ),
        ],
      ),
    );
  }
}

class _WeekEditorScreen extends StatelessWidget {
  const _WeekEditorScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit week')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ActionCard(
            title: 'Adjust study blocks',
            subtitle: 'Balance deep work across days.',
            actionLabel: 'Update blocks',
            onAction: () => _showSnackBar(context, 'Blocks updated.'),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            title: 'Add recurring tasks',
            subtitle: 'Daily recap and review.',
            actionLabel: 'Add recurring',
            onAction: () => _showSnackBar(context, 'Recurring tasks added.'),
          ),
        ],
      ),
    );
  }
}

class _MoodHistoryScreen extends StatelessWidget {
  const _MoodHistoryScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mood history')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _MoodHistoryTile(
            mood: 'Steady',
            time: 'Today · 2:05 pm',
            note: 'Felt focused after the morning lecture.',
          ),
          SizedBox(height: 12),
          _MoodHistoryTile(
            mood: 'Focused',
            time: 'Yesterday · 6:15 pm',
            note: 'Completed lab outline.',
          ),
          SizedBox(height: 12),
          _MoodHistoryTile(
            mood: 'Low energy',
            time: 'Tue · 9:10 pm',
            note: 'Long day, need rest.',
          ),
        ],
      ),
    );
  }
}

class _MoodHistoryTile extends StatelessWidget {
  const _MoodHistoryTile({
    required this.mood,
    required this.time,
    required this.note,
  });

  final String mood;
  final String time;
  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mood, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              time,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(note, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _OcrHelpScreen extends StatelessWidget {
  const _OcrHelpScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('OCR help')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Turn handwritten notes into tasks in seconds.',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _ActionCard(
            title: 'Capture a clear photo',
            subtitle: 'Keep lighting even and avoid shadows.',
            actionLabel: 'Try camera',
            onAction: () => _showSnackBar(context, 'Camera opened.'),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            title: 'Crop to the notes',
            subtitle: 'Focus on the text you want converted.',
            actionLabel: 'Open scans',
            onAction: () => _showSnackBar(context, 'Scan gallery opened.'),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            title: 'Review extracted tasks',
            subtitle: 'Confirm and edit before adding.',
            actionLabel: 'Preview',
            onAction: () => _showSnackBar(context, 'Preview opened.'),
          ),
        ],
      ),
    );
  }
}

class _StreakDetailsScreen extends StatelessWidget {
  const _StreakDetailsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Streak details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _MetricTile(
            label: 'Mood streak',
            value: '5 days',
            detail: 'Consistent check-ins',
          ),
          const SizedBox(height: 12),
          _MetricTile(
            label: 'Completion streak',
            value: '3 days',
            detail: 'Daily tasks completed',
          ),
          const SizedBox(height: 12),
          _MetricTile(
            label: 'Planner streak',
            value: '7 days',
            detail: 'Weekly planning sessions',
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 12),
            _PrimaryButton(label: actionLabel, onPressed: onAction),
          ],
        ),
      ),
    );
  }
}

class _SimpleListTile extends StatelessWidget {
  const _SimpleListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: () => _showSnackBar(context, 'Opened $title.'),
      ),
    );
  }
}

class _AllTasksScreen extends StatelessWidget {
  const _AllTasksScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('All tasks')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _TaskCard(
            title: 'Read Chapter 5',
            subtitle: 'Cognitive Science · 7:00 pm',
            badge: 'Academics',
            accent: theme.colorScheme.primary,
            onTap: () => _openTaskDetails(context, 'Read Chapter 5'),
          ),
          const SizedBox(height: 12),
          _TaskCard(
            title: 'Lab report outline',
            subtitle: 'Bio 204 · 2:30 pm',
            badge: 'Deadline',
            accent: const Color(0xFFD8A15C),
            onTap: () => _openTaskDetails(context, 'Lab report outline'),
          ),
          const SizedBox(height: 12),
          _TaskCard(
            title: 'TA office hours',
            subtitle: 'Stats · 4:10 pm',
            badge: 'Calendar',
            accent: const Color(0xFF6C8A7B),
            onTap: () => _openTaskDetails(context, 'TA office hours'),
          ),
        ],
      ),
    );
  }
}

class _TaskDetailsScreen extends StatelessWidget {
  const _TaskDetailsScreen({required this.taskTitle});

  final String taskTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Task details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(taskTitle, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    'Scheduled today · 45 min',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        color: theme.colorScheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text('Academics', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: theme.colorScheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text('Est. 45 min', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _PrimaryButton(
            label: 'Mark complete',
            onPressed: () => _showSnackBar(context, 'Task marked complete.'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () =>
                _showSnackBar(context, 'Task rescheduled for tomorrow.'),
            child: const Text('Reschedule'),
          ),
        ],
      ),
    );
  }
}

class _InsightsScreen extends StatelessWidget {
  const _InsightsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ProgressTrackerCard(
            taskStreak: 5,
            loadBalance: 0.68,
            achievements: const [
              'Focus streak · 5 days',
              'Planner consistency · 82%',
              'Weekly balance · On track',
            ],
          ),
          const SizedBox(height: 16),
          _ChartCard(
            title: 'Task streaks',
            subtitle: 'Last 7 days',
            bars: const [3, 4, 2, 5, 6, 4, 5],
          ),
          const SizedBox(height: 16),
          _ChartCard(
            title: 'Load balance',
            subtitle: 'Focus vs. admin',
            bars: const [6, 3, 7, 4, 5, 6, 4],
          ),
          const SizedBox(height: 16),
          _AchievementGrid(
            items: const [
              'Early bird',
              'Consistency',
              'Inbox zero',
              'Wellness',
              'Deep work',
              'Weekly reset',
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.bars,
  });

  final String title;
  final String subtitle;
  final List<int> bars;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxValue = bars.isEmpty ? 1 : bars.reduce((a, b) => a > b ? a : b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(bars.length, (index) {
                final value = bars[index];
                final height = 80 * (value / maxValue);
                return Expanded(
                  child: Container(
                    height: height,
                    margin: EdgeInsets.only(
                      right: index == bars.length - 1 ? 0 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementGrid extends StatelessWidget {
  const _AchievementGrid({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Achievements', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: items
                  .map(
                    (item) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.dividerTheme.color ?? Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.emoji_events_outlined,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(item, style: theme.textTheme.labelMedium),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
