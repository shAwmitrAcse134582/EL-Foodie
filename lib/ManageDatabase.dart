import 'package:flutter/material.dart';
import 'manage_food_items_page.dart';
import 'manage_orders_page.dart';
import 'login_page.dart'; // Import your login page here

class ManageDatabasePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Database'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Navigate to login page and remove all routes from the stack
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (Route<dynamic> route) => false, // Prevent going back to previous routes
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          Card(
            child: ListTile(
              title: Text('Manage FoodItems'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageFoodItemsPage(
                      title: 'Manage FoodItems',
                      collection: 'foods',
                      fields: ['category', 'description', 'name', 'price', 'imageUrl'],
                    ),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Manage Orders'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageOrdersPage(
                      title: 'Manage Orders',
                      collection: 'orders',
                      fields: ['address', 'foodId', 'name', 'phone', 'quantity', 'transactionId', 'timestamp'],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
