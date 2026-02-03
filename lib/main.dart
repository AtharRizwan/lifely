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
    return CustomScrollView(
      slivers: [
        _LifelySliverAppBar(
          title: 'Good afternoon, Lina',
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
              _SectionHeader(title: 'Today’s tasks', action: 'See all'),
              const SizedBox(height: 10),
              _TaskCard(
                title: 'Read Chapter 5',
                subtitle: 'Cognitive Science · 7:00 pm',
                badge: 'Academics',
                accent: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              _TaskCard(
                title: 'Lab report outline',
                subtitle: 'Bio 204 · 2:30 pm',
                badge: 'Deadline',
                accent: const Color(0xFFD8A15C),
              ),
              const SizedBox(height: 12),
              _TaskCard(
                title: 'TA office hours',
                subtitle: 'Stats · 4:10 pm',
                badge: 'Calendar',
                accent: const Color(0xFF6C8A7B),
              ),
              const SizedBox(height: 20),
              _SectionHeader(title: 'Suggestion', action: 'Adjust load'),
              const SizedBox(height: 10),
              _InsightCard(
                title: 'Focus: one high-impact task.',
                body:
                    'Shift low-priority items to tomorrow for a cleaner block.',
              ),
              const SizedBox(height: 20),
              _SectionHeader(title: 'Daily recap', action: 'Open'),
              const SizedBox(height: 10),
              _RecapCard(completed: 2, pending: 3, mood: 'Steady'),
              const SizedBox(height: 28),
              _OfflineBanner(text: 'Offline mode · 2 items pending sync'),
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
              _SectionHeader(title: 'Timeline', action: 'Day view'),
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
              _SectionHeader(title: 'Week view', action: 'Edit'),
              const SizedBox(height: 10),
              _WeekOverviewCard(),
            ]),
          ),
        ),
      ],
    );
  }
}

class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({
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
          title: 'Quick add',
          subtitle: 'Type or speak naturally',
          actions: [
            _ThemeToggleButton(
              isDark: themeMode == ThemeMode.dark,
              onChanged: onThemeModeChanged,
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
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: '“Quiz prep Sunday afternoon”',
                ),
              ),
              const SizedBox(height: 16),
              _SectionHeader(title: 'AI rewrite', action: 'Apply'),
              const SizedBox(height: 10),
              _InsightCard(
                title: 'Review quiz material on Sunday afternoon',
                body: 'Category: Academics · Due: Sun, 4:00 pm',
              ),
              const SizedBox(height: 16),
              _SectionHeader(title: 'Quick categories', action: 'Edit'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  _Chip(label: 'Academics'),
                  _Chip(label: 'Group work'),
                  _Chip(label: 'Admin'),
                  _Chip(label: 'Wellness'),
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

class MoodJournalScreen extends StatelessWidget {
  const MoodJournalScreen({
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
          title: 'Mood journal',
          subtitle: 'Check in with yourself',
          actions: [
            _ThemeToggleButton(
              isDark: themeMode == ThemeMode.dark,
              onChanged: onThemeModeChanged,
            ),
            IconButton(
              icon: const Icon(Icons.insights_outlined),
              onPressed: () =>
                  _showSnackBar(context, 'Insights are coming soon.'),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _SectionHeader(title: 'Today', action: 'History'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: const [
                  _MoodChip(label: 'Focused'),
                  _MoodChip(label: 'Steady', selected: true),
                  _MoodChip(label: 'Stressed'),
                  _MoodChip(label: 'Low energy'),
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
              _SectionHeader(title: 'Suggestion', action: 'Adjust load'),
              const SizedBox(height: 10),
              _InsightCard(
                title: 'Keep the next block light.',
                body: 'Finish one core task, then reset.',
              ),
              const SizedBox(height: 20),
              _SectionHeader(title: 'Streaks', action: 'Details'),
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
  const _SectionHeader({required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        Text(
          action,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
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
  });

  final String title;
  final String subtitle;
  final String badge;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.dividerTheme.color ?? Colors.transparent,
        ),
      ),
      child: Text(label, style: theme.textTheme.labelMedium),
    );
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: selected
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.dividerTheme.color ?? Colors.transparent,
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: selected ? Colors.white : theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showSnackBar(context, '$label tapped.'),
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

void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
