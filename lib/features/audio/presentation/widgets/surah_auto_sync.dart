import 'dart:async';

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
  const SurahAutoSync({super.key, required this.child});

  @override
  State<SurahAutoSync> createState() => _SurahAutoSyncState();
}

class _SurahAutoSyncState extends State<SurahAutoSync> {
  Timer? _timer;
  int? _lastAppliedSurah;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 700), (_) => _tick());
  }

  void _tick() async {
    try {
      final surah = QuranLibrary().currentAndLastSurahNumber;
      if (surah >= 1 && surah <= 114 && surah != _lastAppliedSurah) {
        _lastAppliedSurah = surah;
        context.read<AudioCubit>().selectSurah(surah);
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
