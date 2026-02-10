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
  final bool hideWhenIdle;
  final String debugTag;
  final VoidCallback? onOpenFullPlayer;

  const MiniAudioPlayer({
    super.key,
    this.hideWhenIdle = false,
    this.debugTag = 'MiniAudioPlayer',
    this.onOpenFullPlayer,
  });

  void _openFullPlayer(BuildContext context) {
    if (onOpenFullPlayer != null) {
      onOpenFullPlayer!();
    } else {
      _navigateToFullPlayerWithPremiumAnimation(context);
    }
  }

  void _navigateToFullPlayerWithPremiumAnimation(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const FullPlayerPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // متعدد الطبقات - أنيميشن احترافية
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return Stack(
            children: [
              // خلفية تتلاشى
              FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
                  ),
                ),
                child: Container(color: Colors.black.withOpacity(0.6)),
              ),

              // المحتوى الرئيسي مع تحريك متعدد
              ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
                  ),
                ),
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: const Interval(
                            0.1,
                            0.8,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                      ),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.5, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: const Interval(0.3, 1.0),
                      ),
                    ),
                    child: child,
                  ),
                ),
              ),
            ],
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        barrierColor: Colors.black54,
        opaque: false,
      ),
    );
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
            tag: debugTag,
            phase: state.phase,
            surah: state.currentSurah,
            isPlaying: state.isPlaying,
            urlSet: state.url != null,
          );
        }

        if (hideWhenIdle) {
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
          final pendingInfo = QuranLibrary().getSurahInfo(
            surahNumber: pendingSurahNum - 1,
          );

          // Show confirmation dialog
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => AlertDialog(
                title: Text(t.confirmLoadSurah),
                content: Text('${t.loadSurah} ${pendingInfo.name}؟'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      context.read<AudioCubit>().rejectPendingSurah();
                    },
                    child: Text(t.no),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      context.read<AudioCubit>().confirmAndPlaySurah(
                        pendingSurahNum,
                        from: state.pendingInitialPosition,
                      );
                    },
                    child: Text(t.yes),
                  ),
                ],
              ),
            );
          });

          return const SizedBox.shrink();
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
                        // مؤشر التحميل
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: AnimatedOpacity(
                            opacity: state.isBuffering ? 1 : 0,
                            duration: const Duration(milliseconds: 150),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
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
                            onPressed: () => context.read<AudioCubit>().stop(),
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
