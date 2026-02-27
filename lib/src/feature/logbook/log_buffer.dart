import 'dart:async' show scheduleMicrotask;
import 'dart:collection' show Queue;
import 'dart:convert';

import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../../logbook.dart';
import '../../common/model/log_message.dart';
import '../../common/util/log_message_to_csv.dart';
import '../data/logbook_repository.dart';

/// {@template log_buffer}
/// Log buffer.
/// {@endtemplate}
final class LogBuffer with ChangeNotifier {
  /// {@macro log_buffer}
  LogBuffer._internal();

  /// {@macro log_buffer_instance}
  static final LogBuffer _instance = LogBuffer._internal();

  final ILogbookRepository _logbookRepository = const LogbookRepositoryImpl();

  /// Instance
  static LogBuffer get instance => _instance;

  /// Buffer limit
  // 64kb -> 2^16
  // -> 1byte * 1024 = 1kb * 64 -> 64kb * 200(~log_messages_length)
  // -> 12800kb -> 12.8MB
  static const int bufferLimit = 65536;

  /// Queue
  final Queue<LogMessage> _queue = Queue<LogMessage>();

  /// Notification scheduled
  bool _notificationScheduled = false;

  /// Total logs count
  int _totalLogsCount = 0;

  /// This is the total logs count in the buffer
  int get totalLogsCount => _totalLogsCount;

  /// Get the logs
  Iterable<LogMessage> get logs => _queue;

  /// Get the logs prefix
  Iterable<String> get logsPrefix => _queue.map((log) => log.prefix).toSet();

  /// Search logs by text
  Iterable<LogMessage> searchLogs(String text) =>
      _queue.where((log) => log.message.contains(text));

  /// Clear the logs
  void clear() {
    _queue.clear();
    _scheduleNotification();
  }

  /// Add a log to the buffer
  void add(LogMessage log) {
    if (_queue.length >= bufferLimit) _queue.removeFirst();
    _queue.add(log);
    _totalLogsCount = (_totalLogsCount + 1).clamp(0, bufferLimit);
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
    _totalLogsCount = (_totalLogsCount + list.length).clamp(0, bufferLimit);
    _scheduleNotification();
  }

  /// Returns logs added after [sinceCount] total additions.
  Iterable<LogMessage> logsSince(int sinceCount) {
    final available = _queue.length;
    final newCount = (_totalLogsCount - sinceCount).clamp(0, available);
    return _queue.skip(available - newCount);
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

  /// Sends the logs to the server.
  Future<void> sendLogsToServer({
    required final Uri? uri,
    required final String debugFileName,
    required final Map<String, String>? multipartFileFields,
  }) async {
    if (uri == null) return;

    try {
      final file = await toCSVString();
      final bytes = utf8.encode(file);

      await _logbookRepository.sendLog(
        uri,
        bytes,
        fileName: debugFileName,
        fields: multipartFileFields,
      );
    } on Object catch (e, s) {
      l.s('Error on save and send to server: $e', s);
    }
  }

  @override
  void dispose() {
    _queue.clear();
    super.dispose();
  }
}
