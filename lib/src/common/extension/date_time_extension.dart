/// Extension methods for [DateTime].
extension DateTimeX on DateTime? {
  /// Formats the time to a string
  /// example:
  ///   DateTime(2021, 1, 1, 12, 0, 0).timeFormat() -> 12:00:00 (hh:mm:ss)
  String timeFormat({bool withMilliseconds = false}) {
    final time = this;

    if (time == null) return '';

    String timePad(int time) => time.toString().padLeft(2, '0');

    final withMillisecondsString = withMilliseconds
        ? ':${timePad(time.millisecond)}'
        : '';

    return '${timePad(time.hour)}'
        ':${timePad(time.minute)}'
        ':${timePad(time.second)}'
        '$withMillisecondsString';
  }
}
