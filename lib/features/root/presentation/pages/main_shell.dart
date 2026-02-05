import 'package:flutter/material.dart';
import 'package:quran_app/features/home/presentation/pages/home_screen.dart';
import 'package:quran_app/features/audio/presentation/pages/audio_downloads_page.dart';
import 'package:quran_app/features/favorites/presentation/pages/favorites_page.dart';
import 'package:quran_app/core/localization/app_localization_ext.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/core/assets/app_assets.dart';
import 'package:quran_app/features/audio/presentation/widgets/mini_player.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 2; // default to Mushaf as per screenshots (right-most)
  final _pages = const [
    FavoritesPage(),
    AudioDownloadsPage(),
    HomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniAudioPlayer(),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            indicatorColor: Colors.transparent,
            destinations: [
              NavigationDestination(
                icon: SvgPicture.asset(AppAssets.icStarGray, width: 24, height: 24),
                selectedIcon: SvgPicture.asset(AppAssets.icStarGreen, width: 24, height: 24),
                label: t.favoritesTitle,
              ),
              NavigationDestination(
                icon: SvgPicture.asset(AppAssets.icDownloadGray, width: 24, height: 24),
                selectedIcon: SvgPicture.asset(AppAssets.icDownloadGreen, width: 24, height: 24),
                label: t.manageAudio,
              ),
              NavigationDestination(
                icon: SvgPicture.asset(AppAssets.icQuranGray, width: 24, height: 24),
                selectedIcon: SvgPicture.asset(AppAssets.icQuranGreen, width: 24, height: 24),
                label: t.appTitle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
