import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:quran_library/quran_library.dart';
import 'package:quran_app/core/theme/design_tokens.dart';
import 'package:quran_app/features/quran/presentation/pages/quran_surah_page.dart';
import 'package:quran_app/features/quran/presentation/navigation/quran_open_target.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/core/localization/app_localization_ext.dart';
import 'package:quran_app/features/audio/presentation/cubit/audio_cubit.dart';
import 'package:quran_app/core/assets/app_assets.dart';
import 'package:quran_app/core/di/service_locator.dart';
import 'package:quran_app/core/quran/surah_name_resolver.dart';
import 'package:quran_app/core/theme/figma_typography.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/services/last_read_service.dart';

class LastReadCard extends StatelessWidget {
  final int surah;
  final int ayah;
  final int? page;
  final VoidCallback? onReturn;
  const LastReadCard({
    super.key,
    required this.surah,
    required this.ayah,
    this.page,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.tr;
    final names = resolveSurahNamePair(surah);
    final isGerman = Localizations.localeOf(
      context,
    ).languageCode.startsWith('de');
    return InkWell(
      onTap: () async {
        final latest = sl<LastReadService>().getLastRead();
        final targetSurah = latest.surah;
        final targetPage = latest.page;
        // keep audio context in sync with last read
        context.read<AudioCubit>().selectSurah(targetSurah);
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => QuranSurahPage(
              openTarget: (targetPage != null && targetPage >= 1)
                  ? QuranOpenTarget.page(targetPage)
                  : QuranOpenTarget.surah(targetSurah),
            ),
          ),
        );
        onReturn?.call();
      },
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Stack(
          children: [
            Positioned.fill(
              child: isGerman
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(math.pi),
                      child: Image.asset(
                        AppAssets.imgLastReadBg,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(AppAssets.imgLastReadBg, fit: BoxFit.cover),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        AppAssets.icBookmarkSaved,
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(
                          Colors.white70,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        t.lastRead,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          names.arabic,
                          style: GoogleFonts.notoNaskhArabic(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          names.latin,
                          style: FigmaTypography.latinBody15(
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '${_revelationText(context, surah)} • ${_verseCountText(context, surah)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _AyahChip(ayah: ayah),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _revelationText(BuildContext context, int surah) {
  final t = context.tr;
  final place = QuranLibrary()
      .getSurahInfo(surahNumber: surah - 1)
      .revelationType
      .toLowerCase();
  final isMadani = place.contains('mad');
  return isMadani ? t.madani : t.makki;
}

String _verseCountText(BuildContext context, int surah) {
  final count = QuranLibrary().getSurahInfo(surahNumber: surah - 1).ayahsNumber;
  return '$count ${context.tr.aya}';
}

class _AyahChip extends StatelessWidget {
  final int ayah;
  const _AyahChip({required this.ayah});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white70, width: 1.2),
        color: Colors.white.withValues(alpha: 0.06),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(AppAssets.icLastAya, width: 16, height: 16),
          const SizedBox(width: 6),
          Text(
            context.tr.ayahNumber(ayah),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(width: 8),
          // SvgPicture.asset(AppAssets.icPlayMini, width: 18, height: 18, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
        ],
      ),
    );
  }
}
