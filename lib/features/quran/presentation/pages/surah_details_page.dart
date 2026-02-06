import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/core/theme/figma_palette.dart';
import 'package:quran_app/core/theme/figma_typography.dart';
import 'package:quran_app/core/theme/design_tokens.dart';
import 'package:quran_app/features/quran/presentation/navigation/quran_open_target.dart';
import 'package:quran_app/features/quran/presentation/pages/surah_list_page.dart';
import 'package:quran_library/quran_library.dart';
import 'package:quran_app/core/assets/app_assets.dart';
import 'package:quran_app/core/di/service_locator.dart';
import 'package:quran_app/services/favorites_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/features/audio/presentation/cubit/audio_cubit.dart';

class SurahDetailsPage extends StatefulWidget {
  final int surahNumber; // 1-based
  const SurahDetailsPage({super.key, required this.surahNumber});

  @override
  State<SurahDetailsPage> createState() => _SurahDetailsPageState();
}

class _SurahDetailsPageState extends State<SurahDetailsPage> {
  bool _isFav = false;
  int? _firstAyahUQ;
  int? _firstPageIndex; // 0-based
  bool _loadingTafsir = true;

  @override
  void initState() {
    super.initState();
    _isFav = sl<FavoritesService>().isFavorite(widget.surahNumber);
    // حضّر معرّف الآية الأولى ورقم صفحتها للتفسير
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final qc = QuranCtrl.instance;
      if (qc.surahs.isEmpty || qc.ayahs.isEmpty) {
        // تهيئة بيانات القرآن إن لم تكن جاهزة
        await qc.loadQuranDataV1();
      }
      final uq = qc.getAyahUQBySurahAndAyah(widget.surahNumber, 1);
      int? pageIndex;
      if (uq != null) {
        try {
          final ayah = qc.ayahs.firstWhere((a) => a.ayahUQNumber == uq);
          pageIndex = (ayah.page - 1).clamp(0, 603);
        } catch (_) {}
      }
      if (!mounted) return;
      setState(() {
        _firstAyahUQ = uq;
        _firstPageIndex = pageIndex;
        _loadingTafsir = false;
      });
    });
  }

  Future<void> _toggleFav() async {
    final favs = await sl<FavoritesService>().toggle(widget.surahNumber);
    if (!mounted) return;
    setState(() => _isFav = favs.contains(widget.surahNumber));
  }

  @override
  Widget build(BuildContext context) {
    final info = QuranLibrary().getSurahInfo(surahNumber: widget.surahNumber - 1);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(info.name),
        actions: [
          IconButton(
            onPressed: _toggleFav,
            icon: SvgPicture.asset(_isFav ? AppAssets.icStarGreen : AppAssets.icStarGray, width: 22, height: 22),
            tooltip: _isFav ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeaderCard(surahNumber: widget.surahNumber, title: info.name),
          const SizedBox(height: 16),
          _PrimaryAction(
            label: 'القراءة',
            iconPath: AppAssets.icQuranGreen,
            onTap: () {
              // ✅ Sync mini player with opened surah
              context.read<AudioCubit>().selectSurah(widget.surahNumber);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SurahListPage(openTarget: QuranOpenTarget.surah(widget.surahNumber)),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _InfoTile(title: 'رقم السورة', value: '${widget.surahNumber}'),
          const Divider(height: 1, color: FigmaPalette.divider),
          _InfoTile(title: 'الاسم', value: info.name),
          const Divider(height: 1, color: FigmaPalette.divider),
          const SizedBox(height: 16),
          Text('التفسير', style: FigmaTypography.title18(color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 12),
          if (_loadingTafsir)
            const Center(child: CircularProgressIndicator())
          else if (_firstAyahUQ != null && _firstPageIndex != null)
            SizedBox(
              height: 360,
              child: TafsirPagesBuild(
                pageIndex: _firstPageIndex!,
                ayahUQNumber: _firstAyahUQ!,
                isDark: isDark,
              ),
            )
          else
            Text('تعذّر تحميل التفسير حاليًا', style: FigmaTypography.body13(color: Theme.of(context).hintColor)),
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
