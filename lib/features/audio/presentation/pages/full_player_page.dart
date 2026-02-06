import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_library/quran_library.dart';
import 'package:quran_app/core/assets/app_assets.dart';
import 'package:quran_app/core/localization/app_localization_ext.dart';
import 'package:quran_app/features/audio/presentation/cubit/audio_cubit.dart';
import 'package:quran_app/features/audio/presentation/cubit/audio_state.dart';
import 'package:quran_app/features/audio/settings/audio_settings_cubit.dart';
import 'package:quran_app/features/audio/presentation/widgets/audio_settings_sheet.dart';

class FullPlayerPage extends StatelessWidget {
  const FullPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      // appBar: AppBar(
      //   title: const SizedBox.shrink(),
      //   centerTitle: false,
      //   backgroundColor: Colors.transparent,
      // ),
      body: SafeArea(
        child: BlocBuilder<AudioCubit, AudioState>(
          builder: (context, state) {
            final t = context.tr;
            
            // ✅ Error boundary - Show error state
            if (state.phase == AudioPhase.error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.errorMessage ?? t.errorOccurred,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.read<AudioCubit>().retry(),
                        icon: const Icon(Icons.refresh),
                        label: Text(t.retry),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(t.back),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            // ✅ Loading boundary - Show loading state
            if (state.phase == AudioPhase.downloading || state.phase == AudioPhase.preparing) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      state.phase == AudioPhase.downloading
                          ? t.downloadingSurah
                          : t.preparing,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (state.phase == AudioPhase.downloading) ...[
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: LinearProgressIndicator(
                          value: state.downloadProgress.clamp(0.0, 1.0),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }
            
            // ✅ Validate state before rendering
            if (state.currentSurah == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.music_note,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t.noSurahSelected,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(t.back),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            final sNum = state.currentSurah!;
            final info = QuranLibrary().getSurahInfo(surahNumber: sNum - 1);
            final verses = quran.getVerseCount(sNum);
            final place = quran.getPlaceOfRevelation(sNum).toLowerCase();
            final isMadani = place.contains('mad');
            final titleLatin = quran.getSurahName(sNum);

            final duration = state.duration ?? Duration.zero;
            final pos = state.position;
            final max = duration.inMilliseconds == 0
                ? 1.0
                : duration.inMilliseconds.toDouble();
            final val = duration.inMilliseconds == 0
                ? 0.0
                : pos.inMilliseconds
                      .clamp(0, duration.inMilliseconds)
                      .toDouble();

            final verseWord = context.tr.aya;
            return Column(
              children: [
                AppBar(
                  title: Text("${info.name} • $titleLatin"),
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                ),
                // Surah image taking half of screen height
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55,

                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            AppAssets.imgPlayerBgBig,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.black.withOpacity(0.12),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                titleLatin,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 28,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                info.name,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontSize: 24,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '$verses $verseWord • ${isMadani ? t.madani : t.makki}',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Spacer to push controls to bottom
                const Spacer(),

                // Progress slider
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: scheme.primary,
                          inactiveTrackColor: scheme.primary.withOpacity(0.2),
                          thumbColor: scheme.primary,
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                        ),
                        child: Slider(
                          value: val,
                          min: 0,
                          max: max,
                          onChanged: (v) => context.read<AudioCubit>().seek(
                            Duration(milliseconds: v.round()),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _fmt(pos),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              _fmt(duration),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Controls at bottom with padding
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 30,
                    top: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Repeat button on the left
                      _RepeatButton(),

                      // Previous button
                      IconButton(
                        icon: SvgPicture.asset(
                          AppAssets.icNext,
                          width: 32,
                          height: 32,
                          colorFilter: ColorFilter.mode(
                            scheme.onSurface,
                            BlendMode.srcIn,
                          ),
                        ),
                        onPressed: () =>
                            context.read<AudioCubit>().playNextFromCatalog(),
                        tooltip: t.next,
                      ),

                      // Play/Pause button
                      RawMaterialButton(
                        onPressed: () => context.read<AudioCubit>().toggle(),
                        fillColor: scheme.primary,
                        elevation: 2,
                        shape: const CircleBorder(),
                        constraints: const BoxConstraints.tightFor(
                          width: 72,
                          height: 72,
                        ),
                        child: Icon(
                          state.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),

                      // Next button
                      IconButton(
                        icon: SvgPicture.asset(
                          AppAssets.icPrev,
                          width: 32,
                          height: 32,
                          colorFilter: ColorFilter.mode(
                            scheme.onSurface,
                            BlendMode.srcIn,
                          ),
                        ),
                        onPressed: () =>
                            context.read<AudioCubit>().playPrevFromCatalog(),
                        tooltip: t.previous,
                      ),
                      // Settings button
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, size: 28),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            builder: (_) => const AudioSettingsSheet(),
                          );
                        },
                        tooltip: t.settings,
                      ),
                    ],
                  ),
                ),
                if (state.phase == AudioPhase.error)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.errorMessage ?? 'Error',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () => context.read<AudioCubit>().retry(),
                            child: Text(t.retry),
                          ),
                        ],
                      ),
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
        final mode = state.repeatMode;
        String label = mode == RepeatMode.one
            ? 'Repeat One'
            : mode == RepeatMode.off
            ? 'No Repeat'
            : 'Next Surah';
        final baseColor = mode == RepeatMode.off
            ? scheme.onSurface.withOpacity(0.4)
            : scheme.primary;
        return IconButton(
          tooltip: label,
          onPressed: () {
            final next = _cycle(mode);
            context.read<AudioSettingsCubit>().setRepeat(next);
          },
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              SvgPicture.asset(
                AppAssets.icRepeat,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(baseColor, BlendMode.srcIn),
              ),
              if (mode == RepeatMode.one)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: baseColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '1',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  RepeatMode _cycle(RepeatMode b) {
    switch (b) {
      case RepeatMode.one:
        return RepeatMode.off;
      case RepeatMode.off:
        return RepeatMode.next;
      case RepeatMode.next:
        return RepeatMode.one;
    }
  }
}
