import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_library/quran_library.dart';

import 'home_state.dart';

/// Cubit مبسّط لإدارة تبويب الشاشة الرئيسية والبحث في السور
class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState()) {
    _init();
  }

  void _init() {
    // بدايةً: كل السور 1..114
    emit(state.copyWith(filteredSurahs: List<int>.generate(114, (i) => i + 1)));
  }
  String _normalizeArabic(String input) {
    final diacritics = RegExp(r'[\u064B-\u0652\u0670\u0653-\u0655\u0640]');
    var s = input.replaceAll(diacritics, "");
    s = s.replaceAll("أ","ا").replaceAll("إ","ا").replaceAll("آ","ا").replaceAll("ٱ","ا");
    return s;
  }


  void setQuery(String q) {
    final trimmed = q.trim();
    if (trimmed.isEmpty) {
      emit(state.copyWith(query: '', filteredSurahs: List<int>.generate(114, (i) => i + 1)));
      return;
    }
    // فلترة بحسب الاسم العربي مع تجاهل التشكيل في المطابقة فقط
    final List<int> all = List<int>.generate(114, (i) => i + 1);
    final nq = _normalizeArabic(trimmed);
    final filtered = all.where((s) {
      final info = QuranLibrary().getSurahInfo(surahNumber: s - 1);
      final nameAr = info.name;
      return _normalizeArabic(nameAr).contains(nq);
    }).toList();
    emit(state.copyWith(query: trimmed, filteredSurahs: filtered));
  }

  void setTab(int i) => emit(state.copyWith(tabIndex: i));
}
