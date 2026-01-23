import '../entities/surah.dart';

abstract class QuranRepository {
  List<Surah> getAllSurahs();
  List<String> getSurahVerses(int surahNumber, {bool verseEndSymbol = true});
}
