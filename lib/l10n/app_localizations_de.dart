// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Der Heilige Koran';

  @override
  String get tabSurahs => 'Suren';

  @override
  String get tabJuz => 'Abschnitte';

  @override
  String get tabHizb => 'Hizb';

  @override
  String get indexTab => 'Inhalt';

  @override
  String get bookmarksTab => 'Lesezeichen';

  @override
  String get searchTab => 'Suche';

  @override
  String get copied => 'Kopiert';

  @override
  String get hizbName => 'Hizb';

  @override
  String get juzName => 'Juz';

  @override
  String get sajdaName => 'Sadschda';

  @override
  String get manageAudio => 'Audio verwalten';

  @override
  String get favoritesTitle => 'Favoriten';

  @override
  String get noFavorites => 'Noch keine Favoriten';

  @override
  String favSurahNumber(Object s) {
    return 'Sure Nr. $s';
  }

  @override
  String errorPlaySurah(Object e) {
    return 'Wiedergabe fehlgeschlagen: $e';
  }

  @override
  String get removeFromFavorites => 'Aus Favoriten entfernen';

  @override
  String get addToFavorites => 'Mit Stern markieren';

  @override
  String get chooseLanguage => 'Sprache auswählen';

  @override
  String get arabic => 'Arabisch';

  @override
  String get german => 'Deutsch';

  @override
  String get settings => 'Einstellungen';

  @override
  String get appearance => 'Darstellung';

  @override
  String get light => 'Hell';

  @override
  String get dark => 'Dunkel';

  @override
  String get system => 'System';

  @override
  String get language => 'Sprache';

  @override
  String get fontSize => 'Schriftgröße';

  @override
  String get soon => 'Bald verfügbar';

  @override
  String get showVerseEndSymbol => 'Versende-Zeichen anzeigen';

  @override
  String get lastRead => 'Zuletzt gelesen';

  @override
  String ayahNumber(Object ayah) {
    return 'Vers $ayah';
  }

  @override
  String get madani => 'Medinensisch';

  @override
  String get makki => 'Mekkanisch';

  @override
  String get details => 'Details';

  @override
  String get read => 'Lesen';

  @override
  String get surahNumberLabel => 'Suren-Nummer';

  @override
  String get name => 'Name';

  @override
  String get searchSurahHint => 'Suche nach einer Sure';

  @override
  String get downloads => 'Downloads';

  @override
  String get mushaf => 'Mushaf';

  @override
  String get downloadedTab => 'Heruntergeladen';

  @override
  String get notDownloadedTab => 'Nicht heruntergeladen';

  @override
  String get noDownloaded => 'Keine heruntergeladenen Suren';

  @override
  String get noNotDownloaded => 'Keine nicht heruntergeladenen Suren';

  @override
  String get play => 'Abspielen';

  @override
  String get delete => 'Löschen';

  @override
  String get deleteSuccess => 'Sure gelöscht';

  @override
  String get download => 'Herunterladen';

  @override
  String get downloadingSurah => 'Sure wird heruntergeladen...';

  @override
  String get unexpectedError => 'Unerwarteter Fehler';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get previous => 'Zurück';

  @override
  String get pause => 'Pause';

  @override
  String get stop => 'Stopp';

  @override
  String get next => 'Weiter';
}
