extension DateTimeX on DateTime? {
  String timeFormat({bool withMilliseconds = false}) {
    final time = this;

    if (time == null) return '';

    String _timePad(int time) => time.toString().padLeft(2, '0');

    return '${_timePad(time.hour)}:${_timePad(time.minute)}:${_timePad(time.second)}${withMilliseconds ? ':${_timePad(time.millisecond)}' : ''}';
  }
}
