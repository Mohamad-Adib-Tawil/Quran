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
    return Scaffold(
      appBar: AppBar(title: Text(t.settings)),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _SectionTitle(title: t.appearance, iconSvg: AppAssets.icSettingsGreen)
                  ,
              RadioListTile<ThemeMode>(
                title: Text(t.light),
                value: ThemeMode.light,
                groupValue: state.themeMode,
                onChanged: (v) => context.read<SettingsCubit>().setTheme(v!),
              ),
              RadioListTile<ThemeMode>(
                title: Text(t.dark),
                value: ThemeMode.dark,
                groupValue: state.themeMode,
                onChanged: (v) => context.read<SettingsCubit>().setTheme(v!),
              ),
              RadioListTile<ThemeMode>(
                title: Text(t.system),
                value: ThemeMode.system,
                groupValue: state.themeMode,
                onChanged: (v) => context.read<SettingsCubit>().setTheme(v!),
              ),
              const Divider(height: 24),
              _SectionTitle(title: t.language, iconSvg: AppAssets.icLanguage)
                  ,
              RadioListTile<String>(
                title: Text(t.arabic),
                value: 'ar',
                groupValue: state.localeCode ?? 'ar',
                onChanged: (v) => context.read<SettingsCubit>().setLocale(v!),
              ),
              RadioListTile<String>(
                title: Text(t.german),
                value: 'de',
                groupValue: state.localeCode ?? 'ar',
                onChanged: (v) => context.read<SettingsCubit>().setLocale(v!),
              ),
              const Divider(height: 24),
              _SectionTitle(title: t.fontSize)
                  ,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text('A-'),
                    Expanded(
                      child: Slider(
                        value: 1.0, // frozen
                        min: 1.0,
                        max: 1.0,
                        divisions: 1,
                        onChanged: null, // disabled temporarily
                      ),
                    ),
                    Row(children: [const Text('A+'), const SizedBox(width: 8), Chip(label: Text(t.soon))])
                  ],
                ),
              ),
              const Divider(height: 24),
              SwitchListTile(
                title: Text(t.showVerseEndSymbol),
                value: state.verseEndSymbol,
                onChanged: (v) => context.read<SettingsCubit>().toggleVerseEndSymbol(v),
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
          Text(title, style: FigmaTypography.body15(color: FigmaPalette.textDark)),
        ],
      ),
    );
  }
}
