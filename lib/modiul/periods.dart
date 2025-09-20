import 'package:intl/intl.dart';

/// 🔹 Period Generator Utility
/// startTime = "09:30" (24hr বা 12hr format)
/// duration = প্রতি ক্লাসের সময় (মিনিটে)
/// count = মোট কয়টা period বানাতে হবে
List<Map<String, String>> generatePeriods(String startTime, int duration, int count) {
  final format = DateFormat("HH:mm"); // input "09:30"
  DateTime start = format.parse(startTime);

  List<Map<String, String>> periods = [];
  for (int i = 0; i < count; i++) {
    final end = start.add(Duration(minutes: duration));
    periods.add({
      "period": "${i + 1}",
      "start": DateFormat("hh:mm a").format(start),
      "end": DateFormat("hh:mm a").format(end),
    });
    start = end;
  }
  return periods;
}
