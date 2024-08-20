import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nirvan_infotech/colors/colors.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../const fiels/const.dart';

class EachEmployeeAttendance extends StatefulWidget {
  final String empId;

  const EachEmployeeAttendance({Key? key, required this.empId})
      : super(key: key);

  @override
  State<EachEmployeeAttendance> createState() => _EachEmployeeAttendanceState();
}

class _EachEmployeeAttendanceState extends State<EachEmployeeAttendance> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  bool _isLoading = true;
  String _errorMessage = '';
  List<DateTime> _presentDates = [];
  late DateTime _currentMonth;
  late List<String> _months;
  late List<int> _years;
  late String _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    _selectedMonth = DateFormat('MMMM').format(_currentMonth);
    _selectedYear = _currentMonth.year;
    _months = List.generate(
        12, (index) => DateFormat('MMMM').format(DateTime(0, index + 1, 1)));
    _years = List.generate(11,
        (index) => DateTime.now().year - 5 + index); // Example range of years
    _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
            'http://$baseIpAddress/nirvan-api/admin/employe_detail_atten.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'empId': widget.empId}),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        print('Decoded Data: $data');

        if (data['success']) {
          setState(() {
            _presentDates = (data['attendance'] as List)
                .map((dateString) => DateFormat('yyyy-MM-dd').parse(dateString))
                .map((date) => DateTime(date.year, date.month, date.day))
                .toList();
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
          _errorMessage =
              'Failed to load data. Status code: ${response.statusCode}';
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

  void _onMonthChanged(String? month) {
    if (month != null) {
      setState(() {
        _selectedMonth = month;
        _currentMonth = DateFormat('MMMM').parse(month);
        _focusedDay =
            DateTime(_selectedYear, _currentMonth.month, _focusedDay.day);
        _fetchAttendanceData();
      });
    }
  }

  void _onYearChanged(int? year) {
    if (year != null) {
      setState(() {
        _selectedYear = year;
        _currentMonth = DateTime(year, _currentMonth.month, 1);
        _focusedDay =
            DateTime(_selectedYear, _currentMonth.month, _focusedDay.day);
        _fetchAttendanceData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter =
        DateFormat('yyyy-MM-dd'); // Define the date format

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Employee Attendance",
          style: TextStyle(
            color: primaryColorWhite,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColorOcenblue,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: DropdownButton<String>(
                              value: _selectedMonth,
                              items: _months.map((month) {
                                return DropdownMenuItem(
                                  value: month,
                                  child: Text(month),
                                );
                              }).toList(),
                              onChanged: _onMonthChanged,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButton<int>(
                              value: _selectedYear,
                              items: _years.map((year) {
                                return DropdownMenuItem(
                                  value: year,
                                  child: Text(year.toString()),
                                );
                              }).toList(),
                              onChanged: _onYearChanged,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        calendarStyle: CalendarStyle(
                          cellMargin: const EdgeInsets.all(4.0),
                          cellPadding: const EdgeInsets.all(4.0),
                          selectedDecoration: const BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration:
                              BoxDecoration(), // Empty decoration for today
                          todayTextStyle: const TextStyle(
                              color:
                                  Colors.black), // Keep default color for today
                          selectedTextStyle:
                              const TextStyle(color: Colors.white),
                          defaultDecoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          defaultTextStyle:
                              const TextStyle(color: Colors.black),
                        ),
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) {
                            final isPresent = _presentDates.any((date) =>
                                date.year == day.year &&
                                date.month == day.month &&
                                date.day == day.day);

                            Color textColor;

                            if (isPresent) {
                              textColor = Colors.green;
                              FontWeight.bold;
                            } else if (day.weekday == DateTime.saturday ||
                                day.weekday == DateTime.sunday) {
                              textColor = Colors.orange;
                            } else {
                              textColor = Colors.black;
                            }

                            return Center(
                              child: Text(
                                '${day.day}',
                                style: TextStyle(color: textColor),
                              ),
                            );
                          },
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleTextStyle: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          leftChevronIcon: Icon(
                            Icons.chevron_left,
                            color: Colors.blue,
                          ),
                          rightChevronIcon: Icon(
                            Icons.chevron_right,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Selected Date: ${formatter.format(_selectedDay)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
