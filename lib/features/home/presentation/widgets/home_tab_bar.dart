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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        indicator: ShapeDecoration(
          color: scheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.zero,
        labelStyle: FigmaTypography.body15(color: Colors.white),
        unselectedLabelStyle: FigmaTypography.body15(color: scheme.primary),
        labelColor: Colors.white,
        unselectedLabelColor: scheme.primary,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: t.tabSurahs),
          Tab(text: t.tabJuz),
          Tab(text: t.tabHizb),
        ],
      ),
    );
  }
}
