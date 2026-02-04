import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_library/quran_library.dart';
import 'package:quran_app/core/assets/app_assets.dart';
import 'package:quran_app/core/localization/app_localization_ext.dart';
import 'package:quran_app/features/audio/presentation/cubit/audio_cubit.dart';
import 'package:quran_app/features/audio/presentation/cubit/audio_state.dart';
import 'package:quran_app/features/settings/presentation/pages/settings_page.dart';

class FullPlayerPage extends StatelessWidget {
  const FullPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const SizedBox.shrink(),
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: BlocBuilder<AudioCubit, AudioState>(
          builder: (context, state) {
            final t = context.tr;
            final sNum = state.currentSurah ?? 1;
            final info = QuranLibrary().getSurahInfo(surahNumber: sNum - 1);
            final verses = quran.getVerseCount(sNum);
            final place = quran.getPlaceOfRevelation(sNum).toLowerCase();
            final isMadani = place.contains('mad');
            final titleLatin = quran.getSurahName(sNum);

            final duration = state.duration ?? Duration.zero;
            final pos = state.position;
            final max = duration.inMilliseconds == 0 ? 1.0 : duration.inMilliseconds.toDouble();
            final val = duration.inMilliseconds == 0 ? 0.0 : pos.inMilliseconds.clamp(0, duration.inMilliseconds).toDouble();

            final lang = Localizations.localeOf(context).languageCode;
            final verseWord = lang == 'ar' ? 'آية' : 'Verse';
            return Column(
              children: [
                // Green header with background
                Container(
                  height: 320,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppAssets.imgPlayerBgBig),
                      fit: BoxFit.cover,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        titleLatin,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        info.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$verses $verseWord • ${isMadani ? t.madani : t.makki}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Progress slider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      Slider(
                        value: val,
                        min: 0,
                        max: max,
                        onChanged: (v) => context.read<AudioCubit>().seek(Duration(milliseconds: v.round())),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_fmt(pos), style: Theme.of(context).textTheme.bodySmall),
                          Text(_fmt(duration), style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),

                // Controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
                        },
                        tooltip: t.settings,
                      ),
                      IconButton(
                        icon: SvgPicture.asset(AppAssets.icPrev, width: 28, height: 28, colorFilter: ColorFilter.mode(scheme.onSurface, BlendMode.srcIn)),
                        onPressed: () => context.read<AudioCubit>().playPrevFromCatalog(),
                        tooltip: t.previous,
                      ),
                      IconButton(
                        iconSize: 56,
                        icon: state.isPlaying
                            ? const Icon(Icons.pause_circle_filled, size: 56)
                            : SvgPicture.asset(AppAssets.icPlay, width: 56, height: 56),
                        color: scheme.primary,
                        onPressed: () => context.read<AudioCubit>().toggle(),
                        tooltip: state.isPlaying ? t.pause : t.play,
                      ),
                      IconButton(
                        icon: SvgPicture.asset(AppAssets.icNext, width: 28, height: 28, colorFilter: ColorFilter.mode(scheme.onSurface, BlendMode.srcIn)),
                        onPressed: () => context.read<AudioCubit>().playNextFromCatalog(),
                        tooltip: t.next,
                      ),
                      _RepeatButton(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final hh = d.inHours;
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hh > 0 ? '$hh:$mm:$ss' : '$mm:$ss';
  }
}

class _RepeatButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioCubit, AudioState>(
      builder: (context, state) {
        final scheme = Theme.of(context).colorScheme;
        final behavior = state.onComplete;
        String label;
        switch (behavior) {
          case OnCompleteBehavior.repeatOne:
            label = 'Repeat';
            break;
          case OnCompleteBehavior.stop:
            label = 'No repeat';
            break;
          case OnCompleteBehavior.next:
            label = 'Next Surah';
            break;
        }
        return IconButton(
          icon: SvgPicture.asset(AppAssets.icRepeat, width: 24, height: 24, colorFilter: ColorFilter.mode(scheme.primary, BlendMode.srcIn)),
          tooltip: label,
          onPressed: () {
            final next = _cycle(behavior);
            context.read<AudioCubit>().setOnCompleteBehavior(next);
          },
        );
      },
    );
  }

  OnCompleteBehavior _cycle(OnCompleteBehavior b) {
    switch (b) {
      case OnCompleteBehavior.repeatOne:
        return OnCompleteBehavior.stop;
      case OnCompleteBehavior.stop:
        return OnCompleteBehavior.next;
      case OnCompleteBehavior.next:
        return OnCompleteBehavior.repeatOne;
    }
  }
}
