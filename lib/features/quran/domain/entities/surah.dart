import 'package:equatable/equatable.dart';

class Surah extends Equatable {
  final int number; // 1..114
  final String nameArabic;
  final String nameEnglish;
  final int verseCount;
  final String revelation; // Makki / Madani

  const Surah({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.verseCount,
    required this.revelation,
  });

  @override
  List<Object?> get props => [number, nameArabic, nameEnglish, verseCount, revelation];
}
