import 'package:flutter/material.dart';
import 'package:quran/core/theme/figma_palette.dart';

class ListDivider extends StatelessWidget {
  const ListDivider({super.key});
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: FigmaPalette.divider);
  }
}
