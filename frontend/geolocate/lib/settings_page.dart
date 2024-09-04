import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text('Location Permissions'),
              trailing: Switch(
                value: true, // Assume location permission is enabled
                onChanged: (value) {
                  // Handle location permission toggle
                  print('Location permission: $value');
                },
              ),
            ),
            Divider(),
            ListTile(
              title: Text('Geofence Radius'),
              subtitle: Text('Set the radius in meters'),
              trailing: DropdownButton<int>(
                value: 100, // Default value
                items: <int>[50, 100, 200, 500].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value m'),
                  );
                }).toList(),
                onChanged: (newValue) async {
                  // Save selected radius in SharedPreferences
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setInt('geofence_radius', newValue!);
                  print('Geofence radius set to: $newValue m');
                },
              ),
            ),
            Divider(),
            ListTile(
              title: Text('Enable Notifications'),
              trailing: Switch(
                value: true, // Assume notifications are enabled
                onChanged: (value) async {
                  // Handle notification toggle
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool('notifications_enabled', value);
                  print('Notifications enabled: $value');
                },
              ),
            ),
            Divider(),
            ListTile(
              title: Text('Auto Check-in'),
              trailing: Switch(
                value: false, // Assume auto-check-in is disabled by default
                onChanged: (value) async {
                  // Handle auto-check-in toggle
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool('auto_check_in', value);
                  print('Auto check-in enabled: $value');
                },
              ),
            ),
            Divider(),
            ListTile(
              title: Text('Alert Frequency'),
              subtitle: Text('Set the frequency of alerts'),
              trailing: DropdownButton<String>(
                value: 'Medium', // Default value
                items: <String>['Low', 'Medium', 'High'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) async {
                  // Save selected alert frequency in SharedPreferences
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setString('alert_frequency', newValue!);
                  print('Alert frequency set to: $newValue');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
