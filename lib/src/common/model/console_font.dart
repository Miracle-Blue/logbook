/// {@template console_font}
/// Available console fonts
/// {@endtemplate}
enum ConsoleFont {
  /// Bold font
  bold,

  /// Underline font
  underline,

  /// Reversed font
  //reversed,

  /// Default font
  byDefault;

  /// {@macro console_font}
  const ConsoleFont();
}

/// Extension methods for [ConsoleFont].
extension ConsoleFontX on ConsoleFont {
  /// Ansi decorations for terminal
  String get value => switch (this) {
    ConsoleFont.bold => '1m',
    ConsoleFont.underline => '4m',
    // _ConsoleFont.reversed => '7m',
    ConsoleFont.byDefault => '',
  };
}
