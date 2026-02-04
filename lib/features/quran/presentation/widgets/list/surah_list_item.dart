import 'package:flutter/material.dart';
import 'package:quran_app/core/theme/figma_palette.dart';
import 'package:quran_app/core/theme/figma_typography.dart';

class SurahListItem extends StatelessWidget {
  final int surahNumber;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onInfo;
  final Widget? trailing;
  const SurahListItem({super.key, required this.surahNumber, required this.title, this.subtitle, this.onTap, this.onLongPress, this.onInfo, this.trailing});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            _NumberPill(number: surahNumber),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: FigmaTypography.body15(color: Theme.of(context).colorScheme.onSurface)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!, style: FigmaTypography.caption12(color: Theme.of(context).hintColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: 6),
            ],
            if (onInfo != null)
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.grey),
                onPressed: onInfo,
                tooltip: 'تفاصيل',
              ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _NumberPill extends StatelessWidget {
  final int number;
  const _NumberPill({required this.number});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: FigmaPalette.surface,
        border: Border.all(color: FigmaPalette.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('$number', style: FigmaTypography.body13(color: Theme.of(context).colorScheme.onSurface)),
    );
  }
}
