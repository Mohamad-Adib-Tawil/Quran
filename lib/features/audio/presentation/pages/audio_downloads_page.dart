import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_library/quran_library.dart';

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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة الصوت'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'المحمّلة'),
              Tab(text: 'غير المحمّلة'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _DownloadedTab(),
            _NotDownloadedTab(),
          ],
        ),
      ),
    );
  }
}

class _DownloadedTab extends StatelessWidget {
  const _DownloadedTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioDownloadCubit, AudioDownloadState>(
      builder: (context, state) {
        final list = state.downloaded;
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (list.isEmpty) {
          return const Center(child: Text('لا توجد سور محمّلة'));
        }
        return ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_context, _index) => const Divider(height: 1),
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
                    tooltip: 'تشغيل',
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () async {
                      final audioCubit = context.read<AudioCubit>();
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await audioCubit.playSurah(s);
                      } catch (e) {
                        if (!context.mounted) return;
                        messenger.showSnackBar(
                          SnackBar(content: Text('لا يمكن تشغيل السورة: $e')),
                        );
                      }
                    },
                  ),
                  IconButton(
                    tooltip: 'حذف',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final downloadCubit = context.read<AudioDownloadCubit>();
                      final messenger = ScaffoldMessenger.of(context);
                      await downloadCubit.delete(s);
                      if (!context.mounted) return;
                      messenger.showSnackBar(
                        const SnackBar(content: Text('تم حذف السورة')),
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
    return BlocBuilder<AudioDownloadCubit, AudioDownloadState>(
      builder: (context, state) {
        final list = state.notDownloaded;
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (list.isEmpty) {
          return const Center(child: Text('لا توجد سور غير محمّلة'));
        }
        return ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_context, _index) => const Divider(height: 1),
          itemBuilder: (ctx, i) {
            final s = list[i];
            final info = QuranLibrary().getSurahInfo(surahNumber: s - 1);
            final status = state.statusBySurah[s] ?? DownloadStatus.idle;
            final progress = state.progressBySurah[s] ?? 0.0;
            final downloading = status == DownloadStatus.downloading;
            return ListTile(
              title: Text('${info.name} (${s.toString().padLeft(3, '0')})'),
              subtitle: downloading ? LinearProgressIndicator(value: progress) : null,
              trailing: ElevatedButton.icon(
                onPressed: downloading
                    ? null
                    : () => context.read<AudioDownloadCubit>().download(s),
                icon: const Icon(Icons.download),
                label: Text(downloading ? '${(progress * 100).toStringAsFixed(0)}%' : 'تحميل'),
              ),
            );
          },
        );
      },
    );
  }
}
