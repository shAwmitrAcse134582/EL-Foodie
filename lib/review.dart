import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewPage extends StatefulWidget {
  final String foodId; // Pass food_id from previous screen

  ReviewPage({Key? key, required this.foodId}) : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  List<Map<String, dynamic>> reviews = []; // List to store reviews

  TextEditingController reviewController = TextEditingController();
  double rating = 0.0; // Initial rating value

  String? userEmail; // Variable to store user's email

  @override
  void initState() {
    super.initState();
    // Fetch currently logged-in user's email
    fetchUserEmail();
    // Fetch reviews when the widget initializes
    fetchReviews();
  }

  // Function to fetch currently logged-in user's email
  void fetchUserEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email;
      });
    }
  }

  // Function to fetch reviews from Firestore
  void fetchReviews() async {
    try {
      // Query Firestore for reviews with the current food_id
      var snapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('food_id', isEqualTo: widget.foodId)
          .get();

      // Clear previous reviews before updating with new data
      setState(() {
        reviews.clear();
        reviews = snapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      // Handle error fetching reviews
      print('Error fetching reviews: $e');
    }
  }

  // Function to submit review
  void submitReview() async {
    String reviewText = reviewController.text.trim();
    if (reviewText.isNotEmpty && rating > 0) {
      try {
        // Store review data in Firestore
        await FirebaseFirestore.instance.collection('reviews').add({
          'food_id': widget.foodId,
          'user_email': userEmail ?? 'Unknown', // Use userEmail if available, else fallback
          'review_text': reviewText,
          'rating': rating,
          'user_image': 'url_to_user_image.jpg', // Replace with user image URL
          'timestamp': Timestamp.now(), // Optional: Include timestamp
        });

        // Update local UI state
        setState(() {
          reviews.add({
            'user_email': userEmail ?? 'Unknown', // Use userEmail if available, else fallback
            'review_text': reviewText,
            'rating': rating,
            'user_image': 'url_to_user_image.jpg', // Replace with user image URL
          });
          reviewController.clear(); // Clear the text field after submission
          rating = 0.0; // Reset rating
        });

        // Optionally, show a success message or navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Review submitted successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        // Handle errors, e.g., FirestoreException
        print('Error submitting review: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit review. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Handle validation errors, e.g., empty review or rating
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a review and select a rating.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Write a Review',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                controller: reviewController,
                decoration: InputDecoration(
                  hintText: 'Enter your review...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Rating: '),
                  SizedBox(width: 10),
                  Slider(
                    value: rating,
                    onChanged: (newRating) {
                      setState(() {
                        rating = newRating;
                      });
                    },
                    min: 0,
                    max: 5,
                    divisions: 5,
                    label: rating.toStringAsFixed(1),
                  ),
                  Text(rating.toStringAsFixed(1)),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: submitReview,
                child: Text('Submit'),
              ),
              Divider(height: 30, thickness: 2),
              Text(
                'User Reviews',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              reviews.isEmpty
                  ? Text('No reviews yet.')
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        var review = reviews[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(review['user_image']),
                            ),
                            title: Text(review['user_email']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(review['review_text']),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(Icons.star,
                                        color: Colors.amber, size: 18),
                                    SizedBox(width: 5),
                                    Text(review['rating'].toStringAsFixed(1)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
