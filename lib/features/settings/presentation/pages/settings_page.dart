import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran/core/theme/figma_palette.dart';
import 'package:quran/core/theme/figma_typography.dart';
import '../../cubit/settings_cubit.dart';
import '../../cubit/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              const _SectionTitle(title: 'المظهر')
                  ,
              RadioListTile<ThemeMode>(
                title: const Text('فاتح'),
                value: ThemeMode.light,
                groupValue: state.themeMode,
                onChanged: (v) => context.read<SettingsCubit>().setTheme(v!),
              ),
              RadioListTile<ThemeMode>(
                title: const Text('داكن'),
                value: ThemeMode.dark,
                groupValue: state.themeMode,
                onChanged: (v) => context.read<SettingsCubit>().setTheme(v!),
              ),
              RadioListTile<ThemeMode>(
                title: const Text('حسب النظام'),
                value: ThemeMode.system,
                groupValue: state.themeMode,
                onChanged: (v) => context.read<SettingsCubit>().setTheme(v!),
              ),
              const Divider(height: 24),
              const _SectionTitle(title: 'اللغة')
                  ,
              RadioListTile<String>(
                title: const Text('العربية'),
                value: 'ar',
                groupValue: state.localeCode ?? 'ar',
                onChanged: (v) => context.read<SettingsCubit>().setLocale(v!),
              ),
              RadioListTile<String>(
                title: const Text('Deutsch'),
                value: 'de',
                groupValue: state.localeCode ?? 'ar',
                onChanged: (v) => context.read<SettingsCubit>().setLocale(v!),
              ),
              const Divider(height: 24),
              const _SectionTitle(title: 'حجم الخط')
                  ,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text('A-'),
                    Expanded(
                      child: Slider(
                        value: state.fontScale,
                        min: 0.8,
                        max: 2.0,
                        divisions: 12,
                        onChanged: (v) => context.read<SettingsCubit>().setFontScale(v),
                      ),
                    ),
                    const Text('A+')
                  ],
                ),
              ),
              const Divider(height: 24),
              SwitchListTile(
                title: const Text('إظهار علامة نهاية الآية'),
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
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(title, style: FigmaTypography.body15(color: FigmaPalette.textDark)),
    );
  }
}
