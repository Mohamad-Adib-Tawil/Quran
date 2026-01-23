import '../../domain/entities/surah.dart';
import '../../domain/repositories/quran_repository.dart';
import '../datasources/quran_local_data_source.dart';

class QuranRepositoryImpl implements QuranRepository {
  final QuranLocalDataSource local;
  QuranRepositoryImpl(this.local);

  @override
  List<Surah> getAllSurahs() => local.getAllSurahs();

  @override
  List<String> getSurahVerses(int surahNumber, {bool verseEndSymbol = true}) =>
      local.getSurahVerses(surahNumber, verseEndSymbol: verseEndSymbol);
}
