# Quran App - Offline-First Quran Reader & Audio Platform (Multilingual: English, Arabic, German)

### Language Selector / محدد اللغة / Sprachauswahl
**[English](#english-section)** | **[العربية](#arabisch-section--القسم-العربي)** | **[Deutsch](#deutsch-section--القسم-الألماني)**

## English Section

### Project Overview
This is a comprehensive Quran application built with Flutter, designed as an offline-first Quran reader and audio platform. The app provides a seamless experience for reading the Holy Quran, listening to recitations, and managing personal preferences. It supports Arabic, English, and German languages, offering a multilingual interface for a global audience.

### Features
- **Quran Reading**: Display all 114 Surahs with Arabic text, verse-by-verse navigation, and customizable font sizes.
- **Audio Playback**: Integrated audio player for listening to Quran recitations by renowned reciters like Sheikh Ahmed Al-Kuraysi. Supports offline downloads for uninterrupted listening.
- **Offline-First Architecture**: Download audio files for offline access, with robust caching and retry mechanisms.
- **Settings Management**: Customize theme (light/dark/system), font scale, and verse end symbols.
- **Clean Architecture**: Implements feature-based Clean Architecture with clear separation of data, domain, and presentation layers.
- **Dependency Injection**: Uses GetIt for centralized service locator and dependency management.
- **State Management**: Powered by BLoC (Cubit) for predictable and testable UI state handling.
- **Material Design 3**: Modern UI with responsive design, animations, and gesture-driven interactions.
- **Localization**: Full support for Arabic, English, and German with gen-l10n for typed localization accessors.
- **Background Downloads**: Efficient downloading of audio files with progress tracking and error handling.
- **Sharing and Copying**: Share verses or copy text for external use.
- **Favorites and Bookmarks**: Mark favorite Surahs and resume reading from last position.
- **Search Functionality**: Search through Surahs, verses, and content.
- **Accessibility**: Designed with accessibility in mind, including screen reader support.

### Tech Stack
- **Framework**: Flutter (Dart)
- **Architecture**: Clean Architecture (data/domain/presentation layers)
- **State Management**: flutter_bloc (Cubit)
- **Dependency Injection**: get_it
- **Audio**: just_audio, audio_session
- **Persistence**: shared_preferences, flutter_cache_manager
- **Downloads**: background_downloader
- **UI Libraries**: google_fonts, flutter_svg, flutter_screenutil, sliding_up_panel
- **Localization**: intl, gen-l10n
- **Quran Data**: quran_library, quran package
- **Other**: equatable, path_provider, share_plus, cupertino_icons

### Architecture
The app follows a feature-based Clean Architecture:
- **Presentation Layer**: UI components, Cubits for state management, screens like QuranSurahPage, MiniAudioPlayer.
- **Domain Layer**: Business logic, entities (e.g., Surah), repositories interfaces (QuranRepository, AudioRepository).
- **Data Layer**: Data sources (local/remote), repository implementations, API calls or file reads.
- **Core Layer**: Dependency injection (service_locator.dart), themes, utilities.

All layers are decoupled, making the codebase scalable, testable, and maintainable.

### Installation and Running
1. **Prerequisites**: Flutter SDK ^3.10.3, Dart, Android Studio or Xcode for platform-specific builds.
2. **Clone the Repository**: Download or clone the project.
3. **Install Dependencies**:
   ```bash
   flutter pub get
   ```
4. **Run the App**:
   ```bash
   flutter run
   ```
5. **Build for Platforms**: Use `flutter build apk` for Android, `flutter build ios` for iOS, etc.
6. **Supported Platforms**: Android, iOS, Web, Desktop (Linux, macOS, Windows).

### Contributing
- Follow the project's coding standards and architecture guidelines.
- Use Arabic for UI text where appropriate, English for code comments.
- Test thoroughly on multiple platforms and screen sizes.

---

## Arabisch Section / القسم العربي

### نظرة عامة على المشروع
هذا تطبيق قرآن كريم شامل مبني بـ Flutter، مصمم كقارئ قرآن أولاً عبر الإنترنت مع منصة صوتية. يوفر التطبيق تجربة سلسة لقراءة القرآن الكريم، الاستماع إلى التلاوات، وإدارة الإعدادات الشخصية. يدعم اللغات العربية والإنجليزية والألمانية، مما يقدم واجهة متعددة اللغات لجمهور عالمي.

### الميزات
- **قراءة القرآن**: عرض جميع السور الـ 114 بالنص العربي، تنقل آية بآية، وحجم خط قابل للتخصيص.
- **تشغيل الصوت**: مشغل صوت متكامل للاستماع إلى تلاوات القرآن من قبل قارئين مشهورين مثل الشيخ أحمد الكراسي. يدعم التحميل للاستماع دون اتصال.
- **الهيكل أولاً عبر الإنترنت**: تحميل ملفات الصوت للوصول دون اتصال، مع آليات تخزين مؤقت قوية وإعادة محاولة.
- **إدارة الإعدادات**: تخصيص الثيم (فاتح/داكن/نظام)، حجم الخط، ورموز نهاية الآيات.
- **هيكل نظيف**: ينفذ هيكل نظيف قائم على الميزات مع فصل واضح لطبقات البيانات والنطاق والعرض.
- **حقن الاعتمادية**: استخدام GetIt لإدارة الخدمات المركزية وحقن الاعتمادية.
- **إدارة الحالة**: مدعوم بـ BLoC (Cubit) للتعامل مع حالة واجهة المستخدم القابلة للتنبؤ والاختبار.
- **تصميم المواد 3**: واجهة حديثة مع تصميم متجاوب، رسوم متحركة، وتفاعلات مدفوعة بالإيماءات.
- **التعريب**: دعم كامل للعربية والإنجليزية والألمانية مع gen-l10n للوصول المكتوب إلى التعريب.
- **التحميلات الخلفية**: تحميل فعال لملفات الصوت مع تتبع التقدم ومعالجة الأخطاء.
- **المشاركة والنسخ**: مشاركة الآيات أو نسخ النص للاستخدام الخارجي.
- **المفضلة والعلامات**: وضع علامة على السور المفضلة واستئناف القراءة من الموضع الأخير.
- **البحث**: البحث في السور والآيات والمحتوى.
- **الوصولية**: مصمم مع مراعاة الوصولية، بما في ذلك دعم قارئ الشاشة.

### التقنيات المستخدمة
- **الإطار**: Flutter (Dart)
- **الهيكل**: هيكل نظيف (طبقات البيانات/النطاق/العرض)
- **إدارة الحالة**: flutter_bloc (Cubit)
- **حقن الاعتمادية**: get_it
- **الصوت**: just_audio, audio_session
- **الاستمرارية**: shared_preferences, flutter_cache_manager
- **التحميلات**: background_downloader
- **مكتبات واجهة المستخدم**: google_fonts, flutter_svg, flutter_screenutil, sliding_up_panel
- **التعريب**: intl, gen-l10n
- **بيانات القرآن**: quran_library, حزمة quran
- **أخرى**: equatable, path_provider, share_plus, cupertino_icons

### الهيكل
يتبع التطبيق هيكل نظيف قائم على الميزات:
- **طبقة العرض**: مكونات واجهة المستخدم، Cubits لإدارة الحالة، شاشات مثل QuranSurahPage، MiniAudioPlayer.
- **طبقة النطاق**: منطق الأعمال، كيانات (مثل Surah)، واجهات المستودعات (QuranRepository, AudioRepository).
- **طبقة البيانات**: مصادر البيانات (محلية/بعيدة)، تنفيذات المستودعات، استدعاءات API أو قراءة ملفات.
- **طبقة النواة**: حقن الاعتمادية (service_locator.dart)، الثيمات، الأدوات.

جميع الطبقات مفصولة، مما يجعل قاعدة الكود قابلة للتوسع والاختبار والصيانة.

### التثبيت والتشغيل
1. **المتطلبات**: Flutter SDK ^3.10.3, Dart, Android Studio أو Xcode لبناء المنصات المحددة.
2. **استنساخ المستودع**: تحميل أو استنساخ المشروع.
3. **تثبيت الاعتماديات**:
   ```bash
   flutter pub get
   ```
4. **تشغيل التطبيق**:
   ```bash
   flutter run
   ```
5. **البناء للمنصات**: استخدام `flutter build apk` لأندرويد، `flutter build ios` لآي أو إس، إلخ.
6. **المنصات المدعومة**: أندرويد، آي أو إس، الويب، سطح المكتب (لينكس، ماك أو إس، ويندوز).

### المساهمة
- اتبع معايير البرمجة وإرشادات الهيكل للمشروع.
- استخدم العربية لنصوص واجهة المستخدم حيث يناسب، والإنجليزية لتعليقات الكود.
- اختبر بشكل شامل على منصات متعددة وأحجام شاشات مختلفة.

---

## Deutsch Section / القسم الألماني

### Projektübersicht
Dies ist eine umfassende Quran-Anwendung, die mit Flutter entwickelt wurde und als Offline-First-Quran-Leser und Audio-Plattform konzipiert ist. Die App bietet eine nahtlose Erfahrung für das Lesen des Heiligen Qurans, das Hören von Rezitationen und die Verwaltung persönlicher Vorlieben. Sie unterstützt Arabisch, Englisch und Deutsch und bietet eine mehrsprachige Oberfläche für ein globales Publikum.

### Funktionen
- **Quran-Lesen**: Anzeige aller 114 Suren mit arabischem Text, Vers-für-Vers-Navigation und anpassbaren Schriftgrößen.
- **Audio-Wiedergabe**: Integrierter Audio-Player zum Hören von Quran-Rezitationen von bekannten Rezitatoren wie Scheich Ahmed Al-Kuraysi. Unterstützt Offline-Downloads für unterbrechungsfreies Hören.
- **Offline-First-Architektur**: Herunterladen von Audio-Dateien für Offline-Zugang mit robustem Caching und Wiederholungsmechanismen.
- **Einstellungsverwaltung**: Anpassung des Themas (hell/dunkel/system), Schriftgröße und Vers-Endsymbole.
- **Saubere Architektur**: Implementiert funktionsbasierte Clean Architecture mit klarer Trennung von Daten-, Domain- und Präsentationsschichten.
- **Dependency Injection**: Verwendet GetIt für zentralisiertes Service-Locator und Dependency-Management.
- **State-Management**: Unterstützt durch BLoC (Cubit) für vorhersehbare und testbare UI-State-Verarbeitung.
- **Material Design 3**: Moderne UI mit responsivem Design, Animationen und gestenbasierten Interaktionen.
- **Lokalisierung**: Vollständige Unterstützung für Arabisch, Englisch und Deutsch mit gen-l10n für typisierte Lokalisierungs-Zugriffe.
- **Hintergrund-Downloads**: Effizientes Herunterladen von Audio-Dateien mit Fortschrittsverfolgung und Fehlerbehandlung.
- **Teilen und Kopieren**: Verse teilen oder Text für externe Verwendung kopieren.
- **Favoriten und Lesezeichen**: Favorisierte Suren markieren und Lesen von der letzten Position fortsetzen.
- **Suchfunktion**: Suche durch Suren, Verse und Inhalt.
- **Barrierefreiheit**: Entwickelt mit Barrierefreiheit im Blick, einschließlich Screenreader-Unterstützung.

### Tech-Stack
- **Framework**: Flutter (Dart)
- **Architektur**: Clean Architecture (Daten/Domain/Präsentationsschichten)
- **State-Management**: flutter_bloc (Cubit)
- **Dependency Injection**: get_it
- **Audio**: just_audio, audio_session
- **Persistenz**: shared_preferences, flutter_cache_manager
- **Downloads**: background_downloader
- **UI-Bibliotheken**: google_fonts, flutter_svg, flutter_screenutil, sliding_up_panel
- **Lokalisierung**: intl, gen-l10n
- **Quran-Daten**: quran_library, quran-Paket
- **Andere**: equatable, path_provider, share_plus, cupertino_icons

### Architektur
Die App folgt einer funktionsbasierten Clean Architecture:
- **Präsentationsschicht**: UI-Komponenten, Cubits für State-Management, Bildschirme wie QuranSurahPage, MiniAudioPlayer.
- **Domain-Schicht**: Geschäftslogik, Entitäten (z.B. Surah), Repository-Schnittstellen (QuranRepository, AudioRepository).
- **Daten-Schicht**: Datenquellen (lokal/entfernt), Repository-Implementierungen, API-Aufrufe oder Datei-Lesevorgänge.
- **Core-Schicht**: Dependency Injection (service_locator.dart), Themes, Utilities.

Alle Schichten sind entkoppelt, was den Code skalierbar, testbar und wartbar macht.

### Installation und Ausführung
1. **Voraussetzungen**: Flutter SDK ^3.10.3, Dart, Android Studio oder Xcode für plattformspezifische Builds.
2. **Repository klonen**: Projekt herunterladen oder klonen.
3. **Abhängigkeiten installieren**:
   ```bash
   flutter pub get
   ```
4. **App ausführen**:
   ```bash
   flutter run
   ```
5. **Für Plattformen bauen**: Verwende `flutter build apk` für Android, `flutter build ios` für iOS, etc.
6. **Unterstützte Plattformen**: Android, iOS, Web, Desktop (Linux, macOS, Windows).

### Mitwirken
- Befolge die Coding-Standards und Architektur-Richtlinien des Projekts.
- Verwende Arabisch für UI-Texte, wo passend, und Englisch für Code-Kommentare.
- Teste gründlich auf mehreren Plattformen und Bildschirmgrößen.

---

## Documentation
- Arabic Guide: [PROJECT_GUIDE_AR.md](./PROJECT_GUIDE_AR.md)
