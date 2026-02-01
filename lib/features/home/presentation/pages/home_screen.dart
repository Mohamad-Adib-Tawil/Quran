import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_library/quran_library.dart';

import '../../../audio/presentation/widgets/mini_player.dart';
import '../../../quran/presentation/pages/surah_list_page.dart';
import '../../../quran/presentation/navigation/quran_open_target.dart';
import '../../../settings/presentation/pages/language_select_page.dart';
import 'package:quran/core/theme/design_tokens.dart';
import 'package:quran/services/last_read_service.dart';
import 'package:quran/core/di/service_locator.dart';
import 'package:quran/core/theme/app_colors.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeCubit>(
      create: (_) => HomeCubit(),
      child: const _HomeView(),
    );
  }
}

class _LastReadCard extends StatelessWidget {
  final LastRead lastRead;
  const _LastReadCard({required this.lastRead});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = QuranLibrary().getSurahInfo(surahNumber: lastRead.surah - 1);
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SurahListPage(openTarget: QuranOpenTarget.surah(lastRead.surah)),
          ),
        );
      },
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          boxShadow: AppShadows.soft(AppColors.primary),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('آخر المقروء', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white70)),
                  const SizedBox(height: 6),
                  Text(info.name, style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('الآية ${lastRead.ayah}', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
                ],
              ),
            ),
            const Icon(Icons.play_circle_fill, color: Colors.white, size: 36),
          ],
        ),
      ),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  LastRead? _lastRead;

  @override
  void initState() {
    super.initState();
    _lastRead = sl<LastReadService>().getLastRead();
  }

  Future<void> _setLastRead(int surah, int ayah) async {
    await sl<LastReadService>().setLastRead(surah: surah, ayah: ayah);
    if (!mounted) return;
    setState(() => _lastRead = LastRead(surah: surah, ayah: ayah));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('القرآن الكريم'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LanguageSelectPage(),
                  ),
                );
              },
              icon: const Icon(Icons.settings),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'السور'),
              Tab(text: 'الأجزاء'),
              Tab(text: 'الأحزاب'),
            ],
          ),
        ),
        body: Column(
          children: [
            if (_lastRead != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                child: _LastReadCard(lastRead: _lastRead!),
              ),
            // Mini player header
            const Material(elevation: 2, child: Padding(padding: EdgeInsets.all(8), child: MiniAudioPlayer())),
            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'ابحث عن سورة',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.l),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) => context.read<HomeCubit>().setQuery(v),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Surahs tab
                  BlocBuilder<HomeCubit, HomeState>(
                    builder: (context, state) {
                      final surahs = state.filteredSurahs;
                      return ListView.separated(
                        itemCount: surahs.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final s = surahs[i];
                          final info = QuranLibrary().getSurahInfo(surahNumber: s - 1);
                          return ListTile(
                            leading: CircleAvatar(child: Text('$s')),
                            title: Text(info.name),
                            subtitle: Text(info.name),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () async {
                              if (!ctx.mounted) return;
                              _setLastRead(s, 1); // fire-and-forget to avoid async gap with context usage
                              Navigator.of(ctx).push(
                                MaterialPageRoute(
                                  builder: (_) => SurahListPage(
                                    openTarget: QuranOpenTarget.surah(s),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  // Juz tab
                  ListView.separated(
                    itemCount: QuranLibrary.allJoz.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final j = QuranLibrary.allJoz[i];
                      return ListTile(
                        leading: const Icon(Icons.menu_book_outlined),
                        title: Text('الجزء ${i + 1}'),
                        subtitle: Text(j),
                        onTap: () async {
                          if (!ctx.mounted) return;
                          Navigator.of(ctx).push(
                            MaterialPageRoute(
                              builder: (_) => SurahListPage(
                                openTarget: QuranOpenTarget.juz(i + 1),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // Hizb tab (quarters)
                  ListView.separated(
                    itemCount: QuranLibrary.allHizb.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final h = QuranLibrary.allHizb[i];
                      return ListTile(
                        leading: const Icon(Icons.view_week_outlined),
                        title: Text('الحزب ${i + 1}'),
                        subtitle: Text(h),
                        onTap: () async {
                          if (!ctx.mounted) return;
                          Navigator.of(ctx).push(
                            MaterialPageRoute(
                              builder: (_) => SurahListPage(
                                openTarget: QuranOpenTarget.hizb(i + 1),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
