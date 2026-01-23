import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_library/quran_library.dart';

import '../cubit/audio_cubit.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/repositories/audio_download_repository.dart';

/// Periodically sync the audio player's loaded surah with the current
/// surah displayed by QuranLibraryScreen.
///
/// Strategy:
/// - Poll currentAndLastSurahNumber every 700ms.
/// - When it changes and stabilizes for 1 tick, update the player:
///   - If player is playing -> prepare and play new surah from 0:00.
///   - If paused/stopped     -> just prepare new surah without playing.
class SurahAutoSync extends StatefulWidget {
  final Widget child;
  const SurahAutoSync({super.key, required this.child});

  @override
  State<SurahAutoSync> createState() => _SurahAutoSyncState();
}

class _SurahAutoSyncState extends State<SurahAutoSync> {
  Timer? _timer;
  int? _lastSeenSurah;
  int? _pendingSurah;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 700), (_) => _tick());
  }

  void _tick() async {
    try {
      final current = QuranLibrary().currentAndLastSurahNumber;
      if (current <= 0 || current > 114) return;

      if (_pendingSurah == null || _pendingSurah != current) {
        // First time seeing this surah; set pending and wait for next tick to stabilize
        _pendingSurah = current;
        return;
      }

      // Surah stabilized
      if (_lastSeenSurah != current) {
        _lastSeenSurah = current;
        final cubit = context.read<AudioCubit>();
        final isPlaying = cubit.state.isPlaying;
        if (cubit.state.currentSurah == current) return;
        // Only auto-prepare if this surah is already downloaded locally
        final isDownloaded = await sl<AudioDownloadRepository>().isDownloaded(current);
        if (!isDownloaded) return;
        if (isPlaying) {
          await cubit.prepareAndPlaySurah(current, from: Duration.zero, cache: true);
        } else {
          await cubit.prepareSurah(current, initialPosition: Duration.zero, cache: true);
        }
      }
    } catch (_) {
      // ignore errors from library state access
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
