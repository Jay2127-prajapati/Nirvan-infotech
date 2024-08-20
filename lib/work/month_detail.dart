import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Add for Toasts
import 'package:http/http.dart' as http;
import 'package:nirvan_infotech/colors/colors.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For SharedPreferences

import '../const fiels/const.dart';

class MonthDetailScreen extends StatefulWidget {
  final String month;
  final int monthIndex;
  final int selectedYear;

  const MonthDetailScreen({
    Key? key,
    required this.month,
    required this.monthIndex,
    required this.selectedYear,
  }) : super(key: key);

  @override
  _MonthDetailScreenState createState() => _MonthDetailScreenState();
}

class _MonthDetailScreenState extends State<MonthDetailScreen> {
  List<Map<String, dynamic>> _attendanceData = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Define Indian public holidays
  final Map<String, String> _governmentHolidays = {
    '2023-08-15': 'Independence Day',
    '2023-01-26': 'Republic Day',
    '2023-12-25': 'Christmas',
    '2023-11-12': 'Diwali',
    '2023-03-08': 'Holi',
  };

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final empId = prefs
          .getString('employeeId'); // Retrieve empId from SharedPreferences

      // Debug: Print the retrieved empId
      print('Retrieved empId: $empId');

      if (empId == null) {
        setState(() {
          _errorMessage = 'User not logged in';
          _isLoading = false;
        });
        return;
      }

      // Create the JSON payload
      final payload = json.encode({
        'empId': empId,
        'month': widget.monthIndex + 1,
        'year': widget.selectedYear,
      });

      // Print the payload for debugging
      print('Request payload: $payload');

      final response = await http.post(
        Uri.parse(
            'http://$baseIpAddress/nirvan-api/employee/employee_attendance_fetch.php'),
        headers: {"Content-Type": "application/json"},
        body: payload,
      );

      // Print response status and body for debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Print decoded data for debugging
        print('Decoded response data: $data');

        if (data['success']) {
          setState(() {
            _attendanceData =
                List<Map<String, dynamic>>.from(data['attendance'])
                    .where((entry) {
              final DateTime date = DateTime.parse(entry['date']);
              return date.month == widget.monthIndex + 1 &&
                  date.year == widget.selectedYear;
            }).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Failed to load data';
            _isLoading = false;
          });
          print(
              'Error message from API: ${data['message']}'); // Print error message from API
        }
      } else {
        setState(() {
          _errorMessage =
              'Failed to load data: HTTP status ${response.statusCode}';
          _isLoading = false;
        });
        print(
            'Failed to load data: HTTP status ${response.statusCode}'); // Print HTTP status code
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
      print('Error occurred: $e'); // Print error details
    }
  }

  // Check if the date is a holiday (weekend or government holiday)
  bool _isHoliday(DateTime date) {
    String formattedDate =
        "${date.year}-${date.month < 10 ? '0' : ''}${date.month}-${date.day < 10 ? '0' : ''}${date.day}";

    return date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday ||
        _governmentHolidays.containsKey(formattedDate);
  }

  // Get the specific holiday description
  String _getHolidayDescription(DateTime date) {
    String formattedDate =
        "${date.year}-${date.month < 10 ? '0' : ''}${date.month}-${date.day < 10 ? '0' : ''}${date.day}";

    if (date.weekday == DateTime.saturday) {
      return "Weekend holiday, it's Saturday";
    } else if (date.weekday == DateTime.sunday) {
      return "Weekend holiday, it's Sunday";
    } else if (_governmentHolidays.containsKey(formattedDate)) {
      return _governmentHolidays[formattedDate]!;
    }
    return '';
  }

  // Show a toast message when a date is tapped
  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[800],
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.month} ${widget.selectedYear}',
          style: const TextStyle(
            color: secondaryColorSmokewhite,
            fontFamily: 'poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryColorOcenblue,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
          color: secondaryColorSmokewhite,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _buildAttendanceList(),
    );
  }

  Widget _buildAttendanceList() {
    DateTime firstDayOfMonth =
        DateTime(widget.selectedYear, widget.monthIndex + 1, 1);
    DateTime lastDayOfMonth =
        DateTime(widget.selectedYear, widget.monthIndex + 2, 0);

    List<Widget> dayTiles = [];

    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      String currentDate =
          "${widget.selectedYear}-${widget.monthIndex + 1 < 10 ? '0' : ''}${widget.monthIndex + 1}-${i < 10 ? '0' : ''}$i";

      DateTime date = DateTime(widget.selectedYear, widget.monthIndex + 1, i);
      // Filter present data including in-time and out-time
      var presentEntry = _attendanceData.firstWhere(
          (entry) => entry['date'] == currentDate,
          orElse: () => {});

      bool present = presentEntry.isNotEmpty;

      Color tileColor;
      String statusText;
      String inTime = '';
      String outTime = '';

      if (_isHoliday(date)) {
        tileColor = Colors.orange; // Holiday
        statusText = _getHolidayDescription(date);
      } else if (present) {
        tileColor = Colors.green; // Present
        statusText = 'Present';
        inTime = presentEntry['intime'] ?? 'N/A';
        outTime = presentEntry['outtime'] ?? 'N/A';
      } else {
        tileColor = Colors.red; // Absent
        statusText = 'Absent';
      }

      dayTiles.add(
        GestureDetector(
          onTap: () {
            if (_isHoliday(date)) {
              _showToast(statusText); // Show holiday toast
            } else {
              String message = present
                  ? 'In-Time: $inTime\nOut-Time: $outTime'
                  : 'Attendance status: $statusText';
              _showToast(message); // Show in/out time or absent
            }
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ListTile(
              title: Text(
                currentDate,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: tileColor,
                ),
              ),
              subtitle: present
                  ? Text('In-Time: $inTime | Out-Time: $outTime',
                      style: TextStyle(color: tileColor))
                  : null,
              trailing: Text(
                statusText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: tileColor,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: dayTiles,
      ),
    );
  }
}
