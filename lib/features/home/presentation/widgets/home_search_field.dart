import 'package:flutter/material.dart';
import 'package:quran/core/theme/design_tokens.dart';
import 'package:quran/core/theme/figma_palette.dart';

class HomeSearchField extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final String? hintText;
  const HomeSearchField({super.key, this.onChanged, this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: hintText ?? 'ابحث عن سورة',
        filled: true,
        fillColor: FigmaPalette.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.l),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: onChanged,
    );
  }
}
