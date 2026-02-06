import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_library/quran_library.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audio_session/audio_session.dart';
import 'core/localization/localization_service.dart';
import 'core/localization/app_localization_ext.dart';

import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/cubit/settings_cubit.dart';
import 'features/settings/cubit/settings_state.dart';
import 'features/quran/presentation/cubit/quran_cubit.dart';
import 'features/audio/presentation/cubit/audio_cubit.dart';
import 'features/audio/domain/repositories/audio_download_repository.dart';
import 'features/audio/domain/repositories/audio_repository.dart' as audio_domain;
import 'features/splash/presentation/pages/app_splash_page.dart';
import 'services/audio_url_catalog_service.dart';
import 'services/audio_session_manager.dart';
import 'features/audio/settings/audio_settings_cubit.dart';
import 'features/audio/settings/audio_settings_service.dart';
import 'core/logging/logging.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    await QuranLibrary.init();
    await setupLocator();
    // Hook crash reporting after DI ready
    final crash = sl<CrashReporter>();
    FlutterError.onError = (FlutterErrorDetails details) async {
      FlutterError.presentError(details);
      await crash.recordFlutterError(details);
    };
    runApp(const QuranApp());
  }, (Object error, StackTrace stack) async {
    // Forward to crash reporting service
    try {
      final crash = sl<CrashReporter>();
      await crash.recordError(error, stack);
    } catch (_) {}
  });
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsCubit(sl())),
        BlocProvider(create: (_) => QuranCubit(sl())),
        BlocProvider(create: (_) {
          final cubit = AudioCubit(
            sl<audio_domain.AudioRepository>(),
            sl<AudioDownloadRepository>(),
            sl<AudioUrlCatalogService>(),
          );
          // Attach and restore last session (non-blocking)
          final session = sl<AudioSessionManager>();
          session.attach(cubit);
          session.restoreIfNeeded(cubit);
          return cubit;
        }),
        BlocProvider(create: (ctx) => AudioSettingsCubit(sl<AudioSettingsService>(), ctx.read<AudioCubit>())),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return ScreenUtilInit(
            designSize: const Size(390, 844), // iPhone 12-like baseline
            minTextAdapt: true,
            builder: (context, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                onGenerateTitle: (ctx) => ctx.tr.appTitle,
                theme: AppTheme.light(),
                darkTheme: AppTheme.dark(),
                themeMode: settings.themeMode,
                locale: LocalizationService.localeFromCode(settings.localeCode),
                supportedLocales: LocalizationService.supportedLocales,
                localizationsDelegates: LocalizationService.localizationsDelegates,
                builder: (context, child) {
                  // Freeze font scale feature temporarily
                  const scale = 1.0;
                  final mq = MediaQuery.of(context);
                  return MediaQuery(
                    data: mq.copyWith(textScaler: TextScaler.linear(scale)),
                    child: child ?? const SizedBox.shrink(),
                  );
                },
                home: const AppSplashPage(),
              );
            },
          );
        },
      ),
    );
  }
}
