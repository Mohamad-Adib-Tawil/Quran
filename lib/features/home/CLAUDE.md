# Feature: Home

## What it does
الشاشة الرئيسية — 3 تبويبات (سور / أجزاء / أحزاب)، بحث فوري، بطاقة آخر قراءة، فتح أي سورة في القارئ.

## File Map
```
lib/features/home/
├── presentation/
│   ├── cubit/
│   │   ├── home_cubit.dart     — بحث + فلترة (scoped داخل HomeScreen فقط)
│   │   └── home_state.dart     — HomeState: query, filteredSurahs, activeTab
│   └── pages/
│       └── home_screen.dart    — الشاشة الرئيسية + BlocProvider<HomeCubit>
│   └── widgets/
│       ├── home_search_field.dart  — حقل البحث
│       ├── home_segments.dart      — محتوى التبويبات الثلاثة
│       ├── home_tab_bar.dart       — شريط التبويبات
│       └── last_read_card.dart     — بطاقة آخر قراءة (تقرأ من LastReadService)
└── CLAUDE.md
```

## Key Classes
| Class | File | Responsibility |
|-------|------|----------------|
| `HomeCubit` | cubit/home_cubit.dart | `setQuery()` + فلترة السور — scoped، ليس في root |
| `HomeState` | cubit/home_state.dart | `query`, `filteredSurahs`, `activeTab` |
| `HomeScreen` | pages/home_screen.dart | يُنشئ `HomeCubit` بنفسه (ليس من DI) |
| `LastReadCard` | widgets/last_read_card.dart | يقرأ `LastReadService` مباشرة من `sl<>` |

## Notes
- `HomeCubit` ليس في `MultiBlocProvider` الجذر — يُنشأ فقط داخل شجرة `HomeScreen`
- البحث يعمل على كل السور (اسم عربي + إنجليزي + رقم)
- آخر قراءة: default = الفاتحة إذا لم يُسجَّل شيء

## Dependencies
- **يستخدم:** `QuranCubit` (قائمة السور)، `LastReadService` (آخر قراءة)، `AudioCubit` (تشغيل)
- **يُستخدَم من:** `MainShell` (tab index 0)

## Last Updated
2026-06-27 — initial memory generation
