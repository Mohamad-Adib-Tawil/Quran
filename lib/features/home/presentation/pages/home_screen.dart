import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_library/quran_library.dart';

import '../../../audio/presentation/widgets/mini_player.dart';
import '../../../quran/presentation/pages/surah_list_page.dart';
import '../../../quran/presentation/navigation/quran_open_target.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import 'package:quran_app/services/last_read_service.dart';
import 'package:quran_app/core/di/service_locator.dart';
import 'package:quran_app/features/home/presentation/widgets/last_read_card.dart';
import 'package:quran_app/features/home/presentation/widgets/home_tab_bar.dart';
import 'package:quran_app/features/quran/presentation/widgets/list/surah_list_item.dart';
import 'package:quran_app/features/quran/presentation/widgets/list/list_divider.dart';
import 'package:quran_app/features/quran/presentation/widgets/list/juz_list_item.dart';
import '../../../quran/presentation/pages/surah_details_page.dart';
import '../../../quran/presentation/cubit/quran_cubit.dart';
import '../../../quran/presentation/cubit/quran_state.dart' as qs;
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import 'package:quran_app/services/favorites_service.dart';
import 'package:quran_app/features/audio/presentation/cubit/audio_cubit.dart';
import 'package:quran_app/core/localization/app_localization_ext.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/core/assets/app_assets.dart';

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
  Set<int> _favorites = <int>{};
  bool _searching = false;
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _lastRead = sl<LastReadService>().getLastRead();
    // Load favorites once on start
    _favorites = sl<FavoritesService>().getFavorites().toSet();
    _searchCtrl = TextEditingController()
      ..addListener(() {
        if (!mounted) return;
        context.read<HomeCubit>().setQuery(_searchCtrl.text);
      });
  }

  Future<void> _setLastRead(int surah, int ayah) async {
    await sl<LastReadService>().setLastRead(surah: surah, ayah: ayah);
    if (!mounted) return;
    setState(() => _lastRead = LastRead(surah: surah, ayah: ayah));
  }

  Future<void> _toggleFavorite(int surah) async {
    final favs = await sl<FavoritesService>().toggle(surah);
    if (!mounted) return;
    setState(() => _favorites = favs.toSet());
  }

  bool _isFavorite(int surah) => _favorites.contains(surah);

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              title: _searching
                  ? TextField(
                      controller: _searchCtrl,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: t.searchSurahHint,
                        border: InputBorder.none,
                      ),
                    )
                  : Text(t.appTitle),
              pinned: true,
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _searching = !_searching;
                      if (!_searching) {
                        _searchCtrl.clear();
                        context.read<HomeCubit>().setQuery('');
                      }
                    });
                  },
                  icon: SvgPicture.asset(AppAssets.icSearch, width: 22, height: 22),
                  tooltip: t.searchSurahHint,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SettingsPage(),
                      ),
                    );
                  },
                  icon: SvgPicture.asset(AppAssets.icSettingsGreen, width: 22, height: 22),
                  tooltip: t.settings,
                ),
                IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(AppAssets.icMenu, width: 22, height: 22),
                ),
              ],
            ),
            if (_lastRead != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                  child: LastReadCard(surah: _lastRead!.surah, ayah: _lastRead!.ayah),
                ),
              ),
            const SliverToBoxAdapter(
              child: Material(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: MiniAudioPlayer(),
                ),
              ),
            ),
            // Removed always-visible search field; search is toggled in AppBar now
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(const HomeTabBar()),
            ),
          ],
          body: TabBarView(
            children: [
              // Surahs tab
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  final numbers = state.filteredSurahs;
                  return BlocBuilder<QuranCubit, qs.QuranState>(
                    builder: (context, qState) {
                      final meta = qState.surahs;
                      return ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: numbers.length,
                        separatorBuilder: (context, index) => const ListDivider(),
                        itemBuilder: (ctx, i) {
                          final s = numbers[i];
                          final localeCode = Localizations.localeOf(context).languageCode;
                          String titleAr;
                          String titleLatin;
                          String? subtitleAr;
                          String? subtitleLatin;
                          if (meta.isNotEmpty && s - 1 < meta.length) {
                            final m = meta[s - 1];
                            titleAr = m.nameArabic;
                            titleLatin = m.nameEnglish;
                            final isMadani = m.revelation.toLowerCase().contains('mad');
                            final revLocalized = isMadani ? t.madani : t.makki;
                            final verseWord = localeCode == 'de' ? 'Verse' : localeCode == 'ar' ? 'آية' : 'Verses';
                            subtitleAr = '$revLocalized • ${m.verseCount} آية';
                            subtitleLatin = '${m.verseCount} $verseWord • $revLocalized';
                          } else {
                            final info = QuranLibrary().getSurahInfo(surahNumber: s - 1);
                            titleAr = info.name;
                            titleLatin = 'Surah ${s.toString().padLeft(3, '0')}';
                            subtitleAr = null;
                            subtitleLatin = null;
                          }
                          // In AR locale: show Arabic + English; in DE: Arabic + German (fallback to English until dataset is provided).
                          return SurahListItem(
                            surahNumber: s,
                            titleAr: titleAr,
                            titleLatin: titleLatin,
                            subtitleAr: subtitleAr,
                            subtitleLatin: subtitleLatin,
                            onTap: () {
                              if (!ctx.mounted) return;
                              _setLastRead(s, 1);
                              context.read<AudioCubit>().selectSurah(s);
                              Navigator.of(ctx).push(
                                MaterialPageRoute(
                                  builder: (_) => SurahListPage(openTarget: QuranOpenTarget.surah(s)),
                                ),
                              );
                            },
                            onLongPress: () {
                              if (!ctx.mounted) return;
                              Navigator.of(ctx).push(
                                MaterialPageRoute(
                                  builder: (_) => SurahDetailsPage(surahNumber: s),
                                ),
                              );
                            },
                            onInfo: () {
                              if (!ctx.mounted) return;
                              Navigator.of(ctx).push(
                                MaterialPageRoute(
                                  builder: (_) => SurahDetailsPage(surahNumber: s),
                                ),
                              );
                            },
                            trailing: IconButton(
                              tooltip: _isFavorite(s) ? t.removeFromFavorites : t.addToFavorites,
                              icon: SvgPicture.asset(
                                _isFavorite(s) ? AppAssets.icStarGreen : AppAssets.icStarGray,
                                width: 24,
                                height: 24,
                              ),
                              onPressed: () => _toggleFavorite(s),
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
                padding: EdgeInsets.zero,
                itemCount: QuranLibrary.allJoz.length,
                separatorBuilder: (context, index) => const ListDivider(),
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
                padding: EdgeInsets.zero,
                itemCount: QuranLibrary.allHizb.length,
                separatorBuilder: (context, index) => const ListDivider(),
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
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final PreferredSizeWidget tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
