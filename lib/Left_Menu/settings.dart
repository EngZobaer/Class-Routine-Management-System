import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _gmailCtrl = TextEditingController();
  final TextEditingController _mobileCtrl = TextEditingController();
  final TextEditingController _developerCtrl = TextEditingController();
  final TextEditingController _footerCtrl = TextEditingController();

  /// Save data to Firestore
  Future<void> saveInstituteInfo() async {
    await _firestore.collection('Institute_info').doc('institute_info').set({
      'institute_name': _nameCtrl.text,
      'address': _addressCtrl.text,
      'gmail': _gmailCtrl.text,
      'mobile_number': _mobileCtrl.text,
      'developer': _developerCtrl.text,
      'footer_info': _footerCtrl.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Institute Info Saved ✅")),
    );
  }

  /// Load data from Firestore
  Future<void> loadInstituteInfo() async {
    DocumentSnapshot doc = await _firestore
        .collection('Institute_info')
        .doc('institute_info')
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        _nameCtrl.text = data['institute_name'] ?? '';
        _addressCtrl.text = data['address'] ?? '';
        _gmailCtrl.text = data['gmail'] ?? '';
        _mobileCtrl.text = data['mobile_number'] ?? '';
        _developerCtrl.text = data['developer'] ?? '';
        _footerCtrl.text = data['footer_info'] ?? '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadInstituteInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Institute Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 2-column layout using Row + Expanded
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(labelText: "Institute Name"),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _gmailCtrl,
                          decoration: const InputDecoration(labelText: "Gmail"),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _developerCtrl,
                          decoration: const InputDecoration(labelText: "Developer"),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        TextField(
                          controller: _addressCtrl,
                          decoration: const InputDecoration(labelText: "Address"),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _mobileCtrl,
                          decoration: const InputDecoration(labelText: "Mobile Number"),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _footerCtrl,
                          decoration: const InputDecoration(labelText: "Footer Info"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: saveInstituteInfo,
                child: const Text("Save Info"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
