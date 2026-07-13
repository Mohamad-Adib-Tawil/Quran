# Feature: Settings

## What it does
إعدادات التطبيق — الثيم (فاتح/داكن/تلقائي)، اللغة (عربي/ألماني)، أهداف الدراسة.

## File Map
```
lib/features/settings/
├── cubit/
│   ├── settings_cubit.dart          — SettingsCubit: setTheme() + setLocale()
│   └── settings_state.dart          — SettingsState: themeMode, localeCode
└── presentation/
    └── pages/
        ├── settings_page.dart        — الصفحة الرئيسية للإعدادات
        ├── language_select_page.dart — اختيار اللغة
        └── goals_page.dart           — إعداد الأهداف اليومية/الأسبوعية
```

## Key Classes
| Class | Key Methods | Storage |
|-------|------------|---------|
| `SettingsCubit` | `setTheme(ThemeMode)`, `setLocale(String)` | SharedPreferences |
| `SettingsState` | `themeMode`, `localeCode` | — |

## Notes
- `SettingsCubit` في root `MultiBlocProvider` — متاح لكل الشجرة
- تغيير اللغة يُعيد بناء `MaterialApp` كاملاً عبر `BlocBuilder<SettingsCubit>`
- `goals_page.dart` تستخدم `StudyToolsService` مباشرة من `sl<>`

## Dependencies
- **يستخدم:** `SharedPreferences` (عبر SettingsCubit)، `StudyToolsService` (goals_page)
- **يُستخدَم من:** `MainShell` (tab الإعدادات)، `MaterialApp` (theme + locale)

## Last Updated
2026-06-27 — initial memory generation
