import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherRoutineDashboard extends StatelessWidget {
  const TeacherRoutineDashboard({Key? key}) : super(key: key);

  /// 🔹 Group routines by Teacher
  Map<String, List<Map<String, dynamic>>> _groupByTeacher(List<QueryDocumentSnapshot> docs) {
    final Map<String, List<Map<String, dynamic>>> teacherRoutines = {};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final teacher = data['Teacher Name'] ?? "Unknown";
      teacherRoutines.putIfAbsent(teacher, () => []);
      teacherRoutines[teacher]!.add(data);
    }
    return teacherRoutines;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Teachers' Routines")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("class_routines").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final teacherRoutines = _groupByTeacher(snapshot.data!.docs);
          final teachers = teacherRoutines.keys.toList();

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 🔹 3 column
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final teacher = teachers[index];
              final routines = teacherRoutines[teacher]!;

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teacher,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Divider(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: routines.length,
                          itemBuilder: (context, i) {
                            final data = routines[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                "${data['Day']} - ${data['Class Name']} (${data['Book Name']})",
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
