import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nirvan_infotech/colors/colors.dart';

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
      final response = await http.get(Uri.parse(
          'http://$baseIpAddress/nirvan-api/admin/fetch_attendance.php'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success']) {
          setState(() {
            // Filter the data for the selected month and year
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
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
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
    List<String> presentDays = [];
    List<String> absentDays = [];

    DateTime firstDayOfMonth =
        DateTime(widget.selectedYear, widget.monthIndex + 1, 1);
    DateTime lastDayOfMonth =
        DateTime(widget.selectedYear, widget.monthIndex + 2, 0);

    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      String currentDate =
          "${widget.selectedYear}-${widget.monthIndex + 1 < 10 ? '0' : ''}${widget.monthIndex + 1}-${i < 10 ? '0' : ''}$i";
      var present = _attendanceData
          .where((entry) => entry['date'] == currentDate)
          .isNotEmpty;

      if (present) {
        presentDays.add(currentDate);
      } else {
        absentDays.add(currentDate);
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Present Days',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...presentDays.map((day) => ListTile(
                title: Text(day),
              )),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Absent Days',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...absentDays.map((day) => ListTile(
                title: Text(day),
              )),
        ],
      ),
    );
  }
}
