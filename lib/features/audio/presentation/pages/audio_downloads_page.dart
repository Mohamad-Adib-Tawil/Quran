import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/core/theme/figma_palette.dart';
import 'package:quran_app/core/theme/figma_typography.dart';
import 'package:quran_library/quran_library.dart';
import 'package:quran_app/core/localization/app_localization_ext.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/core/assets/app_assets.dart';
import 'package:quran_app/features/settings/presentation/pages/settings_page.dart';

import '../../domain/repositories/audio_download_repository.dart';
import '../cubit/audio_download_cubit.dart';
import '../cubit/audio_download_state.dart';
import '../cubit/audio_cubit.dart';
import '../../../../core/di/service_locator.dart';

class AudioDownloadsPage extends StatelessWidget {
  const AudioDownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AudioDownloadCubit>(
      create: (_) => AudioDownloadCubit(sl()),
      child: const _AudioDownloadsView(),
    );
  }
}

class _AudioDownloadsView extends StatelessWidget {
  const _AudioDownloadsView();

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.manageAudio),
          actions: [
            // IconButton(
            //   onPressed: () {},
            //   icon: SvgPicture.asset(AppAssets.icSearch, width: 22, height: 22),
            //   tooltip: t.searchSurahHint,
            // ),
            IconButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
              },
              icon: SvgPicture.asset(
                AppAssets.icSettingsGreen,
                width: 22,
                height: 22,
              ),
              tooltip: t.settings,
            ),
            // IconButton(
            //   onPressed: () {},
            //   icon: SvgPicture.asset(AppAssets.icMenu, width: 22, height: 22),
            // ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: t.downloadedTab),
              Tab(text: t.notDownloadedTab),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_DownloadedTab(), _NotDownloadedTab()],
        ),
      ),
    );
  }
}

class _DownloadedTab extends StatelessWidget {
  const _DownloadedTab();

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    return BlocBuilder<AudioDownloadCubit, AudioDownloadState>(
      builder: (context, state) {
        final list = state.downloaded;
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon with gradient background
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        FigmaPalette.primary.withValues(alpha: 0.15),
                        FigmaPalette.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AppAssets.icDownloadGreen,
                      width: 60,
                      height: 60,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                Text(
                  t.noDownloaded,
                  style: FigmaTypography.title18(),
                  textAlign: TextAlign.center,
                ),

                // Description
                const SizedBox(height: 48),
              ],
            ),
          );
        }
        return ListView.separated(
          itemCount: list.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (ctx, i) {
            final s = list[i];
            final info = QuranLibrary().getSurahInfo(surahNumber: s - 1);
            return ListTile(
              title: Text('${info.name} (${s.toString().padLeft(3, '0')})'),
              subtitle: null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: t.play,
                    icon: SvgPicture.asset(
                      AppAssets.icPlay,
                      width: 20,
                      height: 20,
                    ),
                    onPressed: () async {
                      final audioCubit = context.read<AudioCubit>();
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await audioCubit.playSurah(s);
                      } catch (e) {
                        if (!context.mounted) return;
                        messenger.showSnackBar(
                          SnackBar(content: Text(t.errorPlaySurah('$e'))),
                        );
                      }
                    },
                  ),
                  IconButton(
                    tooltip: t.delete,
                    icon: Text(t.delete, style: TextStyle(fontSize: 12)),
                    onPressed: () async {
                      final downloadCubit = context.read<AudioDownloadCubit>();
                      final messenger = ScaffoldMessenger.of(context);
                      await downloadCubit.delete(s);
                      if (!context.mounted) return;
                      messenger.showSnackBar(
                        SnackBar(content: Text(t.deleteSuccess)),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _NotDownloadedTab extends StatelessWidget {
  const _NotDownloadedTab();

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    return BlocBuilder<AudioDownloadCubit, AudioDownloadState>(
      builder: (context, state) {
        final list = state.notDownloaded;
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (list.isEmpty) {
          return Center(child: Text(t.noNotDownloaded));
        }
        return ListView.separated(
          itemCount: list.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (ctx, i) {
            final s = list[i];
            final info = QuranLibrary().getSurahInfo(surahNumber: s - 1);
            final status = state.statusBySurah[s] ?? DownloadStatus.idle;
            final progress = state.progressBySurah[s] ?? 0.0;
            final downloading = status == DownloadStatus.downloading;
            return ListTile(
              title: Text('${info.name} (${s.toString().padLeft(3, '0')})'),
              subtitle: downloading
                  ? LinearProgressIndicator(value: progress)
                  : null,
              trailing: IconButton(
                onPressed: downloading
                    ? null
                    : () => context.read<AudioDownloadCubit>().download(s),
                icon: SvgPicture.asset(
                  AppAssets.icDownloadGreen,
                  width: 20,
                  height: 20,
                ),
                tooltip: t.download,
              ),
            );
          },
        );
      },
    );
  }
}
