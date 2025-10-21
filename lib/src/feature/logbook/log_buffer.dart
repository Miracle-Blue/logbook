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
  LogBuffer._internal() {
    _logbookRepository = const LogbookRepositoryImpl();
  }

  /// {@macro log_buffer_instance}
  static final LogBuffer _instance = LogBuffer._internal();

  late final ILogbookRepository _logbookRepository;

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
