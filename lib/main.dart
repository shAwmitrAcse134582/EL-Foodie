import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:food/home.dart';
import 'package:food/login_page.dart';
import 'package:food/register_page.dart'; // Ensure this import is correct

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyDc9ul-9-gtHcD8MGFUqNiLnpogb-obtro',
      appId: '1:1067965204470:android:322f92149555c16286e9d7',
      messagingSenderId: '1067965204470',
      projectId: 'bitebooker-df7f0',
      databaseURL: 'https://bitebooker-df7f0.firebaseio.com',
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BiteBooker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login', // Set the initial route
      routes: {
        '/home': (context) => HomePage(),
        '/register': (context) => RegistrationPage(),
        '/login': (context) => LoginPage(), // Define the home route
      },
    );
  }
}
