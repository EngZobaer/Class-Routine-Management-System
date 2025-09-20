import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShiftPage extends StatefulWidget {
  @override
  _ShiftPageState createState() => _ShiftPageState();
}

class _ShiftPageState extends State<ShiftPage> {
  final _shiftNameController = TextEditingController();
  final _perClassTimeController = TextEditingController();
  final _totalPeriodsController = TextEditingController();
  TimeOfDay? _selectedStartTime;

  Future<void> _addShift() async {
    final shiftName = _shiftNameController.text.trim();
    final perClassTime = int.tryParse(_perClassTimeController.text.trim()) ?? 0;
    final totalPeriods = int.tryParse(_totalPeriodsController.text.trim()) ?? 0;

    if (shiftName.isEmpty || _selectedStartTime == null || perClassTime <= 0 || totalPeriods <= 0) return;

    final startFormatted =
        "${_selectedStartTime!.hour.toString().padLeft(2, "0")}:${_selectedStartTime!.minute.toString().padLeft(2, "0")}";

    final newId = DateTime.now().millisecondsSinceEpoch.toString();

    await FirebaseFirestore.instance.collection("shifts").doc(newId).set({
      "Shift Name": shiftName,
      "start_time": startFormatted,
      "duration": perClassTime,
      "total_periods": totalPeriods,
    });

    _shiftNameController.clear();
    _perClassTimeController.clear();
    _totalPeriodsController.clear();
    _selectedStartTime = null;

    Navigator.pop(context);
  }

  Future<void> _deleteShift(String id) async {
    await FirebaseFirestore.instance.collection("shifts").doc(id).delete();
  }

  Future<void> _editShift(String id, String shiftName, String startTime, int duration, int totalPeriods) async {
    _shiftNameController.text = shiftName;
    _perClassTimeController.text = duration.toString();
    _totalPeriodsController.text = totalPeriods.toString();

    final parts = startTime.split(":");
    _selectedStartTime = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts[1]) ?? 0,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Shift"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _shiftNameController,
                  decoration: InputDecoration(
                    labelText: "Shift Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),

                // ✅ Time Picker
                InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _selectedStartTime ?? TimeOfDay(hour: 9, minute: 0),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedStartTime = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Class Start Time",
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _selectedStartTime == null
                          ? "Select Time"
                          : "${_selectedStartTime!.hour.toString().padLeft(2, "0")}:${_selectedStartTime!.minute.toString().padLeft(2, "0")}",
                    ),
                  ),
                ),
                SizedBox(height: 10),

                TextField(
                  controller: _perClassTimeController,
                  decoration: InputDecoration(
                    labelText: "Per Class Time (Minutes)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),

                TextField(
                  controller: _totalPeriodsController,
                  decoration: InputDecoration(
                    labelText: "Total Periods",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.black)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Update", style: TextStyle(color: Colors.black)),
              onPressed: () async {
                final startFormatted =
                    "${_selectedStartTime!.hour.toString().padLeft(2, "0")}:${_selectedStartTime!.minute.toString().padLeft(2, "0")}";

                await FirebaseFirestore.instance.collection("shifts").doc(id).update({
                  "Shift Name": _shiftNameController.text.trim(),
                  "start_time": startFormatted,
                  "duration": int.tryParse(_perClassTimeController.text.trim()) ?? 0,
                  "total_periods": int.tryParse(_totalPeriodsController.text.trim()) ?? 0,
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddShiftDialog() {
    _shiftNameController.clear();
    _perClassTimeController.clear();
    _totalPeriodsController.clear();
    _selectedStartTime = null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Add New Shift", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _shiftNameController,
                  decoration: InputDecoration(
                    labelText: "Shift Name (Morning/Afternoon)",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),

                // ✅ Time Picker
                InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: 9, minute: 0),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedStartTime = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Class Start Time",
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _selectedStartTime == null
                          ? "Select Time"
                          : "${_selectedStartTime!.hour.toString().padLeft(2, "0")}:${_selectedStartTime!.minute.toString().padLeft(2, "0")}",
                    ),
                  ),
                ),
                SizedBox(height: 10),

                TextField(
                  controller: _perClassTimeController,
                  decoration: InputDecoration(
                    labelText: "Per Class Time (Minutes)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),

                TextField(
                  controller: _totalPeriodsController,
                  decoration: InputDecoration(
                    labelText: "Total Periods",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.black)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              onPressed: _addShift,
              child: Text("Save", style: TextStyle(color: Colors.black)),
            ),
          ],
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
                Text("Shift Management", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _showAddShiftDialog,
                  icon: Icon(Icons.add, color: Colors.black),
                  label: Text("Add Shift", style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
            SizedBox(height: 20),
            Divider(),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("shifts").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return Center(child: Text("No Shifts Found"));

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final id = docs[index].id;
                      final shiftName = data["Shift Name"] ?? "";
                      final startTime = data["start_time"] ?? "";
                      final duration = data["duration"] ?? 0;
                      final totalPeriods = data["total_periods"] ?? 0;

                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: Icon(Icons.access_time, color: Colors.blue),
                          title: Text(shiftName, style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Start: $startTime | Duration: $duration mins | Periods: $totalPeriods"),
                          trailing: PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, color: Colors.black),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _editShift(id, shiftName, startTime, duration, totalPeriods);
                              } else if (value == 'delete') {
                                _deleteShift(id);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [Icon(Icons.edit, color: Colors.black), SizedBox(width: 8), Text("Edit")],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text("Delete")],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
