import 'package:flutter/foundation.dart';

import '../extension/date_time_extension.dart';
import 'console_color.dart';

@immutable
final class LogMessage {
  const LogMessage({
    required this.message,
    required DateTime timestamp,
    required this.prefix,
    required this.color,
  }) : _timestamp = timestamp;

  final String prefix;
  final String message;
  final ConsoleColor color;
  final DateTime _timestamp;

  String get timestamp => _timestamp.timeFormat(withMilliseconds: true);

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
