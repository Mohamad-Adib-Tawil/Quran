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

class MiniAudioPlayer extends StatefulWidget {
  final bool hideWhenIdle;
  final String debugTag;
  final VoidCallback? onOpenFullPlayer;

  const MiniAudioPlayer({
    super.key,
    this.hideWhenIdle = false,
    this.debugTag = 'MiniAudioPlayer',
    this.onOpenFullPlayer,
  });

  @override
  State<MiniAudioPlayer> createState() => _MiniAudioPlayerState();
}

class _MiniAudioPlayerState extends State<MiniAudioPlayer> {
  int? _lastShownPendingSurah;
  bool _dialogShown = false;
  bool _isDialogProcessing = false;
  bool _dialogOpenedInThisBuild = false;
  static bool _globalDialogOpen = false; // Prevent multiple dialogs globally
  bool _isOpeningFullPlayer = false;

  void _openFullPlayer(BuildContext context) {
    if (widget.onOpenFullPlayer != null) {
      widget.onOpenFullPlayer!();
    } else {
      _openFullPlayerBottomSheet(context);
    }
  }

  Future<void> _openFullPlayerBottomSheet(BuildContext context) async {
    if (_isOpeningFullPlayer || !mounted) return;
    _isOpeningFullPlayer = true;
    HapticFeedback.mediumImpact();
    final height = MediaQuery.of(context).size.height * 0.94;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      isDismissible: true,
      showDragHandle: false,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 420),
        reverseDuration: Duration(milliseconds: 320),
      ),
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (_) {
        return Container(
          height: height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: const FullPlayerPage(asBottomSheet: true),
        );
      },
    );

    if (mounted) {
      _isOpeningFullPlayer = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    return BlocBuilder<AudioCubit, AudioState>(
      buildWhen: (prev, curr) {
        return prev.currentSurah != curr.currentSurah ||
            prev.url != curr.url ||
            prev.isPlaying != curr.isPlaying ||
            prev.phase != curr.phase ||
            prev.downloadProgress != curr.downloadProgress ||
            prev.errorMessage != curr.errorMessage ||
            prev.pendingSurah != curr.pendingSurah;
      },
      builder: (context, state) {
        if (kDebugMode) {
          _MiniPlayerDebugLog.maybeLog(
            tag: widget.debugTag,
            phase: state.phase,
            surah: state.currentSurah,
            isPlaying: state.isPlaying,
            urlSet: state.url != null,
          );
        }

        if (widget.hideWhenIdle) {
          if ((state.currentSurah == null &&
                  state.url == null &&
                  state.pendingSurah == null) ||
              state.phase == AudioPhase.idle) {
            return const SizedBox.shrink();
          }
        } else {
          if (state.currentSurah == null &&
              state.url == null &&
              state.pendingSurah == null) {
            return const SizedBox.shrink();
          }
        }

        // Handle awaiting confirmation state - show confirmation dialog
        if (state.phase == AudioPhase.awaitingConfirmation &&
            state.pendingSurah != null) {
          final pendingSurahNum = state.pendingSurah!;

          debugPrint(
            '🔵 [Dialog Check] Phase: awaitingConfirmation, Surah: $pendingSurahNum',
          );
          debugPrint(
            '🔵 [Dialog Check] _dialogShown: $_dialogShown, _lastShownPendingSurah: $_lastShownPendingSurah',
          );
          debugPrint(
            '🔵 [Dialog Check] _isDialogProcessing: $_isDialogProcessing',
          );
          debugPrint(
            '🔵 [Dialog Check] _dialogOpenedInThisBuild: $_dialogOpenedInThisBuild',
          );
          debugPrint(
            '🔵 [Dialog Check] Condition to show: ${(!_dialogShown || _lastShownPendingSurah != pendingSurahNum) && !_isDialogProcessing && !_dialogOpenedInThisBuild}',
          );

          // Only show dialog if we haven't shown it yet for this surah
          // AND we're not currently processing a dialog action
          // AND we haven't already opened a dialog in this build cycle
          // AND there's no global dialog already open
          if ((!_dialogShown || _lastShownPendingSurah != pendingSurahNum) &&
              !_isDialogProcessing &&
              !_dialogOpenedInThisBuild &&
              !_globalDialogOpen) {
            debugPrint(
              '✅ [Dialog Show] Showing dialog for Surah: $pendingSurahNum',
            );
            _dialogShown = true;
            _isDialogProcessing = true;
            _dialogOpenedInThisBuild = true;
            _globalDialogOpen = true;
            _lastShownPendingSurah = pendingSurahNum;

            final pendingInfo = QuranLibrary().getSurahInfo(
              surahNumber: pendingSurahNum - 1,
            );

            // Show confirmation dialog
            Future.microtask(() {
              if (!context.mounted) return;
              debugPrint(
                '📱 [Dialog Display] Opening dialog for Surah: $pendingSurahNum',
              );
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => AlertDialog(
                  title: Text(t.confirmLoadSurah),
                  content: Text('${t.loadSurah} ${pendingInfo.name}؟'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        debugPrint('❌ [Dialog Action] User clicked NO');
                        Navigator.of(dialogContext).pop(false);
                      },
                      child: Text(t.no),
                    ),
                    TextButton(
                      onPressed: () {
                        debugPrint('✅ [Dialog Action] User clicked YES');
                        Navigator.of(dialogContext).pop(true);
                      },
                      child: Text(t.yes),
                    ),
                  ],
                ),
              ).then((confirmed) {
                debugPrint(
                  '🔄 [Dialog Result] Dialog closed, confirmed: $confirmed',
                );
                debugPrint(
                  '🔄 [Dialog Result] context.mounted: ${context.mounted}',
                );
                if (!context.mounted) {
                  debugPrint(
                    '⚠️ [Dialog Result] Context not mounted, returning',
                  );
                  return;
                }

                debugPrint(
                  '🔄 [Dialog Result] Setting _isDialogProcessing = false',
                );
                _isDialogProcessing = false;

                if (confirmed == true) {
                  debugPrint(
                    '▶️ [Dialog Action] Calling confirmAndPlaySurah for Surah: $pendingSurahNum',
                  );
                  // User clicked "Yes" - start playing
                  context.read<AudioCubit>().confirmAndPlaySurah(
                    pendingSurahNum,
                    from: state.pendingInitialPosition,
                  );
                } else {
                  debugPrint('⏹️ [Dialog Action] Calling rejectPendingSurah');
                  // User clicked "No" - reject
                  context.read<AudioCubit>().rejectPendingSurah();
                }

                // Reset dialog flags after handling
                debugPrint(
                  '🔄 [Dialog Result] Setting _dialogShown = false and _globalDialogOpen = false',
                );
                _dialogShown = false;
                _globalDialogOpen = false;
              });
            });
          } else {
            debugPrint(
              '⏭️ [Dialog Skip] Skipping dialog - already shown or processing',
            );
          }

          return const SizedBox.shrink();
        } else {
          // Reset the flag when not in awaiting confirmation state
          if (_dialogShown ||
              _isDialogProcessing ||
              _lastShownPendingSurah != null) {
            debugPrint(
              '🔄 [State Exit] Exiting awaitingConfirmation, resetting flags',
            );
            debugPrint(
              '🔄 [State Exit] Phase: ${state.phase}, pendingSurah: ${state.pendingSurah}',
            );
          }
          _dialogShown = false;
          _isDialogProcessing = false;
          _dialogOpenedInThisBuild = false;
          _globalDialogOpen = false;
          _lastShownPendingSurah = null;
        }
        final sNum = state.currentSurah ?? 1;
        final info = QuranLibrary().getSurahInfo(surahNumber: sNum - 1);

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

        final scheme = Theme.of(context).colorScheme;
        final verses = quran.getVerseCount(sNum);
        final place = quran.getPlaceOfRevelation(sNum).toLowerCase();
        final isMadani = place.contains('mad');

        return GestureDetector(
          onTap: () => _openFullPlayer(context),
          onVerticalDragUpdate: (details) {
            // توفير تغذية هابتيك خلال السحب للأعلى
            if (details.primaryDelta! < -15) {
              HapticFeedback.lightImpact();
            }
          },
          onVerticalDragEnd: (details) {
            // اكتشاف السحب بسرعة مع عتبات محددة
            if (details.primaryVelocity! < -300) {
              // سحب سريع - أنيميشن مميزة مع هابتيك قوية
              HapticFeedback.mediumImpact();
              _openFullPlayer(context);
            } else if (details.primaryVelocity! < -150) {
              // سحب عادي - أنيميشن قياسية مع هابتيك خفيفة
              HapticFeedback.lightImpact();
              _openFullPlayer(context);
            }
          },
          child: Material(
            elevation: 4,
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: scheme.surface,
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
                  color: scheme.outline.withOpacity(0.1),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // صف المحتوى الرئيسي
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        // العنوان والمعلومات
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
                                      Text(
                                        info.name,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.right,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${isMadani ? t.madani : t.makki} • $verses ${t.aya}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: scheme.onSurface
                                                  .withOpacity(0.6),
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

                        // زر التشغيل/الإيقاف
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
                        // زر الإغلاق
                        Semantics(
                          label: t.stop,
                          button: true,
                          child: IconButton(
                            icon: SvgPicture.asset(
                              AppAssets.icExitGreyCross,
                              width: 14,
                              height: 14,
                            ),
                            onPressed: () =>
                                context.read<AudioCubit>().clearAudio(),
                            tooltip: t.stop,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // صف التوقيت
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: _MiniTimesRow(),
                  ),
                  // شريط التقدم
                  _MiniProgressBar(
                    backgroundColor: scheme.surface.withOpacity(0.4),
                    color: scheme.primary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// باقي الكود بدون تغيير
class _MiniPlayerDebugLog {
  static final Map<String, String> _lastKeyByTag = <String, String>{};

  static void maybeLog({
    required String tag,
    required AudioPhase phase,
    required int? surah,
    required bool isPlaying,
    required bool urlSet,
  }) {
    final key = 'phase=$phase surah=$surah isPlaying=$isPlaying urlSet=$urlSet';
    final last = _lastKeyByTag[tag];
    if (last == key) return;
    _lastKeyByTag[tag] = key;
    debugPrint('[MiniPlayer][$tag] $key');
  }
}

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
