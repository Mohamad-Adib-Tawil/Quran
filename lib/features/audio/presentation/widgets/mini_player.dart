import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_library/quran_library.dart';
import 'package:quran_app/core/localization/app_localization_ext.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/core/assets/app_assets.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app/features/audio/presentation/pages/full_player_page.dart';

import '../cubit/audio_cubit.dart';
import '../cubit/audio_state.dart';

class MiniAudioPlayer extends StatelessWidget {
  const MiniAudioPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    return BlocBuilder<AudioCubit, AudioState>(
      builder: (context, state) {
        // Hide if no session
        if ((state.currentSurah == null && state.url == null) || state.phase == AudioPhase.idle) {
          return const SizedBox.shrink();
        }

        // Downloading phase
        if (state.phase == AudioPhase.downloading) {
          return Material(
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(width: 36, height: 36, child: CircularProgressIndicator(strokeWidth: 3)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(t.downloadingSurah, style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(value: state.downloadProgress.clamp(0.0, 1.0)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final scheme = Theme.of(context).colorScheme;
        final duration = state.duration ?? Duration.zero;
        final pos = state.position;
        final pct = (duration.inMilliseconds == 0)
            ? 0.0
            : (pos.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
        final sNum = state.currentSurah ?? 1;
        final info = QuranLibrary().getSurahInfo(surahNumber: sNum - 1);
        final verses = quran.getVerseCount(sNum);
        final place = quran.getPlaceOfRevelation(sNum).toLowerCase();
        final isMadani = place.contains('mad');

        // Main content with background and progress bar
        return Material(
          elevation: 4,
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.9),
              image: const DecorationImage(
                image: AssetImage(AppAssets.imgPlayerBgMini),
                fit: BoxFit.cover,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => FullPlayerPage()),
                    );
                  },
                  child: 
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        // Close
                        IconButton(
                          icon: SvgPicture.asset(AppAssets.icExitGreyCross, width: 20, height: 20),
                          onPressed: () => context.read<AudioCubit>().stop(),
                          tooltip: t.stop,
                        ),
                        // Play/Pause
                        IconButton(
                          iconSize: 36,
                          color: scheme.primary,
                          icon: state.isPlaying
                              ? const Icon(Icons.pause_circle_filled)
                              : SvgPicture.asset(AppAssets.icPlay, width: 36, height: 36),
                          onPressed: () => context.read<AudioCubit>().toggle(),
                          tooltip: state.isPlaying ? t.pause : t.play,
                        ),
                        const SizedBox(width: 8),
                        // Title and info (right-aligned Arabic)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: scheme.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: SvgPicture.asset(
                                      AppAssets.icQuranGray,
                                      width: 20,
                                      height: 20,
                                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          info.name,
                                          style: Theme.of(context).textTheme.titleMedium,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.right,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${isMadani ? t.madani : t.makki} • $verses آية',
                                          style: Theme.of(context).textTheme.bodySmall,
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_fmt(duration), style: Theme.of(context).textTheme.bodySmall),
                        Text(_fmt(pos), style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  // Full-width progress bar at the very bottom
                  SizedBox(
                    height: 3,
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: scheme.surface.withValues(alpha: 0.4),
                      valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                      minHeight: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _fmt(Duration d) {
    final hh = d.inHours;
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hh > 0 ? '$hh:$mm:$ss' : '$mm:$ss';
  }
}
