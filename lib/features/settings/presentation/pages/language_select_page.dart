import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../quran/presentation/pages/surah_list_page.dart';
import '../../cubit/settings_cubit.dart';

class LanguageSelectPage extends StatelessWidget {
  const LanguageSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('اختر اللغة')), // Arabic: Choose language
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            _LangButton(
              label: 'العربية',
              onTap: () {
                context.read<SettingsCubit>().setLocale('ar');
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const SurahListPage()),
                );
              },
            ),
            const SizedBox(height: 12),
            _LangButton(
              label: 'Deutsch',
              onTap: () {
                context.read<SettingsCubit>().setLocale('de');
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const SurahListPage()),
                );
              },
            ),
            const Spacer(),
            Text(
              'يمكن تغيير اللغة لاحقًا من الإعدادات',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _LangButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
