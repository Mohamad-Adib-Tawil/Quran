import 'package:flutter/material.dart';
import 'package:quran_library/quran_library.dart';
import 'package:quran/core/theme/design_tokens.dart';
import 'package:quran/core/theme/app_colors.dart';
import 'package:quran/features/quran/presentation/pages/surah_list_page.dart';
import 'package:quran/features/quran/presentation/navigation/quran_open_target.dart';

class LastReadCard extends StatelessWidget {
  final int surah;
  final int ayah;
  const LastReadCard({super.key, required this.surah, required this.ayah});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = QuranLibrary().getSurahInfo(surahNumber: surah - 1);
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SurahListPage(openTarget: QuranOpenTarget.surah(surah)),
          ),
        );
      },
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          boxShadow: AppShadows.soft(AppColors.primary),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('آخر المقروء', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white70)),
                  const SizedBox(height: 6),
                  Text(info.name, style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('الآية $ayah', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
                ],
              ),
            ),
            const Icon(Icons.play_circle_fill, color: Colors.white, size: 36),
          ],
        ),
      ),
    );
  }
}
