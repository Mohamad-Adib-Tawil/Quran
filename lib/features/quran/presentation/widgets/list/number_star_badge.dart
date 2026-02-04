import 'package:flutter/material.dart';
import 'package:quran_app/core/theme/figma_palette.dart';
import 'package:quran_app/core/theme/figma_typography.dart';

class NumberStarBadge extends StatelessWidget {
  final int number;
  const NumberStarBadge({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: FigmaPalette.primary, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 16, color: FigmaPalette.primary),
          const SizedBox(width: 6),
          Text('$number', style: FigmaTypography.body13(color: FigmaPalette.primary)),
        ],
      ),
    );
  }
}
