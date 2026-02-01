import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_library/quran_library.dart';

import '../../../audio/presentation/widgets/mini_player.dart';
import '../../../quran/presentation/pages/surah_list_page.dart';
import '../../../quran/presentation/navigation/quran_open_target.dart';
import '../../../settings/presentation/pages/language_select_page.dart';
import 'package:quran/services/last_read_service.dart';
import 'package:quran/core/di/service_locator.dart';
import 'package:quran/features/home/presentation/widgets/last_read_card.dart';
import 'package:quran/features/home/presentation/widgets/home_tab_bar.dart';
import 'package:quran/features/home/presentation/widgets/home_search_field.dart';
import 'package:quran/features/quran/presentation/widgets/list/surah_list_item.dart';
import 'package:quran/features/quran/presentation/widgets/list/list_divider.dart';
import 'package:quran/features/quran/presentation/widgets/list/juz_list_item.dart';
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
          bottom: const HomeTabBar(),
        ),
        body: Column(
          children: [
            if (_lastRead != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                child: LastReadCard(surah: _lastRead!.surah, ayah: _lastRead!.ayah),
              ),
            // Mini player header
            const Material(elevation: 2, child: Padding(padding: EdgeInsets.all(8), child: MiniAudioPlayer())),
            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: HomeSearchField(onChanged: (v) => context.read<HomeCubit>().setQuery(v)),
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
                        separatorBuilder: (_, __) => const ListDivider(),
                        itemBuilder: (ctx, i) {
                          final s = surahs[i];
                          final info = QuranLibrary().getSurahInfo(surahNumber: s - 1);
                          return SurahListItem(
                            surahNumber: s,
                            title: info.name,
                            subtitle: info.name,
                            onTap: () {
                              if (!ctx.mounted) return;
                              _setLastRead(s, 1);
                              Navigator.of(ctx).push(
                                MaterialPageRoute(
                                  builder: (_) => SurahListPage(openTarget: QuranOpenTarget.surah(s)),
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
                    separatorBuilder: (_, __) => const ListDivider(),
                    itemBuilder: (ctx, i) {
                      final j = QuranLibrary.allJoz[i];
                      return JuzListItem(
                        index: i + 1,
                        subtitle: j,
                        onTap: () {
                          if (!ctx.mounted) return;
                          Navigator.of(ctx).push(
                            MaterialPageRoute(
                              builder: (_) => SurahListPage(openTarget: QuranOpenTarget.juz(i + 1)),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // Hizb tab (quarters)
                  ListView.separated(
                    itemCount: QuranLibrary.allHizb.length,
                    separatorBuilder: (_, __) => const ListDivider(),
                    itemBuilder: (ctx, i) {
                      final h = QuranLibrary.allHizb[i];
                      return HizbListItem(
                        index: i + 1,
                        subtitle: h,
                        onTap: () {
                          if (!ctx.mounted) return;
                          Navigator.of(ctx).push(
                            MaterialPageRoute(
                              builder: (_) => SurahListPage(openTarget: QuranOpenTarget.hizb(i + 1)),
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
