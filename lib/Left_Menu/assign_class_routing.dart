import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/days_service.dart';
import '../services/period_service.dart'; // ✅ PeriodService import

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
  String? _selectedPeriod;

  // ✅ Custom time support
  String? _customStartTime;
  String? _customEndTime;

  List<String> _days = [];
  List<Map<String, String>> _availablePeriods = [];

  @override
  void initState() {
    super.initState();
    _loadDays();
  }

  Future<void> _loadDays() async {
    _days = await DaysService.getDays();
    setState(() {});
  }

  /// 🔹 Periods load (Shift + Day অনুযায়ী)
  Future<void> _loadPeriods() async {
    if (_selectedShiftId != null && _selectedDay != null) {
      final periods = await PeriodService.getAvailablePeriods(
        _selectedShiftId!,
        _selectedDay!,
      );
      setState(() {
        _availablePeriods = periods;
      });
    } else {
      setState(() {
        _availablePeriods = [];
      });
    }
  }

  /// 🔹 Save Routine
  Future<void> _saveRoutine(BuildContext context, {String? docId}) async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedShiftId == null ||
        _selectedClassId == null ||
        _selectedBookId == null ||
        _selectedTeacherId == null ||
        _selectedDay == null ||
        _selectedPeriod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ All fields are required")),
      );
      return;
    }

    // Period data resolve
    final selectedPeriodData = _availablePeriods.firstWhere(
          (p) => p["period"] == _selectedPeriod,
      orElse: () => {
        "period": _selectedPeriod!,
        "start": _customStartTime ?? "-",
        "end": _customEndTime ?? "-",
      },
    );

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
      "Period": selectedPeriodData["period"],
      "StartTime": selectedPeriodData["start"],
      "EndTime": selectedPeriodData["end"],
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(docId == null
          ? "✅ Routine Added Successfully"
          : "✅ Routine Updated Successfully"),
    ));
  }

  /// 🔹 Delete Routine
  Future<void> _deleteRoutine(String id) async {
    await FirebaseFirestore.instance.collection("class_routines").doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("🗑 Routine Deleted")),
    );
  }

  /// 🔹 Form Popup
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
      _selectedPeriod = routineData["Period"];
      _customStartTime = routineData["StartTime"];
      _customEndTime = routineData["EndTime"];
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
      _selectedPeriod = null;
      _customStartTime = null;
      _customEndTime = null;
    }

    _loadPeriods();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            docId == null ? "Add New Routine" : "Edit Routine",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildDropdown("shifts", "Shift Name", (val, name) {
                    _selectedShiftId = val;
                    _selectedShiftName = name;
                    _loadPeriods(); // reload periods
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

                  /// 🔹 Day select
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
                    onChanged: (val) {
                      setState(() => _selectedDay = val);
                      _loadPeriods(); // reload on day change
                    },
                  ),
                  SizedBox(height: 10),

                  /// 🔹 Period select
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Select Period",
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedPeriod,
                    validator: (val) => val == null ? "Please select period" : null,
                    items: [
                      ..._availablePeriods.map(
                            (p) => DropdownMenuItem(
                          value: p["period"],
                          child: Text(
                              "Period ${p["period"]} (${p["start"]} - ${p["end"]})"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Custom",
                        child: Text("Custom Period (Override)"),
                      ),
                    ],
                    onChanged: (val) => setState(() => _selectedPeriod = val),
                  ),

                  /// 🔹 Custom Period picker
                  if (_selectedPeriod == "Custom") ...[
                    SizedBox(height: 10),
                    InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(hour: 9, minute: 0),
                        );
                        if (picked != null) {
                          setState(() {
                            _customStartTime =
                            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: "Custom Start Time",
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_customStartTime ?? "Pick Time"),
                      ),
                    ),
                    SizedBox(height: 10),
                    InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(hour: 10, minute: 0),
                        );
                        if (picked != null) {
                          setState(() {
                            _customEndTime =
                            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: "Custom End Time",
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_customEndTime ?? "Pick Time"),
                      ),
                    ),
                  ],
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

  /// 🔹 Dropdown Builder
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
                        DataColumn(label: Text("Time")),
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
                          DataCell(Text(
                              "${data["StartTime"] ?? ""} - ${data["EndTime"] ?? ""}")),
                          DataCell(
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert, color: Colors.black),
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
