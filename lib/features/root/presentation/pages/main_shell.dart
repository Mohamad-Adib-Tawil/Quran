import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/features/home/presentation/pages/home_screen.dart';
import 'package:quran_app/features/audio/presentation/pages/audio_downloads_page.dart';
import 'package:quran_app/features/favorites/presentation/pages/favorites_page.dart';
import 'package:quran_app/core/localization/app_localization_ext.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/core/assets/app_assets.dart';
import 'package:quran_app/features/audio/presentation/widgets/mini_player.dart';
import 'package:quran_app/features/audio/presentation/cubit/audio_cubit.dart';
import 'package:quran_app/features/audio/presentation/cubit/audio_state.dart';
import 'package:quran_app/features/study/presentation/pages/study_hub_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 3; // default tab is Home
  final _pages = const [
    StudyHubPage(),
    FavoritesPage(),
    AudioDownloadsPage(),
    HomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    return BlocListener<AudioCubit, AudioState>(
      listenWhen: (prev, curr) =>
          curr.phase == AudioPhase.error &&
          prev.phase != AudioPhase.error &&
          curr.errorKind == AudioErrorKind.network,
      listener: (ctx, state) {
        ScaffoldMessenger.of(ctx)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            duration: const Duration(seconds: 5),
            backgroundColor: const Color(0xFF0CAF60),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'لا يوجد اتصال بالإنترنت',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            action: SnackBarAction(
              label: 'إعادة المحاولة',
              textColor: Colors.white,
              onPressed: () => ctx.read<AudioCubit>().retry(),
            ),
          ));
      },
      child: Scaffold(
      body: _pages[_index],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini Player - يظهر فقط عند التشغيل النشط
          const MiniAudioPlayer(hideWhenIdle: true, debugTag: 'MainShell'),

          // Bottom Navigation Bar
          NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              overlayColor: WidgetStatePropertyAll(Colors.transparent),
            ),
            child: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                NavigationDestination(
                  icon: SvgPicture.asset(
                    AppAssets.icBookmarkSaved,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                  ),
                  selectedIcon: SvgPicture.asset(
                    AppAssets.icBookmarkSaved,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: t.studyHubNav,
                ),
                NavigationDestination(
                  icon: SvgPicture.asset(
                    AppAssets.icStarGray,
                    width: 24,
                    height: 24,
                  ),
                  selectedIcon: SvgPicture.asset(
                    AppAssets.icStarGreen,
                    width: 24,
                    height: 24,
                  ),
                  label: t.favoritesTitle,
                ),
                NavigationDestination(
                  icon: SvgPicture.asset(
                    AppAssets.icDownloadGray,
                    width: 24,
                    height: 24,
                  ),
                  selectedIcon: SvgPicture.asset(
                    AppAssets.icDownloadGreen,
                    width: 24,
                    height: 24,
                  ),
                  label: t.manageAudio,
                ),
                NavigationDestination(
                  icon: SvgPicture.asset(
                    AppAssets.icQuranGray,
                    width: 24,
                    height: 24,
                  ),
                  selectedIcon: SvgPicture.asset(
                    AppAssets.icQuranGreen,
                    width: 24,
                    height: 24,
                  ),
                  label: t.appTitle,
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
