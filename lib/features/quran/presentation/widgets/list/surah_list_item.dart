import 'package:flutter/material.dart';
import 'package:quran_app/core/theme/figma_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/core/assets/app_assets.dart';
import 'package:google_fonts/google_fonts.dart';

class SurahListItem extends StatelessWidget {
  final int surahNumber;
  final String titleAr;
  final String titleLatin;
  final String? subtitleAr;
  final String? subtitleLatin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onInfo;
  final Widget? trailing;
  const SurahListItem({super.key, required this.surahNumber, required this.titleAr, required this.titleLatin, this.subtitleAr, this.subtitleLatin, this.onTap, this.onLongPress, this.onInfo, this.trailing});

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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          titleLatin,
                          style: FigmaTypography.latinBody15(color: Theme.of(context).colorScheme.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          titleAr,
                          style: GoogleFonts.notoNaskhArabic(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  if (subtitleAr != null || subtitleLatin != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: subtitleLatin == null
                              ? const SizedBox.shrink()
                              : Text(
                                  subtitleLatin!,
                                  style: FigmaTypography.caption12(color: Theme.of(context).hintColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: subtitleAr == null
                              ? const SizedBox.shrink()
                              : Text(
                                  subtitleAr!,
                                  style: GoogleFonts.notoNaskhArabic(fontSize: 12, fontWeight: FontWeight.w500, color: Theme.of(context).hintColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                ),
                        ),
                      ],
                    ),
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
    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(AppAssets.icSurahNumberBg, width: 28, height: 28),
          Text('$number', style: FigmaTypography.body13(color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }
}
