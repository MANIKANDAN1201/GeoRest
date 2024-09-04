import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // For local storage
import 'dart:async';
import 'dart:convert';

class LocationService {
  final String backendUrl =
      'http://192.168.102.81:4000/api/app/mark-attendance';
  loc.Location location = loc.Location();
  double? lastLatitude;
  double? lastLongitude;

  LocationService() {
    requestLocationPermission();
  }

  Future<void> requestLocationPermission() async {
    var status = await perm.Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      status = await perm.Permission.locationWhenInUse.request();
    }

    if (status.isGranted) {
      // Request background location permission
      var backgroundStatus = await perm.Permission.locationAlways.status;
      if (!backgroundStatus.isGranted) {
        backgroundStatus = await perm.Permission.locationAlways.request();
      }

      if (backgroundStatus.isGranted) {
        bool serviceEnabled = await location.serviceEnabled();
        if (!serviceEnabled) {
          serviceEnabled = await location.requestService();
          if (!serviceEnabled) {
            print('Location services are disabled.');
            return;
          }
        }
        // Enable background mode for location updates
        bool backgroundModeEnabled =
            await location.enableBackgroundMode(enable: true);
        if (!backgroundModeEnabled) {
          print('Failed to enable background mode.');
          return;
        }
        // Start location updates
        startTrackingLocation();
      } else {
        print('Background location permission denied.');
      }
    } else {
      print('Location permission denied.');
    }
  }

  void startTrackingLocation() async {
    await location.changeSettings(
      accuracy: loc.LocationAccuracy.high, // Use best accuracy available
      interval: 10000, // Update every 10 seconds
      distanceFilter: 0, // Report every movement
    );

    // Listen to location changes
    location.onLocationChanged.listen((loc.LocationData locationData) async {
      double? latitude = locationData.latitude;
      double? longitude = locationData.longitude;

      if (latitude != null && longitude != null) {
        // Update location regardless of whether it has changed significantly
        print('Location updated: Lat=$latitude, Long=$longitude');
        await sendLocationToBackend(latitude, longitude);
      }
    });
  }

  Future<void> sendLocationToBackend(double latitude, double longitude) async {
    try {
      // Retrieve the staff ID from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? staffId = prefs.getString('staffId');

      if (staffId == null) {
        print('Staff ID not found. Please login again.');
        return;
      }

      // Print the staffId in the console for debugging
      print('Sending location for staffId: $staffId');

      final response = await http.post(
        Uri.parse(backendUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'staffId': staffId, // Include staff ID
          'latitude': latitude,
          'longitude': longitude,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        print('Location sent successfully');
      } else {
        print('Failed to send location: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending location: $e');
    }
  }

  void stopTrackingLocation() {
    location.enableBackgroundMode(enable: false);
  }

  void dispose() {
    stopTrackingLocation();
  }
}
