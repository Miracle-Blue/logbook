import 'package:flutter/material.dart';

import '../model/console_color.dart';
import 'logger_colors.dart';

/// Hand-picked, dark-background-friendly colors for custom log prefixes.
/// Order is stable: appending is safe; reordering/removing reshuffles
/// existing prefix→color assignments.
const List<Color> kPrefixPalette = <Color>[
  Color(0xFF7AA2F7), // soft blue
  Color(0xFF9ECE6A), // green
  Color(0xFFBB9AF7), // violet
  Color(0xFF2AC3DE), // cyan
  Color(0xFFE0AF68), // amber
  Color(0xFFF7768E), // rose
  Color(0xFF73DACA), // teal
  Color(0xFFFF9E64), // orange
  Color(0xFFC0CAF5), // periwinkle
  Color(0xFFFF75A0), // pink
  Color(0xFF41A6B5), // deep teal
  Color(0xFFD7BA7D), // tan
  Color(0xFF89DDFF), // sky
  Color(0xFFB4F9F8), // ice
];

/// FNV-1a 32-bit hash over UTF-16 code units.
///
/// Deterministic across runs and platforms (unlike `String.hashCode`), so a
/// given prefix always maps to the same palette entry.
int _fnv1a(String s) {
  var hash = 0x811C9DC5;
  for (var i = 0; i < s.length; i++) {
    hash = (hash ^ s.codeUnitAt(i)) & 0xFFFFFFFF;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash;
}

/// The stable palette color for a custom [prefix].
Color _paletteColor(String prefix) =>
    kPrefixPalette[_fnv1a(prefix) % kPrefixPalette.length];

/// 24-bit truecolor foreground SGR *value* (written after [Constants.esc]),
/// e.g. `'38;2;122;162;247m'`.
///
/// Channels are derived from `toARGB32()` to avoid the deprecated
/// `.red`/`.green`/`.blue` getters.
String _ansiTruecolor(Color color) {
  final argb = color.toARGB32();
  final r = (argb >> 16) & 0xFF;
  final g = (argb >> 8) & 0xFF;
  final b = argb & 0xFF;
  return '38;2;$r;$g;${b}m';
}

/// Resolves the display [Color] for a log [prefix] in the in-app viewer.
///
/// Built-in level prefixes keep their theme-tuned semantic color (matching the
/// existing UI mapping); every other prefix gets a stable color from
/// [kPrefixPalette].
Color colorForPrefix(String prefix, LoggerColors colors) => switch (prefix) {
  'F' => ConsoleColor.black.toColor(colors),
  'C' => ConsoleColor.green.toColor(colors),
  'I' => ConsoleColor.white.toColor(colors),
  'W' => ConsoleColor.yellow.toColor(colors),
  'S' => ConsoleColor.red.toColor(colors),
  _ => _paletteColor(prefix),
};

/// Resolves the console ANSI foreground SGR value for a log [prefix].
///
/// Built-in prefixes fall back to the existing 8-color codes (so a
/// `'S'` prefix still prints red); others emit 24-bit truecolor.
String ansiForegroundForPrefix(String prefix) => switch (prefix) {
  'F' => ConsoleColor.black.foregroundValue,
  'C' => ConsoleColor.green.foregroundValue,
  'I' => ConsoleColor.blue.foregroundValue, // matches l.i console color
  'W' => ConsoleColor.yellow.foregroundValue,
  'S' => ConsoleColor.red.foregroundValue,
  _ => _ansiTruecolor(_paletteColor(prefix)),
};
