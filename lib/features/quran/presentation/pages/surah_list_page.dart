import 'package:flutter/material.dart';
import 'package:quran_library/quran_library.dart';
import 'package:quran_app/features/audio/presentation/widgets/mini_player.dart';
import 'package:quran_app/features/audio/presentation/pages/audio_downloads_page.dart';
import 'package:quran_app/features/audio/presentation/widgets/surah_auto_sync.dart';
import 'package:quran_app/features/quran/presentation/navigation/quran_open_target.dart';
import 'package:quran_app/core/localization/app_localization_ext.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/core/assets/app_assets.dart';
import 'package:quran_app/features/settings/presentation/pages/settings_page.dart';

class SurahListPage extends StatefulWidget {
  final QuranOpenTarget? openTarget;
  const SurahListPage({super.key, this.openTarget});

  @override
  State<SurahListPage> createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage> {
  bool _applied = false;
  final Key _screenKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    // نفّذ القفزة للهدف بعد أول إطار لضمان تهيئة الكنترولرز داخليًا
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_applied) return;
      final t = widget.openTarget;
      if (t != null) {
        switch (t.type) {
          case QuranOpenTargetType.surah:
            QuranLibrary().jumpToSurah(t.number);
            break;
          case QuranOpenTargetType.juz:
            QuranLibrary().jumpToJoz(t.number);
            break;
          case QuranOpenTargetType.hizb:
            QuranLibrary().jumpToHizb(t.number);
            break;
        }
      }
      _applied = true;
      setState(() {}); // لإعادة بناء الشاشة بعد تطبيق القفزة
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.appTitle),
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(AppAssets.icSearch, width: 22, height: 22),
            tooltip: t.searchSurahHint,
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
            icon: SvgPicture.asset(AppAssets.icSettingsGreen, width: 22, height: 22),
            tooltip: t.settings,
          ),
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(AppAssets.icMenu, width: 22, height: 22),
          ),
        ],
      ),
      body: QuranLibraryScreen(
        key: _screenKey, // مفتاح فريد يمنع إعادة استخدام Controllers قديمة
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
        // لا نمرر AyahAudioStyle حتى لا تُنشّط منظومة الصوت الداخلية للحزمة
        topBarStyle: QuranTopBarStyle.defaults(isDark: isDark, context: context).copyWith(
          showAudioButton: false,
          showFontsButton: true,
          tabIndexLabel: t.indexTab,
          tabBookmarksLabel: t.bookmarksTab,
          tabSearchLabel: t.searchTab,
        ),
        indexTabStyle: IndexTabStyle.defaults(isDark: isDark, context: context).copyWith(
          tabSurahsLabel: t.tabSurahs,
          tabJozzLabel: t.tabJuz,
        ),
        ayahMenuStyle: AyahMenuStyle.defaults(isDark: isDark, context: context)
            .copyWith(copySuccessMessage: t.copied, showPlayAllButton: false),
        topBottomQuranStyle:
            TopBottomQuranStyle.defaults(isDark: isDark, context: context).copyWith(
          hizbName: t.hizbName,
          juzName: t.juzName,
          sajdaName: t.sajdaName,
        ),
      ),
      bottomNavigationBar: const SurahAutoSync(child: MiniAudioPlayer()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AudioDownloadsPage()),
          );
        },
        icon: SvgPicture.asset(AppAssets.icDownloadGreen, width: 20, height: 20),
        label: Text(t.manageAudio),
      ),
    );
  }
}
