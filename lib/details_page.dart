import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'review.dart'; // Import your review.dart file
import 'order.dart'; // Import your order.dart file

class DetailsPage extends StatelessWidget {
  final String foodId;

  DetailsPage({required this.foodId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('foods').doc(foodId).get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No data found.'));
          }

          var food = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Image.network(food['imageUrl'], height: 300, fit: BoxFit.cover),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(food['name'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('\$${food['price']}', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(food['description'] ?? '', style: TextStyle(fontSize: 18)),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 4,
                    child: InkWell(
                      onTap: () {
                        // Navigate to review.dart with foodId
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReviewPage(foodId: foodId),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.rate_review, color: Colors.blue),
                            SizedBox(width: 10),
                            Text(
                              'Write a Review',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Implement call functionality
              },
              child: Text('Call Now'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to order.dart with foodId
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderPage(foodId: foodId),
                  ),
                );
              },
              child: Text('Order Now'),
            ),
          ],
        ),
      ),
    );
  }
}
