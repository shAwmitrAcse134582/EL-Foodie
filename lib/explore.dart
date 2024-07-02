import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'details_page.dart';
import 'profile_page.dart';
import 'login_page.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String searchQuery = ''; // To store user's search query

  // Function to format search query
  String formatSearchQuery(String query) {
    return query.trim().toLowerCase();
  }

  int _selectedIndex = 1; // Current index for the bottom navigation bar

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          Navigator.pop(context);
          break;
        case 1:
          // Navigate to ExplorePage (already on explore page)
          break;
      }
    });
  }

  void _handleLogout() {
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore Foods'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by food name...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    // Trigger search query update
                    setState(() {});
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = formatSearchQuery(value);
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: searchQuery.isEmpty
                  ? FirebaseFirestore.instance.collection('foods').snapshots()
                  : FirebaseFirestore.instance
                      .collection('foods')
                      .where('name', isGreaterThanOrEqualTo: searchQuery)
                      .where('name',
                          isLessThanOrEqualTo: searchQuery + '\uf8ff')
                      .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No foods available'));
                }

                return ListView(
                  children: snapshot.data!.docs.map((food) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsPage(foodId: food.id),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text(food['name']),
                        subtitle: Text(food['category']),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(food['imageUrl'] ?? ''),
                        ),
                        trailing: Text('\$${food['price']}'),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}
