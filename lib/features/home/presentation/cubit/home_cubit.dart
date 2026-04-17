import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/core/quran/surah_name_resolver.dart';

import 'home_state.dart';

/// Cubit مبسّط لإدارة تبويب الشاشة الرئيسية والبحث في السور
class HomeCubit extends Cubit<HomeState> {
  static final List<int> _allSurahNumbers = List<int>.unmodifiable(
    List<int>.generate(114, (i) => i + 1),
  );

  HomeCubit() : super(const HomeState()) {
    _init();
  }

  void _init() {
    // بدايةً: كل السور 1..114
    emit(state.copyWith(filteredSurahs: _allSurahNumbers));
  }

  String _normalizeArabic(String input) {
    final diacritics = RegExp(r'[\u064B-\u0652\u0670\u0653-\u0655\u0640]');
    var s = input.replaceAll(diacritics, '');
    s = s
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ٱ', 'ا');
    return s;
  }

  String _normalizeLatin(String input) {
    var s = input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
    s = s.replaceAll('aa', 'a').replaceAll('ee', 'i').replaceAll('oo', 'u');
    return s.endsWith('h') ? s.substring(0, s.length - 1) : s;
  }

  void setQuery(String q) {
    final trimmed = q.trim();
    if (trimmed.isEmpty) {
      emit(state.copyWith(query: '', filteredSurahs: _allSurahNumbers));
      return;
    }
    // فلترة بالعربي واللاتيني مع توحيد الصيغ الشائعة مثل Baqara/Baqarah.
    final arabicQuery = _normalizeArabic(trimmed);
    final latinQuery = _normalizeLatin(trimmed);
    final filtered = _allSurahNumbers.where((s) {
      final names = resolveSurahNamePair(s);
      final arabicName = _normalizeArabic(names.arabic);
      final latinName = _normalizeLatin(names.latin);
      return arabicName.contains(arabicQuery) ||
          (latinQuery.isNotEmpty && latinName.contains(latinQuery));
    }).toList();
    emit(state.copyWith(query: trimmed, filteredSurahs: filtered));
  }

  void setTab(int i) => emit(state.copyWith(tabIndex: i));
}
