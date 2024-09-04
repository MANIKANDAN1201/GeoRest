import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CheckOutPage extends StatelessWidget {
  final String employeeId;
  final String currentDate;
  final String locationDetails;

  CheckOutPage({
    required this.employeeId,
    required this.currentDate,
    required this.locationDetails,
  });

  Future<void> submitCheckOut() async {
    final response = await http.post(
      Uri.parse('http://your_api_endpoint/api/attendance/$employeeId/checkout'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "date": currentDate,
        "checkOut": "06:00 PM", // Replace with actual time data
        "location": locationDetails,
      }),
    );

    if (response.statusCode == 201) {
      print('Check-Out submitted successfully');
    } else {
      print('Failed to submit Check-Out');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check-Out'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () async {
            await submitCheckOut();
          },
          icon: Icon(Icons.check, color: Colors.white),
          label: Text('Check-Out'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            textStyle: GoogleFonts.lato(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
