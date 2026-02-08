import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
  /// If true, shows the player only when actively playing/paused (not idle).
  /// If false, shows whenever a surah is selected.
  final bool hideWhenIdle;

  /// Debug tag to identify the location of this mini player instance.
  /// Example: 'MainShell' or 'SurahListPage'.
  final String debugTag;

  const MiniAudioPlayer({
    super.key,
    this.hideWhenIdle = false,
    this.debugTag = 'MiniAudioPlayer',
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    return BlocBuilder<AudioCubit, AudioState>(
      // ✅ Main rebuild scope: avoid rebuilding the whole widget tree on position updates.
      // Position/duration will be handled by dedicated selectors below.
      buildWhen: (prev, curr) {
        return prev.currentSurah != curr.currentSurah ||
            prev.url != curr.url ||
            prev.isPlaying != curr.isPlaying ||
            prev.phase != curr.phase ||
            prev.downloadProgress != curr.downloadProgress ||
            prev.errorMessage != curr.errorMessage;
      },
      builder: (context, state) {
        // Debug log (only on meaningful changes to avoid log flooding)
        if (kDebugMode) {
          _MiniPlayerDebugLog.maybeLog(
            tag: debugTag,
            phase: state.phase,
            surah: state.currentSurah,
            isPlaying: state.isPlaying,
            urlSet: state.url != null,
          );
        }
        // ✅ Different behavior based on hideWhenIdle flag
        if (hideWhenIdle) {
          // For MainShell: hide if no surah OR if idle (not playing)
          if ((state.currentSurah == null && state.url == null) ||
              state.phase == AudioPhase.idle) {
            return const SizedBox.shrink();
          }
        } else {
          // For SurahListPage: show whenever a surah is selected
          if (state.currentSurah == null && state.url == null) {
            return const SizedBox.shrink();
          }
        }

        // Pre-calculate info for both downloading and normal phases
        final sNum = state.currentSurah ?? 1;
        final info = QuranLibrary().getSurahInfo(surahNumber: sNum - 1);

        // Downloading phase
        if (state.phase == AudioPhase.downloading) {
          return Material(
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
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
                        Text(
                          t.downloadingSurah,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : null,
                              ),
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: state.downloadProgress.clamp(0.0, 1.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final scheme = Theme.of(context).colorScheme;
        final loaded = state.loadedSurah;
        final isQueuedNotLoaded = loaded != null && loaded != sNum;
        final verses = quran.getVerseCount(sNum);
        final place = quran.getPlaceOfRevelation(sNum).toLowerCase();
        final isMadani = place.contains('mad');

        // Downloading phase
        if (state.phase == AudioPhase.downloading) {
          return Material(
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
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
                        Text(
                          t.downloadingSurah,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: state.downloadProgress.clamp(0.0, 1.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Material(
          elevation: 4,
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: scheme.surface.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.95
                    : 0.9,
              ),
              image: DecorationImage(
                image: AssetImage(AppAssets.imgPlayerBgMini),
                fit: BoxFit.cover,
                opacity: Theme.of(context).brightness == Brightness.dark
                    ? 0.2
                    : 0.1,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border.all(
                color: scheme.outline.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? 0.3
                      : 0.1,
                ),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: Theme.of(context).brightness == Brightness.dark
                        ? 0.3
                        : 0.1,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header row (tap or swipe up to open full player)
                GestureDetector(
                  onTap: () => _navigateToFullPlayer(context),
                  onVerticalDragUpdate: (details) {
                    // Provide haptic feedback during upward drag
                    if (details.primaryDelta! < -15) {
                      HapticFeedback.lightImpact();
                    }
                  },
                  onVerticalDragEnd: (details) {
                    // Professional swipe detection with velocity thresholds
                    if (details.primaryVelocity! < -300) {
                      // Fast swipe - premium animation with strong haptic
                      HapticFeedback.mediumImpact();
                      _navigateToFullPlayerWithAnimation(context);
                    } else if (details.primaryVelocity! < -150) {
                      // Normal swipe - standard animation with light haptic
                      HapticFeedback.lightImpact();
                      _navigateToFullPlayer(context);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        // Title and info – ثابتة على اليمين دائماً
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
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
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              info.name,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${isMadani ? t.madani : t.makki} • $verses ${t.aya}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color:
                                                  Theme.of(
                                                        context,
                                                      ).brightness ==
                                                      Brightness.dark
                                                  ? Colors.white70
                                                  : null,
                                            ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // ✅ Buffering indicator (fixed size to avoid layout shift)
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: AnimatedOpacity(
                            opacity: state.isBuffering ? 1 : 0,
                            duration: const Duration(milliseconds: 150),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Play/Pause - ✅ Added Semantics
                        Semantics(
                          label: state.isPlaying ? t.pause : t.play,
                          button: true,
                          child: IconButton(
                            iconSize: 36,
                            color: scheme.primary,
                            icon: state.isPlaying
                                ? const Icon(Icons.pause_circle_filled)
                                : SvgPicture.asset(
                                    AppAssets.icPlay,
                                    width: 36,
                                    height: 36,
                                  ),
                            onPressed: () =>
                                context.read<AudioCubit>().toggle(),
                            tooltip: state.isPlaying ? t.pause : t.play,
                          ),
                        ),
                        // Close button - ✅ Added Semantics
                        Semantics(
                          label: t.stop,
                          button: true,
                          child: IconButton(
                            icon: SvgPicture.asset(
                              AppAssets.icExitGreyCross,
                              width: 14,
                              height: 14,
                            ),
                            onPressed: () => context.read<AudioCubit>().stop(),
                            tooltip: t.stop,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Times row (updates only when position/duration changes)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: _MiniTimesRow(),
                ),

                // Full-width progress bar at bottom (updates only when position/duration changes)
                _MiniProgressBar(
                  backgroundColor: scheme.surface.withValues(alpha: 0.4),
                  color: scheme.primary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToFullPlayer(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const FullPlayerPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutCubic)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _navigateToFullPlayerWithAnimation(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const FullPlayerPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutCubic)),
            ),
            child: FadeTransition(
              opacity: animation.drive(
                Tween(
                  begin: 0.3,
                  end: 1.0,
                ).chain(CurveTween(curve: Curves.easeOut)),
              ),
              child: ScaleTransition(
                scale: animation.drive(
                  Tween(
                    begin: 0.95,
                    end: 1.0,
                  ).chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: child,
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        barrierColor: Colors.black54,
        opaque: false,
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

class _MiniPlayerDebugLog {
  static final Map<String, String> _lastKeyByTag = <String, String>{};

  static void maybeLog({
    required String tag,
    required AudioPhase phase,
    required int? surah,
    required bool isPlaying,
    required bool urlSet,
  }) {
    // Log only when these key values change
    final key = 'phase=$phase surah=$surah isPlaying=$isPlaying urlSet=$urlSet';
    final last = _lastKeyByTag[tag];
    if (last == key) return;
    _lastKeyByTag[tag] = key;
    debugPrint('[MiniPlayer][$tag] $key');
  }
}

/// Updates only when [AudioState.position] or [AudioState.duration] changes.
class _MiniTimesRow extends StatelessWidget {
  const _MiniTimesRow();

  String _fmt(Duration d) {
    final hh = d.inHours;
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hh > 0 ? '$hh:$mm:$ss' : '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final pos = context.select((AudioCubit c) => c.state.position);
    final dur = context.select(
      (AudioCubit c) => c.state.duration ?? Duration.zero,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(_fmt(pos), style: Theme.of(context).textTheme.bodySmall),
        Text(_fmt(dur), style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

/// Updates only when [AudioState.position] or [AudioState.duration] changes.
class _MiniProgressBar extends StatelessWidget {
  final Color backgroundColor;
  final Color color;

  const _MiniProgressBar({required this.backgroundColor, required this.color});

  @override
  Widget build(BuildContext context) {
    final pos = context.select((AudioCubit c) => c.state.position);
    final dur = context.select(
      (AudioCubit c) => c.state.duration ?? Duration.zero,
    );

    final pct = (dur.inMilliseconds == 0)
        ? 0.0
        : (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0);

    return SizedBox(
      height: 3,
      child: LinearProgressIndicator(
        value: pct,
        backgroundColor: backgroundColor,
        valueColor: AlwaysStoppedAnimation<Color>(color),
        minHeight: 3,
      ),
    );
  }
}
