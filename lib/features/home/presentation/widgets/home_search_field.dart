import 'package:flutter/material.dart';
import 'package:quran_app/core/theme/design_tokens.dart';
import 'package:quran_app/core/theme/figma_palette.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/core/assets/app_assets.dart';

class HomeSearchField extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final String? hintText;
  const HomeSearchField({super.key, this.onChanged, this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: SvgPicture.asset(
            AppAssets.icSearch,
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(FigmaPalette.primary, BlendMode.srcIn),
          ),
        ),
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
