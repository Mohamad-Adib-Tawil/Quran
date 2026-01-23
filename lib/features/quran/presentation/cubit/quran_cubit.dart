import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/quran_repository.dart';
import 'quran_state.dart';

class QuranCubit extends Cubit<QuranState> {
  final QuranRepository _repo;
  QuranCubit(this._repo) : super(QuranState.initial()) {
    loadCatalog();
    loadSurah(1);
  }

  void loadSurah(int surah, {bool verseEndSymbol = true}) {
    final verses = _repo.getSurahVerses(surah, verseEndSymbol: verseEndSymbol);
    emit(state.copyWith(currentSurah: surah, currentAyah: 1, verses: verses));
  }

  void loadCatalog() {
    final all = _repo.getAllSurahs();
    emit(state.copyWith(surahs: all));
  }

  void reloadCurrent({bool verseEndSymbol = true}) {
    loadSurah(state.currentSurah, verseEndSymbol: verseEndSymbol);
  }

  void nextAyah() {
    final next = state.currentAyah + 1;
    if (next <= state.verses.length) {
      emit(state.copyWith(currentAyah: next));
    }
  }

  void prevAyah() {
    final prev = state.currentAyah - 1;
    if (prev >= 1) {
      emit(state.copyWith(currentAyah: prev));
    }
  }

  void jumpToAyah(int ayah) {
    if (ayah >= 1 && ayah <= state.verses.length) {
      emit(state.copyWith(currentAyah: ayah));
    }
  }

  void nextSurah({bool verseEndSymbol = true}) {
    final next = state.currentSurah + 1;
    if (next <= (state.surahs.isNotEmpty ? state.surahs.length : 114)) {
      loadSurah(next, verseEndSymbol: verseEndSymbol);
    }
  }

  void prevSurah({bool verseEndSymbol = true}) {
    final prev = state.currentSurah - 1;
    if (prev >= 1) {
      loadSurah(prev, verseEndSymbol: verseEndSymbol);
    }
  }
}
