# Feature: Quran Reader

## What it does
عرض سور القرآن الكريم (نص + تشكيل)، التنقل بين السور/الأجزاء/الأحزاب، التكامل مع مكتبة `quran_library`.

## File Map
```
lib/features/quran/
├── data/
│   ├── datasources/
│   │   └── quran_local_data_source.dart    — يقرأ بيانات السور من حزمة quran
│   └── repositories/
│       └── quran_repository_impl.dart      — impl لـ QuranRepository
├── domain/
│   ├── entities/
│   │   └── surah.dart                      — entity بسيطة: id, name, verseCount, type
│   └── repositories/
│       └── quran_repository.dart           — abstract: getSurahVerses / getAllSurahs
├── presentation/
│   ├── cubit/
│   │   ├── quran_cubit.dart                — load/next/prev surah&ayah، يُهيّأ في main.dart
│   │   └── quran_state.dart                — QuranState: surahs[], verses[], currentSurah, currentAyah
│   ├── navigation/
│   │   └── quran_open_target.dart          — sealed class: SurahTarget | JuzTarget | HizbTarget
│   ├── pages/
│   │   ├── quran_surah_page.dart           — 🔥 صفحة القراءة الحقيقية (quran_library widget)
│   │   ├── reader_page.dart                — ⚠️ STUB فارغ — لا تستخدمه
│   │   └── surah_details_page.dart         — تفاصيل السورة + زر التشغيل
│   └── widgets/
│       └── list/
│           ├── surah_list_item.dart         — عنصر قائمة السورة
│           ├── juz_list_item.dart           — عنصر قائمة الجزء
│           ├── list_divider.dart            — فاصل زخرفي
│           └── number_star_badge.dart       — شارة رقم السورة
└── CLAUDE.md
```

## Key Classes
| Class | File | Responsibility |
|-------|------|----------------|
| `QuranCubit` | cubit/quran_cubit.dart | تحميل الكتالوج + التنقل بين السور والآيات |
| `QuranState` | cubit/quran_state.dart | `surahs`, `verses`, `currentSurah`, `currentAyah` |
| `QuranOpenTarget` | navigation/quran_open_target.dart | sealed class للـ deep navigation |
| `QuranSurahPage` | pages/quran_surah_page.dart | صفحة القراءة الفعلية |

## Key Methods (QuranCubit)
| Method | What it does |
|--------|-------------|
| `loadSurah(int)` | يحمّل آيات السورة ويُعيد الكيوبيت لأول آية |
| `loadCatalog()` | يحمّل قائمة كل السور (يُستدعى في constructor) |
| `nextSurah() / prevSurah()` | التنقل مع verseEndSymbol |
| `jumpToAyah(int)` | الذهاب لآية محددة |

## Known Issues
- [ ] `reader_page.dart` — stub فارغ تمامًا، يجب أن يُعيد redirect إلى `QuranSurahPage`
- [ ] لا يوجد deep linking أو GoRouter — كل navigation يدوي

## Dependencies
- **يستخدم:** حزمة `quran ^1.4.1` + `quran_library ^2.3.3` (local path override في pubspec)
- **يُستخدَم من:** `HomeScreen` (فتح سورة)، `SurahDetailsPage`، `AudioCubit` (sync السورة)
- **Navigation target:** `QuranOpenTarget` — تمريره لـ `QuranSurahPage` عبر constructor

## Last Updated
2026-06-27 — initial memory generation
