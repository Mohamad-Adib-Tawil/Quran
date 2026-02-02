import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_library/quran_library.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audio_session/audio_session.dart';

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // TODO: Forward to crash reporting service if integrated
  };
  await runZonedGuarded(() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    await QuranLibrary.init();
    await setupLocator();
    runApp(const QuranApp());
  }, (Object error, StackTrace stack) {
    // TODO: Forward to crash reporting service if integrated
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
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return ScreenUtilInit(
            designSize: const Size(390, 844), // iPhone 12-like baseline
            minTextAdapt: true,
            builder: (context, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'القرآن الكريم',
                theme: AppTheme.light(),
                darkTheme: AppTheme.dark(),
                themeMode: settings.themeMode,
                locale: settings.localeCode != null ? Locale(settings.localeCode!) : null,
                supportedLocales: const [
                  Locale('ar'),
                  Locale('de'),
                  Locale('en'),
                ],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                builder: (context, child) {
                  final scale = settings.fontScale;
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
