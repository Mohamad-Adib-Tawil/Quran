import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran_library/quran_library.dart';
import 'package:quran_app/features/audio/presentation/widgets/mini_player.dart';
import 'package:quran_app/features/audio/presentation/cubit/audio_cubit.dart';
import 'package:quran_app/features/audio/presentation/cubit/audio_state.dart';
import 'package:quran_app/features/quran/presentation/navigation/quran_open_target.dart';
import 'package:quran_app/core/localization/app_localization_ext.dart';
import 'package:quran_app/core/di/service_locator.dart';
import 'package:quran_app/services/last_read_service.dart';
import 'package:share_plus/share_plus.dart';

class QuranSurahPage extends StatefulWidget {
  final QuranOpenTarget? openTarget;
  const QuranSurahPage({super.key, this.openTarget});

  @override
  State<QuranSurahPage> createState() => _QuranSurahPageState();
}

class _QuranSurahPageState extends State<QuranSurahPage> {
  bool _applied = false;
  final Key _screenKey = UniqueKey();
  int? _lastHandledPageNumber;
  final Map<int, Timer> _tempHighlightTimers = {};
  static const int _reviewLaterColorCode = 0xAAF36077;
  ui.Rect? _shareOriginRect;

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
          case QuranOpenTargetType.page:
            QuranLibrary().jumpToPage(t.number);
            break;
        }
      }
      _applied = true;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _persistLastReadOnExit();
    for (final timer in _tempHighlightTimers.values) {
      timer.cancel();
    }
    final quranCtrl = QuranCtrl.instance;
    for (final ayahUq in _tempHighlightTimers.keys) {
      quranCtrl.removeExternalHighlight(ayahUq);
    }
    super.dispose();
  }

  void _persistLastReadOnExit() {
    final pageNumber = _resolveCurrentPageNumber();
    int surahNumber;
    try {
      surahNumber = QuranLibrary()
          .getCurrentSurahDataByPageNumber(pageNumber: pageNumber)
          .surahNumber;
    } catch (_) {
      final open = widget.openTarget;
      surahNumber = (open != null && open.type == QuranOpenTargetType.surah)
          ? open.number
          : 1;
    }

    sl<LastReadService>().setLastRead(
      surah: surahNumber,
      ayah: 1,
      page: pageNumber,
    );
  }

  int _resolveCurrentPageNumber() {
    final ctrl = QuranCtrl.instance;
    final pagesController = ctrl.quranPagesController;

    if (pagesController.hasClients) {
      final controllerPage = pagesController.page;
      if (controllerPage != null && controllerPage.isFinite) {
        final pageNumber = controllerPage.round() + 1;
        return pageNumber.clamp(1, 604);
      }
    }

    final open = widget.openTarget;
    if (open != null && open.type == QuranOpenTargetType.page) {
      return open.number.clamp(1, 604);
    }

    final pageNumber = _lastHandledPageNumber ?? ctrl.state.currentPageNumber.value;
    return pageNumber.clamp(1, 604);
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
        ayahSelectedBackgroundColor: primary.withValues(alpha: 0.12),
        ayahIconColor: primary,
        onPageChanged: _handlePageChanged,
        onAyahLongPress: _onAyahLongPress,
        surahInfoStyle: SurahInfoStyle.defaults(
          isDark: isDark,
          context: context,
        ),
        basmalaStyle: BasmalaStyle(
          verticalPadding: 0.0,
          basmalaColor: textColor.withValues(alpha: 0.85),
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
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              sajdaNameColor: primary,
            ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        child: MiniAudioPlayer(
          debugTag: 'QuranSurahPage',
          hideWhenIdle: true,
        ),
      ),
    );
  }

  bool _hasMiniPlayerContext(AudioState state) {
    return state.currentSurah != null ||
        state.url != null ||
        state.pendingSurah != null;
  }

  void _handlePageChanged(int pageIndex) {
    final pageNumber = pageIndex + 1;
    if (_lastHandledPageNumber == pageNumber) return;
    _lastHandledPageNumber = pageNumber;

    final audioCubit = context.read<AudioCubit>();
    final audioState = audioCubit.state;
    if (!_hasMiniPlayerContext(audioState)) return;

    final currentSurah = QuranLibrary()
        .getCurrentSurahDataByPageNumber(pageNumber: pageNumber)
        .surahNumber;

    if (audioState.currentSurah == currentSurah) return;
    audioCubit.playSurah(currentSurah);
  }

  Future<void> _onAyahLongPress(
    LongPressStartDetails details,
    AyahModel ayah,
  ) async {
    _shareOriginRect = _calcShareOrigin(details);
    final isTempHighlighted = _tempHighlightTimers.containsKey(ayah.ayahUQNumber);
    final isReviewLaterHighlighted = _hasReviewLaterHighlight(ayah.ayahUQNumber);
    final action = await showModalBottomSheet<_AyahAction>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.copy_rounded),
                title: const Text('نسخ مع التشكيل'),
                dense: true,
                onTap: () => Navigator.of(ctx).pop(_AyahAction.copyWithTashkeel),
              ),
              ListTile(
                leading: const Icon(Icons.copy_all_rounded),
                title: const Text('نسخ بدون تشكيل'),
                dense: true,
                onTap: () =>
                    Navigator.of(ctx).pop(_AyahAction.copyWithoutTashkeel),
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('مشاركة كنص'),
                dense: true,
                onTap: () => Navigator.of(ctx).pop(_AyahAction.shareAsText),
              ),
              ListTile(
                leading: const Icon(Icons.image_outlined),
                title: const Text('مشاركة الآية كصورة'),
                dense: true,
                onTap: () => Navigator.of(ctx).pop(_AyahAction.shareAsImage),
              ),
              ListTile(
                leading: Icon(
                  isTempHighlighted
                      ? Icons.highlight_remove_rounded
                      : Icons.highlight_alt_rounded,
                ),
                title: Text(
                  isTempHighlighted
                      ? 'إزالة التمييز المؤقت'
                      : 'تمييز لوني مؤقت (20 ثانية)',
                ),
                dense: true,
                onTap: () =>
                    Navigator.of(ctx).pop(_AyahAction.toggleTempHighlight),
              ),
              ListTile(
                leading: Icon(
                  isReviewLaterHighlighted
                      ? Icons.label_off_outlined
                      : Icons.label_important_outline_rounded,
                ),
                title: Text(
                  isReviewLaterHighlighted
                      ? 'إلغاء تمييز المراجعة لاحقًا'
                      : 'تمييز للمراجعة لاحقًا',
                ),
                dense: true,
                onTap: () =>
                    Navigator.of(ctx).pop(_AyahAction.toggleReviewLaterHighlight),
              ),
              ListTile(
                leading: Icon(Icons.play_circle_outline_rounded),
                title: Text('تشغيل السورة في المشغل'),
                dense: true,
                onTap: () => Navigator.of(ctx).pop(_AyahAction.playSurah),
              ),
              ListTile(
                leading: Icon(Icons.menu_book_outlined),
                title: Text('إظهار تفسير الآية'),
                dense: true,
                onTap: () => Navigator.of(ctx).pop(_AyahAction.showTafsir),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) return;

    switch (action) {
      case _AyahAction.copyWithTashkeel:
        await Clipboard.setData(ClipboardData(text: _ayahPlainText(ayah)));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr.copied)),
        );
        break;
      case _AyahAction.copyWithoutTashkeel:
        await Clipboard.setData(
          ClipboardData(text: _removeArabicDiacritics(_ayahPlainText(ayah))),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr.copied)),
        );
        break;
      case _AyahAction.shareAsText:
        await _shareAyahAsText(ayah);
        break;
      case _AyahAction.shareAsImage:
        await _shareAyahAsImage(ayah);
        break;
      case _AyahAction.toggleTempHighlight:
        _toggleTemporaryHighlight(ayah.ayahUQNumber);
        break;
      case _AyahAction.toggleReviewLaterHighlight:
        _toggleReviewLaterHighlight(ayah);
        break;
      case _AyahAction.playSurah:
        final surahNumber = ayah.surahNumber ??
            QuranLibrary().getCurrentSurahDataByAyah(ayah: ayah).surahNumber;
        context.read<AudioCubit>().playSurah(surahNumber);
        break;
      case _AyahAction.showTafsir:
        await QuranLibrary().showTafsir(
          context: context,
          ayahNum: ayah.ayahNumber,
          pageIndex: ayah.page - 1,
          ayahTextN: ayah.text,
          ayahUQNum: ayah.ayahUQNumber,
          ayahNumber: ayah.ayahNumber,
          isDark: Theme.of(context).brightness == Brightness.dark,
        );
        break;
    }
  }

  String _ayahPlainText(AyahModel ayah) => ayah.text.trim();

  String _removeArabicDiacritics(String text) {
    final arabicDiacritics = RegExp(
      r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]',
    );
    return text.replaceAll(arabicDiacritics, '');
  }

  String _ayahReference(AyahModel ayah) {
    final info = _resolveSurahInfo(ayah);
    return 'سورة ${info.name} - الآية ${ayah.ayahNumber}';
  }

  SurahNamesModel _resolveSurahInfo(AyahModel ayah) {
    final surahNumber = _resolveSurahNumber(ayah);
    try {
      return QuranLibrary().getSurahInfo(surahNumber: surahNumber - 1);
    } catch (_) {
      final fallback = QuranCtrl.instance.getSurahsByPageNumber(ayah.page);
      if (fallback.isNotEmpty) {
        final surah = fallback.first;
        return SurahNamesModel(
          number: surah.surahNumber,
          name: surah.arabicName,
          englishName: surah.englishName,
          englishNameTranslation: '',
          revelationType: surah.revelationType ?? '',
          ayahsNumber: surah.ayahs.length,
          surahInfo: '',
          surahInfoFromBook: '',
          surahNames: '',
          surahNamesFromBook: '',
        );
      }
      return SurahNamesModel(
        number: surahNumber,
        name: 'سورة غير معروفة',
        englishName: '',
        englishNameTranslation: '',
        revelationType: '',
        ayahsNumber: 0,
        surahInfo: '',
        surahInfoFromBook: '',
        surahNames: '',
        surahNamesFromBook: '',
      );
    }
  }

  int _resolveSurahNumber(AyahModel ayah) {
    if (ayah.surahNumber != null && ayah.surahNumber! >= 1) {
      return ayah.surahNumber!;
    }
    try {
      return QuranCtrl.instance.getSurahNumberFromPage(ayah.page);
    } catch (_) {
      return 1;
    }
  }

  Future<void> _shareAyahAsText(AyahModel ayah) async {
    final text = '﴿${_ayahPlainText(ayah)}﴾\n\n${_ayahReference(ayah)}';
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        sharePositionOrigin: _shareOriginRect ??
            const ui.Rect.fromLTWH(0, 0, 1, 1),
      ),
    );
  }

  Future<void> _shareAyahAsImage(AyahModel ayah) async {
    try {
      final path = await _buildAyahImageFile(ayah);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(path)],
          text: _ayahReference(ayah),
          sharePositionOrigin: _shareOriginRect ??
              const ui.Rect.fromLTWH(0, 0, 1, 1),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر إنشاء صورة الآية للمشاركة')),
      );
    }
  }

  ui.Rect _calcShareOrigin(LongPressStartDetails details) {
    // ignore: unnecessary_nullable_for_final_variable_declarations
    final OverlayState? overlayState = Overlay.of(context);
    if (overlayState == null) {
      return const ui.Rect.fromLTWH(0, 0, 1, 1);
    }
    final overlayRenderBox =
        overlayState.context.findRenderObject() as RenderBox?;
    if (overlayRenderBox == null) {
      return const ui.Rect.fromLTWH(0, 0, 1, 1);
    }
    final local = overlayRenderBox.globalToLocal(details.globalPosition);
    final dx = local.dx.clamp(0.0, overlayRenderBox.size.width - 1.0);
    final dy = local.dy.clamp(0.0, overlayRenderBox.size.height - 1.0);
    return ui.Rect.fromLTWH(dx, dy, 1, 1);
  }

  Future<String> _buildAyahImageFile(AyahModel ayah) async {
    const width = 1080.0;
    const height = 1400.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        const Offset(width, height),
        [
          const Color(0xFFF9F6EE),
          const Color(0xFFECE4D6),
        ],
      );
    canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), bgPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFFD4C7A2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(50, 50, width - 100, height - 100),
        const Radius.circular(32),
      ),
      borderPaint,
    );

    final versePainter = TextPainter(
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
      maxLines: 12,
      ellipsis: '...',
      text: TextSpan(
        text: '﴿${_ayahPlainText(ayah)}﴾',
        style: const TextStyle(
          fontSize: 54,
          height: 1.9,
          color: Color(0xFF1E1E1E),
          fontWeight: FontWeight.w600,
        ),
      ),
    )..layout(maxWidth: width - 180);

    versePainter.paint(
      canvas,
      Offset((width - versePainter.width) / 2, 210),
    );

    final refPainter = TextPainter(
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
      text: TextSpan(
        text: _ayahReference(ayah),
        style: const TextStyle(
          fontSize: 36,
          color: Color(0xFF6D5F44),
          fontWeight: FontWeight.w500,
        ),
      ),
    )..layout(maxWidth: width - 180);
    refPainter.paint(
      canvas,
      Offset((width - refPainter.width) / 2, height - 220),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final pngBytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (pngBytes == null) {
      throw StateError('Failed to encode ayah image');
    }

    final tempDir = await getTemporaryDirectory();
    final file = File(
      '${tempDir.path}/ayah_${ayah.ayahUQNumber}_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(pngBytes.buffer.asUint8List(), flush: true);
    return file.path;
  }

  void _toggleTemporaryHighlight(int ayahUq) {
    final quranCtrl = QuranCtrl.instance;
    final active = _tempHighlightTimers.remove(ayahUq);
    if (active != null) {
      active.cancel();
      quranCtrl.removeExternalHighlight(ayahUq);
      return;
    }

    quranCtrl.addExternalHighlight(ayahUq);
    _tempHighlightTimers[ayahUq] = Timer(const Duration(seconds: 20), () {
      quranCtrl.removeExternalHighlight(ayahUq);
      _tempHighlightTimers.remove(ayahUq);
    });
  }

  bool _hasReviewLaterHighlight(int ayahUq) {
    final list = BookmarksCtrl.instance.bookmarks[_reviewLaterColorCode] ?? [];
    return list.any((b) => b.ayahId == ayahUq);
  }

  void _toggleReviewLaterHighlight(AyahModel ayah) {
    final bookmarksCtrl = BookmarksCtrl.instance;
    final existing = (bookmarksCtrl.bookmarks[_reviewLaterColorCode] ?? [])
        .where((b) => b.ayahId == ayah.ayahUQNumber)
        .toList();

    if (existing.isNotEmpty) {
      for (final item in existing) {
        bookmarksCtrl.removeBookmark(item.id);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إلغاء تمييز الآية للمراجعة لاحقًا')),
      );
      return;
    }

    final surah = _resolveSurahInfo(ayah);
    bookmarksCtrl.saveBookmark(
      surahName: surah.name,
      ayahId: ayah.ayahUQNumber,
      ayahNumber: ayah.ayahNumber,
      page: ayah.page,
      colorCode: _reviewLaterColorCode,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تمييز الآية للمراجعة لاحقًا')),
    );
  }
}

enum _AyahAction {
  copyWithTashkeel,
  copyWithoutTashkeel,
  shareAsText,
  shareAsImage,
  toggleTempHighlight,
  toggleReviewLaterHighlight,
  playSurah,
  showTafsir,
}
