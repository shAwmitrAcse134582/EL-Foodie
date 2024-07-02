import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Cart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('cart')
                    .where('user_email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
                    .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          return ListView(
            children: snapshot.data!.docs.map((cartItem) {
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Image.network(cartItem['food_image'], width: 100, height: 100, fit: BoxFit.cover),
                  title: Text(cartItem['food_name']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // Remove item from cart
                      FirebaseFirestore.instance.collection('cart').doc(cartItem.id).delete()
                        .then((value) {
                          print('Item removed from cart successfully!');
                        })
                        .catchError((error) {
                          print('Failed to remove item from cart: $error');
                        });
                    },
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
