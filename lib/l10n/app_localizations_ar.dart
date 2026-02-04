// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'القرآن الكريم';

  @override
  String get tabSurahs => 'السور';

  @override
  String get tabJuz => 'الأجزاء';

  @override
  String get tabHizb => 'الأحزاب';

  @override
  String get indexTab => 'الفهرس';

  @override
  String get bookmarksTab => 'العلامات';

  @override
  String get searchTab => 'بحث';

  @override
  String get copied => 'تم النسخ';

  @override
  String get hizbName => 'الحزب';

  @override
  String get juzName => 'الجزء';

  @override
  String get sajdaName => 'السجدة';

  @override
  String get manageAudio => 'إدارة الصوت';

  @override
  String get favoritesTitle => 'المميزة بنجمة';

  @override
  String get noFavorites => 'لا توجد سور مميزة بعد';

  @override
  String favSurahNumber(Object s) {
    return 'سورة رقم $s';
  }

  @override
  String errorPlaySurah(Object e) {
    return 'تعذّر تشغيل السورة: $e';
  }

  @override
  String get removeFromFavorites => 'إزالة من المميزة';

  @override
  String get addToFavorites => 'تمييز بنجمة';

  @override
  String get chooseLanguage => 'اختر اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get german => 'Deutsch';

  @override
  String get settings => 'الإعدادات';

  @override
  String get appearance => 'المظهر';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get system => 'حسب النظام';

  @override
  String get language => 'اللغة';

  @override
  String get fontSize => 'حجم الخط';

  @override
  String get soon => 'Soon';

  @override
  String get showVerseEndSymbol => 'إظهار علامة نهاية الآية';

  @override
  String get lastRead => 'آخر المقروء';

  @override
  String ayahNumber(Object ayah) {
    return 'الآية $ayah';
  }

  @override
  String get madani => 'مدنية';

  @override
  String get makki => 'مكية';

  @override
  String get details => 'تفاصيل';

  @override
  String get read => 'القراءة';

  @override
  String get surahNumberLabel => 'رقم السورة';

  @override
  String get name => 'الاسم';

  @override
  String get searchSurahHint => 'ابحث عن سورة';

  @override
  String get downloads => 'التحميلات';

  @override
  String get mushaf => 'المصحف';

  @override
  String get downloadedTab => 'المحمّلة';

  @override
  String get notDownloadedTab => 'غير المحمّلة';

  @override
  String get noDownloaded => 'لا توجد سور محمّلة';

  @override
  String get noNotDownloaded => 'لا توجد سور غير محمّلة';

  @override
  String get play => 'تشغيل';

  @override
  String get delete => 'حذف';

  @override
  String get deleteSuccess => 'تم حذف السورة';

  @override
  String get download => 'تحميل';

  @override
  String get downloadingSurah => 'جاري تحميل السورة...';

  @override
  String get unexpectedError => 'حدث خطأ غير متوقع';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get previous => 'السابق';

  @override
  String get pause => 'إيقاف مؤقت';

  @override
  String get stop => 'إيقاف';

  @override
  String get next => 'التالي';
}
