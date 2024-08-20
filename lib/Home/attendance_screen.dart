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
  DateTime _lastDay = DateTime.now(); // Updated to include today
  DateTime? _selectedDay;
  Map<DateTime, Map<String, String>> attendanceStatus = {};
  List<DateTime> attendanceDates = [];
  List<Map<String, dynamic>> attendanceData = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission(); // Check permission once during initialization
  }

  Future<void> _checkLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        // Location permissions are permanently denied
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Location Permission Denied'),
              content: const Text(
                  'Location permissions are permanently denied. Please enable them in settings.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error checking location permission: $e');
    }
  }

  Future<void> sendAttendanceData({
    required String empId,
    required DateTime date,
    required String inTime,
    String? outTime,
    required int holidayCurrentMonth,
    required int totalHoliday,
  }) async {
    final url = Uri.parse(
        'http://$baseIpAddress/nirvan-api/employee/emp_attendance.php');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'empid': empId,
          'date': DateFormat('yyyy-MM-dd').format(date),
          'intime': inTime,
          'outtime': outTime ?? '',
          'holidaycurrentmonth': holidayCurrentMonth,
          'totalholiday': totalHoliday,
        }),
      );

      if (response.statusCode == 201 || response.body.contains("success")) {
        print('Attendance added successfully.');
      } else {
        print('Failed to add attendance: ${response.body}');
        throw Exception('Failed to add attendance: ${response.body}');
      }
    } catch (e) {
      print('Error sending attendance data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error sending attendance data.')),
      );
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
      body: Stack(
        children: [
          Column(
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
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: secondaryColorSmokewhite.withOpacity(0.2),
              child: Center(
                child: CircularProgressIndicator(
                  color: primaryColorSkyblue,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleDaySelected(
      DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _isLoading = true;
    });

    try {
      final currentDay = DateTime.now();
      final today = DateTime(currentDay.year, currentDay.month, currentDay.day);

      // Check if the selected day is not today
      if (!isSameDay(selectedDay, today)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You can only mark attendance for today."),
          ),
        );
        return;
      }

      // Check location
      final isWithinLocation = await _checkLocation();
      if (!isWithinLocation) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You are not within the attendance area.')),
        );
        return;
      }

      // Show dialog for attendance marking
      await _showAttendanceDialog(selectedDay);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? empId = prefs.getString('employeeId');

    if (empId == null) {
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
            children: [
              ListTile(
                title: const Text("I'm in"),
                onTap: () async {
                  Navigator.of(context).pop(true);
                  final inTime = _formatTime(DateTime.now());
                  await sendAttendanceData(
                    empId: empId,
                    date: selectedDay,
                    inTime: inTime,
                    outTime: attendanceStatus[selectedDay]?['outTime'],
                    holidayCurrentMonth: 0,
                    totalHoliday: 0,
                  );
                },
              ),
              ListTile(
                title: const Text("I'm out"),
                onTap: () async {
                  Navigator.of(context).pop(false);
                  final inTime =
                      attendanceStatus[selectedDay]?['inTime'] ?? '-';
                  final outTime = _formatTime(DateTime.now());
                  await sendAttendanceData(
                    empId: empId,
                    date: selectedDay,
                    inTime: inTime,
                    outTime: outTime,
                    holidayCurrentMonth: 0,
                    totalHoliday: 0,
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
            'date': DateFormat('yyyy-MM-dd').format(selectedDay),
            'attended': isAttended,
          });

          if (isAttended) {
            attendanceDates.add(selectedDay);
          }
        } else {
          if (isAttended) {
            attendanceStatus[selectedDay]!['inTime'] =
                _formatTime(DateTime.now());
          } else {
            attendanceStatus[selectedDay]!['outTime'] =
                _formatTime(DateTime.now());
          }

          attendanceData
              .where((element) =>
                  element['date'] ==
                  DateFormat('yyyy-MM-dd').format(selectedDay))
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
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  Future<bool> _checkLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      double attendanceLatitude = 22.47622550996352;
      double attendanceLongitude = 72.8083525381228;

      double distanceInMeters = await Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        attendanceLatitude,
        attendanceLongitude,
      );

      print('Current position: ${position.latitude}, ${position.longitude}');
      print('Distance to attendance location: $distanceInMeters meters');

      return distanceInMeters <= 10000;
    } catch (e) {
      print('Error fetching location: $e');
      return false;
    }
  }
}
