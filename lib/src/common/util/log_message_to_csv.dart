import 'package:flutter/foundation.dart' show compute;

import '../../feature/logbook/log_buffer.dart';

/// {@template log_message_to_csv}
/// Log message to CSV extension.
/// {@endtemplate}
extension LogMessageToCSV on LogBuffer {
  /// CSV BOM for correct csv file formatting
  static const String _csvBom = '\uFEFF';

  /// Writes a CSV file using [compute] for off-main-thread processing
  Future<String> toCSVString({bool addBomForExcel = true}) async {
    final rows = [
      ['prefix', 'timestamp', 'message'],
      ...logs.map((log) => [log.prefix, log.timestampUtc, log.message]),
    ];

    final csv = await compute(_listToCSV, rows);

    return '$_csvBom$csv';
  }
}

/// Converts a list of rows to CSV format
String _listToCSV(List<List<Object?>> rows) {
  final buffer = StringBuffer();
  for (var i = 0; i < rows.length; i++) {
    final row = rows[i];

    for (var j = 0; j < row.length; j++) {
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

  return buffer.toString();
}
