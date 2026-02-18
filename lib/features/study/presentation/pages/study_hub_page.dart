import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/core/assets/app_assets.dart';
import 'package:quran_app/core/di/service_locator.dart';
import 'package:quran_app/core/localization/app_localization_ext.dart';
import 'package:quran_app/core/quran/surah_name_resolver.dart';
import 'package:quran_app/core/theme/figma_palette.dart';
import 'package:quran_app/core/theme/figma_typography.dart';
import 'package:quran_app/features/quran/presentation/navigation/quran_open_target.dart';
import 'package:quran_app/features/quran/presentation/pages/quran_surah_page.dart';
import 'package:quran_app/services/study_tools_service.dart';

class StudyHubPage extends StatefulWidget {
  const StudyHubPage({super.key});

  @override
  State<StudyHubPage> createState() => _StudyHubPageState();
}

class _StudyHubPageState extends State<StudyHubPage> {
  late final StudyToolsService _service;

  @override
  void initState() {
    super.initState();
    _service = sl<StudyToolsService>();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.studyHubTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: t.studyHubTagsTab),
              Tab(text: t.studyHubNotesTab),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _TagsTab(service: _service),
            _NotesTab(service: _service),
          ],
        ),
      ),
    );
  }
}

class _TagsTab extends StatelessWidget {
  final StudyToolsService service;
  const _TagsTab({required this.service});

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final all = service.getAllTags();
    if (all.isEmpty) {
      return _StudyEmptyState(
        title: t.studyHubNoTags,
        iconAsset: AppAssets.icBookmarkSaved,
      );
    }
    final grouped = <AyahTagType, List<AyahTagEntry>>{
      AyahTagType.review: [],
      AyahTagType.hifz: [],
      AyahTagType.tadabbur: [],
    };
    for (final item in all) {
      grouped[item.type]?.add(item);
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _TagSection(
          title: t.studyHubTagReview,
          icon: Icons.rate_review_outlined,
          iconColor: Colors.amber,
          items: grouped[AyahTagType.review]!,
        ),
        const SizedBox(height: 10),
        _TagSection(
          title: t.studyHubTagHifz,
          icon: Icons.auto_stories_outlined,
          iconColor: Colors.green,
          items: grouped[AyahTagType.hifz]!,
        ),
        const SizedBox(height: 10),
        _TagSection(
          title: t.studyHubTagTadabbur,
          icon: Icons.lightbulb_outline,
          iconColor: Colors.blue,
          items: grouped[AyahTagType.tadabbur]!,
        ),
      ],
    );
  }
}

class _TagSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<AyahTagEntry> items;
  const _TagSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final t = context.tr;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: scheme.surface,
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: FigmaTypography.body15(
                      color: scheme.onSurface,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: iconColor.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Text(
                    t.studyHubItemsCount(items.length),
                    style: FigmaTypography.caption12(color: scheme.onSurface),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...items.map((e) {
            final names = resolveSurahNamePair(e.surah);
            final date =
                '${e.createdAt.year}-${e.createdAt.month.toString().padLeft(2, '0')}-${e.createdAt.day.toString().padLeft(2, '0')}';
            return ListTile(
              leading: CircleAvatar(
                radius: 8,
                backgroundColor: Color(e.colorValue),
              ),
              title: Text(
                '${names.arabic} • الآية ${e.ayah}',
                style: GoogleFonts.notoNaskhArabic(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '${t.studyHubPageLabel(e.page)} • ${names.latin} • $date',
                style: FigmaTypography.latinBody15().copyWith(fontSize: 12),
              ),
              onTap: () => _openQuranAtPage(context, e.page),
            );
          }),
        ],
      ),
    );
  }
}

class _NotesTab extends StatelessWidget {
  final StudyToolsService service;
  const _NotesTab({required this.service});

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final grouped = service.getNotesGroupedBySurah();
    final surahs = grouped.keys.toList()..sort();
    if (surahs.isEmpty) {
      return _StudyEmptyState(
        title: t.studyHubNoNotes,
        iconAsset: AppAssets.icBookmarkSaved,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: surahs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final s = surahs[i];
        final names = resolveSurahNamePair(s);
        final notes = grouped[s]!
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(ctx).colorScheme.surface,
            border: Border.all(
              color: Theme.of(ctx).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: ExpansionTile(
            title: Text(
              names.arabic,
              style: GoogleFonts.notoNaskhArabic(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              '${names.latin} • ${t.studyHubNotesCount(notes.length)}',
              style: FigmaTypography.latinBody15().copyWith(fontSize: 12),
            ),
            children: notes.map((n) {
              final date =
                  '${n.createdAt.year}-${n.createdAt.month.toString().padLeft(2, '0')}-${n.createdAt.day.toString().padLeft(2, '0')}';
              return ListTile(
                title: Text(
                  n.text,
                  style: GoogleFonts.notoNaskhArabic(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  '${t.ayahNumber(n.ayah)} • ${t.studyHubPageLabel(n.page)} • $date',
                ),
                onTap: () => _openQuranAtPage(context, n.page),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _StudyEmptyState extends StatelessWidget {
  final String title;
  final String iconAsset;
  const _StudyEmptyState({required this.title, required this.iconAsset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  FigmaPalette.primary.withValues(alpha: 0.9),
                  FigmaPalette.primary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: SvgPicture.asset(
                iconAsset,
                width: 60,
                height: 60,
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: FigmaTypography.title18(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

Future<void> _openQuranAtPage(BuildContext context, int page) async {
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => QuranSurahPage(
        openTarget: QuranOpenTarget.page(page),
      ),
    ),
  );
}
