import 'package:flutter/material.dart';
import 'package:quran_app/core/theme/figma_typography.dart';
import 'package:quran_app/core/localization/app_localization_ext.dart';

class HomeTabBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeTabBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final scheme = Theme.of(context).colorScheme;
    return TabBar(
      labelStyle: FigmaTypography.body15(),
      unselectedLabelStyle: FigmaTypography.body15(),
      labelColor: scheme.primary,
      unselectedLabelColor: scheme.onSurface.withValues(alpha: 0.65),
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(width: 3, color: scheme.primary),
        insets: const EdgeInsets.symmetric(horizontal: 20),
      ),
      tabs: [
        Tab(text: t.tabSurahs),
        Tab(text: t.tabJuz),
        Tab(text: t.tabHizb),
      ],
    );
  }
}
