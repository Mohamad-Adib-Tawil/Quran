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
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onInfo;
  final VoidCallback? onFavoriteToggle;
  const SurahListItem({
    super.key,
    required this.surahNumber,
    required this.titleAr,
    required this.titleLatin,
    this.subtitleAr,
    this.subtitleLatin,
    this.isFavorite = false,
    this.onTap,
    this.onLongPress,
    this.onInfo,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Build semantic label for screen readers
    final semanticLabel = 'سورة $titleAr، $titleLatin${subtitleAr != null ? '، $subtitleAr' : ''}';
    
    return Semantics(
      label: semanticLabel,
      button: true,
      onTap: onTap,
      onLongPress: onLongPress,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Stack(
          // Use loose fit so the item can size itself based on its content.
          // This avoids forcing an infinite height when placed in shrink-wrapped lists.
          fit: StackFit.loose,
          alignment: Alignment.center,
          children: [
            // Base content row with directional start padding so number pill doesn't overlap
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 40),
              child: Row(
                textDirection: TextDirection.ltr,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Latin column (left)
                  Flexible(
                    fit: FlexFit.loose,
                    child: Column(
                      textDirection: TextDirection.ltr,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          titleLatin,
                          style: FigmaTypography.latinBody15(color: Theme.of(context).colorScheme.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                        ),
                        // No Latin subtitle; info will always be shown under Arabic title
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 22,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: onFavoriteToggle == null
                                ? SvgPicture.asset(
                                    isFavorite ? AppAssets.icStarGreen : AppAssets.icStarGray,
                                    width: 20,
                                    height: 20,
                                  )
                                : Semantics(
                                    label: isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
                                    button: true,
                                    child: InkWell(
                                      onTap: onFavoriteToggle,
                                      borderRadius: BorderRadius.circular(6),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2),
                                        child: SvgPicture.asset(
                                          isFavorite ? AppAssets.icStarGreen : AppAssets.icStarGray,
                                          width: 20,
                                          height: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Arabic column (right) expands and stays flush to the right
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        textDirection: TextDirection.ltr,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                        Text(
                          titleAr,
                          style: GoogleFonts.notoNaskhArabic(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                        if (subtitleAr != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitleAr!,
                            style: GoogleFonts.notoNaskhArabic(fontSize: 12, fontWeight: FontWeight.w500, color: Theme.of(context).hintColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Directional number pill at the start edge (left in LTR, right in RTL)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: _NumberPill(number: surahNumber),
            ),
          ],
        ),
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
