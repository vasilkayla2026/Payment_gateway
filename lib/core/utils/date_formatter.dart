import 'package:intl/intl.dart';

final DateFormat _dateTimeFormat = DateFormat('d MMM y, h:mm a');

/// Formats a moment in the device's time zone, e.g. `16 Oct 2026, 2:38 PM`.
String formatDateTime(DateTime dateTime) =>
    _dateTimeFormat.format(dateTime.toLocal());
