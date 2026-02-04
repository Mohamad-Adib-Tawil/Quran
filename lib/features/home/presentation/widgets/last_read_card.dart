import 'package:flutter/material.dart';
import 'package:quran_library/quran_library.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app/core/theme/design_tokens.dart';
import 'package:quran_app/features/quran/presentation/pages/surah_list_page.dart';
import 'package:quran_app/features/quran/presentation/navigation/quran_open_target.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/core/localization/app_localization_ext.dart';
import 'package:quran_app/features/audio/presentation/cubit/audio_cubit.dart';
import 'package:quran_app/core/assets/app_assets.dart';

class LastReadCard extends StatelessWidget {
  final int surah;
  final int ayah;
  const LastReadCard({super.key, required this.surah, required this.ayah});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.tr;
    final info = QuranLibrary().getSurahInfo(surahNumber: surah - 1);
    return InkWell(
      onTap: () {
        // keep audio context in sync with last read
        context.read<AudioCubit>().selectSurah(surah);
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
          image: DecorationImage(
            image: AssetImage(AppAssets.imgLastReadBg),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SvgPicture.asset(AppAssets.icBookmark, width: 18, height: 18, colorFilter: const ColorFilter.mode(Colors.white70, BlendMode.srcIn)),
                const SizedBox(width: 8),
                Text(t.lastRead, style: theme.textTheme.labelLarge?.copyWith(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                info.name,
                style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Surah info (e.g., مدنية • 200 آية)
                Text(
                  '${_revelationText(context, surah)} • ${_verseCountText(context, surah)}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(width: 12),
                _AyahChip(ayah: ayah),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _revelationText(BuildContext context, int surah) {
  final t = context.tr;
  final place = quran.getPlaceOfRevelation(surah).toLowerCase();
  final isMadani = place.contains('mad');
  return isMadani ? t.madani : t.makki;
}

String _verseCountText(BuildContext context, int surah) {
  final count = quran.getVerseCount(surah);
  return '$count آية';
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
          Text('الآية $ayah', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
          const SizedBox(width: 8),
          SvgPicture.asset(AppAssets.icPlayMini, width: 18, height: 18, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
        ],
      ),
    );
  }
}
