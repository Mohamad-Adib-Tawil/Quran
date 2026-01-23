import 'package:equatable/equatable.dart';
import '../../domain/repositories/audio_download_repository.dart' show DownloadStatus;

class AudioDownloadState extends Equatable {
  final List<int> downloaded; // sorted
  final List<int> notDownloaded; // sorted
  final Map<int, double> progressBySurah; // 0..1
  final Map<int, DownloadStatus> statusBySurah;
  final bool loading;

  const AudioDownloadState({
    required this.downloaded,
    required this.notDownloaded,
    required this.progressBySurah,
    required this.statusBySurah,
    required this.loading,
  });

  factory AudioDownloadState.initial() => const AudioDownloadState(
        downloaded: [],
        notDownloaded: [],
        progressBySurah: {},
        statusBySurah: {},
        loading: true,
      );

  AudioDownloadState copyWith({
    List<int>? downloaded,
    List<int>? notDownloaded,
    Map<int, double>? progressBySurah,
    Map<int, DownloadStatus>? statusBySurah,
    bool? loading,
  }) =>
      AudioDownloadState(
        downloaded: downloaded ?? this.downloaded,
        notDownloaded: notDownloaded ?? this.notDownloaded,
        progressBySurah: progressBySurah ?? this.progressBySurah,
        statusBySurah: statusBySurah ?? this.statusBySurah,
        loading: loading ?? this.loading,
      );

  @override
  List<Object?> get props => [downloaded, notDownloaded, progressBySurah, statusBySurah, loading];
}
