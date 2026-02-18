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
  String get settingsHeaderSubtitle => 'قم بضبط تفضيلاتك الشخصية لتجربة أفضل';

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
  String get soon => 'قريبًا';

  @override
  String get showVerseEndSymbol => 'إظهار علامة نهاية الآية';

  @override
  String get lastRead => 'آخر المقروء';

  @override
  String ayahNumber(Object ayah) {
    return 'الآية $ayah';
  }

  @override
  String get aya => 'آية';

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

  @override
  String get errorOccurred => 'حدث خطأ';

  @override
  String get back => 'رجوع';

  @override
  String get preparing => 'جاري التحضير...';

  @override
  String get noSurahSelected => 'لم يتم اختيار سورة';

  @override
  String get ready => 'جاهزة';

  @override
  String get confirmLoadSurah => 'تأكيد تحميل السورة';

  @override
  String get loadSurah => 'هل تريد تحميل';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get scholarTitle => 'الشيخ أحمد كراسي رحمه الله';

  @override
  String get scholarBioLabel => 'نبذة عن حياة شيخ قرّاء حلب';

  @override
  String get scholarBioDescription =>
      'نبذة عن حياة شيخ قرّاء حلب\n(القارئ المقرئ الشيخ أحمد كراسي رحمه الله)\n(ولد في عام 1924م ـ وتوفي في عام 2008م)\n\nهو الشيخ المقرئ ذو الصوت القوي والنغم الجميل، والمخارج السليمة، والقراءة الفصيحة، الحسيب النسيب، فضيلة الشيخ أحمد كراسي بن عبد السلام.\n\nولد في حي الفرافرة عام (1924م / 1343هـ). ولما بلغ من العمر السادسة عشرة، زوّجه أبوه، وأكرمه الله بذكورٍ وإناثٍ صالحين، أكبرهم الحاج عبد السلام حفظه الله.\n\nعاش رحمه الله في بيئة محفوفة بالعلم والصلاح، فمنذ نعومة أظفاره لم يبارح مرافقة والده لمجالس الذكر والعلم، ومساعدته في عمله بتجارة الأخشاب.\n\nولبداية أخذه القرآن حكاية؛ إذ كان يومًا في زيارة للشيخ محمد مراد برفقة والده، فطلب منه الشيخ أن يقرأ ولو من قصار السور، فقرأ شيئًا من ذلك. فلما انتهى قال السيد محمد النسر ـ وكان من بين الحاضرين ـ: إن هذا الشاب عنده استعداد لحفظ كلام الله تعالى، وخلقته تساعده.\n\nفأثّرت هذه العبارة فيه، فأخذ يتردد على الشيخ محمد مراد، فجوّد عليه القرآن وبدأ يحفظ. ومرّت الأيام، فزار متجر والده العلامة الشيخ محمد نجيب خياطة، فلما رآه وسمعه حثّه على حفظ القرآن، فحفظه برواية حفص عليه، وأجازه الشيخ.\n\nثم انطلق يصدح بالقرآن هنا وهناك، ومما زاده نبوغًا على نبوغه التزامه بمجالس الذكر والعلم عند الشيخ عبد القادر عيسى رحمه الله، فكان المقدّم عنده في القراءة. ودارت السنون ليجد نفسه بين يدي الشيخ محمد ديب الشهيد رحمه الله، يتلقى عليه الشاطبية، فحفظها وجمع عليه القراءات السبع، وأجازه بها.\n\nوله شيوخ في نواحٍ شتى: في التربية الشيخ عبد القادر عيسى، وفي التجويد الشيخ محمد مراد، وفي حفظ القرآن الشيخ عبد الحميد بدور، وفي القراءات السبع الشيخ محمد ديب الشهيد.\n\nولما تصدّر للإقراء منذ أن حفظ القرآن برواية حفص، لم يتوقف سيل التلاميذ عليه، سواء في محلّه أمام جامع الترمانيني، أو في الجوامع، ولا سيما جامع العادلية، تحت رعاية شيخه الشيخ عبد القادر عيسى.\n\nوطلابه لا يُحصَون عددًا، أذكر منهم: الشيخ محمد نديم الشهابي، الشيخ محمود ديري، الشيخ محمود شحيبر، الشيخ مصطفى جليلاتي، الشيخ عمار بازرباشي، زياد محمد حموية، وكثير غيرهم.\n\nولما التقى بشيخ الإسلام سيدي الشيخ عبد الله سراج الدين قال له: أهل القرآن هم أولياء الله تعالى، وإذا لم يكن أهل القرآن هم الأولياء فليس لله ولي. وكان أحباب الشيخ أحمد كراسي رحمه الله كثيرًا ما ينادونه (حج أحمد)، فقال له سيدي شيخ الإسلام عبد الله سراج الدين: أنت (الشيخ أحمد).\n\nوشيخنا شيخ القرّاء رحمه الله تعالى صاحب كرمٍ وعطاء، وذو شمائل طيبة، أبرزها التواضع، ولين الجانب، وصفاء السريرة، وشدّة الحياء، والنصح للمسلمين. وله أثر يشهد له بالقراءة الجيدة، وجمال وعذوبة الصوت، وحسن الأداء. وله تسجيل كامل للقرآن الكريم بصوته العذب.\n\nوكان يتطلّع دائمًا إلى أن يمدّ الله في عمره، ليقرئ عددًا أكبر، ويخدم كتاب الله أكثر، حتى يلقى ربّه عز وجل بألف حافظ لكتابه سبحانه.\n\nتوفي في آخر يوم من عام 1429هـ، في 30/12/1429هـ الموافق 28/12/2008م، ودُفن يوم الإثنين في مقبرة جبل العظام بحلب.\n\nجزاه الله عنا وعن المسلمين خير الجزاء، وبلّغه وإيانا في الآخرة منازل الشهداء، وحشرنا معه يوم الدين تحت لواء سيد الأنبياء وإمام المرسلين صلى الله عليه وسلم.';

  @override
  String get studyHubNav => 'المحفوظات';

  @override
  String get studyHubTitle => 'المحفوظات الذكية';

  @override
  String get studyHubTagsTab => 'العلامات';

  @override
  String get studyHubNotesTab => 'ملاحظات الآيات';

  @override
  String get studyHubNoTags => 'لا توجد علامات بعد';

  @override
  String get studyHubNoNotes => 'لا توجد ملاحظات آيات بعد';

  @override
  String get studyHubTagReview => 'مراجعة';

  @override
  String get studyHubTagHifz => 'حفظ';

  @override
  String get studyHubTagTadabbur => 'تدبر';

  @override
  String studyHubItemsCount(int count) {
    return '$count عنصر';
  }

  @override
  String studyHubNotesCount(int count) {
    return '$count ملاحظة';
  }

  @override
  String studyHubPageLabel(int page) {
    return 'صفحة $page';
  }

  @override
  String get studySettingsSectionTitle => 'الدراسة والتقدم';

  @override
  String get studyGoalsEntryTitle => 'الأهداف والتقارير';

  @override
  String get studyGoalsEntrySubtitle =>
      'يومي/أسبوعي للآيات والصفحات ودقائق الاستماع';

  @override
  String get goalsPageTitle => 'الأهداف والتقدم';

  @override
  String get goalsSetDialogTitle => 'تحديد الهدف';

  @override
  String get goalsSetDialogHint => 'ادخل الهدف الرقمي';

  @override
  String get goalsTargetDailyWeeklyTitle => 'الأهداف اليومية/الأسبوعية';

  @override
  String get goalsProgressReportTitle => 'تقرير التقدم';

  @override
  String get goalsNoGoalsYet => 'لم يتم إنشاء أهداف بعد.';

  @override
  String get goalsDailyButton => 'هدف يومي';

  @override
  String get goalsWeeklyButton => 'هدف أسبوعي';

  @override
  String get goalMetricAyahs => 'الآيات';

  @override
  String get goalMetricPages => 'الصفحات';

  @override
  String get goalMetricListeningMinutes => 'دقائق الاستماع';

  @override
  String get goalPeriodDaily => 'يومي';

  @override
  String get goalPeriodWeekly => 'أسبوعي';

  @override
  String get ayahActionCopyWithTashkeel => 'نسخ مع التشكيل';

  @override
  String get ayahActionCopyWithoutTashkeel => 'نسخ بدون تشكيل';

  @override
  String get ayahActionShareAsText => 'مشاركة كنص';

  @override
  String get ayahActionShareAsImage => 'مشاركة الآية كصورة';

  @override
  String get ayahActionTempHighlightAdd => 'تمييز لوني مؤقت (20 ثانية)';

  @override
  String get ayahActionTempHighlightRemove => 'إزالة التمييز المؤقت';

  @override
  String get ayahActionReviewLaterAdd => 'تمييز للمراجعة لاحقًا';

  @override
  String get ayahActionReviewLaterRemove => 'إلغاء تمييز المراجعة لاحقًا';

  @override
  String get ayahActionPlaySurahInPlayer => 'تشغيل السورة في المشغل';

  @override
  String get ayahActionShowTafsir => 'إظهار تفسير الآية';

  @override
  String get ayahColoringSection => 'تلوين الآية';

  @override
  String get ayahActionAdvancedTag => 'إضافة علامة متقدمة';

  @override
  String get ayahActionAddNote => 'إضافة ملاحظة على الآية';

  @override
  String get ayahActionShowNotes => 'عرض ملاحظات الآية';

  @override
  String get ayahActionRecitationTest => 'اختبار تسميع تفاعلي';

  @override
  String get ayahActionToggleHideAyah => 'إخفاء/إظهار الآية';

  @override
  String get ayahActionAyahHidden =>
      'تم إخفاء الآية. اضغط مطولًا عليها لإظهارها';

  @override
  String get ayahActionAyahShown => 'تم إظهار الآية';

  @override
  String get ayahActionTagSaved => 'تم حفظ العلامة المتقدمة';

  @override
  String get ayahActionNoteDialogTitle => 'ملاحظة على الآية';

  @override
  String get ayahActionNoteDialogHint => 'اكتب ملاحظة قصيرة';

  @override
  String get ayahActionNoteSaved => 'تم حفظ الملاحظة';

  @override
  String get ayahActionNoNotesForAyah => 'لا توجد ملاحظات لهذه الآية';

  @override
  String get ayahActionRecitationModeProgressive => 'إخفاء تدريجي للكلمات';

  @override
  String get ayahActionRecitationModeFirstWord => 'عرض أول كلمة فقط';

  @override
  String get ayahActionRecitationModeTapReveal => 'إخفاء الآية وإظهارها بالضغط';

  @override
  String get ayahActionRecitationTapToRevealHint => 'اضغط على الآية لإظهارها';

  @override
  String get ayahActionRecitationTitle => 'اختبار تسميع';

  @override
  String get ayahActionRecitationResultTitle => 'نتيجة الاختبار';

  @override
  String get ayahActionRecitationHint => 'اكتب الآية كما تحفظها';

  @override
  String ayahActionRecitationScore(int score) {
    return 'النتيجة: $score%';
  }

  @override
  String get ayahActionTempReviewRemoved =>
      'تم إلغاء تمييز الآية للمراجعة لاحقًا';

  @override
  String get ayahActionTempReviewAdded => 'تم تمييز الآية للمراجعة لاحقًا';

  @override
  String get ayahActionTagReview => 'مراجعة';

  @override
  String get ayahActionTagHifz => 'حفظ';

  @override
  String get ayahActionTagTadabbur => 'تدبر';

  @override
  String get ayahShareImageError => 'تعذر إنشاء صورة الآية للمشاركة';

  @override
  String get unknownSurahName => 'سورة غير معروفة';

  @override
  String get save => 'حفظ';

  @override
  String get close => 'إغلاق';

  @override
  String get verify => 'تحقق';

  @override
  String get done => 'تم';
}
