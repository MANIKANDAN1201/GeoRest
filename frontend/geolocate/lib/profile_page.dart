import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'offsite_work_page.dart'; // Import the offsite work page
import 'camera.dart'; // Import the camera screen page

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> profileData = {}; // Holds fetched profile data
  bool isLoading = true; // Indicator for data loading

  @override
  void initState() {
    super.initState();
    fetchProfileDetails(); // Fetch the profile data when the page loads
  }

  Future<void> fetchProfileDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? staffId = prefs.getString('staffId'); // Ensure key is correct
    print(staffId); // Debug: Check retrieved staffId

    if (staffId == null) {
      // Handle missing staffId: e.g., navigate to login page
      Navigator.pushReplacementNamed(context, '/signin');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.102.81:4000/api/app/profileDetails'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "staffId": staffId, // Pass the correct staff ID from local storage
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          profileData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        // Handle error
        setState(() {
          isLoading = false;
        });
        print("Error fetching profile data: ${response.statusCode}");
      }
    } catch (e) {
      // Handle exception
      setState(() {
        isLoading = false;
      });
      print("Exception fetching profile data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("Profile"),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Show loader while data is fetching
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    Text(
                      profileData['name'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      profileData['email'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 30),
                    Divider(color: Colors.grey),
                    ProfileDetailRow(
                      label: "Staff ID",
                      value: profileData['staffId'] ?? 'N/A',
                    ),
                    ProfileDetailRow(
                      label: "Office ID",
                      value: profileData['officeId'] ?? 'N/A',
                    ),
                    ProfileDetailRow(
                      label: "Designation",
                      value: profileData['Designation'] ?? 'N/A',
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OffsiteWorkPage()),
                        );
                      },
                      child: Text("Switch to Offsite Mode"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CameraScreen(
                                    onBiometricsStatusChanged: (String) {},
                                  )),
                        );
                      },
                      child: Text("Open Camera"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class ProfileDetailRow extends StatelessWidget {
  final String label;
  final String value;

  ProfileDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.grey[900],
            ),
          ),
        ],
      ),
    );
  }
}
