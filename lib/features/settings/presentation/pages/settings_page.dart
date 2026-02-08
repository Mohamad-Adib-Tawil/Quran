import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/core/theme/figma_palette.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: Text(t.settings)),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _SectionTitle(
                title: t.appearance,
                iconSvg: AppAssets.icSettingsGreen,
              ),
              RadioListTile<ThemeMode>(
                title: Text(t.light),
                value: ThemeMode.light,
                groupValue: state.themeMode,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (v) => context.read<SettingsCubit>().setTheme(v!),
              ),
              RadioListTile<ThemeMode>(
                title: Text(t.dark),
                value: ThemeMode.dark,
                groupValue: state.themeMode,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (v) => context.read<SettingsCubit>().setTheme(v!),
              ),
              RadioListTile<ThemeMode>(
                title: Text(t.system),
                value: ThemeMode.system,
                groupValue: state.themeMode,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (v) => context.read<SettingsCubit>().setTheme(v!),
              ),
              const Divider(height: 24),
              _SectionTitle(title: t.language, iconSvg: AppAssets.icLanguage),
              RadioListTile<String>(
                title: Text(t.arabic),
                value: 'ar',
                groupValue: state.localeCode ?? 'ar',
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (v) => context.read<SettingsCubit>().setLocale(v!),
              ),
              RadioListTile<String>(
                title: Text(t.german),
                value: 'de',
                groupValue: state.localeCode ?? 'ar',
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (v) => context.read<SettingsCubit>().setLocale(v!),
              ),

              // SwitchListTile(
              //   title: Text(t.showVerseEndSymbol),
              //   value: state.verseEndSymbol,
              //   onChanged: (v) => context.read<SettingsCubit>().toggleVerseEndSymbol(v),
              // ),
              const Divider(height: 24),
              const SizedBox(height: 24),
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage(
                      "assets/home/صورة الشيخ احمد كراسي الشخصية.png",
                    ),
                    fit: BoxFit.contain,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).shadowColor.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "الشيخ أحمد كراسي رحمه الله",
                textAlign: TextAlign.center,
                style: FigmaTypography.body15(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.onSurface
                      : FigmaPalette.textDark,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? iconSvg;
  const _SectionTitle({required this.title, this.iconSvg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          if (iconSvg != null) ...[
            SvgPicture.asset(iconSvg!, width: 20, height: 20),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: FigmaTypography.body15(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.onSurface
                  : FigmaPalette.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
