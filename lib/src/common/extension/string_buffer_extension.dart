import '../util/constants.dart';

/// Extension methods for [StringBuffer].
extension StringBufferX on StringBuffer {
  /// Writes the escape sequence for the given value.
  void writeEsc(String value) {
    this
      ..write(Constants.esc)
      ..write(value);
  }

  /// Completes the message by adding the given message to the buffer.
  String completeMessage(Object message) =>
      (this
            ..write(']')
            ..write(' ')
            ..write(message))
          .toString();
}
