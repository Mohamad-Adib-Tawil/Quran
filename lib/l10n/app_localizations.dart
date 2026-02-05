import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'القرآن الكريم'**
  String get appTitle;

  /// No description provided for @tabSurahs.
  ///
  /// In ar, this message translates to:
  /// **'السور'**
  String get tabSurahs;

  /// No description provided for @tabJuz.
  ///
  /// In ar, this message translates to:
  /// **'الأجزاء'**
  String get tabJuz;

  /// No description provided for @tabHizb.
  ///
  /// In ar, this message translates to:
  /// **'الأحزاب'**
  String get tabHizb;

  /// No description provided for @indexTab.
  ///
  /// In ar, this message translates to:
  /// **'الفهرس'**
  String get indexTab;

  /// No description provided for @bookmarksTab.
  ///
  /// In ar, this message translates to:
  /// **'العلامات'**
  String get bookmarksTab;

  /// No description provided for @searchTab.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get searchTab;

  /// No description provided for @copied.
  ///
  /// In ar, this message translates to:
  /// **'تم النسخ'**
  String get copied;

  /// No description provided for @hizbName.
  ///
  /// In ar, this message translates to:
  /// **'الحزب'**
  String get hizbName;

  /// No description provided for @juzName.
  ///
  /// In ar, this message translates to:
  /// **'الجزء'**
  String get juzName;

  /// No description provided for @sajdaName.
  ///
  /// In ar, this message translates to:
  /// **'السجدة'**
  String get sajdaName;

  /// No description provided for @manageAudio.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الصوت'**
  String get manageAudio;

  /// No description provided for @favoritesTitle.
  ///
  /// In ar, this message translates to:
  /// **'المميزة بنجمة'**
  String get favoritesTitle;

  /// No description provided for @noFavorites.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد سور مميزة بعد'**
  String get noFavorites;

  /// No description provided for @favSurahNumber.
  ///
  /// In ar, this message translates to:
  /// **'سورة رقم {s}'**
  String favSurahNumber(Object s);

  /// No description provided for @errorPlaySurah.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تشغيل السورة: {e}'**
  String errorPlaySurah(Object e);

  /// No description provided for @removeFromFavorites.
  ///
  /// In ar, this message translates to:
  /// **'إزالة من المميزة'**
  String get removeFromFavorites;

  /// No description provided for @addToFavorites.
  ///
  /// In ar, this message translates to:
  /// **'تمييز بنجمة'**
  String get addToFavorites;

  /// No description provided for @chooseLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اختر اللغة'**
  String get chooseLanguage;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @german.
  ///
  /// In ar, this message translates to:
  /// **'Deutsch'**
  String get german;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get appearance;

  /// No description provided for @light.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In ar, this message translates to:
  /// **'حسب النظام'**
  String get system;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @fontSize.
  ///
  /// In ar, this message translates to:
  /// **'حجم الخط'**
  String get fontSize;

  /// No description provided for @soon.
  ///
  /// In ar, this message translates to:
  /// **'Soon'**
  String get soon;

  /// No description provided for @showVerseEndSymbol.
  ///
  /// In ar, this message translates to:
  /// **'إظهار علامة نهاية الآية'**
  String get showVerseEndSymbol;

  /// No description provided for @lastRead.
  ///
  /// In ar, this message translates to:
  /// **'آخر المقروء'**
  String get lastRead;

  /// No description provided for @ayahNumber.
  ///
  /// In ar, this message translates to:
  /// **'الآية {ayah}'**
  String ayahNumber(Object ayah);

  /// No description provided for @aya.
  ///
  /// In ar, this message translates to:
  /// **'آية'**
  String get aya;

  /// No description provided for @madani.
  ///
  /// In ar, this message translates to:
  /// **'مدنية'**
  String get madani;

  /// No description provided for @makki.
  ///
  /// In ar, this message translates to:
  /// **'مكية'**
  String get makki;

  /// No description provided for @details.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل'**
  String get details;

  /// No description provided for @read.
  ///
  /// In ar, this message translates to:
  /// **'القراءة'**
  String get read;

  /// No description provided for @surahNumberLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم السورة'**
  String get surahNumberLabel;

  /// No description provided for @name.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get name;

  /// No description provided for @searchSurahHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن سورة'**
  String get searchSurahHint;

  /// No description provided for @downloads.
  ///
  /// In ar, this message translates to:
  /// **'التحميلات'**
  String get downloads;

  /// No description provided for @mushaf.
  ///
  /// In ar, this message translates to:
  /// **'المصحف'**
  String get mushaf;

  /// No description provided for @downloadedTab.
  ///
  /// In ar, this message translates to:
  /// **'المحمّلة'**
  String get downloadedTab;

  /// No description provided for @notDownloadedTab.
  ///
  /// In ar, this message translates to:
  /// **'غير المحمّلة'**
  String get notDownloadedTab;

  /// No description provided for @noDownloaded.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد سور محمّلة'**
  String get noDownloaded;

  /// No description provided for @noNotDownloaded.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد سور غير محمّلة'**
  String get noNotDownloaded;

  /// No description provided for @play.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل'**
  String get play;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @deleteSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف السورة'**
  String get deleteSuccess;

  /// No description provided for @download.
  ///
  /// In ar, this message translates to:
  /// **'تحميل'**
  String get download;

  /// No description provided for @downloadingSurah.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل السورة...'**
  String get downloadingSurah;

  /// No description provided for @unexpectedError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع'**
  String get unexpectedError;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @previous.
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get previous;

  /// No description provided for @pause.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف مؤقت'**
  String get pause;

  /// No description provided for @stop.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف'**
  String get stop;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'de'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
