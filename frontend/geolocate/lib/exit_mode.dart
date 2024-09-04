// exit_mode.dart
import 'package:flutter/material.dart';

class ExitModePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("Exit Mode"),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home'); // Navigate back to home page
          },
          child: Text('Exit Mode'),
        ),
      ),
    );
  }
}