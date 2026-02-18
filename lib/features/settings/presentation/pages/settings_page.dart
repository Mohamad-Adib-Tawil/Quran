import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/core/theme/figma_typography.dart';
import '../../cubit/settings_cubit.dart';
import '../../cubit/settings_state.dart';
import 'package:quran_app/core/localization/app_localization_ext.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/core/assets/app_assets.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.settings,
          style: FigmaTypography.title19(color: scheme.onSurface),
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              _HeaderCard(
                title: t.settings,
                subtitle: t.settingsHeaderSubtitle,
                icon: Icons.tune_rounded,
              ),
              const SizedBox(height: 12),
              _SettingsCard(
                title: t.appearance,
                iconSvg: AppAssets.icSettingsGreen,
                child: Column(
                  children: [
                    _ThemeOptionTile(
                      title: t.light,
                      icon: Icons.light_mode_rounded,
                      selected: state.themeMode == ThemeMode.light,
                      onTap: () => context.read<SettingsCubit>().setTheme(
                        ThemeMode.light,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ThemeOptionTile(
                      title: t.dark,
                      icon: Icons.dark_mode_rounded,
                      selected: state.themeMode == ThemeMode.dark,
                      onTap: () => context.read<SettingsCubit>().setTheme(
                        ThemeMode.dark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ThemeOptionTile(
                      title: t.system,
                      icon: Icons.brightness_auto_rounded,
                      selected: state.themeMode == ThemeMode.system,
                      onTap: () => context.read<SettingsCubit>().setTheme(
                        ThemeMode.system,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SettingsCard(
                title: t.language,
                iconSvg: AppAssets.icLanguage,
                child: Row(
                  children: [
                    Expanded(
                      child: _LanguageOptionChip(
                        label: t.arabic,
                        selected: (state.localeCode ?? 'ar') == 'ar',
                        onTap: () =>
                            context.read<SettingsCubit>().setLocale('ar'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _LanguageOptionChip(
                        label: t.german,
                        selected: (state.localeCode ?? 'ar') == 'de',
                        onTap: () =>
                            context.read<SettingsCubit>().setLocale('de'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SettingsCard(
                title: t.studySettingsSectionTitle,
                iconSvg: AppAssets.icBookmarkSaved,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.25,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.studyGoalsEntryTitle,
                              style: FigmaTypography.body15(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              t.studyGoalsEntrySubtitle,
                              style: FigmaTypography.caption12(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.25,
                            ),
                          ),
                        ),
                        child: Text(
                          t.soon,
                          style: FigmaTypography.caption12(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _ScholarBioCard(
                title: t.scholarTitle,
                subtitle: t.scholarBioLabel,
                description: t.scholarBioDescription,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _HeaderCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              scheme.primary.withValues(alpha: 0.16),
              scheme.primary.withValues(alpha: 0.06),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          border: Border.all(color: scheme.primary.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: FigmaTypography.title18(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: FigmaTypography.caption12(
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final String? iconSvg;
  final Widget child;

  const _SettingsCard({required this.title, required this.child, this.iconSvg});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.16)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (iconSvg != null) ...[
                SvgPicture.asset(iconSvg!, width: 18, height: 18),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: FigmaTypography.body15(
                  color: Theme.of(context).colorScheme.onSurface,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected
              ? scheme.primary.withValues(alpha: 0.14)
              : scheme.surfaceContainerHighest.withValues(alpha: 0.35),
          border: Border.all(
            color: selected
                ? scheme.primary.withValues(alpha: 0.42)
                : scheme.outline.withValues(alpha: 0.14),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: FigmaTypography.body15(
                  color: selected ? scheme.primary : scheme.onSurface,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: 18,
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOptionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected
              ? scheme.primary.withValues(alpha: 0.14)
              : scheme.surfaceContainerHighest.withValues(alpha: 0.3),
          border: Border.all(
            color: selected
                ? scheme.primary.withValues(alpha: 0.46)
                : scheme.outline.withValues(alpha: 0.14),
          ),
        ),
        child: Text(
          label,
          style: FigmaTypography.body15(
            color: selected ? scheme.primary : scheme.onSurface,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ScholarBioCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;

  const _ScholarBioCard({
    required this.title,
    required this.subtitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.16)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: scheme.primary.withValues(alpha: 0.35)),
              image: const DecorationImage(
                image: AssetImage(
                  "assets/home/صورة الشيخ احمد كراسي الشخصية.png",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text(
            title,
            style: FigmaTypography.body15(
              color: Theme.of(context).colorScheme.onSurface,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            subtitle,
            style: FigmaTypography.caption12(
              color: Theme.of(context).hintColor,
            ),
          ),
          children: [
            Text(
              description,
              textAlign: TextAlign.start,
              style: FigmaTypography.body13(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
