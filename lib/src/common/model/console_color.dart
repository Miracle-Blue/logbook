import 'package:flutter/material.dart';

import '../util/logger_colors.dart';

/// {@template console_color}
/// Available console colors
/// {@endtemplate}
enum ConsoleColor {
  /// Black color
  black,

  /// Red color
  red,

  /// Green color
  green,

  /// Yellow color
  yellow,

  /// Blue color
  blue,

  /// Magenta color
  magenta,

  /// Cyan color
  cyan,

  /// White color
  white,

  /// Default color
  byDefault;

  /// {@macro console_color}
  const ConsoleColor();
}

/// Extension methods for [ConsoleColor].
extension ConsoleColorX on ConsoleColor {
  /// Ansi foreground colors for terminal
  String get foregroundValue => switch (this) {
    ConsoleColor.black => '30m',
    ConsoleColor.red => '31m',
    ConsoleColor.green => '32m',
    ConsoleColor.yellow => '33m',
    ConsoleColor.blue => '34m',
    ConsoleColor.magenta => '35m',
    ConsoleColor.cyan => '36m',
    ConsoleColor.white => '37m',
    ConsoleColor.byDefault => '',
  };

  /// Ansi background colors for terminal
  String get backgroundValue => switch (this) {
    ConsoleColor.black => '40m',
    ConsoleColor.red => '41m',
    ConsoleColor.green => '42m',
    ConsoleColor.yellow => '43m',
    ConsoleColor.blue => '44m',
    ConsoleColor.magenta => '45m',
    ConsoleColor.cyan => '46m',
    ConsoleColor.white => '47m',
    ConsoleColor.byDefault => '',
  };

  /// Converts the console color to a [Color] using the given [LoggerColors].
  Color toColor(LoggerColors loggerColors) => switch (this) {
    ConsoleColor.white => loggerColors.consoleWhite,
    ConsoleColor.black => loggerColors.consoleBlack,
    ConsoleColor.yellow => loggerColors.consoleYellow,
    ConsoleColor.red => loggerColors.consoleRed,
    ConsoleColor.green => loggerColors.consoleGreen,
    ConsoleColor.magenta => loggerColors.consoleMagenta,
    ConsoleColor.blue => loggerColors.consoleBlue,
    ConsoleColor.cyan => loggerColors.consoleCyan,
    ConsoleColor.byDefault => loggerColors.consoleDefault,
  };

  /// Converts the console color to a [Color]
  /// by resolving [LoggerColors] from context.
  Color consoleColorToColor(BuildContext context) =>
      toColor(LoggerColors.of(context));
}
