import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraScreen extends StatefulWidget {
  final Function(String) onBiometricsStatusChanged;

  CameraScreen({required this.onBiometricsStatusChanged});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _image;
  String? staffId;

  @override
  void initState() {
    super.initState();
    _retrieveStaffId(); // Retrieve staff ID when the widget initializes
  }

  // Method to retrieve the staff ID from SharedPreferences
  Future<void> _retrieveStaffId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      staffId = prefs.getString('staffId'); // Use consistent key name 'staffId'
      if (staffId == null || staffId!.isEmpty) {
        staffId = 'unknown'; // Fallback if there's no staff ID
      }
    });
  }

  // Method to pick an image from the camera
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Set the picked image file
      });

      // Call the backend to send the image
      await _uploadImage(_image!);
    }
  }

  // Method to upload the image and staff ID to the backend
  Future<void> _uploadImage(File image) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://192.168.102.3:8000/matchUser'));

    // Add the image file to the request
    request.files.add(await http.MultipartFile.fromPath('Image', image.path));

    // Include other fields in the request
    request.fields['office_id'] = 'ABC12'; // Example office ID
    request.fields['employee_id'] = staffId ?? 'unknown'; // Include staff ID
    request.fields['name'] = 'Mohan'; // Example name

    try {
      var response = await request.send(); // Send the request
      var responseData =
          await http.Response.fromStream(response); // Get response

      print(
          'Face Recognition Response: ${responseData.body}'); // Debugging response

      if (response.statusCode == 200) {
        var responseJson =
            json.decode(responseData.body); // Decode JSON response
        print(responseJson);

        // Check for a successful match
        if (responseJson['result'] == 'Match found') {
          widget
              .onBiometricsStatusChanged('Active'); // Update biometrics status
          Navigator.pop(context); // Go back to previous screen
        } else {
          _showUnauthorizedMessage(); // Show unauthorized message
        }
      } else {
        _showUnauthorizedMessage(); // Show unauthorized message
      }
    } catch (e) {
      print('Error in face recognition: $e'); // Log error
      _showUnauthorizedMessage(); // Show unauthorized message
    }
  }

  // Method to show an unauthorized message
  void _showUnauthorizedMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unauthorized'),
        content: Text('Face recognition failed. Unauthorized user.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Build the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Recognition'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null ? Text('No image selected.') : Image.file(_image!),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage, // Trigger image picking
              child: Text('Take Photo'),
            ),
          ],
        ),
      ),
    );
  }
}
