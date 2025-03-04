import 'package:intl/intl.dart';

String formatVisitTime(String timeStart, String timeFinish) {
  DateTime startDateTime = DateTime.parse(timeStart).toLocal();
  DateTime endDateTime = DateTime.parse(timeFinish).toLocal();

  DateFormat timeFormat = DateFormat("h:mma");

  String formattedStart = timeFormat.format(startDateTime);
  String formattedEnd = timeFormat.format(endDateTime);

  return "$formattedStart - $formattedEnd";
}

String formatStartTime(String timeStart) {
  DateTime startDateTime = DateTime.parse(timeStart).toLocal();

  DateFormat timeFormat = DateFormat("h:mma");

  String formattedStart = timeFormat.format(startDateTime);

  return formattedStart;
}
