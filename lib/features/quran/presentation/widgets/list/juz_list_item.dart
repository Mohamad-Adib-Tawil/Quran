import 'package:flutter/material.dart';
import 'package:quran/core/theme/figma_palette.dart';
import 'package:quran/core/theme/figma_typography.dart';

class JuzListItem extends StatelessWidget {
  final int index; // 1-based
  final String? subtitle;
  final VoidCallback? onTap;
  const JuzListItem({super.key, required this.index, this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            _Pill(label: 'الجزء $index'),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الجزء $index', style: FigmaTypography.body15(color: Theme.of(context).colorScheme.onSurface)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!, style: FigmaTypography.caption12(color: Theme.of(context).hintColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class HizbListItem extends StatelessWidget {
  final int index; // 1-based
  final String? subtitle;
  final VoidCallback? onTap;
  const HizbListItem({super.key, required this.index, this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            _Pill(label: 'الحزب $index'),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الحزب $index', style: FigmaTypography.body15(color: Theme.of(context).colorScheme.onSurface)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!, style: FigmaTypography.caption12(color: Theme.of(context).hintColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  const _Pill({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: FigmaPalette.surface,
        border: Border.all(color: FigmaPalette.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: FigmaTypography.body13(color: Theme.of(context).colorScheme.onSurface)),
    );
  }
}
