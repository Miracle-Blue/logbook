import 'dart:developer' as developer;

import 'package:flutter/foundation.dart' show kReleaseMode;

import '../../feature/logbook/log_buffer.dart';
import '../extension/date_time_extension.dart';
import '../extension/string_buffer_extension.dart';
import '../model/console_color.dart';
import '../model/console_font.dart';
import '../model/log_message.dart';
import 'constants.dart';

/// Global logger instance.
final l = _L._();

/// {@template logger}
/// Logger class.
/// {@endtemplate}
final class _L {
  /// {@macro logger}
  _L._();

  /// {@macro logger_f}
  final void Function(Object? message) f = _log(
    'F',
    font: ConsoleFont.bold.value,
    foreground: ConsoleColor.black.foregroundValue,
  );

  /// {@macro logger_c}
  void Function(Object? message) c = _log(
    'C',
    font: ConsoleFont.bold.value,
    foreground: ConsoleColor.green.foregroundValue,
  );

  /// {@macro logger_i}
  void Function(Object? message) i = _log(
    'I',
    font: ConsoleFont.bold.value,
    foreground: ConsoleColor.blue.foregroundValue,
  );

  /// {@macro logger_w}
  void Function(Object exception, [StackTrace? stackTrace, String? reason]) w =
      _log(
        'W',
        font: ConsoleFont.bold.value,
        foreground: ConsoleColor.yellow.foregroundValue,
        background: ConsoleColor.black.backgroundValue,
      );

  /// {@macro logger_s}
  void Function(Object exception, [StackTrace? stackTrace, String? reason]) s =
      _log(
        'S',
        font: ConsoleFont.bold.value,
        foreground: ConsoleColor.red.foregroundValue,
      );

  /// {@macro logger_log}
  void log(
    Object message,
    String prefix, {
    StackTrace? stackTrace,
    bool withMilliseconds = false,
  }) {
    final logMessage = LogMessage(
      message: "$message${stackTrace != null ? '\n$stackTrace\n\n' : ''}",
      timestamp: DateTime.now(),
      prefix: prefix,
      color: ConsoleColor.magenta,
    );
    LogBuffer.instance.add(logMessage);

    if (kReleaseMode) return;

    final foreground = ConsoleColor.magenta.foregroundValue;
    final formattedMessage = _formatStyled(
      '${Constants.esc}$foreground $message',
      prefix,
      font: ConsoleFont.bold.value,
      foreground: foreground,
      withMilliseconds: withMilliseconds,
    );

    developer.log(formattedMessage, name: '•', stackTrace: stackTrace);
  }

  static void Function(
    Object? message, [
    StackTrace? stackTrace,
    String? reason,
  ])
  _log(String prefix, {String? font, String? foreground, String? background}) =>
      (message, [stackTrace, reason]) {
        final logMessage = LogMessage(
          message: "$message${stackTrace != null ? '\n$stackTrace\n\n' : ''}",
          timestamp: DateTime.now(),
          prefix: prefix,
          color: switch (prefix) {
            'F' => ConsoleColor.black,
            'C' => ConsoleColor.green,
            'I' => ConsoleColor.white,
            'W' => ConsoleColor.yellow,
            'S' => ConsoleColor.red,
            _ => ConsoleColor.magenta,
          },
        );
        LogBuffer.instance.add(logMessage);

        if (kReleaseMode) return;

        final formattedMessage = _formatStyled(
          '${Constants.esc}$foreground $message',
          prefix,
          font: font,
          foreground: foreground,
          background: background,
        );

        developer.log(formattedMessage, name: '•', stackTrace: stackTrace);
      };
}

/// Extension methods for [_L].
extension _LX on _L {}

/// {@template format_styled}
/// Format styled.
/// {@endtemplate}
String _formatStyled(
  Object message,
  String prefix, {
  String? font,
  String? foreground,
  String? background,
  bool withMilliseconds = false,
}) {
  final buffer = StringBuffer('');
  for (final value in [font, foreground, background]) {
    if (value != null) buffer.writeEsc(value);
  }
  buffer
    ..write('[')
    ..write(prefix)
    ..write(']')
    ..writeEsc(Constants.reset);

  return buffer.completeMessage(
    '['
    '${DateTime.now().timeFormat(withMilliseconds: withMilliseconds)}'
    ']'
    '$message',
  );
}

/// Returns the file location
// ignore: unused_element
String _getFileLocation({required StackTrace stackTrace}) {
  final fileLocation =
      (stackTrace)
          .toString()
          .split('\n')
          .where((e) => e.contains('package'))
          .skip(1)
          .firstOrNull ??
      '';
  return fileLocation
      .substring(fileLocation.indexOf('(') + 1, fileLocation.indexOf(')'))
      .trim();
}
