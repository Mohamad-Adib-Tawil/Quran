import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../settings/audio_settings_cubit.dart';
import '../cubit/audio_cubit.dart';
import '../cubit/audio_state.dart';

class AudioSettingsSheet extends StatelessWidget {
  const AudioSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AudioSettingsCubit>().state;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 12,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Audio Settings', style: Theme.of(context).textTheme.titleMedium),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Playback speed: ${settings.speed.toStringAsFixed(2)}x'),
            Slider(
              value: settings.speed,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              label: '${settings.speed.toStringAsFixed(2)}x',
              onChanged: (v) => context.read<AudioSettingsCubit>().setSpeed(double.parse(v.toStringAsFixed(2))),
            ),
            const SizedBox(height: 12),
            Text('Repeat'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                _repeatChip(context, label: 'One', mode: RepeatMode.one, selected: settings.repeatMode == RepeatMode.one, color: scheme.primary),
                _repeatChip(context, label: 'Off', mode: RepeatMode.off, selected: settings.repeatMode == RepeatMode.off, color: scheme.primary),
                _repeatChip(context, label: 'Next', mode: RepeatMode.next, selected: settings.repeatMode == RepeatMode.next, color: scheme.primary),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Auto download'),
              value: settings.autoDownload,
              onChanged: (v) => context.read<AudioSettingsCubit>().setAutoDownload(v),
            ),
            const SizedBox(height: 12),
            Text('Sleep timer'),
            const SizedBox(height: 6),
            Row(
              children: [
                _timerButton(context, label: 'Off', duration: null),
                const SizedBox(width: 8),
                _timerButton(context, label: '15m', duration: const Duration(minutes: 15)),
                const SizedBox(width: 8),
                _timerButton(context, label: '30m', duration: const Duration(minutes: 30)),
                const SizedBox(width: 8),
                _timerButton(context, label: '60m', duration: const Duration(hours: 1)),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _repeatChip(BuildContext context, {required String label, required RepeatMode mode, required bool selected, required Color color}) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => context.read<AudioSettingsCubit>().setRepeat(mode),
      selectedColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: selected ? color : null),
      side: BorderSide(color: selected ? color : Colors.grey.shade300),
    );
  }

  Widget _timerButton(BuildContext context, {required String label, required Duration? duration}) {
    final active = context.select<AudioCubit, bool>((c) => (c.state.sleepTimer != null && duration != null && c.state.sleepTimer == duration) || (duration == null && c.state.sleepTimer == null));
    return OutlinedButton(
      onPressed: () => context.read<AudioCubit>().setSleepTimer(duration),
      style: OutlinedButton.styleFrom(
        foregroundColor: active ? Theme.of(context).colorScheme.primary : null,
        side: BorderSide(color: active ? Theme.of(context).colorScheme.primary : Colors.grey.shade400),
      ),
      child: Text(label),
    );
  }
}
