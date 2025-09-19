import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignClassRoutinePage extends StatefulWidget {
  @override
  _AssignClassRoutinePageState createState() => _AssignClassRoutinePageState();
}

class _AssignClassRoutinePageState extends State<AssignClassRoutinePage> {
  String? _selectedShiftId, _selectedShiftName;
  String? _selectedClassId, _selectedClassName;
  String? _selectedBookId, _selectedBookName;
  String? _selectedTeacherId, _selectedTeacherName;
  String? _selectedDay;

  final List<String> _days = [
    "Saturday",
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday"
  ];

  /// 🔹 Assign Routine
  Future<void> _assignRoutine() async {
    if (_selectedShiftId == null ||
        _selectedClassId == null ||
        _selectedBookId == null ||
        _selectedTeacherId == null ||
        _selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ All fields are required")),
      );
      return;
    }

    // 🔹 কত Period আছে তা বের করি
    final existing = await FirebaseFirestore.instance
        .collection("class_routines")
        .where("Class ID", isEqualTo: _selectedClassId)
        .where("Shift ID", isEqualTo: _selectedShiftId)
        .where("Day", isEqualTo: _selectedDay)
        .get();

    final period = existing.docs.length + 1; // ✅ Next Period

    // 🔹 Save routine
    final newId = "CR${DateTime.now().millisecondsSinceEpoch}";
    await FirebaseFirestore.instance.collection("class_routines").doc(newId).set({
      "Routine ID": newId,
      "Shift ID": _selectedShiftId,
      "Shift Name": _selectedShiftName,
      "Class ID": _selectedClassId,
      "Class Name": _selectedClassName,
      "Book ID": _selectedBookId,
      "Book Name": _selectedBookName,
      "Teacher ID": _selectedTeacherId,
      "Teacher Name": _selectedTeacherName,
      "Day": _selectedDay,
      "Period": period.toString(), // ✅ এখানে সময়ের পরিবর্তে Period Save
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Routine Assigned Successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Assign Class Routine",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _assignRoutine,
                  icon: Icon(Icons.add, color: Colors.black),
                  label: Text("Save Routine",
                      style: TextStyle(color: Colors.black)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Divider(),

            // Form
            Expanded(
              child: ListView(
                children: [
                  // 🔹 Select Shift
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection("shifts").snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();
                      final shifts = snapshot.data!.docs;
                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Select Shift",
                          border: OutlineInputBorder(),
                        ),
                        items: shifts.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return DropdownMenuItem(
                            value: doc.id,
                            child: Text(data["Shift Name"]),
                          );
                        }).toList(),
                        onChanged: (val) {
                          final data = shifts.firstWhere((d) => d.id == val).data() as Map<String, dynamic>;
                          setState(() {
                            _selectedShiftId = val;
                            _selectedShiftName = data["Shift Name"];
                          });
                        },
                      );
                    },
                  ),
                  SizedBox(height: 10),

                  // 🔹 Select Class
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection("classes").snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();
                      final classes = snapshot.data!.docs;
                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Select Class",
                          border: OutlineInputBorder(),
                        ),
                        items: classes.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return DropdownMenuItem(
                            value: doc.id,
                            child: Text(data["Class Name"]),
                          );
                        }).toList(),
                        onChanged: (val) {
                          final data = classes.firstWhere((d) => d.id == val).data() as Map<String, dynamic>;
                          setState(() {
                            _selectedClassId = val;
                            _selectedClassName = data["Class Name"];
                          });
                        },
                      );
                    },
                  ),
                  SizedBox(height: 10),

                  // 🔹 Select Book
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection("books").snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();
                      final books = snapshot.data!.docs;
                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Select Book",
                          border: OutlineInputBorder(),
                        ),
                        items: books.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return DropdownMenuItem(
                            value: doc.id,
                            child: Text(data["Book Name"]),
                          );
                        }).toList(),
                        onChanged: (val) {
                          final data = books.firstWhere((d) => d.id == val).data() as Map<String, dynamic>;
                          setState(() {
                            _selectedBookId = val;
                            _selectedBookName = data["Book Name"];
                          });
                        },
                      );
                    },
                  ),
                  SizedBox(height: 10),

                  // 🔹 Select Teacher
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection("teachers").snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();
                      final teachers = snapshot.data!.docs;
                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Select Teacher",
                          border: OutlineInputBorder(),
                        ),
                        items: teachers.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return DropdownMenuItem(
                            value: doc.id,
                            child: Text(data["Name Ar"]),
                          );
                        }).toList(),
                        onChanged: (val) {
                          final data = teachers.firstWhere((d) => d.id == val).data() as Map<String, dynamic>;
                          setState(() {
                            _selectedTeacherId = val;
                            _selectedTeacherName = data["Name Ar"];
                          });
                        },
                      );
                    },
                  ),
                  SizedBox(height: 10),

                  // 🔹 Select Day
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Select Day",
                      border: OutlineInputBorder(),
                    ),
                    items: _days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (val) => setState(() => _selectedDay = val),
                  ),
                  SizedBox(height: 20),

                  Divider(),

                  // 🔹 Show Routine Table
                  Text("Routine Table", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("class_routines")
                        .orderBy("Period")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();
                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) return Text("No Routines Found");

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text("Class")),
                            DataColumn(label: Text("Day")),
                            DataColumn(label: Text("Shift")),
                            DataColumn(label: Text("Subject")),
                            DataColumn(label: Text("Teacher")),
                            DataColumn(label: Text("Period")),
                          ],
                          rows: docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return DataRow(cells: [
                              DataCell(Text(data["Class Name"] ?? "")),
                              DataCell(Text(data["Day"] ?? "")),
                              DataCell(Text(data["Shift Name"] ?? "")),
                              DataCell(Text(data["Book Name"] ?? "")),
                              DataCell(Text(data["Teacher Name"] ?? "")),
                              DataCell(Text("Period ${data["Period"] ?? ""}")),
                            ]);
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
