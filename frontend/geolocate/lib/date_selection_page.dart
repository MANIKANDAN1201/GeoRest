// lib/date_selection_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Add this package to format dates

class DateSelectionPage extends StatefulWidget {
  final String currentDate;
  final Function(String) onDateSelected;

  DateSelectionPage({required this.currentDate, required this.onDateSelected});

  @override
  _DateSelectionPageState createState() => _DateSelectionPageState();
}

class _DateSelectionPageState extends State<DateSelectionPage> {
  late String _selectedDate;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.currentDate;
    _currentMonth =
        DateTime.parse(widget.currentDate); // Initialize with current date
  }

  void _handleDateSelection(String date) {
    setState(() {
      _selectedDate = date;
    });
    widget.onDateSelected(date); // Notify parent widget of the selection
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_left),
                onPressed: () {
                  setState(() {
                    _currentMonth =
                        DateTime(_currentMonth.year, _currentMonth.month - 1);
                  });
                },
              ),
              Text(
                DateFormat('MMMM yyyy').format(_currentMonth),
                style:
                    GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.arrow_right),
                onPressed: () {
                  setState(() {
                    _currentMonth =
                        DateTime(_currentMonth.year, _currentMonth.month + 1);
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 10),
          // Date Selector
          Container(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _getDaysInMonth(_currentMonth),
              itemBuilder: (context, index) {
                final date = DateTime(
                    _currentMonth.year, _currentMonth.month, index + 1);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: dateWidget(
                    DateFormat('dd').format(date),
                    DateFormat('EEE').format(date),
                    DateFormat('yyyy-MM-dd').format(date),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getDaysInMonth(DateTime month) {
    return DateTime(month.year, month.month + 1, 0).day;
  }

  Widget dateWidget(String day, String label, String date) {
    final bool isActive = _selectedDate == date;

    return GestureDetector(
      onTap: () => _handleDateSelection(date),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(day,
                style: GoogleFonts.lato(
                    fontSize: 16,
                    color: isActive ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold)),
            Text(label,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: isActive ? Colors.white : Colors.black,
                )),
          ],
        ),
      ),
    );
  }
}