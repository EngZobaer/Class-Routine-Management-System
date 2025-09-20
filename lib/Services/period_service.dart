import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PeriodService {
  /// 🔹 Generate periods dynamically
  static List<Map<String, String>> generatePeriods(
      String startTime, int duration, int totalPeriods) {
    final parts = startTime.split(":");
    int hour = int.tryParse(parts[0]) ?? 9;
    int minute = int.tryParse(parts[1]) ?? 30;

    List<Map<String, String>> periods = [];

    for (int i = 1; i <= totalPeriods; i++) {
      final start = TimeOfDay(hour: hour, minute: minute);

      final endMinute = minute + duration;
      final endHour = hour + (endMinute ~/ 60);
      final end = TimeOfDay(hour: endHour, minute: endMinute % 60);

      periods.add({
        "period": "$i",
        "start":
        "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}",
        "end":
        "${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}",
      });

      // next iteration update
      hour = end.hour;
      minute = end.minute;
    }

    return periods;
  }

  /// 🔹 Get all periods for a shift
  static Future<List<Map<String, String>>> getAllPeriods(String shiftId) async {
    final shiftDoc =
    await FirebaseFirestore.instance.collection("shifts").doc(shiftId).get();

    if (!shiftDoc.exists) return [];

    final data = shiftDoc.data()!;
    final startTime = data["start_time"];
    final duration = data["duration"];
    final totalPeriods = data["total_periods"];

    return generatePeriods(startTime, duration, totalPeriods);
  }

  /// 🔹 Get available periods (not booked yet)
  static Future<List<Map<String, String>>> getAvailablePeriods(
      String shiftId, String day) async {
    final allPeriods = await getAllPeriods(shiftId);

    final existing = await FirebaseFirestore.instance
        .collection("class_routines")
        .where("Shift ID", isEqualTo: shiftId)
        .where("Day", isEqualTo: day)
        .get();

    final booked = existing.docs.map((d) => d["Period"].toString()).toSet();

    return allPeriods.where((p) => !booked.contains(p["period"])).toList();
  }
}
