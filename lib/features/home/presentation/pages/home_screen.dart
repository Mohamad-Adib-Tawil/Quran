import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_library/quran_library.dart';

import '../../../audio/presentation/widgets/mini_player.dart';
import '../../../quran/presentation/pages/surah_list_page.dart';
import '../../../quran/presentation/navigation/quran_open_target.dart';
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

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Der Koran'),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Suren'),
              Tab(text: 'Teile'),
              Tab(text: 'Hizb'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Mini player header
            const Material(elevation: 2, child: Padding(padding: EdgeInsets.all(8), child: MiniAudioPlayer())),
            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'ابحث عن سورة',
                  border: OutlineInputBorder(),
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
                        title: Text('Juz ${i + 1}'),
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
                        title: Text('Hizb ${i + 1}'),
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
