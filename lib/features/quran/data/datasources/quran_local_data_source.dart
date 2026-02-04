import '../../domain/entities/surah.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_library/quran_library.dart';

/// Minimal local data source placeholder.
/// We rely on quran_library widgets in presentation for rendering.
class QuranLocalDataSource {
  List<Surah> getAllSurahs() {
    final List<Surah> list = [];
    for (int s = 1; s <= 114; s++) {
      final info = QuranLibrary().getSurahInfo(surahNumber: s - 1);
      final english = quran.getSurahName(s);
      final verses = quran.getVerseCount(s);
      final place = quran.getPlaceOfRevelation(s); // "Makkah" | "Madina"
      final revelation = place.toLowerCase().contains('mad') ? 'Madani' : 'Makki';
      list.add(Surah(
        number: s,
        nameArabic: info.name,
        nameEnglish: english,
        verseCount: verses,
        revelation: revelation,
      ));
    }
    return list;
  }

  List<String> getSurahVerses(int surahNumber, {bool verseEndSymbol = true}) {
    final count = quran.getVerseCount(surahNumber);
    return List<String>.generate(
      count,
      (i) => quran.getVerse(surahNumber, i + 1, verseEndSymbol: verseEndSymbol),
    );
  }
}
