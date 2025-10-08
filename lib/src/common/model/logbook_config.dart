import 'package:flutter/foundation.dart';

/// {@template logbook_config}
/// Logbook config.
/// {@endtemplate}
@immutable
final class LogbookConfig {
  /// {@macro logbook_config}
  const LogbookConfig({
    this.telegramBotToken,
    this.telegramChatId,
    this.debugFileName = 'debug_info.csv',
    this.enabled = kDebugMode,
  });

  /// Telegram bot token to send logs to Telegram.
  final String? telegramBotToken;

  /// Telegram chat id to send logs to Telegram.
  final String? telegramChatId;

  /// Debug file name to display file name in telegram message.
  final String debugFileName;

  /// Whether to enable logbook.
  final bool enabled;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LogbookConfig &&
        other.telegramBotToken == telegramBotToken &&
        other.telegramChatId == telegramChatId &&
        other.debugFileName == debugFileName &&
        other.enabled == enabled;
  }

  @override
  int get hashCode =>
      telegramBotToken.hashCode ^
      telegramChatId.hashCode ^
      debugFileName.hashCode ^
      enabled.hashCode;
}
