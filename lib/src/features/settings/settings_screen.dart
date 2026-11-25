import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/data_providers_v3.dart';
import '../../data/meal_plan_repository.dart';
import '../../providers.dart';

/// SCR-53 (AC-58, AC-64, AC-43): giao diện, ngôn ngữ, đơn vị nấu, ngày đầu
/// tuần, các bữa, khu vực đi chợ, gia vị cơ bản và vùng nguy hiểm.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final repo = ref.watch(settingsRepositoryProvider);
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    final localeCode = ref.watch(localeCodeProvider).value ?? '';
    final units = ref.watch(unitSystemProvider).value ?? 'metric';
    final weekStart = ref.watch(weekStartProvider).value ?? DateTime.monday;
    final ignoreBasics = ref.watch(ignoreBasicsProvider).value ?? false;
    final slots = ref.watch(mealSlotsProvider).value ?? const <MealSlot>[];
    final titleStyle = theme.textTheme.titleSmall?.copyWith(
      color: theme.colorScheme.primary,
    );
    final stack = MediaQuery.textScalerOf(context).scale(1) > 1.3
        ? Axis.vertical
        : Axis.horizontal;
    Widget header(String t) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Semantics(header: true, child: Text(t, style: titleStyle)),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          header(l.settingsAppearance),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(l.theme, style: theme.textTheme.labelLarge),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              direction: stack,
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(l.themeSystem),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(l.themeLight),
                ),
                ButtonSegment(value: ThemeMode.dark, label: Text(l.themeDark)),
              ],
              selected: {themeMode},
              onSelectionChanged: (s) => repo.setThemeMode(s.first),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(l.language, style: theme.textTheme.labelLarge),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<String>(
              direction: stack,
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: '', label: Text(l.languageSystem)),
                ButtonSegment(value: 'en', label: Text(l.languageEnglish)),
                ButtonSegment(value: 'vi', label: Text(l.languageVietnamese)),
              ],
              selected: {localeCode},
              onSelectionChanged: (s) =>
                  repo.setLocaleCode(s.first.isEmpty ? null : s.first),
            ),
          ),
          header(l.settingsCooking),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              l.settingsDefaultUnits,
              style: theme.textTheme.labelLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<String>(
              direction: stack,
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: 'metric', label: Text(l.unitMetric)),
                ButtonSegment(value: 'us', label: Text(l.unitUs)),
              ],
              selected: {units},
              onSelectionChanged: (s) => repo.setUnitSystem(s.first),
            ),
          ),
          header(l.settingsMenu),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(l.settingsWeekStart, style: theme.textTheme.labelLarge),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<int>(
              direction: stack,
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: DateTime.monday,
                  label: Text(l.settingsMonday),
                ),
                ButtonSegment(
                  value: DateTime.sunday,
                  label: Text(l.settingsSunday),
                ),
              ],
              selected: {
                weekStart == DateTime.sunday
                    ? DateTime.sunday
                    : DateTime.monday,
              },
              onSelectionChanged: (s) => repo.setWeekStart(s.first),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_outlined),
            title: Text(l.settingsMealSlots),
            subtitle: Text(
              slots.isEmpty
                  ? l.menuMealSlots
                  : slots.map((s) => s.name).join(', '),
            ),
            onTap: () => context.push('/settings/meal-slots'),
          ),
          header(l.settingsShoppingPantry),
          ListTile(
            leading: const Icon(Icons.storefront_outlined),
            title: Text(l.settingsAisles),
            onTap: () => context.push('/shopping/aisles'),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.spa_outlined),
            title: Text(l.settingsIgnoreBasics),
            value: ignoreBasics,
            onChanged: repo.setIgnoreBasics,
          ),
          header(l.dangerZone),
          ListTile(
            leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
            title: Text(
              l.settingsDeleteAll,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () => context.push('/settings/delete-all'),
          ),
        ],
      ),
    );
  }
}
