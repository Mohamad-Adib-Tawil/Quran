import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_library/quran_library.dart';

import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/cubit/settings_cubit.dart';
import 'features/settings/cubit/settings_state.dart';
import 'features/quran/presentation/pages/surah_list_page.dart';
import 'features/quran/presentation/cubit/quran_cubit.dart';
import 'features/audio/presentation/cubit/audio_cubit.dart';
import 'features/audio/domain/repositories/audio_download_repository.dart';
import 'features/audio/domain/repositories/audio_repository.dart' as audio_domain;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await QuranLibrary.init();
  await setupLocator();
  runApp(const QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsCubit(sl())),
        BlocProvider(create: (_) => QuranCubit(sl())),
        BlocProvider(create: (_) => AudioCubit(
              sl<audio_domain.AudioRepository>(),
              sl<AudioDownloadRepository>(),
            )),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'القرآن الكريم',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.themeMode,
            home: const SurahListPage(),
          );
        },
      ),
    );
  }
}
