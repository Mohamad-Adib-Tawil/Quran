import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final double fontScale; // 0.8..2.0
  final bool verseEndSymbol;
  final String? localeCode; // e.g., 'ar', 'de'

  const SettingsState({
    required this.themeMode,
    required this.fontScale,
    required this.verseEndSymbol,
    this.localeCode,
  });

  factory SettingsState.initial() => const SettingsState(
        themeMode: ThemeMode.light,
        fontScale: 1.0,
        verseEndSymbol: true,
        localeCode: null,
      );

  SettingsState copyWith({
    ThemeMode? themeMode,
    double? fontScale,
    bool? verseEndSymbol,
    String? localeCode,
  }) =>
      SettingsState(
        themeMode: themeMode ?? this.themeMode,
        fontScale: fontScale ?? this.fontScale,
        verseEndSymbol: verseEndSymbol ?? this.verseEndSymbol,
        localeCode: localeCode ?? this.localeCode,
      );

  @override
  List<Object?> get props => [themeMode, fontScale, verseEndSymbol, localeCode];
}
