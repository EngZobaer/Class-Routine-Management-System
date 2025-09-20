import 'package:cloud_firestore/cloud_firestore.dart';

class DaysService {
  static Future<List<String>> getDays() async {
    final doc =
    await FirebaseFirestore.instance.collection("week").doc("week").get();

    if (!doc.exists) return [];

    final data = doc.data()!;
    final sortedKeys = data.keys.toList()
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    return sortedKeys.map((k) => data[k].toString()).toList();
  }
}
