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

  /// No description provided for @settingsHeaderSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'قم بضبط تفضيلاتك الشخصية لتجربة أفضل'**
  String get settingsHeaderSubtitle;

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
  /// **'قريبًا'**
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

  /// No description provided for @errorOccurred.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ'**
  String get errorOccurred;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @preparing.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحضير...'**
  String get preparing;

  /// No description provided for @noSurahSelected.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم اختيار سورة'**
  String get noSurahSelected;

  /// No description provided for @ready.
  ///
  /// In ar, this message translates to:
  /// **'جاهزة'**
  String get ready;

  /// No description provided for @confirmLoadSurah.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد تحميل السورة'**
  String get confirmLoadSurah;

  /// No description provided for @loadSurah.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تحميل'**
  String get loadSurah;

  /// No description provided for @yes.
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get no;

  /// No description provided for @scholarTitle.
  ///
  /// In ar, this message translates to:
  /// **'الشيخ أحمد كراسي رحمه الله'**
  String get scholarTitle;

  /// No description provided for @scholarBioLabel.
  ///
  /// In ar, this message translates to:
  /// **'نبذة عن حياة شيخ قرّاء حلب'**
  String get scholarBioLabel;

  /// No description provided for @scholarBioDescription.
  ///
  /// In ar, this message translates to:
  /// **'نبذة عن حياة شيخ قرّاء حلب\n(القارئ المقرئ الشيخ أحمد كراسي رحمه الله)\n(ولد في عام 1924م ـ وتوفي في عام 2008م)\n\nهو الشيخ المقرئ ذو الصوت القوي والنغم الجميل، والمخارج السليمة، والقراءة الفصيحة، الحسيب النسيب، فضيلة الشيخ أحمد كراسي بن عبد السلام.\n\nولد في حي الفرافرة عام (1924م / 1343هـ). ولما بلغ من العمر السادسة عشرة، زوّجه أبوه، وأكرمه الله بذكورٍ وإناثٍ صالحين، أكبرهم الحاج عبد السلام حفظه الله.\n\nعاش رحمه الله في بيئة محفوفة بالعلم والصلاح، فمنذ نعومة أظفاره لم يبارح مرافقة والده لمجالس الذكر والعلم، ومساعدته في عمله بتجارة الأخشاب.\n\nولبداية أخذه القرآن حكاية؛ إذ كان يومًا في زيارة للشيخ محمد مراد برفقة والده، فطلب منه الشيخ أن يقرأ ولو من قصار السور، فقرأ شيئًا من ذلك. فلما انتهى قال السيد محمد النسر ـ وكان من بين الحاضرين ـ: إن هذا الشاب عنده استعداد لحفظ كلام الله تعالى، وخلقته تساعده.\n\nفأثّرت هذه العبارة فيه، فأخذ يتردد على الشيخ محمد مراد، فجوّد عليه القرآن وبدأ يحفظ. ومرّت الأيام، فزار متجر والده العلامة الشيخ محمد نجيب خياطة، فلما رآه وسمعه حثّه على حفظ القرآن، فحفظه برواية حفص عليه، وأجازه الشيخ.\n\nثم انطلق يصدح بالقرآن هنا وهناك، ومما زاده نبوغًا على نبوغه التزامه بمجالس الذكر والعلم عند الشيخ عبد القادر عيسى رحمه الله، فكان المقدّم عنده في القراءة. ودارت السنون ليجد نفسه بين يدي الشيخ محمد ديب الشهيد رحمه الله، يتلقى عليه الشاطبية، فحفظها وجمع عليه القراءات السبع، وأجازه بها.\n\nوله شيوخ في نواحٍ شتى: في التربية الشيخ عبد القادر عيسى، وفي التجويد الشيخ محمد مراد، وفي حفظ القرآن الشيخ عبد الحميد بدور، وفي القراءات السبع الشيخ محمد ديب الشهيد.\n\nولما تصدّر للإقراء منذ أن حفظ القرآن برواية حفص، لم يتوقف سيل التلاميذ عليه، سواء في محلّه أمام جامع الترمانيني، أو في الجوامع، ولا سيما جامع العادلية، تحت رعاية شيخه الشيخ عبد القادر عيسى.\n\nوطلابه لا يُحصَون عددًا، أذكر منهم: الشيخ محمد نديم الشهابي، الشيخ محمود ديري، الشيخ محمود شحيبر، الشيخ مصطفى جليلاتي، الشيخ عمار بازرباشي، زياد محمد حموية، وكثير غيرهم.\n\nولما التقى بشيخ الإسلام سيدي الشيخ عبد الله سراج الدين قال له: أهل القرآن هم أولياء الله تعالى، وإذا لم يكن أهل القرآن هم الأولياء فليس لله ولي. وكان أحباب الشيخ أحمد كراسي رحمه الله كثيرًا ما ينادونه (حج أحمد)، فقال له سيدي شيخ الإسلام عبد الله سراج الدين: أنت (الشيخ أحمد).\n\nوشيخنا شيخ القرّاء رحمه الله تعالى صاحب كرمٍ وعطاء، وذو شمائل طيبة، أبرزها التواضع، ولين الجانب، وصفاء السريرة، وشدّة الحياء، والنصح للمسلمين. وله أثر يشهد له بالقراءة الجيدة، وجمال وعذوبة الصوت، وحسن الأداء. وله تسجيل كامل للقرآن الكريم بصوته العذب.\n\nوكان يتطلّع دائمًا إلى أن يمدّ الله في عمره، ليقرئ عددًا أكبر، ويخدم كتاب الله أكثر، حتى يلقى ربّه عز وجل بألف حافظ لكتابه سبحانه.\n\nتوفي في آخر يوم من عام 1429هـ، في 30/12/1429هـ الموافق 28/12/2008م، ودُفن يوم الإثنين في مقبرة جبل العظام بحلب.\n\nجزاه الله عنا وعن المسلمين خير الجزاء، وبلّغه وإيانا في الآخرة منازل الشهداء، وحشرنا معه يوم الدين تحت لواء سيد الأنبياء وإمام المرسلين صلى الله عليه وسلم.'**
  String get scholarBioDescription;

  /// No description provided for @studyHubNav.
  ///
  /// In ar, this message translates to:
  /// **'المحفوظات'**
  String get studyHubNav;

  /// No description provided for @studyHubTitle.
  ///
  /// In ar, this message translates to:
  /// **'المحفوظات الذكية'**
  String get studyHubTitle;

  /// No description provided for @studyHubTagsTab.
  ///
  /// In ar, this message translates to:
  /// **'العلامات'**
  String get studyHubTagsTab;

  /// No description provided for @studyHubNotesTab.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات الآيات'**
  String get studyHubNotesTab;

  /// No description provided for @studyHubNoTags.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد علامات بعد'**
  String get studyHubNoTags;

  /// No description provided for @studyHubNoNotes.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ملاحظات آيات بعد'**
  String get studyHubNoNotes;

  /// No description provided for @studyHubTagReview.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة'**
  String get studyHubTagReview;

  /// No description provided for @studyHubTagHifz.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get studyHubTagHifz;

  /// No description provided for @studyHubTagTadabbur.
  ///
  /// In ar, this message translates to:
  /// **'تدبر'**
  String get studyHubTagTadabbur;

  /// No description provided for @studyHubItemsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} عنصر'**
  String studyHubItemsCount(int count);

  /// No description provided for @studyHubNotesCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} ملاحظة'**
  String studyHubNotesCount(int count);

  /// No description provided for @studyHubPageLabel.
  ///
  /// In ar, this message translates to:
  /// **'صفحة {page}'**
  String studyHubPageLabel(int page);

  /// No description provided for @studySettingsSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'الدراسة والتقدم'**
  String get studySettingsSectionTitle;

  /// No description provided for @studyGoalsEntryTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأهداف والتقارير'**
  String get studyGoalsEntryTitle;

  /// No description provided for @studyGoalsEntrySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'يومي/أسبوعي للآيات والصفحات ودقائق الاستماع'**
  String get studyGoalsEntrySubtitle;

  /// No description provided for @goalsPageTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأهداف والتقدم'**
  String get goalsPageTitle;

  /// No description provided for @goalsSetDialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الهدف'**
  String get goalsSetDialogTitle;

  /// No description provided for @goalsSetDialogHint.
  ///
  /// In ar, this message translates to:
  /// **'ادخل الهدف الرقمي'**
  String get goalsSetDialogHint;

  /// No description provided for @goalsTargetDailyWeeklyTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأهداف اليومية/الأسبوعية'**
  String get goalsTargetDailyWeeklyTitle;

  /// No description provided for @goalsProgressReportTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقرير التقدم'**
  String get goalsProgressReportTitle;

  /// No description provided for @goalsNoGoalsYet.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم إنشاء أهداف بعد.'**
  String get goalsNoGoalsYet;

  /// No description provided for @goalsDailyButton.
  ///
  /// In ar, this message translates to:
  /// **'هدف يومي'**
  String get goalsDailyButton;

  /// No description provided for @goalsWeeklyButton.
  ///
  /// In ar, this message translates to:
  /// **'هدف أسبوعي'**
  String get goalsWeeklyButton;

  /// No description provided for @goalMetricAyahs.
  ///
  /// In ar, this message translates to:
  /// **'الآيات'**
  String get goalMetricAyahs;

  /// No description provided for @goalMetricPages.
  ///
  /// In ar, this message translates to:
  /// **'الصفحات'**
  String get goalMetricPages;

  /// No description provided for @goalMetricListeningMinutes.
  ///
  /// In ar, this message translates to:
  /// **'دقائق الاستماع'**
  String get goalMetricListeningMinutes;

  /// No description provided for @goalPeriodDaily.
  ///
  /// In ar, this message translates to:
  /// **'يومي'**
  String get goalPeriodDaily;

  /// No description provided for @goalPeriodWeekly.
  ///
  /// In ar, this message translates to:
  /// **'أسبوعي'**
  String get goalPeriodWeekly;

  /// No description provided for @ayahActionCopyWithTashkeel.
  ///
  /// In ar, this message translates to:
  /// **'نسخ مع التشكيل'**
  String get ayahActionCopyWithTashkeel;

  /// No description provided for @ayahActionCopyWithoutTashkeel.
  ///
  /// In ar, this message translates to:
  /// **'نسخ بدون تشكيل'**
  String get ayahActionCopyWithoutTashkeel;

  /// No description provided for @ayahActionShareAsText.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة كنص'**
  String get ayahActionShareAsText;

  /// No description provided for @ayahActionShareAsImage.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة الآية كصورة'**
  String get ayahActionShareAsImage;

  /// No description provided for @ayahActionTempHighlightAdd.
  ///
  /// In ar, this message translates to:
  /// **'تمييز لوني مؤقت (20 ثانية)'**
  String get ayahActionTempHighlightAdd;

  /// No description provided for @ayahActionTempHighlightRemove.
  ///
  /// In ar, this message translates to:
  /// **'إزالة التمييز المؤقت'**
  String get ayahActionTempHighlightRemove;

  /// No description provided for @ayahActionReviewLaterAdd.
  ///
  /// In ar, this message translates to:
  /// **'تمييز للمراجعة لاحقًا'**
  String get ayahActionReviewLaterAdd;

  /// No description provided for @ayahActionReviewLaterRemove.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء تمييز المراجعة لاحقًا'**
  String get ayahActionReviewLaterRemove;

  /// No description provided for @ayahActionPlaySurahInPlayer.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل السورة في المشغل'**
  String get ayahActionPlaySurahInPlayer;

  /// No description provided for @ayahActionShowTafsir.
  ///
  /// In ar, this message translates to:
  /// **'إظهار تفسير الآية'**
  String get ayahActionShowTafsir;

  /// No description provided for @ayahColoringSection.
  ///
  /// In ar, this message translates to:
  /// **'تلوين الآية'**
  String get ayahColoringSection;

  /// No description provided for @ayahActionAdvancedTag.
  ///
  /// In ar, this message translates to:
  /// **'إضافة علامة متقدمة'**
  String get ayahActionAdvancedTag;

  /// No description provided for @ayahActionAddNote.
  ///
  /// In ar, this message translates to:
  /// **'إضافة ملاحظة على الآية'**
  String get ayahActionAddNote;

  /// No description provided for @ayahActionShowNotes.
  ///
  /// In ar, this message translates to:
  /// **'عرض ملاحظات الآية'**
  String get ayahActionShowNotes;

  /// No description provided for @ayahActionRecitationTest.
  ///
  /// In ar, this message translates to:
  /// **'اختبار تسميع تفاعلي'**
  String get ayahActionRecitationTest;

  /// No description provided for @ayahActionToggleHideAyah.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء/إظهار الآية'**
  String get ayahActionToggleHideAyah;

  /// No description provided for @ayahActionAyahHidden.
  ///
  /// In ar, this message translates to:
  /// **'تم إخفاء الآية. اضغط مطولًا عليها لإظهارها'**
  String get ayahActionAyahHidden;

  /// No description provided for @ayahActionAyahShown.
  ///
  /// In ar, this message translates to:
  /// **'تم إظهار الآية'**
  String get ayahActionAyahShown;

  /// No description provided for @ayahActionTagSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ العلامة المتقدمة'**
  String get ayahActionTagSaved;

  /// No description provided for @ayahActionNoteDialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة على الآية'**
  String get ayahActionNoteDialogTitle;

  /// No description provided for @ayahActionNoteDialogHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب ملاحظة قصيرة'**
  String get ayahActionNoteDialogHint;

  /// No description provided for @ayahActionNoteSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الملاحظة'**
  String get ayahActionNoteSaved;

  /// No description provided for @ayahActionNoNotesForAyah.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ملاحظات لهذه الآية'**
  String get ayahActionNoNotesForAyah;

  /// No description provided for @ayahActionRecitationModeProgressive.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء تدريجي للكلمات'**
  String get ayahActionRecitationModeProgressive;

  /// No description provided for @ayahActionRecitationModeFirstWord.
  ///
  /// In ar, this message translates to:
  /// **'عرض أول كلمة فقط'**
  String get ayahActionRecitationModeFirstWord;

  /// No description provided for @ayahActionRecitationModeTapReveal.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء الآية وإظهارها بالضغط'**
  String get ayahActionRecitationModeTapReveal;

  /// No description provided for @ayahActionRecitationTapToRevealHint.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على الآية لإظهارها'**
  String get ayahActionRecitationTapToRevealHint;

  /// No description provided for @ayahActionRecitationTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختبار تسميع'**
  String get ayahActionRecitationTitle;

  /// No description provided for @ayahActionRecitationResultTitle.
  ///
  /// In ar, this message translates to:
  /// **'نتيجة الاختبار'**
  String get ayahActionRecitationResultTitle;

  /// No description provided for @ayahActionRecitationHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب الآية كما تحفظها'**
  String get ayahActionRecitationHint;

  /// No description provided for @ayahActionRecitationScore.
  ///
  /// In ar, this message translates to:
  /// **'النتيجة: {score}%'**
  String ayahActionRecitationScore(int score);

  /// No description provided for @ayahActionTempReviewRemoved.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء تمييز الآية للمراجعة لاحقًا'**
  String get ayahActionTempReviewRemoved;

  /// No description provided for @ayahActionTempReviewAdded.
  ///
  /// In ar, this message translates to:
  /// **'تم تمييز الآية للمراجعة لاحقًا'**
  String get ayahActionTempReviewAdded;

  /// No description provided for @ayahActionTagReview.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة'**
  String get ayahActionTagReview;

  /// No description provided for @ayahActionTagHifz.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get ayahActionTagHifz;

  /// No description provided for @ayahActionTagTadabbur.
  ///
  /// In ar, this message translates to:
  /// **'تدبر'**
  String get ayahActionTagTadabbur;

  /// No description provided for @ayahShareImageError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إنشاء صورة الآية للمشاركة'**
  String get ayahShareImageError;

  /// No description provided for @unknownSurahName.
  ///
  /// In ar, this message translates to:
  /// **'سورة غير معروفة'**
  String get unknownSurahName;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @verify.
  ///
  /// In ar, this message translates to:
  /// **'تحقق'**
  String get verify;

  /// No description provided for @done.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get done;
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
