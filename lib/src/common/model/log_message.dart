import 'package:flutter/foundation.dart';

import '../extension/date_time_extension.dart';
import 'console_color.dart';

/// {@template log_message}
/// Log message model.
/// {@endtemplate}
@immutable
final class LogMessage {
  /// {@macro log_message}
  const LogMessage({
    required this.message,
    required DateTime timestamp,
    required this.prefix,
    required this.color,
  }) : _timestamp = timestamp;

  /// The prefix of the log message.
  final String prefix;

  /// The message of the log message.
  final String message;

  /// The color of the log message.
  final ConsoleColor color;

  /// The timestamp of the log message.
  final DateTime _timestamp;

  /// The timestamp of the log message in the format of hh:mm:ss.
  String get timestamp => _timestamp.timeFormat(withMilliseconds: true);

  /// The timestamp of the log message in the format of UTC hh:mm:ss.
  String get timestampUtc =>
      'UTC ${_timestamp.toUtc().timeFormat(withMilliseconds: true)}';

  @override
  String toString() => '[$prefix]\t[$timestamp]\t$message';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LogMessage &&
        other.prefix == prefix &&
        other.message == message &&
        other.color == color &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode =>
      prefix.hashCode ^ message.hashCode ^ color.hashCode ^ timestamp.hashCode;
}
