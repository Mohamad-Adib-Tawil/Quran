import 'package:flutter/material.dart';
import 'package:quran_library/quran_library.dart';
import 'package:quran_app/features/audio/presentation/widgets/mini_player.dart';
import 'package:quran_app/features/audio/presentation/widgets/surah_auto_sync.dart';
import 'package:quran_app/features/quran/presentation/navigation/quran_open_target.dart';
import 'package:quran_app/core/localization/app_localization_ext.dart';

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
    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(t.appTitle),
      // ),
      body: QuranLibraryScreen(
        key: _screenKey, // مفتاح فريد يمنع إعادة استخدام Controllers قديمة
        parentContext: context,
        withPageView: true,
        useDefaultAppBar: true,
        isShowAudioSlider: false,
        showAyahBookmarkedIcon: true,
        isDark: isDark,
        backgroundColor: Theme.of(context).colorScheme.surface,
        textColor: textColor,
        ayahSelectedBackgroundColor: primary.withValues(alpha: 0.12),
        ayahIconColor: primary,

        onAyahLongPress: (details, ayah) {},
        surahInfoStyle: SurahInfoStyle.defaults(
          isDark: isDark,
          context: context,
        ),
        basmalaStyle: BasmalaStyle(
          verticalPadding: 0.0,
          basmalaColor: textColor.withValues(alpha: 0.85),
          basmalaFontSize: 28.0,
        ),
        // لا نمرر AyahAudioStyle حتى لا تُنشّط منظومة الصوت الداخلية للحزمة
        topBarStyle: QuranTopBarStyle.defaults(isDark: isDark, context: context)
            .copyWith(
              showAudioButton: false,
              showFontsButton: true,
              showMenuButton: true,
              showBackButton: true,
              // backgroundColor: Theme.of(context).colorScheme.surface,
              // textColor: Theme.of(context).colorScheme.onSurface,
              // accentColor: primary,
              // iconColor: Theme.of(context).colorScheme.onSurface,
              iconSize: 22,
              elevation: 20,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              tabIndexLabel: t.indexTab,
              tabBookmarksLabel: t.bookmarksTab,
              tabSearchLabel: t.searchTab,
              tabJozzLabel: t.tabJuz,
              tabSurahsLabel: t.tabSurahs,

              backgroundColor: Colors.amber,
            ),
        indexTabStyle: IndexTabStyle.defaults(isDark: isDark, context: context)
            .copyWith(
              tabSurahsLabel: t.tabSurahs,
              tabJozzLabel: t.tabJuz,
              textColor: Theme.of(context).colorScheme.onSurface,
              accentColor: primary,
              tabBarHeight: kTextTabBarHeight + 14,
              tabBarRadius: 12,
              indicatorRadius: 12,
              indicatorPadding: EdgeInsets.zero,
              labelColor: Colors.white,
              unselectedLabelColor: primary,
              tabBarBgAlpha: 0.08,
              listItemRadius: 12,
              surahRowAltBgAlpha: 0.04,
              jozzAltBgAlpha: 0.04,
              hizbItemAltBgAlpha: 0.04,
            ),
        ayahMenuStyle: AyahMenuStyle.defaults(isDark: isDark, context: context)
            .copyWith(
              copySuccessMessage: t.copied,
              showPlayAllButton: false,
              showPlayButton: false,
              dividerColor: Theme.of(context).dividerColor,
              bookmarkIconData: Icons.bookmark_border,
              copyIconData: Icons.copy,
              tafsirIconData: Icons.menu_book_outlined,
            ),
        topBottomQuranStyle:
            TopBottomQuranStyle.defaults(
              isDark: isDark,
              context: context,
            ).copyWith(
              hizbName: t.hizbName,
              juzName: t.juzName,
              sajdaName: t.sajdaName,
              surahNameColor: Theme.of(context).colorScheme.onSurface,
              juzTextColor: primary,
              hizbTextColor: primary,
              pageNumberColor: Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.6),
              sajdaNameColor: primary,
            ),
      ),
      bottomNavigationBar: SurahAutoSync(
        // ✅ Prevent transient resets (often to Al-Fatiha) from overriding
        // the surah we navigated to.
        initialSurah: widget.openTarget?.type == QuranOpenTargetType.surah
            ? widget.openTarget?.number
            : null,
        child: const Padding(
          padding: EdgeInsets.only(bottom: 40, left: 20, right: 20),
          child: MiniAudioPlayer(debugTag: 'SurahListPage'),
        ),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     Navigator.of(context).push(
      //       MaterialPageRoute(builder: (_) => const AudioDownloadsPage()),
      //     );
      //   },
      //   icon: SvgPicture.asset(AppAssets.icDownloadGreen, width: 20, height: 20),
      //   label: Text(t.manageAudio),
      // ),
    );
  }
}
