import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/audio/presentation/cubit/audio_cubit.dart';
import '../features/audio/presentation/cubit/audio_state.dart';

/// مدير جلسة الصوت (Singleton) لحفظ واسترجاع آخر سورة وحالة التشغيل.
/// - يحفظ: آخر سورة، هل كان يشغّل، آخر موضع زمني (اختياري مستقبلًا).
/// - يستمع لحالة AudioCubit ويحدّث التخزين.
class AudioSessionManager {
  static const _keyLastSurah = 'audio.lastSurah';
  static const _keyWasPlaying = 'audio.wasPlaying';
  static const _keyLastPositionMs = 'audio.lastPositionMs';

  final SharedPreferences _prefs;
  StreamSubscription<AudioState>? _sub;

  AudioSessionManager(this._prefs);

  void attach(AudioCubit cubit) {
    _sub?.cancel();
    _sub = cubit.stream.listen((s) {
      if (s.currentSurah != null) {
        _prefs.setInt(_keyLastSurah, s.currentSurah!);
      }
      _prefs.setBool(_keyWasPlaying, s.isPlaying);
      _prefs.setInt(_keyLastPositionMs, s.position.inMilliseconds);
    });
  }

  /// استرجاع آخر جلسة (سورة فقط افتراضيًا). لا تشغيل تلقائي.
  Future<void> restoreIfNeeded(AudioCubit cubit) async {
    final lastSurah = _prefs.getInt(_keyLastSurah) ?? 1; // الفاتحة افتراضيًا
    // عيّن السورة الحالية فقط (بدون تشغيل)
    cubit.selectSurah(lastSurah);
    // يمكن لاحقًا استرجاع الموضع أو التشغيل إن احتجنا
  }

  @mustCallSuper
  Future<void> dispose() async {
    await _sub?.cancel();
  }
}
