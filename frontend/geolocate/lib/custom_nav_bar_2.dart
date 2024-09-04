import 'package:flutter/material.dart';

class CustomNavBar2 extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChange;

  CustomNavBar2({required this.selectedIndex, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      type: BottomNavigationBarType.fixed, // Fixed type for easier navigation
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: 30),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.exit_to_app, size: 30),
          label: 'Exit',
        ),
      ],
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      onTap: onTabChange,
    );
  }
}
