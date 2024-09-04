import 'package:flutter/material.dart';
import 'signin.dart';
import 'homepage.dart'; // Import HomePage or any other screens you want to navigate to

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Set initial route
      routes: {
        '/': (context) => Signin(), // SignIn screen as the initial screen
        '/home': (context) => HomePage(
              staffId: '',
            ), // Define route for HomePage
        // Add other routes here
      },
    );
  }
}
