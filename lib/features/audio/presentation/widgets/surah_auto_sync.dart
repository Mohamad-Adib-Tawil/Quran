import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_library/quran_library.dart';

import '../cubit/audio_cubit.dart';

/// Periodically sync current surah context for audio with QuranLibraryScreen.
///
/// Uses QuranLibrary().currentAndLastSurahNumber which reflects either:
/// - the surah at the top of the current page, or
/// - the surah of the currently selected ayah (if user selected one).
///
/// We only set the current surah context on AudioCubit without auto-playing.
class SurahAutoSync extends StatefulWidget {
  final Widget child;

  /// Optional initial surah to lock on while QuranLibrary settles.
  /// This prevents transient resets (often to Al-Fatiha) from overriding
  /// the surah the user navigated to.
  final int? initialSurah;

  const SurahAutoSync({super.key, required this.child, this.initialSurah});

  @override
  State<SurahAutoSync> createState() => _SurahAutoSyncState();
}

class _SurahAutoSyncState extends State<SurahAutoSync> {
  Timer? _timer;
  int? _lastAppliedSurah;

  int? _candidateSurah;
  int _candidateHits = 0;

  DateTime? _ignoreSurah1Until;

  @override
  void initState() {
    super.initState();

    // If the caller provides an initial surah (e.g., opened via deep link / navigation),
    // apply it immediately and ignore transient surah=1 values for a short window.
    final initSurah = widget.initialSurah;
    if (initSurah != null && initSurah >= 1 && initSurah <= 114) {
      _lastAppliedSurah = initSurah;
      _ignoreSurah1Until = DateTime.now().add(const Duration(seconds: 4));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(context.read<AudioCubit>().selectSurah(initSurah));
      });
    }

    // Reduced polling frequency to save CPU/battery
    _timer = Timer.periodic(const Duration(milliseconds: 1200), (_) => _tick());
  }

  void _tick() {
    try {
      final surah = QuranLibrary().currentAndLastSurahNumber;
      if (kDebugMode) {
        debugPrint('[SurahAutoSync] tick: surah=$surah lastApplied=$_lastAppliedSurah candidate=$_candidateSurah hits=$_candidateHits');
      }
      if (surah < 1 || surah > 114) return;

      // ✅ Guard against transient reset to Al-Fatiha (surah=1)
      // This can happen during QuranLibrary / AudioCtrl initialization.
      if (surah == 1 && _lastAppliedSurah != null && _lastAppliedSurah != 1) {
        final until = _ignoreSurah1Until;
        if (until != null && DateTime.now().isBefore(until)) {
          if (kDebugMode) {
            debugPrint('[SurahAutoSync] ignored transient surah=1 until=$until');
          }
          return;
        }
      }

      // ✅ Stability check: require the same value in 2 consecutive ticks
      // before applying to AudioCubit, to prevent UI flicker.
      if (_candidateSurah != surah) {
        _candidateSurah = surah;
        _candidateHits = 1;
        if (kDebugMode) {
          debugPrint('[SurahAutoSync] candidate set: surah=$surah hits=$_candidateHits');
        }
        return;
      }

      _candidateHits++;

      // Require extra confirmation for surah=1 to reduce false resets.
      final requiredHits = (surah == 1) ? 3 : 2;
      if (_candidateHits < requiredHits) {
        if (kDebugMode) {
          debugPrint('[SurahAutoSync] waiting stability: surah=$surah hits=$_candidateHits required=$requiredHits');
        }
        return;
      }

      if (surah != _lastAppliedSurah) {
        _lastAppliedSurah = surah;
        if (kDebugMode) {
          debugPrint('[SurahAutoSync] apply: selectSurah($surah)');
        }
        unawaited(context.read<AudioCubit>().selectSurah(surah));
      }
    } catch (_) {
      // ignore
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
