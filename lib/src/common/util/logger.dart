import 'dart:async' show scheduleMicrotask;
import 'dart:collection' show Queue;
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart' show kReleaseMode, ChangeNotifier;

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

  final void Function(Object? message) f = _log(
    'F',
    font: ConsoleFont.bold.value,
    foreground: ConsoleColor.black.foregroundValue,
  );

  void Function(Object? message) c = _log(
    'C',
    font: ConsoleFont.bold.value,
    foreground: ConsoleColor.green.foregroundValue,
  );

  void Function(Object? message) i = _log(
    'I',
    font: ConsoleFont.bold.value,
    foreground: ConsoleColor.blue.foregroundValue,
  );

  void Function(Object exception, [StackTrace? stackTrace, String? reason]) w =
      _log(
        'W',
        font: ConsoleFont.bold.value,
        foreground: ConsoleColor.yellow.foregroundValue,
        background: ConsoleColor.black.backgroundValue,
      );

  void Function(Object exception, [StackTrace? stackTrace, String? reason]) s =
      _log(
        'S',
        font: ConsoleFont.bold.value,
        foreground: ConsoleColor.red.foregroundValue,
      );

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
          // [$_esc$foreground] - for [message] color
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

String _formatStyled(
  Object message,
  String prefix, {
  String? font,
  String? foreground,
  String? background,
  bool withMilliseconds = false,
}) {
  final buffer = StringBuffer('[');
  for (final value in [font, foreground, background]) {
    if (value != null) buffer.writeEsc(value);
  }
  buffer
    ..write(prefix)
    ..writeEsc(Constants.reset);

  return buffer.completeMessage(
    // [_timeFormat(DateTime.now())] - this is for showing the time in the log
    '[${DateTime.now().timeFormat(withMilliseconds: withMilliseconds)}]$message',
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

/// Log buffer

class LogBuffer with ChangeNotifier {
  LogBuffer._internal();
  static final LogBuffer _instance = LogBuffer._internal();
  static LogBuffer get instance => _instance;

  static const int bufferLimit =
      65536; // 64kb -> 2^16 -> 1byte*1024=1kb*64=64kb * 200 = 12800kb = 12.8MB
  final Queue<LogMessage> _queue = Queue<LogMessage>();
  bool _notificationScheduled = false;

  /// Get the logs
  Iterable<LogMessage> get logs => _queue;

  /// Clear the logs
  void clear() {
    _queue.clear();
    _scheduleNotification();
  }

  /// Add a log to the buffer
  void add(LogMessage log) {
    if (_queue.length >= bufferLimit) _queue.removeFirst();
    _queue.add(log);
    _scheduleNotification();
  }

  /// Add a list of logs to the buffer
  void addAll(List<LogMessage> logs) {
    final list = logs.take(bufferLimit).toList();
    if (_queue.length + list.length > bufferLimit) {
      final toRemove = _queue.length + list.length - bufferLimit;
      for (var i = 0; i < toRemove; i++) _queue.removeFirst();
    }
    _queue.addAll(list);
    _scheduleNotification();
  }

  /// Schedule a notification to be sent after the current frame
  void _scheduleNotification() {
    if (_notificationScheduled) return;
    _notificationScheduled = true;
    scheduleMicrotask(() {
      _notificationScheduled = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _queue.clear();
    super.dispose();
  }
}
