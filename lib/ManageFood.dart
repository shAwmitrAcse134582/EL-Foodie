import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageFood extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Food'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('foods').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var food = snapshot.data!.docs[index];
              return ListTile(
                title: Text(food['name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Category: ${food['category']} - \$${food['price']}'),
                    Text(food['description'] ?? ''), // Display description
                  ],
                ),
                leading: Image.network(food['imageUrl']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // Edit functionality
                        _editFood(context, food);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        FirebaseFirestore.instance.collection('foods').doc(food.id).delete();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addFood(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _addFood(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AddEditFoodDialog();
      },
    );
  }

  void _editFood(BuildContext context, DocumentSnapshot food) {
    showDialog(
      context: context,
      builder: (context) {
        return AddEditFoodDialog(food: food);
      },
    );
  }
}

class AddEditFoodDialog extends StatefulWidget {
  final DocumentSnapshot? food;

  AddEditFoodDialog({this.food});

  @override
  _AddEditFoodDialogState createState() => _AddEditFoodDialogState();
}

class _AddEditFoodDialogState extends State<AddEditFoodDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _category;
  late String _imageUrl;
  late double _price;
  late String _description;

  @override
  void initState() {
    super.initState();
    _name = widget.food?['name'] ?? '';
    _category = widget.food?['category'] ?? '';
    _imageUrl = widget.food?['imageUrl'] ?? '';
    _price = widget.food?['price'] != null ? widget.food!['price'].toDouble() : 0.0;
    _description = widget.food?['description'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.food == null ? 'Add Food' : 'Edit Food'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              initialValue: _name,
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              onSaved: (value) => _name = value!,
            ),
            TextFormField(
              initialValue: _category,
              decoration: InputDecoration(labelText: 'Category'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a category';
                }
                return null;
              },
              onSaved: (value) => _category = value!,
            ),
            TextFormField(
              initialValue: _imageUrl,
              decoration: InputDecoration(labelText: 'Image URL'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter an image URL';
                }
                return null;
              },
              onSaved: (value) => _imageUrl = value!,
            ),
            TextFormField(
              initialValue: _price.toString(),
              decoration: InputDecoration(labelText: 'Price'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a price';
                }
                return null;
              },
              onSaved: (value) => _price = double.parse(value!),
            ),
            TextFormField(
              initialValue: _description,
              decoration: InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
              onSaved: (value) => _description = value!,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(widget.food == null ? 'Add' : 'Update'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              if (widget.food == null) {
                FirebaseFirestore.instance.collection('foods').add({
                  'name': _name,
                  'category': _category,
                  'imageUrl': _imageUrl,
                  'price': _price,
                  'description': _description,
                });
              } else {
                FirebaseFirestore.instance.collection('foods').doc(widget.food!.id).update({
                  'name': _name,
                  'category': _category,
                  'imageUrl': _imageUrl,
                  'price': _price,
                  'description': _description,
                });
              }
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
