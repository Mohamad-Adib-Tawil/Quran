import 'package:flutter/material.dart';
import 'package:quran_app/core/theme/figma_palette.dart';
import 'package:quran_app/core/theme/figma_typography.dart';
import 'package:quran_library/quran_library.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/core/di/service_locator.dart';
import 'package:quran_app/services/favorites_service.dart';
import 'package:quran_app/features/audio/presentation/cubit/audio_cubit.dart';
import 'package:quran_app/core/localization/app_localization_ext.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late FavoritesService _service;
  List<int> _favorites = const [];

  @override
  void initState() {
    super.initState();
    _service = sl<FavoritesService>();
    _load();
  }

  void _load() {
    setState(() => _favorites = _service.getFavorites());
  }

  Future<void> _toggle(int surah) async {
    await _service.toggle(surah);
    if (!mounted) return;
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.favoritesTitle),
      ),
      body: _favorites.isEmpty
          ? Center(child: Text(t.noFavorites))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _favorites.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final s = _favorites[i];
                final info = QuranLibrary().getSurahInfo(surahNumber: s - 1);
                return _SurahCard(
                  title: info.name,
                  subtitle: t.favSurahNumber('$s'),
                  onPlay: () async {
                    try {
                      await context.read<AudioCubit>().playSurah(s);
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(t.errorPlaySurah('$e'))),
                      );
                    }
                  },
                  onMute: () => context.read<AudioCubit>().pause(),
                  trailing: IconButton(
                    tooltip: t.removeFromFavorites,
                    icon: const Icon(Icons.star, color: FigmaPalette.primary),
                    onPressed: () => _toggle(s),
                  ),
                );
              },
            ),
    );
  }
}

class _SurahCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onPlay;
  final VoidCallback onMute;
  final Widget trailing;
  const _SurahCard({required this.title, required this.subtitle, required this.onPlay, required this.onMute, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          _ChipIcon(icon: Icons.volume_off, color: Colors.grey, onTap: onMute),
          const SizedBox(width: 8),
          _ChipIcon(icon: Icons.play_arrow, color: FigmaPalette.primary, onTap: onPlay),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(title, style: FigmaTypography.body15(color: FigmaPalette.textDark)),
                const SizedBox(height: 4),
                Text(subtitle, style: FigmaTypography.caption12(color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}

class _ChipIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _ChipIcon({required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color),
      ),
    );
  }
}
