import 'dart:async' show TimeoutException;
import 'dart:isolate';

import '../../feature/logbook/log_buffer.dart';

extension LogMessageToCSV on LogBuffer {
  /// CSV BOM for correct csv file formatting
  static const String _csvBom = '\uFEFF';

  /// Writes a CSV file using an isolate for processing
  Future<String> toCSVString({bool addBomForExcel = true}) async {
    final receivePort = ReceivePort();

    final rows = [
      ['prefix', 'timestamp', 'message'],
      ...logs.map((log) => [log.prefix, log.timestampUtc, log.message]),
    ];

    try {
      // Spawn isolate
      await Isolate.spawn(_listToCSV, [receivePort.sendPort, rows]);

      // Wait for the CSV string with timeout
      final csv = await receivePort.first.timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('CSV generation timed out'),
      );

      return '$_csvBom$csv';
    } finally {
      receivePort.close();
    }
  }
}

/// Converts a list of rows to CSV format in an isolate
///
/// Usage example:
/// ```dart
/// await Isolate.spawn(_listToCSV, [receivePort.sendPort, rows]);
/// ```
@pragma('vm:entry-point')
void _listToCSV(List<Object> args) {
  final receivePort = args[0] as SendPort;
  final rows = args[1] as List<List<Object?>>? ?? [];

  final buffer = StringBuffer();
  for (var i = 0; i < rows.length; i++) {
    final row = rows[i];

    for (var j = 0; j < row.length; j++) {
      // Escape values containing commas, quotes, or newlines
      final value = row[j]?.toString() ?? '';

      if (value.contains(',') || value.contains('"') || value.contains('\n')) {
        buffer.write('"${value.replaceAll('"', '""')}"');
      } else {
        buffer.write(value);
      }

      if (j < row.length - 1) buffer.write(',');
    }
    if (i < rows.length - 1) buffer.write('\n');
  }

  receivePort.send(buffer.toString());
}
