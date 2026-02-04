import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_library/quran_library.dart';
import 'package:quran_app/core/localization/app_localization_ext.dart';

import '../cubit/audio_cubit.dart';
import '../cubit/audio_state.dart';

class MiniAudioPlayer extends StatelessWidget {
  const MiniAudioPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    return Material(
      elevation: 6,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: BlocBuilder<AudioCubit, AudioState>(
          builder: (context, state) {
            // Render special phases first
            if (state.phase == AudioPhase.downloading) {
              return Row(
                children: [
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
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
              );
            }

            if (state.phase == AudioPhase.error) {
              return Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.errorMessage ?? t.unexpectedError,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => context.read<AudioCubit>().retry(),
                    child: Text(t.retry),
                  ),
                ],
              );
            }

            final durationMs = (state.duration ?? Duration.zero).inMilliseconds;
            final positionMs = state.position.inMilliseconds.clamp(0, durationMs);
            final canSeek = durationMs > 0;
            return Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: () => context.read<AudioCubit>().playPrevFromCatalog(),
                  tooltip: t.previous,
                ),
                IconButton(
                  icon: Icon(state.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
                  color: Theme.of(context).colorScheme.primary,
                  iconSize: 36,
                  onPressed: () => context.read<AudioCubit>().toggle(),
                  tooltip: state.isPlaying ? t.pause : t.play,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.currentSurah != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            QuranLibrary()
                                .getSurahInfo(surahNumber: (state.currentSurah! - 1))
                                .name,
                            style: Theme.of(context).textTheme.labelMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      Slider(
                        value: durationMs == 0 ? 0 : positionMs.toDouble(),
                        min: 0,
                        max: durationMs == 0 ? 1 : durationMs.toDouble(),
                        onChanged: canSeek
                            ? (v) => context.read<AudioCubit>().seek(Duration(milliseconds: v.round()))
                            : null,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_fmt(state.position), style: Theme.of(context).textTheme.bodySmall),
                          Text(_fmt(state.duration ?? Duration.zero), style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.stop_circle_outlined),
                  onPressed: () => context.read<AudioCubit>().stop(),
                  tooltip: t.stop,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: () => context.read<AudioCubit>().playNextFromCatalog(),
                  tooltip: t.next,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}
