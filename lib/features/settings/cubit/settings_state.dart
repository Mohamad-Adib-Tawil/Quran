import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final double fontScale; // 0.8..2.0
  final bool verseEndSymbol;

  const SettingsState({
    required this.themeMode,
    required this.fontScale,
    required this.verseEndSymbol,
  });

  factory SettingsState.initial() => const SettingsState(
        themeMode: ThemeMode.light,
        fontScale: 1.0,
        verseEndSymbol: true,
      );

  SettingsState copyWith({
    ThemeMode? themeMode,
    double? fontScale,
    bool? verseEndSymbol,
  }) =>
      SettingsState(
        themeMode: themeMode ?? this.themeMode,
        fontScale: fontScale ?? this.fontScale,
        verseEndSymbol: verseEndSymbol ?? this.verseEndSymbol,
      );

  @override
  List<Object?> get props => [themeMode, fontScale, verseEndSymbol];
}
