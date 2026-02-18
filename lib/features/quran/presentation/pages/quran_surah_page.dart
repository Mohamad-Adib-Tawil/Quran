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
import 'package:quran_app/services/study_tools_service.dart';
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
  AyahModel? _lastLongPressedAyah;
  _LastReadSnapshot? _pendingLastReadSnapshot;
  bool _isPersistingLastRead = false;
  final Map<int, Timer> _tempHighlightTimers = {};
  static const int _reviewLaterColorCode = 0xAAF36077;
  static const int _advancedReviewColorCode = 0xAAFFC107;
  static const int _advancedHifzColorCode = 0xAA4CAF50;
  static const int _advancedTadabburColorCode = 0xAA2196F3;
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
            _lastHandledPageNumber = t.number;
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
    _queueSaveLastReadSnapshot(
      forcedPageNumber: _lastHandledPageNumber,
    );
  }

  void _queueSaveLastReadSnapshot({
    int? forcedPageNumber,
    AyahModel? preferredAyah,
  }) {
    final pageNumber = forcedPageNumber ?? _resolveCurrentPageNumber();
    final pageAyah = _resolveAyahForPage(
      pageNumber,
      preferredAyah: preferredAyah,
    );
    final surahNumber = _resolveSurahForPage(pageNumber, pageAyah);
    final ayahNumber = pageAyah?.ayahNumber ?? 1;
    _pendingLastReadSnapshot = _LastReadSnapshot(
      surah: surahNumber,
      ayah: ayahNumber,
      page: pageNumber,
    );
    if (_isPersistingLastRead) return;
    _isPersistingLastRead = true;
    unawaited(_flushLastReadQueue());
  }

  Future<void> _flushLastReadQueue() async {
    while (true) {
      final snapshot = _pendingLastReadSnapshot;
      if (snapshot == null) break;
      _pendingLastReadSnapshot = null;
      await sl<LastReadService>().setLastRead(
        surah: snapshot.surah,
        ayah: snapshot.ayah,
        page: snapshot.page,
      );
    }
    _isPersistingLastRead = false;
    if (_pendingLastReadSnapshot != null && !_isPersistingLastRead) {
      _isPersistingLastRead = true;
      unawaited(_flushLastReadQueue());
    }
  }

  AyahModel? _resolveAyahForPage(
    int pageNumber, {
    AyahModel? preferredAyah,
  }) {
    final pressed = preferredAyah ?? _lastLongPressedAyah;
    if (pressed != null && pressed.page == pageNumber) {
      return pressed;
    }

    try {
      final pageAyahs = QuranLibrary().getPageAyahsByPageNumber(
        pageNumber: pageNumber,
      );
      if (pageAyahs.isEmpty) return null;
      return pageAyahs.firstWhere(
        (ayah) => ayah.ayahNumber >= 1,
        orElse: () => pageAyahs.first,
      );
    } catch (_) {
      return null;
    }
  }

  int _resolveSurahForPage(int pageNumber, AyahModel? pageAyah) {
    final ayahSurah = pageAyah?.surahNumber;
    if (ayahSurah != null && ayahSurah >= 1) {
      return ayahSurah;
    }

    try {
      return QuranLibrary()
          .getCurrentSurahDataByPageNumber(pageNumber: pageNumber)
          .surahNumber;
    } catch (_) {
      final open = widget.openTarget;
      if (open != null && open.type == QuranOpenTargetType.surah) {
        return open.number;
      }
      return 1;
    }
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

    final trackedPageNumber = _lastHandledPageNumber ?? ctrl.state.currentPageNumber.value;
    if (trackedPageNumber >= 1) {
      return trackedPageNumber.clamp(1, 604);
    }

    final open = widget.openTarget;
    if (open != null && open.type == QuranOpenTargetType.page) {
      return open.number.clamp(1, 604);
    }

    return 1;
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
    _queueSaveLastReadSnapshot(forcedPageNumber: pageNumber);
    unawaited(sl<StudyToolsService>().trackPageRead(pageNumber));

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
    final t = context.tr;
    _lastLongPressedAyah = ayah;
    unawaited(sl<StudyToolsService>().trackAyahRead(ayah.ayahUQNumber));
    final currentPage = _resolveCurrentPageNumber();
    if (ayah.page == currentPage) {
      _queueSaveLastReadSnapshot(
        forcedPageNumber: currentPage,
        preferredAyah: ayah,
      );
    }
    _shareOriginRect = _calcShareOrigin(details);
    final isTempHighlighted = _tempHighlightTimers.containsKey(ayah.ayahUQNumber);
    final isReviewLaterHighlighted = _hasReviewLaterHighlight(ayah.ayahUQNumber);
    final hasAyahNotes =
        sl<StudyToolsService>().getNotesForAyah(ayah.ayahUQNumber).isNotEmpty;
    final action = await showModalBottomSheet<_AyahAction>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        Widget actionTile({
          required IconData icon,
          required String title,
          required _AyahAction value,
          Color? color,
        }) {
          return ListTile(
            dense: true,
            leading: Icon(icon, color: color ?? scheme.primary),
            title: Text(title),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onTap: () => Navigator.of(ctx).pop(value),
          );
        }

        Widget section(String title, List<Widget> children) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.12)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      title,
                      style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                ...children,
              ],
            ),
          );
        }

        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: ListView(
              shrinkWrap: true,
            children: [
              section(
                t.ayahActionCopyWithTashkeel,
                [
                  actionTile(
                    icon: Icons.copy_rounded,
                    title: t.ayahActionCopyWithTashkeel,
                    value: _AyahAction.copyWithTashkeel,
                  ),
                  actionTile(
                    icon: Icons.copy_all_rounded,
                    title: t.ayahActionCopyWithoutTashkeel,
                    value: _AyahAction.copyWithoutTashkeel,
                  ),
                  actionTile(
                    icon: Icons.share_outlined,
                    title: t.ayahActionShareAsText,
                    value: _AyahAction.shareAsText,
                  ),
                  actionTile(
                    icon: Icons.image_outlined,
                    title: t.ayahActionShareAsImage,
                    value: _AyahAction.shareAsImage,
                  ),
                ],
              ),
              section(
                t.studyHubTagsTab,
                [
                  actionTile(
                    icon: Icons.bookmark_add_outlined,
                    title: t.ayahActionAdvancedTag,
                    value: _AyahAction.advancedTag,
                  ),
                  actionTile(
                    icon: Icons.note_add_outlined,
                    title: t.ayahActionAddNote,
                    value: _AyahAction.addNote,
                  ),
                  if (hasAyahNotes)
                    actionTile(
                      icon: Icons.notes_outlined,
                      title: t.ayahActionShowNotes,
                      value: _AyahAction.showNotes,
                    ),
                ],
              ),
              section(
                t.settings,
                [
                  actionTile(
                    icon: Icons.menu_book_outlined,
                    title: t.ayahActionShowTafsir,
                    value: _AyahAction.showTafsir,
                  ),
                  actionTile(
                    icon: Icons.play_circle_outline_rounded,
                    title: t.ayahActionPlaySurahInPlayer,
                    value: _AyahAction.playSurah,
                  ),
                ],
              ),
              section(
                t.ayahColoringSection,
                [
                  actionTile(
                    icon: isTempHighlighted
                        ? Icons.highlight_remove_rounded
                        : Icons.highlight_alt_rounded,
                    title: isTempHighlighted
                        ? t.ayahActionTempHighlightRemove
                        : t.ayahActionTempHighlightAdd,
                    value: _AyahAction.toggleTempHighlight,
                  ),
                  actionTile(
                    icon: isReviewLaterHighlighted
                        ? Icons.label_off_outlined
                        : Icons.label_important_outline_rounded,
                    title: isReviewLaterHighlighted
                        ? t.ayahActionReviewLaterRemove
                        : t.ayahActionReviewLaterAdd,
                    value: _AyahAction.toggleReviewLaterHighlight,
                  ),
                ],
              ),
            ],
            ),
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
      case _AyahAction.advancedTag:
        await _pickAdvancedTag(ayah);
        break;
      case _AyahAction.addNote:
        await _addAyahNote(ayah);
        break;
      case _AyahAction.showNotes:
        await _showAyahNotes(ayah);
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
        name: context.tr.unknownSurahName,
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
        SnackBar(content: Text(context.tr.ayahShareImageError)),
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
        SnackBar(content: Text(context.tr.ayahActionTempReviewRemoved)),
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
      SnackBar(content: Text(context.tr.ayahActionTempReviewAdded)),
    );
  }

  Future<void> _pickAdvancedTag(AyahModel ayah) async {
    final t = context.tr;
    final tag = await showModalBottomSheet<AyahTagType>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.rate_review_outlined, color: Colors.amber),
                title: Text(t.ayahActionTagReview),
                onTap: () => Navigator.of(ctx).pop(AyahTagType.review),
              ),
              ListTile(
                leading: const Icon(Icons.auto_stories_outlined, color: Colors.green),
                title: Text(t.ayahActionTagHifz),
                onTap: () => Navigator.of(ctx).pop(AyahTagType.hifz),
              ),
              ListTile(
                leading: const Icon(Icons.lightbulb_outline, color: Colors.blue),
                title: Text(t.ayahActionTagTadabbur),
                onTap: () => Navigator.of(ctx).pop(AyahTagType.tadabbur),
              ),
            ],
          ),
        );
      },
    );
    if (tag == null) return;
    final colorCode = _advancedColorCodeForTag(tag);
    final color = Color(colorCode);
    final surah = ayah.surahNumber ??
        QuranLibrary().getCurrentSurahDataByAyah(ayah: ayah).surahNumber;
    _removeAdvancedBookmarksForAyah(ayah.ayahUQNumber);
    BookmarksCtrl.instance.saveBookmark(
      surahName: _resolveSurahInfo(ayah).name,
      ayahId: ayah.ayahUQNumber,
      ayahNumber: ayah.ayahNumber,
      page: ayah.page,
      colorCode: colorCode,
    );
    await sl<StudyToolsService>().upsertTag(
      AyahTagEntry(
        ayahUq: ayah.ayahUQNumber,
        surah: surah,
        ayah: ayah.ayahNumber,
        page: ayah.page,
        type: tag,
        colorValue: color.toARGB32(),
        createdAt: DateTime.now(),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.ayahActionTagSaved)),
    );
  }

  int _advancedColorCodeForTag(AyahTagType tag) {
    switch (tag) {
      case AyahTagType.review:
        return _advancedReviewColorCode;
      case AyahTagType.hifz:
        return _advancedHifzColorCode;
      case AyahTagType.tadabbur:
        return _advancedTadabburColorCode;
    }
  }

  void _removeAdvancedBookmarksForAyah(int ayahUq) {
    final bookmarksCtrl = BookmarksCtrl.instance;
    final codes = <int>{
      _advancedReviewColorCode,
      _advancedHifzColorCode,
      _advancedTadabburColorCode,
    };
    for (final code in codes) {
      final existing = (bookmarksCtrl.bookmarks[code] ?? [])
          .where((b) => b.ayahId == ayahUq)
          .toList();
      for (final item in existing) {
        bookmarksCtrl.removeBookmark(item.id);
      }
    }
  }

  Future<void> _addAyahNote(AyahModel ayah) async {
    final t = context.tr;
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(t.ayahActionNoteDialogTitle),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: t.ayahActionNoteDialogHint,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(t.no),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
              child: Text(t.save),
            ),
          ],
        );
      },
    );
    final note = text?.trim() ?? '';
    if (note.isEmpty) return;
    final surah = ayah.surahNumber ??
        QuranLibrary().getCurrentSurahDataByAyah(ayah: ayah).surahNumber;
    await sl<StudyToolsService>().addNote(
      AyahNoteEntry(
        id: '${ayah.ayahUQNumber}_${DateTime.now().millisecondsSinceEpoch}',
        ayahUq: ayah.ayahUQNumber,
        surah: surah,
        ayah: ayah.ayahNumber,
        page: ayah.page,
        text: note,
        createdAt: DateTime.now(),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.ayahActionNoteSaved)),
    );
  }

  Future<void> _showAyahNotes(AyahModel ayah) async {
    final t = context.tr;
    final notes = sl<StudyToolsService>().getNotesForAyah(ayah.ayahUQNumber);
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: notes.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(t.ayahActionNoNotesForAyah),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: notes.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final n = notes[i];
                    return ListTile(
                      title: Text(n.text),
                      subtitle: Text(
                        '${n.createdAt.year}-${n.createdAt.month.toString().padLeft(2, '0')}-${n.createdAt.day.toString().padLeft(2, '0')}',
                      ),
                    );
                  },
                ),
        );
      },
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
  advancedTag,
  addNote,
  showNotes,
}

class _LastReadSnapshot {
  final int surah;
  final int ayah;
  final int page;

  const _LastReadSnapshot({
    required this.surah,
    required this.ayah,
    required this.page,
  });
}
