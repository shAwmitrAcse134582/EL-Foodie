import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ManageOrdersPage extends StatefulWidget {
  final String title;
  final String collection;
  final List<String> fields;
  final Map<String, dynamic>? defaultValues;

  ManageOrdersPage({
    required this.title,
    required this.collection,
    required this.fields,
    this.defaultValues,
  });

  @override
  _ManageOrdersPageState createState() => _ManageOrdersPageState();
}

class _ManageOrdersPageState extends State<ManageOrdersPage> {
  final Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    for (String field in widget.fields) {
      controllers[field] = TextEditingController();
      if (widget.defaultValues != null &&
          widget.defaultValues!.containsKey(field)) {
        controllers[field]!.text = widget.defaultValues![field].toString();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showDialog({DocumentSnapshot? doc, required bool isEditing}) {
    if (isEditing && doc != null) {
      for (String field in widget.fields) {
        controllers[field]!.text = doc[field].toString();
      }
    } else {
      controllers.forEach((key, controller) {
        controller.clear();
      });
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('${isEditing ? 'Edit' : 'Add'} ${widget.title}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...widget.fields.map((field) {
                      return TextFormField(
                        controller: controllers[field],
                        decoration: InputDecoration(
                          labelText: field.capitalize(),
                        ),
                        keyboardType: field == 'quantity'
                            ? TextInputType.number
                            : TextInputType.text,
                      );
                    }).toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Map<String, dynamic> data = {};
                    widget.fields.forEach((field) {
                      if (field == 'quantity') {
                        data[field] =
                            int.tryParse(controllers[field]!.text) ?? 0;
                      } else {
                        data[field] = controllers[field]!.text;
                      }
                    });

                    if (isEditing && doc != null) {
                      FirebaseFirestore.instance
                          .collection(widget.collection)
                          .doc(doc.id)
                          .update(data)
                          .then((_) {
                        Navigator.pop(context);
                      });
                    } else {
                      data['timestamp'] = DateTime.now(); // Add timestamp
                      FirebaseFirestore.instance
                          .collection(widget.collection)
                          .add(data)
                          .then((docRef) {
                        Navigator.pop(context);
                      });
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: DataSearchDelegate(
                  widget.collection,
                  widget.fields,
                  showDialogFunction: _showDialog,
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(widget.collection)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var documents = snapshot.data!.docs;
                  return SingleChildScrollView(
                    scrollDirection:
                        Axis.horizontal, // Enable horizontal scrolling
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('ID')),
                        ...widget.fields.map((field) =>
                            DataColumn(label: Text(field.capitalize()))),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: documents.map((doc) {
                        return DataRow(cells: [
                          DataCell(Text(doc.id)),
                          ...widget.fields.map((field) {
                            if (field == 'timestamp') {
                              // Format timestamp
                              DateTime? timestamp = doc[field]?.toDate();
                              String formattedDate =
                                  DateFormat('dd/MM/yyyy HH:mm')
                                      .format(timestamp!);
                              return DataCell(Text(formattedDate));
                            } else {
                              return DataCell(
                                  Text(doc[field]?.toString() ?? ''));
                            }
                          }).toList(),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  _showDialog(doc: doc, isEditing: true);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  FirebaseFirestore.instance
                                      .collection(widget.collection)
                                      .doc(doc.id)
                                      .delete();
                                },
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDialog(isEditing: false);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class DataSearchDelegate extends SearchDelegate<String> {
  final String collectionName;
  final List<String> fields;
  final Function({DocumentSnapshot? doc, required bool isEditing})
      showDialogFunction;

  DataSearchDelegate(this.collectionName, this.fields,
      {required this.showDialogFunction});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collectionName).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var filteredDocs = snapshot.data!.docs.where((doc) {
          return fields.any((field) {
            var fieldValue = doc[field]?.toString().toLowerCase() ?? '';
            return fieldValue.contains(query.toLowerCase());
          });
        }).toList();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Enable horizontal scrolling
          child: DataTable(
            columns: [
              DataColumn(label: Text('ID')),
              ...fields
                  .map((field) => DataColumn(label: Text(field.capitalize()))),
              DataColumn(label: Text('Actions')),
            ],
            rows: filteredDocs.map((doc) {
              return DataRow(cells: [
                DataCell(Text(doc.id)),
                ...fields.map((field) {
                  if (field == 'timestamp') {
                    // Format timestamp
                    DateTime? timestamp = doc[field]?.toDate();
                    String formattedDate =
                        DateFormat('dd/MM/yyyy HH:mm').format(timestamp!);
                    return DataCell(Text(formattedDate));
                  } else {
                    return DataCell(Text(doc[field]?.toString() ?? ''));
                  }
                }).toList(),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        showDialogFunction(doc: doc, isEditing: true);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection(collectionName)
                            .doc(doc.id)
                            .delete();
                      },
                    ),
                  ],
                )),
              ]);
            }).toList(),
          ),
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
