import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherPage extends StatefulWidget {
  @override
  _TeacherPageState createState() => _TeacherPageState();
}

class _TeacherPageState extends State<TeacherPage> {
  final _teacherIdController = TextEditingController();
  final _nameBnController = TextEditingController();
  final _nameArController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();

  /// 🔹 Generate Next Teacher ID (T1, T2, ...)
  Future<String> _generateNextTeacherId() async {
    final snapshot = await FirebaseFirestore.instance.collection("teachers").get();
    final nextSL = snapshot.docs.length + 1;
    return "T$nextSL";
  }

  Future<void> _addTeacher() async {
    var teacherId = _teacherIdController.text.trim();
    final nameBn = _nameBnController.text.trim();
    final nameAr = _nameArController.text.trim();
    final mobile = _mobileController.text.trim();
    final email = _emailController.text.trim();

    if (nameBn.isEmpty || nameAr.isEmpty || mobile.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ All fields are required")),
      );
      return;
    }

    if (teacherId.isEmpty) {
      teacherId = await _generateNextTeacherId();
    }

    // 🔹 Duplicate check
    final idExists = await FirebaseFirestore.instance
        .collection("teachers")
        .where("Teacher ID", isEqualTo: teacherId)
        .get();
    final mobileExists = await FirebaseFirestore.instance
        .collection("teachers")
        .where("Mobile", isEqualTo: mobile)
        .get();
    final emailExists = await FirebaseFirestore.instance
        .collection("teachers")
        .where("Email", isEqualTo: email)
        .get();

    if (idExists.docs.isNotEmpty || mobileExists.docs.isNotEmpty || emailExists.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Duplicate Teacher ID, Mobile or Email already exists!")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection("teachers").doc(teacherId).set({
      "Teacher ID": teacherId,
      "Name Bn": nameBn,
      "Name Ar": nameAr,
      "Mobile": mobile,
      "Email": email,
    });

    _teacherIdController.clear();
    _nameBnController.clear();
    _nameArController.clear();
    _mobileController.clear();
    _emailController.clear();

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Teacher Added Successfully")),
    );
  }

  Future<void> _deleteTeacher(String id) async {
    await FirebaseFirestore.instance.collection("teachers").doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("🗑 Teacher Deleted")),
    );
  }

  void _showAddTeacherDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Add New Teacher", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _teacherIdController,
                  decoration: InputDecoration(
                    labelText: "Teacher ID (Leave empty for auto-generate)",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _nameBnController,
                  decoration: InputDecoration(
                    labelText: "Teacher Name (Bangla)",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _nameArController,
                  decoration: InputDecoration(
                    labelText: "Teacher Name (Arabic/English)",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _mobileController,
                  decoration: InputDecoration(
                    labelText: "Mobile Number",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(backgroundColor: Colors.grey.shade200),
              child: Text("Cancel", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: _addTeacher,
              style: TextButton.styleFrom(backgroundColor: Colors.grey.shade200),
              child: Text("Save", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  void _showEditTeacherDialog(Map<String, dynamic> teacherData, String docId) {
    _teacherIdController.text = teacherData["Teacher ID"];
    _nameBnController.text = teacherData["Name Bn"];
    _nameArController.text = teacherData["Name Ar"];
    _mobileController.text = teacherData["Mobile"];
    _emailController.text = teacherData["Email"];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Edit Teacher", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _teacherIdController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Teacher ID",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _nameBnController,
                  decoration: InputDecoration(
                    labelText: "Teacher Name (Bangla)",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _nameArController,
                  decoration: InputDecoration(
                    labelText: "Teacher Name (Arabic/English)",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _mobileController,
                  decoration: InputDecoration(
                    labelText: "Mobile Number",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(backgroundColor: Colors.grey.shade200),
              child: Text("Cancel", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection("teachers").doc(docId).update({
                  "Name Bn": _nameBnController.text.trim(),
                  "Name Ar": _nameArController.text.trim(),
                  "Mobile": _mobileController.text.trim(),
                  "Email": _emailController.text.trim(),
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("✅ Teacher Updated Successfully")),
                );
              },
              style: TextButton.styleFrom(backgroundColor: Colors.grey.shade200),
              child: Text("Update", style: TextStyle(color: Colors.black)),
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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Teachers Management", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _showAddTeacherDialog,
                  icon: Icon(Icons.add, color: Colors.black),
                  label: Text("Add Teacher", style: TextStyle(color: Colors.black)),
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
                stream: FirebaseFirestore.instance.collection("teachers").orderBy("Teacher ID").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return Center(child: Text("No Teachers Found"));

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final id = docs[index].id;
                      final teacherId = data["Teacher ID"] ?? "";
                      final nameBn = data["Name Bn"] ?? "";
                      final nameAr = data["Name Ar"] ?? "";
                      final mobile = data["Mobile"] ?? "";
                      final email = data["Email"] ?? "";

                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Section 1: ID
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: Text("ID: $teacherId",
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                              // Section 2: Names
                              Expanded(
                                flex: 2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(nameBn, style: TextStyle(fontSize: 15)),
                                    Text(nameAr, style: TextStyle(fontSize: 15)),
                                  ],
                                ),
                              ),
                              // Section 3: Mobile & Email
                              Expanded(
                                flex: 3,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Mobile: $mobile"),
                                    Text("Email: $email"),
                                  ],
                                ),
                              ),
                              // Section 4: Action Menu
                              PopupMenuButton<String>(
                                icon: Icon(Icons.add, color: Colors.black),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditTeacherDialog(data, id);
                                  } else if (value == 'delete') {
                                    _deleteTeacher(id);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text("Edit"),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text("Delete"),
                                  ),
                                ],
                              )
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
