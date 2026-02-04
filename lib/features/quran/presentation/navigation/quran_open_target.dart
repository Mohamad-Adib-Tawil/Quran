// نموذج تنقّل صريح لفتح المصحف على هدف محدّد
// (سورة، جزء، حزب) بدون الاعتماد على أي حالة سابقة.

enum QuranOpenTargetType { surah, juz, hizb }

class QuranOpenTarget {
  final QuranOpenTargetType type;
  final int number; // 1-based index

  const QuranOpenTarget._(this.type, this.number);

  factory QuranOpenTarget.surah(int surah) => QuranOpenTarget._(QuranOpenTargetType.surah, surah);
  factory QuranOpenTarget.juz(int juz) => QuranOpenTarget._(QuranOpenTargetType.juz, juz);
  factory QuranOpenTarget.hizb(int hizb) => QuranOpenTarget._(QuranOpenTargetType.hizb, hizb);

  @override
  String toString() => 'QuranOpenTarget(type: $type, number: $number)';
}
