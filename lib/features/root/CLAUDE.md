# Feature: Root / Shell

## What it does
الهيكل العام للتطبيق — Bottom Navigation بين الشاشات الرئيسية، تضمين MiniPlayer.

## File Map
```
lib/features/root/
└── presentation/
    └── pages/
        └── main_shell.dart   — Scaffold + BottomNavigationBar + MiniPlayer
```

## Navigation Tabs
| Index | Screen | Notes |
|-------|--------|-------|
| 0 | `HomeScreen` | قائمة السور/أجزاء/أحزاب |
| 1 | `FavoritesPage` | السور المفضّلة |
| 2 | `StudyHubPage` | مركز الدراسة |
| 3 | `SettingsPage` | الإعدادات |

## Notes
- `MiniPlayer` يظهر فوق الـ BottomNav فقط إذا كان `feature_flag('mini_player')` مُفعَّلاً
- الانتقال بين التبويبات: `setState(() => _index = i)` — بدون IndexedStack (يُعيد البناء)
- لا يوجد deep linking — كل navigation يدوي من هنا

## Dependencies
- **يستخدم:** `AudioCubit` (MiniPlayer)، `FeatureFlagsService`
- **يُستخدَم من:** `AppSplashPage` (يفتحه عند انتهاء Splash)

## Last Updated
2026-06-27 — initial memory generation
