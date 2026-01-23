import '../../domain/entities/surah.dart';

/// Minimal local data source placeholder.
/// We rely on quran_library widgets in presentation for rendering.
class QuranLocalDataSource {
  List<Surah> getAllSurahs() => const <Surah>[];
  List<String> getSurahVerses(int surahNumber, {bool verseEndSymbol = true}) => const <String>[];
}
