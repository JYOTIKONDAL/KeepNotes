import 'package:intl/intl.dart';

/// Formats [dateTime] for display in note list items.
class DateFormatter {
  DateFormatter._();

  static final DateFormat _listFormat = DateFormat('MMM d, yyyy • h:mm a');

  static String formatNoteDate(DateTime dateTime) {
    return _listFormat.format(dateTime);
  }
}
