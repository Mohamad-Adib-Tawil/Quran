import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FigmaTypography {
  FigmaTypography._();

  static TextStyle title19({Color? color}) =>
      GoogleFonts.balooBhaijaan2(fontSize: 19, fontWeight: FontWeight.w600, color: color);

  static TextStyle title18({Color? color}) =>
      GoogleFonts.balooBhaijaan2(fontSize: 18, fontWeight: FontWeight.w600, color: color);

  static TextStyle body15({Color? color}) =>
      GoogleFonts.balooBhaijaan2(fontSize: 15, fontWeight: FontWeight.w500, color: color);

  static TextStyle body13({Color? color}) =>
      GoogleFonts.balooBhaijaan2(fontSize: 13, fontWeight: FontWeight.w500, color: color);

  static TextStyle caption12({Color? color}) =>
      GoogleFonts.balooBhaijaan2(fontSize: 12, fontWeight: FontWeight.w500, color: color);

  // Latin helper (DM Sans), if needed
  static TextStyle latinBody15({Color? color}) =>
      GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500, color: color);
}
