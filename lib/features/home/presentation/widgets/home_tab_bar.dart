import 'package:flutter/material.dart';
import 'package:quran/core/theme/figma_palette.dart';
import 'package:quran/core/theme/figma_typography.dart';

class HomeTabBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeTabBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TabBar(
      labelStyle: FigmaTypography.body15(),
      unselectedLabelStyle: FigmaTypography.body15(),
      labelColor: scheme.onSurface,
      unselectedLabelColor: scheme.onSurface.withValues(alpha: 0.7),
      indicator: UnderlineTabIndicator(
        borderSide: const BorderSide(width: 3, color: FigmaPalette.primary),
        insets: const EdgeInsets.symmetric(horizontal: 24),
      ),
      tabs: const [
        Tab(text: 'السور'),
        Tab(text: 'الأجزاء'),
        Tab(text: 'الأحزاب'),
      ],
    );
  }
}
