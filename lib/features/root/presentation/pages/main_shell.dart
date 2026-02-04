import 'package:flutter/material.dart';
import 'package:quran_app/features/home/presentation/pages/home_screen.dart';
import 'package:quran_app/features/audio/presentation/pages/audio_downloads_page.dart';
import 'package:quran_app/features/favorites/presentation/pages/favorites_page.dart';
import 'package:quran_app/core/localization/app_localization_ext.dart';

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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.star_border), selectedIcon: const Icon(Icons.star), label: t.favoritesTitle),
          NavigationDestination(icon: const Icon(Icons.download_outlined), selectedIcon: const Icon(Icons.download), label: t.manageAudio),
          NavigationDestination(icon: const Icon(Icons.menu_book_outlined), selectedIcon: const Icon(Icons.menu_book), label: t.appTitle),
        ],
      ),
    );
  }
}
