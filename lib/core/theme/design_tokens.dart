import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();
  static const double xs = 6;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 6;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class AppDurations {
  AppDurations._();
  static const short = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 250);
  static const long = Duration(milliseconds: 400);
}

class AppShadows {
  AppShadows._();
  static List<BoxShadow> soft(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.08),
          blurRadius: 12,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ];
}
