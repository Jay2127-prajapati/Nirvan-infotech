// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:nirvan_infotech/colors/colors.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:nirvan_infotech/Home/notification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../const fiels/const.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _firstDay = DateTime.utc(2024, 1, 1);
  DateTime _lastDay = DateTime.utc(2024, 12, 31);
  DateTime? _selectedDay;
  Map<DateTime, Map<String, String>> attendanceStatus = {};
  List<DateTime> attendanceDates = [];
  List<Map<String, dynamic>> attendanceData = [];

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    try {
      LocationPermission permission;
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        bool enableResult = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Location Services Disabled'),
              content: const Text(
                  'Please enable location services to use this feature.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('Enable'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );

        if (enableResult == true) {
          permission = await Geolocator.requestPermission();
        } else {
          return;
        }
      } else {
        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
      }

      if (permission == LocationPermission.denied) {
        print('Location permissions are denied.');
      } else if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied.');
      } else {
        print('Location permissions granted!');
      }
    } catch (e) {
      print('Error checking location permission: $e');
    }
  }

  Future<void> sendAttendanceData({
    required String empId,
    required DateTime date,
    required String inTime,
    String? outTime, // Allow null for outTime
    required int holidayCurrentMonth,
    required int totalHoliday,
  }) async {
    final url = Uri.parse(
        'http://$baseIpAddress/nirvan-api/employee/emp_attendance.php');

    // Debugging: Check which fields are present
    List<String> missingFields = [];
    if (empId.isEmpty) missingFields.add('empId');
    if (inTime.isEmpty) missingFields.add('inTime');
    if (holidayCurrentMonth < 0) missingFields.add('holidayCurrentMonth');
    if (totalHoliday < 0) missingFields.add('totalHoliday');

    if (missingFields.isNotEmpty) {
      print('Missing fields: ${missingFields.join(', ')}');
      return;
    }

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'empid': empId,
        'date': DateFormat('yyyy-MM-dd').format(date),
        'intime': inTime,
        'outtime': outTime ?? '', // Send empty string if outTime is null
        'holidaycurrentmonth': holidayCurrentMonth,
        'totalholiday': totalHoliday,
      }),
    );

    if (response.statusCode == 201) {
      print('Attendance added successfully.');
    } else {
      // Print response body for debugging
      print('Failed to add attendance: ${response.body}');
      throw Exception('Failed to add attendance: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance',
          style: TextStyle(
            color: primaryColorWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColorOcenblue,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
            icon: const Icon(Icons.notifications),
            color: primaryColorWhite,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TableCalendar(
                    firstDay: _firstDay,
                    lastDay: _lastDay,
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) =>
                        isSameDay(_selectedDay, day) ||
                        attendanceDates.contains(day),
                    onDaySelected: (selectedDay, focusedDay) {
                      _handleDaySelected(selectedDay, focusedDay);
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: primaryColorNaiveblue.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: primaryColorNaiveblue,
                        shape: BoxShape.circle,
                      ),
                      weekendTextStyle: const TextStyle(color: warningRed),
                    ),
                    headerStyle: const HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                    ),
                  ),
                  const Divider(thickness: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Attendance Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                // Implement search functionality
                              },
                              icon: const Icon(Icons.search),
                              color: primaryColorNaiveblue,
                            ),
                            IconButton(
                              onPressed: () {
                                // Implement filter functionality
                              },
                              icon: const Icon(Icons.filter_list),
                              color: primaryColorNaiveblue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: attendanceData.length,
                    itemBuilder: (context, index) {
                      final data = attendanceData[index];
                      final entryTime =
                          attendanceStatus[data['date']]?['inTime'] ?? '-';
                      final exitTime =
                          attendanceStatus[data['date']]?['outTime'] ?? '-';
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue, width: 1.0),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                '${data['date'].day}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text('Entry: $entryTime - Exit: $exitTime'),
                            subtitle: Text(
                              data['attended']
                                  ? 'Welcome To Nirvan Institute'
                                  : 'Thanks for your time.\nYour day is completed.',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    await _showAttendanceDialog(selectedDay);
  }

  Future<void> _showAttendanceDialog(DateTime selectedDay) async {
    bool hasExistingData = attendanceStatus.containsKey(selectedDay);

    bool isWithinLocation = await _checkLocation();

    if (!isWithinLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You are not within the attendance area.')),
      );
      return;
    }

    String entryTime = '-';
    String exitTime = '-';

    if (hasExistingData) {
      entryTime = attendanceStatus[selectedDay]!['inTime'] ?? '-';
      exitTime = attendanceStatus[selectedDay]!['outTime'] ?? '-';
    }

    // Retrieve empId from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? empId = prefs.getString('empId');

    if (empId == null) {
      // Handle the case where empId is not found
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee ID not found.')),
      );
      return;
    }

    bool? isAttended = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              "Attendance for ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: const Text("I'm in"),
                onTap: () async {
                  Navigator.of(context).pop(true);
                  final inTime = _formatTime(DateTime.now());
                  final outTime = null; // Set to null or empty string
                  await sendAttendanceData(
                    empId: empId,
                    date: selectedDay,
                    inTime: inTime,
                    outTime: outTime,
                    holidayCurrentMonth: 0, // Example data
                    totalHoliday: 0, // Example data
                  );
                },
              ),
              ListTile(
                title: const Text("I'm out"),
                onTap: () async {
                  Navigator.of(context).pop(false);
                  final inTime =
                      attendanceStatus[selectedDay]!['inTime'] ?? '-';
                  final outTime = _formatTime(DateTime.now());
                  await sendAttendanceData(
                    empId: empId,
                    date: selectedDay,
                    inTime: inTime,
                    outTime: outTime,
                    holidayCurrentMonth: 0, // Example data
                    totalHoliday: 0, // Example data
                  );
                },
              ),
            ],
          ),
        );
      },
    );

    if (isAttended != null) {
      setState(() {
        if (!hasExistingData) {
          attendanceStatus[selectedDay] = {
            'inTime': isAttended ? _formatTime(DateTime.now()) : '-',
            'outTime': isAttended ? '-' : _formatTime(DateTime.now()),
          };

          attendanceData.add({
            'date': selectedDay,
            'attended': isAttended,
          });

          if (isAttended) {
            attendanceDates.add(selectedDay);
          }
        } else {
          attendanceStatus[selectedDay]!['outTime'] =
              _formatTime(DateTime.now());

          attendanceData
              .where((element) => element['date'] == selectedDay)
              .forEach((element) {
            element['attended'] = isAttended;
          });

          if (isAttended) {
            if (!attendanceDates.contains(selectedDay)) {
              attendanceDates.add(selectedDay);
            }
          } else {
            attendanceDates.remove(selectedDay);
          }
        }
      });
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}'; // Format as HH:mm:ss
  }

  Future<bool> _checkLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      double attendanceLatitude = 22.561703;
      double attendanceLongitude = 72.922973;

      double distanceInMeters = await Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        attendanceLatitude,
        attendanceLongitude,
      );

      return distanceInMeters <= 100;
    } catch (e) {
      print('Error fetching location: $e');
      return false;
    }
  }
}
