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

  /// Your server URI.
  final Uri? uri;

  /// Your multipart file fields.
  final Map<String, String>? multipartFileFields;

  /// Debug file name to display file name in the message.
  final String debugFileName;

  /// Whether to enable logbook.
  final bool enabled;

  @override
  String toString() =>
      'LogbookConfig(uri: $uri, multipartFileFields: $multipartFileFields, debugFileName: $debugFileName, enabled: $enabled)';
}
