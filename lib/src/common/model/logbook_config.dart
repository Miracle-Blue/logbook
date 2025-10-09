import 'package:flutter/foundation.dart';

/// {@template logbook_config}
/// Logbook config.
/// {@endtemplate}
@immutable
final class LogbookConfig {
  /// {@macro logbook_config}
  const LogbookConfig({
    this.uri,
    this.multipartFileFields,
    this.debugFileName = 'debug_info.csv',
    this.enabled = kDebugMode,
  });

  ///
  final Uri? uri;

  ///
  final Map<String, String>? multipartFileFields;

  /// Debug file name to display file name in telegram message.
  final String debugFileName;

  /// Whether to enable logbook.
  final bool enabled;
}
