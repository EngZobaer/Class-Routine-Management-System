import 'package:cloud_firestore/cloud_firestore.dart';

class DaysService {
  static Future<List<String>> getDays() async {
    final doc = await FirebaseFirestore.instance
        .collection("week")
        .doc("week")
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      // sort by numeric key (1,2,3...)
      final sortedKeys = data.keys.toList()
        ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
      return sortedKeys.map((key) => data[key].toString()).toList();
    }
    return [];
  }
}
