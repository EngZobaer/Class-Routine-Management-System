import 'package:cloud_firestore/cloud_firestore.dart';
import '../modiul/periods.dart';

class PeriodService {
  /// 🔹 নির্দিষ্ট Shift থেকে সব Period বের করো
  static Future<List<Map<String, String>>> getAllPeriods(
      String shiftId) async {
    final shiftDoc = await FirebaseFirestore.instance
        .collection("shifts")
        .doc(shiftId)
        .get();

    if (!shiftDoc.exists) return [];

    final shiftData = shiftDoc.data()!;
    final startTime = shiftData["start_time"];   // যেমন "09:30"
    final duration = shiftData["duration"];      // যেমন 40
    final totalPeriods = shiftData["total_periods"]; // যেমন 6

    return generatePeriods(startTime, duration, totalPeriods);
  }

  /// 🔹 Available Period বের করো (যেটা এখনো booked হয়নি)
  static Future<List<Map<String, String>>> getAvailablePeriods(
      String shiftId, String day) async {
    // সব Period বের করো
    final allPeriods = await getAllPeriods(shiftId);

    // ওই দিন + shift এ booked periods আনো
    final existing = await FirebaseFirestore.instance
        .collection("routines")
        .where("Shift ID", isEqualTo: shiftId)
        .where("Day", isEqualTo: day)
        .get();

    final booked = existing.docs.map((d) => d["Period"].toString()).toSet();

    // শুধু available গুলো ফেরত দাও
    return allPeriods.where((p) => !booked.contains(p["period"])).toList();
  }
}
