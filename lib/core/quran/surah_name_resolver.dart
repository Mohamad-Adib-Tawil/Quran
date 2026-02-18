import 'package:quran/quran.dart' as quran;
import 'package:quran_library/quran_library.dart';

class SurahNamePair {
  final String arabic;
  final String latin;

  const SurahNamePair({
    required this.arabic,
    required this.latin,
  });
}

SurahNamePair resolveSurahNamePair(int surahNumber) {
  final info = QuranLibrary().getSurahInfo(surahNumber: surahNumber - 1);
  return SurahNamePair(
    arabic: info.name,
    latin: quran.getSurahName(surahNumber),
  );
}
