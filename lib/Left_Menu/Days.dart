import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DaysPage extends StatelessWidget {
  const DaysPage({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _getDays() async {
    final doc = await FirebaseFirestore.instance.collection("week").doc("week").get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final sortedKeys = data.keys.toList()
        ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
      return sortedKeys
          .map((key) => {"id": key, "name": data[key].toString()})
          .toList();
    }
    return [];
  }

  Future<void> _editDay(BuildContext context, String id, String oldValue) async {
    String newValue = oldValue;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit Day"),
        content: TextField(
          controller: TextEditingController(text: oldValue),
          onChanged: (val) => newValue = val,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection("week").doc("week").update({
                id: newValue,
              });
              Navigator.pop(context);
            },
            child: Text("Save"),
          )
        ],
      ),
    );
  }

  Future<void> _deleteDay(BuildContext context, String id) async {
    final doc = await FirebaseFirestore.instance.collection("week").doc("week").get();
    if (doc.exists) {
      final data = Map<String, dynamic>.from(doc.data()!);
      data.remove(id);
      await FirebaseFirestore.instance.collection("week").doc("week").set(data);
    }
  }

  /// 🔹 নতুন দিন যোগ করা
  Future<void> _addDay(BuildContext context) async {
    String newDayName = "";
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add New Day"),
        content: TextField(
          decoration: InputDecoration(hintText: "Enter Day Name"),
          onChanged: (val) => newDayName = val,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (newDayName.trim().isEmpty) return;
              final doc = await FirebaseFirestore.instance.collection("week").doc("week").get();
              Map<String, dynamic> data = {};
              if (doc.exists) data = doc.data()!;
              // নতুন id হবে last key + 1
              final nextId = (data.keys.map((e) => int.tryParse(e) ?? 0).fold<int>(0, (a, b) => a > b ? a : b) + 1).toString();
              data[nextId] = newDayName;
              await FirebaseFirestore.instance.collection("week").doc("week").set(data);
              Navigator.pop(context);
            },
            child: Text("Save"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("সাপ্তাহিক দিনসমূহ")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getDays(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("কোনো দিন পাওয়া যায়নি"));
          }
          final days = snapshot.data!;
          return ListView.builder(
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              return Card(
                color: Colors.grey.shade100,
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(child: Text("${index + 1}")),
                  title: Text(day["name"], style: const TextStyle(fontSize: 18)),
                  trailing: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editDay(context, day["id"], day["name"]);
                      } else if (value == 'delete') {
                        _deleteDay(context, day["id"]);
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
              );
            },
          );
        },
      ),

      /// 🔹 Add Floating Button
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addDay(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
