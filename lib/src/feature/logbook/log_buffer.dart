import 'dart:async' show scheduleMicrotask;
import 'dart:collection' show Queue;

import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../common/model/log_message.dart';

/// {@template log_buffer}
/// Log buffer.
/// {@endtemplate}
final class LogBuffer with ChangeNotifier {
  /// {@macro log_buffer}
  LogBuffer._internal();

  /// {@macro log_buffer_instance}
  static final LogBuffer _instance = LogBuffer._internal();

  /// Instance
  static LogBuffer get instance => _instance;

  /// Buffer limit
  static const int bufferLimit =
      65536; // 64kb -> 2^16 -> 1byte*1024=1kb*64=64kb * 200 = 12800kb = 12.8MB

  /// Queue
  final Queue<LogMessage> _queue = Queue<LogMessage>();

  /// Notification scheduled
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
      for (var i = 0; i < toRemove; i++) {
        _queue.removeFirst();
      }
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
