import 'package:flutter/material.dart';

/// Placeholder screen kept for routing extensibility.
/// The actual Quran display is provided by QuranLibraryScreen.
class ReaderPage extends StatelessWidget {
  final int surahNumber;
  const ReaderPage({super.key, required this.surahNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('القرآن الكريم')),
      body: const SizedBox.shrink(),
    );
  }
}
