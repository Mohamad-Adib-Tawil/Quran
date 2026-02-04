import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/core/theme/figma_palette.dart';
import 'package:quran_app/core/theme/figma_typography.dart';
import 'package:quran_app/core/theme/design_tokens.dart';
import 'package:quran_app/features/quran/presentation/navigation/quran_open_target.dart';
import 'package:quran_app/features/quran/presentation/pages/surah_list_page.dart';
import 'package:quran_library/quran_library.dart';
import 'package:quran_app/core/assets/app_assets.dart';

class SurahDetailsPage extends StatelessWidget {
  final int surahNumber; // 1-based
  const SurahDetailsPage({super.key, required this.surahNumber});

  @override
  Widget build(BuildContext context) {
    final info = QuranLibrary().getSurahInfo(surahNumber: surahNumber - 1);
    return Scaffold(
      appBar: AppBar(title: Text(info.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeaderCard(surahNumber: surahNumber, title: info.name),
          const SizedBox(height: 16),
          _PrimaryAction(
            label: 'القراءة',
            iconPath: AppAssets.icQuranGreen,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SurahListPage(openTarget: QuranOpenTarget.surah(surahNumber)),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _InfoTile(title: 'رقم السورة', value: '$surahNumber'),
          const Divider(height: 1, color: FigmaPalette.divider),
          _InfoTile(title: 'الاسم', value: info.name),
          const Divider(height: 1, color: FigmaPalette.divider),
          // ملاحظات: يمكن توسيع التفاصيل (عدد الآيات/مكية-مدنية) عند توفر API دقيق من quran_library
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final int surahNumber;
  final String title;
  const _HeaderCard({required this.surahNumber, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: const LinearGradient(
          colors: [FigmaPalette.primary, FigmaPalette.primaryDark],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: AppShadows.soft(FigmaPalette.primary),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('$surahNumber', style: FigmaTypography.title18(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: FigmaTypography.title19(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          SvgPicture.asset(AppAssets.icPlayMini, width: 28, height: 28, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
        ],
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  final String label;
  final String iconPath;
  final VoidCallback onTap;
  const _PrimaryAction({required this.label, required this.iconPath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: FigmaPalette.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.l)),
        ),
        onPressed: onTap,
        icon: SvgPicture.asset(iconPath, width: 20, height: 20, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
        label: Text(label, style: FigmaTypography.body15(color: Colors.white)),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;
  const _InfoTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text(title, style: FigmaTypography.body13(color: Theme.of(context).hintColor))),
          Text(value, style: FigmaTypography.body15(color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }
}
