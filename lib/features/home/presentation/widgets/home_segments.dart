import 'package:flutter/material.dart';
import 'package:quran_app/core/theme/figma_palette.dart';
import 'package:quran_app/core/theme/figma_typography.dart';

class HomeSegments extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const HomeSegments({super.key, required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final segments = const [
      ('السور', 0),
      ('الأجزاء', 1),
      ('الأحزاب', 2),
      ('الأرباع', 3),
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: segments.map((e) {
          final selected = e.$2 == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(e.$2),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? FigmaPalette.primary.withValues(alpha: 0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  e.$1,
                  style: FigmaTypography.body15(color: selected ? FigmaPalette.primary : Colors.black87),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
