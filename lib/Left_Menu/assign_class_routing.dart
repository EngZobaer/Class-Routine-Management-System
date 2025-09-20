import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignClassRoutinePage extends StatefulWidget {
  @override
  _AssignClassRoutinePageState createState() => _AssignClassRoutinePageState();
}

class _AssignClassRoutinePageState extends State<AssignClassRoutinePage> {
  final _formKey = GlobalKey<FormState>();

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

  /// 🔹 Save or Update Routine
  Future<void> _saveRoutine(BuildContext context, {String? docId}) async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedShiftId == null ||
        _selectedClassId == null ||
        _selectedBookId == null ||
        _selectedTeacherId == null ||
        _selectedDay == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("⚠️ All fields are required")));
      return;
    }

    final existing = await FirebaseFirestore.instance
        .collection("class_routines")
        .where("Class ID", isEqualTo: _selectedClassId)
        .where("Shift ID", isEqualTo: _selectedShiftId)
        .where("Day", isEqualTo: _selectedDay)
        .get();

    final period = existing.docs.length + 1;

    final newId = docId ?? "CR${DateTime.now().millisecondsSinceEpoch}";
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
      "Period": period.toString(),
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(docId == null
            ? "✅ Routine Added Successfully"
            : "✅ Routine Updated Successfully")));
  }

  /// 🔹 Delete Routine
  Future<void> _deleteRoutine(String id) async {
    await FirebaseFirestore.instance.collection("class_routines").doc(id).delete();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("🗑 Routine Deleted")));
  }

  /// 🔹 Show Popup Form (Add or Edit)
  void _showRoutineFormPopup({Map<String, dynamic>? routineData, String? docId}) {
    if (routineData != null) {
      _selectedShiftId = routineData["Shift ID"];
      _selectedShiftName = routineData["Shift Name"];
      _selectedClassId = routineData["Class ID"];
      _selectedClassName = routineData["Class Name"];
      _selectedBookId = routineData["Book ID"];
      _selectedBookName = routineData["Book Name"];
      _selectedTeacherId = routineData["Teacher ID"];
      _selectedTeacherName = routineData["Teacher Name"];
      _selectedDay = routineData["Day"];
    } else {
      _selectedShiftId = null;
      _selectedShiftName = null;
      _selectedClassId = null;
      _selectedClassName = null;
      _selectedBookId = null;
      _selectedBookName = null;
      _selectedTeacherId = null;
      _selectedTeacherName = null;
      _selectedDay = null;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(docId == null ? "Add New Routine" : "Edit Routine",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildDropdown("shifts", "Shift Name", (val, name) {
                    _selectedShiftId = val;
                    _selectedShiftName = name;
                  }, selectedValue: _selectedShiftId),
                  SizedBox(height: 10),

                  _buildDropdown("classes", "Class Name", (val, name) {
                    _selectedClassId = val;
                    _selectedClassName = name;
                  }, selectedValue: _selectedClassId),
                  SizedBox(height: 10),

                  _buildDropdown("books", "Book Name", (val, name) {
                    _selectedBookId = val;
                    _selectedBookName = name;
                  }, selectedValue: _selectedBookId),
                  SizedBox(height: 10),

                  _buildDropdown("teachers", "Name Ar", (val, name) {
                    _selectedTeacherId = val;
                    _selectedTeacherName = name;
                  }, selectedValue: _selectedTeacherId),
                  SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Select Day",
                      border: OutlineInputBorder(),
                    ),
                    value: _days.contains(_selectedDay) ? _selectedDay : null,
                    validator: (val) => val == null ? "Please select day" : null,
                    items: _days
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedDay = val),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.black)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              onPressed: () => _saveRoutine(context, docId: docId),
              child: Text(docId == null ? "Save" : "Update"),
            ),
          ],
        );
      },
    );
  }

  /// 🔹 Reusable Dropdown Builder (safe value check)
  Widget _buildDropdown(String collection, String field,
      Function(String?, String?) onChanged,
      {String? selectedValue}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        final docs = snapshot.data!.docs;

        final items = docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return DropdownMenuItem(
            value: doc.id,
            child: Text(data[field]),
          );
        }).toList();

        final isValidValue = docs.any((doc) => doc.id == selectedValue);

        return DropdownButtonFormField<String>(
          value: isValidValue ? selectedValue : null,
          decoration: InputDecoration(
            labelText: "Select ${field.split(" ").first}",
            border: OutlineInputBorder(),
          ),
          validator: (val) => val == null ? "Please select $field" : null,
          items: items,
          onChanged: (val) {
            if (val == null) return;
            final data =
            docs.firstWhere((d) => d.id == val).data() as Map<String, dynamic>;
            setState(() => onChanged(val, data[field]));
          },
        );
      },
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Assign Class Routine",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () => _showRoutineFormPopup(),
                  icon: Icon(Icons.add, color: Colors.black),
                  label: Text("Add Routine", style: TextStyle(color: Colors.black)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Divider(),

            // Text("Routine Table",
            //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
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
                        DataColumn(label: Text("Actions")),
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
                          DataCell(
                            PopupMenuButton<String>(
                              icon: Icon(Icons.add, color: Colors.black),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showRoutineFormPopup(
                                      routineData: data, docId: doc.id);
                                } else if (value == 'delete') {
                                  _deleteRoutine(doc.id);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, color: Colors.blue),
                                      SizedBox(width: 8),
                                      Text("Edit"),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text("Delete"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
