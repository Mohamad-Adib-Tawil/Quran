import 'package:equatable/equatable.dart';
import '../../domain/entities/surah.dart';

class QuranState extends Equatable {
  final int currentSurah; // 1..114
  final int currentAyah; // 1..verseCount
  final List<String> verses; // of current surah
  final List<Surah> surahs; // metadata list

  const QuranState({
    required this.currentSurah,
    required this.currentAyah,
    required this.verses,
    required this.surahs,
  });

  factory QuranState.initial() => const QuranState(
        currentSurah: 1,
        currentAyah: 1,
        verses: [],
        surahs: [],
      );

  QuranState copyWith({
    int? currentSurah,
    int? currentAyah,
    List<String>? verses,
    List<Surah>? surahs,
  }) =>
      QuranState(
        currentSurah: currentSurah ?? this.currentSurah,
        currentAyah: currentAyah ?? this.currentAyah,
        verses: verses ?? this.verses,
        surahs: surahs ?? this.surahs,
      );

  @override
  List<Object?> get props => [currentSurah, currentAyah, verses, surahs];
}
