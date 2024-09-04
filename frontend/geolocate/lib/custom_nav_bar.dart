// custom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChange;

  CustomNavBar({required this.selectedIndex, required this.onTabChange});

  get animation => null;

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: selectedIndex,
      height: 60.0,
      items: <Widget>[
        Icon(Icons.home, size: 30, color: Colors.white),
        Icon(Icons.person, size: 30, color: Colors.white),
        Icon(Icons.settings, size: 30, color: Colors.white),
      ],
      color: Colors.blueAccent,
      buttonBackgroundColor: Colors.blueAccent,
      backgroundColor: Colors.white,
      animationCurve: Curves.easeInOut,
      animationDuration: Duration(milliseconds: 600),
      onTap: onTabChange,
    );
  }
}
