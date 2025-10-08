/// Available console fonts
enum ConsoleFont {
  bold,
  underline,
  //reversed,
  byDefault,
}

extension ConsoleFontX on ConsoleFont {
  /// Ansi decorations for terminal
  String get value => switch (this) {
    ConsoleFont.bold => '1m',
    ConsoleFont.underline => '4m',
    // _ConsoleFont.reversed => '7m',
    ConsoleFont.byDefault => '',
  };
}
