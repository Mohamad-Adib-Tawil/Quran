import 'package:flutter/material.dart';
import 'package:quran_library/quran_library.dart';
import 'package:quran_app/core/theme/design_tokens.dart';
import 'package:quran_app/core/theme/app_colors.dart';
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
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          boxShadow: AppShadows.soft(AppColors.primary),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(AppAssets.imgLastReadBg, fit: BoxFit.cover),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.lastRead, style: theme.textTheme.labelLarge?.copyWith(color: Colors.white70)),
                      const SizedBox(height: 6),
                      Text(info.name, style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(t.ayahNumber('$ayah'), style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
                SvgPicture.asset(
                  AppAssets.icPlayMini,
                  width: 36,
                  height: 36,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
