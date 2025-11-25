import 'package:flutter/material.dart';

/// {@template app_colors}
/// Emphasis class
/// Logger colors for the application:
/// {@endtemplate}
@immutable
final class LoggerColors extends ThemeExtension<LoggerColors> {
  /// {@macro app_colors}
  const LoggerColors({
    required this.consoleWhite,
    required this.consoleBlack,
    required this.consoleYellow,
    required this.consoleRed,
    required this.consoleGreen,
    required this.consoleMagenta,
    required this.consoleBlue,
    required this.consoleCyan,
    required this.consoleDefault,
    required this.loggerBackground,
    required this.brilliantAzure,
    required this.gray,
  });

  /// Gets the logger colors from the theme.
  factory LoggerColors.of(BuildContext context) {
    try {
      final theme = Theme.of(context);

      return theme.extension<LoggerColors>() ??
          switch (theme.brightness) {
            Brightness.light => LoggerColors.light,
            Brightness.dark => LoggerColors.dark,
          };
    } on Object {
      return LoggerColors.light;
    }
  }

  /// The background color of the logger.
  final Color loggerBackground;

  /// The white color of the console.
  final Color consoleWhite;

  /// The black color of the console.
  final Color consoleBlack;

  /// The yellow color of the console.
  final Color consoleYellow;

  /// The red color of the console.
  final Color consoleRed;

  /// The green color of the console.
  final Color consoleGreen;

  /// The magenta color of the console.
  final Color consoleMagenta;

  /// The blue color of the console.
  final Color consoleBlue;

  /// The cyan color of the console.
  final Color consoleCyan;

  /// The default color of the console.
  final Color consoleDefault;

  /// The brilliant azure color.
  final Color brilliantAzure;

  /// The gray color.
  final Color gray;

  /// The default light theme colors.
  static const light = LoggerColors(
    loggerBackground: Color(0xFFf2f2f2),
    consoleWhite: Color(0xFF555555),
    consoleBlack: Color(0xFF000000),
    consoleYellow: Color(0xFF787a01),
    consoleRed: Color(0xFFcd3131),
    consoleGreen: Color(0xFF0e7c10),
    consoleMagenta: Color(0xFFbc06bc),
    consoleBlue: Color(0xFF0000FF),
    consoleCyan: Color(0xFF00FFFF),
    consoleDefault: Color(0xFF000000),
    brilliantAzure: Color(0xFF3794ff),
    gray: Color(0xFF808080),
  );

  /// The default dark theme colors.
  static const dark = LoggerColors(
    loggerBackground: Color(0xFF181818),
    consoleWhite: Color(0xFFe5e5e5),
    consoleBlack: Color(0xFF797979),
    consoleYellow: Color(0xFFe5e50e),
    consoleRed: Color(0xFFd75959),
    consoleGreen: Color(0xFF0fbc7a),
    consoleMagenta: Color(0xFFc353c3),
    consoleBlue: Color(0xFF0000FF),
    consoleCyan: Color(0xFF00FFFF),
    consoleDefault: Color(0xFF000000),
    brilliantAzure: Color(0xFF3794ff),
    gray: Color(0xFF808080),
  );

  @override
  LoggerColors copyWith({
    Color? loggerBackground,
    Color? consoleWhite,
    Color? consoleBlack,
    Color? consoleYellow,
    Color? consoleRed,
    Color? consoleGreen,
    Color? consoleMagenta,
    Color? consoleBlue,
    Color? consoleCyan,
    Color? consoleDefault,
    Color? brilliantAzure,
    Color? gray,
  }) => LoggerColors(
    // logViewer colors
    loggerBackground: loggerBackground ?? this.loggerBackground,
    consoleWhite: consoleWhite ?? this.consoleWhite,
    consoleBlack: consoleBlack ?? this.consoleBlack,
    consoleYellow: consoleYellow ?? this.consoleYellow,
    consoleRed: consoleRed ?? this.consoleRed,
    consoleGreen: consoleGreen ?? this.consoleGreen,
    consoleMagenta: consoleMagenta ?? this.consoleMagenta,
    consoleBlue: consoleBlue ?? this.consoleBlue,
    consoleCyan: consoleCyan ?? this.consoleCyan,
    consoleDefault: consoleDefault ?? this.consoleDefault,
    brilliantAzure: brilliantAzure ?? this.brilliantAzure,
    gray: gray ?? this.gray,
  );

  @override
  ThemeExtension<LoggerColors> lerp(
    ThemeExtension<LoggerColors>? other,
    double t,
  ) => other is! LoggerColors
      ? this
      : LoggerColors(
          loggerBackground: Color.lerp(
            loggerBackground,
            other.loggerBackground,
            t,
          )!,
          consoleWhite: Color.lerp(consoleWhite, other.consoleWhite, t)!,
          consoleBlack: Color.lerp(consoleBlack, other.consoleBlack, t)!,
          consoleYellow: Color.lerp(consoleYellow, other.consoleYellow, t)!,
          consoleRed: Color.lerp(consoleRed, other.consoleRed, t)!,
          consoleGreen: Color.lerp(consoleGreen, other.consoleGreen, t)!,
          consoleMagenta: Color.lerp(consoleMagenta, other.consoleMagenta, t)!,
          consoleBlue: Color.lerp(consoleBlue, other.consoleBlue, t)!,
          consoleCyan: Color.lerp(consoleCyan, other.consoleCyan, t)!,
          consoleDefault: Color.lerp(consoleDefault, other.consoleDefault, t)!,
          brilliantAzure: Color.lerp(brilliantAzure, other.brilliantAzure, t)!,
          gray: Color.lerp(gray, other.gray, t)!,
        );

  @override
  String toString() => 'LoggerColors{}';
}
