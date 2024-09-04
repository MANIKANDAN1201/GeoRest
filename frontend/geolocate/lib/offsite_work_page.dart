import 'package:flutter/material.dart';
import 'package:geolocate/exit_mode.dart';
import 'package:geolocate/profile_page.dart';
import 'homepage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'location.dart';
import 'custom_nav_bar_2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OffsiteWorkPage extends StatefulWidget {
  @override
  _OffsiteWorkPageState createState() => _OffsiteWorkPageState();
}

class _OffsiteWorkPageState extends State<OffsiteWorkPage> {
  LocationService locationService = LocationService();
  String locationDetails = 'Fetching location...';
  String employeeId = '';
  String checkInTime = 'Not Checked In';
  String checkOutTime = 'Not Checked Out';
  String selectedLocation = '';
  String manualLocation = '';
  bool isCheckedIn = false;
  int _selectedIndex = 0;
  bool showCheckInMessage = false;
  bool showCheckOutMessage = false;

  @override
  void initState() {
    super.initState();
    _loadEmployeeId();
    _fetchCheckInStatus();
    locationService.requestLocationPermission();
    locationService.location.onLocationChanged.listen((locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        setState(() {
          locationDetails =
              'Lat: ${locationData.latitude}, Long: ${locationData.longitude}';
          suggestLocation(locationData.latitude!, locationData.longitude!);
        });
      }
    });
  }

  Future<void> _loadEmployeeId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      employeeId = prefs.getString('staffId') ?? '';
    });
  }

  Future<void> _fetchCheckInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final checkIn = prefs.getString('checkInTime');
    final checkOut = prefs.getString('checkOutTime');
    final status = prefs.getBool('isCheckedIn') ?? false;

    setState(() {
      checkInTime = checkIn ?? 'Not Checked In';
      checkOutTime = checkOut ?? 'Not Checked Out';
      isCheckedIn = status;
      showCheckInMessage = status;
      showCheckOutMessage = !status;
    });
  }

  void suggestLocation(double latitude, double longitude) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.102.81:8080/api/offsite/suggestLocation'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "latitude": latitude,
          "longitude": longitude,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['suggestedLocation'] != null) {
          setState(() {
            selectedLocation = data['suggestedLocation']['name'];
            manualLocation = selectedLocation;
          });
        } else {
          _showNoLocationDialog();
        }
      } else {
        setState(() {
          selectedLocation = 'Error fetching suggested location';
        });
      }
    } catch (e) {
      setState(() {
        selectedLocation = 'Error: $e';
      });
    }
  }

  void _showNoLocationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Suggested Location'),
          content: Text('No nearby location found. Please enter manually.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> submitCheckIn() async {
    final response = await http.post(
      Uri.parse('http://192.168.102.81:8080/api/attendance/checkin'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "staffId": employeeId,
        "time": DateTime.now().toIso8601String(),
        "location":
            manualLocation.isNotEmpty ? manualLocation : locationDetails,
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        checkInTime = DateTime.now().toString().split(' ')[1].split('.')[0];
        isCheckedIn = true;
        showCheckInMessage = true;
        showCheckOutMessage = false;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('checkInTime', checkInTime);
      await prefs.setBool('isCheckedIn', true);
    }
  }

  Future<void> submitCheckOut() async {
    final response = await http.post(
      Uri.parse('http://192.168.102.81:8080/api/attendance/checkout'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "staffId": employeeId,
        "time": DateTime.now().toIso8601String(),
        "location":
            manualLocation.isNotEmpty ? manualLocation : locationDetails,
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        checkOutTime = DateTime.now().toString().split(' ')[1].split('.')[0];
        isCheckedIn = false;
        showCheckInMessage = false;
        showCheckOutMessage = true;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('checkOutTime', checkOutTime);
      await prefs.setBool('isCheckedIn', false);
    }
  }

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OffsiteWorkPage()),
        );
      } else if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage(staffId: '',)),
        );
      }
      // Reset messages when navigating
      showCheckInMessage = false;
      showCheckOutMessage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location Details
              Text('Current Location:',
                  style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              SizedBox(height: 10),
              Text(
                locationDetails,
                style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[800]),
              ),
              SizedBox(height: 20),
              // Suggested Location
              Text('Suggested Location:',
                  style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              SizedBox(height: 10),
              Text(
                selectedLocation,
                style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[800]),
              ),
              SizedBox(height: 20),
              // Manual Location Input
              TextField(
                controller: TextEditingController(text: manualLocation),
                onChanged: (value) {
                  setState(() {
                    manualLocation = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Enter Location Manually',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              // Info Cards Row
              Row(
                children: [
                  Expanded(
                    child: infoCard(
                        'Check In', checkInTime, FontAwesomeIcons.signInAlt),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: infoCard(
                        'Check Out', checkOutTime, FontAwesomeIcons.signOutAlt),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Animated Button for Check-In/Check-Out
              Center(
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: isCheckedIn
                      ? ElevatedButton(
                          key: ValueKey<bool>(isCheckedIn),
                          onPressed: () {
                            submitCheckOut();
                            _fetchCheckInStatus(); // Refresh check-in status
                          },
                          child: Text('Check Out'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            textStyle: TextStyle(fontSize: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        )
                      : ElevatedButton(
                          key: ValueKey<bool>(isCheckedIn),
                          onPressed: () {
                            submitCheckIn();
                            _fetchCheckInStatus(); // Refresh check-in status
                          },
                          child: Text('Check In'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            textStyle: TextStyle(fontSize: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavBar2(
        selectedIndex: _selectedIndex,
        onTabChange: _onTabChange,
      ),
    );
  }

  Widget infoCard(String title, String time, IconData icon) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          FaIcon(icon, color: Colors.blueAccent, size: 30),
          SizedBox(height: 10),
          Text(title,
              style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          SizedBox(height: 5),
          Text(time,
              style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[800])),
        ],
      ),
    );
  }
}
