import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'details_page.dart';
import 'explore.dart';
import 'profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import firebase_auth package for user email
import 'login_page.dart'; // Import your login page

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> imgList = [
    'https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg',
    'https://images.pexels.com/photos/70497/pexels-photo-70497.jpeg',
    'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg',
  ];

  String? selectedCategory = 'All'; // Initialize with 'All'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('El-Foody'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Menu'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Explore'), // Add Explore option
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExplorePage()),
                );
              },
            ),
            ListTile(
              title: Text('Profile'), // Add Profile option
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore), // Changed from category to explore icon
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon:
                Icon(Icons.person), // Changed from shopping_cart to person icon
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Navigate to HomePage (already on home page)
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ExplorePage()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
              break;
          }
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CarouselSlider(
              options: CarouselOptions(
                height: 200.0,
                autoPlay: true,
                enlargeCenterPage: true,
              ),
              items: imgList
                  .map((item) => GestureDetector(
                        onTap: () {
                          // Navigate to details page with food id
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailsPage(
                                    foodId:
                                        'sample_food_id')), // Replace with actual food id
                          );
                        },
                        child: Container(
                          child: Center(
                            child: Image.network(item,
                                fit: BoxFit.cover, width: 1000),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Categories',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('foods').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                var categories = snapshot.data!.docs
                    .map((doc) => doc['category'])
                    .toSet()
                    .toList();
                categories.insert(
                    0, 'All'); // Insert 'All' category at the beginning
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                          child: Chip(
                            label: Text(category ?? '',
                                style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Available Foods',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            StreamBuilder(
              stream: (selectedCategory == 'All')
                  ? FirebaseFirestore.instance.collection('foods').snapshots()
                  : FirebaseFirestore.instance
                      .collection('foods')
                      .where('category', isEqualTo: selectedCategory)
                      .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: snapshot.data!.docs.map((food) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                // Navigate to details page with food id
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DetailsPage(foodId: food.id)),
                                );
                              },
                              child: Card(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Image.network(food['imageUrl'] ?? '',
                                        height: 100,
                                        width: 150,
                                        fit: BoxFit.cover),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(food['name'] ?? '',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(food['category'] ?? '',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('\$${food['price'] ?? ''}',
                                          style: TextStyle(fontSize: 16)),
                                    ),
                                    StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('reviews')
                                          .where('food_id', isEqualTo: food.id)
                                          .snapshots(),
                                      builder: (context,
                                          AsyncSnapshot<QuerySnapshot>
                                              reviewSnapshot) {
                                        if (!reviewSnapshot.hasData)
                                          return SizedBox();
                                        var ratings = reviewSnapshot.data!.docs
                                            .map((doc) => doc['rating'] ?? 0)
                                            .toList();
                                        double averageRating = ratings.isEmpty
                                            ? 0
                                            : ratings.reduce((a, b) => a + b) /
                                                ratings.length;
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: <Widget>[
                                              RatingBar.builder(
                                                initialRating: averageRating,
                                                minRating: 1,
                                                direction: Axis.horizontal,
                                                allowHalfRating: true,
                                                itemCount: 5,
                                                itemSize: 20,
                                                itemBuilder: (context, _) =>
                                                    Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                                onRatingUpdate: (rating) {
                                                  // Handle rating update if needed
                                                  print(
                                                      'Rating updated to: $rating');
                                                },
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                averageRating
                                                    .toStringAsFixed(1),
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                    Icons.add_shopping_cart),
                                                onPressed: () {
                                                  // Add to cart functionality
                                                  _addToCart(food);
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(DocumentSnapshot food) async {
    // Add to cart logic
    User? user = FirebaseAuth.instance.currentUser; // Get the current user

    if (user != null) {
      await FirebaseFirestore.instance.collection('cart').add({
        'food_id': food.id,
        'food_image': food['imageUrl'],
        'food_name': food['name'],
        'price': food['price'],
        'user_email': user.email, // Add user email
      }).then((value) {
        print('Item added to cart successfully!');
      }).catchError((error) {
        print('Failed to add item to cart: $error');
      });
    } else {
      print('No user is signed in');
    }
  }
}
