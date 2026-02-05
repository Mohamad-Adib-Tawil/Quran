import 'package:flutter/material.dart';
import 'package:quran_app/core/theme/figma_palette.dart';
import 'package:quran_app/core/theme/figma_typography.dart';
import 'package:quran_app/core/localization/app_localization_ext.dart';

class JuzListItem extends StatelessWidget {
  final int index; // 1-based
  final String? subtitle;
  final VoidCallback? onTap;
  const JuzListItem({super.key, required this.index, this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            _Pill(label: '$index'),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.juzName, style: FigmaTypography.body15(color: Theme.of(context).colorScheme.onSurface)),
                  if (subtitle != null && !subtitle!.contains(t.juzName)) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!, style: FigmaTypography.caption12(color: Theme.of(context).hintColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            Icon(
              Directionality.of(context) == TextDirection.rtl ? Icons.chevron_right : Icons.chevron_left,
              color: Colors.grey,
            ),
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
    final t = context.tr;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            _Pill(label: '$index'),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.hizbName, style: FigmaTypography.body15(color: Theme.of(context).colorScheme.onSurface)),
                  if (subtitle != null && !subtitle!.contains(t.hizbName)) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!, style: FigmaTypography.caption12(color: Theme.of(context).hintColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            Icon(
              Directionality.of(context) == TextDirection.rtl ? Icons.chevron_right : Icons.chevron_left,
              color: Colors.grey,
            ),
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
