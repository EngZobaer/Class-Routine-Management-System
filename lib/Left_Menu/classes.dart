import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassPage extends StatefulWidget {
  @override
  _ClassPageState createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {
  final _classNameController = TextEditingController();

  /// Add Class
  Future<void> _addClass() async {
    final className = _classNameController.text.trim();
    if (className.isEmpty) return;

    // মোট ডকুমেন্ট সংখ্যা বের করি
    final snapshot = await FirebaseFirestore.instance.collection("classes").get();
    final nextSL = snapshot.docs.length + 1;
    final docId = "CL$nextSL";

    await FirebaseFirestore.instance.collection("classes").doc(docId).set({
      "SL": nextSL.toString(),
      "Class Name": className,
    });

    _classNameController.clear();
    Navigator.pop(context);
  }

  /// Delete Class
  Future<void> _deleteClass(String id) async {
    await FirebaseFirestore.instance.collection("classes").doc(id).delete();
  }

  /// Popup Dialog for Add
  void _showAddClassDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Add New Class", style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _classNameController,
            decoration: InputDecoration(
              labelText: "Class Name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.black)),
              style: TextButton.styleFrom(backgroundColor: Colors.grey.shade200),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              onPressed: _addClass,
              style: TextButton.styleFrom(backgroundColor: Colors.grey.shade200),
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
      backgroundColor: Colors.white, // পুরো ব্যাকগ্রাউন্ড সাদা
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Class Management", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _showAddClassDialog,
                  icon: Icon(Icons.add, color: Colors.black),
                  label: Text("Add Class", style: TextStyle(color: Colors.black)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Divider(),

            // Records
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("classes").orderBy("SL").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) return Center(child: Text("No Classes Found"));

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final id = docs[index].id;
                      final sl = data["SL"] ?? "";
                      final className = data["Class Name"] ?? "";

                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(sl, style: TextStyle(color: Colors.white)),
                          ),
                          title: Text(className, style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Doc ID: $id"),
                          trailing: TextButton(
                            onPressed: () => _deleteClass(id),
                            style: TextButton.styleFrom(backgroundColor: Colors.white),
                            child: Text("Delete", style: TextStyle(color: Colors.black)),
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
