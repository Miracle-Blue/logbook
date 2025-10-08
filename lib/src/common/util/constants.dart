/// {@template constants}
/// Constants class.
/// {@endtemplate}
sealed class Constants {
  /// {@macro constants}
  const Constants._();

  /// Ansi escape
  static const String esc = '\x1B[';

  /// Ansi reset
  static const String reset = '0m';

  static const telegramBaseUrl = 'https://api.telegram.org';
}
