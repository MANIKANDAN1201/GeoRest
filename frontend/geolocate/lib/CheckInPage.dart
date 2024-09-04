import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CheckInPage extends StatelessWidget {
  final String employeeId;
  final String currentDate;
  final String locationDetails;

  CheckInPage({
    required this.employeeId,
    required this.currentDate,
    required this.locationDetails,
  });

  Future<void> submitCheckIn() async {
    final response = await http.post(
      Uri.parse('http://your_api_endpoint/api/attendance/$employeeId/checkin'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "date": currentDate,
        "checkIn": "09:00 AM", // Replace with actual time data
        "location": locationDetails,
      }),
    );

    if (response.statusCode == 201) {
      print('Check-In submitted successfully');
    } else {
      print('Failed to submit Check-In');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check-In'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () async {
            await submitCheckIn();
          },
          icon: Icon(Icons.check, color: Colors.white),
          label: Text('Check-In'),
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
