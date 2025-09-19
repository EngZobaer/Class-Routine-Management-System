import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';

class BooksPage extends StatefulWidget {
  @override
  _BooksPageState createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  final _bookNameBnController = TextEditingController();
  final _bookNameEngController = TextEditingController();
  String? _selectedClassId;
  String? _selectedClassName;

  // 🔹 Filter state
  String? _filterClass;
  String? _filterBook;

  Future<void> _addBook() async {
    final bookBn = _bookNameBnController.text.trim();
    final bookEng = _bookNameEngController.text.trim();

    if (bookBn.isEmpty || bookEng.isEmpty || _selectedClassId == null) return;

    final newId = "B${DateTime.now().millisecondsSinceEpoch}";

    await FirebaseFirestore.instance.collection("books").doc(newId).set({
      "Book Name Bn": bookBn,
      "Book Name Eng": bookEng,
      "Class ID": _selectedClassId,
      "Class Name": _selectedClassName,
    });

    // ✅ Clear only book fields, keep class selection
    _bookNameBnController.clear();
    _bookNameEngController.clear();
  }

  void _showAddBookDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text("Add New Book", style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    // 🔹 Class Dropdown (Searchable)
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection("classes").orderBy("SL").snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final classes = snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return {
                            "id": doc.id,
                            "name": data["Class Name"] ?? "",
                          };
                        }).toList();

                        return DropdownSearch<Map<String, dynamic>>(
                          items: classes,
                          itemAsString: (cls) => cls!["name"],
                          selectedItem: _selectedClassId != null
                              ? classes.firstWhere(
                                (cls) => cls["id"] == _selectedClassId,
                            orElse: () => {"id": null, "name": ""},
                          )
                              : null,
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: "Select Class",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            constraints: BoxConstraints(maxHeight: 250),
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                labelText: "Search Class",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedClassId = value?["id"];
                              _selectedClassName = value?["name"];
                            });
                          },
                        );
                      },
                    ),
                    SizedBox(height: 10),

                    // 🔹 Book Name Bangla
                    TextField(
                      controller: _bookNameBnController,
                      decoration: InputDecoration(
                        labelText: "Book Name (Bangla)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),

                    // 🔹 Book Name English
                    TextField(
                      controller: _bookNameEngController,
                      decoration: InputDecoration(
                        labelText: "Book Name (English)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text("Cancel", style: TextStyle(color: Colors.black)),
                  style: TextButton.styleFrom(backgroundColor: Colors.grey.shade200),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  onPressed: _addBook,
                  style: TextButton.styleFrom(backgroundColor: Colors.grey.shade200),
                  child: Text("Save", style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteBook(String id) async {
    await FirebaseFirestore.instance.collection("books").doc(id).delete();
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
            // 🔹 Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 🔹 Filter Section
                Row(
                  children: [
                    // Class Filter
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection("books").snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return SizedBox();

                        final classList = snapshot.data!.docs
                            .map((doc) => doc["Class Name"] ?? "")
                            .toSet()
                            .toList();

                        return DropdownButton<String>(
                          hint: Text("Filter by Class"),
                          value: _filterClass,
                          items: classList.map((cls) {
                            return DropdownMenuItem<String>(
                              value: cls,
                              child: Text(cls),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _filterClass = value);
                          },
                        );
                      },
                    ),
                    SizedBox(width: 10),
                    // Subject Filter
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection("books").snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return SizedBox();

                        final bookList = snapshot.data!.docs
                            .map((doc) => doc["Book Name Eng"] ?? "")
                            .toSet()
                            .toList();

                        return DropdownButton<String>(
                          hint: Text("Filter by Subject"),
                          value: _filterBook,
                          items: bookList.map((subj) {
                            return DropdownMenuItem<String>(
                              value: subj,
                              child: Text(subj),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _filterBook = value);
                          },
                        );
                      },
                    ),
                    SizedBox(width: 10),
                    // ✅ Clear Button
                    if (_filterClass != null || _filterBook != null)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _filterClass = null;
                            _filterBook = null;
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                        ),
                        child: Text("Clear Filters", style: TextStyle(color: Colors.black)),
                      ),
                  ],
                ),

                // Add Button
                TextButton.icon(
                  onPressed: _showAddBookDialog,
                  icon: Icon(Icons.add, color: Colors.black),
                  label: Text("Add Book", style: TextStyle(color: Colors.black)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Divider(),

            // 🔹 Records Section
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("books").orderBy("Book Name Eng").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                  var docs = snapshot.data!.docs;

                  // Apply filters
                  if (_filterClass != null) {
                    docs = docs.where((d) => d["Class Name"] == _filterClass).toList();
                  }
                  if (_filterBook != null) {
                    docs = docs.where((d) => d["Book Name Eng"] == _filterBook).toList();
                  }

                  if (docs.isEmpty) {
                    return Center(child: Text("No Books Found"));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final id = docs[index].id;
                      final bookBn = data["Book Name Bn"] ?? "";
                      final bookEng = data["Book Name Eng"] ?? "";
                      final className = data["Class Name"] ?? "";

                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: Icon(Icons.menu_book, color: Colors.blue),
                          title: Text("$bookBn / $bookEng"),
                          subtitle: Text("Class: $className"),
                          trailing: TextButton(
                            onPressed: () => _deleteBook(id),
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
