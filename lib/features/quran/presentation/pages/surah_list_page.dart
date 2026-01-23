import 'package:flutter/material.dart';
import 'package:quran_library/quran_library.dart';
import 'package:quran/features/audio/presentation/widgets/mini_player.dart';
import 'package:quran/features/audio/presentation/pages/audio_downloads_page.dart';
import 'package:quran/features/audio/presentation/widgets/surah_auto_sync.dart';

class SurahListPage extends StatelessWidget {
  const SurahListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    return Scaffold(
      body: QuranLibraryScreen(
        parentContext: context,
        withPageView: true,
        useDefaultAppBar: true,
        isShowAudioSlider: false,
        showAyahBookmarkedIcon: false,
        isDark: isDark,
        backgroundColor: Theme.of(context).colorScheme.surface,
        textColor: textColor,
        ayahSelectedBackgroundColor: primary.withValues(alpha: 0.12),
        ayahIconColor: primary,
        surahInfoStyle: SurahInfoStyle.defaults(isDark: isDark, context: context),
        basmalaStyle: BasmalaStyle(
          verticalPadding: 0.0,
          basmalaColor: textColor.withValues(alpha: 0.85),
          basmalaFontSize: 28.0,
        ),
        ayahStyle: AyahAudioStyle.defaults(isDark: isDark, context: context)
            .copyWith(dialogWidth: 320, readersTabText: 'القراء')
            .copyWith(),
        topBarStyle: QuranTopBarStyle.defaults(isDark: isDark, context: context).copyWith(
          showAudioButton: false,
          showFontsButton: true,
          tabIndexLabel: 'الفهرس',
          tabBookmarksLabel: 'العلامات',
          tabSearchLabel: 'بحث',
        ),
        indexTabStyle: IndexTabStyle.defaults(isDark: isDark, context: context).copyWith(
          tabSurahsLabel: 'السور',
          tabJozzLabel: 'الأجزاء',
        ),
        ayahMenuStyle: AyahMenuStyle.defaults(isDark: isDark, context: context)
            .copyWith(copySuccessMessage: 'تم النسخ', showPlayAllButton: false),
        topBottomQuranStyle:
            TopBottomQuranStyle.defaults(isDark: isDark, context: context).copyWith(
          hizbName: 'الحزب',
          juzName: 'الجزء',
          sajdaName: 'السجدة',
        ),
      ),
      bottomNavigationBar: const SurahAutoSync(child: MiniAudioPlayer()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AudioDownloadsPage()),
          );
        },
        icon: const Icon(Icons.library_music),
        label: const Text('إدارة الصوت'),
      ),
    );
  }
}
