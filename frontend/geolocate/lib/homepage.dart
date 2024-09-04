import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'custom_nav_bar.dart';
import 'location.dart';
import 'dart:async';
import 'camera.dart'; // Import the CameraScreen

class HomePage extends StatefulWidget {
  final String staffId; // Add staffId as a parameter

  HomePage({required this.staffId}); // Constructor to accept staffId

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LocationService locationService = LocationService();
  String locationDetails = 'Fetching location...';
  int _selectedIndex = 0;
  String currentDate = '';
  Map<String, dynamic> attendanceData = {};
  String firstCheckIn = 'N/A';
  String lastCheckOut = 'N/A';
  bool isLoading = false;
  bool isCheckedIn = false;
  String debugInfo = '';
  List<String> notifications = []; // List to store notifications
  Timer? _timer; // Timer for periodic updates
  Timer? _checkInOutTimer; // Timer for checking in/out every 15 seconds
  Timer? _biometricsTimer; // Timer for biometrics alert
  String biometricsStatus = 'Inactive'; // Initial biometrics status

  @override
  void initState() {
    super.initState();
    locationService.requestLocationPermission();
    locationService.location.onLocationChanged.listen((locationData) {
      setState(() {
        locationDetails =
            'Lat: ${locationData.latitude}, Long: ${locationData.longitude}';
      });
    });

    currentDate = DateTime.now().toIso8601String().split('T')[0];
    fetchAttendanceData();

    // Start timer for sending location updates and checking in/out every 15 seconds
    _timer = Timer.periodic(Duration(seconds: 15), (timer) {
      if (biometricsStatus == 'Active') {
        submitAttendance(); // Send location only if biometrics is active
      }
    });

    // Start timer for checking attendance every 15 seconds
    _checkInOutTimer = Timer.periodic(Duration(seconds: 15), (timer) {
      fetchAttendanceData(); // Check for recent check-in and check-out every 15 seconds
    });

    // Start timer for biometrics alert every minute
    _biometricsTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      _showBiometricsAlert(); // Show alert every minute
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the location timer when the widget is disposed
    _checkInOutTimer?.cancel(); // Cancel the check-in/out timer
    _biometricsTimer?.cancel(); // Cancel the biometrics alert timer
    super.dispose();
  }

  void _onNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> fetchAttendanceData([String? selectedDate]) async {
    setState(() {
      isLoading = true;
      debugInfo = 'Fetching data...';
    });

    selectedDate ??= currentDate;

    try {
      final response = await http.post(
        Uri.parse('http://192.168.102.244:4000/api/app/attendanceRecord'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"staffId": widget.staffId}), // Use widget.staffId
      );

      print('API Response: ${response.body}'); // Debugging line

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          attendanceData = data;
          firstCheckIn = data['firstCheckIn'] ?? 'Not Checked In';
          lastCheckOut = data['lastCheckOut'] ?? 'Not Checked Out';
          isCheckedIn = lastCheckOut == 'N/A'; // Adjust this logic as needed
          debugInfo = 'Data fetched successfully';

          // Add notification for recent check-in/check-out
          if (data['firstCheckIn'] != null) {
            notifications.add('Checked In at ${data['firstCheckIn']}');
          }
          if (data['lastCheckOut'] != null) {
            notifications.add('Checked Out at ${data['lastCheckOut']}');
          }
        });
      } else {
        throw Exception(
            'Failed to load attendance data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching attendance data: $e');
      setState(() {
        debugInfo = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void onDateSelected(String selectedDate) {
    setState(() {
      currentDate = selectedDate;
    });
    fetchAttendanceData(selectedDate);
  }

  void _showBiometricsAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Biometrics Needed'),
        content: Text('Biometrics verification is needed.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CameraScreen(
                    onBiometricsStatusChanged: (status) {
                      setState(() {
                        biometricsStatus =
                            status; // Update status based on camera response
                      });
                    },
                  ),
                ),
              );
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> submitAttendance() async {
    final now = DateTime.now();
    final checkTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    final response = await http.post(
      Uri.parse('http://192.168.102.244:4000/api/app/geoFenceCheck'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "staffId": widget.staffId, // Use widget.staffId
        "location": locationDetails
      }),
    );

    if (response.statusCode == 200) {
      print('Attendance submitted successfully');
      final responseData = json.decode(response.body);
      // Add notification for check-in/check-out
      notifications.add('${responseData['message']} at $checkTime');
      fetchAttendanceData();
    } else {
      print('Failed to submit attendance');
      setState(() {
        debugInfo = 'Failed to submit attendance: ${response.statusCode}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          buildHomePageContent(),
          ProfilePage(),
          Center(child: Text("Settings Page")),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onTabChange: _onNavBarTap,
      ),
    );
  }

  Widget buildHomePageContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildUserInfo(),
            SizedBox(height: 20),
            buildBiometricsStatusWidget(), // Add Biometrics Status Widget
            SizedBox(height: 20),
            buildAttendanceInfo(),
            SizedBox(height: 20),
            buildLocationInfo(),
            SizedBox(height: 20),
            buildCheckInOutButton(),
            SizedBox(height: 16),
            Text('Debug Info: $debugInfo'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : fetchAttendanceData,
              child: Text('Refresh Data'),
            ),
            SizedBox(height: 20),
            buildNotificationsList(), // Add notifications list
          ],
        ),
      ),
    );
  }

  Widget buildBiometricsStatusWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Biometrics Status:',
          style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          biometricsStatus,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: biometricsStatus == 'Active' ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget buildUserInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage('assets/avatar.jpg'),
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Michael Mitc',
                style: GoogleFonts.lato(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Lead UI/UX Designer', style: GoogleFonts.lato(fontSize: 16)),
          ],
        ),
      ],
    );
  }

  Widget buildAttendanceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Attendance for $currentDate',
            style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            infoCard(
                'Check In', firstCheckIn, 'Status', FontAwesomeIcons.signInAlt),
            infoCard('Check Out', lastCheckOut, 'Status',
                FontAwesomeIcons.signOutAlt),
          ],
        ),
      ],
    );
  }

  Widget buildLocationInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Current Location:',
            style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text(
          locationDetails,
          style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[800]),
        ),
      ],
    );
  }

  Widget buildCheckInOutButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: submitAttendance,
        icon: Icon(Icons.swipe, color: Colors.white),
        label: Text(isCheckedIn ? 'Swipe to Check Out' : 'Swipe to Check In'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          textStyle: GoogleFonts.lato(fontSize: 18),
        ),
      ),
    );
  }

  Widget infoCard(String title, String time, String status, IconData icon) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            FaIcon(icon, color: Colors.blueAccent, size: 30),
            SizedBox(height: 10),
            Text(title,
                style: GoogleFonts.lato(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text(time, style: GoogleFonts.lato(fontSize: 16)),
            SizedBox(height: 5),
            Text(status,
                style: GoogleFonts.lato(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget buildNotificationsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notifications',
            style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Container(
          height: 150, // Set a fixed height for the notifications list
          child: ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(notifications[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
