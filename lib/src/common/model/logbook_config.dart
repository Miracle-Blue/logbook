// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;

/// {@template logbook_config}
/// Logbook config.
/// {@endtemplate}
@immutable
class LogbookConfig {
  /// {@macro logbook_config}
  const LogbookConfig({
    this.uri,
    this.multipartFileFields,
    this.debugFileName = 'debug_info.csv',
    this.enabled = kDebugMode,
    this.fontFamily = 'Monospace',
    this.themeMode = ThemeMode.system,
  });

  /// Your server URI.
  final Uri? uri;

  /// Your multipart file fields.
  final Map<String, String>? multipartFileFields;

  /// Debug file name to display file name in the message.
  final String debugFileName;

  /// Whether to enable logbook.
  final bool enabled;

  /// Font family to use for the logbook.
  final String fontFamily;

  /// Theme mode to use for changing the theme of the logbook.
  final ThemeMode themeMode;

  /// Copy with.
  LogbookConfig copyWith({
    Uri? uri,
    Map<String, String>? multipartFileFields,
    String? debugFileName,
    bool? enabled,
    String? fontFamily,
    ThemeMode? themeMode,
  }) => LogbookConfig(
    uri: uri ?? this.uri,
    multipartFileFields: multipartFileFields ?? this.multipartFileFields,
    debugFileName: debugFileName ?? this.debugFileName,
    enabled: enabled ?? this.enabled,
    fontFamily: fontFamily ?? this.fontFamily,
    themeMode: themeMode ?? this.themeMode,
  );

  @override
  bool operator ==(covariant LogbookConfig other) {
    if (identical(this, other)) return true;

    return other.uri == uri &&
        mapEquals(other.multipartFileFields, multipartFileFields) &&
        other.debugFileName == debugFileName &&
        other.enabled == enabled &&
        other.fontFamily == fontFamily &&
        other.themeMode == themeMode;
  }

  @override
  int get hashCode =>
      uri.hashCode ^
      multipartFileFields.hashCode ^
      debugFileName.hashCode ^
      enabled.hashCode ^
      fontFamily.hashCode ^
      themeMode.hashCode;

  @override
  String toString() =>
      'LogbookConfig('
      'uri: $uri, '
      'multipartFileFields: $multipartFileFields, '
      'debugFileName: $debugFileName, '
      'enabled: $enabled, '
      'fontFamily: $fontFamily, '
      'themeMode: $themeMode)';
}
