import 'package:flutter/material.dart';
import 'package:quran_library/quran_library.dart';
import 'package:quran_app/features/audio/presentation/widgets/mini_player.dart';
import 'package:quran_app/features/quran/presentation/navigation/quran_open_target.dart';
import 'package:quran_app/core/localization/app_localization_ext.dart';

class QuranSurahPage extends StatefulWidget {
  final QuranOpenTarget? openTarget;
  const QuranSurahPage({super.key, this.openTarget});

  @override
  State<QuranSurahPage> createState() => _QuranSurahPageState();
}

class _QuranSurahPageState extends State<QuranSurahPage> {
  bool _applied = false;
  final Key _screenKey = UniqueKey();

  @override
  void initState() {
    super.initState();
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
      setState(() {});
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
      body: QuranLibraryScreen(
        key: _screenKey,
        parentContext: context,
        withPageView: true,
        useDefaultAppBar: true,
        isShowAudioSlider: false,
        showAyahBookmarkedIcon: true,
        isDark: isDark,
        backgroundColor: Theme.of(context).colorScheme.surface,
        textColor: textColor,
        ayahSelectedBackgroundColor: primary.withOpacity(0.12),
        ayahIconColor: primary,
        onAyahLongPress: (details, ayah) {},
        surahInfoStyle: SurahInfoStyle.defaults(
          isDark: isDark,
          context: context,
        ),
        basmalaStyle: BasmalaStyle(
          verticalPadding: 0.0,
          basmalaColor: textColor.withOpacity(0.85),
          basmalaFontSize: 28.0,
        ),
        topBarStyle: QuranTopBarStyle.defaults(isDark: isDark, context: context)
            .copyWith(
              showAudioButton: false,
              showFontsButton: true,
              showMenuButton: true,
              showBackButton: true,
              iconSize: 22,
              elevation: 20,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              tabIndexLabel: t.indexTab,
              tabBookmarksLabel: t.bookmarksTab,
              tabSearchLabel: t.searchTab,
              tabJozzLabel: t.tabJuz,
              tabSurahsLabel: t.tabSurahs,
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        child: MiniAudioPlayer(debugTag: 'SurahListPage'),
      ),
    );
  }
}
